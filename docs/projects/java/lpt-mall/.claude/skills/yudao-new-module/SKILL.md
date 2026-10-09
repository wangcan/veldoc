---
name: yudao-new-module
description: 脚手架新建一个 yudao 业务模块（yudao-module-{name} 的 -api/-biz 子模块、pom、分层包、framework 配置、根 pom 与 server pom 注册），并编译自检。当用户要求「新建一个模块」「加一个 xx 业务域」「创建 yudao-module-xxx」时触发。
---

# 技能：新建业务模块

## 触发场景
- 「新建一个 hr 模块」
- 「加一个 yudao-module-cms 业务域」
- 「创建 yudao-module-warehouse」

## 输入
- 模块名 `{name}`（小写英文，如 `hr`）

## 执行步骤
1. **参照模板**：Glob `yudao-module-member`（最精简）与 `yudao-module-member/yudao-module-member-biz/pom.xml`、`framework/` 包结构。
2. **根 pom**：`/data/java/ruoyi-vue-pro/pom.xml` 的 `<modules>` 增加 `<module>yudao-module-{name}</module>`（不加注释）。
3. **父 pom**：`yudao-module-{name}/pom.xml`，`<packaging>pom</packaging>`，聚合 `-api`/`-biz`，`<parent>` 指向根。
4. **-api 子模块**：
   - `yudao-module-{name}-api/pom.xml`：依赖 `yudao-common`。
   - 包根 `cn.iocoder.yudao.module.{name}.api`，预留 `{X}Api.java` 接口 + `dto/`。
5. **-biz 子模块**：
   - `yudao-module-{name}-biz/pom.xml`：依赖本模块 `-api`、`yudao-spring-boot-starter-web/security/mybatis/redis` 等、`yudao-module-infra-api`（按需）。
   - 包根 `cn.iocoder.yudao.module.{name}`，建分层包：`controller/{admin,app}`、`service`、`dal/{dataobject,mysql,redis}`、`convert`、`framework`、`job`、`mq/{consumer,message,producer}`、`enums/ErrorCodeConstants.java`（占位）。
   - `framework/` 内建 Spring 配置类（参照 member）。
6. **server 引用**：`yudao-server/pom.xml` 增加 `yudao-module-{name}-biz` 依赖。
7. **配置**：如需独立配置项，在 `yudao-server/src/main/resources/application.yaml` 增占位（不连库）。
8. **自检**：`mvn clean compile -pl yudao-module-{name}/yudao-module-{name}-biz -am -T 1C`；如 `-api` 被其它模块依赖则先 `mvn clean install -T 1C -DskipTests`。
9. **输出**：目录树 + pom 改动行 + 验证命令 + 后续如何用 `yudao-new-crud` 加功能。

## 约束
- 模块名与包名、`<module>`、表前缀 `{name}_` 一致。
- `-api` 只放接口与 DTO；`-biz` 放实现。
- 红线：不做数据库操作；不编辑 `target/`、`*.class`、`generated-sources/`。

## 关联
- 规则：`.claude/rules/module-structure.md`。
- 代理：`.claude/agents/module-scaffolder.md`。
- 命令：`/yudao-new-module`。
