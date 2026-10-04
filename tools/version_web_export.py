#!/usr/bin/env python3
"""Version the Godot Web pack so mobile browsers cannot reuse stale game code."""

from __future__ import annotations

import argparse
import json
import re
import shutil
from pathlib import Path

BUILD_RE = re.compile(r"^[A-Za-z0-9._-]+$")
CONFIG_RE = re.compile(r"const GODOT_CONFIG = (\{[^\n]+\});")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--build-id", required=True)
    args = parser.parse_args()

    root: Path = args.root
    build_id: str = args.build_id
    if not BUILD_RE.fullmatch(build_id):
        raise SystemExit("build id contains unsupported characters")

    html_path = root / "index.html"
    pack_path = root / "index.pck"
    if not html_path.is_file() or not pack_path.is_file():
        raise SystemExit("Godot export is missing index.html or index.pck")

    versioned_pack_name = f"index-{build_id}.pck"
    versioned_pack = root / versioned_pack_name
    shutil.copy2(pack_path, versioned_pack)

    html = html_path.read_text(encoding="utf-8")
    old_script = '<script src="index.js"></script>'
    new_script = f'<script src="index.js?v={build_id}"></script>'
    if old_script not in html:
        raise SystemExit("Godot index.js script tag was not found")
    html = html.replace(old_script, new_script, 1)

    match = CONFIG_RE.search(html)
    if not match:
        raise SystemExit("GODOT_CONFIG was not found")
    config = json.loads(match.group(1))
    file_sizes = dict(config.get("fileSizes", {}))
    file_sizes[versioned_pack_name] = versioned_pack.stat().st_size
    config["fileSizes"] = file_sizes
    config["mainPack"] = versioned_pack_name

    encoded = json.dumps(config, separators=(",", ":"), sort_keys=True)
    html = html[: match.start(1)] + encoded + html[match.end(1) :]
    html_path.write_text(html, encoding="utf-8")

    verify = html_path.read_text(encoding="utf-8")
    if versioned_pack_name not in verify or new_script not in verify:
        raise SystemExit("versioned web export verification failed")

    print(
        json.dumps(
            {
                "build_id": build_id,
                "main_pack": versioned_pack_name,
                "pack_bytes": versioned_pack.stat().st_size,
            },
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
