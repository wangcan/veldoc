# custom 业务模块 v6 新增功能分析

> 对比基线：`68bcca972f753eaee4aae596737140ce60ad9d65`（引入 Claude AI 辅助编程）
> 目标版本：`89149b0821ae6a2feab8b0de010ae88e52337749`（合并亚东已开发功能版本 dev-cusom-v6）
> 模块路径：`liupin-service/liupin-custom-service/`
> 分析日期：2026-09-07

---

## 一、变更概述

本次合并（dev-cusom-v6）在 custom 业务模块中新增了一套**「推荐商品（Recommend Product）」**业务功能，覆盖后台管理与前台/淘宝端展示两个侧端，并附带对订单控制器的 MCP 工具化标记。

### 变更文件统计（liupin-custom-service 内，27 个文件）

| 类型 | 新增/调整 | 说明 |
|------|-----------|------|
| Controller | 新增 6 个 | 推荐商品/分类的 后台、前台、淘宝端 控制器 |
| Controller | 调整 1 个 | `OrderController` 类级新增 `@LiupinMcpTool` 注解 |
| Domain 实体 | 新增 2 个 | `AdminRecommendProduct`、`AdminRecommendProductCategory` |
| Domain 实体 | 调整 1 个 | `AdminCustomBizConfig` 新增 2 个字段 |
| Result 返回对象 | 新增 4 个 | `AdminRecommendProductResult`、`AdminRecommendProductCategoryResult`、`RecommendProductResult`、`RecommendProductDetailResult` |
| Mapper 接口 + XML | 新增 2 套 | `AdminRecommendProductMapper`、`AdminRecommendProductCategoryMapper` |
| Mapper | 调整 1 个 | `AdminCustomBizConfigMapper` 新增 `updateRecommendFirstPageTip` |
| Service | 新增 2 个 | `AdminRecommendProductService`、`AdminRecommendProductCategoryService` |
| Service | 调整 2 个 | `CustomService`（新增效果图合成/查询等辅助方法）、`AdminCustomBizConfigService`、`FileService` |
| 配置 | 新增 1 个 | `bootstrap-local.yaml` |
| 测试 | 删除 | `AppTest.java`（-20 行） |

代码量：约 **1952 行新增 / 53 行删除**。

---

## 二、新功能介绍：推荐商品（Recommend Product）

### 业务背景

毛笔定制场景中，将「笔尖 SKU + 笔杆 SKU」的组合作为一套**推荐商品**对外展示。每个推荐商品绑定一组笔尖/笔杆商品编码，后台通过 Excel 批量导入时自动调用刻字效果图合成与底图合成，生成展示图片；前台按分类分页浏览，展示组合价格、库存与关注数，并支持浏览数（关注数）自增统计。

### 功能拆解

1. **分类管理（后台）**
   - 推荐商品分类的增、删、改、列表查询。
   - 分类名称限 6 个字；删除分类时事务性级联删除该分类下的所有推荐商品。
   - 配置推荐首页提示语（固定 6 字长度），写入 `admin_custom_biz_config.admin_recommend_first_page_tip`。

2. **商品管理（后台）**
   - 推荐商品分页列表（含笔尖/笔杆实时价格、库存、关注数）。
   - 商品详情、删除、修改（简介 / 排序 / 关注底数）。
   - **Excel 批量导入**：上传 `.xls/.xlsx`，按模板字段（品名、描述、笔头编码、笔杆编码、关注底数）解析，校验 SKU 是否存在、是否存在对应的笔尖笔杆效果图配置，自动合成刻字效果图 + 底图后批量入库。
   - **Excel 模板下载**：导出含固定表头的示例文件。

3. **前台展示（C 端）**
   - 分类列表（仅返回 `status=1` 的开启分类）。
   - 推荐商品分页列表：自动过滤笔尖或笔杆无库存的组合；关注数按规则换算（≥1万显示「N万」、≥1千显示「N千」）。
   - 商品详情：校验分类开启状态与库存，返回组合价格、SKU、关注数。
   - 浏览数自增：每次进入详情可调用 `userFocusNumIncrease` 将 `focusNum + 1`。

4. **淘宝端展示**
   - 与前台展示功能一致，差异在于鉴权方式：淘宝端通过 `CustomerAssert.checkLogin()` + `LoginContext.getPlatId()` 获取当前平台 ID；而 C 端控制器中 platId 当前硬编码为 `15`（`CUSTOM_TAOBAO` 平台 ID），登录校验被注释（待接入）。

5. **订单控制器 MCP 化**
   - `OrderController` 类级新增 `@LiupinMcpTool` 注解，使其被 `McpAddConfig` 自动扫描并注册为 MCP Server 工具。**该调整不改变任何 HTTP 接口的路径、方法或参数**，属于框架元数据层面的变更。

### 数据库变更

| 表 | 变更 |
|----|------|
| `admin_recommend_product_category` | 新增表：推荐商品分类（id, name, sort, status, create_time, update_time） |
| `admin_recommend_product` | 新增表：推荐商品（id, category_id, name, pic, description, introduction, pen_point_sku_code, pen_holder_sku_code, focus_basic_num, focus_num, sort, create_time, update_time） |
| `admin_custom_biz_config` | 新增字段 `admin_recommend_pic`（推荐商品合成效果底图）、`admin_recommend_first_page_tip`（推荐首页提示语） |

---

## 三、新增接口清单

共 **6 个 Controller、19 个 HTTP 接口**。

### 3.1 后台 — 推荐商品分类 `AdminRecommendProductCategoryController`
基路径：`/api/admin/recommendProductCategory`（鉴权：`CustomerAssert.checkCustomBackUserLoginByUrl` 后台用户登录校验）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 分类列表（含每个分类下的推荐商品数量） |
| POST | `/insert` | 新增分类，body `{name}`，名称限 6 字 |
| POST | `/update` | 修改分类，body `{id, name?, sort?, status?}` |
| GET | `/del/{id}` | 删除分类（事务级联删除其下推荐商品） |
| GET | `/updateRecommendFirstPageTip` | 更新推荐首页提示语，query `tipText`（固定 6 字） |

### 3.2 后台 — 推荐商品 `AdminRecommendProductController`
基路径：`/api/admin/recommendProduct`（鉴权：后台用户登录校验）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 推荐商品分页列表，query `pageNum, pageSize, categoryId` |
| GET | `/del/{id}` | 删除推荐商品 |
| POST | `/updateProduct` | 修改简介/排序/关注底数，body `{id, introduction?, sort?, focusBasicNum?}` |
| GET | `/productDetail` | 推荐商品详情，query `id` |
| POST | `/excelImport` | Excel 批量导入，form `categoryId` + `imgFile`(multipart) |
| POST | `/excelExample` | 下载 Excel 导入模板（响应为二进制 Excel 文件） |

### 3.3 前台 — 推荐分类 `RecommendProductCategoryController`
基路径：`/api/recommendProductCategory`（无登录校验，待接入）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 开启状态(status=1)的分类列表 |

### 3.4 前台 — 推荐商品 `RecommendProductController`
基路径：`/api/recommendProduct`（platId 当前硬编码 15，登录校验待接入）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 推荐商品分页列表（过滤无库存组合），query `pageNum, pageSize, categoryId` |
| GET | `/detail` | 推荐商品详情，query `id` |
| GET | `/userFocusNumIncrease` | 浏览数 +1，query `id` |

### 3.5 淘宝端 — 推荐商品 `TaoaboRecommendProductController`
基路径：`/api/taobaoRecommendProduct`（鉴权：`checkLogin()` + `LoginContext.getPlatId()`）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 推荐商品分页列表 |
| GET | `/detail` | 推荐商品详情 |
| GET | `/userFocusNumIncrease` | 浏览数 +1 |

### 3.6 淘宝端 — 推荐分类 `TaobaoRecommendProductCategoryController`
基路径：`/api/taobaoRecommendProductCategory`（鉴权：`checkLogin()`）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/list` | 开启状态分类列表 |

---

## 四、有调整的接口清单

| Controller | 路径前缀 | 调整内容 | 是否影响 HTTP 接口签名 |
|------------|----------|----------|------------------------|
| `OrderController` | `/api/order` | 类级新增 `@LiupinMcpTool` 注解（标记为 MCP 工具类，由 `McpAddConfig` 自动扫描注册到 MCP Server）；同时调整了 import 顺序 | **否** — 所有 HTTP 接口的路径、HTTP 方法、参数、返回值均未变化，仅框架元数据层面变更 |

> 说明：`OrderController` 的 HTTP REST 接口本身未发生功能调整，因此未在 `custom-v6.json` 中重复生成接口文档（其既有接口不属于本次「新代码」范畴）。如需 OrderController 全量接口的 MCP 工具文档，可单独梳理。

---

## 五、关键数据结构

### AdminRecommendProductCategoryResult（后台分类列表项）
`id, name, recommendProductCount(该分类下推荐商品数), sort, status`

### AdminRecommendProductResult（后台商品列表项）
`id, categoryId, name, pic, description, introduction, penPointAndHolderPrice(笔尖+笔杆总价), penPointSkuCode, penPointSkuCodeStock, penHolderSkuCode, penHolderSkuCodeStock, focusBasicNum, focusNum, sort, createTime`

### RecommendProductResult（前台商品列表项）
`id, categoryId, name, pic, description, penPointAndHolderPrice, focusNum(换算后字符串), penPointStock(是否有库存), penHolderStock, createTime`

### RecommendProductDetailResult（前台商品详情）
`id, categoryId, name, pic, introduction, penPointAndHolderPrice, penPointSkuCode, penHolderSkuCode, focusNum, createTime`

### 统一响应 ApiResponse
`status(0=成功, 其他=错误), msg, data, totalNum, pageIndex, pageSize, totalPage`

---

## 六、配套接口文档

- Swagger 3.0 (OpenAPI 3.0) 接口文档见同目录：[`custom-v6.json`](./custom-v6.json)
- 文档覆盖范围：上述 19 个新增接口。OrderController 因仅注解调整、HTTP 接口未变，未纳入。
