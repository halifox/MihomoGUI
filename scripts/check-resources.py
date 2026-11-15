#!/usr/bin/env python3
"""Check resource identity and packaging invariants using temporary fixtures."""
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

sys.dont_write_bytecode = True

spec = importlib.util.spec_from_file_location('resources', Path(__file__).with_name('resources.py'))
assert spec and spec.loader
resources = importlib.util.module_from_spec(spec)
spec.loader.exec_module(resources)


def rejected(operation):
    try:
        operation()
    except ValueError:
        return
    raise AssertionError('Mismatched resource accepted')


with tempfile.TemporaryDirectory(prefix='MihomoGUI-resources-') as temporary:
    root = Path(temporary)
    resources.ROOT = root
    resources.MANIFEST = root / 'resources/manifest.json'
    resources.RECEIPTS = root / '.build/resource-receipts.json'
    resources.VERIFIED = root / '.build/verified-resources.json'
    assets, receipts = {}, {}
    targets = resources.resource_targets('arm64')
    for target in targets:
        data = ('fixture ' + target).encode()
        path = root / 'resources' / target
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        archive = gzip.compress(data) if target.startswith('core/') else data
        asset = {'name': 'fixture.gz' if target.startswith('core/') else 'fixture',
                 'sha256': hashlib.sha256(archive).hexdigest(), 'asset_id': 1, 'tag': 'fixture'}
        assets[target] = asset
        receipts[target] = {'asset': asset, 'source_sha256': hashlib.sha256(data).hexdigest()}
    resources.MANIFEST.write_text(json.dumps(assets))
    resources.RECEIPTS.parent.mkdir()
    resources.RECEIPTS.write_text(json.dumps(receipts))
    os.environ.pop('ALLOW_UNVERIFIED_RESOURCES', None)
    resources.verify('arm64')
    state = json.loads(resources.VERIFIED.read_text())
    assert state['verification'] == 'pinned-source-sha256'
    app = root / 'Fixture.app'
    for target in targets:
        destination = app / ('Contents/Helpers/mihomo' if target.startswith('core/') else 'Contents/Resources/' + target)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / 'resources' / target, destination)
    resources.bundle_manifest('arm64', app)
    (app / 'Contents/Resources/geodata/Country.mmdb').write_bytes(b'changed')
    rejected(lambda: resources.bundle_manifest('arm64', app))
    changed = root / 'resources/geodata/Country.mmdb'
    original = changed.read_bytes()
    changed.write_bytes(b'changed')
    rejected(lambda: resources.verify('arm64'))
    changed.write_bytes(original)
    assets[targets[0]]['tag'] = 'different'
    resources.MANIFEST.write_text(json.dumps(assets))
    rejected(lambda: resources.verify('arm64'))
    resources.RECEIPTS.unlink()
    rejected(lambda: resources.verify('arm64'))
    os.environ['ALLOW_UNVERIFIED_RESOURCES'] = '1'
    resources.verify('arm64')
    manual = json.loads(resources.VERIFIED.read_text())
    assert manual['verification'] == 'local-unverified'
    assert all('source_asset' not in entry for entry in manual['assets'].values())
    rejected(lambda: resources.verify('unsupported'))
print('PASS: source receipts, staged bytes, manifest changes and explicitly unverified local resources')
