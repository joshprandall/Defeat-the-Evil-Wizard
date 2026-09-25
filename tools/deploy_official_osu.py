#!/usr/bin/env python3
"""Promote the verified adaptive Evil Wizard main build to the OSU portfolio.

Scope:
- replaces only public_html/games/evil-wizard with the checksum-pinned build
- updates only Evil Wizard links in projects.html and play-evil-wizard.html
- creates a full rollback backup before changing anything
"""
from __future__ import annotations

import hashlib
import os
import re
import shutil
import tempfile
from datetime import datetime
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

ARCHIVE_URL = (
    "https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/"
    "actions/artifacts/10852114171.zip"
)
ARCHIVE_SHA256 = "da9c74754364483ec2bd53ec6380bfc32a2e777b9545cf35fc47941fc4275e80"
REQUIRED = {
    "play.html", "console-champions.js", "console.html", "index.apple-touch-icon.png",
    "index.audio.position.worklet.js", "index.audio.worklet.js", "index.html",
    "index.icon.png", "index.js", "index.pck", "index.png", "index.wasm",
}
MAX_ARCHIVE_BYTES = 30_000_000
MAX_EXPANDED_BYTES = 60_000_000


def atomic_write(path: Path, data: bytes) -> None:
    fd, temp_name = tempfile.mkstemp(prefix=".evil-wizard-page-", dir=path.parent)
    temp = Path(temp_name)
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(data)
        shutil.copymode(path, temp)
        os.replace(temp, path)
    finally:
        if temp.exists():
            temp.unlink()


def update_projects(original: bytes) -> bytes:
    text = original.decode("utf-8")
    match = re.search(r'<article\b[^>]*\bid=["\']evil-wizard["\'][^>]*>.*?</article>', text, re.S)
    if not match:
        raise ValueError("Evil Wizard portfolio tile was not found.")
    card = match.group(0)

    if 'href="games/evil-wizard/play.html"' not in card:
        if 'href="play-evil-wizard.html"' not in card:
            raise ValueError("Expected Evil Wizard launch link was not found.")
        card = card.replace('href="play-evil-wizard.html"', 'href="games/evil-wizard/play.html"', 1)

    card = card.replace("View the game project ↗", "Play the game ↗")
    card = card.replace(
        "Open Defeat the Evil Wizard dedicated project page in a new tab",
        "Play Defeat the Evil Wizard in a new tab",
    )
    card = card.replace(
        "Browser prototype · see game for current features",
        "Adaptive Web release · mobile + desktop",
    )

    # The single adaptive launcher makes a separate handheld link obsolete.
    card = re.sub(
        r'<a\b[^>]*href=["\'][^"\']*evil-wizard[^"\']*(?:console\.html|handheld[^"\']*)["\'][^>]*>.*?</a>',
        "",
        card,
        flags=re.S | re.I,
    )

    updated = text[:match.start()] + card + text[match.end():]
    if 'href="games/evil-wizard/play.html"' not in updated:
        raise ValueError("Portfolio launch-link verification failed.")
    return updated.encode("utf-8")


def update_project_page(original: bytes) -> tuple[bytes, bool]:
    """Best-effort project-page update.

    The live OSU page has changed independently over time, so failure to find
    an older embedded-game URL must never block promotion of the verified game.
    """
    text = original.decode("utf-8")
    before = text

    # Normalize any known live/preview Evil Wizard launch URL to the canonical
    # adaptive launcher. This intentionally leaves unrelated links untouched.
    text = re.sub(
        r'games/evil-wizard(?:-[^"\']+)?/(?:index|console|play)\.html',
        'games/evil-wizard/play.html',
        text,
        flags=re.I,
    )
    text = text.replace("Open Game Full Window", "Play Fullscreen")
    text = text.replace("PLAYABLE ROUGH DRAFT / v2.0.2", "ADAPTIVE WEB RELEASE / MOBILE + DESKTOP")
    return text.encode("utf-8"), (text != before)


def main() -> None:
    site = Path.home() / "public_html"
    games = site / "games"
    live = games / "evil-wizard"
    projects = site / "projects.html"
    project_page = site / "play-evil-wizard.html"

    for required in (site, games, live, projects):
        if not required.exists():
            raise ValueError(f"Required live path is missing: {required}")
    if not (live / "index.html").is_file():
        raise ValueError("Existing Evil Wizard game is not intact; nothing changed.")

    print("Downloading verified Evil Wizard mobile-combat main build...", flush=True)
    request = Request(ARCHIVE_URL, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=120) as response:
        archive_bytes = response.read(MAX_ARCHIVE_BYTES + 1)

    if len(archive_bytes) > MAX_ARCHIVE_BYTES:
        raise ValueError("Build archive exceeds expected size; nothing changed.")
    if hashlib.sha256(archive_bytes).hexdigest() != ARCHIVE_SHA256:
        raise ValueError("Build checksum mismatch; nothing changed.")

    with ZipFile(BytesIO(archive_bytes)) as bundle:
        entries = bundle.infolist()
        if {entry.filename for entry in entries} != REQUIRED or len(entries) != len(REQUIRED):
            raise ValueError("Unexpected build contents; nothing changed.")
        if any(entry.is_dir() or entry.file_size <= 0 for entry in entries):
            raise ValueError("Missing or empty game asset; nothing changed.")
        if sum(entry.file_size for entry in entries) > MAX_EXPANDED_BYTES:
            raise ValueError("Expanded build exceeds expected size; nothing changed.")
        if bundle.testzip() is not None:
            raise ValueError("Build ZIP failed integrity check; nothing changed.")

        # Validate page edits before creating any live changes.
        new_projects = update_projects(projects.read_bytes())
        new_project_page = None
        project_page_changed = False
        if project_page.exists():
            new_project_page, project_page_changed = update_project_page(project_page.read_bytes())

        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        backup = Path.home() / f"evil-wizard-official-backup-{stamp}"
        backup.mkdir(mode=0o700)
        shutil.copytree(live, backup / "evil-wizard")
        shutil.copy2(projects, backup / "projects.html")
        if project_page.exists():
            shutil.copy2(project_page, backup / "play-evil-wizard.html")

        stage = Path(tempfile.mkdtemp(prefix=".evil-wizard-official-", dir=games))
        hold = games / f".evil-wizard-previous-{stamp}"
        swapped = False
        try:
            for entry in entries:
                destination = stage / entry.filename
                content = bundle.read(entry)
                destination.write_bytes(content)
                destination.chmod(0o644)
                if hashlib.sha256(destination.read_bytes()).digest() != hashlib.sha256(content).digest():
                    raise OSError(f"Readback failed for {entry.filename}")
            stage.chmod(0o755)

            live.rename(hold)
            stage.rename(live)
            swapped = True

            atomic_write(projects, new_projects)
            if project_page.exists() and new_project_page is not None and project_page_changed:
                atomic_write(project_page, new_project_page)

            if not (live / "play.html").is_file() or not (live / "console.html").is_file():
                raise OSError("New live game verification failed.")
            if b'games/evil-wizard/play.html' not in projects.read_bytes():
                raise OSError("Portfolio launch-link verification failed after write.")
            # The project-detail page is not required for the canonical launch
            # path. If it contained a recognizable game URL and was updated,
            # verify only that targeted edit.
            if project_page.exists() and project_page_changed:
                if b'games/evil-wizard/play.html' not in project_page.read_bytes():
                    raise OSError("Project-page launch-link verification failed after write.")

            shutil.rmtree(hold)
        except BaseException:
            if swapped:
                if live.exists():
                    shutil.rmtree(live, ignore_errors=True)
                if hold.exists():
                    hold.rename(live)
            elif stage.exists():
                shutil.rmtree(stage, ignore_errors=True)

            shutil.copy2(backup / "projects.html", projects)
            if (backup / "play-evil-wizard.html").exists():
                shutil.copy2(backup / "play-evil-wizard.html", project_page)
            raise

    print("\nOFFICIAL EVIL WIZARD RELEASE DEPLOYED")
    print("Play:", "https://web.engr.oregonstate.edu/~randjosh/games/evil-wizard/play.html")
    print("Portfolio:", "https://web.engr.oregonstate.edu/~randjosh/projects.html")
    print("Rollback backup:", backup)
    if project_page.exists() and not project_page_changed:
        print("Note: play-evil-wizard.html used a different layout, so it was left unchanged.")
    print("Other portfolio projects and the Learning Platform were not changed.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        raise SystemExit(f"STOP: {error}") from error
