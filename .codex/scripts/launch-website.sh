#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
SITE_DIR="$ROOT_DIR/dist"
REQUESTED_PORT="${STAIA_WEBSITE_PORT:-8080}"
HOST="127.0.0.1"
PORT=""
URL=""
SERVER_PID=""
SERVER_READY="false"

fail() {
  printf '[staia-website] ERROR: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

command -v python3 >/dev/null 2>&1 || fail "python3 is required."
command -v npm >/dev/null 2>&1 || fail "npm is required."
command -v open >/dev/null 2>&1 || fail "macOS open is required."
[[ -f "$ROOT_DIR/package.json" ]] || fail "package.json not found at $ROOT_DIR."

ensure_dependencies() {
  if [[ -x "$ROOT_DIR/node_modules/.bin/eleventy" ]]; then
    return 0
  fi

  [[ -f "$ROOT_DIR/package-lock.json" ]] || fail "package-lock.json not found at $ROOT_DIR."
  printf '[staia-website] Installing dependencies with npm ci...\n'
  npm --prefix "$ROOT_DIR" ci
}

port_is_available() {
  local candidate_port="$1"
  python3 - "$HOST" "$candidate_port" <<'PY' >/dev/null 2>&1
import socket
import sys

host = sys.argv[1]
port = int(sys.argv[2])
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.bind((host, port))
PY
}

select_port() {
  local start_port="$1"
  local max_port="${STAIA_WEBSITE_MAX_PORT:-65535}"
  local candidate_port

  [[ "$start_port" =~ ^[0-9]+$ ]] || fail "STAIA_WEBSITE_PORT must be a number."
  [[ "$max_port" =~ ^[0-9]+$ ]] || fail "STAIA_WEBSITE_MAX_PORT must be a number."
  (( start_port >= 1 && start_port <= 65535 )) || fail "STAIA_WEBSITE_PORT must be between 1 and 65535."
  (( max_port >= start_port && max_port <= 65535 )) || fail "STAIA_WEBSITE_MAX_PORT must be between STAIA_WEBSITE_PORT and 65535."

  for ((candidate_port = start_port; candidate_port <= max_port; candidate_port++)); do
    if port_is_available "$candidate_port"; then
      PORT="$candidate_port"
      return 0
    fi
  done

  fail "No available port found from $start_port to $max_port."
}

select_port "$REQUESTED_PORT"
URL="http://$HOST:$PORT/"

ensure_dependencies
npm --prefix "$ROOT_DIR" run build
[[ -f "$SITE_DIR/index.html" ]] || fail "Built index.html not found at $SITE_DIR."

python3 -m http.server "$PORT" --bind "$HOST" --directory "$SITE_DIR" &
SERVER_PID="$!"

for _ in $(seq 1 50); do
  if python3 - "$URL" "$SITE_DIR/index.html" <<'PY' >/dev/null 2>&1
import sys
from pathlib import Path
from urllib.request import urlopen

url = sys.argv[1]
index_path = Path(sys.argv[2])

with urlopen(url, timeout=0.2) as response:
    if response.read() != index_path.read_bytes():
        raise SystemExit(1)
PY
  then
    SERVER_READY="true"
    break
  fi
  sleep 0.1
done

if ! kill -0 "$SERVER_PID" 2>/dev/null; then
  wait "$SERVER_PID"
fi
[[ "$SERVER_READY" == "true" ]] || fail "Timed out waiting for $URL."

open -a "Google Chrome" "$URL"
printf '[staia-website] Serving %s at %s\n' "$SITE_DIR" "$URL"
printf '[staia-website] Built site directory: %s\n' "$SITE_DIR"
printf '[staia-website] Press Ctrl-C to stop.\n'
wait "$SERVER_PID"
