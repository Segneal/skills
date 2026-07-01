# LARGE-CODEBASES.md — chunking & continuation

Use this when the repo is too big to hold in one context. The goal is coverage without losing your place.

## Token discipline

- Budget roughly **60% reading, 40% writing**. Don't read everything — read the highest-leverage files and stop.
- After each phase or major section, emit a **STATE BLOCK** (below). It's your resume point.
- If you approach the context limit mid-phase, emit `CONTINUE_REQUEST` + the latest STATE BLOCK + a `NEXT_READ_QUEUE`, then resume by re-ingesting the STATE BLOCK.

## Pass 0 — file index & prioritization

Walk the tree (via `subagent_type=Explore`) and classify each file: code / test / config / migration / infra / docs. Score importance:

- **Up:** entry points, high-coupling modules, heavily tested modules, runtime-critical configs, feature modules.
- **Down:** vendor deps, build artifacts, generated code, large binaries.

Emit a **FILE INDEX** — one line per file, highest priority first:

```
(#) PRIORITY | PATH | TYPE | LINES | NOTES
```

## Chunking

- Read in chunks of a few hundred lines; split on function/class boundaries, not mid-symbol.
- Label a chunk `PATH#START-END` and note its local header so refs stay stable.
- For file refs in the brain dump, use `path:line` (or `path::symbol`) so they're clickable.

## Passes (breadth-first, then deepen)

1. **Map** — structure, languages, entry points (breadth-first).
2. **Backbone** — the runtime-critical path deep dive.
3. **Feature catalog** — one entry per feature.
4. **Cross-cutting** — auth, logging, caching, security.
5. **Synthesis** — assemble `CODEBASE_KNOWLEDGE.md`.

**Tests-first shortcut:** start from E2E/integration tests to discover features fast — they name the important flows.

**Dependency heuristic:** build a rough import/call map and prioritize modules by in/out degree (most-depended-on first).

## STATE BLOCK

Emit after each phase:

```
STATE BLOCK
- FILE_MAP_SUMMARY: top ~50 files read/pending
- OPEN_QUESTIONS: unresolved questions
- KNOWN_RISKS: fragile areas, guesses, unread hot spots
- GLOSSARY_DELTA: new domain terms since last block
- NEXT_READ_QUEUE: ordered paths/chunks to read next
```

## Assumptions

When you infer rather than confirm, record it in the **Assumptions** table (Assumption | Confidence | How to confirm) rather than stating it as fact. Note generated/opaque code by its generator and public API surface instead of reading it line by line.

## Output hygiene

Every section must be actionable and end with **Findings / Open Questions / Next Steps**. If you bounded coverage (top-N only, skipped a directory), **say so** — silent truncation reads as "fully covered" when it isn't.
