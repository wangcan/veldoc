#!/usr/bin/env bash
# Stop hook: notify the developer when Claude finishes a turn.
# Best-effort: silent if no notifier is available (e.g. headless Linux/CI).
set -euo pipefail

if command -v notify-send >/dev/null 2>&1; then
  (notify-send "Claude Code" "Turn finished" 2>/dev/null &) || true
elif command -v osascript >/dev/null 2>&1; then
  (osascript -e 'display notification "Turn finished" with title "Claude Code"' 2>/dev/null &) || true
fi

printf '✅ Claude finished this turn.\n'
exit 0
