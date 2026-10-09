# 规则：禁止数据库操作

> 优先级：最高（红线）。来源：`.requirements/ai/ai.txt` 第 1 行「不做任何数据库操作」。

## 规则
在本项目中，Claude **不得执行任何数据库操作**，包括但不限于：

- 不连接任何数据库（MySQL、达梦 DM、Redis、Mongo 等）。
- 不执行 DDL（`CREATE/ALTER/DROP TABLE`、`CREATE INDEX` 等）。
- 不执行 DML（`INSERT/UPDATE/DELETE`、`TRUNCATE` 等）。
- 不调用数据库客户端 CLI（`mysql`、`psql`、`disql`、`redis-cli`、`mongo` 等）。
- 不运行数据库迁移工具命令（`mvn flyway:*`、`mvn liquibase:*`）。
- 不通过应用接口进行写库操作（如调用会写库的管理接口）。

## 允许
- **生成** SQL 脚本文件（放 `sql/` 目录），交由人工执行。
- **审查** SQL 脚本内容（见 `sql-reviewer` 代理）。
- **只读** 地用 `cat`/`grep` 查看 SQL 文件。

## 如何处理「需要建表/改表」的需求
1. 生成对应的 `sql/*.sql` 脚本（建表、索引、初始化数据），文件名含模块与日期。
2. 在脚本顶部注明「由人工执行」与执行顺序。
3. 在交付说明中明确告知用户需手动执行该脚本，不自动执行。

## 关联
- `.claude/settings.json` 的 `permissions.deny` 已禁用数据库客户端命令。
- `.claude/agents/sql-reviewer.md` 只审查不执行。
