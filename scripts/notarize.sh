#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to a stored notarytool keychain profile}"
APP_DIR="$PWD/dist/MihomoGUI.app"
codesign --verify --deep --strict "$APP_DIR"
if ! codesign -d --verbose=4 "$APP_DIR" 2>&1 | /usr/bin/grep -q '^Authority=Developer ID Application:'; then
  printf 'Notarization requires a Developer ID Application signature.\n' >&2
  exit 1
fi
umask 077
NOTARY_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/MihomoGUI-notary.XXXXXX")"
trap 'rm -rf "$NOTARY_STAGE"' EXIT
mkdir -p .build
NOTARY_FLAGS=(--keychain-profile "$NOTARY_PROFILE")
if [ -n "${NOTARY_KEYCHAIN:-}" ]; then NOTARY_FLAGS+=(--keychain "$NOTARY_KEYCHAIN"); fi
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$NOTARY_STAGE/application.zip"
xcrun notarytool submit "$NOTARY_STAGE/application.zip" "${NOTARY_FLAGS[@]}" \
  --wait --timeout 30m --output-format json > .build/notarization-result.json
python3 - <<'PY'
import json
from pathlib import Path
result = json.loads(Path('.build/notarization-result.json').read_text())
if result.get('status') != 'Accepted':
    raise SystemExit('Notarization was not accepted; inspect .build/notarization-result.json and the notarytool log.')
PY
xcrun stapler staple "$APP_DIR"
xcrun stapler validate "$APP_DIR"
spctl --assess --type execute --verbose=2 "$APP_DIR"
