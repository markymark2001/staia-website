# Media Query Listener Fallback Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep homepage initialization from aborting on browsers that expose `MediaQueryList.addListener` but not `addEventListener`.

**Architecture:** Add one helper for reduced-motion media query subscriptions. Prefer the modern `addEventListener("change", ...)` API when available, and fall back to legacy `addListener(...)` for older Safari/iOS behavior.

**Tech Stack:** Browser JavaScript, MediaQueryList compatibility, Eleventy static build.

---

### Task 1: Add Listener Fallback

**Files:**
- Modify: `public/scripts/home.js`

- [ ] **Step 1: Replace direct listener call**

Replace:

```js
reducedMotion.addEventListener("change", syncHeroVideoMotion);
```

with:

```js
if (typeof reducedMotion.addEventListener === "function") {
  reducedMotion.addEventListener("change", syncHeroVideoMotion);
} else if (typeof reducedMotion.addListener === "function") {
  reducedMotion.addListener(syncHeroVideoMotion);
}
```

Expected: older browsers can register the listener without throwing, and browsers without either API continue initializing the header behavior.

### Task 2: Verify

**Files:**
- Verify: `public/scripts/home.js`

- [ ] **Step 1: Build**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully.

- [ ] **Step 2: Compatibility smoke**

Run a small Node script that loads `public/scripts/home.js` with a fake `matchMedia` object that has `addListener` but no `addEventListener`.

Expected: the script does not throw and scroll/resize listeners are registered.

- [ ] **Step 3: Browser smoke**

Open the homepage from local `dist` in the Codex browser and verify there are no console errors.
