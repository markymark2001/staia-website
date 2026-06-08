# Review Responsive And Heading Fixes Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve review findings for the tablet CTA phone preview and Jobs page heading structure.

**Architecture:** Keep the existing CTA desktop and mobile designs, but move the CTA-only stacked layout to a wider breakpoint so tablet widths do not keep an absolute phone preview with too little space. Preserve Jobs page content and routing while making the visible page title the page-level heading.

**Tech Stack:** Static HTML, CSS media queries, Eleventy build, local HTTP verification.

---

### Task 1: Fix CTA Tablet Layout

**Files:**
- Modify: `public/styles/responsive.css`

- [ ] **Step 1: Add a CTA-only tablet breakpoint**

Insert this breakpoint before the existing `@media (max-width: 720px)` block:

```css
@media (max-width: 900px) {
  .download-cta {
    padding: 56px 0;
  }

  .download-cta__inner {
    grid-template-columns: 1fr;
    min-height: 0;
    gap: var(--space-6);
    padding: 44px 24px 0;
    text-align: center;
  }

  .download-cta__copy {
    justify-items: center;
    width: 100%;
    max-width: 100%;
    min-width: 0;
  }

  .download-cta h2 {
    max-width: 100%;
    font-size: clamp(31px, 8.5vw, 36px);
  }

  .download-cta__actions,
  .download-cta__meta {
    justify-content: center;
    max-width: 100%;
  }

  .download-cta__actions {
    align-items: center;
  }

  .download-cta__meta {
    flex-wrap: wrap;
    row-gap: 8px;
  }

  .download-cta__preview .download-cta__device {
    width: min(280px, 76vw);
    transform: translateY(24%);
  }

  .download-cta__preview {
    position: relative;
    inset: auto;
    justify-content: center;
    margin-top: -8px;
    margin-left: 0;
    width: 100%;
    max-height: 440px;
    overflow: hidden;
  }
}
```

Expected: at 768px, the CTA uses the stacked layout and the phone preview remains visible.

- [ ] **Step 2: Remove duplicated CTA mobile rules**

Remove the duplicate `.download-cta` rules from the `@media (max-width: 720px)` block, leaving only the narrower device override already present near the end of that block:

```css
.download-cta .download-cta__device {
  width: min(280px, 100%);
}
```

Expected: CTA tablet and mobile styling is owned by the 900px block, with the 720px block only narrowing the device where needed.

### Task 2: Fix Jobs Heading

**Files:**
- Modify: `src/pages/jobs.html`

- [ ] **Step 1: Promote Jobs title to h1**

Replace:

```html
<h2>Jobs at Staia</h2>
```

with:

```html
<h1>Jobs at Staia</h1>
```

Expected: `/jobs/` has a page-level `h1` when visited directly.

### Task 3: Verify Fixes

**Files:**
- Verify: `public/styles/responsive.css`
- Verify: `src/pages/jobs.html`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Build**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully.

- [ ] **Step 2: Serve locally**

Run:

```bash
python3 -m http.server 8124 --bind 127.0.0.1 --directory dist
```

Expected: the site serves at `http://127.0.0.1:8124/`.

- [ ] **Step 3: Browser-check tablet CTA**

Open `http://127.0.0.1:8124/` in the Codex browser at `768x900`, scroll to the footer CTA, and verify the phone preview is visible and not collapsed.

- [ ] **Step 4: Browser-check Jobs heading**

Open `http://127.0.0.1:8124/jobs/` in the Codex browser and verify the visible title is `Jobs at Staia` and the DOM contains an `h1`.

- [ ] **Step 5: Static checks**

Run:

```bash
bash -n .codex/scripts/launch-website.sh
git diff --check
```

Expected: no shell syntax or whitespace errors.
