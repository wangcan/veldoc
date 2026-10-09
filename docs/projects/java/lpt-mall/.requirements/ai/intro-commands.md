# intro-commands.md — .claude/commands/ 目录分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/commands/` 目录下各文件，介绍内容与作用。
> 全程未做任何数据库操作。

## 一、目录定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/commands/`。
- **性质**：Claude Code **自定义斜杠命令（slash commands）**目录。每个 `.md` 文件对应一个 `/命令名`，含 frontmatter（`description` + `argument-hint`）+ 指令模板；`$ARGUMENTS` 占位接收用户传入参数。
- **文件数**：4 个，覆盖「生成 CRUD / 新建模块 / 启动服务 / 代码审查」四类高频操作。
- **特点**：命令是对技能/代理的快捷入口，用户输入 `/yudao-new-crud ...` 即触发对应流程，无需手动描述步骤。

## 二、各文件内容与作用

### 1. yudao-new-crud.md
- **命令**：`/yudao-new-crud <模块名> <功能名> [字段:类型 ...]`
- **参数**：`$ARGUMENTS` 解析为模块名（如 system）、功能名（如 dept）、字段清单（如 name:String, sort:Integer）。
- **内容**：7 步执行模板——解析参数；Glob/Grep 找同模块相似功能作模板；生成 DO（extends TenantBaseDO/BaseDO，@TableName/@TableId）、Mapper（extends BaseMapperX，*IfPresent）、Service+Impl（create/update/delete/get/page，唯一性校验抛 exception）、VO（SaveReqVO/PageReqVO extends PageParam/RespVO/SimpleRespVO）、Controller（@Tag/@Operation/@Parameter/@PreAuthorize，返回 CommonResult/PageResult）、ErrorCode 常量；用 BeanUtils.toBean 转换；生成 `sql/{module}_{feature}.sql`（含 tenant_id/审计字段/utf8mb4，不执行）；`mvn clean compile` 自检；输出文件清单+权限码+SQL 路径。末尾红线声明。
- **作用**：一条命令生成完整合规 CRUD，是日常加功能的主入口，对应技能 `yudao-new-crud` 与代理 `java-backend-dev`。

### 2. yudao-new-module.md
- **命令**：`/yudao-new-module <模块名>`
- **内容**：8 步——解析模块名；以 yudao-module-member 为模板 Glob；根 pom `<modules>` 加 `<module>`；创建父 pom（packaging=pom 聚合）、-api 子模块（依赖 yudao-common，预留 Api+dto）、-biz 子模块（依赖 -api+starter，建分层空包 controller/admin|app、service、dal/{dataobject,mysql,redis}、convert、framework、job、mq/{consumer,message,producer}、enums/ErrorCodeConstants 占位、framework Spring 配置）；server pom 引入 -biz；不连库，建库脚本放 sql/ 注明人工执行；`mvn clean compile` 自检；输出目录树+pom 改动+验证命令。引用 `module-scaffolder` 代理与 `module-structure` 规则。
- **作用**：一键脚手架新业务域，对应技能 `yudao-new-module` 与代理 `module-scaffolder`。

### 3. yudao-run.md
- **命令**：`/yudao-run [local|dev|test]`
- **内容**：6 步——确定 profile（默认 local）；先 `mvn clean install -T 1C -DskipTests` 安装依赖；后台 `mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles={profile}`，日志重定向 `/tmp/yudao-server-{profile}.log`；轮询日志等 `Started YudaoServerApplication` 或 48080 端口（最多 ~90s）；报告 PID/日志路径/访问地址（http://localhost:48080，Swagger /swagger-ui）；停止用 `pkill`。注意：不连库，启动失败因库未就绪则提示用户手动准备库。
- **作用**：标准化启动流程，避免 -api 未 install 导致启动失败；对应技能 `yudao-run-server`。

### 4. yudao-review.md
- **命令**：`/yudao-review [路径或分支，默认当前 diff]`
- **内容**：并行调用三个只读审查代理——`conventions-reviewer`（分层/命名/Mapper/Convert/异常/Java8）、`api-doc-reviewer`（@Tag/@Operation/@Parameter/@PreAuthorize/@Valid/返回类型）、`sql-reviewer`（SQL 表前缀/审计字段/tenant_id/字符集）。确定审查范围（空则 git diff；否则路径或分支对比 master）；仅审查 .java 与 sql/，忽略 target/等；汇总 findings 按严重度排序（跨模块直传 DO > 缺权限注解 > SQL 风险 > 手写转换 > 命名 > 风格）；输出 findings 表 + 总体结论；不修改代码。
- **作用**：一键多维度代码审查，对应技能 `yudao-conventions-check`，是 PR 前自检利器。

## 三、整体设计思路

- **命令=技能/代理的快捷入口**：4 个命令分别绑定一个技能，部分再绑定代理，形成「命令触发→技能编排→代理执行」链路。
- **参数化**：`$ARGUMENTS` + `argument-hint` 让用户一眼知道如何传参，降低使用门槛。
- **红线一致**：4 个命令均声明禁库/禁改 target，与全局规则一致。
- **自检闭环**：生成型命令（new-crud/new-module）末尾均含 `mvn clean compile` 自检步骤，确保产物可编译。

## 四、与其它资产的关联

| 命令 | 对应技能 | 对应代理 | 对应规则 |
| --- | --- | --- | --- |
| `/yudao-new-crud` | yudao-new-crud | java-backend-dev | java-conventions / api-conventions / module-structure |
| `/yudao-new-module` | yudao-new-module | module-scaffolder | module-structure |
| `/yudao-run` | yudao-run-server | — | no-db-ops |
| `/yudao-review` | yudao-conventions-check | conventions/api-doc/sql-reviewer | java-conventions / api-conventions / security-conventions / no-db-ops |
