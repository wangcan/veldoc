# intro-hooks.md — .claude/hooks/ 目录分析

> 需求 `.requirements/ai/ai.txt` 需求3 之一：分析 `.claude/hooks/` 目录下各文件，介绍内容与作用。
> 全程未做任何数据库操作。

## 一、目录定位

- **路径**：`/data/java/ruoyi-vue-pro/.claude/hooks/`。
- **性质**：Claude Code **自动化钩子（hooks）脚本**目录。脚本由 `.claude/settings.json` 的 `hooks` 字段在特定事件触发时自动执行，无需人工或 Claude 主动调用。
- **文件数**：2 个 Python 脚本（`prevent_target_writes.py`、`session_context.py`），均已 `chmod +x`、`py_compile` 通过、自测验证。
- **运行时**：Python 3（环境为 Python 3.11.6）。

## 二、各文件内容与作用

### 1. prevent_target_writes.py — PreToolUse 写入拦截钩子
- **触发事件**：`PreToolUse`，matcher 为 `Edit|Write|MultiEdit`（即每次文件写入前）。
- **触发配置**（settings.json）：
  ```json
  "PreToolUse": [{ "matcher": "Edit|Write|MultiEdit",
    "hooks": [{ "type": "command", "command": "python3 .claude/hooks/prevent_target_writes.py" }] }]
  ```
- **输入**：stdin 收到 JSON，含 `tool_input.file_path`（或 `path`）。
- **逻辑**：
  1. 解析 stdin JSON 取目标路径（`_norm` 归一化）。
  2. `is_forbidden(path)` 逐条匹配 6 类红线路径：
     - `target/`（Maven 构建产物）
     - `generated-sources` / `generated-test-sources`（注解处理器生成代码）
     - `.flattened-pom.xml`（flatten-maven-plugin 产物）
     - `*.class`（编译字节码）
     - `.settings/`（Eclipse IDE 元数据）
     - `.claude/settings.local.json`（本地个人配置）
  3. 命中则打印 deny 决策 JSON（`hookSpecificOutput.permissionDecision=deny` + 中文原因），阻止写入；未命中静默放行；JSON 解析失败 fail-open（return 0 不阻断）。
- **自测结果**：对 `.../target/x.txt` 输出 deny；对 `.../src/main/java/X.java` 静默放行，行为正确。
- **作用**：把「禁改构建产物/生成代码/本地配置」从文字约定（CLAUDE.md 第 6 节红线②）变为**自动拦截**，避免 Claude 误编辑 `target/`、`*.class` 等导致构建污染或配置覆盖。是质量与安全的执行层。

### 2. session_context.py — SessionStart 上下文注入钩子
- **触发事件**：`SessionStart`（每次会话启动）。
- **触发配置**（settings.json）：
  ```json
  "SessionStart": [{ "hooks": [{ "type": "command", "command": "python3 .claude/hooks/session_context.py" }] }]
  ```
- **输入**：stdin JSON（含 `cwd`、`source`）。
- **逻辑**：
  1. 解析 stdin 取 cwd/source（失败用默认值）。
  2. 扫描仓库根的 `yudao-module-*` 目录，统计已启用业务模块列表。
  3. 向 stdout 输出项目上下文摘要：项目身份（yudao/Java8/SpringBoot2.7.18/Maven 多模块）、启动命令与端口 48080、已启用业务模块清单、核心红线（禁库/禁改构建产物）、资产指引（CLAUDE.md 与 .claude/rules/skills/commands）。
- **作用**：每次新会话**自动注入项目上下文**，Claude 无需人工说明即获知项目身份、模块地图、红线，减少冷启动摸索，确保从第一条消息起就遵循项目约定。stdout 内容直接作为上下文展示给 Claude。

## 三、整体设计思路

- **一守一送**：`prevent_target_writes.py` 是「守门员」（拦截违规写入），`session_context.py` 是「迎宾员」（注入上下文）；一个 Pre 一个 Start，覆盖会话关键节点。
- **与 CLAUDE.md/rules 一致**：钩子的红线判定与 CLAUDE.md 第 6 节、`no-db-ops.md`、settings.json deny 完全对齐，单一来源、多层执行。
- **fail-open 容错**：JSON 解析失败时不阻断正常工作，避免钩子自身故障卡死 Claude。
- **零依赖纯 Python**：仅用标准库 `json/os/sys`，无需安装第三方包，跨环境可靠运行。

## 四、与其它资产的关联

- **settings.json**：`hooks` 字段声明两个脚本的触发事件与 matcher，是脚本的注册入口（见 `intro-settings.md`）。
- **CLAUDE.md**：第 6 节红线②明确「由 `hooks/prevent_target_writes.py` 自动拦截」；第 8 节资产索引列出两个钩子。
- **rules/no-db-ops.md**：禁库红线靠 settings.json deny 落地，本目录钩子负责「禁改构建产物」红线。
- 钩子不直接调用 agents/skills/commands，但为其提供安全运行环境（确保代理产出不污染 target/）。
