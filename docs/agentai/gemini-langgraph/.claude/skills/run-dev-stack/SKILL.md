---
name: run-dev-stack
description: Start and troubleshoot the Gemini fullstack dev stack (LangGraph backend on :2024 + Vite frontend on :5173). Use when asked to run, start, restart, or debug the dev servers.
---

# Run the dev stack

This project is a fullstack LangGraph app: a Python/LangGraph backend and a React/Vite frontend, run together via `make dev`.

## Prerequisites (check first)
1. `GEMINI_API_KEY` must be set. Verify `backend/.env` exists and contains `GEMINI_API_KEY="..."` (copy from `backend/.env.example`). If missing, tell the user to add it — do NOT write a real key into a file (the PreToolUse hook will block it).
2. Backend deps installed: `backend/` has `pip install .` run. If `langgraph` is not on PATH, run `cd backend && pip install -e ".[dev]"` (or `pip install .`).
3. Frontend deps installed: `frontend/node_modules` exists. If not, `cd frontend && npm install`.

## Start both servers
From the project root:
```bash
make dev
```
- Backend: `cd backend && langgraph dev` -> API at `http://127.0.0.1:2024` (also opens LangGraph UI).
- Frontend: `cd frontend && npm run dev` -> app at `http://localhost:5173/app`.

To run only one: `make dev-backend` or `make dev-frontend`.

## Troubleshooting decision tree
- **`GEMINI_API_KEY is not set` ValueError on backend start** -> `backend/.env` missing or empty. Create it from `.env.example`.
- **Frontend `npm run dev` 404s on `/api/...`** -> Vite proxy in `vite.config.ts` targets `http://127.0.0.1:8000`; the LangGraph dev server runs on `:2024`. Either point the proxy at `:2024` or run the backend on `:8000`. Confirm `apiUrl` in `frontend/src/App.tsx` matches.
- **Port already in use** -> `lsof -i :2024` or `lsof -i :5173`; stop the stale process.
- **`langgraph: command not found`** -> backend deps not installed in the active env: `cd backend && pip install -e ".[dev]"`.
- **Frontend type errors on `npm run build`** -> `cd frontend && npx tsc -b --noEmit` to see them; fix before relying on `npm run dev` (Vite skips type-checking).

## Verify it works
- `curl -s http://127.0.0.1:2024/ok` should return health info from the FastAPI app (`backend/src/agent/app.py`).
- Open `http://localhost:5173/app`, submit a research question, and watch the `ActivityTimeline` stream.
