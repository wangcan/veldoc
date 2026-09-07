# liupin-custom-service 模块介绍

## 一、模块概述

`liupin-custom-service`（字帖/毛笔定制服务）是留品微服务体系中专注于**个性化定制业务**的核心业务服务。它围绕"毛笔/字帖定制"场景，提供从定制选品（笔尖、笔杆、笔包）、刻字预览、下单支付、物流跟踪、到售后延保、新人礼抽奖、淘宝渠道定制等端到端的业务能力，是连接 C 端用户（小程序 / 淘宝）与后端商城、营销、用户中心、毛笔工厂、聚水潭 ERP 等系统的业务枢纽。

- **启动类**：`com.liupin.custom.CustomApp`（`@SpringBootApplication` + `@EnableDiscoveryClient` + `@EnableFeignClients` + `@EnableAsync` + `@EnableAccessLog`）
- **服务名**：`liupin-custom-service`
- **服务端口**：`9097`
- **默认 profile**：`test`（见 `bootstrap.yaml` 中 `spring.profiles.active: test`）
- **网关前缀**：`/customService`（生产：`https://api.liupinshuyuan.com/customService`；测试：`https://route.liupinyike.com/customService`）
- **模块路径**：`liupin-service/liupin-custom-service/`

---

## 二、技术栈与依赖

| 技术组件 | 说明 |
|---------|------|
| Spring Boot 2.3.4.RELEASE | 基础框架（继承自 `liupin-parent`） |
| Spring Cloud Hoxton.SR8 + Spring Cloud Alibaba 2.2.3.RELEASE | 微服务框架 |
| Nacos | 服务注册与配置中心（`@EnableDiscoveryClient`） |
| OpenFeign | 服务间调用（`@EnableFeignClients`，HTTPClient 实现 + 请求/响应压缩） |
| Spring Boot Actuator + spring-boot-admin-starter-client | 健康检查与监控上报 |
| MyBatis 1.3.2 + Druid 1.1.20 | 多数据源 ORM 与连接池 |
| Redis (spring-boot-starter-data-redis) | 缓存 |
| Log4j2 2.17.1 + Disruptor | 异步日志 |
| Lombok / Fastjson | 代码简化 / JSON 处理 |
| weixin-java-pay 4.6.0 | 微信支付（下单、回调、退款） |
| 聚水坦 SDK (jushuitan 1.0) | 聚水潭 ERP 物流/订单推送 |
| 淘宝 SDK (taobao-sdk-java-auto) | 淘宝开放平台对接（淘宝渠道定制） |
| tencent-spring-boot-starter | 腾讯云 COS 对象存储 / STS |
| alibaba-dingtalk-service-sdk 2.0.0 | 钉钉消息推送（延保通知等） |
| Apache POI 5.0.0 | Excel 导入导出 |
| liupin-common | 全局工具、统一响应 `ApiResponse`、`LoginContext`、`CustomerAssert` 等 |

> 说明：项目未引入 springdoc / springfox，接口文档通过静态解析生成（见同目录 `api.json`）。

---

## 三、包结构

```
com.liupin.custom
├── CustomApp                       # 启动类
├── controller                      # 接口控制器（35 个，见下文业务域）
│   ├── admin/                      # 后台管理接口
│   ├── member/                     # 会员（加企微）
│   ├── newcomerPrizes/             # 新人礼
│   ├── orderLogisticsPushWechat/   # 物流推送微信
│   ├── produceSource/              # 生产溯源 / 延保
│   ├── raffle/                     # 抽奖
│   ├── scanBarCode/                # 扫码
│   └── taobao/                     # 淘宝渠道定制系列接口
├── service                         # 业务服务层（含 custom/shop/usercenter/mallservice/ruoyiShop/usercenter 子包）
├── mapper                          # MyBatis Mapper（custom / shop / usercenter 三组）
├── domain                          # 领域模型
│   ├── custom/ (params | result | ...)   # 定制业务入参与返回
│   ├── shop/ (params | result)           # 商城库领域
│   └── usercenter/ (result)              # 用户中心库领域
├── component
│   ├── constant/                   # 业务常量与枚举
│   ├── context/                    # 业务上下文（AdminCustomBizConfigContext）
│   ├── fengin/                     # Feign 客户端（Mall/Marketing/TabletPhp/UserCenter）
│   ├── factory/ (hanlder/)         # 工厂与策略处理者
│   └── schedule/                   # 定时任务
├── config                          # 配置类（多数据源、WxPay、聚水坦、淘宝、COS、字体/文件路径等）
└── utils/TaobaoUtil.java           # 淘宝工具类
```

资源目录 `src/main/resources`：
- `bootstrap.yaml` / `bootstrap-{dev,test,pro}.yaml`：启动配置（Nacos、Redis、三数据源、第三方账号、字体/文件路径）
- `mybatis-config.xml` + `mapper/{custom,shop,usercenter}/*.xml`：MyBatis 映射
- `log4j2.xml`：日志配置
- `apiclient_cert.p12`：微信支付证书

---

## 四、业务功能域

模块按业务域划分为 35 个控制器，对外提供 132 个 HTTP 接口（GET 100 个 / POST 32 个）。各业务域如下：

### 4.1 定制核心流程（C 端小程序）
- **CustomController**（`/api/custom`）：定制选品主流程——笔尖选择（`penPointPage`）、笔尖规格（`penPointSpecSelect`）、笔杆选择（`penHolderPage`）、刻字（`letteringPage`）、定制画图（`drawPic`）、预览（`previewPage`）、分享（`share`/`sharePic`）、笔包（`penPackagePage`）、再次定制（`customAgain`）、SKU 校验（`skuCheck`）。
- **CustomBizConfigController**（`/api/homePage`）：首页配置、发货提示、生产溯源文案等。
- **ProductController**（`/api/product`）：定制商品 / SKU 规格（笔尖、笔杆、笔包规格匹配）。
- **ShareController**（`/api/share`）：分享相关。
- **FileController**（`/api/file`）：文件上传（对接腾讯云 COS）。

### 4.2 用户与选品记录
- **CustomUserController**（`/api/custom/user/`）：定制用户信息。
- **CustomUserSelectController**（`/api/custom/userSelect`）：用户定制选品记录保存与查询。
- **CustomUserOrderReviewsController**（`/api/previews`）：用户订单评价。
- **CustomUserViedoPlayController**（`/api/videoPlay`）：定制视频播放记录。
- **UserAddressController**（`/api/userAddress`）：用户收货地址。
- **MemberController**（`/api/member/`）：加企微会员。

### 4.3 知识与问答
- **CustomKnowledgeController**（`/api/knowledge`）：定制知识库分类与内容。
- **CustomQuestionController**（`/api/question`）：定制常见问题与推荐解答。

### 4.4 订单与支付
- **OrderController**（`/api/order`）：下单（`submitOrder`）、支付明细（`payDetailPage`）、微信支付回调（`wxPayCallback`/`wxPayCallback2`）、退款回调（`wxRefundPayCallback`）、订单修复等。回调由微信主动 POST 调用。
- **LogisticsController**（`/api/logistics`）：物流查询。
- **OrderLogisticsPushWechatController**（`/api/orderLogisticsPushWechat`）：物流信息推送微信小程序。

### 4.5 延保与生产溯源
- **WarrantyQuestionSubmitController**（`/api/warrantyQuestionSubmit`）：质保问题提交。
- **WarrantyQuestionTypeController**（`/api/warrantyQuestionType`）：质保问题类型。
- **ProduceSourceUserController**（`/api/userProduceSource`）：用户扫码溯源。
- **AdminWarrantyQuestionSubmitController**（`/api/admin/warrantyQuestionSubmit`）：后台延保查询与处理。

### 4.6 新人礼 / 抽奖 / 优惠券 / 扫码
- **NewcomerPrizesController**（`/api/newcomerPrizes`）：新人礼领取与发放。
- **RaffleDrawController**（`/api/raffle/`）：抽奖抽奖、中奖记录。
- **UserCouponPrizesRecordController**（`/api/coupon/user`）：新人礼个人优惠券记录。
- **ScanBarCodeController**（`/api/barCode`）：扫码条码（送优惠券 / 立减）。

### 4.7 淘宝渠道定制
`controller/taobao/` 下提供与 C 端小程序对应的淘宝渠道全套接口（`/api/taobaoCustom` 及子路径），包括：
- **LoginController**：淘宝登录。
- **TaobaoCustomController / TaobaoProductController / TaobaoOrderController**：淘宝定制、商品、订单。
- **TaoBaoCustomKnowledgeController / TaoBaoCustomQuestionController**：淘宝知识、问答。
- **TaobaoCustomUserSelectController / TaobaoCustomUserOrderReviewsController**：淘宝选品、评价。

### 4.8 后台管理
- **AdminCustomBizConfigController**（`/api/admin`）：定制业务配置。
- **AdminCustomBizSettingController**（`/api/admin/setting`）：业务参数设置。
- **AdminCustomStatisticsController**（`/api/admin/statistics`）：定制统计。

---

## 五、多数据源架构

模块通过 `config/` 下三个 `DataSourceConfiguration` 配置类接入 **三个 MySQL 库**（Druid 连接池），分别对应三组 `mapper/` 与 `domain/`：

| 数据源 | 配置类 | Mapper 子包 | 数据库 | 用途 |
|--------|--------|------------|--------|------|
| custom | `CustomDataSourceConfiguration` | `mapper/custom` | `lpt_custom` | 定制业务主库（订单、选品、抽奖、延保等） |
| shop | `ShopDataSourceConfiguration` | `mapper/shop` | `shop` / `shop_test` | 商城商品 / SKU / 订单（PHP 商城库） |
| usercenter | `UsercenterDataSourceConfiguration` | `mapper/usercenter` | `lpt_user_center` | 用户中心（用户、第三方登录） |

> 数据库连接信息按 profile 在 `bootstrap-{dev,test,pro}.yaml` 中配置。

---

## 六、服务间调用（Feign）

`component/fengin/` 下定义 4 个 Feign 客户端，调用其他微服务 / 异构 sidecar：

| Feign 客户端 | 目标服务 | 用途 |
|-------------|---------|------|
| `MallFeignClient` | `liupin-mall-service` | 商城商品、订单、库存 |
| `MarketingFeignClient` | `liupin-marketing-service` | 营销、优惠券 |
| `UserCenterFeignClient` | `liupin-usercenter-service` | 用户信息、登录态 |
| `TabletPhpFeignClient` | `tablet-php-sidecar` | 平板 PHP 服务（如新人礼兑换码、会员加微） |

Feign 启用 HTTPClient 实现，并对 `text/xml`、`application/xml`、`application/json` 超过 2048 字节的请求/响应做压缩。

---

## 七、第三方系统集成

| 集成对象 | 配置类 / 属性 | 能力 |
|---------|--------------|------|
| 微信支付 | `WxPayConfiguration` / `WxPayProperties` | JSAPI 下单、支付回调、退款回调；证书 `apiclient_cert.p12` |
| 微信小程序 | `WxMiniAppConstant` / bootstrap `wx.miniapp` | 小程序消息、登录 |
| 聚水潭 ERP | `JushuitanConfiguration` / `JuShuiTanProperties` | 订单推送、物流同步 |
| 淘宝开放平台 | `TaobaoProperties` / `TaobaoUtil` | 淘宝渠道定制对接 |
| 毛笔工厂系统 | `MaobiFactoryProperties` | 毛笔溯源、生产视频、条码 |
| 信息管理系统 | `InformationProperties` | 码详情、生产溯源 |
| 中间商城 | `MiddleMallProperties` | 中间商城下单、实时库存 |
| 平板系统 | `TabletProperties` | 新人礼兑换码 |
| 腾讯云 COS | `tencent-spring-boot-starter`（`cos.*`） | 字体 / 定制图 / 会员图存储 |
| 钉钉 | `shop.ding-talk` | 延保 / 售后消息推送 |
| 字体 / 文件路径 | `FontPathProperties` / `FilePathProperties` | 楷体、黑体、隶书字体；定制图生成目录 |

---

## 八、定时任务

`component/schedule/` 下三个 `@EnableAsync` 驱动的定时任务：

| 任务类 | 功能 |
|--------|------|
| `OrderLogisticsPushWechatSchedule` | 物流订单信息定时推送到微信小程序 |
| `OrderStatusUpdateSchedule` | 定制订单状态定时更新 |
| `UserWinAwardExpiredSchedule` | 用户过期中奖记录处理 |

---

## 九、工厂与策略模式

`component/factory/` 采用工厂 + 策略模式解耦不同渠道 / 业务的处理逻辑：

- **OrderHandlerFactory / OrderHandlerService**：订单处理工厂，按渠道分发到 `MaobiCustomOrderHandler`（毛笔定制）、`TabletOrderHandler`（平板）等处理者。
- **NewcomerPrizesSendFactory / NewcomerPrizesSendService**：新人礼发放工厂，处理者包括：
  - `NewcomerPrizesAddWechat`（加微体验课）
  - `NewcomerPrizesCourseCoupon`（课程优惠券）
  - `NewcomerPrizesTabletMember`（碑帖会员）
  - `NewcomerPrizesTaoBaoCommand`（淘宝口令）
- **UserCouponReduceFactory / UserCouponReduceService**：优惠券立减工厂，处理者包括 `ScrmMemberRaffleReducePrice`（成为 SCRM 会员送抽奖立减券）、`UserCouponScanBarCodeReducePrice`（扫码送券减金额）。

---

## 十、核心常量与枚举

`component/constant/` 集中定义业务常量与枚举，便于统一维护：

- `CustomOrderStatus`：定制订单状态机（待发货 / 已发货 / 已签收待评价 / 交易成功等）。
- `ProductCustomType` / `MaobiFactoryBarCodeType`：定制类型、工厂条码类型。
- `UserPrizesRecordType` / `UserPrizesCouponUseStatus` / `UserPrizesRecordReceiveDataKey`：新人礼奖品记录类型、券使用状态、领取数据键。
- `CustomSettingType`：后台业务设置项类型。
- `TaoboAppType` / `WxMiniAppConstant` / `WxMsgType`：淘宝应用、微信小程序、微信消息类型。

---

## 十一、配置体系

- **多环境**：`bootstrap.yaml`（公共）+ `bootstrap-{dev,test,pro}.yaml`（环境差异）。环境通过 `spring.profiles.active` 切换（`dev` / `test` / `pro`，无 `uat`）。
- **Nacos 配置中心**：`spring.cloud.nacos.server-addr` + `username` / `password`，各环境地址不同。
- **关键配置项**：三数据源、Redis、微信支付、聚水潭、淘宝应用、毛笔工厂、中间商城、平板、COS、钉钉、字体与文件路径。
- **Actuator**：暴露所有端点（`management.endpoints.web.exposure.include: "*"`），健康检查明细开启。
- **Spring Boot Admin**：客户端上报到监控平台（`admin` / `liupintang`）。
- **文件上传**：单文件 500MB、请求 550MB 上限。

---

## 十二、统一响应与鉴权约定

- **统一响应**：所有接口统一返回 `com.liupin.common.api.ApiResponse<T>`（`status` / `msg` / `data`，分页接口附带 `totalNum` / `pageIndex` / `pageSize` / `totalPage`）。`status=0` 表示成功。
- **登录态**：多数 C 端接口通过 `CustomerAssert.checkLogin()` 校验登录态，并从 `LoginContext` 获取 `platId` / `userId`。请求经 API 网关鉴权后转发。
- **后台接口**：`/api/admin/**` 走后台鉴权；部分接口受 IP 白名单（`shop.admin-ip-whitelist`）与 token 校验（`shop.validate-token-url`）约束。

---

## 十三、相关文档

- 接口文档（OpenAPI 3.0）：见同目录 `api.json`。
- 打包与部署文档：见同目录 `intro-deploy.md`。
- 模块自带业务文档：`doc/会员页面-延保功能.md`、`doc/后台-延保功能查询.md`。

---

**文档版本**：v1.0
**更新时间**：2026-09-07
**维护团队**：留品技术团队
