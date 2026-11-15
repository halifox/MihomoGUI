#!/usr/bin/env python3
"""Pin upstream release assets or download the exact assets in the manifest."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "resources/manifest.json"
RECEIPTS = ROOT / ".build/resource-receipts.json"
VERIFIED = ROOT / ".build/verified-resources.json"
SOURCES = [
    ("MetaCubeX/mihomo", "latest", {"core/arm64/mihomo": None}),
    ("MetaCubeX/meta-rules-dat", "tags/latest", {
        "geodata/Country.mmdb": "country.mmdb", "geodata/geoip.dat": "geoip.dat",
        "geodata/geosite.dat": "geosite.dat"}),
    ("xishang0128/geoip", "latest", {"geodata/ASN.mmdb": "GeoLite2-ASN.mmdb"}),
]


def metadata(repository, release):
    request = urllib.request.Request(
        f"https://api.github.com/repos/{repository}/releases/{release}",
        headers={"Accept": "application/vnd.github+json"})
    if os.environ.get("GH_TOKEN"):
        request.add_header("Authorization", "Bearer " + os.environ["GH_TOKEN"])
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def update():
    assets = {}
    for repository, release, files in SOURCES:
        info = metadata(repository, release)
        for target, name in files.items():
            if name is None:
                name = f"mihomo-darwin-arm64-{info['tag_name']}.gz"
            asset = next(a for a in info["assets"] if a["name"] == name)
            digest = asset.get("digest", "")
            if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest or ""):
                raise ValueError(f"Missing SHA-256 for {repository}/{name}")
            assets[target] = {
                "repository": repository, "tag": info["tag_name"],
                "asset_id": asset["id"], "name": name,
                "url": asset["browser_download_url"], "sha256": digest[7:]}
    MANIFEST.write_text(json.dumps(assets, indent=2) + "\n")


def download():
    assets = json.loads(MANIFEST.read_text())
    expected = {target for _, _, files in SOURCES for target in files}
    if set(assets) != expected:
        raise ValueError("Resource manifest must contain exactly the five required assets")
    receipts = {}
    for target, asset in assets.items():
        if not asset["url"].startswith("https://github.com/" + asset["repository"] + "/releases/download/"):
            raise ValueError("Invalid resource URL")
        destination = ROOT / "resources" / target
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory() as temporary:
            archive = Path(temporary) / "asset"
            if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", asset["repository"]):
                raise ValueError("Invalid upstream repository")
            if type(asset["asset_id"]) is not int or asset["asset_id"] <= 0:
                raise ValueError("Invalid upstream asset ID")
            with archive.open("wb") as output:
                subprocess.run(["gh", "api", "-H", "Accept: application/octet-stream",
                                f"repos/{asset['repository']}/releases/assets/{asset['asset_id']}"],
                               stdout=output, check=True)
            data = archive.read_bytes()
            if not data or hashlib.sha256(data).hexdigest() != asset["sha256"]:
                raise ValueError(f"Resource changed or corrupted: {target}; update the manifest")
            if asset["name"].endswith(".gz"):
                data = gzip.decompress(data)
            if not data:
                raise ValueError(f"Empty resource: {target}")
            staged = Path(temporary) / "resource"
            staged.write_bytes(data)
            if target.startswith("core/"):
                subprocess.run(["/usr/bin/lipo", str(staged), "-verify_arch", "arm64"], check=True)
                staged.chmod(0o755)
            shutil.copy2(staged, destination)
            receipts[target] = {"asset": asset, "source_sha256": hashlib.sha256(data).hexdigest()}
    RECEIPTS.parent.mkdir(parents=True, exist_ok=True)
    temporary = RECEIPTS.with_suffix(".tmp")
    temporary.write_text(json.dumps(receipts, indent=2) + "\n")
    temporary.replace(RECEIPTS)


def file_digest(path):
    result = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def resource_targets(architecture):
    if architecture not in ("arm64", "x86_64"):
        raise ValueError("Unsupported resource architecture")
    return [f"core/{architecture}/mihomo"] + ["geodata/" + name for name in
            ("Country.mmdb", "geoip.dat", "geosite.dat", "ASN.mmdb")]


def verify(architecture):
    assets = json.loads(MANIFEST.read_text())
    targets = resource_targets(architecture)
    hashes = {}
    for target in targets:
        path = ROOT / "resources" / target
        if not path.is_file() or path.stat().st_size == 0:
            raise ValueError(f"Missing resource: {target}")
        hashes[target] = file_digest(path)
    receipts = json.loads(RECEIPTS.read_text()) if RECEIPTS.exists() else {}
    pinned = all(target in assets and receipts.get(target, {}).get("asset") == assets[target]
                 and receipts[target].get("source_sha256") == hashes[target] for target in targets)
    if not pinned and os.environ.get("ALLOW_UNVERIFIED_RESOURCES") != "1":
        raise ValueError("Resources do not match verified download receipts; run resources.py download. "
                         "Manual local resources require ALLOW_UNVERIFIED_RESOURCES=1 and are labeled unverified.")
    state = {"schema_version": 1, "architecture": architecture,
             "verification": "pinned-source-sha256" if pinned else "local-unverified", "assets": {}}
    for target in targets:
        entry = {"source_sha256": hashes[target]}
        if pinned:
            entry["source_asset"] = assets[target]
        state["assets"][target] = entry
    VERIFIED.parent.mkdir(parents=True, exist_ok=True)
    temporary = VERIFIED.with_suffix(".tmp")
    temporary.write_text(json.dumps(state, indent=2) + "\n")
    temporary.replace(VERIFIED)
    print("Resource verification: " + state["verification"])


def bundle_manifest(architecture, app, signed=False):
    state = json.loads(VERIFIED.read_text())
    if state.get("architecture") != architecture or set(state["assets"]) != set(resource_targets(architecture)):
        raise ValueError("Verified resource snapshot does not match build architecture")
    app = Path(app)
    for target, entry in state["assets"].items():
        core = target.startswith("core/")
        path = app / ("Contents/Helpers/mihomo" if core else "Contents/Resources/" + target)
        actual = file_digest(path)
        if (not signed or not core) and actual != entry["source_sha256"]:
            raise ValueError(f"Packaged resource changed after verification: {target}")
        if signed:
            entry["bundled_sha256"] = actual
            entry["transformation"] = "codesign" if core else "copy"
    if signed:
        subprocess.run(["/usr/bin/codesign", "--verify", "--strict", str(app / "Contents/Helpers/mihomo")], check=True)
        (app / "Contents/Resources/resources-manifest.json").write_text(json.dumps(state, indent=2) + "\n")


if __name__ == "__main__":
    if sys.argv[1:] == ["update"]:
        update()
    elif sys.argv[1:] == ["download"]:
        download()
    elif len(sys.argv) == 3 and sys.argv[1] == "verify":
        verify(sys.argv[2])
    elif len(sys.argv) == 4 and sys.argv[1] in ("verify-staged", "bundle-manifest"):
        bundle_manifest(sys.argv[2], sys.argv[3], signed=sys.argv[1] == "bundle-manifest")
    else:
        sys.exit("Usage: python3 scripts/resources.py update|download|verify ARCH|verify-staged ARCH APP|bundle-manifest ARCH APP")
