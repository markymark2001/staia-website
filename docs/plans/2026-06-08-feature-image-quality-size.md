# Feature Image Quality And Size Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make homepage feature images larger on the page and provide higher-resolution WebP files for R2 upload.

**Architecture:** Keep the same R2 feature URLs, because the user can replace the objects at `1.webp` through `4.webp` without code churn. Re-export the local source PNGs as 900 by 900 WebPs for upload, then update the homepage feature image display box to 400 by 400 with cache-busted CSS imports.

**Tech Stack:** Eleventy templates, CSS fixed-size replaced elements, `cwebp` WebP conversion, local browser evidence.

---

### Task 1: Generate Better Feature WebPs

**Files:**
- Read: `/Users/markvasilyev/Downloads/1.png`
- Read: `/Users/markvasilyev/Downloads/2.png`
- Read: `/Users/markvasilyev/Downloads/3.png`
- Read: `/Users/markvasilyev/Downloads/4.png`
- Create: `/Users/markvasilyev/Downloads/staia-feature-webps/1.webp`
- Create: `/Users/markvasilyev/Downloads/staia-feature-webps/2.webp`
- Create: `/Users/markvasilyev/Downloads/staia-feature-webps/3.webp`
- Create: `/Users/markvasilyev/Downloads/staia-feature-webps/4.webp`

- [ ] **Step 1: Convert PNGs to high-resolution WebPs**

Run:

```bash
mkdir -p /Users/markvasilyev/Downloads/staia-feature-webps
for asset in 1 2 3 4; do
  cwebp -quiet -lossless -z 6 -resize 900 900 \
    "/Users/markvasilyev/Downloads/${asset}.png" \
    -o "/Users/markvasilyev/Downloads/staia-feature-webps/${asset}.webp"
done
```

Expected: four replacement WebPs exist at 900 by 900 pixels, preserving source quality better than the prior 320 by 320 exports.

- [ ] **Step 2: Verify generated image dimensions**

Run:

```bash
for asset in 1 2 3 4; do
  file "/Users/markvasilyev/Downloads/staia-feature-webps/${asset}.webp"
  sips -g pixelWidth -g pixelHeight "/Users/markvasilyev/Downloads/staia-feature-webps/${asset}.webp"
done
```

Expected: each file reports `900 x 900`.

### Task 2: Display Features At 400 By 400

**Files:**
- Modify: `src/pages/index.html`
- Modify: `public/styles/home.css`
- Modify: `public/style.css`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Update intrinsic layout attributes**

Change the feature image markup to:

```html
<img src="{{ feature.image }}" width="400" height="400" alt="Staia app screenshot">
```

Expected: browser layout reserves a 400 by 400 square before the image finishes loading.

- [ ] **Step 2: Update feature image CSS**

Change `.feature-image` and `.feature-image img` to use `400px` for width and height.

Expected: desktop feature images render as plain 400 by 400 squares with no border or shadow.

- [ ] **Step 3: Bump CSS cache keys**

Update the homepage stylesheet query and changed CSS imports from `20260608-2` to `20260608-3`.

Expected: browsers fetch the new feature image sizing CSS.

- [ ] **Step 4: Verify locally**

Run:

```bash
npm run build
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open `http://127.0.0.1:8080/` in the Codex browser and measure `.features .feature-image` and `.features .feature-image img`.

Expected: each feature image reports `width: 400`, `height: 400`, no border, no shadow, and no console errors.

- [ ] **Step 5: Commit and push without review script**

Run:

```bash
git add src/pages/index.html public/styles/home.css public/style.css docs/plans/2026-06-08-feature-image-quality-size.md
git commit -m "Enlarge feature images"
git fetch https://github.com/markymark2001/staia-website.git main:refs/remotes/origin/main
git merge-tree "$(git merge-base HEAD origin/main)" HEAD origin/main
git push https://github.com/markymark2001/staia-website.git HEAD:website-v2
```

Expected: branch pushes cleanly. Skip `./.codex/scripts/codex-review.sh` for this image-only work per user instruction.
