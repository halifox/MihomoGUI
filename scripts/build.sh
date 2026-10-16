#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
ARCH="$(uname -m)"
CORE_FILE="$PWD/resources/core/$ARCH/mihomo"
GEO_DIR="$PWD/resources/geodata"
for resource in "$CORE_FILE" "$GEO_DIR/Country.mmdb" "$GEO_DIR/geoip.dat" "$GEO_DIR/geosite.dat" "$GEO_DIR/ASN.mmdb"; do
  if [ ! -s "$resource" ]; then
    printf 'Missing bundled resource: %s\nSee resources/README.md for required files.\n' "$resource" >&2
    exit 1
  fi
done
if ! /usr/bin/lipo "$CORE_FILE" -verify_arch "$ARCH" >/dev/null 2>&1; then
  printf 'Bundled mihomo must be a macOS executable supporting %s: %s\n' "$ARCH" "$CORE_FILE" >&2
  exit 1
fi
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
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Helpers" "$APP_DIR/Contents/Resources/geodata"
cp "$BUILD_DIR/ClashDesk" "$APP_DIR/Contents/MacOS/ClashDesk"
cp "$BUILD_DIR/clash-stats" "$APP_DIR/Contents/Helpers/clash-stats"
cp "$CORE_FILE" "$APP_DIR/Contents/Helpers/mihomo"
chmod 755 "$APP_DIR/Contents/Helpers/mihomo"
for name in Country.mmdb geoip.dat geosite.dat ASN.mmdb; do
  cp "$GEO_DIR/$name" "$APP_DIR/Contents/Resources/geodata/$name"
done
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>ClashDesk</string>
<key>CFBundleIdentifier</key><string>local.clashdesk.app</string>
<key>CFBundleName</key><string>ClashDesk</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.5.0</string>
<key>CFBundleVersion</key><string>5</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP_DIR/Contents/Helpers/clash-stats"
codesign --force --sign - "$APP_DIR/Contents/Helpers/mihomo"
codesign --force --sign - "$APP_DIR"
printf 'Built: %s\n' "$APP_DIR"
printf 'If ClashDesk is already running, quit with Cmd-Q and reopen the app to load this build.\n'
