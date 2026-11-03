#!/usr/bin/env python3
"""Checks a project's Google Play assets before a release. No extra libraries needed.
  check-store-assets.py <project>            full check: icon source, store art, listing text
  check-store-assets.py --icon <png>         only the app icon source (used by the release build)
Exit 0 = all PASS, 3 = something MISSING or to FIX (the lead asks the owner, or offers the
ChatGPT prompt pack from the google-play-release skill)."""
import os, re, struct, sys

def image_info(path):
    """(format, width, height, has_alpha) from the file header, or None."""
    with open(path, "rb") as f:
        head = f.read(32)
        if head[:8] == b"\x89PNG\r\n\x1a\n":
            w, h, depth, ctype = struct.unpack(">IIBB", head[16:26])
            return "PNG", w, h, ctype in (4, 6)
        if head[:2] == b"\xff\xd8":
            f.seek(2)
            while True:
                b = f.read(1)
                while b and b != b"\xff": b = f.read(1)
                while b == b"\xff": b = f.read(1)
                if not b: return None
                if b[0] in (0xC0, 0xC1, 0xC2):
                    f.read(3); h, w = struct.unpack(">HH", f.read(4)); return "JPEG", w, h, False
                size = struct.unpack(">H", f.read(2))[0]; f.seek(size - 2, 1)
    return None

rows = []
def add(item, ok, note): rows.append((item, "PASS" if ok is True else ok, note))

def check_icon_source(p):
    if not p or not os.path.isfile(p): add("Icon source (1024x1024 PNG)", "MISSING", "set ICON in android.env"); return
    i = image_info(p)
    if not i or i[0] != "PNG": add("Icon source", "FIX", f"{p} is not a PNG"); return
    _, w, h, _ = i
    if w != h: add("Icon source", "FIX", f"{w}x{h}: must be square"); return
    if w < 512: add("Icon source", "FIX", f"{w}x{h}: at least 512, best 1024"); return
    add("Icon source", True, f"{w}x{h} PNG" + ("" if w >= 1024 else " (1024 is better)"))

def env_value(path, key):
    if not os.path.isfile(path): return ""
    m = re.search(rf'^{key}="?([^"\n]*)"?', open(path, encoding="utf-8", errors="ignore").read(), re.M)
    return m.group(1).strip() if m else ""

def listing_field(text, key):
    m = re.search(rf"^{key}:\s*(.*)$", text, re.M | re.I); return m.group(1).strip() if m else ""

if len(sys.argv) == 3 and sys.argv[1] == "--icon":
    check_icon_source(sys.argv[2])
else:
    proj = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    icon = env_value(os.path.join(proj, "android.env"), "ICON")
    check_icon_source(os.path.join(proj, icon) if icon and not os.path.isabs(icon) else icon)
    for key, label in (("APP_NAME", "App name (under the icon)"), ("APP_ID", "Bundle id")):
        v = env_value(os.path.join(proj, "android.env"), key)
        add(label, True if v else "MISSING", v or "decide before the first release")
    final = os.path.join(proj, "store", "google-play", "final")
    files = sorted(os.listdir(final)) if os.path.isdir(final) else []
    def find(prefix): return [f for f in files if f.lower().startswith(prefix)]
    ic = find("icon")
    if not ic: add("Store icon 512x512", "MISSING", "store/google-play/final/icon.png")
    else:
        p = os.path.join(final, ic[0]); i = image_info(p)
        ok = i and i[0] == "PNG" and i[1:3] == (512, 512) and os.path.getsize(p) <= 1024 * 1024
        add("Store icon 512x512", True if ok else "FIX", f"{ic[0]}: {i[0]} {i[1]}x{i[2]}" if i else f"{ic[0]}: unreadable")
    fg = find("feature")
    if not fg: add("Feature graphic 1024x500", "MISSING", "store/google-play/final/feature-graphic.png")
    else:
        i = image_info(os.path.join(final, fg[0]))
        ok = i and i[1:3] == (1024, 500) and not i[3]
        add("Feature graphic 1024x500", True if ok else "FIX", (f"{i[1]}x{i[2]}" + (", has transparency" if i[3] else "")) if i else "unreadable")
    shots = [f for f in find("screenshot") + find("shot") if f.lower().endswith((".png", ".jpg", ".jpeg"))]
    bad, big = [], 0
    for f in shots:
        i = image_info(os.path.join(final, f))
        if not i: bad.append(f + " unreadable"); continue
        _, w, h, a = i; lo, hi = min(w, h), max(w, h)
        if lo < 320 or hi > 3840 or hi > 2 * lo or a: bad.append(f"{f} {w}x{h}{' alpha' if a else ''}")
        if lo >= 1080: big += 1
    if len(shots) < 2: add("Screenshots (2-8)", "MISSING", f"{len(shots)} found in store/google-play/final/ (name them screenshot-01.png ...)")
    elif len(shots) > 8 or bad: add("Screenshots (2-8)", "FIX", f"{len(shots)} found; " + "; ".join(bad[:4]))
    else: add("Screenshots (2-8)", True, f"{len(shots)} ok" + ("" if big >= 3 else "; games: 3+ at 1080px for large-format (recommended)"))
    lp = os.path.join(proj, "store", "google-play", "LISTING.md")
    text = open(lp, encoding="utf-8", errors="ignore").read() if os.path.isfile(lp) else ""
    for key, label, mx in (("Title", "Store title", 30), ("Short description", "Short description", 80)):
        v = listing_field(text, key)
        add(label, "MISSING" if not v else (True if len(v) <= mx else "FIX"), f"{len(v)}/{mx} characters" if v else f"'{key}:' line in LISTING.md")
    full = re.search(r"^## Full description\s*\n(.*?)(?=^## |\Z)", text, re.M | re.S)
    n = len(full.group(1).strip()) if full else 0
    add("Full description", "MISSING" if not n else (True if n <= 4000 else "FIX"), f"{n}/4000 characters" if n else "'## Full description' section in LISTING.md")
    for key in ("Privacy policy", "Contact email", "Category"):
        v = listing_field(text, key)
        add(key, True if v else "MISSING", v or f"'{key}:' line in LISTING.md")

w = max(len(r[0]) for r in rows)
for item, status, note in rows: print(f"{item:<{w}}  {status:<7}  {note}")
missing = [r for r in rows if r[1] != "PASS"]
print(f"\n{len(rows) - len(missing)} of {len(rows)} ready." + ("" if not missing else " Ask the owner for the missing items, or offer the ChatGPT prompt pack (google-play-release skill)."))
sys.exit(3 if missing else 0)
