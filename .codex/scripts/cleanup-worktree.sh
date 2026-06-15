#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${CODEX_WORKTREE_PATH:-}"
if [[ -z "$ROOT_DIR" ]]; then
  ROOT_DIR="$(git rev-parse --show-toplevel)"
fi

printf '[staia-website-cleanup] Removing generated Eleventy artifact at %s/dist\n' "$ROOT_DIR"
rm -rf "$ROOT_DIR/dist"
