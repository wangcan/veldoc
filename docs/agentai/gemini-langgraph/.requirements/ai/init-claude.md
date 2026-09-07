# init-claude.md — Claude 配置初始化结果

> 本文件记录需求1的执行结果：基于当前项目（`gemini-fullstack-langgraph-quickstart`）的技术栈，按指定目录结构完善 `.claude/` 相关设置，生成 agents / skills / rules / commands / hooks 等文件。
>
> **关于 ai.txt 中其它需求的说明**：`ai.txt` 在需求1之后、需求4之前写有「忽略以下所有需求」，因此需求2–10 均按要求忽略，本任务只执行需求1。

---

## 0. 项目技术栈速览（配置据此量身定制）

| 层 | 技术栈 |
|---|---|
| 后端 | Python 3.11+ · LangGraph `StateGraph` · LangChain 0.3 · `langchain-google-genai` + `google-genai` · FastAPI · Pydantic · ruff(google pydocstyle)/mypy/pytest |
| 模型 | `gemini-2.0-flash`(查询/检索) · `gemini-2.5-flash`(反思) · `gemini-2.5-pro`(作答) |
| 前端 | React 19 · Vite 6(SWC) · Tailwind 4(`@tailwindcss/vite`) · shadcn/ui(new-york/neutral) · Radix · `@langchain/langgraph-sdk` · ESLint 9 · TS 5.7 |
| 基础设施 | Dockerfile(多阶段) · docker-compose(Redis + Postgres + LangGraph 平台) · Makefile |
| Agent 图 | `generate_query → web_research(并行扇出) → reflection → evaluate_research → {web_research | finalize_answer} → END` |
| 密钥 | `GEMINI_API_KEY`(Gemini) · `LANGSMITH_API_KEY`(平台部署) |

---

## 1. 生成的目录结构

```
.claude/
├── settings.json              # 项目基础设置（提交 Git）
├── settings.local.json        # 本地个人覆盖（已加入 .gitignore）
├── agents/                    # 自定义子代理
│   ├── backend-agent-dev.md
│   ├── frontend-react-dev.md
│   ├── langgraph-reviewer.md
│   └── deploy-ops.md
├── skills/                    # 自定义技能
│   ├── run-dev-stack/SKILL.md
│   ├── add-graph-node/SKILL.md
│   └── add-shadcn-component/SKILL.md
├── rules/                     # 规则文件（由根 CLAUDE.md @-引用加载）
│   ├── python-backend-style.md
│   ├── frontend-style.md
│   ├── secrets-and-env.md
│   └── graph-conventions.md
├── commands/                  # 自定义斜杠命令
│   ├── dev.md
│   ├── build.md
│   ├── lint.md
│   ├── research-agent.md
│   └── test-cli.md
└── hooks/                     # 自动化钩子脚本（均已 chmod +x）
    ├── check-secrets.sh
    ├── format-python.sh
    └── notify-done.sh
```

另在仓库根目录新增 `CLAUDE.md`，作为加载规则、说明项目要点的入口（详见 §8）。
`.gitignore` 新增一行 `.claude/settings.local.json`，确保本地覆盖不被提交。

---

## 2. settings.json（项目基础设置，提交 Git）

路径：`.claude/settings.json`

- **permissions.allow**：预置本项目常用且安全的命令，减少权限弹窗：
  - 构建/运行：`make dev`、`langgraph dev`、`langgraph build`、`npm run dev/build/lint`、`npx shadcn@latest:*`、`pip install .`、`python examples/cli_research.py:*`
  - 检查：`ruff:*`、`mypy:*`、`pytest:*`、`eslint:*`、`tsc:*`、`vite:*`
  - 部署：`docker build:*`、`docker-compose:*`、`docker compose:*`
  - 只读 git：`git status`、`git diff:*`、`git log:*`、`git show:*`
- **permissions.deny**：禁止危险操作与读取密钥文件：
  - `Bash(rm -rf /*)`、`Bash(rm -rf ~/*)`
  - `Read(backend/.env)`、`Read(**/.env)`、`Read(**/.env.*)`、`Read(**/secrets/*)`
- **env**：注入项目级环境变量供会话使用 —— `PYTHON_VERSION=3.11`、`BACKEND_PORT=2024`、`FRONTEND_PORT=5173`、`LANGGRAPH_API_URL=http://127.0.0.1:2024`、`FRONTEND_BASE_PATH=/app/`。
- **hooks**：注册三个钩子（详见 §7）：PreToolUse(Write|Edit) → `check-secrets.sh`；PostToolUse(Write|Edit) → `format-python.sh`；Stop → `notify-done.sh`。

作用：把项目里反复要用到的命令预授权、把危险/敏感操作显式禁止、把钩子挂到工具生命周期上，使 Claude 在本仓库内「开箱即用」且安全可控。

## 3. settings.local.json（本地个人覆盖，Git 忽略）

路径：`.claude/settings.local.json`（已加入 `.gitignore`）

- 模板字段：`model`（个人默认模型，默认 `sonnet`）、`permissions.allow`（个人追加的允许项，留空待开发者自行补充）。
- 说明注释：明确「不要在此提交真实 API Key」。
- 运行时由 Claude Code 自动写入用户授予的本地权限（如本次已自动记录 `Bash(chmod +x .claude/hooks/*.sh)`）。

作用：每位开发者可在不污染团队共享配置的前提下，覆盖模型选择、追加本地权限（例如在自己机器上允许读取 `backend/.env`）。

## 4. agents/ — 自定义子代理（4 个）

| 文件 | 触发场景 | 作用 |
|---|---|---|
| `backend-agent-dev.md` | 编辑 `backend/src/agent/*`、`app.py`、`pyproject.toml` | Python/LangGraph 后端专家：掌握图的节点/边/状态、Gemini 调用方式、ruff(google pydocstyle) 规范、`Configuration` 配置机制，结束后跑 ruff/mypy/`langgraph dev` 验证 |
| `frontend-react-dev.md` | 编辑 `frontend/src/*`、`vite.config.ts`、`tsconfig`、`eslint.config.js` | React/Vite/Tailwind/shadcn 前端专家：掌握 `@` 别名、`base:/app/`、dev proxy、shadcn new-york 风格、`@langchain/langgraph-sdk` 流式调用，结束后跑 `npm run lint` + `npm run build` |
| `langgraph-reviewer.md` | 改动 graph 前的只读审查 | 对抗式审查者：核验图接线、状态 reducer、循环终止条件、引用/URL 处理、密钥安全；按严重级别输出 findings 并给 ship/fix-required 结论 |
| `deploy-ops.md` | 改 `Dockerfile`/`docker-compose.yml`/`Makefile` 或规划生产部署 | DevOps 专家：掌握多阶段镜像、Redis(pub-sub)/Postgres(状态+任务队列)、`LANGSMITH_API_KEY` 依赖、`apiUrl` 联调、部署检查清单 |

每个 agent 文件含 frontmatter（`name`/`description`/`tools`/`model`）+ 系统提示，Claude Code 会自动发现并可在 `Agent` 工具中选用。

## 5. skills/ — 自定义技能（3 个）

技能采用 `.claude/skills/<name>/SKILL.md` 结构，含 `name`/`description` frontmatter。

| 技能 | 作用 |
|---|---|
| `run-dev-stack` | 启动并排查全栈开发环境：检查 `GEMINI_API_KEY` 与依赖、`make dev` 启动后端(:2024)+前端(:5173)、提供常见故障决策树（proxy 端口不匹配、`langgraph` 未安装、端口占用等）、验证 `curl /ok` 与 UI 流式效果 |
| `add-graph-node` | 端到端新增 LangGraph 节点的清单：决定 state 字段(并行 list 必须配 `operator.add` reducer)、写 `def node(state, config)->dict`、用 `Configuration.from_runnable_config`、注册 `add_node`/`add_edge`/`add_conditional_edges`、可选加 `Configuration` 旋钮、ruff + `langgraph dev` + CLI 验证 |
| `add-shadcn-component` | 新增 shadcn/ui 组件：`npx shadcn@latest add <component>`、用 `@/components/ui/...` 引入、保留 Tailwind 4 CSS-first 配置（无 JS config）、`npm run lint` + `npm run build` 验证 |

## 6. commands/ — 自定义斜杠命令（5 个）

命令采用 `.claude/commands/*.md`，含 `description` frontmatter，正文为提示模板。

| 命令 | 作用 |
|---|---|
| `/dev` | 启动全栈开发环境并验证可达：检查密钥/依赖、后台跑 `make dev`、`curl /ok` 验证后端、验证前端 `/app`、报告 URL 与错误 |
| `/build` | 生产构建校验：前端 `npm run build`(tsc+vite)、后端 `langgraph build`，末尾给 `BUILD OK`/`BUILD FAILED` |
| `/lint` | 全仓 lint：后端 `ruff check` + `ruff format --check`(+可选 mypy)、前端 `npm run lint`；按 `file:line — rule — message` 汇总，征得同意后再 `--fix` |
| `/research-agent` | 读 `backend/src/agent/` 源码后讲解 agent：ASCII 流程图、各节点用到的模型与写入字段、终止条件、引用链路、可配项与默认值 |
| `/test-cli` | 通过 `backend/examples/cli_research.py` 跑一次研究查询（支持 `$ARGUMENTS` 传参，默认用可再生能源示例），打印带引用的最终答案并报告循环次数/错误 |

## 7. hooks/ — 自动化钩子脚本（3 个，均已可执行）

钩子在 `settings.json` 的 `hooks` 段注册，Claude Code 在工具生命周期调用，通过 stdin 收到 JSON 描述、用退出码控制行为（`exit 2` 阻断并把 stderr 反馈给模型）。

| 脚本 | 挂载点 | 作用 |
|---|---|---|
| `check-secrets.sh` | PreToolUse(Write\|Edit) | 从 JSON 取 `file_path` 与写入内容，对源码/配置类文件 grep `GEMINI_API_KEY\|LANGSMITH_API_KEY\|GOOGLE_API_KEY` 后跟 20+ 字符的真实值；命中则 `exit 2` 阻断写入并提示放入 `backend/.env`；占位符（`YOUR_ACTUAL_API_KEY` 等）放行。**已通过冒烟测试**：真实 key 阻断、占位符放行、`.md` 也扫描 |
| `format-python.sh` | PostToolUse(Write\|Edit) | 写入 `.py` 后自动 `ruff format` + `ruff check --fix`，与 `pyproject.toml` 的 ruff 配置保持一致；best-effort，失败不阻断 |
| `notify-done.sh` | Stop | 一轮结束时发桌面通知（`notify-send`/`osascript`，无则静默），并打印 `✅ Claude finished this turn.` |

## 8. rules/ 与根 CLAUDE.md — 规则与加载入口

`.claude/rules/` 不是 Claude Code 原生自动加载的目录；为让规则真正生效，在仓库根新增 `CLAUDE.md`，并通过 `@.claude/rules/<file>.md` 导入语法把四条规则加载进上下文：

| 规则文件 | 内容 |
|---|---|
| `python-backend-style.md` | ruff 启用项(E/F/I/D/D401/T201/UP)、忽略项(UP006/007/035/D417/E501)、google pydocstyle、imperative 首行 docstring、isort 顺序、mypy、pytest 约定 |
| `frontend-style.md` | React19+Vite6+Tailwind4(CSS-first, 无 JS config)、shadcn new-york/neutral、`@`→`src` 别名、`base:/app/`、`npm run build` 才做类型检查、ESLint 9 扁平配置 |
| `secrets-and-env.md` | 只许 `os.getenv`、密钥放 `backend/.env`、禁止硬编码/提交 `.env`/烤进镜像；说明钩子如何强制执行 |
| `graph-conventions.md` | state 必须给并行 list 配 reducer、节点签名 `def node(state,config)->dict`、`web_research` 故意用 `google.genai.Client`(需 grounding_metadata)、条件边可返回字符串或 `list[Send]`、循环必须有显式终止、`Configuration` 字段带 `metadata.description`、引用 URL 缩短/还原链路 |

`CLAUDE.md` 本身还包含：项目速览、Agent 图流程、常用命令、密钥说明、各 `.claude/` 子目录的指引，作为每次会话的入口上下文。

## 9. 验证结果

- **结构**：`find .claude -type f` 共 21 个文件（4 agents + 5 commands + 3 hooks + 4 rules + 2 settings + 3 skills），全部就位。
- **JSON**：`settings.json` 与 `settings.local.json` 均通过 `json.load` 校验。
- **钩子可执行**：三个脚本均已 `chmod +x`（`-rwxr-xr-x`）。
- **密钥钩子冒烟测试**：真实 key（`GEMINI_API_KEY="AIzaSy…"`）→ 阻断(exit 2)；占位符(`YOUR_ACTUAL_API_KEY`)→ 放行(exit 0)；`.md` 中的真实 key → 阻断。
- **`.gitignore`**：已添加 `.claude/settings.local.json`（原 `*.local` 不匹配 `.json` 后缀的本地设置文件）。

## 10. 后续可选增强

- 把 `backend/Makefile` 与 `frontend/package.json` 的脚本纳入更多 `permissions.allow`，按实际需要补充。
- 在 `backend/tests/` 补单测后，可新增 `.claude/commands/test.md` 跑 `pytest`。
- 若接入 MCP（需求3 相关，本次已忽略），可在 `settings.json` 的 `mcpServers` 段添加（本次未涉及）。
- `settings.local.json` 由开发者各自填写 `model` 与本地允许项。
