#!/usr/bin/env python3
"""Install a checksum-pinned Evil Wizard visual preview in a new OSU game folder."""
from __future__ import annotations

import argparse
import hashlib
import shutil
import tempfile
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    "actions/artifacts/10725595005.zip"
)
ARCHIVE_SHA256 = "d4389e2c17d3f370a1bba7ce75100207bc2e045555ae7109da519f583a86737f"
PREVIEW_FOLDER = "evil-wizard-visual-polish-preview-v22"
REQUIRED = {
    "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000


def install(archive_bytes: bytes, site: Path) -> Path:
    if len(archive_bytes) > MAX_ARCHIVE_BYTES:
        raise ValueError("Build download exceeds the expected size; nothing changed.")
    digest = hashlib.sha256(archive_bytes).hexdigest()
    if digest != ARCHIVE_SHA256:
        raise ValueError("Build checksum mismatch; nothing changed.")

    games = site / "games"
    live = games / "evil-wizard"
    if not games.is_dir() or not live.is_dir() or not (live / "index.html").is_file():
        raise ValueError("Existing live game not found; nothing changed.")
    target = games / PREVIEW_FOLDER
    if target.exists():
        raise ValueError(f"Preview folder already exists: {target}. Nothing replaced.")

    with ZipFile(BytesIO(archive_bytes)) as bundle:
        entries = bundle.infolist()
        if {entry.filename for entry in entries} != REQUIRED or len(entries) != len(REQUIRED):
            raise ValueError("Unexpected build contents; nothing changed.")
        if any(entry.is_dir() or entry.file_size <= 0 for entry in entries):
            raise ValueError("Missing or empty game asset; nothing changed.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            raise ValueError("Expanded build exceeds the expected size; nothing changed.")
        if bundle.testzip() is not None:
            raise ValueError("Corrupt build archive; nothing changed.")

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-preview-", dir=games))
        try:
            for entry in entries:
                content = bundle.read(entry)
                destination = stage / entry.filename
                destination.write_bytes(content)
                destination.chmod(0o644)
                if hashlib.sha256(destination.read_bytes()).digest() != hashlib.sha256(content).digest():
                    raise OSError(f"Readback failed for {entry.filename}")
            stage.chmod(0o755)
            if target.exists():
                raise FileExistsError(f"Preview appeared during install: {target}")
            stage.rename(target)
        except BaseException:
            shutil.rmtree(stage, ignore_errors=True)
            raise
    return target


def main() -> None:
    parser = argparse.ArgumentParser(description="Install a separate Evil Wizard visual preview")
    parser.add_argument("--archive", type=Path, help="Use an already downloaded ZIP (offline test)")
    parser.add_argument("--site", type=Path, default=Path.home() / "public_html")
    args = parser.parse_args()
    if args.archive:
        data = args.archive.read_bytes()
    else:
        print("Downloading checksum-verified Evil Wizard visual preview…", flush=True)
        request = Request(ARCHIVE_URL, headers={"User-Agent": "Mozilla/5.0"})
        with urlopen(request, timeout=120) as response:
            data = response.read(MAX_ARCHIVE_BYTES + 1)
    target = install(data, args.site)
    url = "https://web.engr.oregonstate.edu/~randjosh/games/" + target.name
    print("\nPREVIEW READY — HANDHELD:\n" + url + "/console.html")
    print("\nREGULAR WEB PREVIEW:\n" + url + "/index.html")
    print("\nNo existing game or portfolio file was replaced.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
