# 中台商城订单重新推送 — 实现记录

> 对应需求：`.requirements/subservices/custom/task.txt` 需求 3
> 表名说明：需求描述中的 `custom_order_inf` 实际为 `custom_order_info`（mapper/SQL 中所用表名），按实际表名实现。

## 需求

部分 `custom_order_info` 订单在支付成功后向中台商城推送时失败（生成中台商城订单失败），需要对符合指定条件的订单重新向中台商城发起推送请求，调用 `MiddleMallService.createOrder` 重新推送并获取商城订单 ID。

## 实现概览

改动**纯增量**——未修改支付回调主流程、订单处理器（`TabletOrderHandler` / `MaobiCustomOrderHandler`）和 `MiddleMallService.createOrder`。

### 新增文件

| 文件 | 说明 |
| --- | --- |
| `service/MiddleMallOrderRepushService.java` | 重新推送编排服务：查询失败订单 → 构建 `MiddleMallCreateOrderParam` → 调用 `createOrder` → 回写商城订单号 |
| `domain/custom/result/MiddleMallOrderRepushResult.java` | 推送结果 DTO（total/successCount/failCount/skipCount/details） |
| `controller/admin/AdminMiddleMallOrderRepushController.java` | 运营端接口 |

### 修改文件（仅追加，未动已有方法）

| 文件 | 改动 |
| --- | --- |
| `mapper/custom/CustomOrderInfoMapper.java` | 新增 `selectMiddleMallCreateFailedOrders()` 方法声明 |
| `resources/mapper/custom/CustomOrderInfoMapper.xml` | 新增对应 `SELECT`（`order_status = 3` 且 `middle_order_num` 为空，`limit 200`） |
| `service/custom/CustomOrderService.java` | 新增同名委托方法 |

模块路径：`liupin-service/liupin-custom-service/`

## 工作流程

1. 查询符合条件的订单：`order_status = 3`（商城入库失败）**且** `middle_order_num` 为空。
2. 按订单号重新拉取最新状态校验（防重复推送：状态非 3 或已存在商城订单号则 `skip`）。
3. 按 `platId` / `orderType` 重新构建 `MiddleMallCreateOrderParam`（与两个 handler 的参数构建保持一致），调用 `MiddleMallService.createOrder` 重新推送。
4. 成功则回写 `middle_order_id` / `middle_order_num`（`createOrder` 内部已把状态置为 4「商城入库成功」）。

### 各业务线参数构建（与 handler 一致）

- **碑帖（`TABLET`，platId=1）**：推送订单全部明细。
- **毛笔定制（`CUSTOM_TAOBAO`，platId=15，orderType=1）**：仅推送包装明细（`CUSTOM_PEN_PACKAGE`）。
- **抽奖订单（`CUSTOM_TAOBAO`，platId=15，orderType=2）**：从奖品记录 `RaffleUserWinRecord.awardSettingJson` 解析明细。

## 接口

均需登录（`CustomerAssert.checkLogin()`）。

- `GET /api/admin/middleMallOrderRepush/repushAll` — 批量重推（最多 200 单/次）
- `GET /api/admin/middleMallOrderRepush/repushByOrderNum?orderNum=xxx` — 单订单重推

返回结构：

```json
{
  "total": N,
  "successCount": N,
  "failCount": N,
  "skipCount": N,
  "details": [
    { "orderId": , "orderNum": , "platId": , "orderType": , "middleOrderNum": , "status": "success|fail|skip", "errorDescription": }
  ]
}
```

## 影响评估（是否会影响到其他功能）

**结论：不影响现有功能。**

1. **现有流程零改动**：未触碰 `PayService.wxPayCallback`（支付回调）、两个 `OrderHandler`（下单处理）、`MiddleMallService.createOrder`。对三个已存在文件的修改均为**新增方法/SQL**，不改任何已有逻辑。正常下单、支付回调、商城推送、退款流程完全不受影响。

2. **副作用边界严格**：重推只做「构建参数 → `createOrder` → 回写商城订单号」，**不重复**执行库存解锁、定制记录支付状态更新、优惠券/抽奖奖品状态更新——这些在首次推送时已执行，避免双重副作用。

3. **无 DB schema 变更**：只新增一条 `SELECT`，未建表/改表。

## 需注意的风险

（非对现有功能的影响，而是重推本身的使用注意点）

- **参数构建逻辑与 handler 重复**：`buildMiddleMallCreateOrderParam` 镜像了两个 handler 的构建逻辑。代码中已注释标明对应关系，若 handler 逻辑变更需同步修改。
- **超时重试可能产生重复商城订单**：`createOrder` 无幂等键（既有限制）。若首次失败是网络超时（商城实际已建单但响应丢失，`error_description` 含「调用中台商城接口异常」），重推会在商城侧再建一单。建议：批量前先看 `error_description`，超时类失败优先用单订单接口并在商城侧核验；「成功但未返回订单号」类失败可放心重推。
- **并发**：接口为运营手动触发，按 `id` 升序、单次 `limit 200`，查-推间存在小窗口竞态，不建议并发调用。

## 验证

编译通过（JDK 8，`mvn -pl liupin-service/liupin-custom-service compile`，BUILD SUCCESS）。

未改动 `LoginServiceImpl.java`（会话开始前已是 modified 状态，与本需求无关）。
