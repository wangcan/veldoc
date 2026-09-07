---
name: add-graph-node
description: Add a new node to the LangGraph research graph in backend/src/agent/graph.py end-to-end. Use when extending the agent flow with a new step (e.g. summarization, dedup, guardrail).
---

# Add a LangGraph node

The graph lives in `backend/src/agent/graph.py` and is compiled at module load as `graph = builder.compile(name="pro-search-agent")`. Follow this checklist so state, routing, and config stay consistent.

## 1. Decide the state shape
- If the node produces new data, add a field to `OverallState` (or a sub-state) in `backend/src/agent/state.py`.
- For list fields that accumulate across parallel branches, annotate with `Annotated[list, operator.add]` (see `search_query`, `web_research_result`, `sources_gathered`). A plain `list` without a reducer will be overwritten by parallel `Send` returns.
- Scalars (`int`, `str`, `bool`) are last-write-wins by default — fine for counts/flags.

## 2. Write the node function
Signature: `def my_node(state: OverallState, config: RunnableConfig) -> dict:`.
- Read config via `configurable = Configuration.from_runnable_config(config)`.
- Instantiate the LLM with `ChatGoogleGenerativeAI(model=<from config>, api_key=os.getenv("GEMINI_API_KEY"), ...)`.
- For structured output: `llm.with_structured_output(MySchema)` where `MySchema` is a Pydantic model in `tools_and_schemas.py`.
- Return a **dict** (state update), e.g. `return {"web_research_result": [text]}`. Never mutate `state` in place expecting it to persist — return the delta.
- Add a Google-style docstring (ruff `D401`: imperative first line).

## 3. Register + wire the node
```python
builder.add_node("my_node", my_node)
builder.add_edge("reflection", "my_node")          # linear
# or conditional:
builder.add_conditional_edges("my_node", my_router, ["web_research", "finalize_answer"])
```
- Conditional routers can return a node-name string OR a list of `Send(...)` for parallel fan-out (see `continue_to_web_research`, `evaluate_research`).
- Keep the termination condition explicit: `is_sufficient or research_loop_count >= max_research_loops`.

## 4. Add config knobs (optional)
If the node needs a tunable (model name, threshold), add a field to `Configuration` in `configuration.py` with `Field(default=..., metadata={"description": ...})`. It becomes overridable via env var (`NAME_UPPER`) or `configurable`.

## 5. Validate
- `cd backend && ruff check src && ruff format src`
- `cd backend && langgraph dev` must start with no import errors.
- Hit the graph via the CLI: `cd backend && python examples/cli_research.py "<question>"`.
