#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
SECONDS=0
VERSION="$(cat VERSION)"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid VERSION: expected major.minor.patch\n' >&2
  exit 1
fi
trap 'printf "Build failed after %ss (line %s).\n" "$SECONDS" "$LINENO" >&2' ERR
printf '[1/6] Checking bundled resources and architecture...\n'
ARCH="$(uname -m)"
CORE_FILE="$PWD/resources/core/$ARCH/mihomo"
GEO_DIR="$PWD/resources/geodata"
for resource in "$PWD/resources/AppIcon.icns" "$CORE_FILE" "$GEO_DIR/Country.mmdb" "$GEO_DIR/geoip.dat" "$GEO_DIR/geosite.dat" "$GEO_DIR/ASN.mmdb"; do
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
printf '[2/6] Compiling MihomoCore...\n'
swiftc "${SWIFT_FLAGS[@]}" -O -parse-as-library -emit-module -emit-object -whole-module-optimization \
  -module-name MihomoCore Sources/MihomoCore/*.swift \
  -emit-module-path "$BUILD_DIR/MihomoCore.swiftmodule" -o "$BUILD_DIR/MihomoCore.o"
printf '[3/6] Compiling Mihomo...\n'
swiftc "${SWIFT_FLAGS[@]}" -O -I "$BUILD_DIR" \
  Sources/MihomoHelper/*.swift "$BUILD_DIR/MihomoCore.o" -o "$BUILD_DIR/mihomo-helper"
swiftc "${SWIFT_FLAGS[@]}" -O -parse-as-library -I "$BUILD_DIR" \
  Sources/Mihomo/*.swift "$BUILD_DIR/MihomoCore.o" -o "$BUILD_DIR/mihomo-app"
printf '[4/6] Packaging application and bundled resources...\n'
APP_DIR="$PWD/dist/mihomo.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Helpers" "$APP_DIR/Contents/Resources/geodata"
cp "$BUILD_DIR/mihomo-app" "$APP_DIR/Contents/MacOS/mihomo-app"
cp resources/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"
cp -R resources/licenses "$APP_DIR/Contents/Resources/"
cp resources/manifest.json "$APP_DIR/Contents/Resources/resources-manifest.json"
cp "$BUILD_DIR/mihomo-helper" "$APP_DIR/Contents/Helpers/mihomo-helper"
cp "$CORE_FILE" "$APP_DIR/Contents/Helpers/mihomo"
chmod 755 "$APP_DIR/Contents/Helpers/mihomo"
for name in Country.mmdb geoip.dat geosite.dat ASN.mmdb; do
  cp "$GEO_DIR/$name" "$APP_DIR/Contents/Resources/geodata/$name"
done
cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>mihomo-app</string>
<key>CFBundleIdentifier</key><string>local.mihomo.app</string>
<key>CFBundleName</key><string>mihomo</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$VERSION</string>
<key>CFBundleVersion</key><string>$VERSION</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
printf '[5/6] Signing application and helpers...\n'
codesign --force --sign - "$APP_DIR/Contents/Helpers/mihomo"
codesign --force --sign - --options runtime "$APP_DIR/Contents/Helpers/mihomo-helper"
codesign --force --sign - --options runtime "$APP_DIR"
printf '[6/6] Build completed in %ss.\n' "$SECONDS"
printf 'Built: %s\n' "$APP_DIR"
printf 'If Mihomo is already running, quit with Cmd-Q and reopen the app to load this build.\n'
