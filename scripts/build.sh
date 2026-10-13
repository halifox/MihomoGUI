#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
BUILD_DIR="$PWD/.build/manual"
mkdir -p "$BUILD_DIR"
export CLANG_MODULE_CACHE_PATH="$BUILD_DIR/module-cache"
SWIFT_FLAGS=(-module-cache-path "$BUILD_DIR/module-cache" -target "$(uname -m)-apple-macosx13.0")
# Direct swiftc also works on machines whose Command Line Tools have a broken SwiftPM.
swiftc "${SWIFT_FLAGS[@]}" -O -parse-as-library -emit-module -emit-object -whole-module-optimization \
  -module-name ClashCore -I Sources/CSQLite Sources/ClashCore/*.swift \
  -emit-module-path "$BUILD_DIR/ClashCore.swiftmodule" -o "$BUILD_DIR/ClashCore.o"
swiftc "${SWIFT_FLAGS[@]}" -O -parse-as-library -I "$BUILD_DIR" -I Sources/CSQLite \
  Sources/ClashStats/*.swift "$BUILD_DIR/ClashCore.o" -lsqlite3 -o "$BUILD_DIR/clash-stats"
swiftc "${SWIFT_FLAGS[@]}" -O -parse-as-library -I "$BUILD_DIR" -I Sources/CSQLite \
  Sources/ClashDesk/*.swift "$BUILD_DIR/ClashCore.o" -lsqlite3 -o "$BUILD_DIR/ClashDesk"
APP_DIR="$PWD/dist/ClashDesk.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Helpers"
cp "$BUILD_DIR/ClashDesk" "$APP_DIR/Contents/MacOS/ClashDesk"
cp "$BUILD_DIR/clash-stats" "$APP_DIR/Contents/Helpers/clash-stats"
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>ClashDesk</string>
<key>CFBundleIdentifier</key><string>local.clashdesk.app</string>
<key>CFBundleName</key><string>ClashDesk</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.2.0</string>
<key>CFBundleVersion</key><string>2</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP_DIR/Contents/Helpers/clash-stats"
codesign --force --sign - "$APP_DIR"
printf 'Built: %s\n' "$APP_DIR"
printf 'If ClashDesk is already running, quit with Cmd-Q and reopen the app to load this build.\n'
