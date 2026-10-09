# intro-settings.md — .claude/settings.json 文件分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/settings.json` 文件，介绍其内容与作用。
> 说明：ai.txt 原文写为 `.claude/.settings.json`（多一个点），实际文件为 `.claude/settings.json`，本文分析该实际文件。
> 全程未做任何数据库操作。

## 一、文件位置与定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/settings.json`。
- **性质**：Claude Code **项目级基础设置**，提交到 Git，团队成员共享。
- **对应关系**：与 `.claude/settings.local.json`（本地个人覆盖，已 gitignore）互补；本文件是入库的团队基线。
- **体量**：88 行，合法 JSON，含 `$schema`、`permissions`、`hooks`、`env` 四个顶层字段。

## 二、文件内容（逐字段）

### 1. `$schema`
```json
"$schema": "https://json.schemastore.org/claude-code-settings.json"
```
引用 JSON Schema，提供编辑器自动补全与字段校验。

### 2. `permissions`（权限三段式：allow / deny / ask）

**allow（29 条，免确认放行）**——聚焦只读与构建：
- Maven 构建/测试：`mvn clean compile*`、`mvn clean install*`、`mvn clean test*`、`mvn test*`、`mvn compile*`、`mvn install*`、`mvn spring-boot:run*`、`mvn dependency:tree*`、`mvn help:effective-pom*`。
- Git 只读：`git status/log/diff/branch/show/blame`。
- 文件只读：`ls/find/grep/rg/cat/head/tail/wc/tree`。
- 进程管理：`pkill -f yudao-server*`、`pkill -f spring-boot:run*`。
- 版本查询：`java -version`、`mvn -version`、`python3 --version`。

**deny（12 条，硬禁）**——落实安全与「禁库」红线：
- 危险删除：`rm -rf *`、`rm -fr *`、`sudo *`。
- **数据库客户端**：`mysql *`、`psql *`、`mongo *`、`redis-cli *`、`sqlplus *`、`disql *`（覆盖 MySQL/PG/Mongo/Redis/Oracle/达梦）。
- **数据库迁移工具**：`mvn flyway*`、`mvn liquibase*`。
- 隐私：`Read(.claude/settings.local.json)`（禁止读取他人本地配置）。

**ask（8 条，需确认）**——外发/改写类操作：
- Git 写操作：`git push/commit/merge/rebase/reset/checkout`。
- Maven 发布：`mvn deploy*`、`mvn release*`。

### 3. `hooks`（两个事件）

- **PreToolUse**（matcher: `Edit|Write|MultiEdit`）：调用 `python3 .claude/hooks/prevent_target_writes.py`，在每次文件写入前拦截 `target/`、`generated-sources`、`.flattened-pom.xml`、`*.class`、`.settings/`、`settings.local.json`。
- **SessionStart**：调用 `python3 .claude/hooks/session_context.py`，会话启动时注入项目上下文摘要。

### 4. `env`（环境变量）
```json
"JAVA_PROJECT_VERSION": "2.0.1-jdk8-snapshot",
"YUDAO_JAVA_VERSION": "1.8",
"YUDAO_NO_DB_OPS": "true"
```
向 Claude 进程注入项目版本、Java 版本与「禁库」标志，供运行时读取。

## 三、所起到的作用

1. **减少权限打断**：把日常高频的只读/构建命令放入 `allow`，Claude 执行 `mvn compile`、`git diff`、`grep` 等无需逐次确认，提升自动化效率。
2. **硬性守住安全与禁库红线**：`deny` 直接阻断 `rm -rf`、`sudo`、所有数据库客户端 CLI 与迁移工具，与 `CLAUDE.md` 第 6 节、`.claude/rules/no-db-ops.md` 形成「指令+规则+执行」三层防护，确保 ai.txt 第 1 行「不做任何数据库操作」在工具层不可逾越。
3. **保护敏感操作**：`ask` 让 `git push/commit`、`mvn deploy` 等外发/改写操作必须人工确认，防止误推送或误发布。
4. **自动化拦截构建产物误改**：PreToolUse 钩子把「禁改 target/生成代码」从文字约定变为自动拦截，避免污染构建产物。
5. **会话上下文自动注入**：SessionStart 钩子让每次新会话无需人工说明即获知项目身份与红线。
6. **环境信号**：`env` 让 Claude 在决策时感知 Java 版本与禁库标志，避免生成 9+ 语法或涉库方案。

## 四、与其它资产的关联

- `deny` 列表与 `.claude/rules/no-db-ops.md`、`CLAUDE.md` 第 6 节红线一一对应。
- `hooks` 引用的两个脚本位于 `.claude/hooks/`（见 `intro-hooks.md`）。
- `settings.local.json`（本地个人覆盖）与本文件叠加生效，前者不入库；`.gitignore` 已忽略之。
- `env` 的 `YUDAO_NO_DB_OPS` 被 rules/agents/skills 引用为禁库依据。
