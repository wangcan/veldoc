# Rule: Python backend style

Scope: all `backend/**/*.py`.

## Lint/format — ruff (source of truth: `backend/pyproject.toml`)
- Enabled: `E` (pycodestyle), `F` (pyflakes), `I` (isort), `D` (pydocstyle), `D401` (imperative first docstring line), `T201`, `UP` (pyupgrade).
- Ignored: `UP006`, `UP007`, `UP035` (keep `typing_extensions` imports), `D417` (don't require docstring for every param), `E501` (no hard line length).
- `tests/*` relax `D` and `UP`.
- Pydocstyle convention: **google**.

## What this means in practice
- Every public function/class gets a Google-style docstring whose first line is imperative: `"""Generate search queries for the user's question."""`.
- Imports: stdlib -> third-party -> local, sorted by isort. Import `typing` symbols from `typing`/`typing_extensions` (do not "modernize" to built-in generics).
- Type hints encouraged; run `mypy backend/src` for non-test code.
- No stray `print` (`T201`); use logging or return values.
- Format with `ruff format`; the PostToolUse hook auto-formats `.py` files on Write/Edit, so do not fight its output.

## Tests
- `pytest` (dev dependency). New logic in `graph.py`/`utils.py` that is pure (URL resolution, citation insertion, routing) should get a unit test under `backend/tests/`.
