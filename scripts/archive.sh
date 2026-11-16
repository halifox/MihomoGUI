#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
APP_DIR="$PWD/dist/MihomoGUI.app"
RELEASE_DIR="$PWD/dist/release"
VERSION="$(cat VERSION)"
ARCH="$(uname -m)"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
codesign --verify --deep --strict "$APP_DIR"
test "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP_DIR/Contents/Info.plist")" = "$VERSION"
test ! -L "$RELEASE_DIR"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/MihomoGUI-dmg.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT
ditto "$APP_DIR" "$STAGING_DIR/MihomoGUI.app"
ln -s /Applications "$STAGING_DIR/Applications"
IMAGE="$RELEASE_DIR/MihomoGUI-v$VERSION-macos-$ARCH.dmg"
hdiutil create -volname "MihomoGUI $VERSION" -srcfolder "$STAGING_DIR" -fs HFS+ -format UDZO "$IMAGE"
hdiutil verify "$IMAGE"
python3 - <<'PY'
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess

metadata = {
    'version': Path('VERSION').read_text().strip(),
    'architecture': platform.machine(),
    'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
    'working_tree_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], text=True)),
    'repository': os.environ.get('GITHUB_REPOSITORY'),
    'workflow_commit': os.environ.get('GITHUB_SHA'),
    'workflow_ref': os.environ.get('GITHUB_WORKFLOW_REF'),
    'workflow_run_id': os.environ.get('GITHUB_RUN_ID'),
    'workflow_run_attempt': os.environ.get('GITHUB_RUN_ATTEMPT'),
    'swift_version': subprocess.check_output(['swiftc', '--version'], text=True, stderr=subprocess.STDOUT).strip(),
    'sdk_version': subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-version'], text=True).strip(),
    'resource_manifest_sha256': hashlib.sha256(Path('dist/MihomoGUI.app/Contents/Resources/resources-manifest.json').read_bytes()).hexdigest(),
}
Path('dist/release/BUILD-METADATA.json').write_text(json.dumps(metadata, indent=2, sort_keys=True) + '\n')
PY
(
  cd "$RELEASE_DIR"
  shasum -a 256 *.dmg BUILD-METADATA.json > SHA256SUMS
  shasum -a 256 -c SHA256SUMS
)
