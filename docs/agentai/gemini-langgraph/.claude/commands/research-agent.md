---
description: Explain how the LangGraph research agent works (nodes, state, routing) by reading the source.
---

Read `backend/src/agent/` and explain the research agent end-to-end. Do not paraphrase from memory — read the actual files.

## Read
- `backend/src/agent/graph.py` (nodes + edges + compile)
- `backend/src/agent/state.py` (OverallState, ReflectionState, sub-states, reducers)
- `backend/src/agent/configuration.py` (defaults: models, query count, max loops)
- `backend/src/agent/prompts.py` (query_writer, web_searcher, reflection, answer instructions)
- `backend/src/agent/tools_and_schemas.py` (SearchQueryList, Reflection)
- `backend/src/agent/utils.py` (resolve_urls, get_citations, insert_citation_markers)

## Produce
1. A flow diagram (ASCII) of the graph: `generate_query -> web_research (parallel) -> reflection -> evaluate_research -> {web_research | finalize_answer} -> END`.
2. For each node: which Gemini model it uses, what it returns, and which state fields it writes.
3. The termination condition (`is_sufficient or research_loop_count >= max_research_loops`).
4. How citations flow: long URL -> short `vertexaisearch` URL -> inserted markers -> restored to original in `finalize_answer`.
5. The configurable knobs and their defaults.
