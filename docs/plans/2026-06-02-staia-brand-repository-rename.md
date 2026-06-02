# Staia Brand Repository Rename Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the public-site rebrand to Staia, replace the logo with the downloaded vector mark, and rename the GitHub repository to `staia-website`.

**Architecture:** Keep the Eleventy source-of-truth model: edit templates, data, docs, and passthrough assets, then rebuild `dist`. Use the downloaded SVG as a public asset referenced by the shared logo mask, and update local Git remote metadata after the GitHub repository rename.

**Tech Stack:** Eleventy 3, Nunjucks templates, static public assets, GitHub CLI, GitHub Pages.

---

### Task 1: Brand Source Updates

**Files:**
- Modify: `src/pages/*.html`
- Modify: `src/_includes/partials/*.njk`
- Modify: `src/_data/home.js`
- Modify: `src/design-system.html`
- Modify: `public/styles/components.css`
- Modify: `public/assets/staia-logo.svg`
- Modify: `README.md`
- Modify: `architecture.md`
- Modify: `package.json`
- Modify: `package-lock.json`
- Modify: `.codex/scripts/launch-website.sh`

- [ ] **Step 1: Replace logo asset**

Copy `/Users/markvasilyev/Downloads/Vector.svg` into `public/assets/staia-logo.svg`, remove the previous logo asset, and update CSS mask URLs to `staia-logo.svg`.

- [ ] **Step 2: Replace editable brand text**

Replace editable source/docs/package occurrences of the previous product name with `Staia`, `STAIA`, and `staia` as context requires. Update repository-name references to `staia-website` where they refer to this repository or local command prefixes.

- [ ] **Step 3: Inspect remaining old references**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
terms = [
    ''.join(['T', 'a', 'i', 'a']),
    ''.join(['T', 'A', 'I', 'A']),
    ''.join(['t', 'a', 'i', 'a', '-', 'l', 'o', 'g', 'o']),
    ''.join(['l', 'u', 'n', 'a', '-', 'w', 'e', 'b', 's', 'i', 't', 'e']),
]
roots = [Path(p) for p in ['src', 'public', 'README.md', 'architecture.md', 'package.json', 'package-lock.json', '.codex']]
for root in roots:
    paths = [root] if root.is_file() else [p for p in root.rglob('*') if p.is_file()]
    for path in paths:
        text = path.read_text(errors='ignore')
        for line_no, line in enumerate(text.splitlines(), 1):
            if any(term in line for term in terms):
                print(f'{path}:{line_no}:{line}')
PY
```

Expected: no results.

### Task 2: Build and Browser Verification

**Files:**
- Verify: `docs/workflows/runtime-evidence.md`
- Verify: generated `dist/`

- [ ] **Step 1: Build the static site**

Run:

```bash
npm run build
git diff --check
```

Expected: Eleventy builds successfully and diff whitespace check passes.

- [ ] **Step 2: Serve and inspect changed public pages**

Serve `dist` locally, open `/`, `/about/`, `/contact/`, `/privacy/`, `/terms/`, and `/jobs/` in the Codex browser, and confirm the Staia logo/text render with no console errors.

### Task 3: Repository Rename and Publish

**Files:**
- Modify remote repository metadata through GitHub.

- [ ] **Step 1: Rename GitHub repository**

Run:

```bash
CURRENT_REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
gh repo rename staia-website --repo "$CURRENT_REPO" --yes
git remote set-url origin git@github.com:markymark2001/staia-website.git
```

Expected: GitHub repository is renamed and local `origin` points to `staia-website`.

- [ ] **Step 2: Commit and push**

Run:

```bash
git status --short
git add .
git commit -m "Rename website brand to Staia"
git fetch origin main
git merge-tree "$(git merge-base HEAD origin/main)" HEAD origin/main
git push -u origin website-v2
```

Expected: changes are committed and `website-v2` is pushed to the renamed repository.

- [ ] **Step 3: Open non-draft PR**

Run:

```bash
gh pr create --base main --head website-v2 --title "Rename website brand to Staia" --body-file /tmp/staia-website-pr.md
```

Expected: a non-draft PR into `main` exists for the pushed branch.
