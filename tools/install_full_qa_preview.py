#!/usr/bin/env python3
"""Install the fully verified Evil Wizard QA build as an isolated OSU preview."""
from __future__ import annotations

import hashlib
import shutil
import stat
import tempfile
from io import BytesIO
from pathlib import Path, PurePosixPath
from urllib.request import Request, urlopen
from zipfile import ZipFile

ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    "actions/artifacts/10850439434.zip"
)
ARCHIVE_SHA256 = "6a9abc301e774482d57bd25c615f6b7f316ac7f3fc7ee9c1783d0f17ef48e266"
PREVIEW_FOLDER = "evil-wizard-full-qa-preview-v25"
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 70_000_000
REQUIRED = {
    "play.html", "console.html", "console-champions.js",
    "index.html", "index.js", "index.wasm", "index.pck", ".htaccess",
}

def _safe_name(name: str) -> bool:
    p = PurePosixPath(name)
    return (
        bool(name)
        and not p.is_absolute()
        and ".." not in p.parts
        and len(p.parts) == 1
        and not name.endswith("/")
    )

def install(data: bytes, site: Path) -> Path:
    if len(data) > MAX_ARCHIVE_BYTES:
        raise ValueError("Build archive exceeds expected size; nothing changed.")
    actual = hashlib.sha256(data).hexdigest()
    if actual != ARCHIVE_SHA256:
        raise ValueError(f"Build checksum mismatch ({actual}); nothing changed.")

    games = site / "games"
    live = games / "evil-wizard"
    if not games.is_dir() or not live.is_dir() or not (live / "play.html").is_file():
        raise ValueError("Existing official Evil Wizard game not found; nothing changed.")

    target = games / PREVIEW_FOLDER
    if target.exists():
        shutil.rmtree(target)

    with ZipFile(BytesIO(data)) as bundle:
        entries = bundle.infolist()
        names = {entry.filename for entry in entries}
        missing = REQUIRED - names
        if missing:
            raise ValueError("Verified build is missing required files: " + ", ".join(sorted(missing)))
        if any(not _safe_name(entry.filename) for entry in entries):
            raise ValueError("Unexpected path inside build ZIP; nothing changed.")
        if any(stat.S_IFMT(entry.external_attr >> 16) == stat.S_IFLNK for entry in entries):
            raise ValueError("Symlinks are not allowed in build ZIP; nothing changed.")
        if any(entry.file_size <= 0 for entry in entries):
            raise ValueError("Empty game asset found; nothing changed.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            raise ValueError("Expanded build exceeds expected size; nothing changed.")
        if bundle.testzip() is not None:
            raise ValueError("Build ZIP failed integrity check; nothing changed.")

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-qa-", dir=games))
        try:
            for entry in entries:
                payload = bundle.read(entry)
                dest = stage / entry.filename
                dest.write_bytes(payload)
                dest.chmod(0o644)
                if hashlib.sha256(dest.read_bytes()).digest() != hashlib.sha256(payload).digest():
                    raise OSError(f"Readback failed for {entry.filename}")
            stage.chmod(0o755)
            stage.rename(target)
        except BaseException:
            shutil.rmtree(stage, ignore_errors=True)
            raise

    return target

def main() -> None:
    site = Path.home() / "public_html"
    print("Downloading checksum-pinned full QA preview...", flush=True)
    req = Request(ARCHIVE_URL, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(req, timeout=120) as response:
        data = response.read(MAX_ARCHIVE_BYTES + 1)
    target = install(data, site)
    url = "https://web.engr.oregonstate.edu/~randjosh/games/" + target.name + "/play.html"
    print("\nFULL QA PREVIEW READY:")
    print(url)
    print("\nTest: first enemies, point-blank attacks, Facebook/Messenger portrait, and Memory Labyrinth.")
    print("Official game and portfolio were not changed.")

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
