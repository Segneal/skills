# components/ui/

Shared UI primitives — the building blocks every feature uses. Think `Button`, `Input`, `Dialog`, `Tooltip`, `Card`.

## Rules

- **No domain knowledge.** A primitive doesn't know about users, billing, workspaces, etc. If it takes a `User` prop, it belongs in a feature.
- **No imports from `features/`.** Primitives sit below features in the dependency graph.
- **May import from `lib/`** for utilities (e.g. `cn()` for class merging).
- **May import from other primitives** (e.g. `Dialog` uses `Button`).

## What goes here

- Design-system primitives (Button, Input, Select, Checkbox, Dialog, Popover…)
- Layout helpers that aren't tied to a domain (Stack, Grid, Container)
- Wrappers around third-party UI libs (e.g. shadcn-style re-exports)

## What does NOT go here

- Anything domain-specific (`UserAvatar`, `InvoiceRow`) — those live in their feature.
- Page layouts — those live in `pages/` or a top-level `layouts/`.
