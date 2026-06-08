# Launch Action Dependency Bootstrap Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Codex Launch Website action work from a fresh checkout without preinstalled Node dependencies.

**Architecture:** Keep `.codex/scripts/launch-website.sh` as the single runtime entrypoint. Before `npm run build`, check whether the local Eleventy binary exists; if not, run `npm ci` from the repository root so dependencies are installed from `package-lock.json` without changing dependency versions.

**Tech Stack:** Bash, npm clean install, Eleventy, Python static server.

---

### Task 1: Bootstrap Missing Dependencies

**Files:**
- Modify: `.codex/scripts/launch-website.sh`

- [ ] **Step 1: Add dependency bootstrap**

Add this function after command validation:

```bash
ensure_dependencies() {
  if [[ -x "$ROOT_DIR/node_modules/.bin/eleventy" ]]; then
    return 0
  fi

  [[ -f "$ROOT_DIR/package-lock.json" ]] || fail "package-lock.json not found at $ROOT_DIR."
  printf '[staia-website] Installing dependencies with npm ci...\n'
  npm --prefix "$ROOT_DIR" ci
}
```

Then call:

```bash
ensure_dependencies
```

before:

```bash
npm --prefix "$ROOT_DIR" run build
```

Expected: a fresh checkout installs locked dependencies before building.

### Task 2: Verify Fresh-Dependency Path

**Files:**
- Verify: `.codex/scripts/launch-website.sh`

- [ ] **Step 1: Syntax check**

Run:

```bash
bash -n .codex/scripts/launch-website.sh
```

Expected: no output and exit status `0`.

- [ ] **Step 2: Fresh dependency smoke**

Temporarily move `node_modules` aside, run the launcher on a fixed local port, and verify it installs dependencies, builds, and serves the homepage.

Expected: `npm ci` runs only when Eleventy is missing, and the launcher still serves HTTP 200.

- [ ] **Step 3: Restore dependency state**

Stop the launcher and remove any temporary `node_modules` backup.

Expected: no temporary files are left in the worktree.
