# Feature module template

Reference for adding a new feature under `features/`. Treat each feature as a self-contained module.

## Layout

```
<feature>/
├── components/   # feature-local components — not consumed outside the feature
│   └── <Component>.tsx
├── hooks/        # feature-local hooks (useX, useY)
│   └── use<X>.ts
├── api/          # data layer — fetchers, mutations, React Query keys
│   ├── queries.ts
│   └── mutations.ts
├── stores/       # feature-local state (only if you actually need it)
│   └── <feature>Store.ts
├── types.ts      # domain types for this feature
└── index.ts      # public API
```

Only create the folders you actually use. A read-only feature probably has no `stores/`. A feature without local state probably has no `hooks/`.

## `index.ts` — the public API

```ts
// features/billing/index.ts
export { BillingOverview } from './components/BillingOverview'
export { useBillingSummary } from './hooks/useBillingSummary'
export type { Invoice } from './types'
```

Export only what other layers (pages, occasionally other UI shells) need to consume. Everything else stays private.

## Checklist when creating a feature

- [ ] Folder name is the domain noun (e.g. `billing`, not `billingFeature` or `BillingModule`).
- [ ] All cross-layer imports go through `./index.ts` from the outside.
- [ ] No imports from sibling features. If shared, lift to `lib/` or `components/ui/`.
- [ ] No `useEffect` for derived state or syncing — reconsider the design.
- [ ] No `enum` — use union of string literals or `as const` objects.
- [ ] Page that uses this feature is a thin composition layer.
