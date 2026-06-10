# Pages Node 24 Deploy Fix Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the failing GitHub Pages deployment on `main` by using Node 24-native GitHub Actions instead of forcing older actions onto Node 24.

**Architecture:** Keep the existing two-job Pages workflow: build uploads the Eleventy `dist` artifact and deploy publishes it only on `main`. Update the action versions to current Node 24-compatible majors and remove the global `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` override that caused `actions/deploy-pages@v4` to fail authentication while running under Node 24.

**Tech Stack:** GitHub Actions, GitHub Pages Actions, Eleventy.

---

### Task 1: Capture Failure Evidence

**Files:**
- Verify: GitHub Actions run `27287441054`

- [x] **Step 1: Inspect the failed run**

Run:

```bash
curl -sS -H 'Accept: application/vnd.github+json' \
  'https://api.github.com/repos/markymark2001/staia-website/actions/runs?per_page=10'
```

Expected: the latest `main` push run, `27287441054`, has `conclusion: failure`.

- [x] **Step 2: Inspect deploy job logs**

Fetch the deploy job log for job `80598494584`.

Expected: build and artifact upload succeeded, but `actions/deploy-pages@v4` failed with `HttpError: Requires authentication` while `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` was present.

### Task 2: Update Pages Workflow

**Files:**
- Modify: `.github/workflows/pages.yml`
- Modify: `architecture.md`

- [x] **Step 1: Update action majors and remove the force flag**

In `.github/workflows/pages.yml`:

```yaml
- uses: actions/checkout@v5
- uses: actions/setup-node@v6
- uses: actions/upload-pages-artifact@v5
- uses: actions/deploy-pages@v5
```

Remove:

```yaml
env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
```

Expected: all JavaScript actions in the workflow use Node 24-native versions and the workflow no longer forces older actions onto Node 24.

- [x] **Step 2: Update deployment architecture docs**

In `architecture.md`, update the deployment contract so it no longer names `actions/upload-pages-artifact@v4` and `actions/deploy-pages@v4`; it should describe current Node 24-compatible Pages actions.

Expected: future agents do not reintroduce the older Pages action majors.

### Task 3: Verify and Publish

**Files:**
- Verify: `.github/workflows/pages.yml`
- Verify: generated `dist`

- [x] **Step 1: Run local checks**

Run:

```bash
npm run build
git diff --check
```

Expected: Eleventy builds `dist` successfully and no whitespace errors are reported.

- [x] **Step 2: Commit and push the current branch**

Run:

```bash
git add .github/workflows/pages.yml architecture.md docs/plans/2026-06-10-pages-node24-deploy-fix.md
git commit -m "Fix GitHub Pages Node 24 deploy"
git push origin codex/app-store-search-metadata
```

Expected: the current branch is pushed with the workflow fix.
