# features/

Bounded contexts. Each subfolder is a self-contained module for one domain (e.g. `auth/`, `billing/`, `workspaces/`).

## Module structure

```
<feature>/
├── components/   # feature-local components (not reused outside)
├── hooks/        # feature-local hooks
├── api/          # data fetching / mutations (React Query, fetch wrappers)
├── stores/       # feature-local state (zustand, jotai, context)
├── types.ts      # domain types
└── index.ts      # public API — only export what other layers consume
```

## Rules

- **No cross-feature imports.** A feature must not import from another feature. If two features need to share something, lift it to `lib/` or `components/ui/`.
- **`index.ts` is the public API.** Export the minimum surface (usually a couple of components and hooks). Everything else stays private to the module.
- **Pages compose features, never the other way around.** Features must not know about pages or routes.
- **UI primitives come from `components/ui/`.** Don't reinvent Button, Input, Dialog inside a feature.

## Adding a new feature

Copy the layout in `_TEMPLATE.md` as a checklist. Most features won't need every folder — only create what you actually use.
