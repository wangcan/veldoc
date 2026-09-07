#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): auto-format and lint-fix Python files with ruff.
# Runs after a write lands so backend/src stays consistent with pyproject.toml's ruff config.
# Exit 0 always (best-effort; never block on formatting failure).
set -euo pipefail

input="$(cat)"

file_path="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))
except Exception:
    print("")
' 2>/dev/null || true)"

case "$file_path" in
  *.py) ;;
  *) exit 0 ;;
esac

[ -n "$file_path" ] && [ -f "$file_path" ] || exit 0

if command -v ruff >/dev/null 2>&1; then
  ruff format "$file_path" >/dev/null 2>&1 || true
  ruff check --fix "$file_path" >/dev/null 2>&1 || true
fi

exit 0
