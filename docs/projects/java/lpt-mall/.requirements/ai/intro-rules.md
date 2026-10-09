# intro-rules.md — .claude/rules/ 目录分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/rules/` 目录下各文件，介绍内容与作用。
> 全程未做任何数据库操作。

## 一、目录定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/rules/`。
- **性质**：Claude Code **规则文件（rules）**目录。每个 `.md` 是一条独立、可被 Claude 引用的项目规则，把 CLAUDE.md 中的约定细化为可执行清单。
- **文件数**：5 个，覆盖「禁库 / 模块结构 / Java 编码 / 接口约定 / 安全」五个维度。
- **特点**：规则是「单一来源」的细化层——CLAUDE.md 给总纲，rules 给细则，agents/skills 引用 rules 执行。

## 二、各文件内容与作用

### 1. no-db-ops.md（禁止数据库操作）— 最高优先级红线
- **来源**：ai.txt 第 1 行「不做任何数据库操作」。
- **内容**：
  - **规则**：不连任何数据库（MySQL/达梦/Redis/Mongo）；不执行 DDL（CREATE/ALTER/DROP）；不执行 DML（INSERT/UPDATE/DELETE/TRUNCATE）；不调数据库客户端 CLI（mysql/psql/disql/redis-cli/mongo）；不跑迁移工具（mvn flyway/liquibase）；不通过应用接口写库。
  - **允许**：生成 SQL 脚本（放 sql/）交人工执行；审查 SQL 内容；只读 cat/grep 查看 SQL 文件。
  - **处理「需建表/改表」**：生成 `sql/*.sql`（含模块与日期）、顶部注明人工执行与顺序、交付说明明确告知。
- **作用**：把 ai.txt 顶层约束固化为项目规则，是所有代理/技能/命令的不可逾越底线。关联 settings.json deny 列表与 sql-reviewer 代理落地。

### 2. module-structure.md（业务模块结构与分层）
- **内容**：
  - **子模块拆分**：每模块拆 `-api`（对外接口+DTO，禁放 DO/Service 实现）与 `-biz`（业务实现，依赖 -api+starter）。
  - **-biz 包结构**（强约束）：`controller/{admin,app}/{feature}`、`service/{feature}`、`dal/{dataobject,mysql,redis}/{feature}`、`convert/{feature}`、`framework`、`job/{feature}`、`mq/{consumer,message,producer}`、`enums`。
  - **-api 包结构**：`api/{feature}/{X}Api`+`{X}ApiImpl`+`dto/`。
  - **模块注册**：根 pom `<modules>` 加 `<module>`；server pom 引入 -biz；crm/report/example 默认注释。
  - **命名一致性**：模块目录/`<module>`/包根 `module.{name}`/表前缀 `{name}_` 一致。
- **作用**：为新模块脚手架（module-scaffolder 代理、yudao-new-module 技能）提供结构蓝图，保证 11 个模块风格统一、跨模块依赖走 -api。

### 3. java-conventions.md（Java 编码约定）
- **内容**：Java 8 语法限制（禁 var/record/switch 表达式/Stream.toList() 等，用 Collectors.toList()+Hutool）；Lombok（@Data+@EqualsAndHashCode(callSuper=true)、@Slf4j）；`@Resource` 注入；MyBatis-Plus（BaseMapperX+@Mapper、LambdaQueryWrapperX 的 *IfPresent、@TableName/@TableId/@KeySequence、TenantBaseDO/BaseDO、禁手写 XML 除非联表）；对象转换（BeanUtils.toBean 优先、MapStruct 次之、禁手写 setXxx）；Controller（@Tag/@Operation/@Parameter、CommonResult/PageResult/PageParam、@PreAuthorize、admin/app 分离）；异常（exception(ErrorCode)+ErrorCodeConstants）；多租户（TenantUtils.executeIgnore）；注释（Javadoc+@author+中文行注释）。
- **作用**：Java 代码风格统一基准，被 conventions-reviewer 代理逐项核对、java-backend-dev 代理遵循，避免 Java9+ 语法与手写转换等常见违规。

### 4. api-conventions.md（REST 接口约定）
- **内容**：
  - **路径**：`@RequestMapping("/{module}/{feature}")`，admin/app 分离，`/admin-api`/`/app-api` 前缀由 starter-web 统一加。
  - **动词与 HTTP 方法映射表**：create→POST（SaveReqVO→Long）、update→PUT（→Boolean）、delete→DELETE（id→Boolean）、get→GET（id→RespVO）、page→GET（PageReqVO→PageResult）、list→GET（ListReqVO→List<SimpleRespVO>）、export→GET（写 Response）。
  - **必须注解**：类级 @Tag/@RestController/@Validated；方法级 @Operation/@Parameter/@Valid @RequestBody/@PreAuthorize（action∈create|update|delete|query|export）。
  - **返回**：CommonResult/PageResult，精简列表用 SimpleRespVO。
  - **导出**：EasyExcel `ExcelUtils.write`。
- **作用**：REST 接口标准化，被 api-doc-reviewer 代理核对，确保 Knife4j 文档完整、权限校验不缺失、动词语义统一。

### 5. security-conventions.md（安全约定）
- **内容**：
  - **权限**：所有后台接口必 @PreAuthorize；App 端用 @PreAuthorize(@ss.hasScope) 或登录态；权限码配套菜单/按钮 SQL 交人工执行。
  - **敏感数据**：密码 BCrypt 不记明文；手机号/身份证/银行卡用 protection starter 的 @Desensitize 脱敏；日志不记 token/密码/密钥。
  - **密钥与配置**：不硬编码，放 application-{profile}.yaml 经环境变量/配置中心注入；application-my.yaml 已 gitignore；提交前 grep 复核密钥。
  - **SQL 注入**：一律 LambdaQueryWrapperX 参数化，禁字符串拼接；XML 用 #{} 不用 ${}（排序字段白名单除外）。
  - **文件上传**：走 infra 文件服务（MinIO/本地/七牛），校验类型/大小（16MB）。
  - **跨模块**：走 -api 的 Api，DTO 字段最小化。
  - **红线**：禁库、禁反射绕过权限。
- **作用**：安全基线，覆盖权限/脱敏/密钥/注入/上传/跨模块，与 no-db-ops 互为补充，是 security-review 的依据。

## 三、整体设计思路

- **维度正交**：5 条规则各管一域（库/结构/Java/接口/安全），无重叠，组合即完整质量基线。
- **细化 CLAUDE.md**：CLAUDE.md 第 4-6 节给总纲，rules 给可逐项核对的清单，便于代理审查。
- **关联落地**：每条规则末尾标注关联的代理/技能/钩子/settings，形成「规则→执行→拦截」闭环。
- **红线分层**：no-db-ops 为最高优先级，其余为质量约定；红线由 settings.json deny + hooks 强制，约定由审查代理软约束。

## 四、与其它资产的关联

| 规则 | 关联代理 | 关联技能/命令 | 关联执行层 |
| --- | --- | --- | --- |
| no-db-ops | sql-reviewer | yudao-run-server / /yudao-run | settings.json deny、env YUDAO_NO_DB_OPS |
| module-structure | module-scaffolder | yudao-new-module / /yudao-new-module | — |
| java-conventions | conventions-reviewer、java-backend-dev | yudao-new-crud / /yudao-review | — |
| api-conventions | api-doc-reviewer | yudao-new-crud / /yudao-review | — |
| security-conventions | conventions-reviewer、api-doc-reviewer | /yudao-review | settings.json deny、CLAUDE.md 第 6 节 |
