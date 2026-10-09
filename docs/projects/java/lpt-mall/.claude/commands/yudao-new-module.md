---
description: 脚手架新建一个 yudao 业务模块（-api/-biz 子模块、pom、分层包、framework、server 引用）。
argument-hint: "<模块名>"
---

为芋道项目新建一个业务模块。参数：$ARGUMENTS

请按 `.claude/agents/module-scaffolder.md` 与 `.claude/rules/module-structure.md` 执行：

1. 解析模块名 `{name}`（小写英文）。
2. 以 `yudao-module-member` 为模板，Glob 其结构与 pom。
3. 在根 `pom.xml` 的 `<modules>` 增加 `<module>yudao-module-{name}</module>`。
4. 创建：
   - `yudao-module-{name}/pom.xml`（packaging=pom，聚合 -api/-biz）
   - `yudao-module-{name}-api/`：pom（依赖 yudao-common）+ 包根 `cn.iocoder.yudao.module.{name}.api`（预留 {X}Api + dto/）
   - `yudao-module-{name}-biz/`：pom（依赖本模块 -api + 所需 starter + yudao-module-infra-api 等）+ 分层空包（controller/admin、controller/app、service、dal/{dataobject,mysql,redis}、convert、framework、job、mq/{consumer,message,producer}、enums/ErrorCodeConstants 占位）
   - `framework/` 内 Spring 配置类占位
5. 在 `yudao-server/pom.xml` 引入 `yudao-module-{name}-biz` 依赖。
6. 不连库；如需建库脚本放 `sql/{name}.sql` 注明人工执行。
7. 用 `mvn clean compile -pl yudao-module-{name}/yudao-module-{name}-biz -am -T 1C` 自检。
8. 输出目录树 + pom 改动行 + 验证命令。

红线：不做任何数据库操作；不编辑 target/、*.class、generated-sources/。
