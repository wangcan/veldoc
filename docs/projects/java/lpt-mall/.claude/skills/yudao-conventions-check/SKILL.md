---
name: yudao-conventions-check
description: 按芋道约定审查当前 diff 或指定路径的 Java/SQL 代码（分层/命名/Mapper/Convert/权限注解/Java8/SQL 规范/安全），只读不改。当用户要求「检查代码规范」「审查一下我的改动」「看看是否符合芋道约定」时触发。
---

# 技能：芋道约定审查（只读）

## 触发场景
- 「检查这次改动是否符合规范」
- 「审查一下我的代码」
- 「看看 yudao 约定有没有违规」

## 输入
- 目标：路径、分支或空（空=当前 `git diff` + 已暂存）

## 执行步骤
1. **确定范围**：
   - 空：`git diff --name-only` + `git diff --cached --name-only`。
   - 路径：该路径下 `.java`/`sql` 文件。
   - 分支：`git diff --name-only master...{branch}`。
2. **过滤**：仅 `.java` 与 `sql/` 下文件；排除 `target/`、`*.class`、`generated-sources/`、`.flattened-pom.xml`。
3. **并行审查**（用子代理或直接 Read+Grep）：
   - 约定审查（`conventions-reviewer` 清单）：分层/命名/Mapper/Convert/异常/Java8/跨模块直传 DO。
   - 接口审查（`api-doc-reviewer` 清单）：@Tag/@Operation/@Parameter/@PreAuthorize/@Valid/返回类型/路径动词。
   - SQL 审查（`sql-reviewer` 清单）：表前缀/tenant_id/审计字段/utf8mb4/索引/幂等。
4. **汇总**：findings 按 `file:line` + 问题 + 修复建议；按严重度排序：
   跨模块直传 DO > 缺权限注解 > SQL 风险 > 手写转换 > 命名错误 > 风格。
5. **输出**：findings 表 + 总体结论（通过 / 需返工 N 处）。**不改代码**。

## 约束
- 只读：不修改任何文件，不执行 SQL，不连库。
- 不编辑 `target/`、`*.class`、`generated-sources/`。

## 关联
- 代理：`conventions-reviewer.md`、`api-doc-reviewer.md`、`sql-reviewer.md`。
- 命令：`/yudao-review`。
- 规则：`java-conventions.md`、`api-conventions.md`、`security-conventions.md`、`no-db-ops.md`。
