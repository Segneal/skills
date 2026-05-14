---
name: setup-channel-architecture
description: Bootstrap a "channel" — an async communication log between development sessions (Claude↔Claude across runs, or human↔Claude when not co-present) backed by GitHub issues. One issue = one message. Use when the user wants to set up cross-session handoffs, decision logs, and free-form notes shared across development sessions for a project.
---

# setup-channel-architecture

A **channel** is an async message log for a project. Each message is a GitHub issue tagged with a type (`handoff`, `decision`, `note`). Sessions of Claude leave handoffs for future sessions; humans and Claude can leave decisions and notes for each other when not co-present.

This skill scaffolds the protocol doc, helper scripts, labels, and a SessionStart hook that surfaces the most recent open handoff at the start of every Claude session.

## Scaffold flow

### 1. Confirm location of the channel

Ask the user where channel issues should live:

> "Where should channel issues be stored?
> 1. **Same repo as the project** (label `channel` distinguishes them from real work)
> 2. **Dedicated repo** (zero noise — I'll create `<project>-channel`)"

If dedicated, ask for the repo name (default: `<current-repo>-channel`) and visibility (default: private), then run:

```bash
gh repo create <name> --private --confirm
```

Record the chosen repo as `CHANNEL_REPO` (e.g. `segneal/myproj-channel` or the project repo itself). All scripts and the hook will read this from a config file.

### 2. Create labels

In `CHANNEL_REPO`, create the labels the protocol depends on:

| Label             | Color     | Purpose                                  |
| ----------------- | --------- | ---------------------------------------- |
| `channel`         | `#0E8A16` | Marks an issue as a channel message      |
| `type:handoff`    | `#1D76DB` | Session handoff                          |
| `type:decision`   | `#5319E7` | Design / architectural decision          |
| `type:note`       | `#FBCA04` | Free-form note                           |
| `status:open`     | `#D93F0B` | Handoff still needs picking up           |
| `status:resolved` | `#0E8A16` | Handoff has been consumed                |

Run for each:

```bash
gh label create <name> --color <hex> --description "<purpose>" --repo "$CHANNEL_REPO"
```

Skip if a label already exists (gh returns exit 1; ignore).

### 3. Drop the protocol doc and config

- Copy `templates/CHANNEL.md` → `<project root>/CHANNEL.md` (so Claude reads it automatically when it sees the file).
- Write `<project root>/.channel/config` with:

  ```sh
  CHANNEL_REPO="<chosen repo>"
  ```

### 4. Drop helper scripts

Copy these into `<project root>/.channel/` and `chmod +x` each:

- `templates/channel-write.sh` → `.channel/write.sh`
- `templates/channel-read.sh`  → `.channel/read.sh`
- `templates/session-start.sh` → `.channel/session-start.sh`

### 5. Wire the SessionStart hook

Ask whether to register the hook globally (`~/.claude/settings.json`) or per-project (`.claude/settings.local.json`). Default: per-project.

Merge into the chosen settings file (do not overwrite — read first, then add the entry):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          { "type": "command", "command": ".channel/session-start.sh" }
        ]
      }
    ]
  }
}
```

If `SessionStart` already has entries, append; do not replace.

### 6. Final instructions

Print:

> Channel ready.
>
> - Repo: `$CHANNEL_REPO`
> - Protocol: `CHANNEL.md`
> - Write a message: `.channel/write.sh handoff "title" < body.md` (or pipe from stdin)
> - Read recent: `.channel/read.sh [type] [limit]`
> - On next session start, the hook surfaces the latest open handoff.
>
> Try it now: `.channel/write.sh note "channel bootstrapped" <<<"setup complete"`

## What this skill does NOT do

- No automatic message generation — Claude decides when to leave a handoff (typically at session close when asked).
- No syncing of channel state into git — messages live in GitHub issues only.
- No deletion of past messages — close issues to mark them resolved.
- No multi-channel-per-project support — one channel per project.
