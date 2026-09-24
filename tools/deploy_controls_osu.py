#!/usr/bin/env python3
"""Deploy the verified adaptive Evil Wizard input/browser build to OSU.

Scope:
- replaces only ~/public_html/games/evil-wizard
- creates a full rollback backup first
- does not modify the portfolio, Learning Platform, Battle Chess, or Geometric AI
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import tempfile
from datetime import datetime
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

BUILD_COMMIT = "86eec9dbb6682ad6a79a6dd38f0df0d31e2bd702"
ARTIFACT_ID = 10833729782
ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    f"actions/artifacts/{ARTIFACT_ID}.zip"
)
EXPECTED_SHA256 = {
    ".htaccess": "092929636313b35dfc5f1fae97a59aad91f7bec44971997a0a8e74921b1bed25",
    "console-champions.js": "b3fc5fba19f1ea579f5c3e59d9152cef38d8168ef0cc30d7d4ea8ba9b97d6138",
    "console.html": "3267ca05361444d359b150e88dcad5db6605a988e91bba50d876712099a5f359",
    "index.apple-touch-icon.png": "01d4f63e525941e06ce74f5187dad030d20a8d52a07ce365ae4e94af97a3b1f5",
    "index.audio.position.worklet.js": "be33985bc7160d6bf9646f259cd86b259cd67b02ccb297ee5c44f8ac84327bc8",
    "index.audio.worklet.js": "5b476a9c9ce642c0ee4256436d1bc31d9c38f868aca0f9a8e2a57c18d2dec2a3",
    "index.html": "a01117feae9136fe7e054af60f007acc27c6fa8ff5acbad216a998828ac03a43",
    "index.icon.png": "ad3c35ad0facf487c618204bd98db543034fc95224eadc7f08c7a9ff38d5b3b5",
    "index.js": "33c94cb3175f3333b82e2a3be5e8e86f77986f0aa2042b1631f6367a4e5bb6ba",
    "index.pck": "306c05eb6017a9e4dd9c92500b06bc71fbf3d3913b32334ed08797f6dedbbf12",
    "index.png": "3cb4495c0b98dfbe4b663cbf2b6836473572339beb66d902367893162a70be0e",
    "index.wasm": "fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0",
    "play.html": "b59d7b932b4402c9ff17a6189355d5c7aa7ba5a4466684e3ace1d62c4bbbe5ed",
}
REQUIRED = {
    ".htaccess", "play.html", "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000

def fail(message: str) -> None:
    raise SystemExit("STOP: " + message)

def verify_text(files: dict[str, bytes]) -> None:
    play = files["play.html"].decode("utf-8")
    touch = files["console.html"].decode("utf-8")
    model = files["console-champions.js"].decode("utf-8")

    for marker in (
        'data-screen="play"',
        'data-screen="controls"',
        'data-screen="settings"',
        'data-screen="how"',
        'id="touch-map"',
        'id="keyboard-map"',
        'id="gamepad-map"',
        'id="difficulty"',
        'id="master-volume"',
        'id="brightness"',
        "Reset controls to defaults",
        "console.html?",
    ):
        if marker not in play:
            fail(f"Game menu verification failed: missing {marker}")

    for marker in (
        "data-evil-wizard-console",
        "embeddedWebView",
        "ew_launch",
        "orientation-gate",
        "Turn your screen sideways",
        "left-zone",
        "right-zone",
        "top-left",
        "top-right",
        'data-position="south"',
        "xbox-label",
        "ps-label",
        'src="./index.html?build=',
        "touchstart",
        "touchmove",
        "touchcancel",
        "setPointerCapture?.",
        "20260924-stickfix1",
    ):
        if marker not in touch:
            fail(f"Floating controller verification failed: missing {marker}")
    if 'class="dpad"' in touch:
        fail("Virtual D-pad unexpectedly returned.")
    if "--control:62px" not in touch or "--joy:128px" not in touch:
        fail("Large joystick-only touch sizing is missing.")

    for marker in (
        "keyOptions",
        "gamepadOptions",
        "PlayStation controller",
        "Xbox / standard gamepad",
        "masterVolume",
        "cameraShake",
    ):
        if marker not in model:
            fail(f"Control/settings model verification failed: missing {marker}")



def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--commit", required=True, help="Exact verified Evil Wizard game commit")
    args = parser.parse_args()
    if args.commit != BUILD_COMMIT:
        fail(f"--commit must be the verified build {BUILD_COMMIT}")

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
        for name, data in files.items():
            digest = hashlib.sha256(data).hexdigest()
            if digest != EXPECTED_SHA256.get(name):
                fail(f"File checksum mismatch for {name}: {digest}")
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
    print("EVIL WIZARD CROSS-PLATFORM RELEASE DEPLOYED")
    print("Build:", BUILD_COMMIT)
    print("Play: https://web.engr.oregonstate.edu/~randjosh/games/evil-wizard/play.html")
    print("Backup:", backup)
    print("Portfolio and Learning Platform: unchanged")

if __name__ == "__main__":
    main()
