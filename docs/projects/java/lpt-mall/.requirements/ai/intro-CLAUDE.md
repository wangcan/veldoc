# intro-CLAUDE.md — CLAUDE.md 文件分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `CLAUDE.md` 文件，介绍其内容与作用。
> 全程未做任何数据库操作。

## 一、文件位置与定位

- **路径**：`/data/java/ruoyi-vue-pro/CLAUDE.md`（仓库根）。
- **性质**：Claude Code 的**项目核心指令文件**。Claude Code 启动时自动加载仓库根的 `CLAUDE.md` 作为本项目的总纲，所有子代理（agents）、技能（skills）、规则（rules）、命令（commands）、钩子（hooks）均围绕它展开。
- **体量**：8 节，约 9.9 KB，139 行。

## 二、文件内容（逐节）

### 1. 项目概述
记录项目身份与底层技术栈，使 Claude 一开篇即具备准确上下文：
- 项目：芋道源码 ruoyi-vue-pro（`cn.iocoder.boot` / `yudao` / `revision 2.0.1-jdk8-snapshot`），2024/7/9 从上游 GitHub 拉取。
- 语言/运行时：**Java 8**，Maven 多模块。
- 核心框架：Spring Boot 2.7.18、Spring Security、MyBatis-Plus、Druid+dynamic-datasource、Redis(Redisson+Lock4j)、RocketMQ、Flowable、Spring Cloud(部分)。
- 数据库：MySQL 主（兼容达梦 DmJdbcDriver18），Druid+dynamic-datasource 多数据源，MyBatis-Plus+Join。
- 接口文档：Knife4j + SpringDoc OpenAPI 3（`@Tag`/`@Operation`/`@Parameter`）。
- 其它：EasyExcel、MapStruct、Lombok、Hutool、FastJSON、MinIO、微信 Java、阿里云/腾讯云 SMS、JustAuth、Spring Boot Admin、SkyWalking、ip2region、JimuReport、screw、Velocity、JSch。

### 2. 模块地图
用表格列出 12 个顶层模块及职责：`yudao-dependencies`(BOM)、`yudao-framework`(15 个自研 starter)、`yudao-server`(启动主项目)、9 个业务模块（system/infra/member/bpm/mp/pay/mall/erp + 默认未启用的 crm/report）。说明根 `pom.xml` 的 `<modules>` 决定参与编译的模块，`crm`/`report`/`example` 默认被注释关闭。

### 3. 常用命令
给出可直接执行的 Maven 命令：整体编译 `mvn clean compile -T 1C`、安装 `mvn clean install -T 1C -DskipTests`、单模块测试 `mvn clean test -pl <module> -am`、启动 `mvn spring-boot:run -pl yudao-server -Dspring-boot.run.profiles=local|test`、停止 `pkill -f "yudao-server"`；并指出启动主类 `YudaoServerApplication`、配置文件位置、单测/集成测试目录与 JUnit5+`yudao-spring-boot-starter-test`。

### 4. 架构与分层约定（强约束）
以 `system/dept` 为样本，画出 `*-biz` 模块完整包结构（controller/admin|app、service、dal/{dataobject,mysql,redis}、convert、framework、job、mq）与 `*-api` 子模块结构（Api/ApiImpl/dto）。列出**命名铁律**：DO/Mapper/Service(+Impl)/Controller/VO(区分 SaveReqVO/PageReqVO/ListReqVO/RespVO/SimpleRespVO)/DTO 后缀；跨模块必须走 `*-api` 禁直传 DO；Controller 返回 `CommonResult<T>`/`PageResult<T>`、入参继承 `PageParam`、`@PreAuthorize` 权限；转换优先 `BeanUtils.toBean`。

### 5. 编码约定
细化 Java 层规范：Java 8 禁用 9+ 语法（`var`/`record`/`switch 表达式`/`Stream.toList()`）；Lombok `@Data`+`@EqualsAndHashCode(callSuper=true)`；`@Resource` 注入；MyBatis-Plus `BaseMapperX`+`LambdaQueryWrapperX` 的 `*IfPresent`；DO 继承 `BaseDO`/`TenantBaseDO` 审计字段自动填充；多租户 `TenantUtils.executeIgnore`；异常 `exception(ErrorCode)`+`ErrorCodeConstants`；Jackson 时间戳；Javadoc+`@author`+中文行注释。

### 6. 强制红线（项目级规则）
5 条不可逾越的红线：① 不做任何数据库操作（只生成 SQL 交人工）；② 禁改 `target/`/`*.class`/`generated-sources/`/`.flattened-pom.xml`（由 hook 拦截）；③ 新模块须在根 pom 注册并完成 `-api`/`-biz` 拆分；④ 接口必带权限+Swagger 注解；⑤ 跨模块禁直传 DO。

### 7. Git 工作流
默认分支 `master`、开发分支 `dev-bak`；提交前 `mvn clean compile` 通过；中文提交信息 + Claude 标识；`.requirements/` 与 `.claude/settings.local.json` 被 gitignore、`.claude/settings.json` 入库。

### 8. Claude 资产索引
一张表索引全部 Claude 资产（agents 5/skills 4/rules 5/commands 4/hooks 2），便于快速定位。

## 三、所起到的作用

1. **统一上下文**：每次会话启动 Claude 即获知项目身份、版本（Java8/SpringBoot2.7.18）、模块地图，避免凭记忆误用 3.x/jakarta API。
2. **强约束分层与命名**：把芋道 `-api`/`-biz` 拆分、包结构、命名后缀、`BaseMapperX`/`BeanUtils.toBean`/`CommonResult`/`@PreAuthorize` 等约定固化为指令，生成的代码天然合规。
3. **守护红线**：把「禁库」「禁改构建产物」「跨模块禁传 DO」等安全/质量底线写入总纲，并由 rules/hooks 落地执行。
4. **资产枢纽**：作为 agents/skills/rules/commands/hooks 的索引与依据，其它资产均引用 CLAUDE.md 的章节，形成自洽体系。
5. **降低人工干预**：常用命令、启动方式、Git 规范集中给出，减少 Claude 反复询问，提升自动化执行效率。

## 四、与其他资产的关联

- 被 `.claude/agents/*.md`、`.claude/skills/*/SKILL.md`、`.claude/rules/*.md` 多处引用（如「遵循 CLAUDE.md 第 4 节」）。
- `.claude/hooks/session_context.py` 在 SessionStart 时注入的上下文摘要即取自 CLAUDE.md 的项目概述与红线。
- `.claude/settings.json` 的 deny 列表与 `env`（`YUDAO_NO_DB_OPS`）是第 6 节红线的执行层。
