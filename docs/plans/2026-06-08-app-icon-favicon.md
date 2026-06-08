# App Icon Favicon Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Use the Staia app icon from the local app repo as the public website favicon.

**Architecture:** Keep favicon assets local under `public/` instead of R2 because favicons are tiny root-level site assets and browsers commonly request `/favicon.ico` directly. Generate scaled PNG assets from the 1024px iOS marketing icon, wrap multiple PNG sizes into a root `favicon.ico`, and add explicit icon links to the shared head partial.

**Tech Stack:** iOS app icon PNG, macOS `sips`, Python standard library ICO container generation, Eleventy static passthrough.

---

### Task 1: Generate Favicon Assets

**Files:**
- Source: `/Users/markvasilyev/staia/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- Create: `public/favicon.ico`
- Create: `public/favicon-32x32.png`
- Create: `public/apple-touch-icon.png`

- [ ] **Step 1: Confirm source icon**

Run:

```bash
sips -g pixelWidth -g pixelHeight /Users/markvasilyev/staia/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
```

Expected: the source icon is `1024x1024`.

- [ ] **Step 2: Generate scaled PNGs**

Run:

```bash
mkdir -p public
sips -s format png -z 32 32 /Users/markvasilyev/staia/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png --out public/favicon-32x32.png
sips -s format png -z 180 180 /Users/markvasilyev/staia/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png --out public/apple-touch-icon.png
```

Expected: `public/favicon-32x32.png` and `public/apple-touch-icon.png` are square PNGs at the requested dimensions.

- [ ] **Step 3: Generate root ICO**

Generate `public/favicon.ico` with embedded 16px, 32px, and 48px PNG entries from the same source.

Expected: browsers that request `/favicon.ico` receive a multi-size ICO at the site root.

### Task 2: Wire Head Links

**Files:**
- Modify: `src/_includes/partials/head.njk`

- [ ] **Step 1: Add icon links**

Insert these links after the page title:

```html
  <link rel="icon" href="/favicon.ico" sizes="any">
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
```

Expected: standard browsers can select the root ICO or 32px PNG, and iOS Web Clip uses the 180px touch icon.

### Task 3: Verify

**Files:**
- Verify: `public/favicon.ico`
- Verify: `public/favicon-32x32.png`
- Verify: `public/apple-touch-icon.png`
- Verify: `src/_includes/partials/head.njk`
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Inspect asset dimensions**

Run:

```bash
file public/favicon.ico public/favicon-32x32.png public/apple-touch-icon.png
sips -g pixelWidth -g pixelHeight public/favicon-32x32.png public/apple-touch-icon.png
```

Expected: PNG dimensions are `32x32` and `180x180`; ICO is recognized as an icon file.

- [ ] **Step 2: Build**

Run:

```bash
npm run build
```

Expected: Eleventy copies all favicon assets to `dist/`.

- [ ] **Step 3: HTTP and browser evidence**

Serve `dist` locally, then verify:

```bash
curl -I http://127.0.0.1:8129/favicon.ico
curl -I http://127.0.0.1:8129/favicon-32x32.png
curl -I http://127.0.0.1:8129/apple-touch-icon.png
```

Expected: each returns `200 OK`. In the Codex browser, open the homepage and verify the head contains the icon links and no console errors are reported.
