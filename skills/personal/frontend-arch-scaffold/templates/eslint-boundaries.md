# ESLint boundaries config

Uses [`eslint-plugin-boundaries`](https://github.com/javierbrea/eslint-plugin-boundaries) to enforce the dependency graph.

## Install

```bash
pnpm add -D eslint-plugin-boundaries
```

## Flat config (`eslint.config.js`)

```js
import boundaries from 'eslint-plugin-boundaries'

export default [
  {
    plugins: { boundaries },
    settings: {
      'boundaries/elements': [
        { type: 'feature', pattern: 'src/features/*' },
        { type: 'ui',      pattern: 'src/components/ui/**' },
        { type: 'lib',     pattern: 'src/lib/**' },
        { type: 'page',    pattern: 'src/pages/**' },
      ],
    },
    rules: {
      'boundaries/element-types': ['error', {
        default: 'disallow',
        rules: [
          { from: 'feature', allow: ['ui', 'lib'] },
          { from: 'page',    allow: ['feature', 'ui', 'lib'] },
          { from: 'ui',      allow: ['ui', 'lib'] },
          { from: 'lib',     allow: ['lib'] },
        ],
      }],
      'boundaries/no-private': ['error', { allowUncles: false }],
    },
  },
]
```

## Legacy config (`.eslintrc.cjs`)

```js
module.exports = {
  plugins: ['boundaries'],
  extends: ['plugin:boundaries/recommended'],
  settings: {
    'boundaries/elements': [
      { type: 'feature', pattern: 'src/features/*' },
      { type: 'ui',      pattern: 'src/components/ui/**' },
      { type: 'lib',     pattern: 'src/lib/**' },
      { type: 'page',    pattern: 'src/pages/**' },
    ],
  },
  rules: {
    'boundaries/element-types': ['error', {
      default: 'disallow',
      rules: [
        { from: 'feature', allow: ['ui', 'lib'] },
        { from: 'page',    allow: ['feature', 'ui', 'lib'] },
        { from: 'ui',      allow: ['ui', 'lib'] },
        { from: 'lib',     allow: ['lib'] },
      ],
    }],
  },
}
```

## What this enforces

- `features/*` can only reach `components/ui/`, `lib/` — no sibling features.
- `pages/*` may compose features and primitives but cannot be imported back from.
- `components/ui/*` cannot pull in feature code or pages.
- `lib/*` is the leaf — it can't import from anything above it.
- Anything not in the table defaults to **disallow**, so accidental imports fail loudly.

## Bypassing (use sparingly)

If a single import legitimately violates the rule, prefer per-line `// eslint-disable-next-line boundaries/element-types` with a comment explaining why — never disable the rule globally.
