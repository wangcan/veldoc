# intro-skills.md — .claude/skills/ 目录分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/skills/` 目录下各文件，介绍内容与作用。
> 全程未做任何数据库操作。

## 一、目录定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/skills/`。
- **性质**：Claude Code **自定义技能（skills）**目录。每个技能一个子目录，内含 `SKILL.md`（frontmatter 的 `name`+`description` + 指令正文）。技能是「可复用、按场景触发」的能力包，描述中声明触发条件，Claude 识别到匹配场景时自动加载。
- **文件数**：4 个技能（各一个 `SKILL.md`），与 4 个斜杠命令一一对应，分别封装「生成 CRUD / 新建模块 / 启动服务 / 约定审查」四类流程。
- **与命令/代理的关系**：技能是流程编排层（步骤+约束+关联），命令是触发入口（`/xxx`），代理是执行单元（写代码/审查）；三者协同。

## 二、各技能内容与作用

### 1. yudao-new-crud — 生成完整 CRUD 功能
- **路径**：`.claude/skills/yudao-new-crud/SKILL.md`。
- **触发场景**：「在 system 模块加一个岗位的增删改查」「给 mall 加商品分类 CRUD」「生成 xxx 管理（含分页、导出）」。
- **输入**：模块名 module、功能名 feature+实体名 X、字段清单（字段名:Java类型）。
- **执行步骤**：6 步——① Glob 定位同模块相似功能作模板；② 生成 DO（@TableName/@TableId/@Data+@EqualsAndHashCode、TenantBaseDO|BaseDO）、Mapper（BaseMapperX+*IfPresent+selectByXxx）、Service+Impl（@Resource、create/update/delete/get/page、唯一性校验抛 exception）、VO（SaveReqVO/PageReqVO extends PageParam/RespVO/SimpleRespVO + JSR303）、Controller（@Tag/@Operation/@Parameter/@PreAuthorize、CommonResult/PageResult）、ErrorCode 常量；③ BeanUtils.toBean 转换；④ 生成 `sql/{module}_{feature}.sql`（含 tenant_id/审计字段/utf8mb4/索引，不执行）；⑤ `mvn clean compile` 自检；⑥ 输出文件清单+权限码+SQL 路径+菜单提示。
- **约束**：Java8、@Resource、*IfPresent、禁手写转换、禁直传 DO、禁库/禁改 target。
- **作用**：日常加功能的核心能力包，一次产出全层合规代码并自检编译。对应命令 `/yudao-new-crud`、代理 `java-backend-dev`。

### 2. yudao-new-module — 新建业务模块
- **路径**：`.claude/skills/yudao-new-module/SKILL.md`。
- **触发场景**：「新建一个 hr 模块」「加一个 yudao-module-cms 业务域」「创建 yudao-module-warehouse」。
- **输入**：模块名 {name}（小写英文）。
- **执行步骤**：9 步——① Glob yudao-module-member 作模板；② 根 pom 加 `<module>`；③ 父 pom（packaging=pom 聚合）；④ -api 子模块（pom 依赖 yudao-common + 包根预留 Api+dto）；⑤ -biz 子模块（pom 依赖 -api+starter + 分层包 controller/{admin,app}/service/dal/{dataobject,mysql,redis}/convert/framework/job/mq/{consumer,message,producer}/enums/ErrorCodeConstants + framework Spring 配置）；⑥ server pom 引入 -biz；⑦ 配置占位（不连库）；⑧ `mvn clean compile`（或 install）自检；⑨ 输出目录树+pom 改动+验证命令+后续加功能指引。
- **约束**：模块名/包名/`<module>`/表前缀一致；-api 只放接口+DTO；禁库/禁改 target。
- **作用**：新业务域脚手架，保证结构与注册正确。对应命令 `/yudao-new-module`、代理 `module-scaffolder`、规则 `module-structure`。

### 3. yudao-run-server — 启动 yudao-server
- **路径**：`.claude/skills/yudao-run-server/SKILL.md`。
- **触发场景**：「启动服务」「把项目跑起来」「启动 yudao，用 local/dev/test profile」「本地启动一下看效果」。
- **输入**：profile（可选，默认 local）。
- **执行步骤**：6 步——① 确定 profile；② `mvn clean install -T 1C -DskipTests`（后台，日志 /tmp/yudao-build.log）；③ 后台 `mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles={profile}`（日志 /tmp/yudao-server-{profile}.log）；④ 每 ~10s 读日志尾部等 `Started YudaoServerApplication` 或 48080 端口（最多 ~120s）；⑤ 报告 PID/日志路径/访问地址（http://localhost:48080、Swagger /swagger-ui、Knife4j /doc.html）；⑥ 停止用 pkill。
- **失败处理**：库未就绪则提示用户手动准备 MySQL 与执行 sql/ 脚本（不自动连库）；端口占用则 pkill 重试。
- **作用**：标准化启动流程，避免 -api 未 install 致启动失败；守护禁库红线。对应命令 `/yudao-run`、规则 `no-db-ops`。

### 4. yudao-conventions-check — 芋道约定审查（只读）
- **路径**：`.claude/skills/yudao-conventions-check/SKILL.md`。
- **触发场景**：「检查这次改动是否符合规范」「审查一下我的代码」「看看 yudao 约定有没有违规」。
- **输入**：目标（路径/分支/空，空=当前 git diff+已暂存）。
- **执行步骤**：5 步——① 确定范围（空用 git diff；路径取 .java/sql；分支对比 master）；② 过滤（仅 .java 与 sql/，排除 target/等）；③ 并行审查（conventions-reviewer 清单：分层/命名/Mapper/Convert/异常/Java8/跨模块直传 DO；api-doc-reviewer 清单：@Tag/@Operation/@Parameter/@PreAuthorize/@Valid/返回/动词；sql-reviewer 清单：表前缀/tenant_id/审计字段/utf8mb4/索引/幂等）；④ 汇总 findings 按严重度排序（跨模块直传 DO > 缺权限注解 > SQL 风险 > 手写转换 > 命名 > 风格）；⑤ 输出 findings 表+总体结论，不改代码。
- **约束**：只读，不改文件、不执行 SQL、不连库。
- **作用**：PR 前多维度自检，一次覆盖约定/接口/SQL 三类审查。对应命令 `/yudao-review`、三个审查代理、四条规则。

## 三、整体设计思路

- **技能=流程编排**：每个技能把「定位模板→生成/执行→自检→输出」固化为可复用步骤，比命令更详细（技能含完整步骤，命令是简短触发器）。
- **触发词驱动**：description 中声明自然语言触发场景，Claude 识别用户意图后自动加载，无需用户记命令。
- **生成与审查分离**：yudao-new-crud/yudao-new-module 为生成型（有写权限的代理执行），yudao-conventions-check 为只读型；yudao-run-server 为运维型。
- **红线一致**：4 个技能均声明禁库/禁改 target，与全局规则一致。
- **自检闭环**：生成型技能末尾含 `mvn clean compile` 自检，确保产物可编译。

## 四、与其它资产的关联

| 技能 | 对应命令 | 对应代理 | 对应规则 |
| --- | --- | --- | --- |
| yudao-new-crud | /yudao-new-crud | java-backend-dev | java-conventions / api-conventions / module-structure |
| yudao-new-module | /yudao-new-module | module-scaffolder | module-structure |
| yudao-run-server | /yudao-run | — | no-db-ops |
| yudao-conventions-check | /yudao-review | conventions/api-doc/sql-reviewer | java-conventions / api-conventions / security-conventions / no-db-ops |

技能 frontmatter 引用 `.claude/agents/*.md`、`.claude/rules/*.md`、`.claude/commands/*.md`，形成完整的「触发→编排→执行→约束」链路。
