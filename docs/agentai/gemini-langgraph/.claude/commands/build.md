---
description: Build the frontend (tsc + vite) and validate the backend graph compiles.
---

Validate a production build of both sides.

## Frontend
1. `cd frontend`
2. `npm run build` (runs `tsc -b && vite build`).
3. Report any TypeScript or Vite errors. Do not claim success unless both pass.
4. Note the output dir (`frontend/dist/`) — this is what the Docker image serves.

## Backend
1. `cd backend`
2. `langgraph build` to confirm the graph compiles for deployment.
3. Report success/failure and the artifact location if produced.

## Summary
End with a one-line status: `BUILD OK` or `BUILD FAILED: <reason>`.
