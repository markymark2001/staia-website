# App Link Swap Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace public app CTA links that point to the old app destination with `https://applink.staia.io/ik5ochf`.

**Architecture:** Keep Eleventy source files as the source of truth and let `npm run build` regenerate `dist`. The shared header, footer navigation, footer CTA, and homepage hero own the current app CTAs, so edit those source anchors directly without introducing a new abstraction for a one-time link update.

**Tech Stack:** Eleventy 3, Nunjucks templates, static HTML, GitHub Pages artifact build.

---

### Task 1: Replace App CTA Hrefs

**Files:**
- Modify: `src/_includes/partials/header.njk`
- Modify: `src/_includes/partials/footer.njk`
- Modify: `src/_includes/partials/footer-cta.njk`
- Modify: `src/pages/index.html`
- Verify: `docs/workflows/runtime-evidence.md`

- [x] **Step 1: Confirm old source links**

Run:

```bash
rg -n "https://abr.ge/kmrvcpp" src
```

Expected: the command lists the header CTA, footer navigation CTA, footer download CTA, and homepage hero CTA.

- [x] **Step 2: Replace source href values**

Replace every `href="https://abr.ge/kmrvcpp"` in the listed source files with:

```html
href="https://applink.staia.io/ik5ochf"
```

Expected: the CTA text, ARIA labels, classes, and SVG icons stay unchanged.

- [x] **Step 3: Rebuild generated site**

Run:

```bash
npm run build
```

Expected: Eleventy writes the updated static artifact under `dist`.

- [x] **Step 4: Verify source and generated output**

Run:

```bash
rg -n "https://abr.ge/kmrvcpp" src dist
rg -n "https://applink.staia.io/ik5ochf" src dist/index.html
```

Expected: the old URL is absent from `src` and `dist`; the new URL appears in the changed source files and generated homepage output.

- [x] **Step 5: Verify browser behavior**

Serve the generated site:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open `http://127.0.0.1:8080/` with the Codex browser and verify:

```js
[...document.querySelectorAll('a[href="https://applink.staia.io/ik5ochf"]')].length >= 4
document.querySelector('.site-header .button.primary').href === 'https://applink.staia.io/ik5ochf'
document.querySelector('.video-hero .hero-button').href === 'https://applink.staia.io/ik5ochf'
document.querySelector('.download-cta__button').href === 'https://applink.staia.io/ik5ochf'
```

Expected: the homepage renders with no console errors, and the visible app CTAs resolve to the new destination.

- [x] **Step 6: Run final checks and commit**

Run:

```bash
git diff --check
git status --short
git add docs/plans/2026-06-21-app-link-swap.md src/_includes/partials/header.njk src/_includes/partials/footer.njk src/_includes/partials/footer-cta.njk src/pages/index.html
git commit -m "Update app CTA links"
git push origin main
```

Expected: checks pass, only intended source and docs files are staged, the commit succeeds, and `main` pushes to origin.
