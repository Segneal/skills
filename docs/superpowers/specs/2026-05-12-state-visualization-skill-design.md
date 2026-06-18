# state-visualization skill — design

**Date:** 2026-05-12
**Status:** Approved, ready for implementation plan
**Skill path:** `skills/personal/state-visualization/`

## Purpose

Scaffold an interactive HTML page that visualizes workflows between packages/components in a project. The page is driven by a JSON document. Clicking an action (e.g. "invite new user", "desktop build") highlights the subgraph of packages involved and annotates what each edge passes between packages.

## Scope

- **Generic**: works in any project where the user invokes the skill.
- **Scaffold-only behavior**: the skill creates files and exits. The renderer (HTML) is static after scaffolding — the user edits the JSON over time, not the HTML. The skill can be re-invoked later to regenerate one or more of the scaffolded files (e.g. to pull in an updated renderer or reset the JSON to the template), with per-file overwrite confirmation.
- **No code introspection in v1**: the user fills the JSON by hand.

## Architecture

### File layout in the skill

```
skills/personal/state-visualization/
  SKILL.md
  template/
    flows.html       (renderer; dark theme; dagre + SVG)
    flows.json       (data with "Invite new user" example preloaded)
    serve-flows.sh   (one-line wrapper around python3 -m http.server)
```

### Files scaffolded into the target project

By default, in the user's current working directory at invocation time (the target project's root):

- `flows.html` — renderer (static)
- `flows.json` — data (edited often)
- `serve-flows.sh` — local server helper (executable)

### Viewing model

`flows.html` does `fetch('./flows.json')`. Because `file://` would block that under CORS, the user runs the included `serve-flows.sh` (defaults to `python3 -m http.server 8765`) and opens `http://localhost:8765/flows.html`.

Rationale for separate JSON file (vs. inline in HTML): the user can regenerate the JSON without touching the renderer.

### Tech inside `flows.html`

- Dark theme, inline CSS.
- [dagre](https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js) via CDN for automatic graph layout.
- Vanilla SVG for rendering (follows the styling and structure of the approved dark-mode mockup: 3-column grid, purple-violet accent for active highlights, glow filter on involved nodes, dashed strokes for async edges).
- No frameworks, no build step.

## JSON schema

```json
{
  "nodes": [
    { "id": "auth", "name": "auth", "subtitle": "@app/auth" },
    { "id": "invites", "name": "invites", "subtitle": "@app/invites" },
    { "id": "email", "name": "email", "subtitle": "@app/email" },
    { "id": "db", "name": "db" }
  ],
  "actions": [
    {
      "id": "invite-user",
      "name": "Invite new user",
      "description": "User invites someone by email",
      "edges": [
        { "from": "auth",    "to": "invites", "payload": "{ inviterId, role }",   "async": false },
        { "from": "invites", "to": "email",   "payload": "{ to, token, link }",   "async": false },
        { "from": "invites", "to": "db",      "payload": "insert pending_invite", "async": false },
        { "from": "email",   "to": "db",      "payload": "mark sent_at",          "async": true  }
      ]
    }
  ]
}
```

### Rules

- **`nodes`** — global, unique `id`. `name` for display. `subtitle` optional.
- **`actions`** — each action owns its own `edges` (not shared). Same `from→to` pair can have different payloads in different actions.
- **`edges`** — `from`/`to` reference `node.id`. `payload` is free text shown verbatim in the panel. `async: true` renders the edge as a dashed line.
- **`_doc`** (optional top-level) — string with inline schema reminder. The renderer ignores it. See [Skill invocation flow](#skill-invocation-flow-skillmd-body-summary) for the contents the scaffold writes.
- **Validation**: at runtime, if an edge references a missing node id, log a console warning. Do not crash.

### Not in v1

- Per-node `kind`/color differentiation.
- Action categories or grouping.
- Tags or filters on actions.

## HTML behavior

### Screen layout

Three-column grid (matches the approved dark-mode mockup):

```
┌──────────────────────────────────────────────────────────┐
│ ◆ Flow Explorer                                          │
├──────────┬───────────────────────────────┬───────────────┤
│ Actions  │ Graph                         │ Detail panel  │
└──────────┴───────────────────────────────┴───────────────┘
```

- **Actions sidebar (left)** — list of `actions[].name`, click to select.
- **Graph canvas (center)** — SVG with all nodes laid out by dagre.
- **Detail panel (right)** — list of edges of the active action with payload.

### Interactions (v1)

1. **Page load**
   - `fetch('./flows.json')`, parse, validate edges against node ids (console warnings on misses).
   - Render actions sidebar.
   - Compute graph layout **once** using the union of all edges across all actions. Render nodes only (no edges visible yet, all nodes neutral styling).
   - Detail panel shows empty state: "Select an action to see the flow".

2. **Click on an action**
   - Mark that action as active in the sidebar (purple highlight).
   - Glow + full opacity on nodes involved in the action.
   - Fade non-involved nodes (opacity 0.35).
   - Draw only the active action's edges. Solid stroke if sync, dashed if `async: true`.
   - Populate the detail panel with the list of edges and their payloads.

3. **Click the active action again, or press `Esc`** → return to neutral state (no edges drawn, all nodes neutral).

4. **Click on a node** → no-op in v1 (reserved for v2).

### Layout stability

Node positions are computed once on load from the union of all edges, and **never recomputed**. Selecting different actions only changes which nodes/edges are highlighted. This prevents jarring re-layouts.

### Visual details

- ~200ms CSS transitions on opacity and stroke when highlight changes.
- `viewBox` of the SVG auto-fits the bounding box of all nodes.
- Empty or invalid JSON → a clear inline message in the graph area.

### Error handling

- Invalid JSON syntax → render a message in the canvas: "flows.json is not valid JSON. Check console."
- Edge references missing node id → console.warn, but render the rest of the graph.
- Empty `actions` array → show empty state in the sidebar.

## Skill invocation flow (SKILL.md body, summary)

1. **Confirm destination** — ask the user where to scaffold (default: the user's cwd at invocation time). Create the folder if needed.

2. **Conflict detection** — for each of `flows.html`, `flows.json`, `serve-flows.sh`, check if it already exists. Ask the user separately whether to overwrite each one. This supports the case where the user wants to regenerate only one file (e.g. refresh just the renderer, keep the JSON).

3. **Copy template files** — copy from `skills/personal/state-visualization/template/` to the destination. `chmod +x serve-flows.sh`.

4. **Final instructions** — print:
   - "Run `./serve-flows.sh` and open http://localhost:8765/flows.html"
   - "Edit `flows.json` to add your nodes and actions. Schema is documented at the top of the file in a `_doc` field."

5. **No code introspection** — v1 does not scan the codebase to suggest packages. The user fills the JSON manually.

### `serve-flows.sh` contents

```bash
#!/usr/bin/env bash
PORT="${1:-8765}"
python3 -m http.server "$PORT"
```

### `_doc` field in `flows.json`

The scaffolded `flows.json` includes a top-level `_doc` field with inline schema documentation, so users can re-read it without leaving the file. The renderer ignores `_doc`.

```json
{
  "_doc": "Schema: { nodes: [{id, name, subtitle?}], actions: [{id, name, description?, edges: [{from, to, payload, async?}]}] }. See full docs at skills/personal/state-visualization/SKILL.md.",
  "nodes": [ ... ],
  "actions": [ ... ]
}
```

## Roadmap v2 (out of v1 scope)

- Pan / zoom on the graph canvas.
- Search box to filter actions in the sidebar.
- Filters on actions (by tag or category).
- Animation along edges (token flowing from `from` to `to`).
- Click on a node → cross-action highlight (which actions touch this node).
- Keyboard navigation beyond `Esc`.
- Per-node `kind` field driving color differentiation.
- Codebase scan to suggest nodes from package layout.

## Open questions

None at the time of writing.
