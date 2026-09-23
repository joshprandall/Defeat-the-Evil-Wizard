#!/usr/bin/env python3
"""Install the checksum-pinned iPhone/WebView regression preview in a separate OSU folder."""
from __future__ import annotations

import hashlib
import shutil
import tempfile
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    "actions/artifacts/10769702499.zip"
)
ARCHIVE_SHA256 = "32115c730c99549e36227d5aeefe0d21fbae108e461a44ab7de27b04b7487e77"
PREVIEW_FOLDER = "evil-wizard-iphone-fix-preview-v24"
REQUIRED = {
    "play.html", "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000

def install(data: bytes, site: Path) -> Path:
    if len(data) > MAX_ARCHIVE_BYTES:
        raise ValueError("Build archive exceeds expected size; nothing changed.")
    if hashlib.sha256(data).hexdigest() != ARCHIVE_SHA256:
        raise ValueError("Build checksum mismatch; nothing changed.")

    games = site / "games"
    live = games / "evil-wizard"
    if not games.is_dir() or not live.is_dir() or not (live / "play.html").is_file():
        raise ValueError("Existing official Evil Wizard game not found; nothing changed.")

    target = games / PREVIEW_FOLDER
    if target.exists():
        shutil.rmtree(target)

    with ZipFile(BytesIO(data)) as bundle:
        entries = bundle.infolist()
        if {entry.filename for entry in entries} != REQUIRED or len(entries) != len(REQUIRED):
            raise ValueError("Unexpected build contents; nothing changed.")
        if any(entry.is_dir() or entry.file_size <= 0 for entry in entries):
            raise ValueError("Missing or empty game asset; nothing changed.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            raise ValueError("Expanded build exceeds expected size; nothing changed.")
        if bundle.testzip() is not None:
            raise ValueError("Corrupt build ZIP; nothing changed.")

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-iphone-fix-", dir=games))
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
    site = Path.home() / "public_html"
    print("Downloading verified iPhone/WebView fix preview...", flush=True)
    request = Request(ARCHIVE_URL, headers={"User-Agent":"Mozilla/5.0"})
    with urlopen(request, timeout=120) as response:
        data = response.read(MAX_ARCHIVE_BYTES + 1)
    target = install(data, site)
    url = "https://web.engr.oregonstate.edu/~randjosh/games/" + target.name + "/play.html"
    print("\nIPHONE FIX PREVIEW READY:")
    print(url)
    print("\nThis preview leaves the official game and portfolio unchanged.")

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
