#!/usr/bin/env bash
# PreToolUse hook (Write|Edit): block writes that hard-code real API keys.
# Claude Code feeds a JSON object on stdin describing the tool call.
# Exit 0  -> allow the write.
# Exit 2  -> block the write; stderr is shown to the model as feedback.
set -euo pipefail

input="$(cat)"

# Extract the file path and the content being written/edited from the JSON payload.
file_path="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))
except Exception:
    print("")
' 2>/dev/null || true)"

content="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); ti=d.get("tool_input",{})
    print(ti.get("content") or ti.get("new_string") or "")
except Exception:
    print("")
' 2>/dev/null || true)"

# Only scan source/config-style files; skip everything else.
case "$file_path" in
  *.py|*.ts|*.tsx|*.js|*.jsx|*.env|*.json|*.yml|*.yaml|*.sh|*.toml|*.md) ;;
  *) exit 0 ;;
esac

# A real key looks like GEMINI_API_KEY="AIza..." (>=20 alnum chars).
# Placeholders such as YOUR_ACTUAL_API_KEY or <key> are allowed through.
if printf '%s' "$content" | grep -qiE '(GEMINI_API_KEY|LANGSMITH_API_KEY|GOOGLE_API_KEY)[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_-]{20,}'; then
  echo "BLOCKED by .claude/hooks/check-secrets.sh" >&2
  echo "  Detected a hard-coded API key in: ${file_path:-<unknown>}" >&2
  echo "  Put secrets in backend/.env (git-ignored) and read them via os.getenv()." >&2
  exit 2
fi

exit 0
