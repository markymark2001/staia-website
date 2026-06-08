# Homepage Feature 2 And 3 Swap Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Swap homepage feature 2 and feature 3 content while preserving the existing left, right, left, right layout pattern.

**Architecture:** Keep the existing `src/pages/index.html` feature loop and its reverse-class logic unchanged. Exchange only the title, copy, and image data between the second and third entries in `src/_data/home.js`, then run the Eleventy build so generated `dist/index.html` reflects the current data.

**Tech Stack:** Eleventy, static HTML, Python local static server, Codex browser verification.

---

### Task 1: Swap Homepage Feature Content

**Files:**
- Modify: `src/_data/home.js`
- Verify generated output: `dist/index.html`

- [ ] **Step 1: Update source feature data**

In `src/_data/home.js`, leave the second feature entry as the only one of the two with `reverse: true`, and replace its content with feature 3:

```js
{
  title: "Understand Your Chart",
  copy: "Personal astrology from your exact birth data.",
  image: "https://website.staia.io/3a.webp",
  reverse: true
}
```

Replace the third feature entry with feature 2 content and image, without adding `reverse`:

```js
{
  title: "Make Your Move",
  copy: "Choose the right moment with confidence.",
  image: "https://website.staia.io/2a.webp"
}
```

Do not edit `src/pages/index.html`; it should continue rendering the feature layout from `home.features`.

- [ ] **Step 2: Build generated site files**

Run:

```bash
npm run build
```

Expected: `dist/index.html` is rebuilt and shows feature 2 as `Understand Your Chart` with `3a.webp`, feature 3 as `Make Your Move` with `2a.webp`, with the second article still reversed and the third article still non-reversed.

- [ ] **Step 3: Inspect the diff**

Run:

```bash
git diff -- src/_data/home.js docs/plans/2026-06-08-homepage-feature-2-3-swap.md
```

Expected: only the plan file and the homepage feature 2/3 data changed.

### Task 2: Verify Homepage Rendering

**Files:**
- Verify: `docs/workflows/runtime-evidence.md`

- [ ] **Step 1: Serve the site locally**

Run from repo root:

```bash
npm run build
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

If port `8080` is busy, use another local port and record the exact URL.

- [ ] **Step 2: Check desktop browser evidence**

Open:

```text
http://127.0.0.1:8080/
```

Expected: feature 2 displays `Understand Your Chart` in the reverse layout position with `3a.webp`, feature 3 displays `Make Your Move` in the standard layout position with `2a.webp`, and no browser console errors are present.

- [ ] **Step 3: Check mobile browser evidence**

Open the same URL at a mobile viewport.

Expected: feature content appears in the same source order, the feature section stacks cleanly, and no horizontal overflow or browser console errors are present.

- [ ] **Step 4: Check local HTTP response**

Run:

```bash
curl -I http://127.0.0.1:8080/
```

Expected: a `200` response for the homepage.

### Task 3: Commit And Push

**Files:**
- Stage: `src/_data/home.js`
- Stage: `docs/plans/2026-06-08-homepage-feature-2-3-swap.md`

- [ ] **Step 1: Confirm checkout state**

Run:

```bash
git status --short --branch
```

Expected: existing unrelated local changes remain unstaged.

- [ ] **Step 2: Commit scoped files**

Run:

```bash
git add src/_data/home.js docs/plans/2026-06-08-homepage-feature-2-3-swap.md
git commit -m "Swap homepage feature sections"
```

Expected: commit succeeds without staging unrelated files.

- [ ] **Step 3: Push current branch**

If the checkout is detached, create one `codex/` branch at the current HEAD, then push that branch and open a non-draft pull request into `main`. If on `main`, push `main`.
