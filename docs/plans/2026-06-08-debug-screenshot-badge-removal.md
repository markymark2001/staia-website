# Debug Screenshot Badge Removal Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the visible DEBUG badge from the shared public app screenshot.

**Architecture:** Keep the existing screenshot asset path so all templates continue to reference `/assets/hero-app-screenshot.png`. Patch only the top-right badge region of the PNG, replacing the triangular debug overlay with a dark sampled app-background color.

**Tech Stack:** PNG asset edit, Python standard library, Eleventy build, browser evidence.

---

### Task 1: Patch Screenshot Asset

**Files:**
- Modify: `public/assets/hero-app-screenshot.png`

- [ ] **Step 1: Confirm asset usage**

Run:

```bash
rg -n "hero-app-screenshot" src public
```

Expected: the asset is used by the homepage and shared footer CTA.

- [ ] **Step 2: Remove the top-right debug badge**

Use a standard-library PNG rewrite to replace the top-right triangular badge pixels with a dark background color sampled from nearby app chrome.

Expected: `public/assets/hero-app-screenshot.png` no longer shows the red DEBUG ribbon.

### Task 2: Verify Asset

**Files:**
- Verify: `public/assets/hero-app-screenshot.png`
- Verify: `src/pages/index.html`
- Verify: `src/_includes/partials/footer-cta.njk`

- [ ] **Step 1: Inspect the edited image**

Open `public/assets/hero-app-screenshot.png` locally and verify the top-right corner has no red DEBUG badge.

- [ ] **Step 2: Rebuild**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully and copies the edited asset to `dist/assets/hero-app-screenshot.png`.

- [ ] **Step 3: Browser-check visible pages**

Serve `dist`, open the homepage in the Codex browser, and verify the footer CTA screenshot renders without the DEBUG badge.
