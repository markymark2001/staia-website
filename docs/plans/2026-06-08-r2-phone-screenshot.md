# R2 Phone Screenshot Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace local phone screenshot assets with the uploaded R2-hosted `taiaphone.webp`.

**Architecture:** Keep the reusable phone frame markup and CSS unchanged. Point every phone screenshot `<img>` at `https://website.staia.io/taiaphone.webp`, remove `public/assets/hero-app-screenshot.png` so the generated artifact no longer bundles the old local PNG, and update the architecture contract to state that app screenshots can be hosted on the external website media domain.

**Tech Stack:** Eleventy templates, Cloudflare R2 custom-domain WebP image, GitHub Pages passthrough asset cleanup.

---

### Task 1: Replace Phone Image Sources

**Files:**
- Modify: `src/pages/index.html`
- Modify: `src/_includes/partials/footer-cta.njk`

- [ ] **Step 1: Update homepage feature phone**

Change:

```html
<img src="/assets/hero-app-screenshot.png" alt="Staia app screenshot">
```

to:

```html
<img src="https://website.staia.io/taiaphone.webp" alt="Staia app screenshot">
```

- [ ] **Step 2: Update footer CTA phone**

Change:

```html
<img src="/assets/hero-app-screenshot.png" alt="">
```

to:

```html
<img src="https://website.staia.io/taiaphone.webp" alt="">
```

Expected: all rendered phone screenshots load from the new R2 WebP URL.

### Task 2: Remove Local Phone Asset

**Files:**
- Delete: `public/assets/hero-app-screenshot.png`
- Modify: `architecture.md`

- [ ] **Step 1: Delete old local screenshot**

Run:

```bash
rm public/assets/hero-app-screenshot.png
```

Expected: the old local PNG is no longer copied to `dist/assets/`.

- [ ] **Step 2: Update asset contract**

In `architecture.md`, update:

```markdown
Homepage behavior lives in `public/scripts/home.js`. App screenshots and logos
live under `public/assets/`.
```

to:

```markdown
Homepage behavior lives in `public/scripts/home.js`. Logos and small root site
assets live under `public/`; app screenshots and large media can use the
external `website.staia.io` media domain.
```

Expected: durable architecture documentation matches the new external screenshot ownership.

### Task 3: Verify

**Files:**
- Verify: `src/pages/index.html`
- Verify: `src/_includes/partials/footer-cta.njk`
- Verify: `public/assets/hero-app-screenshot.png`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Check R2 asset**

Run:

```bash
curl -I https://website.staia.io/taiaphone.webp
```

Expected: `HTTP 200` with `content-type: image/webp`.

- [ ] **Step 2: Build**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully and `dist/assets/hero-app-screenshot.png` does not exist.

- [ ] **Step 3: Reference check**

Run:

```bash
rg -n "hero-app-screenshot|taiaphone" src dist public architecture.md
```

Expected: active source/generated files reference only `https://website.staia.io/taiaphone.webp`; no active source or generated file references `hero-app-screenshot`.

- [ ] **Step 4: Browser evidence**

Serve `dist` locally, open the homepage in the Codex browser, and verify the feature phone plus footer CTA phone images load from `https://website.staia.io/taiaphone.webp` with no console errors.
