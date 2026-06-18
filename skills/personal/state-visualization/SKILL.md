---
name: state-visualization
description: Scaffold an interactive HTML page that visualizes workflows between packages/components in a project, driven by a JSON document. Use when user wants to document or visualize cross-package action flows.
---

# state-visualization

Scaffold an interactive HTML graph viewer (`flows.html`) plus a data file (`flows.json`) plus a local server helper (`serve-flows.sh`) into the user's project. The page lists actions on the left, shows a graph of packages in the center, and a per-action edge detail panel on the right. Clicking an action highlights the subgraph of packages involved and lists what each edge passes (payload).

## When to use

The user wants to document or visualize how packages/components interact for specific user-facing actions (e.g. "invite new user", "desktop build", "sync workspace").

## Scaffold flow

Follow these steps in order when invoked.

### 1. Confirm destination

Ask the user where to scaffold. Default is the current working directory (the root of the project they're in).

> "Scaffold `flows.html`, `flows.json`, and `serve-flows.sh` here (`<cwd>`)? Or another path?"

Create the target directory with `mkdir -p` if it does not exist.

### 2. Check for conflicts

For each of the three files (`flows.html`, `flows.json`, `serve-flows.sh`), check whether the file already exists at the destination. For each existing file, ask the user **separately** whether to overwrite it:

> "`flows.json` already exists. Overwrite it? (Keeping the existing one lets you preserve your edits.)"

This per-file granularity supports the common case of re-invoking the skill to refresh only the renderer (`flows.html`) while preserving the user's data (`flows.json`).

### 3. Copy template files

For each file that the user agreed to write, read the source from `skills/personal/state-visualization/template/<filename>` and write it to the destination.

After writing `serve-flows.sh`, set the executable bit:

```bash
chmod +x <destination>/serve-flows.sh
```

### 4. Final instructions

Print:

> Scaffolded:
> - `flows.html` (renderer)
> - `flows.json` (data — edit this to add nodes and actions)
> - `serve-flows.sh` (local server helper)
>
> To view: run `./serve-flows.sh` and open http://localhost:8765/flows.html
>
> The schema is documented at the top of `flows.json` in the `_doc` field.

### What this skill does NOT do (v1)

- No automatic codebase scan to suggest nodes/packages — the user fills `flows.json` by hand.
- No regeneration of the renderer beyond a fresh copy of the template.
- No support for multiple flows files in the same directory.
