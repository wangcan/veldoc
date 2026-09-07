# CLAUDE.md

Project: **Gemini Fullstack LangGraph Quickstart** — a fullstack AI research agent.
A React frontend talks to a LangGraph backend that generates search queries, researches
the web with Google Search + Gemini, reflects on gaps, and writes a cited answer.

## Quick facts
- **Backend** (`backend/`, Python 3.11+): LangGraph `StateGraph`, LangChain, `langchain-google-genai` + `google-genai`, FastAPI, Pydantic. Graph entry: `backend/src/agent/graph.py:graph`. Dev: `cd backend && langgraph dev` (API `:2024`). Lint: `ruff`.
- **Frontend** (`frontend/`, TS): React 19 + Vite 6 + Tailwind 4 + shadcn/ui (new-york) + `@langchain/langgraph-sdk`. Path alias `@` -> `src`, base `/app/`. Dev: `cd frontend && npm run dev` (`:5173/app`). Build: `npm run build` (`tsc -b && vite build`).
- **Run both**: `make dev`.
- **Deploy**: `docker build -t gemini-fullstack-langgraph -f Dockerfile .` then `GEMINI_API_KEY=... LANGSMITH_API_KEY=... docker-compose up` (Redis + Postgres). App at `http://localhost:8123/app/`.
- **Secrets**: `GEMINI_API_KEY` (Gemini), `LANGSMITH_API_KEY` (platform). Keep them in `backend/.env` (git-ignored). Never hard-code — the PreToolUse hook blocks it.

## Agent graph flow
`generate_query -> web_research (parallel fan-out via Send) -> reflection -> evaluate_research -> {web_research | finalize_answer} -> END`.
Termination: `is_sufficient or research_loop_count >= max_research_loops` (default 2).

## How to work here
- Match the surrounding code style. Python: ruff (google pydocstyle, imperative docstrings). Frontend: ESLint 9 flat config, strict TS.
- Before declaring work done: backend `ruff check && ruff format` (+ `mypy`/`pytest` for logic); frontend `npm run lint && npm run build`.
- Custom subagents live in `.claude/agents/` (backend, frontend, graph-reviewer, deploy-ops). Skills in `.claude/skills/`. Slash commands in `.claude/commands/`.
- Hooks (`.claude/hooks/`): `check-secrets.sh` (PreToolUse, blocks hard-coded keys), `format-python.sh` (PostToolUse, ruff on `.py`), `notify-done.sh` (Stop).

## Project rules (loaded via @-imports below)
@.claude/rules/python-backend-style.md
@.claude/rules/frontend-style.md
@.claude/rules/secrets-and-env.md
@.claude/rules/graph-conventions.md
