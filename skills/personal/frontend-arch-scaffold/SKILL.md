---
name: frontend-arch-scaffold
description: Scaffold the initial folder architecture of a React + Vite frontend project — features/, components/ui/, lib/, pages/ with per-folder READMEs and an ESLint boundaries config that blocks cross-feature imports. Use when starting a new React project or when the user asks to set up the folder structure / module layout for the frontend.
---

# frontend-arch-scaffold

Scaffold the canonical folder layout for a React + Vite frontend, with each feature treated as a self-contained module.

## Target architecture

```
src/
├── features/             # bounded contexts (one domain per folder)
│   └── <feature>/
│       ├── components/   # feature-local components
│       ├── hooks/        # feature-local hooks
│       ├── api/          # data fetching / mutations
│       ├── stores/       # feature-local state (zustand, jotai, etc.)
│       ├── types.ts
│       └── index.ts      # public API — export only what other layers need
├── components/ui/        # shared UI primitives (Button, Input, Dialog…)
├── lib/                  # utilities, helpers, configs
└── pages/                # thin routing layer — compose feature components, no logic
```

### Import rules (enforced by ESLint boundaries)

- `features/` → `components/ui/`, `lib/` ✓
- `features/` → other `features/` ✗ (never cross-import)
- `pages/` → `features/`, `components/ui/`, `lib/` ✓ (composition only)
- `components/ui/` → `components/ui/`, `lib/` ✓
- `lib/` → `lib/` ✓

## Scaffold flow

### 1. Confirm destination

Ask the user where to scaffold. Default is `<cwd>/src`.

> "Scaffold `features/`, `components/ui/`, `lib/`, `pages/` under `<cwd>/src`? Or another path?"

Create the target directory with `mkdir -p` if needed.

### 2. Check for conflicts

For each of the four top-level folders, check whether it already exists. If yes, ask the user separately whether to overwrite its README:

> "`src/features/` already exists. Overwrite its `README.md`? (The folder itself is kept.)"

Never delete existing source files.

### 3. Create folders + READMEs

Create the four folders if missing. For each, copy the matching template from `templates/` into the folder as `README.md`:

| Folder              | Template                       |
| ------------------- | ------------------------------ |
| `src/features/`     | `templates/features.md`        |
| `src/components/ui/`| `templates/components-ui.md`   |
| `src/lib/`          | `templates/lib.md`             |
| `src/pages/`        | `templates/pages.md`           |

Also place `templates/feature-module.md` at `src/features/_TEMPLATE.md` so it's available as a reference when adding new features.

### 4. ESLint boundaries config

Detect whether the project uses flat config (`eslint.config.js`) or legacy (`.eslintrc.*`).

- If neither exists, ask whether to create `eslint.config.js`.
- If one exists, do not overwrite. Print the relevant snippet from `templates/eslint-boundaries.md` and instruct the user to merge it.
- Remind the user to install: `pnpm add -D eslint-plugin-boundaries` (or npm/yarn equivalent — ask which package manager).

### 5. Final instructions

Print:

> Scaffolded:
> - `src/features/`, `src/components/ui/`, `src/lib/`, `src/pages/` with READMEs
> - `src/features/_TEMPLATE.md` (reference for new feature modules)
> - ESLint boundaries config (or merge snippet)
>
> Next steps:
> 1. Install the boundaries plugin (see above).
> 2. Add a tsconfig path alias `@/*` → `src/*` if not already configured.
> 3. When adding a new feature, copy the `_TEMPLATE.md` structure and expose only what's needed via `index.ts`.

## What this skill does NOT do

- No code generation for actual features or components — only the folder skeleton.
- No tsconfig editing (alias setup is a suggestion, not automated).
- No router setup — the `pages/` convention assumes the user wires routing themselves.
- No package install — the user runs the package manager command.
