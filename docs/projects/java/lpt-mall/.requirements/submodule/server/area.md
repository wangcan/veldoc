# 行政区划数据更新 & 收件地址三级区划缺失修复 — 执行结果

> 需求来源：`.requirements/submodule/server/task.txt`
> 执行日期：2026-10-19
> 需求内容：
> 1. 中国相关行政区划数据（area.csv）不是最新的，更新成最新的数据；
> 2. 用户添加地址时偶尔缺失第三级行政区划编码（如测试环境 member_address id=1472 记录到的 area_id=441900 东莞市级），导致订单推送聚水潭时报地址异常。

---

## 一、根因分析

- `member_address.area_id` 由前端提交，后端原先**无任何校验**。前端（含微信导入地址场景）做「省/市/区」三级匹配时，若乡镇名与 `area.csv` 数据不一致，会回退提交市级编码。
- 数据根因（本次已修复）：
  - 东莞市**缺失 441903 东城街道**（东莞市区主要街道之一），且「莞城区/南城区/万江区」为过时名称（官方最新为「莞城街道/南城街道/万江街道」）——东城街道用户必然匹配失败，回退提交 441900；
  - 儋州市（460400）**完全没有三级行政区划数据**；
  - 西安市鄠邑区存在重复条目（610118 与旧编码 610125 并存）。
- 后果链路：`JushuitanOrderServiceImpl` 通过 `AreaUtils.format(areaId).split(" ")` 取省市区三级名称，市级编码只能切出 2 段 → `receiver_district` 缺失 → 推送聚水潭失败（记录「获取用户地址异常」并跳过该订单）。

## 二、改动文件清单

| # | 文件 | 改动内容 |
|---|---|---|
| 1 | `yudao-framework/yudao-spring-boot-starter-biz-ip/src/main/resources/area.csv` | 行政区划数据更新（明细见第三节） |
| 2 | `yudao-module-member/yudao-module-member-api/.../enums/ErrorCodeConstants.java` | 新增错误码 `ADDRESS_AREA_NOT_COMPLETE`（1_004_004_001，「收件地址地区不完整，请重新选择省市区」） |
| 3 | `yudao-module-member/yudao-module-member-biz/.../service/address/AddressServiceImpl.java` | `createAddress`/`updateAddress` 新增 `validAreaComplete` 校验：areaId 必须为区县级（type=4），拦截不完整地址 |
| 4 | `yudao-module-mall/yudao-module-trade-biz/.../service/order/JushuitanOrderServiceImpl.java` | 新增 `resolveReceiverArea` 方法：订单/换货单推送时若 areaId 只到市级（存量脏数据），从详细地址中匹配该市下级乡镇/街道名**兜底补齐第三级**；两处推送组装（订单、换货单）均接入 |
| 5 | `yudao-module-member/yudao-module-member-biz/src/test/.../MemberAddressServiceImplTest.java` | 修正 2 个受新校验影响的用例（areaId 改用合法区县编码），新增 2 个校验异常用例 |
| 6 | `sql/mysql/member_address_area_incomplete.sql` | **新增**：存量脏数据诊断脚本（只读 SELECT，需人工执行，见第六节） |

## 三、area.csv 数据变更明细

数据基线：国家统计局 2023 年 6 月版统计用区划代码（目前可获得的最新权威版本；2024-10 后统计局不再公开代码，2024–2025 年无县级区划调整记录）。

| 类别 | 变更 |
|---|---|
| 东莞市（需求 2 主根因） | 441901 莞城区→**莞城街道**、441902 南城区→**南城街道**、441904 万江区→**万江街道**、**新增 441903 东城街道**（下级达 32 个，4 街道 + 28 镇，与官方一致） |
| 儋州市 | **新增 16 个镇**（460401 那大镇 ~ 460416 新州镇），补齐三级行政区划 |
| 三沙市 | 460321 西沙群岛→**西沙区**、460322 南沙群岛→**南沙区**（2020 年官方设区命名）；删除过时条目 460323 中沙群岛的岛礁及其海域 |
| 新设立城市 | **新增 659012 白杨市**（新疆兵团，2023-01 设立，挂在 659000 下） |
| 撤县设市更名 | 540422 米林县→**米林市**、540530 错那县→**错那市**（2023-04） |
| 重复/错误条目 | 删除西安市重复的鄠邑区旧编码条目 610125（保留官方 610118） |
| 开发区更名 | 152571 乌拉盖管委会→乌拉盖管理区管委会、371471 德州经济技术开发区→德州天衢新区、411671 河南周口经济开发区→周口临港开发区 |

**存量数据兼容策略（重要）**：
- 米林/错那保留旧编码仅改名称（不引入官方新码 540481/540581），避免区域树新旧并存重复显示，同时保证 `member_address`、`trade_order` 存量 area_id 仍可正常解析；
- 东莞/儋州沿用历史伪编码段（4419xx/4604xx），存量引用不受影响；
- 中山市（442001-442023）、洋浦经济开发区（469050）等此前手工修复的数据经回归验证保持不变。

## 四、调整功能涉及的接口清单

### 4.1 数据变更直接影响（返回内容变化，接口签名不变）

| 接口 | 方法 | 说明 |
|---|---|---|
| `GET /app-api/system/area/tree` | 用户 App - 获得地区树 | 区域树数据源即 area.csv，新增/更名条目后返回最新三级结构（东莞 32 个下级、儋州 16 镇、白杨市等）。**前端地址选择器依赖此接口**；若 App 端有本地缓存需确认刷新机制 |
| `GET /admin-api/system/area/tree` | 管理后台 - 获得地区树 | 同上，管理后台使用 |
| `GET /admin-api/system/area/get-by-ip` | 管理后台 - 获得 IP 对应的地区名 | 输出经 `AreaUtils.format` 格式化，更名条目输出随之更新（如「莞城街道」） |

### 4.2 新增校验影响（行为变化：areaId 非区县级时返回业务异常）

| 接口 | 方法 | 变化 |
|---|---|---|
| `POST /app-api/member/address/create` | 用户 App - 创建用户收件地址 | **新增校验**：`areaId` 必须为区县级编码（type=4），否则返回错误码 `1_004_004_001`「收件地址地区不完整，请重新选择省市区」 |
| `PUT /app-api/member/address/update` | 用户 App - 更新用户收件地址 | 同上 |

> 正常经区域树选择器提交的地址不受影响；仅拦截前端三级匹配异常时回退提交的省/市级编码（如 441900），从源头杜绝不完整地址落库。

### 4.3 数据展示影响（areaName 输出更新，接口签名不变）

| 接口 | 方法 | 说明 |
|---|---|---|
| `GET /app-api/member/address/get` | 用户 App - 获得用户收件地址 | RespVO 的 `areaName` 经 `AreaUtils.format` 生成，更名条目（莞城街道、米林市等）输出随之更新 |
| `GET /app-api/member/address/get-default` | 用户 App - 获得默认收件地址 | 同上 |
| `GET /app-api/member/address/list` | 用户 App - 获得用户收件地址列表 | 同上 |
| `GET /admin-api/member/address/list` | 管理后台 - 获得用户收件地址列表 | 同上（只读接口，无校验变化） |

### 4.4 内部链路（非 HTTP 接口，聚水潭推送兜底）

| 链路 | 说明 |
|---|---|
| 聚水潭订单推送（`JushuitanOrderServiceImpl#createOrder`） | 定时任务 `JushuitanOrderPushJob` 及订单支付成功回调触发。存量脏数据（市级编码）推送时，自动从 `receiverDetailAddress` 匹配该市下级乡镇/街道名补齐第三级（有 warn 日志），仍无法补齐时维持原「跳过 + 错误日志」行为 |
| 聚水潭换货单推送（`JushuitanOrderServiceImpl#createOrderReturnGoods`） | 定时任务 `JushuitanOrderReturnGoodsPushJob` 触发，兜底逻辑同上 |
| 跨模块 `MemberAddressApi`（trade 模块下单时快照收件地址） | 无代码改动；地址来源已在上游校验，快照数据随之完整 |

## 五、验证结果

| 验证项 | 结果 |
|---|---|
| area.csv 结构校验（无重复 id、父子关系完整、无自环、31 省份、东莞 32 下级、儋州 16 下级、所有市级均有三级行政区划） | ✅ 通过 |
| `AreaUtils` 真实代码加载冒烟测试 17 项（441903→「广东省 东莞市 东城街道」、460401→「海南省 儋州市 那大镇」、659012→白杨市、610118→鄠邑区、110105→「北京 北京市 朝阳区」回归等） | ✅ 全部通过 |
| `MemberAddressServiceImplTest` 单测（原 5 个修正后 + 新增 2 个校验用例，共 7 个） | ✅ 7/7 通过 |
| 受影响模块编译（member-api / member-biz / trade-biz / biz-ip，`-am` 含依赖链） | ✅ BUILD SUCCESS |
| 全量 `mvn clean compile -T 1C`（JDK 8：8.0.432-zulu） | ✅ BUILD SUCCESS |

## 六、需人工处理事项

1. **执行诊断 SQL**：`sql/mysql/member_address_area_incomplete.sql`（只读 SELECT，Claude 不做数据库操作，需人工执行）
   - 定位 `member_address`、`trade_order` 中 area_id 为省/市级的存量脏数据（含 id=1472）；
   - 修复建议：引导用户在 App 重新编辑保存地址（新版服务端已校验，不会再落库不完整地址），或依据 detail_address 中的乡镇名人工更新 area_id（脚本内附东莞市 441901~441932 编码对照），未发货订单优先处理。
2. **App 前端**：确认区域树（`/app-api/system/area/tree`）无本地持久缓存；若有，需加版本/失效机制，否则东莞东城街道、儋州各镇在旧缓存下仍不可选。
3. **存量订单兜底说明**：聚水潭推送的「详细地址匹配乡镇」为兜底逻辑，匹配成功时有 warn 日志可查；无法匹配的仍会跳过推送，需按第 1 项修复地址后重推。
