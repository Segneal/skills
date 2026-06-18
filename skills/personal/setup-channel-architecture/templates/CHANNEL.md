# Channel protocol

This project uses a **channel** — an async log of messages exchanged between development sessions. Messages are GitHub issues in `$CHANNEL_REPO` (see `.channel/config`).

Audiences:
- **Claude ↔ Claude** across sessions (handoffs at session close, picked up at session start).
- **Human ↔ Claude** when not co-present (leave a decision or note for the other to read later).

## Message = one GitHub issue

| Field    | Convention                                                              |
| -------- | ----------------------------------------------------------------------- |
| Title    | `[<type>] <short title>` — e.g. `[handoff] OAuth flow WIP — refresh TBD`|
| Labels   | `channel` + `type:<handoff\|decision\|note>` + optional `status:*`      |
| Body     | Markdown, structured per type (see below)                               |
| State    | Issues stay open until consumed; close to mark resolved                 |

## Message types

### `handoff` — pick this up next session

Use at session close when work was left mid-stream. Label: `type:handoff` + `status:open`.

```md
## Context
One sentence on what was being worked on.

## Done
- bullet
- bullet

## Pending
- bullet (next session picks this up)

## Where to resume
`path/to/file.ts:42` or a clear entry point.
```

A session that consumes a handoff should comment "picked up" on the issue and either close it (if fully done) or relabel `status:resolved`.

### `decision` — record a choice for future context

Use when a design or architectural choice was made that won't be obvious from the code alone. Label: `type:decision`. Usually stays open as a permanent record (don't close).

```md
## Decision
One-liner stating the choice.

## Why
The motivating constraint or trade-off.

## Alternatives considered
- X — rejected because…
- Y — rejected because…

## Implications
What this changes downstream.
```

### `note` — free-form observation

Use for anything else worth surfacing later: a gotcha discovered, an idea to revisit, a non-actionable observation. Label: `type:note`. Close once read or after it's no longer relevant.

```md
## Note
Free-form text.
```

## Workflow

| Situation                                  | Action                                                   |
| ------------------------------------------ | -------------------------------------------------------- |
| Closing a session with pending work        | `.channel/write.sh handoff "<title>"` (body via stdin)   |
| Making a non-trivial design choice         | `.channel/write.sh decision "<title>"`                   |
| Capturing a passing observation            | `.channel/write.sh note "<title>"`                       |
| Starting a session                         | The SessionStart hook surfaces the latest open handoff   |
| Picking up a handoff                       | Comment "picked up" + close (or relabel `status:resolved`) |
| Browsing                                   | `.channel/read.sh [type] [limit]`                        |

## Conventions

- One topic per message. If a handoff spans two unrelated areas, write two handoffs.
- Title is a sentence fragment, not a question. The body has the detail.
- Don't put secrets in the channel — issues are searchable.
- Decisions are immutable. To revise, file a new decision that references the old one (`supersedes #<n>`).
