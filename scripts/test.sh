#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEST_DIR="$PWD/.build/tests"
mkdir -p "$TEST_DIR"
export CLANG_MODULE_CACHE_PATH="$TEST_DIR/module-cache"
SWIFT_FLAGS=(-module-cache-path "$TEST_DIR/module-cache" -target "$(uname -m)-apple-macosx13.0")
swiftc "${SWIFT_FLAGS[@]}" -enable-testing -parse-as-library -emit-module -emit-object -whole-module-optimization \
  -module-name ClashCore -I Sources/CSQLite Sources/ClashCore/*.swift \
  -emit-module-path "$TEST_DIR/ClashCore.swiftmodule" -o "$TEST_DIR/ClashCore.o"
cat > "$TEST_DIR/main.swift" <<'SWIFT'
#if canImport(XCTest)
import XCTest
XCTMain([testCase(CoreTests.allTests)])
#else
for (name, test) in CoreTests.allTests {
    try test(CoreTests())()
    print("PASS: \(name)")
}
#endif
SWIFT
swiftc "${SWIFT_FLAGS[@]}" -I "$TEST_DIR" -I Sources/CSQLite Tests/ClashCoreTests/*.swift \
  "$TEST_DIR/main.swift" "$TEST_DIR/ClashCore.o" -lsqlite3 -o "$TEST_DIR/core-tests"
"$TEST_DIR/core-tests"
