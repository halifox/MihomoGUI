#!/usr/bin/env python3
"""Require the reviewed configuration version before executing a bundled core."""
import json
from pathlib import Path
import platform
import re
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
source = (root / 'Sources/MihomoGUICore/DocSchemas.swift').read_text()
versions = re.findall(r'^public let configurationCoreVersion = "(\d+\.\d+\.\d+)"$', source, re.M)
if len(versions) != 1:
    raise SystemExit('Missing or ambiguous configuration compatibility version')
version = versions[0]
architecture = sys.argv[1] if len(sys.argv) > 1 else platform.machine()
if architecture not in ('arm64', 'x86_64'):
    raise SystemExit('Unsupported architecture')
key = f'core/{architecture}/mihomo'
asset = json.loads((root / 'resources/manifest.json').read_text()).get(key)
if asset is not None and asset.get('tag') != 'v' + version:
    raise SystemExit('Pinned core changed: review configuration fields/defaults and compatibility version first')
result = subprocess.run([str(root / 'resources' / key), '-v'], capture_output=True, text=True, timeout=15, check=True)
match = re.match(r'Mihomo Meta v(\d+\.\d+\.\d+) darwin ' + architecture + r'\b', result.stdout)
if not match or match[1] != version:
    raise SystemExit('Bundled core does not match the reviewed configuration version/architecture')
print('PASS: configuration schema and bundled core match mihomo v' + version)
