# TEMPLATE — `CODEBASE_KNOWLEDGE.md`

Fill this skeleton into `codebase-analysis-docs/CODEBASE_KNOWLEDGE.md`. Delete guidance comments (`<!-- ... -->`) as you go. Keep three tiers: skim-able overview → practical notes → deep reference.

---

```md
# <Project Name> — Codebase Knowledge

> Self-contained brain dump. A reader with no repo access should understand the app from this file alone. All paths are relative to the repo root.

_Last mapped: <commit hash / date>. Coverage: <what was read vs skipped>._

## Part 1 — High-Level Overview

### What it is
<!-- One paragraph: purpose, domain, target users. -->

### Tech stack
<!-- Languages, frameworks, notable dependencies, architecture type. -->

### Features & business purpose
<!-- Table: Feature | What it does | Business need it serves | Key entry file(s) -->

### How features relate
<!-- Prose + a Mermaid graph of feature-to-feature dependencies. -->

## Part 2 — Mid-Level Technical Notes

### Architecture
<!-- Mermaid component diagram. Name real modules/services and the seams between them. -->

### Data flow
<!-- Mermaid sequence diagram: user → entry point → service → DB → response. -->

### Cross-cutting concerns
<!-- Auth, security, logging, caching, error handling — where each lives (file/module). -->

### Feature deep dives
<!-- Repeat per feature -->
#### <Feature>
- **Purpose / business need:**
- **Entry points:** `path` (route/UI)
- **Controllers / services:** `path::function`
- **Models / DB:** `path` (tables/collections)
- **Side effects:** emails, jobs, webhooks — `path`
- **Interacts with:** <other features / shared modules>
- **Edge cases & hidden dependencies:**

### Things You Must Know Before Changing Code
<!-- Gotchas: non-obvious decisions + likely rationale, bottlenecks, security implications,
     hardcoded business rules, counterintuitive code. Tie each to a file/function. -->

## Part 3 — Deep Reference

### Glossary
<!-- Domain term → definition. Reuse CONTEXT.md vocabulary if it exists. -->

### Key modules, classes & functions
<!-- Table: Symbol | File | Responsibility | Notes -->

### Database schema
<!-- Mermaid erDiagram of tables/entities and relationships. -->

### APIs
<!-- Internal + external endpoints. Method + path + purpose + example request/response. -->

### Assumptions
<!-- Table: Assumption | Confidence (high/med/low) | How to confirm -->

### Open questions & next steps
```
