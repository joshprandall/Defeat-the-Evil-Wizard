#!/usr/bin/env python3
"""Install the checksum-pinned early-combat preview in a separate OSU folder."""
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
    "actions/artifacts/10852200511.zip"
)
ARCHIVE_SHA256 = "d8723de57502240345583a8839d74b03bade7fc4636306a0d125065840680044"
PREVIEW_FOLDER = "evil-wizard-combat-preview-v25"
REQUIRED = {
    "play.html", "console.html", "console-champions.js", ".htaccess",
    "index.html", "index.js", "index.wasm", "index.pck",
}
MAX_ARCHIVE_BYTES = 35_000_000
MAX_EXPANDED_BYTES = 70_000_000

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
        entries = [entry for entry in bundle.infolist() if not entry.is_dir()]
        names = {entry.filename for entry in entries}
        if not REQUIRED.issubset(names):
            raise ValueError("Expected game files are missing; nothing changed.")
        if any(
            Path(entry.filename).is_absolute()
            or ".." in Path(entry.filename).parts
            or entry.file_size <= 0
            for entry in entries
        ):
            raise ValueError("Unsafe or empty build entry; nothing changed.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            raise ValueError("Expanded build exceeds expected size; nothing changed.")
        if bundle.testzip() is not None:
            raise ValueError("Corrupt build ZIP; nothing changed.")

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-combat-", dir=games))
        try:
            for entry in entries:
                destination = stage / entry.filename
                destination.parent.mkdir(parents=True, exist_ok=True)
                payload = bundle.read(entry)
                destination.write_bytes(payload)
                destination.chmod(0o644)
            stage.chmod(0o755)
            stage.rename(target)
        except BaseException:
            shutil.rmtree(stage, ignore_errors=True)
            raise
    return target

def main() -> None:
    site = Path.home() / "public_html"
    print("Downloading verified early-combat preview...", flush=True)
    request = Request(ARCHIVE_URL, headers={"User-Agent":"Mozilla/5.0"})
    with urlopen(request, timeout=120) as response:
        data = response.read(MAX_ARCHIVE_BYTES + 1)
    target = install(data, site)
    url = "https://web.engr.oregonstate.edu/~randjosh/games/" + target.name + "/play.html"
    print("\nCOMBAT PREVIEW READY:")
    print(url)
    print("\nExpected first encounter:")
    print("- first Crawler has a visible red health bar")
    print("- point-blank ATTACK connects")
    print("- three ordinary Warrior light hits can defeat it")
    print("- HIT numbers and DEFEATED text are visible")
    print("\nThe official game and portfolio were not changed.")

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
