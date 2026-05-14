# pages/

Thin routing layer. One file per route. Pages compose feature components and pass route params — they hold no business logic.

## Rules

- **No logic.** No data fetching, no state, no transformations. If you find yourself writing a hook in a page, that hook belongs in a feature.
- **Compose, don't build.** A page should mostly be JSX assembling feature components.
- **Read route params, pass them down.** Anything beyond reading params/search is suspicious.
- **May import from `features/`, `components/ui/`, `lib/`.** Never the reverse.

## Anatomy of a good page

```tsx
// pages/workspaces/[id]/billing.tsx
import { BillingOverview } from '@/features/billing'
import { PageShell } from '@/components/ui'

export default function BillingPage() {
  const { id } = useParams()
  return (
    <PageShell title="Billing">
      <BillingOverview workspaceId={id} />
    </PageShell>
  )
}
```

If a page grows beyond ~30 lines or starts importing hooks/utilities directly, the logic has leaked out of a feature — pull it back.
