# lpt-wx-platform 项目说明文档

> 六品堂微信平台相关管理后端服务

## 1. 项目概述

`lpt-wx-platform` 是六品堂（liupin）旗下的微信公众号平台管理后端，基于 Spring Boot 构建。项目围绕**微信公众号（Official Account）**与**企业微信（Company WeChat）**两大生态，提供公众号管理、粉丝管理、素材/菜单管理、图文发布、消息推送、二维码平台、数据统计等完整能力，并对接了用户中心、分析服务、商城等多个内部系统。

- **Group / Artifact**：`com.liupin` / `wx-platform`
- **版本**：`0.0.1-SNAPSHOT`
- **服务端口**：`9610`
- **默认激活 profile**：`test`（见 `application.yml` → `spring.profiles.active`）
- **Spring Boot 版本**：`2.7.2`
- **JDK**：`1.8`
- **构建工具**：Gradle 7.5.1（自带 wrapper `gradlew`）
- **打包产物**：`build/libs/wx-platform-0.0.1-SNAPSHOT.jar`（fat jar，约 120MB）

## 2. 技术栈

| 分类 | 选型 | 说明 |
| --- | --- | --- |
| 基础框架 | Spring Boot 2.7.2 | web / aop / autoconfigure / data-redis |
| ORM | MyBatis-Plus 3.5.2 | 含分页等扩展，Mapper XML 与注解混合 |
| 缓存/分布式锁 | Redisson 3.17.0 + Spring Data Redis | access_token 缓存、分布式锁 |
| 消息队列 | RocketMQ Client 4.3.0 | 回调监听（当前已标注 `@Deprecated`） |
| 任务调度 | XXL-Job（`com.liupin:xxl-job-spring-boot-starter:1.0-SNAPSHOT`） | 定时/延迟任务，如消息延迟推送、粉丝同步、菜单发布 |
| 搜索/分析 | Elasticsearch 7.6.2（RestHighLevelClient） | 粉丝/扫码等数据分析 |
| 数据库 | MySQL（HikariCP 连接池） | 主数据存储 |
| 对象存储 | 腾讯云 COS（cos_api 5.6.23 + cos-sts 3.0.6） | 素材/图片上传 |
| 二维码 | ZXing 3.4.1（`libs/` 本地 jar） | 二维码生成 |
| HTTP 客户端 | Retrofit 2.9.0 + OpenFeign 12.0 + Hutool HttpUtil | 对外/对内 HTTP 调用 |
| Excel | Apache POI 5.2.2 | 导入导出 |
| HTML 解析 | Jsoup 1.18.1 | 图文/HTML 处理 |
| JSON | Fastjson2 2.0.6 + Fastjson 1.2.83 | 双版本兼容 |
| 鉴权 | JJWT 0.9.1 | JWT Token |
| API 文档 | springdoc-openapi-webmvc-core 1.6.9 | 路径 `/api/docs` |
| 日志 | Log4j2（替换默认 Logback） | |
| 热部署 | spring-boot-devtools | 开发期热加载 |
| 工具 | Lombok / Hutool 5.8.2 | |
| 部署插件 | gradle-ssh-plugin 2.2.0 | 一键远程部署 |

## 3. 目录结构

```
lpt-wx-platform/
├── build.gradle                  # 构建脚本 + deploy 任务
├── settings.gradle               # rootProject.name = 'wx-platform'
├── run-server.sh                 # 服务器启停脚本（start/stop/remote_start）
├── gradlew / gradlew.bat         # Gradle Wrapper
├── libs/                         # 本地依赖 jar（ZXing core/javase 3.4.1）
├── src/main/java/com/liupin/wxplatform/
│   ├── WxPlatformApplication.java        # 启动类
│   ├── rest/                             # REST 控制层
│   │   ├── oa/                           # 公众号相关控制器（主体）
│   │   ├── qrcodeplatform/               # 二维码平台
│   │   ├── admin/                        # 后台用户管理
│   │   ├── wecaht/                       # 微信 URL Link（拼写如此）
│   │   ├── LoginController.java          # 登录
│   │   ├── AccessTokenController.java
│   │   ├── AnalysisController.java       # 数据分析
│   │   └── ...
│   ├── service/                          # 业务服务层
│   │   ├── oa/                           # 公众号业务
│   │   ├── es/                           # Elasticsearch 服务
│   │   ├── qrcodeplatform/               # 二维码平台业务
│   │   └── admin/
│   ├── mapper/                           # MyBatis-Plus Mapper（36 个）
│   ├── entity/                           # 数据库实体 + params/result
│   ├── bean/                             # VO/DTO/参数对象
│   ├── wx/                               # 微信开放平台 API 封装
│   │   ├── api/                          # 各类微信 API 接口与实现
│   │   ├── token/                        # AccessToken / 企业 AccessToken / Ticket
│   │   ├── provider/                     # AccessTokenProvider
│   │   ├── http/                         # HttpMethod
│   │   └── aes/                          # 微信消息加解密（WXBizMsgCrypt）
│   ├── configuration/                    # Spring 配置类
│   ├── authority/                        # 鉴权拦截器 + @Auth 注解 + 访问日志
│   ├── context/                          # AccessContext / AccessInterceptor
│   ├── listener/                         # MQ / XXL-Job 监听器
│   │   ├── mq/                           # RocketMQ（已废弃）
│   │   └── xxljob/                       # 延迟/定时任务
│   ├── constant/                         # 枚举常量
│   ├── properties/                       # 配置属性绑定类
│   ├── util/                             # 工具类（线程池/二维码/COS/Excel 等）
│   ├── encryption/                       # SHA1
│   └── exception/                        # 业务异常
├── src/main/resources/
│   ├── application.yml                   # 主配置
│   ├── application-dev.yml               # 开发环境
│   ├── application-test.yml              # 测试环境（默认）
│   ├── application-pro.yml               # 生产环境
│   ├── mapper/*.xml                      # MyBatis XML（20 个）
│   └── db/auto_reply_msg.sql             # 示例 SQL
└── src/test/                             # 单元测试（3 个）
```

代码规模：主代码约 325 个 Java 文件，Mapper XML 20 个，测试 3 个。

## 4. 启动类与核心注解

`WxPlatformApplication`：

```java
@SpringBootApplication
@MapperScan("com.liupin.wxplatform.mapper")
@EnableAsync        // 开启异步任务
@EnableScheduling   // 开启定时任务
@EnableAccessLog    // 自定义：开启访问日志（authority 包）
public class WxPlatformApplication
```

启动类同时声明了 `SpringContextHolder`（静态获取 Bean）与 `RestTemplate` Bean。

## 5. 分层架构

### 5.1 控制层（rest）

统一前缀 `/api/**`，主要业务分组：

- **`rest/oa`（公众号管理，主体）**
  - `CallbackController` — 微信后台配置的消息/事件回调入口 `/api/officialAccount/action/callback`
  - `OfficialAccountController` — 公众号增删查、当前子类型
  - `OfficialAccountFansController` / `OfficialAccountFansTagController` — 粉丝与粉丝标签
  - `OfficialAccountNewsController` / `OfficialAccountDraftController` / `FreePublishController` / `OfficialAccountPublishController` — 图文素材、草稿、发布
  - `OfficialAccountPushController` / `OfficialAccountPushTagController` / `OfficialAccountEventTagController` — 消息推送与标签
  - `QrCodeController` / `QrCodeMsgTemplateController` — 公众号带参二维码与扫码消息模板
  - `MenuDataController` / `MenuInfoController` — 菜单
  - `MediaDataController` / `MediaImageController` / `MediaThumbController` / `ImgDirController` — 素材与图片目录
  - `CompanyWXController` — 企业微信
  - `WxAppSubscribeMsgController` — 订阅消息
  - `DefaultMsgController` — 默认回复
- **`rest/qrcodeplatform`（二维码平台）** — `CategoryController`、`QrCodeController`、`StatisticsController`，支持活码/分组/扫码统计/外链
- **`rest/admin`** — 后台用户管理
- **`rest/wecaht`** — 微信 URL Link（短链）生成与统计
- 顶层：`LoginController`（登录）、`AccessTokenController`、`AnalysisController`（分析）、`ComponentController`、`QrCodeGroupController`、`QrCodeScanController`、`ToolController`、`UserAppController`、`TempController`

### 5.2 服务层（service）

与控制器一一对应的业务 Service（如 `OfficialAccountFansService`、`OfficialAccountPushService`、`QrCodeService`、`FreePublishManageService` 等），以及：

- `TokenService` — JWT 校验/解析 userId
- `LoginService` — 登录签发 token
- `WxAppService` — 微信应用配置（appId/appSecret）读取
- `service/es/ElasticsearchService` — ES 操作封装

### 5.3 微信 API 封装（wx）

独立的微信开放能力封装层，接口在 `wx/api/`，实现在 `wx/api/impl/`：

- `WxService` / `WxMaterialService` — 基础能力与素材
- `OfficialAccountDraftService` / `OfficialAccountNewsService` / `OfficialAccountPublishService` / `FreePublishService` — 草稿、图文、发布
- `OfficialAccountFansDetailService` — 粉丝详情
- `OfficialAccountKfMessageService` — 客服消息
- `OfficialAccountMsgPushService` — 消息推送
- `OfficialAccountQrCodeService` — 带参二维码
- `OfficialAccountMediaForeverService` — 永久素材
- `TicketService` — ticket 获取（用于 jsapi 签名等）
- `CompanyWxService` — 企业微信

**Token 机制**（`wx/token/`）：

- `AccessTokenService` — 公众号 access_token：优先从 Redis（Redisson）读取（key=`RedisConstant.ACCESS_TOKEN_CACHE + wxAppId`），过期则调用微信 `cgi-bin/token` 接口刷新并回写 Redis（提前 300 秒失效）；同时提供 H5 OAuth2 获取 unionid。
- `CompanyAccessTokenService` — 企业微信 token。
- `AccessTokenProvider` — 以 `WxApp` 为维度包装 token 获取。

**消息加解密**（`wx/aes/`）：`WXBizMsgCrypt`、`PKCS7Encoder`、`XMLParse`，用于回调消息的 AES 加解密与签名校验。

### 5.4 数据层（mapper / entity）

- 36 个 MyBatis-Plus Mapper（`@MapperScan("com.liupin.wxplatform.mapper")`），20 个 XML 映射文件。
- `BaseEntity` + `CustomMetaObjectHandler` 自动填充公共字段。
- `MybatisPlusConfiguration` 配置分页等插件。

### 5.5 任务与消息（listener）

- `listener/xxljob/`：
  - `OfficialAccountMsgPushListener` — 实现 `DelayJobHandler`，延迟推送公众号消息
  - `SyncFansInfoByOpenId` — 按 openId 同步粉丝信息
  - `WXMenuPublish` — 菜单发布
- `listener/mq/OfficialAccountCallbackListener` — RocketMQ 消费者，**已 `@Deprecated`**。

### 5.6 配置层（configuration）

| 配置类 | 作用 |
| --- | --- |
| `WebMvcConfiguration` | 注册拦截器、FastJson2 消息转换器 |
| `AsyncConfiguration` | 异步线程池（核心 15 / 最大 30 / 队列 200，CallerRunsPolicy） |
| `CorsConfig` | 跨域 |
| `MybatisPlusConfiguration` | MyBatis-Plus 分页插件 + 自动填充 |
| `RedissonClientConfiguration` | Redisson 客户端 |
| `FeignConfiguration` | Feign 配置 |
| `XxlJobConfiguration` | XXL-Job 执行器 |
| `QrConfigConfiguration` | 二维码配置 |
| `BusiAccessLogConfiguration` / `BizLogHandler1` | 业务访问日志 |
| `GlobalExceptionHandler` | 全局异常处理 |

## 6. 鉴权机制

采用 **JWT + 双拦截器** 模型，拦截所有 `/api/**`：

1. **`AccessInterceptor`（order=0）**：从请求头 `Authorization` 取 token，经 `TokenService.verify` 校验并解析出 `userId`，再查 `UserAppService` 得到当前用户应用上下文放入 `AccessContext`（ThreadLocal）；请求结束清理。
2. **`AuthorityInterceptor`（order=1）**：基于 `@Auth(codes={...})` 注解做组件级权限校验。**当前实现中 `preHandle` 直接 `return true`，细粒度权限逻辑已注释，处于关闭状态**，保留扩展点。
3. **白名单**（`WebMvcConfiguration.excludePaths` + `application.yml` 的 `security.excludePaths`）：登录 `/api/login/**`、文档 `/api/docs/**`、回调 `/api/officialAccount/action/callback/**`、企业微信校验、部分二维码/短链对外接口、后台用户管理等。
4. **全局异常**：`GlobalExceptionHandler` 统一捕获 `BizException`、`LoginException`、`IllegalArgumentException` 等，返回标准 `ApiResponse`。

> 登录入口：`POST /api/login`（`LoginController`），入参 `LoginParams{userName, password}`，返回 JWT token。

## 7. 对外集成

通过 `application-*.yml` 的 `api` 配置对接内部系统：

- `api.user-center` — 用户中心（`9096`）
- `api.analysis-url` — 分析服务（`9618`）
- `api.mall-urls` — 商城扫码回传（`9085`，`/api/member/eduScrmQrScanMember`）

微信侧：

- 公众号 access_token：`https://api.weixin.qq.com/cgi-bin/token`
- H5 OAuth2：`https://api.weixin.qq.com/sns/oauth2/access_token`
- 回调地址：`/api/officialAccount/action/callback`

## 8. 环境配置（profile）

| profile | 数据库 | Redis | ES | RocketMQ | XXL-Job | 用途 |
| --- | --- | --- | --- | --- | --- | --- |
| `dev` | 腾讯云 CDB `wx_platform` | 127.0.0.1:6379 | 本地 9200 | 本地 9876 | 本地 18080 | 本地开发 |
| `test`（默认） | 腾讯云 CDB `wx_platform` | 192.168.203.1:6379 | 192.168.203.1:9200 | 192.168.203.1:9876 | 192.168.203.1:18080 | 内网测试 |
| `pro` | `lpt_wx_platform`（172.17.16.13） | 172.17.0.8:6380 | 腾讯云 ES 集群 | 172.17.16.111:9876 | 172.17.16.111:18080 | 生产（关闭 API 文档） |

二维码平台配置 `qrcodeplatform.qrcode`：对外域名 `https://qrs.liupinshuyuan.com`，目标路径、尺寸（400×400）、边距、活码上限等。

## 9. 关键业务流程

1. **公众号接入**：在 `OfficialAccountController` 录入公众号（appId/appSecret/子类型）→ 存入 `WxApp` 表；后续 access_token 由 `AccessTokenService` 自动获取并缓存。
2. **消息回调**：微信推送至 `/api/officialAccount/action/callback` → `CallBackService.handleCallback` → 经 `WXBizMsgCrypt` 解密 → 根据事件类型（关注/扫码/取关/文本等，见 `OfficialAccountEventType`、`MsgType`）分发处理，含自动回复、粉丝同步、扫码统计等。
3. **图文发布**：草稿 `OfficialAccountDraftService` → 发布 `OfficialAccountPublishService` / `FreePublishService`。
4. **消息推送**：`OfficialAccountPushService` 创建推送任务 → 通过 XXL-Job 延迟触发 `OfficialAccountMsgPushListener.immediatelyPush` → 调用 `OfficialAccountMsgPushService` 客服/群发接口。
5. **二维码平台**：生成活码（ZXing）→ 上传 COS → 扫码命中 → 回传商城 SCRM + 统计扫码流量（`QrCodePlatformUserScanCodeFlow`）。

## 10. API 文档

- springdoc-openapi，路径 `/api/docs`（`application.yml` → `springdoc.api-docs.path`）。
- 生产环境（`pro`）已通过 `springdoc.api-docs.enabled: false` 关闭。

## 11. 开发约定

- 包名统一 `com.liupin.wxplatform.*`，作者多标注 `@author Jack` / `author myd`。
- 返回值统一 `ApiResponse<T>`（`common/ApiResponse`）。
- 参数校验使用 `CustomerAssert.notNull(...)` 抛业务异常。
- 日志使用 Lombok `@Slf4j` + Log4j2。
- 代码中 `rest/wecaht` 为既有拼写（微信 wechat），新增代码请勿延续该拼写错误。

---

相关文档：启动/热部署/打包手册见 [deply.md](deply.md)。
