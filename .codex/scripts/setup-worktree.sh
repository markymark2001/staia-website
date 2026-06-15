#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${CODEX_WORKTREE_PATH:-}"
if [[ -z "$ROOT_DIR" ]]; then
  ROOT_DIR="$(git rev-parse --show-toplevel)"
fi

fail() {
  printf '[staia-website-setup] ERROR: %s\n' "$*" >&2
  exit 1
}

command -v npm >/dev/null 2>&1 || fail "npm is required."
[[ -f "$ROOT_DIR/package.json" ]] || fail "package.json not found at $ROOT_DIR."
[[ -f "$ROOT_DIR/package-lock.json" ]] || fail "package-lock.json not found at $ROOT_DIR."

printf '[staia-website-setup] Installing locked npm dependencies...\n'
npm --prefix "$ROOT_DIR" ci

printf '[staia-website-setup] Building Eleventy site...\n'
npm --prefix "$ROOT_DIR" run build

printf '[staia-website-setup] Ready. Built artifact: %s/dist\n' "$ROOT_DIR"
