---
description: 按芋道约定审查当前 diff 或指定路径（分层/命名/转换/权限注解/Java8/安全）。
argument-hint: "[路径或分支，默认当前 diff]"
---

审查代码是否符合芋道约定。目标：$ARGUMENTS（为空则审查当前 `git diff`）。

并行调用以下只读审查代理，汇总结论：
1. `.claude/agents/conventions-reviewer.md`：分层/命名/Mapper/Convert/异常/Java8。
2. `.claude/agents/api-doc-reviewer.md`：Controller 的 @Tag/@Operation/@Parameter/@PreAuthorize/@Valid 与返回类型。
3. `.claude/agents/sql-reviewer.md`：diff 中涉及的 SQL 脚本（表前缀/审计字段/tenant_id/字符集）。

步骤：
1. 确定审查范围：若 $ARGUMENTS 为空，`git diff --name-only` + `git diff --cached --name-only` 取变更文件；否则用给定路径/分支对比 `master`。
2. 仅审查 `.java` 与 `sql/` 文件，忽略 `target/`、`*.class`、`generated-sources/`。
3. 各代理给出 findings（file:line + 问题 + 修复建议）。
4. 汇总按严重度排序：跨模块直传 DO / 缺权限注解 / SQL 风险 / 手写转换 / 命名错误 / 风格。
5. 输出：findings 表 + 一句话总体结论（通过 / 需返工 N 处）。
6. **不修改代码**；如用户随后要修复，再单独授权。

红线：不做数据库操作；审查 SQL 时只读不执行。
