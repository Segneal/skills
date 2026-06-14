---
name: svg-path-animator
description: Animate SVG paths — self-drawing line/stroke effects, morphing one shape into another, and moving elements along a path. Use when the user wants to animate an SVG, make a line "draw itself", build a signature/logo/icon draw-on animation, morph between shapes, animate stroke-dashoffset, or move something along an SVG path.
---

# SVG Path Animator

Pick the technique by **what you're animating**, then copy the recipe. Full details, library APIs, and gotchas live in [REFERENCE.md](REFERENCE.md) — read it before reaching for a library or hitting an edge case.

## Pick a technique

- **Line/stroke draws itself** → §1 below (the dasharray trick). 90% of requests.
- **Shape A turns into shape B (morph)** → [REFERENCE.md](REFERENCE.md) §6.
- **An element travels along a path** → [REFERENCE.md](REFERENCE.md) §7 (`offset-path`).
- **Designer handed you an After Effects animation** → Lottie, [REFERENCE.md](REFERENCE.md) §8.

## 1. The self-drawing line (the core recipe)

A stroke can render as a dash pattern. Make **one dash as long as the whole path**, then slide it on/off with `stroke-dashoffset`. Offset = length → hidden; offset = 0 → fully drawn. Animating offset down to 0 "draws" the line.

**Most portable version — CSS only, no JS, works on any path size.** Use the `pathLength="1"` attribute to normalize the path to length 1, so dash math is just fractions:

```html
<svg viewBox="0 0 200 100">
  <path class="draw" d="M10,80 Q95,10 180,80" pathLength="1"
        fill="none" stroke="#222" stroke-width="3" />
</svg>
```
```css
.draw {
  stroke-dasharray: 1;
  stroke-dashoffset: 1;            /* start hidden */
  animation: draw 2s ease-in-out forwards;
}
@keyframes draw { to { stroke-dashoffset: 0; } }   /* end fully drawn */

@media (prefers-reduced-motion: reduce) {
  .draw { animation: none; stroke-dashoffset: 0; }  /* show drawn, no motion */
}
```

Always include the `prefers-reduced-motion` block.

**Need to measure precisely / drive from JS** (e.g. couple to scroll) → use `getTotalLength()` + Web Animations API. See [REFERENCE.md](REFERENCE.md) §2, §4.

**Must animate inside `<img src="x.svg">`** (CSS/JS can't reach it) → SMIL `<animate>`. See [REFERENCE.md](REFERENCE.md) §5.

## Before you ship — quick checks

- Is the artwork a **stroke**, not a **fill**? The dash trick only reveals strokes. Filled logos/icons need a stroke added, or a clip-path/mask wipe, or a library. ([REFERENCE.md](REFERENCE.md) §9)
- Does `d` have **multiple subpaths** (`M ... M ...`) or many `<path>` elements? They animate in parallel, not in sequence — split + stagger delays. ([REFERENCE.md](REFERENCE.md) §9)
- Using `stroke-linecap: round/square`? It distorts dash math — use `butt` for pixel-accurate draws. ([REFERENCE.md](REFERENCE.md) §9)
- Rotating/scaling the path and it "flies off screen"? SVG `transform-origin` defaults to (0,0) — set `transform-box: fill-box; transform-origin: center`. ([REFERENCE.md](REFERENCE.md) §9)

## Worked example

[`demo.html`](demo.html) is a runnable, self-contained page (open it via any static server, e.g. `python3 -m http.server`). It shows the advanced case: a single thread that weaves **behind** zigzag images and, on arrival at each one, **draws itself into a medical icon** (stethoscope → bag → heart). Techniques on display: per-segment scroll scrubbing (each connector/icon gets its own slice of the scroll timeline, so multiple subpaths draw in sequence instead of in parallel), a head dot riding the tip via `getPointAtLength()`, DOM-driven geometry (`viewBox` = real pixel size, icons centred on measured image positions), and two stacked SVG layers (connectors behind cards, icons in front).

## Libraries — only when CSS isn't enough

GSAP (free since 2025) for pro line-drawing (`DrawSVGPlugin`) and best-in-class morphing of arbitrary shapes (`MorphSVGPlugin`); anime.js v4 for a lightweight all-rounder; Vivus.js for tiny draw-only; Lottie for After Effects exports. Full comparison + snippets in [REFERENCE.md](REFERENCE.md) §8.
