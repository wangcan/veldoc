---
description: Run ruff (backend) and eslint (frontend), then report and offer to fix.
---

Lint the whole repo according to each side's config.

## Backend (ruff — config in backend/pyproject.toml)
- `cd backend && ruff check src`
- `cd backend && ruff format --check src`
- Optionally `mypy src` for type coverage.

## Frontend (eslint 9 flat config)
- `cd frontend && npm run lint`

## Report
- Group findings by file. For each, give `file:line — rule — message`.
- Offer to auto-fix: ruff with `ruff check --fix src` / `ruff format src`, eslint with `npm run lint -- --fix`.
- Do not auto-fix until I confirm. End with `LINT CLEAN` or `LINT: N issues`.
