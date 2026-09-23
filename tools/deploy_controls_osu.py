#!/usr/bin/env python3
"""Deploy the verified adaptive Evil Wizard input/browser build to OSU.

Scope:
- replaces only ~/public_html/games/evil-wizard
- creates a full rollback backup first
- does not modify the portfolio, Learning Platform, Battle Chess, or Geometric AI
"""
from __future__ import annotations

import hashlib
import shutil
import tempfile
from datetime import datetime
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

BUILD_COMMIT = "f9fdf4dc2fd29dcd6d97bce815f75afdd2c81fca"
ARTIFACT_ID = 10778440736
ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    f"actions/artifacts/{ARTIFACT_ID}.zip"
)
ARCHIVE_SHA256 = "8d1cef6a647154b7e1f5b731fcb621fa3c426f952ecbc36e898435c31d9af144"
REQUIRED = {
    "play.html", "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000

def fail(message: str) -> None:
    raise SystemExit("STOP: " + message)

def verify_text(files: dict[str, bytes]) -> None:
    play = files["play.html"].decode("utf-8")
    console = files["console.html"].decode("utf-8")
    controls = files["console-champions.js"].decode("utf-8")

    for marker in (
        "compactTouchDevice",
        "knownHandheldPC",
        "navigator.getGamepads",
        "Controller detected",
        "mode=handheld",
    ):
        if marker not in play:
            fail(f"Launcher verification failed: missing {marker}")

    for marker in (
        "orientation-gate",
        "Turn your device sideways",
        'src="./console-champions.js"',
        "data-evil-wizard-console",
    ):
        if marker not in console:
            fail(f"Handheld shell verification failed: missing {marker}")

    for marker in (
        "HOW TO PLAY / CONTROLS",
        "Xbox-compatible controller",
        "Desktop keyboard &amp; mouse",
        "Handheld console",
    ):
        if marker not in controls:
            fail(f"Control-guide verification failed: missing {marker}")

def main() -> None:
    home = Path.home()
    live = home / "public_html" / "games" / "evil-wizard"
    games = live.parent

    if not live.is_dir() or not (live / "index.html").is_file():
        fail(f"Existing Evil Wizard web build is not intact at {live}")

    print("Verified Evil Wizard build:", BUILD_COMMIT)
    print("Downloading checksum-pinned GitHub Actions artifact...", flush=True)
    request = Request(ARCHIVE_URL, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=120) as response:
        archive_bytes = response.read(MAX_ARCHIVE_BYTES + 1)

    if len(archive_bytes) > MAX_ARCHIVE_BYTES:
        fail("Build archive is unexpectedly large.")
    digest = hashlib.sha256(archive_bytes).hexdigest()
    if digest != ARCHIVE_SHA256:
        fail(f"Build checksum mismatch: {digest}")

    with ZipFile(BytesIO(archive_bytes)) as bundle:
        entries = bundle.infolist()
        names = {entry.filename for entry in entries}
        if names != REQUIRED or len(entries) != len(REQUIRED):
            fail("Build contents do not match the validated artifact.")
        if any(entry.is_dir() or entry.file_size <= 0 for entry in entries):
            fail("Build contains an empty or invalid file.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            fail("Expanded build is unexpectedly large.")
        if bundle.testzip() is not None:
            fail("Build ZIP integrity test failed.")

        files = {entry.filename: bundle.read(entry) for entry in entries}
        verify_text(files)

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = home / f"evil-wizard-pre-input-release-{stamp}"
    print("Creating rollback backup:", backup, flush=True)
    shutil.copytree(live, backup)

    stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-input-", dir=games))
    previous = games / f".evil-wizard-previous-{stamp}"
    swapped = False
    try:
        for name, data in files.items():
            target = stage / name
            target.write_bytes(data)
            target.chmod(0o644)
        stage.chmod(0o755)

        verify_text({name: (stage / name).read_bytes() for name in REQUIRED})

        live.rename(previous)
        stage.rename(live)
        swapped = True

        for name in REQUIRED:
            path = live / name
            if not path.is_file() or path.stat().st_size <= 0:
                raise RuntimeError(f"Live verification failed for {name}")

        verify_text({name: (live / name).read_bytes() for name in REQUIRED})
        shutil.rmtree(previous)
    except BaseException as exc:
        if swapped:
            if live.exists():
                shutil.rmtree(live, ignore_errors=True)
            if previous.exists():
                previous.rename(live)
        elif stage.exists():
            shutil.rmtree(stage, ignore_errors=True)
        fail(f"Deployment failed and was rolled back: {exc}")

    print("")
    print("EVIL WIZARD ADAPTIVE INPUT RELEASE DEPLOYED")
    print("Build:", BUILD_COMMIT)
    print("Play: https://web.engr.oregonstate.edu/~randjosh/games/evil-wizard/play.html")
    print("Backup:", backup)
    print("Portfolio and Learning Platform: unchanged")

if __name__ == "__main__":
    main()
