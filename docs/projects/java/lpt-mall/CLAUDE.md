# CLAUDE.md — 芋道（ruoyi-vue-pro）项目核心指令

> 本文件是 Claude Code 在本仓库工作时的核心指令。所有子代理（agents）、技能（skills）、规则（rules）、命令（commands）、钩子（hooks）均围绕本文件展开。

## 1. 项目概述

- **项目**：芋道源码 ruoyi-vue-pro（`groupId: cn.iocoder.boot`，`artifactId: yudao`，`revision: 2.0.1-jdk8-snapshot`）。
- **来源**：2024/7/9 从 https://github.com/YunaiV/ruoyi-vue-pro 拉取作为底层框架。
- **语言/运行时**：Java 8（`java.version=1.8`），Maven 多模块项目。
- **核心框架**：Spring Boot 2.7.18、Spring Security、MyBatis-Plus、Druid（dynamic-datasource）、Redis（Redisson + Lock4j）、RocketMQ、Flowable（工作流）、Spring Cloud（部分）。
- **数据库**：MySQL 为主，兼容达梦（DmJdbcDriver18）；Druid + dynamic-datasource 多数据源；MyBatis-Plus + MyBatis-Plus-Join。
- **接口文档**：Knife4j + SpringDoc OpenAPI 3（`@Tag` / `@Operation` / `@Parameter`）。
- **其它**：EasyExcel、MapStruct、Lombok、Hutool、FastJSON、MinIO、微信 Java（mp/miniapp/pay）、阿里云/腾讯云 SMS、JustAuth（社交登录）、Spring Boot Admin、SkyWalking APM、ip2region、JimuReport、screw（数据库文档）、Velocity、JSch。

## 2. 模块地图

仓库采用「主项目 + 业务模块」结构，每个业务模块再拆分为 `*-api`（对外 API，供其它模块依赖）与 `*-biz`（业务实现）两个子模块。

| 模块 | 作用 |
| --- | --- |
| `yudao-dependencies` | BOM，统一管理所有依赖版本 |
| `yudao-framework` | 自研 starter 集合：`yudao-common`、`*-web`、`*-security`、`*-mybatis`、`*-redis`、`*-mq`、`*-job`、`*-excel`、`*-monitor`、`*-websocket`、`*-biz-data-permission`、`*-biz-ip`、`*-biz-tenant`、`*-protection`、`*-test` |
| `yudao-server` | 启动主项目（`yudao-server` Spring Boot 应用，默认 `local` profile） |
| `yudao-module-system` | 系统：用户/角色/部门/字典/权限/租户/短信/邮件/通知/社交登录 |
| `yudao-module-infra` | 基础设施：代码生成/文件/配置/Redis 监控/接口文档/定时任务 |
| `yudao-module-member` | 会员中心 |
| `yudao-module-bpm` | 工作流（Flowable） |
| `yudao-module-mp` | 微信公众号 |
| `yudao-module-pay` | 支付 |
| `yudao-module-mall` | 商城 |
| `yudao-module-erp` | ERP |
| `yudao-module-crm` | CRM（默认未启用） |
| `yudao-module-report` | 报表（JimuReport，默认未启用） |

根 `pom.xml` 的 `<modules>` 决定实际参与编译的模块；`yudao-module-crm`、`yudao-module-report`、`yudao-example` 默认被注释关闭，新增/启用模块时在根 `pom.xml` 取消注释。

## 3. 常用命令

```bash
# 编译整个工程（Java 8 + flatten-maven-plugin 统一 revision）
mvn clean compile -T 1C

# 安装到本地仓库（模块间依赖 -api 时需要先 install）
mvn clean install -T 1C -DskipTests

# 只编译/测试某模块（-pl 指定模块，-am 同时编译依赖）
mvn clean test -pl yudao-module-system/yudao-module-system-biz -am

# 启动服务端（默认 local profile，端口 48080）
mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=local
# 或用 test profile
mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=test

# 停止服务端
pkill -f "yudao-server"
```

- 启动主类：`yudao-server` 模块下的 `cn.iocoder.yudao.server.YudaoServerApplication`。
- 配置文件：`yudao-server/src/main/resources/application{,-local,-dev,-test,-pro}.yaml`。
- 单测位于各 `*-biz` 模块的 `src/test/java`，集成测试位于 `src/test-integration/java`；使用 JUnit 5 + `yudao-spring-boot-starter-test`。

## 4. 架构与分层约定（强约束）

每个 `*-biz` 模块的包根为 `cn.iocoder.yudao.module.{module}`，内部固定分层（以 `system` 模块 `dept` 功能为例）：

```
cn.iocoder.yudao.module.system
├── controller
│   ├── admin/dept/               # 后台管理端 REST 控制器
│   │   ├── DeptController.java
│   │   └── vo/dept/               # 接口入参/出参 VO
│   │       ├── DeptSaveReqVO.java    # 新增/修改入参
│   │       ├── DeptPageReqVO.java    # 分页查询入参（继承 PageParam）
│   │       ├── DeptListReqVO.java    # 列表查询入参
│   │       ├── DeptRespVO.java       # 详情/分页出参
│   │       └── DeptSimpleRespVO.java # 精简出参（下拉等）
│   └── app/dept/                 # 用户 App 端 REST 控制器（如有）
├── service/dept/                 # 业务逻辑：DeptService + DeptServiceImpl
├── dal
│   ├── dataobject/dept/DeptDO.java   # 数据对象，@TableName/@TableId，extends BaseDO|TenantBaseDO
│   ├── mysql/dept/DeptMapper.java    # MyBatis-Plus Mapper，extends BaseMapperX<DO>，@Mapper
│   └── redis/dept/...                # Redis DAO（如有）
├── convert/dept/DeptConvert.java     # MapStruct 转换器（部分新代码直接用 BeanUtils.toBean）
├── framework/...                 # 模块内框架配置（captcha/datapermission/operatelog/sms/web）
├── job/dept/...                  # 定时任务
└── mq/{consumer,message,producer}/...  # RocketMQ 消息

cn.iocoder.yudao.module.system.api.dept   # 在 *-api 子模块：对外 API
├── DeptApi.java                       # 接口
├── DeptApiImpl.java                   # 实现（在 *-biz 模块）
└── dto/                               # 跨模块 DTO（避免直接传递 DO）
```

**命名铁律**：
- DO 后缀 `DO`，Mapper 后缀 `Mapper`，Service 接口 `{X}Service` + 实现 `{X}ServiceImpl`，Controller 后缀 `Controller`，VO 后缀 `ReqVO`/`RespVO`/`PageReqVO`/`ListReqVO`/`SimpleRespVO`，跨模块 DTO 后缀 `DTO`。
- 跨模块调用**必须**走 `*-api` 子模块的 `XxxApi`，**禁止**直接 import 另一模块的 `DO`/`Service`。
- Controller 返回统一包装 `CommonResult<T>`，分页返回 `PageResult<T>`，分页入参继承 `PageParam`。
- Controller 使用 `@PreAuthorize("@ss.hasPermission('{module}:{feature}:{action}')")` 做权限校验。
- 对象转换优先 `BeanUtils.toBean(source, TargetClass.class)`（`yudao-common` 提供）；复杂映射用 MapStruct `Convert`，禁止手写 `setXxx`。

## 5. 编码约定

- **Java 8**：不得使用 Java 9+ 语法（`var`、`record`、`switch` 表达式、`Stream.toList()` 等）。集合用 `CollUtil`/`ListUtil`（Hutool）或 `Collectors.toList()`。
- **Lombok**：DO/VO/DTO 使用 `@Data`；继承基类时加 `@EqualsAndHashCode(callSuper = true)`。
- **依赖注入**：用 `@Resource`（项目默认风格），非 `@Autowired`。
- **MyBatis-Plus**：Mapper 继承 `BaseMapperX<DO>`（自研增强，含 `selectList(LambdaQueryWrapperX)` 等）；条件构造用 `LambdaQueryWrapperX` 的 `likeIfPresent/eqIfPresent/inIfPresent` 等 `*IfPresent` 方法，自动忽略空值。
- **审计字段**：DO 继承 `BaseDO`（含 `createTime/updateTime/creator/updater/deleted`）或 `TenantBaseDO`（多租户，自动带 `tenantId`）。`@TableField(fill = ...)` 由框架自动填充。
- **多租户**：租户表 DO 继承 `TenantBaseDO`；涉及租户的 Mapper/SQL 由 `yudao-spring-boot-starter-biz-tenant` 自动拦截。跨租户操作用 `TenantUtils.executeIgnore(() -> ...)`。
- **异常**：抛 `ServiceException`，使用 `exception(ErrorCode)` 静态导入；错误码集中在各模块 `enums.ErrorCodeConstants`。
- **时间**：Jackson 配置 `write-dates-as-timestamps: true`，时间统一时间戳；用 `LocalDateTime`，工具 `LocalDateTimeUtils`。
- **注释**：类/公有方法使用 Javadoc，`@author` 标注作者；复杂逻辑加中文行注释（与现有代码风格一致）。

## 6. 强制红线（项目级规则）

详见 `.claude/rules/`。重点：

1. **不做任何数据库操作**：不执行 `DDL/DML`、不连库、不跑迁移脚本、不直接修改数据。需要建表/改表时只生成 SQL 文件（放 `sql/` 目录）并交由人工执行。参见 `rules/no-db-ops.md`。
2. **禁止修改 `target/` 与生成代码**：`target/`、`*.class`、`generated-sources/`、`.flattened-pom.xml` 均为构建产物，不得编辑。由 `hooks/prevent_target_writes.py` 自动拦截。
3. **新增模块需在根 `pom.xml` 注册 `<module>`**，并完成 `-api`/`-biz` 拆分与 `framework` 包。
4. **接口必须带权限注解与 Swagger 注解**（`@Tag`/`@Operation`/`@PreAuthorize`）。
5. **跨模块禁止直传 DO**，必须经 `*-api` 的 DTO。

## 7. Git 工作流

- 默认分支 `master`，开发分支 `dev-bak` 等；提交前确保 `mvn clean compile -T 1C` 通过。
- 提交信息遵循现有风格（中文简述）；Claude 生成的 commit/PR 按会话要求附加 Co-Authored-By / Generated with Claude Code 标识。
- `.requirements/` 目录被 `.gitignore` 忽略（仅保留 `.gitignore`），需求文档与中间产物不入库。
- `.claude/settings.local.json` 为本地个人配置，已加入 `.gitignore`；`.claude/settings.json` 入库。

## 8. Claude 资产索引

| 类型 | 路径 | 说明 |
| --- | --- | --- |
| 子代理 | `.claude/agents/*.md` | java-backend-dev、module-scaffolder、conventions-reviewer、api-doc-reviewer、sql-reviewer |
| 技能 | `.claude/skills/*/SKILL.md` | yudao-new-crud、yudao-new-module、yudao-run-server、yudao-conventions-check |
| 规则 | `.claude/rules/*.md` | java-conventions、module-structure、no-db-ops、api-conventions、security-conventions |
| 命令 | `.claude/commands/*.md` | /yudao-new-crud、/yudao-new-module、/yudao-run、/yudao-review |
| 钩子 | `.claude/hooks/*.py` + `settings.json` | prevent-target-writes（PreToolUse）、session-context（SessionStart） |
