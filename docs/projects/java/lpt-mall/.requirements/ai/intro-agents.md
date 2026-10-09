# intro-agents.md — .claude/agents/ 目录分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/agents/` 目录下各文件，介绍内容与作用。
> 全程未做任何数据库操作。

## 一、目录定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/agents/`。
- **性质**：Claude Code **自定义子代理（subagents）**目录。每个 `.md` 文件定义一个可被主 Claude 委派的专职代理，含 frontmatter（name/description/tools/model）+ 指令正文。
- **文件数**：5 个，分为「生成型」2 个（写代码）与「审查型」3 个（只读）。
- **共同 frontmatter**：`model: inherit`（继承父会话模型）；生成型 `tools` 含 `Edit,Write`，审查型仅 `Read,Glob,Grep,Bash`（只读）。

## 二、各文件内容与作用

### 1. java-backend-dev.md（Java 后端开发代理）— 生成型
- **name**：`java-backend-dev`。
- **职责**：在某个 `yudao-module-*` 模块内编写 Controller/Service/ServiceImpl/DO/Mapper/VO/Convert/Api/ApiImpl/DTO。
- **内容要点**：10 条必须遵守的约定——包结构按 CLAUDE.md 第 4 节分层；命名后缀铁律；`@Resource` 注入 + Lombok；DO 的 `@TableName`/`@TableId`/`@KeySequence`/`TenantBaseDO`；Mapper `extends BaseMapperX` + `LambdaQueryWrapperX` 的 `*IfPresent`；转换用 `BeanUtils.toBean`；Controller 的 `@Tag`/`@Operation`/`@Parameter`/`@PreAuthorize` + `CommonResult`/`PageResult`；异常 `exception(ErrorCode)`；Java 8 限制；红线（禁库/禁改 target）。
- **工作方式**：先 Glob/Grep 找同模块相似功能作参照，多文件一次产出，产出后 `mvn clean compile` 自检。
- **作用**：把芋道后端约定固化为代理行为，委派给它写 CRUD 代码天然合规，减少返工。

### 2. module-scaffolder.md（业务模块脚手架代理）— 生成型
- **name**：`module-scaffolder`。
- **职责**：按芋道规范创建一整个新业务模块 `yudao-module-{name}`。
- **内容要点**：7 步流程——参照 member/system 模板；根 pom 注册 `<module>`；父 pom（packaging=pom 聚合）；`-api` 子模块（依赖 yudao-common，预留 Api+dto）；`-biz` 子模块（依赖 -api+starter，建分层空包 controller/admin|app、service、dal/{dataobject,mysql,redis}、convert、framework、job、mq/{consumer,message,producer}、enums/ErrorCodeConstants）；server pom 引用 -biz；配置占位。约定模块名/包名/`<module>`/表前缀一致，-api 禁放 DO/Service 实现。
- **作用**：新业务域一键脚手架，保证模块结构与注册正确，避免遗漏 pom 注册或分层包。

### 3. conventions-reviewer.md（芋道约定审查代理）— 只读
- **name**：`conventions-reviewer`。
- **职责**：审查 Java 代码是否符合芋道分层/命名/转换/异常约定，**只读不改**。
- **内容要点**：11 项审查清单——分层包路径、命名后缀（DO/VO/DTO/Mapper/Service/ServiceImpl/Controller/Api/ApiImpl 及 VO 五分类）、DO 注解与基类、Mapper 的 BaseMapperX+*IfPresent、对象转换（禁手写 setXxx）、Controller 注解与返回类型、异常、`@Resource` 注入、跨模块禁直传 DO、Java 8 语法、红线。按严重度排序 findings。
- **作用**：代码质量守门，发现违规给出 file:line + 修复建议，是 `/yudao-review` 命令的核心组成。

### 4. api-doc-reviewer.md（接口文档与权限审查代理）— 只读
- **name**：`api-doc-reviewer`。
- **职责**：审查 REST Controller 的接口文档注解与权限注解完整性，**只读**。
- **内容要点**：6 项审查——类级 `@Tag`/`@RestController`/`@RequestMapping`/`@Validated`；方法级 `@Operation`/路径动词与 HTTP 方法映射（create→POST 等）/`@Parameter`/`@Valid @RequestBody`；`@PreAuthorize` 权限码语义一致；返回 `CommonResult`/`PageResult`；admin/app 分离与前缀规则；Knife4j 配置可见性。
- **作用**：确保接口文档可被 Knife4j 正确展示、权限校验不缺失，是接口质量专项守门。

### 5. sql-reviewer.md（SQL 脚本审查代理）— 只读，绝不执行
- **name**：`sql-reviewer`。
- **职责**：审查 `sql/` 目录或变更中的 SQL 脚本是否符合芋道规范，**只读审查，绝不执行 SQL、绝不连库**。
- **内容要点**：10 项审查——表前缀与模块一致、主键 BIGINT+序列、`tenant_id`、审计字段（creator/create_time/updater/update_time/deleted，与 BaseDO 对应）、utf8mb4+InnoDB、字段类型规范、索引、禁物理外键、破坏性语句警告（DROP DATABASE/TRUNCATE）、DDL/DML 分离、幂等。红线：不执行 SQL/不连库/不调客户端 CLI。
- **作用**：在「禁库」前提下仍能把控 SQL 质量，高亮破坏性语句，生成可交人工执行的合规脚本。

## 三、整体设计思路

- **生成与审查分离**：生成型代理（java-backend-dev、module-scaffolder）有写权限；审查型代理（conventions/api-doc/sql-reviewer）仅只读工具，避免审查时误改代码。
- **围绕 CLAUDE.md**：所有代理引用 CLAUDE.md 章节（如第 4 节分层）与 `.claude/rules/`，约定单一来源、不重复定义。
- **红线贯穿**：5 个代理均显式声明禁库/禁改构建产物，与 settings.json deny、hooks 拦截形成多层一致。
- **可组合**：审查型代理可被 `/yudao-review` 命令并行调用，汇总多维度结论。

## 四、与其它资产的关联

- 生成型代理对应技能：`yudao-new-crud`（→java-backend-dev）、`yudao-new-module`（→module-scaffolder）。
- 审查型代理对应命令：`/yudao-review`（并行调三个审查代理）与技能 `yudao-conventions-check`。
- 规则文件为其提供细则：`java-conventions.md`/`api-conventions.md`/`module-structure.md`/`no-db-ops.md`/`security-conventions.md`。
