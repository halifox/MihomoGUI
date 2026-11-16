#!/usr/bin/env python3
"""Exercise publication gates with an isolated gh fixture; never access GitHub."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
run = subprocess.check_output([
    'ruby', '-ryaml', '-e',
    'w=YAML.load_file(ARGV[0]); print w["jobs"]["upload"]["steps"].find { |s| s["name"] == "Upload release archive" }["run"]',
    str(ROOT / '.github/workflows/build.yml'),
], text=True)
subprocess.run(['bash', '-n'], input=run, text=True, check=True)

MOCK = r'''#!/usr/bin/env python3
import hashlib, json, os
from pathlib import Path
import sys
args = sys.argv[1:]
path = Path('state.json')
state = json.loads(path.read_text())
state['calls'].append(args)
def save(): path.write_text(json.dumps(state))
save()
mode = state['mode']
if args[:2] == ['attestation', 'verify']:
    sys.exit(1 if mode == 'invalid-proof' else 0)
if args[0] == 'api' and '/commits/' in args[-1]:
    print(json.dumps({'sha': ('b' if mode == 'changed-tag' else 'a') * 40}))
elif args[0] == 'api' and '--paginate' in args and '--slurp' in args:
    if mode == 'transport': sys.exit(1)
    if mode == 'forbidden':
        print('{}')
        sys.exit(1)
    if mode == 'invalid-state': print('{}')
    elif mode == 'duplicate-drafts': print(json.dumps([[state['release'], state['release']]]))
    elif mode == 'paged-draft':
        print(json.dumps([[{'id': 0, 'tag_name': 'v0.9.0', 'draft': False, 'assets': []}], [state['release']]]))
    else: print(json.dumps([[state['release']] if state['release'] else []]))
elif args[:2] == ['release', 'create']:
    assert '--draft' in args and '--verify-tag' in args
    assert state['release'] is None
    state['release'] = {'id': 1, 'tag_name': 'v1.0.0', 'draft': True, 'assets': []}
    save()
elif args[:2] == ['release', 'upload']:
    assert '--clobber' not in args
    for name in [value for value in args if value.startswith('release/')]:
        state['release']['assets'].append({'name': Path(name).name, 'state': 'uploaded',
            'digest': 'sha256:' + hashlib.sha256(Path(name).read_bytes()).hexdigest()})
        if mode == 'partial-upload':
            save()
            sys.exit(1)
    if mode == 'bad-digest': state['release']['assets'][0]['digest'] = 'sha256:' + '0' * 64
    if mode == 'missing-asset': state['release']['assets'].pop()
    save()
elif args[:2] == ['release', 'edit']:
    assert '--draft=false' in args and '--verify-tag' in args
    state['release']['draft'] = False
    save()
else: raise SystemExit('Unexpected gh invocation')
'''

for mode in ['new', 'draft', 'published', 'collision', 'partial-upload', 'bad-digest',
             'missing-asset', 'invalid-proof', 'changed-tag', 'forbidden', 'transport', 'incomplete',
             'bad-checksum', 'invalid-state', 'duplicate-drafts', 'paged-draft',
             'unexpected-asset', 'verification-collision']:
    with tempfile.TemporaryDirectory(prefix='MihomoGUI-release-') as temporary:
        folder = Path(temporary)
        release = folder / 'release'
        release.mkdir()
        archive = 'MihomoGUI-v1.0.0-macos-arm64.dmg'
        (release / archive).write_bytes(b'fixture archive')
        (release / 'BUILD-METADATA.json').write_text(json.dumps({
            'source_commit': 'a' * 40, 'version': '1.0.0', 'architecture': 'arm64'}))
        (release / 'provenance.sigstore.json').write_text('{}')
        (release / 'SHA256SUMS').write_text(''.join(
            hashlib.sha256((release / name).read_bytes()).hexdigest() + '  ' + name + '\n'
            for name in [archive, 'BUILD-METADATA.json']))
        state = {'mode': mode, 'calls': [], 'release': None if mode == 'new' else {
            'id': 1, 'tag_name': 'v1.0.0', 'draft': mode != 'published', 'assets': []}}
        if mode == 'collision': state['release']['assets'] = [{'name': archive}]
        if mode == 'unexpected-asset': state['release']['assets'] = [{'name': 'unrelated.txt'}]
        if mode == 'verification-collision': state['release']['assets'] = [{'name': 'SHA256SUMS'}]
        if mode == 'incomplete': (release / 'provenance.sigstore.json').unlink()
        if mode == 'bad-checksum': (release / archive).write_bytes(b'changed')
        (folder / 'state.json').write_text(json.dumps(state))
        gh = folder / 'gh'
        gh.write_text(MOCK)
        gh.chmod(0o700)
        env = dict(os.environ, PATH=str(folder) + os.pathsep + os.environ['PATH'],
                   GITHUB_REPOSITORY='fixture/project', RELEASE_TAG='v1.0.0')
        result = subprocess.run(['bash', '-euo', 'pipefail', '-c', run], cwd=folder,
                                env=env, capture_output=True, text=True)
        final = json.loads((folder / 'state.json').read_text())
        published = any(args[:2] == ['release', 'edit'] for args in final['calls'])
        if mode in ['new', 'draft', 'paged-draft']:
            assert result.returncode == 0 and published, (mode, result.stderr)
            assert final['release']['draft'] is False
            assert [asset['name'] for asset in final['release']['assets']] == [archive], mode
        else:
            assert result.returncode != 0 and not published, (mode, result.stderr)
        if mode in ['forbidden', 'transport', 'invalid-proof', 'changed-tag', 'incomplete', 'bad-checksum', 'invalid-state', 'duplicate-drafts']:
            assert not any(args[:2] == ['release', 'create'] for args in final['calls']), mode
        if mode in ['collision', 'unexpected-asset', 'verification-collision']:
            assert not any(args[:2] == ['release', 'upload'] for args in final['calls'])
print('PASS: draft publication gates, immutable assets, partial uploads, digests, proof, tags and API failures')
