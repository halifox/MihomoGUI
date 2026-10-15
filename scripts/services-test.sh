#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
BUILD_DIR="$PWD/.build/manual"
swiftc -module-cache-path "$BUILD_DIR/module-cache" -target "$(uname -m)-apple-macosx13.0" \
  -parse-as-library -I "$BUILD_DIR" -I Sources/CSQLite \
  Sources/ClashDesk/Services.swift Tests/Integration/ServiceTests.swift "$BUILD_DIR/ClashCore.o" \
  -lsqlite3 -o "$BUILD_DIR/services-test"
"$BUILD_DIR/services-test"
python3 - <<'PY'
import os, pathlib, subprocess, tempfile
binary = pathlib.Path('.build/manual/clash-stats').resolve()
with tempfile.TemporaryDirectory() as directory:
    log = pathlib.Path(directory) / 'core.log'
    subprocess.run([str(binary), '--log-stream', str(log), '--log-user', str(os.getuid()), str(os.getgid())], input=b'x' * (3 * 1024 * 1024), check=True)
    assert log.stat().st_size <= 1024 * 1024
    assert pathlib.Path(str(log) + '.1').stat().st_size <= 1024 * 1024
    assert log.stat().st_mode & 0o777 == 0o600
    rejected = subprocess.run([str(binary), '--log-stream', str(log), '--log-user', '0', '0'], input=b'rejected', capture_output=True)
    assert rejected.returncode != 0
    print('PASS: service logs rotate at 1 MiB and retain private permissions')
PY
