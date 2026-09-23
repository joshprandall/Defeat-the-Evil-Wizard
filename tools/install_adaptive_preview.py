#!/usr/bin/env python3
"""Install the checksum-pinned adaptive Evil Wizard preview in a separate OSU folder."""
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
    "actions/artifacts/10731261290.zip"
)
ARCHIVE_SHA256 = "5642676d11c4ecfb9bb4778144b857a7fdce259f519f259ecf9e5f212b62dc0f"
PREVIEW_FOLDER = "evil-wizard-adaptive-preview-v23"
REQUIRED = {
    "play.html", "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000

def install(archive_bytes: bytes, site: Path) -> Path:
    if len(archive_bytes) > MAX_ARCHIVE_BYTES:
        raise ValueError("Build download exceeds the expected size; nothing changed.")
    if hashlib.sha256(archive_bytes).hexdigest() != ARCHIVE_SHA256:
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

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-adaptive-", dir=games))
        try:
            for entry in entries:
                content = bundle.read(entry)
                destination = stage / entry.filename
                destination.write_bytes(content)
                destination.chmod(0o644)
                if hashlib.sha256(destination.read_bytes()).digest() != hashlib.sha256(content).digest():
                    raise OSError(f"Readback failed for {entry.filename}")
            stage.chmod(0o755)
            stage.rename(target)
        except BaseException:
            shutil.rmtree(stage, ignore_errors=True)
            raise
    return target

def main() -> None:
    parser = argparse.ArgumentParser(description="Install adaptive Evil Wizard preview")
    parser.add_argument("--archive", type=Path, help="Use an already downloaded ZIP")
    parser.add_argument("--site", type=Path, default=Path.home() / "public_html")
    args = parser.parse_args()

    if args.archive:
        data = args.archive.read_bytes()
    else:
        print("Downloading checksum-verified adaptive Evil Wizard preview…", flush=True)
        request = Request(ARCHIVE_URL, headers={"User-Agent": "Mozilla/5.0"})
        with urlopen(request, timeout=120) as response:
            data = response.read(MAX_ARCHIVE_BYTES + 1)

    target = install(data, args.site)
    url = "https://web.engr.oregonstate.edu/~randjosh/games/" + target.name + "/play.html"
    print("\nADAPTIVE PREVIEW READY:")
    print(url)
    print("\nMobile/tablet -> handheld console")
    print("Desktop/laptop -> borderless keyboard Web game")
    print("First tap/key requests browser fullscreen; Esc exits where supported.")
    print("\nNo existing game or portfolio file was replaced.")

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
