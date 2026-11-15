#!/usr/bin/env python3
"""Check provenance coverage and whether reviewed field artifacts have changed."""
import hashlib
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent
record = json.loads((root / 'docs/field-sources.json').read_text())
if record['schema_version'] != 1 or not re.fullmatch(r'\d{4}-\d{2}-\d{2}', record['review_date']):
    raise SystemExit('Unsupported field provenance format')
for key in ('documentation_commit', 'core_commit'):
    if not re.fullmatch('[0-9a-f]{40}', record[key]):
        raise SystemExit('Expected immutable source commits')
references = set()
for name in ('DocSchemas.swift', 'HelpDocs.swift'):
    source = (root / 'Sources/MihomoGUICore' / name).read_text()
    references.update(re.findall(r'"document": "([^"]+)"', source))
    references.update(re.findall(r'^  "([^"|]+)\|', source, re.M))
documents = record['documents']
paths = [item['path'] for item in documents]
if len(set(paths)) != len(paths) or set(paths) != {'docs/config/' + name for name in references}:
    raise SystemExit('Referenced field documents differ from the reviewed source inventory')
for item in documents:
    if not re.fullmatch('[0-9a-f]{40}', item['git_blob_sha1']) or not re.fullmatch('[0-9a-f]{64}', item['sha256']):
        raise SystemExit('Invalid source file identity')
expected = {'Sources/MihomoGUICore/' + name for name in ('DocSchemas.swift', 'HelpDocs.swift', 'Groups.swift')}
if set(record['reviewed_artifacts_sha256']) != expected:
    raise SystemExit('Incomplete reviewed field artifact inventory')
for name, digest in record['reviewed_artifacts_sha256'].items():
    if hashlib.sha256((root / name).read_bytes()).hexdigest() != digest:
        raise SystemExit('Field artifact changed; review and update source provenance: ' + name)
source = (root / 'Sources/MihomoGUICore/DocSchemas.swift').read_text()
version = re.search(r'^public let configurationCoreVersion = "([^"]+)"$', source, re.M)
if not version or 'v' + version[1] != record['core_version']:
    raise SystemExit('Field review targets a different core version')
print(f'PASS: {len(documents)} pinned field source documents and reviewed artifact identities')
