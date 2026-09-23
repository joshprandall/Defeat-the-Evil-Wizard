#!/usr/bin/env python3
from __future__ import annotations
import hashlib, shutil, tempfile
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile

ARCHIVE_URL="https://nightly.link/joshprandall/Defeat-the-Evil-Wizard/actions/artifacts/10770912480.zip"
ARCHIVE_SHA256="3f1ce4677bd3b257d77ab1dc32f4e72c10f87577c736f2d12e7798f281116e69"
TARGET_NAME="evil-wizard-melee-fix-preview-v25"
REQUIRED={"play.html","console-champions.js","console.html","index.apple-touch-icon.png","index.audio.position.worklet.js","index.audio.worklet.js","index.html","index.icon.png","index.js","index.pck","index.png","index.wasm"}
MAX_ARCHIVE=30_000_000
MAX_EXPANDED=60_000_000

def main():
    site=Path.home()/"public_html"
    games=site/"games"
    live=games/"evil-wizard"
    if not (live/"play.html").is_file():
        raise SystemExit("STOP: official game not found; nothing changed.")
    print("Downloading verified melee-fix preview...",flush=True)
    req=Request(ARCHIVE_URL,headers={"User-Agent":"Mozilla/5.0"})
    with urlopen(req,timeout=120) as r:
        data=r.read(MAX_ARCHIVE+1)
    if len(data)>MAX_ARCHIVE or hashlib.sha256(data).hexdigest()!=ARCHIVE_SHA256:
        raise SystemExit("STOP: build verification failed; nothing changed.")
    target=games/TARGET_NAME
    if target.exists():
        shutil.rmtree(target)
    with ZipFile(BytesIO(data)) as z:
        infos=z.infolist()
        if {x.filename for x in infos}!=REQUIRED or len(infos)!=len(REQUIRED):
            raise SystemExit("STOP: unexpected build contents; nothing changed.")
        if sum(x.file_size for x in infos)>MAX_EXPANDED or z.testzip() is not None:
            raise SystemExit("STOP: archive integrity check failed; nothing changed.")
        stage=Path(tempfile.mkdtemp(prefix=".evil-wizard-melee-",dir=games))
        try:
            for info in infos:
                b=z.read(info)
                p=stage/info.filename
                p.write_bytes(b); p.chmod(0o644)
            stage.chmod(0o755)
            stage.rename(target)
        except BaseException:
            shutil.rmtree(stage,ignore_errors=True)
            raise
    print("\nMELEE FIX PREVIEW READY:")
    print("https://web.engr.oregonstate.edu/~randjosh/games/"+TARGET_NAME+"/play.html")
    print("\nOfficial game and portfolio were not changed.")

if __name__=="__main__":
    main()
