# liupin-usercenter-service 模块功能分析

> 模块路径：`liupin-service/liupin-usercenter-service/`
> 主类：`com.liupin.usercenter.UserCenterApp`（`@SpringBootApplication`）
> 默认端口：`9096`（见 `src/main/resources/bootstrap.yaml`）

## 1. 模块定位

用户中心微服务，是 liupin 云课堂/掌上碑帖等产品线的**统一账号与权限中心**。承担用户注册、多渠道登录鉴权、Token 签发与刷新、用户资料管理、后台 RBAC（角色/菜单/功能/组件）体系、教师管理、用户黑名单、短信验证码、微信生态能力（小程序码/URL Link/模板消息/分享配置）等职责，并为其它微服务提供内部用户查询接口。

服务注册于 **Nacos**（`@EnableDiscoveryClient`），配置从 **Nacos Config** 拉取（`bootstrap-*.yaml`），通过 **OpenFeign**（`@EnableFeignClients`）调用其它服务，使用 **MyBatis** + **MySQL** 持久化、**Redis** 缓存/限流、**Druid** 连接池。

## 2. 技术栈

| 维度 | 选型 |
|------|------|
| 框架 | Spring Boot 2.3.4.RELEASE、Spring Cloud Hoxton.SR8、Spring Cloud Alibaba（Nacos discovery + config） |
| 语言/JDK | Java 8（项目锁定 Lombok 1.18.20，须用 JDK 8 编译） |
| Web | spring-boot-starter-web（`@RestController`，统一响应 `ApiResponse<T>`） |
| 持久化 | MyBatis Spring Boot Starter + MySQL + Druid 连接池 |
| 缓存 | spring-boot-data-redis |
| RPC | spring-cloud-starter-openfeign + feign-httpclient |
| 监控 | spring-boot-starter-actuator + spring-boot-admin-starter-client（暴露全部 endpoints，Prometheus 指标） |
| 日志 | log4j2 + LMAX Disruptor（异步日志） |
| 短信 | 腾讯云 SMS（`tencent-spring-boot-starter`）、阿里云 dysmsapi（`dysmsapi20170525`） |
| 微信 | `wechat-spring-boot-starter` |
| 对象存储 | 腾讯云 COS（头像/图片） |
| 其它 | Apache POI（Excel）、fastjson、hutool、bouncycastle（AES 加解密） |

## 3. 架构分层

```
controller (25 个 @RestController, 143 个 HTTP 接口)
    ↓
service / service.impl (27 个 Service 接口 + 实现)
    ↓
mapper (MyBatis 接口) + resources/mapper/*.xml (27 个映射文件)
    ↓
MySQL (库: lpt_user_center)
```

横切组件位于 `component/`：`aspect`（切面，如 `@LimitAccess` 限流、`@EnableAccessLog` 访问日志）、`feignclient`（外部服务调用）、`handler`、`interceptor`。配置在 `config/`（`properties` 自定义配置类、`constance` 常量）。统一响应包装 `ApiResponse<T>`（`status/msg/data` + 分页字段 `totalNum/pageIndex/pageSize/totalPage`）来自 `liupin-common`。

## 4. 功能域与接口分布

按业务域划分（接口前缀即 `@RequestMapping` 类级路径）：

### 4.1 登录鉴权（LoginController `/api/v1/login`，~33 接口）
核心登录中心，覆盖全终端多渠道：
- B 端账号密码登录/登出/改密：`backLogin`、`backLoginOut`、`backUpdateUserPwd`
- 标准账号密码登录：`standardLogin`
- 手机验证码登录/注册：`smsLogin`
- 微信/小程序授权登录：`wxLogin`、`wxLogin/v2`（带合并手机号）
- 第六宝（掌上碑帖扫码）微信登录：`sixthProductLogin/wxLogin`、`wxLoginV2ForPhone`、`wxLoginV2NonePhone`、`successNotice`、`sixthProductUserToken`（设备轮询取 token）、`dyLogin`（抖音登录）
- 友盟一键登录：`umengLogin`
- 小程序手机号登录：`miniProgramPhoneLogin`、`miniProgramPhoneLoginForBack`
- 苹果账号登录/注册绑定：`appleLogin`、`appleRegisterOrBind`
- 微信授权手机登录：`wxAuthPhoneLogin`
- 扫码登录/Token 刷新/解析：`scanCodeLogin`、`refresh`、`refreshV2`、`parseLoginToken`
- 游客登录、碑帖退出：`anonymousLogin`、`tabletApp/logout`
- 外部登录：`externalLogin`、`wxAndPhone/register`

### 4.2 Art 碑帖账号（ArtController `/api/art`，9 接口）
`auth`（appId/secret 取授权）、`login/password`、`login/phone`、`login/phone/password`、`miniAppLogin`、`modifyPassword`、`pcScanLogin`、`registerUser`。

### 4.3 用户资料（UserController `/api/v1/user`、UserControllerV2 `/api/v2/user`，~18 接口）
用户基本信息查询/修改、`getUserById`、`infoByUid`、`getUnionIdByUserId`、`getOpenIdByUserWxCode`（毛笔定制支付用）、`getPhoneByUserWxCodeAndEncryptedDataAndIV`、`phoneBind`/`bindPhoneByMiniPrograms`、`checkVerifyCode`、`loggedOff`（注销）、`checkUserFirstLogin`、`tabletPlatExchangeToken`、V2 的 `tablet/phoneBind`、`tablet/wxBind`。

### 4.4 碑帖平板用户（SysUserController `/api/sysUser`，~9 接口）
`tablet/deregister/{userId}`（注销）、`tablet/merge`（合并）、`tablet/phone`（换手机）、`tablet/recover`（恢复）、`tablet/view/progress`、`modifyPassword`、`userInfos`、`openIds`。

### 4.5 B 端用户（UserBackController `/api/v1/userBack`，6 接口）
`getUserDetail`（按手机号）、`getRoleDetail`、`getUserDetailsByIds`、`addUser`、`updateUser`、`password`（改密）。

### 4.6 后台 RBAC（`controller/admin/`）
- **UserManagerController `/api/v1/admin/sysBackUser`**（~17 接口）：后台用户增改、批量注销/冻结/解冻/重置密码、角色与组件分配、用户详情、用户列表、可选角色、用户所属系统。
- **RoleManagerController `/api/v1/admin/role`**（~7 接口）：角色增改、状态切换、分页列表、角色组件查询与分配。
- **ComponentManagerController `/api/v1/admin/component`**（~8 接口）：组件增改删、状态切换、组件树（按系统/分类）、平台与系统列表。
- **MenuController `/api/v1/menu`、FuncController `/api/v1/func`**：菜单树、当前用户功能列表。
- **AdminSysUserBlacklistController `/api/v1/admin/blacklist`**：用户黑名单增删。
- **AuthController `/api/v1/admin/auth`**：内部业务（如黑名单业务）获取 token。
- **SystemLogController `/api/v1/admin/log`**：系统日志列表、用户日志列表。
- **SysTeacherController `/api/teacher`**：教师记录增删改查。
- **EvaluationUserController `/api/evaluationUser`**：评测用户分页/列表/修改。

### 4.7 短信（SmsController `/api/v1/sms`、SmsControllerV2 `/api/v2/sms`，~4 接口）
`send`（发送验证码，腾讯云/阿里云双通道）、`verifyImg`（生成图文验证）、`check`（校验）。

### 4.8 微信生态（WeChatController `/api/v1/wechat`，~12 接口）
`accessToken`/`accessTokenForOpen`、`callback`（微信回调）、`getGenerateUrllink`/`getGenerateUrllink2`/`getQueryUrllink`（URL Link 生成）、`getWxAcodeUnlimit`（小程序码）、`miniProgramsMsgSend`（模板消息推送）、`saveTmpMsgAllow`/`tmpMsgAllow`（模板消息授权记录）、`sharedConfig`（分享配置）、`wechatUserInfo`。

### 4.9 内部服务接口（InternalController `/api/internal`，~9 接口）
供其它微服务调用：`initUser`、`registeUser`、`userInfo`、`selectUserInfo`、`userList`、`userPage`、`users`、`userDetail`、`userAuthInfo`、`updateUser`。

### 4.10 第三方/外部对接
- **WpUserController `/api/wp`**：微铺（wp）登录。
- **ZheMeiMoBaoController `/api/zheMeiMoBao`**：浙美墨宝小程序登录。
- **LiuliuController `/api/liuliu`**：六六用户 `addOrUpdateUser`。
- **UserSyncController `/api/v1/userSync`**：用户同步（`backUser`、`userInfo`）。
- **TempController `/api/temp`**：临时上传。

## 5. 数据模型

数据库 `lpt_user_center`，核心实体（`domain/` 包，对应 `mapper/*.xml`）：

- 账号主体：`SysUser`（C 端用户）、`SysBackUser`（B 端后台用户）、`ArtAccount`（碑帖账号）
- RBAC：`SysBackRole`、`SysBackMenu`、`SysBackFunc`、`SysBackComponent`、`SysBackPlatRelation`，以及关联表实体 `SysBackRoleMenus`/`SysBackRoleFunc`/`SysBackRoleComponent`/`SysBackUserRoles`/`SysBackUserMenus`/`SysBackUserFunc`/`SysBackUserComponent`
- 登录记录与第三方绑定：`SysUserAuthLogin`、`SysUserAuthLoginWxScan`、`SysUserAppleAuthLogin`、`SysUserLoginRecord`、`UserDevices`、`UserAnonymousLogin`、`UserLoginWxUnionIdErrorInfo`
- 业务：`SysTeacher`、`SysUserTeacherRelation`、`SysUserBlacklist`、`SmsConfig`、`SixthProductGetUserToken`、`Permission`

> `db.sql` 仅包含 `sys_back_component`、`sys_back_role_component`、`sys_back_user_component` 三张表的 DDL，其余表结构由 DBA/其它脚本维护。

## 6. 关键外部集成

| 集成 | 用途 | 配置位置 |
|------|------|----------|
| 腾讯云 SMS / COS | 短信验证码、对象存储（头像图片） | `bootstrap.yaml` `tencent.sms` / `cos` |
| 阿里云 dysmsapi | 短信验证码备用通道 | `bootstrap.yaml` `ali.sms` |
| 微信开放平台/小程序 | 登录、小程序码、URL Link、模板消息、分享 | Nacos `wechatConfig.yaml` / `wechat-appconfig.yaml` |
| 友盟 | 一键登录 | `bootstrap.yaml` `umeng` |
| 抖音 | 第六宝抖音登录 | `dy.auth.configs` |
| 第六宝扫码 | AES 加解密扫码字符串 | `sixthproduct.secret` / `iv` |
| 中台商城 | 校验后台用户登录态 | `middle.mall.tokenUrl` |

## 7. 接口文档

- 完整接口清单（Swagger 3.0 / OpenAPI 3.0 JSON）见同目录 `api.json`（25 个 Controller、143 个接口、72 个 Schema）。
- 打包/部署/热部署命令见同目录 `intro-deploy.md`。
