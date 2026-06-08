# Feature Square Images Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render the four homepage feature images as plain 320 by 320 pixel squares with no borders, shadows, or phone-frame chrome.

**Architecture:** Supersedes `docs/plans/2026-06-08-feature-r2-images.md` for presentation details after user feedback. Keep the numbered R2 URLs in `src/_data/home.js`, replace the feature section's phone-frame markup with a dedicated feature image figure, and style that figure independently from the reusable phone frame used by the footer CTA.

**Tech Stack:** Eleventy data files, Nunjucks templates, CSS replaced-element sizing, Cloudflare R2 WebP images, local browser evidence.

---

### Task 1: Replace Feature Phone Frames With Plain Images

**Files:**
- Modify: `src/pages/index.html`
- Modify: `public/styles/home.css`
- Modify: `public/styles/responsive.css`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Change the feature markup**

Update the feature loop in `src/pages/index.html` to render:

```html
<figure class="feature-image" aria-label="Staia app feature preview">
  <img src="{{ feature.image }}" width="320" height="320" alt="Staia app screenshot">
</figure>
```

Expected: feature images no longer use `device-frame`, `device-frame--iphone`, or `device-frame__screen`.

- [ ] **Step 2: Add plain square feature image CSS**

Update `public/styles/home.css` so `.feature-image` is a centered, plain, 320 by 320 square with no decorative pseudo-element:

```css
.feature-image {
  justify-self: center;
  width: 320px;
  height: 320px;
  margin: 0;
}

.feature-image img {
  display: block;
  width: 320px;
  height: 320px;
  object-fit: cover;
}
```

Expected: the feature image has no border, no box-shadow, no background frame, and no blurred shadow.

- [ ] **Step 3: Update responsive ordering selectors**

Update `public/styles/responsive.css` selectors that referenced `.feature-device` for feature ordering so they reference `.feature-image` instead. Leave `device-frame--iphone` rules intact for the footer CTA phone.

Expected: reversed feature rows still place image/copy correctly on desktop and reset to source order on mobile.

- [ ] **Step 4: Verify generated and browser-rendered dimensions**

Run:

```bash
npm run build
rg -n "feature-image|device-frame device-frame--iphone feature-device|website.staia.io/[1-4]\\.webp" dist/index.html public/styles/home.css public/styles/responsive.css
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open `http://127.0.0.1:8080/` in the Codex browser and verify:

```js
Array.from(document.querySelectorAll(".features .feature-image img")).map((img) => {
  const styles = getComputedStyle(img);
  const rect = img.getBoundingClientRect();
  return {
    src: img.currentSrc,
    width: rect.width,
    height: rect.height,
    boxShadow: styles.boxShadow,
    border: styles.border,
    complete: img.complete,
    naturalWidth: img.naturalWidth,
    naturalHeight: img.naturalHeight
  };
})
```

Expected: four loaded images from `1.webp` through `4.webp`, each reports `width: 320`, `height: 320`, `boxShadow: "none"`, and no visible border. Browser console has no errors.

- [ ] **Step 5: Review, commit, and push**

Run:

```bash
./.codex/scripts/codex-review.sh
git add src/_data/home.js src/pages/index.html public/styles/home.css public/styles/responsive.css docs/plans/2026-06-08-feature-r2-images.md docs/plans/2026-06-08-feature-square-images.md
git commit -m "Use square R2 feature images"
git fetch origin main
git merge-tree "$(git merge-base HEAD origin/main)" HEAD origin/main
git push origin HEAD:website-v2
```

Expected: review passes, the commit contains only the feature image data/template/CSS and plans, no merge conflicts are reported, and `origin/website-v2` is updated.
