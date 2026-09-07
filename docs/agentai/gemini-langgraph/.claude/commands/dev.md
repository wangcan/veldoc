---
description: Start the fullstack dev stack (LangGraph backend + Vite frontend) and verify it's reachable.
---

Start the Gemini fullstack dev environment and confirm both servers come up.

## Steps
1. Verify `backend/.env` exists and has `GEMINI_API_KEY`. If missing, tell me to create it from `backend/.env.example` — do not write a real key.
2. Ensure deps: if `frontend/node_modules` is missing run `cd frontend && npm install`; if `langgraph` isn't on PATH run `cd backend && pip install -e ".[dev]"`.
3. Run `make dev` in the background (or `make dev-backend` and `make dev-frontend` separately).
4. After a few seconds, verify:
   - `curl -s http://127.0.0.1:2024/ok` returns health info (FastAPI app in `backend/src/agent/app.py`).
   - `http://localhost:5173/app` is reachable.
5. Report the backend URL, frontend URL, and any errors. If the frontend `/api` proxy 404s, check that `vite.config.ts` proxy target matches the running backend port (`:2024` for `langgraph dev`).
