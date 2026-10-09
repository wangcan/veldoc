# 规则：安全约定

> 项目使用 Spring Security + `yudao-spring-boot-starter-security`，权限基于 RBAC + 多租户。

## 权限
- 所有后台接口必须 `@PreAuthorize("@ss.hasPermission('{module}:{feature}:{action}')")`，无例外。
- App 端接口用 `@PreAuthorize("@ss.hasScope('...)')` 或登录态校验，按现有模块模式。
- 权限码格式 `{module}:{feature}:{action}`，action ∈ `create|update|delete|query|export`。
- 新增权限码需配套菜单/按钮 SQL（生成到 `sql/`，人工执行），不自动写库。

## 敏感数据
- 密码：用 `PasswordUtils`/BCrypt；不记录明文日志。
- 手机号/身份证/银行卡等：用 `yudao-spring-boot-starter-protection` 脱敏注解（如 `@Desensitize`）。
- 日志：不打印完整 token、密码、密钥；使用 `OperateLog` 注解记录关键操作。

## 密钥与配置
- 密钥、第三方 AppSecret、数据库密码**不硬编码**，放 `application-{profile}.yaml` 并通过环境变量/配置中心注入。
- `application-local.yaml` 可含本地配置但**不提交真实密钥**；`application-my.yaml` 已被 gitignore。
- 提交前检查 diff 不含密钥（`grep -RE 'password|secret|appSecret|accessKey'` 复核）。

## SQL 注入
- 查询一律用 MyBatis-Plus `LambdaQueryWrapperX` 参数化；禁止字符串拼接 SQL。
- 自定义 XML SQL 用 `#{}` 占位，不用 `${}`（除非排序字段且经白名单校验）。

## 文件上传
- 上传走 `yudao-module-infra` 的文件服务（MinIO/本地/七牛等），不直接落业务目录。
- 校验文件类型/大小（`spring.servlet.multipart.max-file-size=16MB`）。

## 跨模块
- 跨模块调用走 `*-api` 的 `Api`，不直传 DO；DTO 字段最小化，不暴露内部字段。

## 红线
- 不做数据库操作（见 `no-db-ops.md`）。
- 不为绕过权限校验而反射/内省安全 bean。
