# Rule: Secrets & environment variables

Scope: whole repo. Enforced mechanically by `.claude/hooks/check-secrets.sh` (PreToolUse, Write|Edit).

## Allowed
- Read secrets only via `os.getenv("GEMINI_API_KEY")`, `os.getenv("LANGSMITH_API_KEY")`, etc.
- Store real keys in `backend/.env` (git-ignored — see `.gitignore`) and reference `backend/.env.example` for the template.
- Pass production keys at runtime: `GEMINI_API_KEY=... LANGSMITH_API_KEY=... docker-compose up`.

## Forbidden
- Hard-coding `GEMINI_API_KEY="AIza..."` (or any 20+ char value) in `.py`, `.ts`, `.tsx`, `.json`, `.yml`, `.sh`, `.toml`, `.md`, `.env`.
- Committing `backend/.env`, `**/.env`, or `**/.env.*` (deny rule in `settings.json` blocks reads; `.gitignore` excludes them).
- Baking keys into the Docker image.

## Enforcement
- The `check-secrets.sh` PreToolUse hook greps written content for `GEMINI_API_KEY|LANGSMITH_API_KEY|GOOGLE_API_KEY` followed by `=`/`:` and a 20+ char value. Matches exit 2 and block the write. Placeholders like `YOUR_ACTUAL_API_KEY` or `<key>` are allowed.
- If a legitimate write is blocked, restructure to read from env instead of asking to disable the hook.
