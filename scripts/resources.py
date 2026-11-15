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


if __name__ == "__main__":
    if sys.argv[1:] == ["update"]:
        update()
    elif sys.argv[1:] == ["download"]:
        download()
    else:
        sys.exit("Usage: python3 scripts/resources.py update|download")
