# Hero Pointer Ripple Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an interactive pointer-following ripple/distortion effect to the initial homepage hero surface.

**Architecture:** Keep the effect on the static homepage only. Add a duplicate, aria-hidden hero video layer clipped to a pointer-following circular lens; apply an SVG `feTurbulence` plus `feDisplacementMap` filter to that layer, and drive its position/strength with `pointermove` plus `requestAnimationFrame`. Disable it for reduced-motion users and non-hover/coarse-pointer devices.

**Tech Stack:** Eleventy/Nunjucks HTML, CSS custom properties, SVG filters, vanilla JavaScript.

---

### Task 1: Add Ripple Layer Markup

**Files:**
- Modify: `src/pages/index.html`

- [ ] **Step 1: Add a hidden SVG filter and duplicate hero video layer**

Insert this immediately after the base `.video-hero__media` video:

```html
  <svg class="video-hero__filter" aria-hidden="true" focusable="false">
    <filter id="hero-surface-displacement" x="-20%" y="-20%" width="140%" height="140%" color-interpolation-filters="sRGB">
      <feTurbulence type="turbulence" baseFrequency="0.018 0.028" numOctaves="2" seed="7" result="heroRippleNoise" />
      <feDisplacementMap id="hero-ripple-displacement" in="SourceGraphic" in2="heroRippleNoise" scale="0" xChannelSelector="R" yChannelSelector="G" />
    </filter>
  </svg>
  <div class="video-hero__ripple" aria-hidden="true">
    <video class="video-hero__ripple-media" muted loop playsinline preload="metadata" tabindex="-1">
      <source src="https://website.lunaapp.io/homepage-background.mp4" type="video/mp4">
    </video>
  </div>
```

Expected: the layer exists only for visual effect and is hidden from assistive technology.

### Task 2: Style the Ripple Lens

**Files:**
- Modify: `public/styles/home.css`
- Modify: `public/styles/responsive.css`

- [ ] **Step 1: Add base ripple styles**

Add rules that place the duplicate video over the base video, clip it to a pointer-following circle, apply `filter: url("#hero-surface-displacement")`, and add subtle radial highlight/ring shading through `::before` and `::after`.

- [ ] **Step 2: Respect reduced motion**

Add a reduced-motion rule that hides `.video-hero__ripple` and `.video-hero__filter`.

Expected: users who prefer reduced motion do not get the pointer-driven effect.

### Task 3: Drive the Effect With Pointer Motion

**Files:**
- Modify: `public/scripts/home.js`

- [ ] **Step 1: Sync duplicate video playback**

Update `syncHeroVideoMotion()` so it starts/pauses both `.video-hero__media` and `.video-hero__ripple-media`, keeping the duplicate video close to the base video's current time.

- [ ] **Step 2: Add pointer-driven animation**

Add a `setupHeroSurfaceRipple()` function that:

```js
const supportsFinePointer = window.matchMedia("(hover: hover) and (pointer: fine)");
```

Only initialize when the hero, ripple layer, and displacement map exist, reduced motion is not active, and a fine pointer is available. Use `pointermove`, `pointerenter`, and `pointerleave` on `.video-hero`, store target pointer data, and update CSS variables plus the displacement map scale inside `requestAnimationFrame`.

Expected: moving the mouse over the first hero creates a clipped surface ripple that follows the cursor and fades out after leave.

### Task 4: Verify and Publish

**Files:**
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Build and static checks**

Run:

```bash
npm run build
git diff --check
bash -n .codex/scripts/launch-website.sh
```

Expected: build succeeds and checks pass.

- [ ] **Step 2: Browser evidence**

Serve `dist` locally and open `http://127.0.0.1:8080/`. Verify desktop pointer movement over the initial hero updates the ripple lens, the mobile viewport has no horizontal overflow, and no browser-visible layout break appears.

- [ ] **Step 3: Commit and push**

Run:

```bash
git add src/pages/index.html public/styles/home.css public/styles/responsive.css public/scripts/home.js docs/plans/2026-06-02-hero-pointer-ripple.md
git commit -m "Add hero pointer ripple effect"
git fetch origin main
git merge-tree --write-tree HEAD origin/main
git push
```

Expected: the implementation is pushed to the current branch.
