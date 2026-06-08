# R2 Media Domain Staia Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update externally hosted website media assets from the old Luna R2 custom domain to the new Staia R2 custom domain.

**Architecture:** Keep the public GitHub Pages website domain and `public/CNAME` unchanged. Only update R2-backed media asset URLs from `https://website.lunaapp.io/...` to `https://website.staia.io/...`, and update the architecture contract so future agents know which host owns external website media.

**Tech Stack:** Eleventy static templates, Cloudflare R2 public bucket custom domain, local static build verification.

---

### Task 1: Update Authored Media URLs

**Files:**
- Modify: `src/pages/index.html`
- Modify: `src/pages/about.html`
- Modify: `src/pages/contact.html`

- [ ] **Step 1: Replace old R2 custom-domain host**

Run:

```bash
perl -0pi -e 's#https://website\\.lunaapp\\.io/#https://website.staia.io/#g' src/pages/index.html src/pages/about.html src/pages/contact.html
```

Expected: homepage video, About image, and Contact image all point at `https://website.staia.io/`.

- [ ] **Step 2: Confirm source references**

Run:

```bash
rg -n "website\\.(lunaapp|staia)\\.io" src architecture.md README.md docs/plans/2026-06-08-r2-media-domain-staia.md
```

Expected: active source files use `website.staia.io`; old `website.lunaapp.io` remains only in historical plans unless this new plan has before/after text.

### Task 2: Update Architecture Contract

**Files:**
- Modify: `architecture.md`

- [ ] **Step 1: Update service-stack media host**

Replace:

```markdown
- `website.lunaapp.io` hosts external website media assets such as the homepage
  background video.
```

with:

```markdown
- `website.staia.io` hosts external website media assets such as the homepage
  background video.
```

- [ ] **Step 2: Update R2 video contract**

Replace:

```text
https://website.lunaapp.io/homepage-background.mp4
```

with:

```text
https://website.staia.io/homepage-background.mp4
```

Expected: architecture docs identify `website.staia.io` as the R2/custom-domain media host.

### Task 3: Verify

**Files:**
- Verify: `src/pages/index.html`
- Verify: `src/pages/about.html`
- Verify: `src/pages/contact.html`
- Verify: `architecture.md`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Build**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully.

- [ ] **Step 2: Check generated references**

Run:

```bash
rg -n "website\\.(lunaapp|staia)\\.io" src dist architecture.md
```

Expected: all active source, generated HTML, and architecture references use `website.staia.io`.

- [ ] **Step 3: Check remote assets**

Run:

```bash
curl -I https://website.staia.io/homepage-background.mp4
curl -I https://website.staia.io/about-stats.webp
```

Expected: both URLs return a successful HTTP status or an authenticated/CDN status that proves the host resolves.

- [ ] **Step 4: Browser evidence**

Serve `dist` locally, open `/`, `/about/`, and `/contact/` in the Codex browser, and verify:

```js
document.querySelector('video source')?.src === 'https://website.staia.io/homepage-background.mp4'
[...document.querySelectorAll('.media-stat-panel__image')].every((img) => img.currentSrc.startsWith('https://website.staia.io/'))
```

Expected: changed pages render with no console errors and use the new R2 media domain.
