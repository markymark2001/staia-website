# Staia Website Codex Local Environment

Codex reads `.codex/environments/environment.toml` to expose repo-local setup,
cleanup, and launch actions in the desktop app.

## Setup Script

The tracked Codex setup callback runs:

```bash
cd "$CODEX_WORKTREE_PATH" && ./.codex/scripts/setup-worktree.sh
```

The setup script installs locked npm dependencies with `npm ci` and builds the
Eleventy static artifact into `dist/`.

## Cleanup Script

The tracked Codex cleanup callback runs:

```bash
cd "$CODEX_WORKTREE_PATH" && ./.codex/scripts/cleanup-worktree.sh
```

The cleanup script removes the generated `dist/` artifact. The website launch
action owns its local server lifetime and stops the server when the action
terminal exits.

## Actions

Use **Launch Website** to build the Eleventy site, serve `dist/` on the next
available local port starting at `STAIA_WEBSITE_PORT` or `8080`, and open the
site in Google Chrome.

The action delegates to:

```bash
./.codex/scripts/launch-website.sh
```
