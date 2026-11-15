#!/usr/bin/env python3
"""Check packaged architecture and deployment metadata; this is not a runtime test."""
import platform
import plistlib
import re
import subprocess
import sys
from pathlib import Path

app = Path(sys.argv[1] if len(sys.argv) > 1 else 'dist/MihomoGUI.app')
architecture = sys.argv[2] if len(sys.argv) > 2 else platform.machine()
if architecture not in ('arm64', 'x86_64'):
    raise SystemExit('Unsupported architecture')
with (app / 'Contents/Info.plist').open('rb') as source:
    info = plistlib.load(source)
if info.get('LSMinimumSystemVersion') != '13.0':
    raise SystemExit('Expected macOS 13.0 minimum in Info.plist')
for relative in ('MacOS/MihomoGUI', 'Helpers/MihomoGUIHelper', 'Helpers/mihomo'):
    binary = app / 'Contents' / relative
    architectures = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).split()
    if architectures != [architecture]:
        raise SystemExit(f'{relative}: expected only {architecture}, found {architectures}')
    metadata = subprocess.check_output(['xcrun', 'vtool', '-show-build', str(binary)], text=True)
    platforms = re.findall(r'^\s*platform\s+(\S+)', metadata, re.M)
    versions = re.findall(r'^\s*minos\s+(\d+(?:\.\d+)*)', metadata, re.M)
    if platforms != ['MACOS'] or len(versions) != 1:
        raise SystemExit(f'{relative}: missing or ambiguous macOS deployment metadata')
    version = tuple(int(part) for part in versions[0].split('.'))
    if (version + (0, 0))[:3] > (13, 0, 0):
        raise SystemExit(f'{relative}: requires macOS {versions[0]}, newer than advertised minimum')
    print(f'PASS: {relative}: {architecture}, minimum macOS {versions[0]}')
print('Metadata checks passed; runtime compatibility still requires tests on each supported system.')
