# SVG Path Animation — Reference

Detailed techniques behind [SKILL.md](SKILL.md). Every section has a copy-pasteable snippet.

## 1. The line-drawing trick — how `stroke-dasharray` + `stroke-dashoffset` works

A stroke can be rendered as a dash pattern:

- **`stroke-dasharray`** — the repeating dash/gap pattern. `20` = 20px dash, 20px gap. `20 5` = 20px dash, 5px gap.
- **`stroke-dashoffset`** — shifts where the pattern *starts* along the path.

The trick: set `stroke-dasharray` to **one value equal to the total path length**. The path now holds one dash covering the whole stroke followed by an equally long gap (off the end) — it looks solid. Set `stroke-dashoffset` to that same length and the dash slides entirely off, leaving the gap over the visible region — the line disappears. Animate `stroke-dashoffset` from `length` → `0` and the dash slides back in, "drawing" the line end to end.

> Mnemonic: dasharray makes one dash the size of the whole line; dashoffset slides it on/off. Offset = length → hidden; offset = 0 → drawn.

```css
.path {
  stroke-dasharray: 1000;   /* >= the path's real length */
  stroke-dashoffset: 1000;  /* start hidden */
  animation: dash 5s linear forwards;
}
@keyframes dash { to { stroke-dashoffset: 0; } }
```

**Closed-path caveat** (from the CSS-Tricks article): browsers interpret `stroke-dashoffset` inconsistently on closed paths when the dash pattern is twice the path length. More robust alternative — animate `stroke-dasharray` itself:

```css
@keyframes dash {
  from { stroke-dasharray: 0 1000; }   /* zero dash, full gap → invisible */
  to   { stroke-dasharray: 1000 0; }   /* full dash, no gap → solid */
}
```

Source: [How SVG Line Animation Works — CSS-Tricks](https://css-tricks.com/svg-line-animation-works/)

## 2. Getting the path length

**A. `getTotalLength()` in JS** — on any `SVGGeometryElement` (`path`, `line`, `circle`…):

```js
const path = document.querySelector(".path");
const length = path.getTotalLength();
path.style.strokeDasharray = length;
path.style.strokeDashoffset = length;
```

**B. `pathLength` attribute — normalize, no JS.** Tells the browser to pretend the path is a given length; all stroke math scales by `pathLength / realLength`. Set `pathLength="1"` and every dash value is a **fraction of the whole path** — the cleanest CSS-only approach, works for any path size. Supported on `circle`, `ellipse`, `line`, `path`, `polygon`, `polyline`, `rect`.

```html
<path d="M10,80 Q95,10 180,80" pathLength="1"
      fill="none" stroke="black" stroke-width="3"
      stroke-dasharray="1" stroke-dashoffset="1" />
```

Source: [MDN — pathLength](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/pathLength)

## 3. CSS approach (keyframes, hover, easing, reduced-motion)

Keyframe draw (with normalized `pathLength="1"`):

```css
.draw { stroke-dasharray: 1; stroke-dashoffset: 1; animation: draw 2s ease-in-out forwards; }
@keyframes draw { to { stroke-dashoffset: 0; } }
```

Draw on hover (transition, not animation):

```css
.draw { stroke-dasharray: 1; stroke-dashoffset: 1; transition: stroke-dashoffset 1s ease-out; }
.draw:hover { stroke-dashoffset: 0; }
```

Reduced motion — present the final state instantly:

```css
@media (prefers-reduced-motion: reduce) {
  .draw { animation: none; transition: none; stroke-dashoffset: 0; }
}
```

## 4. JS approach (Web Animations API + requestAnimationFrame)

**WAAPI** — same engine as CSS, but you can measure length first:

```js
const path = document.querySelector(".path");
const len = path.getTotalLength();
path.style.strokeDasharray = len;
path.animate(
  [{ strokeDashoffset: len }, { strokeDashoffset: 0 }],
  { duration: 2000, easing: "ease-in-out", fill: "forwards" }
);
```

**requestAnimationFrame** — when progress couples to scroll/input/physics:

```js
const path = document.querySelector(".path");
const len = path.getTotalLength();
path.style.strokeDasharray = len;
const duration = 2000;
let start;
function frame(now) {
  if (!start) start = now;
  const t = Math.min((now - start) / duration, 1);
  path.style.strokeDashoffset = len * (1 - t);   // len → 0
  if (t < 1) requestAnimationFrame(frame);
}
requestAnimationFrame(frame);
```

## 5. SMIL `<animate>` — native in-SVG animation

```html
<svg viewBox="0 0 200 100">
  <path d="M10,80 Q95,10 180,80" pathLength="1"
        fill="none" stroke="#222" stroke-width="3"
        stroke-dasharray="1" stroke-dashoffset="1">
    <animate attributeName="stroke-dashoffset" from="1" to="0" dur="2s" fill="freeze" />
  </path>
</svg>
```

**Pros:** self-contained — the only approach that animates inside `<img src="...svg">` (CSS/JS can't reach there). No dependencies. Can morph `d` (§6) and move along paths (§7).
**Cons / status:** verbose; harder to sync with app state. **Not deprecated** — Chrome's 2015 deprecation was reversed; supported in all current browsers (never in IE/legacy Edge). Prefer CSS/WAAPI for new work; use SMIL for its unique capabilities.

Source: [Chromium "Intent to deprecate: SMIL" (reversed)](https://groups.google.com/a/chromium.org/g/blink-dev/c/5o0yiO440LM/m/YGEJBsjUAwAJ)

## 6. Morphing between paths (animating `d`)

The governing constraint: smooth morphing is pairwise point interpolation, well-defined only when both paths have the **same number and type of commands, in the same order**.

**Native CSS `d` property** — both `path()` values must use the identical command sequence. **Safari does NOT support it** (WebKit bug 234227); needs a fallback:

```css
@keyframes morph {
  from { d: path("M10,50 L50,10 L90,50 Z"); }
  to   { d: path("M10,90 L50,50 L90,90 Z"); }
}
path { d: path("M10,50 L50,10 L90,50 Z"); animation: morph 2s ease-in-out infinite alternate; }
```

**Native SMIL** `<animate attributeName="d">` — same constraint, but **works in Safari**:

```html
<path d="M10,50 L50,10 L90,50 Z" fill="tomato">
  <animate attributeName="d" dur="2s" repeatCount="indefinite"
    values="M10,50 L50,10 L90,50 Z; M10,90 L50,50 L90,90 Z; M10,50 L50,10 L90,50 Z" />
</path>
```

**Libraries** (handle *different* point counts automatically — convert to béziers, subdivide, match points):

- **GSAP MorphSVGPlugin** — `gsap.to("#circle", { duration: 1, morphSVG: "#star" });` Options: `shapeIndex`, `type:"rotational"`, `map`.
- **anime.js v4** — `animate($el, { points: svg.morphTo($target, precision), duration: 500 });`
- **Flubber** — rendering-agnostic, returns the in-between string: `const i = interpolate(dA, dB); i(0.5);` Best for arbitrary shapes; also `toCircle`, `separate`, `combine`.
- **SVG.js** (`svg.pathmorphing.js`) — `path.animate().plot("M100 0 H190 V90 H100 Z");`

Sources: [MDN CSS `d`](https://developer.mozilla.org/en-US/docs/Web/CSS/d), [GSAP MorphSVG](https://gsap.com/docs/v3/Plugins/MorphSVGPlugin/), [Flubber](https://github.com/veltman/flubber)

## 7. Motion along a path (move an element along a track)

**CSS Motion Path — `offset-path`** (Baseline: Chrome/Edge 55+, Firefox 72+, Safari 15.1+):

```css
.dot {
  offset-path: path("M50,50 Q300,50 500,200 T50,350");
  offset-rotate: auto;          /* face direction of travel */
  animation: move 8s linear infinite;
}
@keyframes move { from { offset-distance: 0%; } to { offset-distance: 100%; } }
```

`offset-path` also accepts `url(#svgPathId)`, basic shapes, or `ray()`. `offset-anchor` sets which point of the element rides the path.

**SMIL `<animateMotion>` + `<mpath>`:**

```html
<path id="track" fill="none" stroke="#ccc" d="M20,50 C20,-50 180,150 180,50" />
<circle r="5" fill="red">
  <animateMotion dur="10s" repeatCount="indefinite" rotate="auto"><mpath href="#track" /></animateMotion>
</circle>
```

`rotate="auto"` orients to path direction. Default `calcMode` is `paced` (constant speed). `keyPoints`+`keyTimes` control non-uniform pacing.

Sources: [MDN offset-path](https://developer.mozilla.org/en-US/docs/Web/CSS/offset-path), [MDN animateMotion](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateMotion)

## 8. Libraries — what each is best for

| Library | Best for | Status (2026) |
|---|---|---|
| **GSAP — DrawSVGPlugin** | Pro timeline-driven line drawing (tweens dasharray/offset for you). | **Free since Apr 2025**, commercial OK. |
| **GSAP — MorphSVGPlugin** | Best-in-class morphing of arbitrary shapes / different point counts. | Free. |
| **anime.js v4** | Lightweight ESM all-rounder (draw, morph, motion). | Current = v4 (`import { animate, svg }`). |
| **Vivus.js** | One job: zero-dep self-drawing strokes. | Frozen (v0.4.6, 2021); still works. |
| **Snap.svg** | Imperative SVG building/manipulation. | Largely unmaintained — avoid for new work. |
| **Lottie (lottie-web)** | Playing After Effects animations exported to JSON (Bodymovin). | Active, de-facto standard. |

```js
// GSAP DrawSVG — target must have a visible stroke (animates strokes, not fills)
gsap.registerPlugin(DrawSVGPlugin);
gsap.from(".draw-me", { duration: 2, drawSVG: "0%", ease: "power1.inOut" });

// anime.js v4
import { animate, svg } from "animejs";
animate(svg.createDrawable(".line"), { draw: ["0 0", "0 1"], duration: 2000 });

// Vivus
new Vivus("my-svg-id", { type: "delayed", duration: 200 });
```

**Decision guide:** everything + top performance → GSAP. Lightweight & code-driven → anime.js v4. Only line drawing, tiny → Vivus. Designer-authored AE motion → Lottie.

Source: [GSAP now free — CSS-Tricks](https://css-tricks.com/gsap-is-now-completely-free-even-for-commercial-use/)

## 9. Common gotchas

- **`stroke-linecap` distorts dash math.** `round`/`square` add a cap (half a stroke-width) at each dash end, so a one-dash-equals-path setup can overshoot or look off. Use `stroke-linecap: butt` for pixel-accurate draws. (Inverse trick: `stroke-dasharray: 0 20; stroke-linecap: round;` makes dotted lines.)
- **`vector-effect: non-scaling-stroke`** keeps stroke width constant under transforms, but its interaction with `stroke-dasharray`/`dashoffset` is spec-ambiguous — dash-based draws may render differently across browsers. Test across engines.
- **`transform-origin` differs in SVG.** It defaults to the SVG user-space origin (0,0), not the element's center — rotations/scales "fly off." Set `transform-box: fill-box; transform-origin: center`.
- **Performance.** `stroke-dashoffset` and `d` are *not* GPU-compositable — main-thread paint each frame. Fine for a few small paths; many/large paths can jank. Prefer `opacity`/`transform` where the effect allows; keep point counts modest.
- **Multiple subpaths.** A `d` with several `M` commands, or many separate `<path>` elements, all get the *same* dash pattern → they draw in parallel, not in sequence. Split into separate elements and stagger animation delays (or use Vivus, which sequences them).
- **Fills vs strokes.** The dash trick only reveals **strokes**. Filled icons/logos have no stroke — add a stroke and animate it, reveal the fill with a `clip-path`/mask wipe, or use GSAP/Lottie.

Sources: [MDN vector-effect](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/vector-effect), [O'Reilly *Using SVG* ch.13 — Strokes](https://oreillymedia.github.io/Using_SVG/ch13-strokes-files/)
