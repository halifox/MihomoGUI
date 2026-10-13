#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$#" -ne 1 ]; then
  printf 'Usage: bash scripts/integration-test.sh /path/to/mihomo\n' >&2
  exit 1
fi
BUILD_DIR="$PWD/.build/manual"
swiftc -module-cache-path "$BUILD_DIR/module-cache" -target "$(uname -m)-apple-macosx13.0" \
  -parse-as-library -I "$BUILD_DIR" -I Sources/CSQLite Tests/Integration/main.swift \
  "$BUILD_DIR/ClashCore.o" -lsqlite3 -o "$BUILD_DIR/integration-test"
PROXY_TMP="$(mktemp -d)"
python3 Tests/Integration/proxy.py "$PROXY_TMP/port" &
PROXY_PID=$!
trap 'kill "$PROXY_PID" 2>/dev/null || true; wait "$PROXY_PID" 2>/dev/null || true; rm -rf "$PROXY_TMP"' EXIT
for attempt in {1..50}; do
  if [ -s "$PROXY_TMP/port" ]; then break; fi
  sleep 0.1
done
"$BUILD_DIR/integration-test" "$1" "$(cat "$PROXY_TMP/port")"
