# lib/

Utilities, helpers, configs. Pure code with no domain or UI concerns.

## Rules

- **No React components.** This is not a place for JSX. Hooks that are generic (e.g. `useDebounce`, `useMediaQuery`) are fine.
- **No imports from `features/`, `components/ui/`, or `pages/`.** `lib/` sits at the bottom of the dependency graph.
- **Group by concern, not by type.** Prefer `lib/date/` over `lib/utils/`.

## Typical contents

- `cn.ts` — class name merging helper (clsx + tailwind-merge)
- `fetcher.ts` — base HTTP client / fetch wrapper
- `queryClient.ts` — React Query client config
- `env.ts` — typed environment variable parsing
- `date/` — date formatting / parsing helpers
- `constants.ts` — app-wide constants

## Test policy

Pure utilities here are the easiest things to unit-test. Keep them deterministic and side-effect-free.
