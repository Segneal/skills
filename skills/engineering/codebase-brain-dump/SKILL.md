---
name: codebase-brain-dump
description: Explore an unfamiliar codebase end-to-end and produce a self-contained codebase-analysis-docs/CODEBASE_KNOWLEDGE.md that another agent can use to implement features, fix bugs, or refactor safely. Use when the user wants to document, analyze, or onboard onto a codebase, generate a "brain dump" / architecture reference, or map an unknown repo.
---

# Codebase Brain Dump

You are a senior architect writing a **brain dump** another agent will rely on with no repo access. Explore the repo with the tools you have — don't wait for files to be pasted. Read only what you need, most-critical first, and iterate to fill gaps.

## Output contract

- Write everything under `codebase-analysis-docs/` (create it if absent).
- Master doc: `codebase-analysis-docs/CODEBASE_KNOWLEDGE.md`.
- Diagrams / schemas / supplements: `codebase-analysis-docs/assets/`.
- Every file reference is a **relative path from the repo root**, tied to a real file, function, or class.
- Skeleton to fill: [TEMPLATE.md](TEMPLATE.md).

## First: reuse what exists

If the repo has a `CONTEXT.md` (domain glossary), `docs/adr/`, or a README, read them first and **reuse their vocabulary** so the brain dump speaks the project's language instead of inventing new terms.

## Rules

- **Think first, write clean.** Reason internally; the doc contains findings only, not your reasoning chain.
- **One phase at a time.** Finish a phase before starting the next, and reuse the same terms across phases.
- **Maximum specificity.** Always name the actual path / class / function. No vague statements.
- **Explore before reading.** Use the Agent tool (`subagent_type=Explore`) to map the tree and locate things, then open the critical files yourself.
- **Self-contained.** A reader with no repo access must still understand the app.

## Phases

Run in order. After each, jot a short **STATE BLOCK** (file map so far, open questions, known risks, glossary delta) so you can resume. For big repos, see [LARGE-CODEBASES.md](LARGE-CODEBASES.md).

1. **Context scan** — Structure, languages, tech stack, notable deps, architecture type. Decide which files matter most and read them. Deliver: what the app is and does, its main features, each feature's business purpose, and how features relate at a high level.
2. **Architecture deep dive** — Components and interactions, data flow (user → backend → DB → response), third-party integrations, cross-cutting concerns (auth, security, logging, caching), architectural patterns/conventions. Deliver: Mermaid architecture + data-flow diagrams and a component map.
3. **Feature-by-feature** — For each feature: purpose + business need; entry points (routes/UI); controllers/services; models/DB; side effects (emails, jobs, webhooks); interactions with other features and shared modules; edge cases and hidden dependencies.
4. **Nuances & gotchas** — Non-obvious decisions and likely rationale, performance bottlenecks, security implications, hardcoded business rules, tricky/counterintuitive code. Deliver: a "Things You Must Know Before Changing Code" section.
5. **Technical reference** — Domain glossary; key classes/modules/functions with summaries; DB schema as a Mermaid ER diagram; internal/external APIs with example requests/responses.
6. **Assemble** — Merge phases 1–5 into `CODEBASE_KNOWLEDGE.md` (High-Level Overview → Mid-Level Notes → Deep Reference), cross-linked, with diagrams inline or in `assets/`. Verify it is complete and self-contained, then save.

## Diagrams

Mermaid for architecture / sequence / ER (keep each focused and small). ASCII or descriptive prose when Mermaid doesn't fit. Store large or standalone diagrams in `assets/` and link them.

## Close every section

End each section with **Findings**, **Open Questions**, and **Next Steps** — and log any coverage you skipped (top-N cutoffs, unread generated code) so gaps aren't mistaken for completeness.
