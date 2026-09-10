# excelImport 接口性能分析与优化方案

> 接口：`POST /api/admin/recommendProduct/excelImport`
> 入口：`AdminRecommendProductController#excelImport`
> 核心实现：`AdminRecommendProductService#excelImport`（liupin-custom-service）
> 现象：导入十余条记录的 Excel，整体耗时十几秒。

---

## 一、接口处理流程概览

`excelImport(platId, userType=null, categoryId, imgFile)` 分两阶段：

**阶段 A —— Excel 解析与校验（`stream().map(...)`，逐行）**
对每一行：
1. 读取品名/描述/笔头编码/笔杆编码/关注底数；
2. `productSkusMapper.getByNo(penPointSkuCode)` —— DB 查询笔头 SKU（1 次）；
3. `productSkusMapper.getByNo(penHolderSkuCode)` —— DB 查询笔杆 SKU（1 次）；
4. `customService.getAdminCustomLettering(point, holder)` —— 内部又做 `productSkusService.getSkuBySkuCode(point)` + `getSkuBySkuCode(holder)` 两次 DB 查询，再 `adminCustomLetteringService.getByPointProductIdAndHolderProductId(...)` 一次 DB 查询。

**阶段 B —— 合成效果图（`products.forEach(...)`，逐行，串行）**
对每一行：
1. `customService.getAdminCustomLettering(...)` —— **重复执行**阶段 A 第 4 步（3 次 DB 查询，本可复用）；
2. `customService.checkLocationParam(...)` —— 内存校验，廉价；
3. `customService.getAdminCustomLettering(...)` —— **再次重复**（第 201 行，返回值甚至没被使用，纯浪费，3 次 DB 查询）；
4. `customService.drawPic1(...)` → `getDrawPic(...)`：
   - `FileUtils.transferFile(pointHolderPic, ...)` —— **从远程 URL 下载笔杆图到本地磁盘**（网络 I/O）；
   - `Font.createFont(TRUETYPE_FONT, new File(fontPathProperties.getLishu()))` —— **每次都从磁盘重新加载字体文件**；
   - `DrawUtil.textOnImage(...)` —— Java2D 绘文字到图片并 `ImageIO.write` 写本地 PNG（CPU + 磁盘）；
   - `cosFileService.xsjyUpload(imageOutPath, ...)` —— **上传到腾讯云 COS**（网络 I/O，含失败最多重试 3 次）；
   - 删除中间文件。
5. `customService.adminRecommendPic(...)`：
   - `FileUtils.transferFile2(pointHolderPic, ...)` —— **再次从远程 URL 下载**同一张笔杆图（第 2 次下载同一图）；
   - `adminCustomLetteringService.getById(letteringId)` —— 又一次 DB 查询（本可复用上面的 lettering）；
   - `drawService.merge(...)`：`ImageIO.read` 读底图 + 旋转/缩放/合成（3 次 Graphics2D 绘制 + `ImageIO.write` 写本地 PNG，CPU + 磁盘，代码内自带耗时日志）；
   - `cosFileService.xsjyUpload(outPath, ...)` —— **第二次上传 COS**（网络 I/O）；
   - 删除中间文件。

**阶段 C**：`batchInsert(products)` 批量入库（1 次 DB，廉价）。

---

## 二、性能瓶颈定位

按对"十余条耗时十几秒"的贡献从大到小排序：

### 瓶颈 1：每行 2 次远程图片上传到 COS（网络 I/O，最大头）
- `drawTextOnPenHolder` 内 1 次 `xsjyUpload`，`merge` 内 1 次 `xsjyUpload`，**每行 2 次同步上传**。
- `uploadByLocalFile` 直接 `cosClient.putObject(...)` 同步阻塞；失败时 `xsjyUpload` 还会 **do-while 重试最多 3 次**，单次失败会把耗时放大数倍。
- 10 行 = 20 次上传。COS 单次上传（含建连、传输、服务端处理）通常 300ms~1s+，20 次很容易累计到 6~15 秒。**这是十几秒的主要来源。**
- 证据：`CosFileService#xsjyUpload` / `uploadByLocalFile`（tencent-spring-boot-starter）。

### 瓶颈 2：每行 2 次远程图片下载（网络 I/O）
- `getDrawPic` 内 `FileUtils.transferFile(pointHolderPic, ...)` 从 URL 下载笔杆图；
- `adminRecommendPic` 内 `FileUtils.transferFile2(pointHolderPic, ...)` **下载同一张图**。
- `pointHolderPic` 来自 `lettering.getPointHolderPic()`，对同一 `lettering`（同一笔头笔杆组合）图片是固定的，**同一组合下载两次是纯浪费**；不同行若组合相同也重复下载。
- 10 行 = 20 次下载。证据：`FileUtils#transferFile` / `transferFile2`（liupin-common）。

### 瓶颈 3：图片合成是 CPU 密集 + 串行执行（无法并发）
- `merge` 里做了：旋转 → 缩放 → 与底图合成，3 次创建 `BufferedImage` + `Graphics2D` 绘制，最后 `ImageIO.write` 写 PNG。代码内已有 `log.info("分享图合成 ... 总耗时 ：{} ")`，单次通常几百毫秒到 1 秒。
- `textOnImage` 同样一次 Java2D 绘制 + 写 PNG。
- 这两步每行各一次，且 **`forEach` 串行**，10 行 = 10 次旋转合成 + 10 次文字绘制，累计可达数秒。
- 证据：`DrawService#merge` / `DrawUtil#textOnImage`。

### 瓶颈 4：DB 查询大量重复，存在 N+1（每行 ~9 次 DB 往返）
逐行统计 DB 查询次数（阶段 A + 阶段 B）：
- 阶段 A：`getByNo` ×2 + `getAdminCustomLettering`（内含 `getSkuBySkuCode` ×2 + `getByPointProductIdAndHolderProductId` ×1）= **5 次**；
- 阶段 B：`getAdminCustomLettering` ×2（其中一次返回值未使用）+ `adminRecommendPic` 内 `getById` ×1 = **7 次**。
- 合计 **每行约 12 次 DB 往返**，10 行 ≈ 120 次。即便单次 2~5ms，也累计 0.2~0.6s，且会与上述网络/IO 交错放大总时长。
- 同一组合的 lettering / sku 在同一请求内被反复查 3~4 次。证据：`excelImport` 第 184、199、201 行 + `adminRecommendPic` 第 850 行。

### 瓶颈 5：字体文件每次都从磁盘重新加载
- `getDrawPic` 第 673 行：`Font.createFont(Font.TRUETYPE_FONT, new File(fontPathProperties.getLishu()))` 每行执行一次，每次都重新读取 `.ttf` 并注册到本地字体环境。
- 字体文件不大，单次几十毫秒，但 10 行累计也有几百毫秒，且属可消除的纯重复开销。
- 证据：`CustomService#getDrawPic`。

### 瓶颈 6：底图每行重复读盘
- `adminRecommendPic` 每行 `ImageIO.read(new File(basePicPath))` 读底图（虽有"不存在则下载"的缓存逻辑，但 **读盘/解码每行都做**）。底图按 `platId` 维度是固定的，可只解码一次复用。
- 证据：`DrawService#merge` 第 136 行。

### 其它次要问题
- 第 201 行 `customService.getAdminCustomLettering(...)` 调用结果未被使用，是明显的冗余调用（可顺带删除，消除 3 次 DB 往返/行）。
- 第 174 行 `skuCodeException.add(penPointSkuCode)` 应为 `penHolderSkuCode`（复制粘贴 bug，与性能无关，但建议一并修正）。
- `excelImport` 整个方法无 `@Transactional`，但流程里只有最后 `batchInsert` 写库，前面都是图片处理，事务意义不大；失败时已上传的 COS 图片会残留（一致性/存储成本问题，非性能）。

---

## 三、优化方案

按 **性价比（收益/改动成本）** 从高到低排列。建议至少落地方案 1~3，可覆盖绝大部分耗时。

### 方案 1：消除重复 DB 查询，按请求缓存 lettering / sku（收益高，改动小）
- 阶段 A 已经查到的 `AdminCustomLettering` 直接挂到 `product`（或用 `Map<pointCode+holderCode, AdminCustomLettering>` 缓存），阶段 B 复用，**删除第 199、201 行的重复 `getAdminCustomLettering` 调用**（第 201 行本就未使用）。
- `adminRecommendPic` 内的 `getById(letteringId)` 也改为复用传入的 lettering 对象，不再单独查。
- `getByNo`（阶段 A）与 `getSkuBySkuCode`（`getAdminCustomLettering` 内）查的是同一批 sku，可合并：阶段 A 查到的 sku 信息缓存后直接用，避免 `getAdminCustomLettering` 内再查两次。
- 预期：每行 DB 往返从 ~12 次降到 ~3 次（甚至更少），整体可省 0.2~0.6s，并减少与网络 IO 的交错。

### 方案 2：合并两次图片合成为一次本地流水线，避免重复下载/上传（收益高，改动中）
- 当前链路：下载笔杆图 → 绘文字 → 上传 COS(drawPic) → 再下载同一笔杆图 → 旋转合成 → 上传 COS(merge)。
- 优化：**只下载一次笔杆图**，在内存中完成"绘文字 → 旋转 → 缩放 → 与底图合成"全流程，最终 `BufferedImage` 直接 `xsjyUpload`（用 `uploadByByteArray` 上传字节数组，避免再落盘），**每行从 2 次下载 + 2 次上传 降为 1 次下载 + 1 次上传**。
- 即把 `drawPic1` 与 `adminRecommendPic` 合并为一个方法，全程 `BufferedImage` 在内存传递，不写中间 PNG。
- 预期：网络往返减半（上传 20→10、下载 20→10），是降耗最大的一项，可省数秒。

### 方案 3：并行化逐行处理（收益高，改动中）
- 当前 `products.forEach` 串行，10 行串行做图片合成。
- 改为用线程池并行（注意：Java2D `Graphics2D` 非线程安全，**每个任务内部各自创建自己的 `BufferedImage`/`Graphics2D`**，不要共享；`ImageIO` 写不同文件路径也安全）。
- 并发度建议 4~8（受限于 CPU 核数与 COS 并发上限），用 `ThreadPoolExecutor` 或 `CompletableFuture`。
- 注意 `ArrayList<String> skuCodeException` 在并行下要换成线程安全集合或预校验后再并行合成。
- 预期：在 4~8 并发下，图片合成阶段（瓶颈 1+2+3）整体可降至原来的 1/4 ~ 1/8。

### 方案 4：字体与底图只加载一次复用（收益中，改动小）
- 字体：`getDrawPic` 里把 `Font.createFont(...).deriveFont(...)` 的结果按 `size` 缓存（字段或 `ConcurrentHashMap<Integer, Font>`），整个请求/进程复用。
- 底图：`adminRecommendPic` 里按 `platId` 缓存解码后的 `BufferedImage baseImage`（注意 `merge` 会 `createGraphics` 并在其上绘制——并行时要每个任务 `clone`/重新读或用不可变副本，避免并发污染底图；最稳妥是缓存"底图文件路径已存在"并每个任务各自 `ImageIO.read` 读一份，省掉下载但不共享 `BufferedImage`）。
- 预期：省掉每行字体加载 + 底图下载/解码，累计几百毫秒~1s。

### 方案 5：改为异步任务 + 轮询/回调（收益看场景，改动大）
- 若业务允许，前端提交后立即返回任务 ID，后台异步跑完再通知/落库，前端轮询进度。把"十几秒"移出请求链路。
- 适合导入量可能继续增长（几十上百条）的场景。可与方案 1~3 叠加。

### 方案 6：COS 上传参数调优（收益小，改动小）
- 确认 `cosClient` 的 `ClientConfig` 是否设置了合理的连接超时/Socket 超时/Region；当前 `uploadByLocalFile` 用 `cosClient.putObject` 小文件同步上传，可评估用 `TransferManager` 异步上传或开启连接池复用。
- `xsjyUpload` 的"失败重试 3 次"在正常情况下不触发，但一旦网络抖动会显著放大耗时，建议加超时上限与监控告警。

---

## 四、预期收益估算（十余条记录）

| 优化项 | 主要消除 | 预计节省 |
|---|---|---|
| 方案 1 去重复 DB | ~120 次 → ~30 次 DB 往返 | 0.2~0.6s |
| 方案 2 合并下载/上传 | 上传 20→10、下载 20→10 | 数秒（最大头） |
| 方案 3 并行合成 | 串行 → 4~8 并发 | 合成阶段降至 1/4~1/8 |
| 方案 4 字体/底图复用 | 每行加载字体/读底图 | 0.3~1s |
| 合计（1+2+3+4） | — | 十余秒可降至 1~3 秒量级 |

> 估算基于代码静态分析，实际耗时分布建议以日志为准：`DrawService.merge` 已打印"旋转/resize/总耗时"，`DrawUtil.textOnImage` 已打印"耗时"，`CosFileService` 上传无耗时日志——**建议先在上传方法补一行耗时日志**，用真实数据校准上述占比，再决定优先级。

---

## 五、推荐落地顺序

1. **先补日志**（上传/下载/DB 各打点），用一次真实导入确认瓶颈占比（建议）。
2. **方案 1**（去重复 DB，含删除第 201 行无用调用、修正第 174 行 bug）——改动小、风险低，立刻落地。
3. **方案 2**（合并下载/上传、内存流水线）——收益最大，作为核心改动。
4. **方案 4**（字体/底图复用）——顺手做掉。
5. **方案 3**（并行化）——在 2、4 基础上叠加，注意线程安全。
6. 视后续导入量增长评估 **方案 5**（异步化）。

---

## 六、附：关键代码位置索引

| 关注点 | 文件:行 |
|---|---|
| 入口 | `AdminRecommendProductController#excelImport` |
| 主流程 | `AdminRecommendProductService#excelImport`（liupin-custom-service）|
| 重复 lettering 查询 | `excelImport` 第 184、199、201 行 |
| 笔杆图下载 ×2 | `getDrawPic` 第 669 行；`adminRecommendPic` 第 853 行 |
| 字体每次重载 | `getDrawPic` 第 673 行 |
| 文字合成 + 首次上传 | `DrawService#drawTextOnPenHolder` 第 35~46 行 |
| 旋转/缩放合成 + 二次上传 | `DrawService#merge` 第 55~163 行 |
| 底图每行读盘 | `DrawService#merge` 第 136 行 |
| COS 同步上传 + 重试 | `CosFileService#xsjyUpload`/`uploadByLocalFile`（tencent-spring-boot-stater）|
| 逐行串行循环 | `excelImport` 第 197 行 `products.forEach` |
| 复制粘贴 bug（非性能） | `excelImport` 第 174 行（应为 `penHolderSkuCode`）|
