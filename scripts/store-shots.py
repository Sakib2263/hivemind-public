#!/usr/bin/env python3
"""Store screenshots: keep the best gameplay moments from QA and turn them into every store size, automatically.

Folders in a game project (made on first use):
  store/screenshots/raw/        every keeper from QA, full size: NN-<moment>.png (portrait 1080x1920 or landscape 1920x1080)
  store/screenshots/SHOTS.md    one line per keeper: file | what happens | why it's fun | portrait/landscape
  store/google-play/reference/  Play phone screenshots, 1080x1920 or 1920x1080, no transparency (max 8)
  store/playgama/covers/        Playgama covers: <name>-800x800, -1080x1920, -1920x1080

  python3 store-shots.py make <project> [file ...]   size the keepers (default: the first 8 in raw/, by name)
  python3 store-shots.py status <project>            what is there and what is still missing
Crops to fill (centre), never stretches. Uses Pillow, else ffmpeg.
"""
import os, re, shutil, subprocess, sys

PLAY = {"portrait": (1080, 1920), "landscape": (1920, 1080)}
COVERS = [(800, 800), (1080, 1920), (1920, 1080)]
IMG = (".png", ".jpg", ".jpeg", ".webp")


def size_of(path):
    try:
        from PIL import Image
        with Image.open(path) as im:
            return im.size
    except Exception:
        r = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height",
                            "-of", "csv=p=0", path], capture_output=True, text=True)
        w, h = (r.stdout.strip().split(",") + ["0", "0"])[:2]
        return int(w or 0), int(h or 0)


def fit(src, dst, w, h):
    """Crop to fill w x h around the centre, save as RGB PNG (stores reject transparency)."""
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    try:
        from PIL import Image
        with Image.open(src) as im:
            im = im.convert("RGB")
            s = max(w / im.width, h / im.height)
            im = im.resize((max(w, round(im.width * s)), max(h, round(im.height * s))), Image.LANCZOS)
            l, t = (im.width - w) // 2, (im.height - h) // 2
            im.crop((l, t, l + w, t + h)).save(dst, "PNG", optimize=True)
        return True
    except ImportError:
        vf = f"scale={w}:{h}:force_original_aspect_ratio=increase:flags=lanczos,crop={w}:{h},format=rgb24"
        return subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", src, "-vf", vf, dst]).returncode == 0


def make(proj, files):
    raw = os.path.join(proj, "store", "screenshots", "raw")
    os.makedirs(raw, exist_ok=True)
    if not files:
        files = sorted(f for f in os.listdir(raw) if f.lower().endswith(IMG))[:8]
    if not files:
        print(f"No keepers yet in {raw}: QA saves them there (see the game-developer skill, 'Store shots')."); return 1
    for f in files:
        src = f if os.path.isabs(f) else os.path.join(raw, os.path.basename(f))
        name = re.sub(r"\.[^.]+$", "", os.path.basename(src))
        w, h = size_of(src)
        orient = "landscape" if w > h else "portrait"
        pw, ph = PLAY[orient]
        out = [fit(src, os.path.join(proj, "store", "google-play", "reference", f"{name}.png"), pw, ph)]
        for cw, ch in COVERS:
            out.append(fit(src, os.path.join(proj, "store", "playgama", "covers", f"{name}-{cw}x{ch}.png"), cw, ch))
        small = " (source under 1080 px: recapture at store size for sharp art)" if min(w, h) < 1080 else ""
        print(f"{'ok ' if all(out) else 'ERR'} {name}: {w}x{h} {orient} -> Play {pw}x{ph}, Playgama 3 covers{small}")
    status(proj)
    return 0


def status(proj):
    def count(*p):
        d = os.path.join(proj, *p)
        return len([f for f in os.listdir(d) if f.lower().endswith(IMG)]) if os.path.isdir(d) else 0
    raw, play, cov = count("store", "screenshots", "raw"), count("store", "google-play", "reference"), count("store", "playgama", "covers")
    shots = os.path.join(proj, "store", "screenshots", "SHOTS.md")
    print(f"keepers {raw} (aim 6-12) | Play reference {play} (2-8, 3+ at 1080 px) | Playgama covers {cov} (3 sizes each)"
          + ("" if os.path.exists(shots) else " | SHOTS.md missing: one line per keeper"))
    return 0


if __name__ == "__main__":
    a = sys.argv[1:]
    if len(a) >= 2 and a[0] == "make":
        sys.exit(make(a[1], a[2:]))
    if len(a) == 2 and a[0] == "status":
        sys.exit(status(a[1]))
    print(__doc__); sys.exit(2)
