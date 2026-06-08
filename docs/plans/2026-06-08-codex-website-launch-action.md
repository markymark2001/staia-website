# Codex Website Launch Action Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the existing Staia website launcher as a Codex local environment action.

**Architecture:** Add the missing Codex environment action metadata under `.codex/environments/environment.toml`, matching the action pattern used by the local Staia app repo. Keep the existing `.codex/scripts/launch-website.sh` as the runtime owner and document the wiring in `.codex/README.md`.

**Tech Stack:** Codex environment TOML, Bash launcher, Eleventy build output served by Python `http.server`.

---

### Task 1: Add Codex Action Metadata

**Files:**
- Create: `.codex/environments/environment.toml`
- Create: `.codex/README.md`

- [ ] **Step 1: Confirm root cause**

Run:

```bash
find .codex -maxdepth 3 -type f -print | sort
```

Expected: `.codex/scripts/launch-website.sh` exists, but `.codex/environments/environment.toml` is missing.

- [ ] **Step 2: Create the environment action config**

Create `.codex/environments/environment.toml` with:

```toml
version = 1
name = "staia-website"

[[actions]]
name = "Launch Website"
icon = "run"
command = "./.codex/scripts/launch-website.sh"
```

Expected: Codex has a named action that invokes the existing website launcher.

- [ ] **Step 3: Document the local Codex wiring**

Create `.codex/README.md` with:

```markdown
# Staia Website Codex Local Environment

Codex reads `.codex/environments/environment.toml` to expose repo-local launch
actions in the desktop app.

## Actions

Use **Launch Website** to build the Eleventy site, serve `dist/` on the next
available local port starting at `STAIA_WEBSITE_PORT` or `8080`, and open the
site in Google Chrome.

The action delegates to:

```bash
./.codex/scripts/launch-website.sh
```
```

Expected: future agents can identify why the action exists and which script owns runtime behavior.

### Task 2: Verify Action Configuration

**Files:**
- Verify: `.codex/environments/environment.toml`
- Verify: `.codex/README.md`
- Verify: `.codex/scripts/launch-website.sh`

- [ ] **Step 1: Inspect the TOML**

Run:

```bash
sed -n '1,80p' .codex/environments/environment.toml
```

Expected: the file contains one `Launch Website` action and points to `./.codex/scripts/launch-website.sh`.

- [ ] **Step 2: Check launcher syntax**

Run:

```bash
bash -n .codex/scripts/launch-website.sh
```

Expected: no output and exit status `0`.

- [ ] **Step 3: Build the static site**

Run:

```bash
npm run build
```

Expected: Eleventy exits successfully and writes `dist/index.html`.

- [ ] **Step 4: Check repository diff**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors and only the plan plus `.codex` environment documentation/config are changed.

### Task 3: Commit And Push

**Files:**
- Stage: `.codex/environments/environment.toml`
- Stage: `.codex/README.md`
- Stage: `docs/plans/2026-06-08-codex-website-launch-action.md`

- [ ] **Step 1: Stage the scoped changes**

Run:

```bash
git add .codex/environments/environment.toml .codex/README.md docs/plans/2026-06-08-codex-website-launch-action.md
```

Expected: only those files are staged.

- [ ] **Step 2: Commit**

Run:

```bash
git commit -m "Add Codex website launch action"
```

Expected: commit succeeds on the current branch.

- [ ] **Step 3: Push**

Run:

```bash
git push origin website-v2
```

Expected: the `website-v2` branch pushes successfully.
