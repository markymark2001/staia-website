# Feature R2 Images Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Use the four uploaded R2-hosted numbered WebP images for the homepage feature section in order.

**Architecture:** Keep homepage feature content in `src/_data/home.js` as the source of truth. Add an `image` URL to each feature object, then update `src/pages/index.html` so the feature loop renders `feature.image` instead of reusing the shared phone screenshot URL. The footer CTA phone image remains on `https://website.staia.io/taiaphone.webp`.

**Tech Stack:** Eleventy data files, Nunjucks templates, Cloudflare R2 custom-domain WebP images, local static build and browser evidence.

---

### Task 1: Wire Numbered Feature Images

**Files:**
- Modify: `src/_data/home.js`
- Modify: `src/pages/index.html`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Add R2 image URLs to the four feature records**

Update `src/_data/home.js` so the first through fourth `home.features` entries include these exact URLs:

```js
image: "https://website.staia.io/1.webp"
image: "https://website.staia.io/2.webp"
image: "https://website.staia.io/3.webp"
image: "https://website.staia.io/4.webp"
```

Expected: each feature owns the image URL that matches its visual order.

- [ ] **Step 2: Render each feature image in the homepage loop**

Update the feature phone image in `src/pages/index.html` from:

```html
<img src="https://website.staia.io/taiaphone.webp" alt="Staia app screenshot">
```

to:

```html
<img src="{{ feature.image }}" alt="Staia app screenshot">
```

Expected: the generated homepage contains `1.webp`, `2.webp`, `3.webp`, and `4.webp` in feature order.

- [ ] **Step 3: Verify the R2 assets and generated HTML**

Run:

```bash
for asset in 1 2 3 4; do curl -I "https://website.staia.io/${asset}.webp"; done
npm run build
rg -n "https://website.staia.io/[1-4]\\.webp|https://website.staia.io/taiaphone.webp" dist/index.html
```

Expected: each numbered image returns `HTTP 200` with `content-type: image/webp`; Eleventy exits successfully; `dist/index.html` contains the four numbered images in the feature section and keeps `taiaphone.webp` only where still intentionally used outside the numbered feature images.

- [ ] **Step 4: Capture browser evidence**

Serve the generated site:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open `http://127.0.0.1:8080/` in the Codex browser and verify:

```js
Array.from(document.querySelectorAll(".features .feature-device img")).map((img) => img.currentSrc)
```

Expected: the result is exactly:

```js
[
  "https://website.staia.io/1.webp",
  "https://website.staia.io/2.webp",
  "https://website.staia.io/3.webp",
  "https://website.staia.io/4.webp"
]
```

Also verify the homepage has no browser console errors.

- [ ] **Step 5: Review, commit, and push**

Run:

```bash
./.codex/scripts/codex-review.sh
git status --short
git add src/_data/home.js src/pages/index.html docs/plans/2026-06-08-feature-r2-images.md
git commit -m "Use R2 feature images"
git fetch origin main
git merge-tree "$(git merge-base HEAD origin/main)" HEAD origin/main
git push origin HEAD:website-v2
```

Expected: the review script exits successfully, the commit contains only the intended feature-image changes and plan, the branch has no merge conflicts with `origin/main`, and `origin/website-v2` is updated.
