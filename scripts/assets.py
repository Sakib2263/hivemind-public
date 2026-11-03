#!/usr/bin/env python3
"""Shared asset library: one place for downloaded/free assets so every game can reuse them.

Library root: ASSET_LIBRARY in config/folders.env, else <work folder>/Games/_Assets.
Layout:
  INDEX.md                 one row per pack (read this first; it is small)
  <type>/<pack-id>/        extracted files, plus PACK.md (source, licence, date) and files.txt (one path per line)
  _zips/<original>.zip     original archives, kept so nothing has to be downloaded again
Types: audio, music, sprites, ui, fonts, textures, 3d, vfx, video, other (guessed from file types).

Commands (run from anywhere):
  add <zip|folder|file> [--type T] [--id ID] [--source URL] [--license L] [--tags a,b] [--keep]
        Zips are extracted (zip built in; .7z/.rar need 7z). The original moves to _zips (--keep copies it).
  scan <folder> [--source URL]   add every .zip/.7z/.rar in a folder that is not in the library yet
  peek <zip>                      list what is inside an archive without extracting it
  find <word> [word...] [--type T]  search file names in all packs (cheap: reads files.txt only)
  list [type]                     packs, newest first
  copy <pack-id>/<path-or-glob> <project folder> [--to sub/dir] [--ogg]
        copy files into a game (--ogg converts audio with ffmpeg when it is installed)
  index                           rebuild INDEX.md
"""
import os, re, sys, shutil, zipfile, fnmatch, subprocess, datetime, argparse

KIT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
TYPES = ["audio", "music", "sprites", "ui", "fonts", "textures", "3d", "vfx", "video", "other"]
EXT = {"audio": {".ogg", ".wav", ".mp3", ".m4a", ".flac", ".aif", ".aiff"}, "fonts": {".ttf", ".otf", ".woff", ".woff2"},
       "3d": {".glb", ".gltf", ".fbx", ".obj", ".blend", ".dae"}, "video": {".mp4", ".webm", ".mov"},
       "sprites": {".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".psd", ".aseprite"}}
SKIP = {"__MACOSX", ".DS_Store", "Thumbs.db"}

def win2wsl(p):
    m = re.match(r"^([A-Za-z]):[\\/](.*)$", p.strip().strip('"'))
    if m and os.path.isdir("/mnt/" + m.group(1).lower()): return "/mnt/" + m.group(1).lower() + "/" + m.group(2).replace("\\", "/")
    return p.strip().strip('"')

def lib_root():
    f = os.path.join(KIT, "config", "folders.env")
    if os.path.exists(f):
        for line in open(f, encoding="utf-8", errors="ignore"):
            m = re.match(r'\s*ASSET_LIBRARY="?([^"\r\n]*)"?', line)
            if m and m.group(1).strip(): return win2wsl(m.group(1))
    return os.path.join(os.path.dirname(KIT), "Games", "_Assets")

LIB = lib_root()
slug = lambda s: re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-") or "pack"

def guess_type(files):
    n = {t: 0 for t in EXT}
    for f in files:
        e = os.path.splitext(f)[1].lower()
        for t, s in EXT.items():
            if e in s: n[t] += 1
    t = max(n, key=n.get)
    if n[t] == 0: return "other"
    if t == "audio" and any(re.search(r"music|loop|theme|bgm", f, re.I) for f in files) and len(files) < 40: return "music"
    if t == "sprites":
        low = " ".join(files[:400]).lower()
        if re.search(r"\bui\b|button|icon|panel|cursor", low): return "ui"
        if re.search(r"particle|smoke|fire|explosion|spark", low): return "vfx"
        if re.search(r"texture|tile|pattern", low): return "textures"
    return t

def licence_of(folder):
    for root, _, fs in os.walk(folder):
        for f in fs:
            if re.match(r"(licen[cs]e|readme|credits)", f, re.I) and f.lower().endswith((".txt", ".md", "")):
                try: t = open(os.path.join(root, f), encoding="utf-8", errors="ignore").read(4000)
                except OSError: continue
                for pat, name in [(r"CC0|creative commons zero|public domain", "CC0"), (r"CC[- ]BY[- ]SA", "CC-BY-SA (credit, share-alike)"),
                                  (r"CC[- ]BY", "CC-BY (credit needed)"), (r"\bMIT\b", "MIT"), (r"OFL|Open Font License", "OFL")]:
                    if re.search(pat, t, re.I): return name
    return "unknown (check before shipping)"

def rel_files(folder):
    out = []
    for root, ds, fs in os.walk(folder):
        ds[:] = [d for d in ds if d not in SKIP]
        for f in fs:
            if f in SKIP or f in ("PACK.md", "files.txt"): continue
            out.append(os.path.relpath(os.path.join(root, f), folder).replace("\\", "/"))
    return sorted(out)

def extract(src, dest):
    os.makedirs(dest, exist_ok=True)
    low = src.lower()
    if low.endswith(".zip"):
        with zipfile.ZipFile(src) as z:
            for m in z.infolist():
                p = os.path.normpath(os.path.join(dest, m.filename))
                if not p.startswith(os.path.abspath(dest)) and not os.path.abspath(p).startswith(os.path.abspath(dest)): continue  # zip-slip guard
                if any(part in SKIP for part in m.filename.split("/")): continue
                z.extract(m, dest)
    elif low.endswith((".7z", ".rar")):
        exe = shutil.which("7z") or shutil.which("7za")
        if not exe: sys.exit("This is a .7z/.rar file. Install 7-Zip in WSL first: sudo apt install p7zip-full")
        subprocess.run([exe, "x", "-y", "-o" + dest, src], check=True, stdout=subprocess.DEVNULL)
    # one wrapper folder with everything inside: lift it up
    items = [i for i in os.listdir(dest) if i not in SKIP]
    if len(items) == 1 and os.path.isdir(os.path.join(dest, items[0])):
        inner = os.path.join(dest, items[0])
        for i in os.listdir(inner): shutil.move(os.path.join(inner, i), os.path.join(dest, i))
        os.rmdir(inner)

def write_pack(folder, pid, typ, source, lic, tags, origin):
    files = rel_files(folder)
    open(os.path.join(folder, "files.txt"), "w", encoding="utf-8").write("\n".join(files) + "\n")
    exts = {}
    for f in files: e = os.path.splitext(f)[1].lower() or "(none)"; exts[e] = exts.get(e, 0) + 1
    fmt = ", ".join(f"{k} {v}" for k, v in sorted(exts.items(), key=lambda x: -x[1])[:5])
    open(os.path.join(folder, "PACK.md"), "w", encoding="utf-8").write(
        f"# {pid}\n- type: {typ}\n- source: {source or 'unknown'}\n- licence: {lic}\n- added: {datetime.date.today()}\n"
        f"- from: {origin}\n- files: {len(files)} ({fmt})\n- tags: {tags}\n- list: files.txt (one path per line)\n")
    return len(files)

def packs():
    out = []
    if not os.path.isdir(LIB): return out
    for t in TYPES:
        d = os.path.join(LIB, t)
        if not os.path.isdir(d): continue
        for p in os.listdir(d):
            pm = os.path.join(d, p, "PACK.md")
            if os.path.exists(pm):
                info = dict(re.findall(r"^- (\w+): (.*)$", open(pm, encoding="utf-8").read(), re.M)); info.update(id=p, type=t); out.append(info)
    return out

def index():
    ps = packs(); os.makedirs(LIB, exist_ok=True)
    lines = ["# Asset library index", "", f"Root: Games/_Assets in the work folder (`{LIB}` from WSL). One row per pack. Search file names: `python3 scripts/assets.py find <word>` (Hivemind).",
             "Licence column: CC0/MIT/OFL = free for commercial use, no credit. CC-BY = add a credit line. unknown = check first.", ""]
    for t in TYPES:
        rows = [p for p in ps if p["type"] == t]
        if not rows: continue
        lines += [f"## {t}", "| pack | files | licence | source | tags |", "|---|---|---|---|---|"]
        for p in sorted(rows, key=lambda x: x["id"]):
            lines.append(f"| {p['id']} | {p.get('files','?')} | {p.get('licence','?')} | {p.get('source','?')} | {p.get('tags','')} |")
        lines.append("")
    open(os.path.join(LIB, "INDEX.md"), "w", encoding="utf-8").write("\n".join(lines))
    print(f"INDEX.md: {len(ps)} packs")

def add(src, typ=None, pid=None, source="", lic=None, tags="", keep=False):
    src = os.path.abspath(win2wsl(src))
    if not os.path.exists(src): sys.exit(f"not found: {src}")
    base = os.path.basename(src.rstrip("/"))
    name = re.sub(r"\.(zip|7z|rar)$", "", base, flags=re.I)
    pid = slug(pid or name)
    for p in packs():
        if p["id"] == pid: print(f"skip {pid}: already in the library ({p['type']})"); return
    tmp = os.path.join(LIB, "_incoming", pid); shutil.rmtree(tmp, ignore_errors=True)
    if os.path.isdir(src): shutil.copytree(src, tmp)
    elif base.lower().endswith((".zip", ".7z", ".rar")): extract(src, tmp)
    else: os.makedirs(tmp, exist_ok=True); shutil.copy2(src, tmp)
    typ = typ or guess_type(rel_files(tmp))
    if typ not in TYPES: sys.exit(f"type must be one of {TYPES}")
    if not source and pid.startswith("kenney"): source = "https://kenney.nl/assets/" + pid.replace("kenney-", "")
    lic = lic or licence_of(tmp)
    dest = os.path.join(LIB, typ, pid); os.makedirs(os.path.dirname(dest), exist_ok=True); shutil.move(tmp, dest)
    shutil.rmtree(os.path.join(LIB, "_incoming"), ignore_errors=True)
    if os.path.isfile(src) and base.lower().endswith((".zip", ".7z", ".rar")):
        z = os.path.join(LIB, "_zips"); os.makedirs(z, exist_ok=True); tgt = os.path.join(z, base)
        if keep or os.path.exists(tgt): shutil.copy2(src, tgt) if not os.path.exists(tgt) else None
        else:
            try: shutil.move(src, tgt)
            except OSError: shutil.copy2(src, tgt); print(f"  (could not remove {src}; copied instead)")
    n = write_pack(dest, pid, typ, source, lic, tags, base)
    print(f"added {typ}/{pid}: {n} files, licence {lic}")
    index()

def scan(folder, source=""):
    folder = win2wsl(folder); hit = 0
    for f in sorted(os.listdir(folder)):
        if f.lower().endswith((".zip", ".7z", ".rar")): add(os.path.join(folder, f), source=source); hit += 1
    print(f"scan: {hit} archive(s) looked at in {folder}")

def peek(z):
    z = win2wsl(z)
    with zipfile.ZipFile(z) as zz:
        names = [n for n in zz.namelist() if not n.endswith("/")]
    print(f"{len(names)} files in {os.path.basename(z)}"); [print(" ", n) for n in names[:200]]
    if len(names) > 200: print(f"  ... {len(names) - 200} more")

def find(words, typ=None, limit=60):
    ws = [w.lower() for w in words]; n = 0
    for p in packs():
        if typ and p["type"] != typ: continue
        ft = os.path.join(LIB, p["type"], p["id"], "files.txt")
        for line in open(ft, encoding="utf-8"):
            l = line.strip()
            if all(w in l.lower() for w in ws):
                print(f"{p['id']}/{l}"); n += 1
                if n >= limit: print(f"... more, narrow the words"); return
    if not n: print("no match")

def list_(typ=None):
    for p in sorted(packs(), key=lambda x: x.get("added", ""), reverse=True):
        if not typ or p["type"] == typ: print(f"{p['type']:9} {p['id']:40} {p.get('files','?'):>22}  {p.get('licence','')}")

def copy(spec, project, to=None, ogg=False):
    pid, _, pat = spec.partition("/")
    pk = next((p for p in packs() if p["id"] == pid), None)
    if not pk: sys.exit(f"no pack {pid} (see INDEX.md)")
    root = os.path.join(LIB, pk["type"], pid); files = [f for f in rel_files(root) if fnmatch.fnmatch(f, pat or "*") or fnmatch.fnmatch(os.path.basename(f), pat or "*")]
    if not files: sys.exit("no file matches " + spec)
    dest = os.path.join(win2wsl(project), to or ("assets/" + pk["type"])); os.makedirs(dest, exist_ok=True)
    ff = shutil.which("ffmpeg") if ogg else None
    for f in files:
        s = os.path.join(root, f)
        if ogg and ff and os.path.splitext(f)[1].lower() in EXT["audio"]:
            out = os.path.join(dest, os.path.splitext(os.path.basename(f))[0] + ".ogg")
            subprocess.run([ff, "-loglevel", "error", "-y", "-i", s, "-ac", "1", "-c:a", "libvorbis", "-q:a", "3", out], check=True)
        else: shutil.copy2(s, os.path.join(dest, os.path.basename(f)))
    print(f"copied {len(files)} file(s) from {pid} to {dest}" + ("" if not ogg or ff else " (ffmpeg missing: copied as is)"))
    print(f"log it in the project's ASSETS.md: {pid} | {pk.get('licence')} | {pk.get('source')}")

def run_lines(text):  # relay 'assets' worker: one command per line, quoted paths ok
    import shlex
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith('#'): continue
        print('$ assets ' + line); sys.stdout.flush()
        subprocess.run([sys.executable, os.path.realpath(__file__)] + shlex.split(line))

if __name__ == "__main__":
    a = sys.argv[1:]
    if a[:1] == ["--lines"]: run_lines(sys.stdin.read()); sys.exit(0)
    if not a or a[0] in ("-h", "--help", "help"): print(__doc__); sys.exit(0)
    ap = argparse.ArgumentParser(add_help=False); ap.add_argument("cmd"); ap.add_argument("args", nargs="*")
    for o in ("--type", "--id", "--source", "--license", "--tags", "--to"): ap.add_argument(o)
    ap.add_argument("--keep", action="store_true"); ap.add_argument("--ogg", action="store_true")
    o = ap.parse_args(a)
    if o.cmd == "add": add(o.args[0], o.type, o.id, o.source or "", o.license, o.tags or "", o.keep)
    elif o.cmd == "scan": scan(o.args[0] if o.args else ".", o.source or "")
    elif o.cmd == "peek": peek(o.args[0])
    elif o.cmd == "find": find(o.args, o.type)
    elif o.cmd == "list": list_(o.args[0] if o.args else None)
    elif o.cmd == "copy": copy(o.args[0], o.args[1], o.to, o.ogg)
    elif o.cmd == "index": index()
    else: print(__doc__)
