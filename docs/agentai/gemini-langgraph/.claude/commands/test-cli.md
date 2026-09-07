---
description: Run the backend agent from the CLI via examples/cli_research.py and print the answer.
---

Run a one-off research query through the LangGraph agent from the command line.

## Prerequisite
- `GEMINI_API_KEY` must be set in `backend/.env`. If not, tell me to add it (do not write a real key).

## Run
If I gave an argument `$ARGUMENTS`, use it as the question; otherwise default to a sample question.
```bash
cd backend
python examples/cli_research.py "$ARGUMENTS"
```
(If no argument: use `"What are the latest trends in renewable energy?"`.)

## Report
- Print the final answer the agent produces (it includes inline citations).
- Note how many research loops ran and any errors (e.g. rate limits, missing grounding metadata).
- If it fails on `GEMINI_API_KEY is not set`, point me to `backend/.env.example`.
