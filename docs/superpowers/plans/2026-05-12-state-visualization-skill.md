# state-visualization Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a personal skill that scaffolds an interactive HTML graph viewer (`flows.html` + `flows.json` + `serve-flows.sh`) into any project, so the user can document inter-package action flows.

**Architecture:** A skill directory under `skills/personal/state-visualization/` containing `SKILL.md` and a `template/` folder with the three artifacts. When invoked, Claude follows `SKILL.md` to copy the template files into the user's cwd, with per-file overwrite confirmation. The renderer is a single-file HTML using dagre (CDN) for layout and vanilla SVG for rendering; it `fetch`es `./flows.json` (served via a tiny `python3 -m http.server` wrapper).

**Tech Stack:** Bash, HTML5, vanilla JS (ES2020), inline CSS, [dagre 0.8.5](https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js) via CDN, Python 3 (for the local server).

**Spec:** `docs/superpowers/specs/2026-05-12-state-visualization-skill-design.md`

---

## File Structure

Files created by this plan:

```
skills/personal/state-visualization/
  SKILL.md                              # Claude-facing instructions
  template/
    flows.html                          # Renderer (dark theme + dagre + SVG)
    flows.json                          # Data template with "Invite new user" example
    serve-flows.sh                      # python3 -m http.server wrapper
```

Files modified by this plan:

```
skills/personal/README.md               # Add entry for state-visualization
```

Files NOT touched (per CLAUDE.md project rule — personal skills are not promoted):

- `README.md` (repo root)
- `.claude-plugin/plugin.json`

---

## Task 1: Scaffold skill directory and SKILL.md frontmatter

**Files:**
- Create: `skills/personal/state-visualization/SKILL.md`
- Create: `skills/personal/state-visualization/template/` (directory)

- [ ] **Step 1: Create the skill directory and template subdirectory**

Run:
```bash
mkdir -p skills/personal/state-visualization/template
```

Expected: no output. Verify with `ls skills/personal/state-visualization/` → shows `template/`.

- [ ] **Step 2: Create SKILL.md with frontmatter only (body comes in Task 7)**

Write `skills/personal/state-visualization/SKILL.md`:

```markdown
---
name: state-visualization
description: Scaffold an interactive HTML page that visualizes workflows between packages/components in a project, driven by a JSON document. Use when user wants to document or visualize cross-package action flows.
---

# state-visualization

(Body of SKILL.md is added in Task 7.)
```

- [ ] **Step 3: Verify frontmatter parses**

Run:
```bash
head -5 skills/personal/state-visualization/SKILL.md
```

Expected output:
```
---
name: state-visualization
description: Scaffold an interactive HTML page that visualizes workflows between packages/components in a project, driven by a JSON document. Use when user wants to document or visualize cross-package action flows.
---
```

- [ ] **Step 4: Commit**

```bash
git add skills/personal/state-visualization/
git commit -m "Scaffold state-visualization skill directory"
```

---

## Task 2: Create `flows.json` template

**Files:**
- Create: `skills/personal/state-visualization/template/flows.json`

- [ ] **Step 1: Write `flows.json` with the example "Invite new user" flow**

Write `skills/personal/state-visualization/template/flows.json`:

```json
{
  "_doc": "Schema: { nodes: [{id, name, subtitle?}], actions: [{id, name, description?, edges: [{from, to, payload, async?}]}] }. The _doc field is ignored by the renderer.",
  "nodes": [
    { "id": "auth",     "name": "auth",     "subtitle": "@app/auth" },
    { "id": "invites",  "name": "invites",  "subtitle": "@app/invites" },
    { "id": "email",    "name": "email",    "subtitle": "@app/email" },
    { "id": "db",       "name": "db",       "subtitle": "@app/db" },
    { "id": "billing",  "name": "billing",  "subtitle": "@app/billing" }
  ],
  "actions": [
    {
      "id": "invite-user",
      "name": "Invite new user",
      "description": "A user invites someone by email",
      "edges": [
        { "from": "auth",    "to": "invites", "payload": "{ inviterId, role }",   "async": false },
        { "from": "invites", "to": "email",   "payload": "{ to, token, link }",   "async": false },
        { "from": "invites", "to": "db",      "payload": "insert pending_invite", "async": false },
        { "from": "email",   "to": "db",      "payload": "mark sent_at",          "async": true  }
      ]
    },
    {
      "id": "desktop-build",
      "name": "Desktop build",
      "description": "Placeholder — replace with your own flow",
      "edges": []
    }
  ]
}
```

- [ ] **Step 2: Validate JSON syntax**

Run:
```bash
python3 -c "import json; json.load(open('skills/personal/state-visualization/template/flows.json'))" && echo OK
```

Expected output: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/personal/state-visualization/template/flows.json
git commit -m "Add flows.json template with example flow"
```

---

## Task 3: Create `serve-flows.sh`

**Files:**
- Create: `skills/personal/state-visualization/template/serve-flows.sh`

- [ ] **Step 1: Write the server wrapper**

Write `skills/personal/state-visualization/template/serve-flows.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8765}"
echo "Serving flows.html on http://localhost:${PORT}/flows.html"
echo "Press Ctrl+C to stop."
exec python3 -m http.server "$PORT"
```

- [ ] **Step 2: Validate bash syntax**

Run:
```bash
bash -n skills/personal/state-visualization/template/serve-flows.sh && echo OK
```

Expected output: `OK`

- [ ] **Step 3: Note about chmod**

The template file is committed without the executable bit. `SKILL.md` (Task 6) will instruct Claude to `chmod +x` the copy in the destination after scaffolding. Storing it as non-executable in the template is fine and avoids cross-platform git pitfalls.

- [ ] **Step 4: Commit**

```bash
git add skills/personal/state-visualization/template/serve-flows.sh
git commit -m "Add serve-flows.sh helper"
```

---

## Task 4: Create `flows.html` — HTML skeleton, layout, and styling

This task produces a renderable page with the 3-column grid and the empty state. No JSON loading or graph rendering yet — that comes in Tasks 5 and 6.

**Files:**
- Create: `skills/personal/state-visualization/template/flows.html`

- [ ] **Step 1: Write the skeleton with inline dark-theme CSS**

Write `skills/personal/state-visualization/template/flows.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Flow Explorer</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    :root {
      --bg: #0e0f13;
      --panel: #15171f;
      --border: #232633;
      --text: #e6e8ee;
      --muted: #8a90a3;
      --label: #5d6275;
      --accent: #7c5cff;
      --accent-soft: rgba(124, 92, 255, 0.18);
      --accent-edge: rgba(74, 214, 255, 0.08);
      --node-stroke-inactive: #3a3f52;
      --edge-cold: #2a2e3d;
    }
    * { box-sizing: border-box; }
    html, body {
      margin: 0; padding: 0;
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, system-ui, "Segoe UI", sans-serif;
      height: 100%;
    }
    body { padding: 24px; }
    .header { display: flex; gap: 12px; align-items: center; margin-bottom: 6px; }
    .header .bar {
      width: 6px; height: 24px;
      background: linear-gradient(180deg, #7c5cff, #4ad6ff);
      border-radius: 3px;
    }
    .header h1 {
      margin: 0; font-size: 18px; font-weight: 600;
      letter-spacing: -0.01em; color: #fff;
    }
    .subtitle {
      color: var(--muted); margin: 0 0 20px 18px; font-size: 13px;
    }
    .grid {
      display: grid;
      grid-template-columns: 220px 1fr 300px;
      gap: 16px;
      min-height: calc(100vh - 110px);
    }
    .panel {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 14px;
      overflow: auto;
    }
    .label {
      font-size: 10px;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--label);
      font-weight: 600;
      margin-bottom: 10px;
    }
    .action-list { display: flex; flex-direction: column; gap: 4px; }
    .action-item {
      padding: 8px 10px;
      color: var(--muted);
      font-size: 12px;
      border-radius: 6px;
      cursor: pointer;
      border: 1px solid transparent;
    }
    .action-item:hover { color: var(--text); }
    .action-item.active {
      background: linear-gradient(90deg, var(--accent-soft), var(--accent-edge));
      border: 1px solid #4a3d8a;
      color: #c8b9ff;
      font-weight: 500;
    }
    #canvas { width: 100%; height: 100%; min-height: 360px; }
    .empty-state {
      display: flex; align-items: center; justify-content: center;
      height: 100%; color: var(--label); font-size: 13px;
    }
    .edge-list { display: flex; flex-direction: column; gap: 10px; font-size: 11.5px; }
    .edge-item .ends { color: #c8b9ff; font-weight: 500; }
    .edge-item .async-tag { color: var(--label); font-weight: 400; margin-left: 4px; }
    .edge-item code {
      color: var(--muted);
      font-size: 10.5px;
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    /* SVG node and edge styles */
    .node rect {
      fill: #1c1f2c;
      stroke: var(--node-stroke-inactive);
      stroke-width: 1.5;
      transition: stroke 200ms, opacity 200ms, filter 200ms;
    }
    .node text { fill: #fff; font-size: 13px; font-weight: 600; }
    .node text.subtitle-text { fill: var(--muted); font-size: 10px; font-weight: 400; }
    .node.active rect {
      stroke: var(--accent);
      stroke-width: 2;
      filter: url(#glow);
    }
    .node.inactive { opacity: 0.35; }
    .edge {
      stroke: var(--accent);
      stroke-width: 2.5;
      fill: none;
      filter: url(#glow);
      transition: opacity 200ms;
    }
    .edge.async { stroke-dasharray: 4 3; }
    .error-banner {
      background: #3a1f1f; border: 1px solid #5a2929;
      color: #ffb4b4; padding: 10px 14px; border-radius: 8px;
      font-size: 13px; margin-bottom: 12px;
    }
  </style>
</head>
<body>
  <div class="header">
    <div class="bar"></div>
    <h1>Flow Explorer</h1>
  </div>
  <p class="subtitle">Click an action to highlight the subgraph of packages involved.</p>

  <div id="error" class="error-banner" style="display:none"></div>

  <div class="grid">
    <div class="panel">
      <div class="label">Actions</div>
      <div id="actions" class="action-list"></div>
    </div>
    <div class="panel">
      <svg id="canvas" preserveAspectRatio="xMidYMid meet">
        <defs>
          <filter id="glow">
            <feGaussianBlur stdDeviation="3" result="blur"/>
            <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
          <marker id="arrow" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
            <path d="M0,0 L9,3 L0,6 z" fill="#7c5cff"/>
          </marker>
        </defs>
      </svg>
    </div>
    <div class="panel">
      <div class="label">Flow</div>
      <div id="detail"><div class="empty-state">Select an action</div></div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js"></script>
  <script>
    // Renderer code is added in Tasks 5 and 6.
  </script>
</body>
</html>
```

- [ ] **Step 2: Verify file is non-empty and contains the expected structure**

Run:
```bash
grep -c 'id="canvas"' skills/personal/state-visualization/template/flows.html
grep -c 'dagre@0.8.5' skills/personal/state-visualization/template/flows.html
```

Expected output: `1` and `1`.

- [ ] **Step 3: Commit**

```bash
git add skills/personal/state-visualization/template/flows.html
git commit -m "Add flows.html skeleton with dark theme and 3-column layout"
```

---

## Task 5: Add JSON loading, validation, and graph layout

This task makes the page load `flows.json`, validate it, compute the layout from the union of edges, and render the nodes (no edge highlighting yet — that comes in Task 6).

**Files:**
- Modify: `skills/personal/state-visualization/template/flows.html` (replace the empty `<script>` body at the end of `<body>`)

- [ ] **Step 1: Replace the renderer script block**

In `skills/personal/state-visualization/template/flows.html`, replace the line `// Renderer code is added in Tasks 5 and 6.` with the following script body:

```javascript
const NODE_W = 120;
const NODE_H = 60;
const PADDING = 20;

const state = {
  data: null,
  activeActionId: null,
  layout: null,
};

function showError(msg) {
  const el = document.getElementById('error');
  el.textContent = msg;
  el.style.display = 'block';
}

function validateData(data) {
  if (!data || typeof data !== 'object') {
    throw new Error('flows.json must be a JSON object');
  }
  const nodes = Array.isArray(data.nodes) ? data.nodes : [];
  const actions = Array.isArray(data.actions) ? data.actions : [];
  const nodeIds = new Set(nodes.map(n => n.id));
  for (const action of actions) {
    for (const edge of (action.edges || [])) {
      if (!nodeIds.has(edge.from)) {
        console.warn(`Action "${action.name}" edge references unknown node id "${edge.from}"`);
      }
      if (!nodeIds.has(edge.to)) {
        console.warn(`Action "${action.name}" edge references unknown node id "${edge.to}"`);
      }
    }
  }
  return { nodes, actions };
}

function computeLayout(nodes, actions) {
  const g = new dagre.graphlib.Graph();
  g.setGraph({ rankdir: 'LR', nodesep: 40, ranksep: 70, marginx: PADDING, marginy: PADDING });
  g.setDefaultEdgeLabel(() => ({}));

  for (const n of nodes) {
    g.setNode(n.id, { width: NODE_W, height: NODE_H });
  }
  const seen = new Set();
  for (const action of actions) {
    for (const edge of (action.edges || [])) {
      const key = `${edge.from}->${edge.to}`;
      if (!seen.has(key)) {
        seen.add(key);
        g.setEdge(edge.from, edge.to);
      }
    }
  }
  dagre.layout(g);

  const positions = {};
  let maxX = 0, maxY = 0;
  for (const id of g.nodes()) {
    const n = g.node(id);
    positions[id] = { x: n.x - NODE_W / 2, y: n.y - NODE_H / 2 };
    maxX = Math.max(maxX, n.x + NODE_W / 2);
    maxY = Math.max(maxY, n.y + NODE_H / 2);
  }
  return { positions, width: maxX + PADDING, height: maxY + PADDING };
}

function renderNodes() {
  const svg = document.getElementById('canvas');
  // Remove existing node groups (keep <defs>)
  svg.querySelectorAll('g.node').forEach(el => el.remove());

  const { positions } = state.layout;
  for (const node of state.data.nodes) {
    const pos = positions[node.id];
    if (!pos) continue;
    const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    g.setAttribute('class', 'node');
    g.setAttribute('data-id', node.id);
    g.setAttribute('transform', `translate(${pos.x}, ${pos.y})`);

    const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    rect.setAttribute('width', NODE_W);
    rect.setAttribute('height', NODE_H);
    rect.setAttribute('rx', 10);
    g.appendChild(rect);

    const nameText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    nameText.setAttribute('x', NODE_W / 2);
    nameText.setAttribute('y', node.subtitle ? 28 : 36);
    nameText.setAttribute('text-anchor', 'middle');
    nameText.textContent = node.name;
    g.appendChild(nameText);

    if (node.subtitle) {
      const subText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      subText.setAttribute('class', 'subtitle-text');
      subText.setAttribute('x', NODE_W / 2);
      subText.setAttribute('y', 46);
      subText.setAttribute('text-anchor', 'middle');
      subText.textContent = node.subtitle;
      g.appendChild(subText);
    }
    svg.appendChild(g);
  }

  svg.setAttribute('viewBox', `0 0 ${state.layout.width} ${state.layout.height}`);
}

async function load() {
  let raw;
  try {
    const res = await fetch('./flows.json');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    raw = await res.json();
  } catch (err) {
    showError(`Could not load flows.json: ${err.message}. Are you serving via http? Run ./serve-flows.sh`);
    return;
  }
  try {
    state.data = validateData(raw);
  } catch (err) {
    showError(err.message);
    return;
  }
  state.layout = computeLayout(state.data.nodes, state.data.actions);
  renderNodes();
  // Sidebar + edge rendering added in Task 6.
}

load();
```

- [ ] **Step 2: Manual verification — page loads with nodes visible**

Manual test:
1. Copy `flows.html` and `flows.json` to a temp directory:
   ```bash
   mkdir -p /tmp/flow-test
   cp skills/personal/state-visualization/template/flows.html /tmp/flow-test/
   cp skills/personal/state-visualization/template/flows.json /tmp/flow-test/
   cd /tmp/flow-test && python3 -m http.server 8766 &
   ```
2. Open `http://localhost:8766/flows.html` in a browser.
3. Verify: page renders with dark theme, 5 nodes laid out horizontally (auth, invites, email, db, billing), actions sidebar shows nothing yet (Task 6), detail panel shows "Select an action".
4. Stop server: `kill %1` (or `pkill -f "http.server 8766"`).

If nodes don't appear, open the browser devtools and check the console for errors before proceeding.

- [ ] **Step 3: Commit**

```bash
git add skills/personal/state-visualization/template/flows.html
git commit -m "Add JSON loading, validation, and node layout"
```

---

## Task 6: Add action sidebar, click-to-highlight, and detail panel

**Files:**
- Modify: `skills/personal/state-visualization/template/flows.html` (append to the renderer script)

- [ ] **Step 1: Add the interactive renderer code**

Replace the **entire `<script>` block** added in Task 5 (everything between `<script>` and `</script>` at the end of `<body>`, excluding the dagre CDN script tag) with the following. This supersedes Task 5's renderer:

```javascript
const NODE_W = 120;
const NODE_H = 60;
const PADDING = 20;

const state = {
  data: null,
  activeActionId: null,
  layout: null,
};

function showError(msg) {
  const el = document.getElementById('error');
  el.textContent = msg;
  el.style.display = 'block';
}

function validateData(data) {
  if (!data || typeof data !== 'object') {
    throw new Error('flows.json must be a JSON object');
  }
  const nodes = Array.isArray(data.nodes) ? data.nodes : [];
  const actions = Array.isArray(data.actions) ? data.actions : [];
  const nodeIds = new Set(nodes.map(n => n.id));
  for (const action of actions) {
    for (const edge of (action.edges || [])) {
      if (!nodeIds.has(edge.from)) {
        console.warn(`Action "${action.name}" edge references unknown node id "${edge.from}"`);
      }
      if (!nodeIds.has(edge.to)) {
        console.warn(`Action "${action.name}" edge references unknown node id "${edge.to}"`);
      }
    }
  }
  return { nodes, actions };
}

function computeLayout(nodes, actions) {
  const g = new dagre.graphlib.Graph();
  g.setGraph({ rankdir: 'LR', nodesep: 40, ranksep: 70, marginx: PADDING, marginy: PADDING });
  g.setDefaultEdgeLabel(() => ({}));
  for (const n of nodes) {
    g.setNode(n.id, { width: NODE_W, height: NODE_H });
  }
  const seen = new Set();
  for (const action of actions) {
    for (const edge of (action.edges || [])) {
      const key = `${edge.from}->${edge.to}`;
      if (!seen.has(key)) {
        seen.add(key);
        g.setEdge(edge.from, edge.to);
      }
    }
  }
  dagre.layout(g);

  const positions = {};
  let maxX = 0, maxY = 0;
  for (const id of g.nodes()) {
    const n = g.node(id);
    positions[id] = {
      x: n.x - NODE_W / 2,
      y: n.y - NODE_H / 2,
      cx: n.x,
      cy: n.y,
    };
    maxX = Math.max(maxX, n.x + NODE_W / 2);
    maxY = Math.max(maxY, n.y + NODE_H / 2);
  }
  return { positions, width: maxX + PADDING, height: maxY + PADDING };
}

function renderNodes() {
  const svg = document.getElementById('canvas');
  svg.querySelectorAll('g.node').forEach(el => el.remove());

  const { positions } = state.layout;
  for (const node of state.data.nodes) {
    const pos = positions[node.id];
    if (!pos) continue;
    const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    g.setAttribute('class', 'node');
    g.setAttribute('data-id', node.id);
    g.setAttribute('transform', `translate(${pos.x}, ${pos.y})`);

    const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    rect.setAttribute('width', NODE_W);
    rect.setAttribute('height', NODE_H);
    rect.setAttribute('rx', 10);
    g.appendChild(rect);

    const nameText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    nameText.setAttribute('x', NODE_W / 2);
    nameText.setAttribute('y', node.subtitle ? 28 : 36);
    nameText.setAttribute('text-anchor', 'middle');
    nameText.textContent = node.name;
    g.appendChild(nameText);

    if (node.subtitle) {
      const subText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      subText.setAttribute('class', 'subtitle-text');
      subText.setAttribute('x', NODE_W / 2);
      subText.setAttribute('y', 46);
      subText.setAttribute('text-anchor', 'middle');
      subText.textContent = node.subtitle;
      g.appendChild(subText);
    }
    svg.appendChild(g);
  }
  svg.setAttribute('viewBox', `0 0 ${state.layout.width} ${state.layout.height}`);
}

function renderSidebar() {
  const container = document.getElementById('actions');
  container.innerHTML = '';
  if (state.data.actions.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'empty-state';
    empty.textContent = 'No actions defined';
    container.appendChild(empty);
    return;
  }
  for (const action of state.data.actions) {
    const el = document.createElement('div');
    el.className = 'action-item';
    el.dataset.actionId = action.id;
    el.textContent = action.name;
    el.addEventListener('click', () => toggleAction(action.id));
    container.appendChild(el);
  }
}

function toggleAction(actionId) {
  if (state.activeActionId === actionId) {
    clearActive();
  } else {
    setActive(actionId);
  }
}

function clearActive() {
  state.activeActionId = null;
  document.querySelectorAll('.action-item').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('g.node').forEach(el => {
    el.classList.remove('active');
    el.classList.remove('inactive');
  });
  removeEdges();
  document.getElementById('detail').innerHTML = '<div class="empty-state">Select an action</div>';
}

function setActive(actionId) {
  const action = state.data.actions.find(a => a.id === actionId);
  if (!action) return;
  state.activeActionId = actionId;

  document.querySelectorAll('.action-item').forEach(el => {
    el.classList.toggle('active', el.dataset.actionId === actionId);
  });

  const involved = new Set();
  for (const edge of (action.edges || [])) {
    involved.add(edge.from);
    involved.add(edge.to);
  }
  document.querySelectorAll('g.node').forEach(el => {
    const id = el.getAttribute('data-id');
    if (involved.has(id)) {
      el.classList.add('active');
      el.classList.remove('inactive');
    } else {
      el.classList.add('inactive');
      el.classList.remove('active');
    }
  });

  renderEdges(action);
  renderDetail(action);
}

function removeEdges() {
  document.querySelectorAll('path.edge').forEach(el => el.remove());
}

function renderEdges(action) {
  removeEdges();
  const svg = document.getElementById('canvas');
  const { positions } = state.layout;
  for (const edge of (action.edges || [])) {
    const from = positions[edge.from];
    const to = positions[edge.to];
    if (!from || !to) continue;
    const x1 = from.cx + NODE_W / 2 * sign(to.cx - from.cx);
    const y1 = from.cy;
    const x2 = to.cx - NODE_W / 2 * sign(to.cx - from.cx);
    const y2 = to.cy;
    const mx = (x1 + x2) / 2;
    const d = `M ${x1} ${y1} C ${mx} ${y1}, ${mx} ${y2}, ${x2} ${y2}`;
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('class', 'edge' + (edge.async ? ' async' : ''));
    path.setAttribute('d', d);
    path.setAttribute('marker-end', 'url(#arrow)');
    svg.appendChild(path);
  }
}

function sign(n) { return n >= 0 ? 1 : -1; }

function renderDetail(action) {
  const el = document.getElementById('detail');
  el.innerHTML = '';
  const title = document.createElement('div');
  title.style.cssText = 'color:#fff;font-size:14px;font-weight:600;margin-bottom:6px';
  title.textContent = action.name;
  el.appendChild(title);

  if (action.description) {
    const desc = document.createElement('div');
    desc.style.cssText = 'color:var(--muted);font-size:12px;margin-bottom:14px';
    desc.textContent = action.description;
    el.appendChild(desc);
  }

  const edgesLabel = document.createElement('div');
  edgesLabel.className = 'label';
  edgesLabel.textContent = 'Edges';
  el.appendChild(edgesLabel);

  if (!action.edges || action.edges.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'empty-state';
    empty.textContent = 'No edges';
    el.appendChild(empty);
    return;
  }

  const list = document.createElement('div');
  list.className = 'edge-list';
  for (const edge of action.edges) {
    const item = document.createElement('div');
    item.className = 'edge-item';
    const ends = document.createElement('div');
    ends.className = 'ends';
    ends.innerHTML = `${escape(edge.from)} ${edge.async ? '⇢' : '→'} ${escape(edge.to)}`
      + (edge.async ? '<span class="async-tag">(async)</span>' : '');
    const code = document.createElement('code');
    code.textContent = edge.payload || '';
    item.appendChild(ends);
    item.appendChild(code);
    list.appendChild(item);
  }
  el.appendChild(list);
}

function escape(s) {
  const d = document.createElement('div');
  d.textContent = String(s);
  return d.innerHTML;
}

function setupKeyboard() {
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') clearActive();
  });
}

async function load() {
  let raw;
  try {
    const res = await fetch('./flows.json');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    raw = await res.json();
  } catch (err) {
    showError(`Could not load flows.json: ${err.message}. Are you serving via http? Run ./serve-flows.sh`);
    return;
  }
  try {
    state.data = validateData(raw);
  } catch (err) {
    showError(err.message);
    return;
  }
  state.layout = computeLayout(state.data.nodes, state.data.actions);
  renderNodes();
  renderSidebar();
  setupKeyboard();
}

load();
```

- [ ] **Step 2: Manual verification — full interactivity works**

Manual test:
1. Copy the updated `flows.html` to the temp dir and serve:
   ```bash
   cp skills/personal/state-visualization/template/flows.html /tmp/flow-test/
   cd /tmp/flow-test && python3 -m http.server 8766 &
   ```
2. Open `http://localhost:8766/flows.html`.
3. Verify:
   - Sidebar lists "Invite new user" and "Desktop build".
   - Click "Invite new user" → 4 edges appear (auth→invites, invites→email, invites→db, email→db dashed); billing fades; detail panel shows 4 edge rows with payloads.
   - Click "Invite new user" again → returns to neutral state.
   - Press `Esc` while active → returns to neutral.
   - Click "Desktop build" (empty edges) → detail panel shows "Edges / No edges" and no edges drawn.
4. Stop server: `pkill -f "http.server 8766"`.

If any step fails, open browser devtools and inspect `state.data` in the console.

- [ ] **Step 3: Commit**

```bash
git add skills/personal/state-visualization/template/flows.html
git commit -m "Add action selection, edge rendering, and detail panel"
```

---

## Task 7: Write `SKILL.md` body (invocation flow)

**Files:**
- Modify: `skills/personal/state-visualization/SKILL.md`

- [ ] **Step 1: Replace the body of SKILL.md**

Overwrite `skills/personal/state-visualization/SKILL.md` with:

```markdown
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
```

- [ ] **Step 2: Verify the file is well-formed**

Run:
```bash
head -4 skills/personal/state-visualization/SKILL.md
grep -c "^## " skills/personal/state-visualization/SKILL.md
```

Expected: frontmatter starts with `---` on line 1, and there is at least 1 `##` heading.

- [ ] **Step 3: Commit**

```bash
git add skills/personal/state-visualization/SKILL.md
git commit -m "Flesh out SKILL.md with scaffold invocation flow"
```

---

## Task 8: Register skill in `skills/personal/README.md`

**Files:**
- Modify: `skills/personal/README.md`

- [ ] **Step 1: Read current content**

Run:
```bash
cat skills/personal/README.md
```

Expected current content:
```
# Personal

Skills tied to my own setup, not promoted in the plugin.

- **[edit-article](./edit-article/SKILL.md)** — Edit and improve articles by restructuring sections, improving clarity, and tightening prose.
- **[obsidian-vault](./obsidian-vault/SKILL.md)** — Search, create, and manage notes in an Obsidian vault with wikilinks and index notes.
```

- [ ] **Step 2: Append the new entry**

The new list (in alphabetical order, matching the existing convention) should be:

```
- **[edit-article](./edit-article/SKILL.md)** — Edit and improve articles by restructuring sections, improving clarity, and tightening prose.
- **[obsidian-vault](./obsidian-vault/SKILL.md)** — Search, create, and manage notes in an Obsidian vault with wikilinks and index notes.
- **[state-visualization](./state-visualization/SKILL.md)** — Scaffold an interactive HTML page that visualizes workflows between packages/components, driven by a JSON document.
```

Use Edit tool to add only the new line at the end of the file.

- [ ] **Step 3: Verify**

Run:
```bash
grep -c "state-visualization" skills/personal/README.md
```

Expected: `1`

- [ ] **Step 4: Commit**

```bash
git add skills/personal/README.md
git commit -m "List state-visualization in personal skills index"
```

---

## Task 9: End-to-end verification

Simulate the skill being invoked in a fresh project directory and verify everything works.

- [ ] **Step 1: Create a fresh test directory**

```bash
TEST_DIR=$(mktemp -d)
echo "Test dir: $TEST_DIR"
```

- [ ] **Step 2: Manually replay the scaffold steps**

```bash
cp skills/personal/state-visualization/template/flows.html "$TEST_DIR/"
cp skills/personal/state-visualization/template/flows.json "$TEST_DIR/"
cp skills/personal/state-visualization/template/serve-flows.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/serve-flows.sh"
ls -l "$TEST_DIR/"
```

Expected: three files present, `serve-flows.sh` has executable bit.

- [ ] **Step 3: Start the server and open the page**

```bash
cd "$TEST_DIR" && ./serve-flows.sh 8767 &
SERVER_PID=$!
sleep 1
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8767/flows.html
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8767/flows.json
```

Expected: two `200` lines.

- [ ] **Step 4: Manual browser test**

Open `http://localhost:8767/flows.html` in a browser. Verify:

- The page renders with dark theme.
- Sidebar shows "Invite new user" and "Desktop build".
- Click "Invite new user" → highlighted subgraph + 4 edges + populated detail panel.
- Click again or press Esc → cleared.
- No errors in the browser console.

- [ ] **Step 5: Clean up**

```bash
kill $SERVER_PID 2>/dev/null
rm -rf "$TEST_DIR"
```

- [ ] **Step 6: Final commit (if any leftover changes)**

```bash
git status
```

Expected: clean working tree (everything already committed in previous tasks).

---

## Out of scope (v2 roadmap)

These are deliberately not part of v1, per the design spec. Do not include them in this plan's implementation:

- Pan/zoom on the graph canvas.
- Search box to filter actions.
- Action categorization or tags.
- Animation of tokens flowing along edges.
- Click-on-node cross-action highlight.
- Keyboard nav beyond `Esc`.
- Per-node `kind` field for color differentiation.
- Codebase scan to auto-suggest nodes.
