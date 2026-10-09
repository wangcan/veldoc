# init-claude.md — Claude 配置初始化结果说明

> 本文件为需求 `.requirements/ai/ai.txt` 中**需求1**的处理结果描述。
> 需求3~10 已按 ai.txt 第 20 行「忽略以下所有需求」忽略，未执行。
> 全程未做任何数据库操作（遵守 ai.txt 第 1 行红线）。

## 一、需求与依据

- **需求1**：基于开源项目 ruoyi-vue-pro（2024/7/9 拉取，Java 8），结合当前项目技术栈，按给定目录结构完善系统 Claude 相关设置，生成 agents/skills/rules/commands/hooks 等文件，并将处理结果存到本文件。
- **技术栈勘察依据**：
  - 根 `pom.xml`：`groupId=cn.iocoder.boot`、`artifactId=yudao`、`revision=2.0.1-jdk8-snapshot`、`java.version=1.8`、`spring.boot.version=2.7.18`、`mapstruct=1.5.5.Final`、`lombok=1.18.30`、flatten-maven-plugin 统一 revision。
  - `yudao-dependencies/pom.xml`：MyBatis-Plus、Druid+dynamic-datasource、Redisson+Lock4j、RocketMQ、Flowable、EasyExcel、Knife4j+SpringDoc、Hutool、MinIO、微信 Java、阿里云/腾讯云 SMS、JustAuth、Spring Boot Admin、SkyWalking、ip2region、JimuReport、screw、Velocity、JSch、达梦 DmJdbcDriver18 等。
  - `yudao-framework`：自研 starter（common/web/security/mybatis/redis/mq/job/excel/monitor/websocket/biz-data-permission/biz-ip/biz-tenant/protection/test）。
  - 业务模块：`yudao-module-{system,infra,member,bpm,mp,pay,mall,erp}` 默认启用；`crm/report/example` 默认注释关闭；每模块拆 `-api`/`-biz`。
  - 分层与命名（以 `system/dept` 为样本）：`controller/admin/{feature}/{X}Controller` + `vo/{feature}/{X}{Save|Page|List}ReqVO`/`{X}RespVO`/`{X}SimpleRespVO`、`service/{feature}/{X}Service(+Impl)`、`dal/dataobject/{feature}/{X}DO`（`@TableName`/`@TableId`/`extends TenantBaseDO|BaseDO`）、`dal/mysql/{feature}/{X}Mapper`（`extends BaseMapperX`/`LambdaQueryWrapperX`）、`convert/{feature}/{X}Convert`（或 `BeanUtils.toBean`）、`api/{feature}/{X}Api(+Impl)/dto`。Controller 使用 `@Tag`/`@Operation`/`@Parameter`/`@PreAuthorize("@ss.hasPermission(...)")`，返回 `CommonResult<T>`/`PageResult<T>`。
  - `yudao-server`：启动主项目，默认 `local` profile，端口 48080；`application.yaml` 允许循环依赖、Knife4j 启用、Flowable `database-schema-update`。

## 二、生成的目录结构

```
/data/java/ruoyi-vue-pro
├── CLAUDE.md                              # 项目核心指令（新增）
├── .gitignore                             # 追加 .claude/settings.local.json 忽略
├── .claude/
│   ├── settings.json                      # 项目基础设置（提交到 Git，新增）
│   ├── settings.local.json                # 本地个人覆盖配置（已存在，保留；已加入 .gitignore）
│   ├── agents/                            # 自定义子代理（5 个，新增）
│   │   ├── java-backend-dev.md
│   │   ├── module-scaffolder.md
│   │   ├── conventions-reviewer.md
│   │   ├── api-doc-reviewer.md
│   │   └── sql-reviewer.md
│   ├── skills/                            # 自定义技能（4 个，新增）
│   │   ├── yudao-new-crud/SKILL.md
│   │   ├── yudao-new-module/SKILL.md
│   │   ├── yudao-run-server/SKILL.md
│   │   └── yudao-conventions-check/SKILL.md
│   ├── rules/                             # 规则文件（5 个，新增）
│   │   ├── no-db-ops.md
│   │   ├── module-structure.md
│   │   ├── java-conventions.md
│   │   ├── api-conventions.md
│   │   └── security-conventions.md
│   ├── commands/                          # 自定义斜杠命令（4 个，新增）
│   │   ├── yudao-new-crud.md
│   │   ├── yudao-new-module.md
│   │   ├── yudao-run.md
│   │   └── yudao-review.md
│   └── hooks/                             # 自动化钩子脚本（2 个，新增）
│       ├── prevent_target_writes.py
│       └── session_context.py
└── .requirements/ai/init-claude.md        # 本文件（处理结果描述）
```

## 三、各文件内容与作用

### 1. CLAUDE.md（项目核心指令）
Claude Code 在本仓库工作的总纲。涵盖：项目概述（yudao/Java8/SpringBoot2.7.18/技术栈）、模块地图（11 个业务模块 + framework + server）、常用命令（编译/测试/启动/停止）、架构与分层约定（`-api`/`-biz` 拆分、包结构、命名铁律）、编码约定（Lombok/`@Resource`/`BaseMapperX`/`LambdaQueryWrapperX`/`BeanUtils.toBean`/`CommonResult`/多租户/异常/Java8 限制）、强制红线（禁库、禁改 target、模块注册、接口注解、跨模块禁传 DO）、Git 工作流、Claude 资产索引。

### 2. .claude/settings.json（项目基础设置，入库）
- `permissions.allow`（29 条）：放行只读/构建类命令（`mvn clean compile/install/test`、`mvn spring-boot:run`、`git status/log/diff/branch/show/blame`、`ls/find/grep/rg/cat/head/tail/wc/tree`、`pkill -f yudao-server`、版本查询），减少日常权限打断。
- `permissions.deny`（12 条）：硬禁危险与数据库命令（`rm -rf`、`sudo`、`mysql/psql/mongo/redis-cli/sqlplus/disql`、`mvn flyway/liquibase`、读取 `settings.local.json`），落实「禁库」红线。
- `permissions.ask`（8 条）：外发/改写操作需确认（`git push/commit/merge/rebase/reset/checkout`、`mvn deploy/release`）。
- `hooks`：`PreToolUse`(Edit|Write|MultiEdit) → `prevent_target_writes.py`；`SessionStart` → `session_context.py`。
- `env`：`JAVA_PROJECT_VERSION`、`YUDAO_JAVA_VERSION=1.8`、`YUDAO_NO_DB_OPS=true`。

### 3. .claude/settings.local.json（本地个人覆盖，已 gitignore）
项目内已存在（用户个人 allow 列表，含 `mvn compile/spring-boot:run`、`pkill`、`javap`、`Read(/tmp/**)` 等）。本次保留不动，并在 `.gitignore` 增加 `.claude/settings.local.json` 使其不入库。

### 4. agents/（自定义子代理）
| 文件 | 作用 |
| --- | --- |
| `java-backend-dev.md` | Java 后端开发代理。按 yudao 分层与命名在模块内编写 Controller/Service/DO/Mapper/VO/Convert，遵守 Java8/`@Resource`/`BaseMapperX`/`BeanUtils.toBean`/`@PreAuthorize` 等约定，产出后自检编译。 |
| `module-scaffolder.md` | 业务模块脚手架代理。新建 `yudao-module-{name}` 的 `-api`/`-biz` 子模块、pom、分层包、framework 配置，注册根 pom 与 server pom。 |
| `conventions-reviewer.md` | 只读约定审查代理。核对分层/命名/Mapper/Convert/异常/Java8/跨模块直传 DO 等 11 项，输出 findings。 |
| `api-doc-reviewer.md` | 只读接口文档审查代理。核对 Controller 的 `@Tag`/`@Operation`/`@Parameter`/`@PreAuthorize`/`@Valid`/返回类型/路径动词规范。 |
| `sql-reviewer.md` | 只读 SQL 审查代理。核对表前缀/tenant_id/审计字段/utf8mb4/索引/幂等/无物理外键；**绝不执行 SQL**，高亮破坏性语句。 |

### 5. skills/（自定义技能）
| 技能 | 作用 |
| --- | --- |
| `yudao-new-crud` | 在指定模块为某功能生成完整 CRUD（DO/Mapper/Service/Controller/VO/Convert + ErrorCode + 建表 SQL），自动编译自检。 |
| `yudao-new-module` | 脚手架新建业务模块（pom/分层包/framework/server 引用），编译自检。 |
| `yudao-run-server` | 编译依赖并后台启动 yudao-server（默认 local，48080），轮询日志确认就绪，返回 PID/日志/地址。 |
| `yudao-conventions-check` | 按约定审查当前 diff 或指定路径的 Java/SQL，只读不改，汇总 findings。 |

### 6. rules/（规则文件）
| 文件 | 作用 |
| --- | --- |
| `no-db-ops.md` | 最高优先级红线：禁止任何数据库操作（不连库/不 DDL/不 DML/不迁移工具/不客户端 CLI）；只允许生成 SQL 脚本与只读审查。 |
| `module-structure.md` | 业务模块 `-api`/`-biz` 拆分与 `-biz` 包分层强约束、模块注册与命名一致性。 |
| `java-conventions.md` | Java8 语法限制、Lombok、`@Resource`、MyBatis-Plus `BaseMapperX`/`LambdaQueryWrapperX`、`BeanUtils.toBean`、Controller/异常/多租户/注释约定。 |
| `api-conventions.md` | REST 路径/动词/HTTP 方法映射、必须注解（`@Tag`/`@Operation`/`@Parameter`/`@PreAuthorize`/`@Valid`）、`CommonResult`/`PageResult`、EasyExcel 导出。 |
| `security-conventions.md` | 权限注解、敏感数据脱敏、密钥不硬编码、SQL 注入防护、文件上传、跨模块最小化 DTO。 |

### 7. commands/（自定义斜杠命令）
| 命令 | 作用 |
| --- | --- |
| `/yudao-new-crud <模块> <功能> [字段:类型 ...]` | 调用 `yudao-new-crud` 技能生成 CRUD。 |
| `/yudao-new-module <模块名>` | 调用 `yudao-new-module` 技能新建模块。 |
| `/yudao-run [local\|dev\|test]` | 编译并后台启动服务端。 |
| `/yudao-review [路径或分支]` | 并行调用三个审查代理汇总约定/接口/SQL 审查结论。 |

### 8. hooks/（自动化钩子脚本）
| 脚本 | 事件 | 作用 |
| --- | --- | --- |
| `prevent_target_writes.py` | PreToolUse（Edit/Write/MultiEdit） | 解析 stdin 的 `tool_input.file_path`，命中 `target/`、`generated-sources`、`.flattened-pom.xml`、`*.class`、`.settings/`、`.claude/settings.local.json` 时输出 `permissionDecision=deny` 阻止写入；否则放行；解析失败 fail-open。已通过本地自测（deny target/ 写、放行 src 写）。 |
| `session_context.py` | SessionStart | 会话启动时向 Claude 注入项目上下文摘要（项目/版本/启动命令/已启用模块/禁库红线/资产指引）。 |

两个脚本均 `python3` 可执行（已 `chmod +x`、`py_compile` 通过）。

## 四、验证情况

- `settings.json`：`python3 -c json.load` 通过（allow 29 / deny 12 / hooks 2 事件）。
- `prevent_target_writes.py`：`py_compile` 通过；自测 deny `target/` 写、放行 `src/` 写，行为正确。
- `session_context.py`：`py_compile` 通过。
- 目录结构：`find .claude -type f` 确认 23 个文件齐全（agents 5 / skills 4 / rules 5 / commands 4 / hooks 2 / settings ×2）。
- CLAUDE.md：9891 字节，含项目概述/模块/命令/分层/编码/红线/Git/资产索引。

## 五、未执行 / 待人工确认事项

1. **需求3~10 已忽略**（ai.txt 第 20 行「忽略以下所有需求」），故未生成 `mcp.md`、`intro-*.md` 等文件。
2. **settings.json 的权限/hooks 变更**：本文件含权限放行与自动钩子，属项目级安全配置，已写入 `.claude/settings.json`（入库）。如需收紧/调整，可编辑该文件或用 `.claude/settings.local.json` 覆盖。
3. **禁库红线**：所有代理/技能/命令均不连库；建表/初始化数据只生成 `sql/` 脚本，由人工执行。
4. `.requirements/` 目录被其 `.gitignore` 忽略（仅保留 `.gitignore`），本文件与 `ai.txt` 不入库，符合需求目录定位。

## 六、如何使用

- 启动会话即自动加载 `CLAUDE.md` 与 `settings.json`，`SessionStart` 钩子注入上下文。
- 新增功能：`/yudao-new-crud system dept name:String sort:Integer status:Integer` 或调用技能 `yudao-new-crud`。
- 新增模块：`/yudao-new-module hr`。
- 启动服务：`/yudao-run local`。
- 代码审查：`/yudao-review` 或技能 `yudao-conventions-check`。
- 编辑构建产物时 `PreToolUse` 钩子自动拦截并提示。
