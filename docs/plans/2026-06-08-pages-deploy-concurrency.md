# Pages Deploy Concurrency Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent pull request build runs from sharing the GitHub Pages deployment concurrency queue while preventing older main builds from deploying after newer pushes.

**Architecture:** Keep workflow-level concurrency, but split groups by event and ref. Pull request runs use a PR-specific group, `main` runs use the Pages deployment group and cancel superseded runs, and non-main manual dispatches use branch-specific build-only groups.

**Tech Stack:** GitHub Actions workflow YAML, GitHub Pages Actions.

---

### Task 1: Split Pages Concurrency By Event

**Files:**
- Modify: `.github/workflows/pages.yml`

- [ ] **Step 1: Replace global Pages concurrency**

Replace the top-level concurrency block with:

```yaml
concurrency:
  group: ${{ github.event_name == 'pull_request' && format('pages-pr-{0}', github.event.pull_request.number) || github.ref == 'refs/heads/main' && 'pages-deploy' || format('pages-build-{0}', github.ref_name) }}
  cancel-in-progress: ${{ github.ref == 'refs/heads/main' }}
```

Expected: PR builds and non-main manual runs do not share the deployment queue, and newer `main` runs cancel older build/deploy runs before stale artifacts can deploy.

### Task 2: Verify

**Files:**
- Verify: `.github/workflows/pages.yml`

- [ ] **Step 1: Inspect workflow**

Run:

```bash
sed -n '1,80p' .github/workflows/pages.yml
```

Expected: the top-level `concurrency` block uses a PR-specific group for pull requests, `pages-deploy` for `main`, and a branch-specific build group for non-main manual runs.

- [ ] **Step 2: Run local checks**

Run:

```bash
npm run build
git diff --check
```

Expected: build succeeds and no whitespace errors are reported.
