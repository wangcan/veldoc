# Rule: LangGraph graph conventions

Scope: `backend/src/agent/{graph,state,configuration,utils,tools_and_schemas,prompts}.py`.

## State (`state.py`)
- Use `TypedDict` for state shapes (`OverallState`, `ReflectionState`, `QueryGenerationState`, `WebSearchState`).
- Any list field that receives writes from parallel `Send` branches MUST have a reducer: `Annotated[list, operator.add]` (or `add_messages` for `messages`). A bare `list` is last-write-wins and will silently drop parallel results.
- Scalars (`int`/`str`/`bool`) are last-write-wins — fine for `research_loop_count`, `is_sufficient`.

## Nodes (`graph.py`)
- Signature: `def node(state, config: RunnableConfig) -> dict`. Always return a **state-update dict**; never mutate `state` and rely on it persisting.
- Read tunables from `Configuration.from_runnable_config(config)`; do not read `config["configurable"]` directly.
- Instantiate Gemini via `ChatGoogleGenerativeAI(model=..., api_key=os.getenv("GEMINI_API_KEY"))`. For structured output use `llm.with_structured_output(Schema)` where `Schema` is a Pydantic model in `tools_and_schemas.py`.
- The `web_research` node intentionally uses the raw `google.genai.Client` (not langchain) because langchain does not surface `grounding_metadata`. Preserve this when editing.

## Routing
- Conditional edges may return a node name (string) or a `list[Send]` for parallel fan-out.
- Every loop must have an explicit termination: `is_sufficient or research_loop_count >= max_research_loops`. Never introduce a cycle without a bound.

## Config (`configuration.py`)
- All knobs are Pydantic fields with `metadata={"description": ...}` so the LangGraph UI surfaces them.
- Env override convention: `os.environ.get(name.upper(), ...)`. Defaults: `gemini-2.0-flash`, `gemini-2.5-flash`, `gemini-2.5-pro`, `number_of_initial_queries=3`, `max_research_loops=2`.

## Citations (`utils.py`)
- `resolve_urls` shortens long vertex URLs to `https://vertexaisearch.cloud.google.com/id/<id>-<idx>`.
- `insert_citation_markers` sorts citations by `end_index` descending so insertions from the end don't shift earlier indices. Keep this ordering if you touch it.
- `finalize_answer` swaps `short_url` -> `value` and keeps only sources actually cited in `result.content`.
