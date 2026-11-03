#!/usr/bin/env python3
"""vidkit — motion-video pipeline (voiceover -> timeline -> frames -> soundtrack -> MP4).

Usage (PROJECT is a folder holding cuts.json, scenes.js and optional assets/):
  vidkit.py doctor                      check/repair the toolchain (run first, every session)
  vidkit.py new PROJECT [--from starter] start a project from a bundled example
  vidkit.py vo PROJECT                  synthesize voiceover clips + build build/timeline.json
  vidkit.py snap PROJECT CUT [t ...]    render still frames (default: one per scene) + contact sheets
  vidkit.py audio PROJECT [CUT ...]     build soundtrack(s): VO + music + SFX, ducked
  vidkit.py render PROJECT [CUT ...] [--workers N]   render video, mux audio -> build/out/*.mp4
  vidkit.py build PROJECT [CUT ...]     vo + audio + render + verify in one go
  vidkit.py logo SRC OUT                 make a transparent, white-text logo for dark backgrounds
  vidkit.py verify PROJECT              probe outputs (duration, streams, loudness) + spot-frame sheet
"""
import argparse, base64, functools, http.server, json, os, shutil, subprocess, sys, threading, time

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENGINE = os.path.join(SKILL, "scripts", "engine")
CACHE = os.path.expanduser("~/.cache/motion-video-producer")
KOKORO_URL = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/"
FONT_FILES = ["Poppins-Bold.ttf", "Poppins-Medium.ttf", "Inter-Regular.otf", "Inter-Medium.otf",
              "Inter-SemiBold.otf", "Inter-Bold.otf", "Inter-ExtraBold.otf"]
SIZES = {"16:9": (1920, 1080), "9:16": (1080, 1920), "1:1": (1080, 1080)}
FONT_DIRS = ["/usr/share/fonts", os.path.expanduser("~/.fonts"), os.path.join(CACHE, "fonts")]


def sh(cmd, **kw):
    return subprocess.run(cmd, shell=isinstance(cmd, str), **kw)


def load(project):
    return json.load(open(os.path.join(project, "cuts.json")))


def bdir(project, *p):
    d = os.path.join(project, "build", *p)
    os.makedirs(d if not os.path.splitext(d)[1] else os.path.dirname(d), exist_ok=True)
    return d


# ------------------------------------------------------------------ doctor
def find_font(name):
    for root in FONT_DIRS:
        for dp, _, fs in os.walk(root):
            if name in fs:
                return os.path.join(dp, name)
    return None


def doctor(_=None, quiet=False):
    """Check every dependency; install/download what is missing. Returns list of problems left."""
    probs = []
    log = (lambda *a: None) if quiet else print
    if not shutil.which("ffmpeg"):
        probs.append("ffmpeg missing (try: apt-get install -y ffmpeg)")
    for mod, pipname in [("numpy", "numpy"), ("scipy", "scipy"), ("soundfile", "soundfile"),
                         ("playwright", "playwright"), ("kokoro_onnx", "kokoro-onnx"), ("PIL", "pillow")]:
        try:
            __import__(mod)
        except ImportError:
            log(f"installing {pipname} ...")
            sh([sys.executable, "-m", "pip", "install", "-q", "--break-system-packages", pipname])
            try:
                __import__(mod)
            except ImportError:
                probs.append(f"python module {mod} could not be installed")
    # headless chromium
    try:
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            b = p.chromium.launch(); v = b.version; b.close()
        log("chromium ok", v)
    except Exception as e:
        log("chromium missing, trying playwright install ...")
        sh([sys.executable, "-m", "playwright", "install", "chromium"])
        try:
            with sync_playwright() as p:
                p.chromium.launch().close()
        except Exception:
            probs.append(f"headless chromium unavailable ({str(e)[:80]})")
    # voice model
    os.makedirs(CACHE, exist_ok=True)
    for f in ["kokoro-v1.0.onnx", "voices-v1.0.bin"]:
        dst = os.path.join(CACHE, f)
        alt = os.path.join("/home/claude/tts", f)
        if not os.path.exists(dst) and os.path.exists(alt):
            shutil.copy(alt, dst)
        if not os.path.exists(dst) or os.path.getsize(dst) < 1e6:
            log(f"downloading {f} ...")
            r = sh(["curl", "-sSL", "-o", dst, KOKORO_URL + f])
            if r.returncode or not os.path.exists(dst) or os.path.getsize(dst) < 1e6:
                probs.append(f"voice model {f} not downloadable (GitHub blocked?) - captions-only video still possible")
    # fonts
    for f in FONT_FILES:
        if not find_font(f):
            fam = f.split("-")[0].lower()
            url = (f"https://github.com/google/fonts/raw/main/ofl/poppins/{f}" if fam == "poppins"
                   else f"https://github.com/rsms/inter/raw/v3.19/docs/font-files/{f}")
            os.makedirs(os.path.join(CACHE, "fonts"), exist_ok=True)
            sh(["curl", "-sSL", "-o", os.path.join(CACHE, "fonts", f), url])
            if not find_font(f) or os.path.getsize(find_font(f)) < 10000:
                probs.append(f"font {f} missing (engine falls back to system sans)")
    log("DOCTOR:", "all good" if not probs else "problems:\n  - " + "\n  - ".join(probs))
    return probs


# ------------------------------------------------------------------ project bootstrap
def new(args):
    src = os.path.join(SKILL, "assets", "examples", args.from_)
    if os.path.exists(args.project) and os.listdir(args.project):
        sys.exit(f"{args.project} exists and is not empty")
    shutil.copytree(src, args.project, dirs_exist_ok=True)
    print("project created from", args.from_, "->", args.project)


# ------------------------------------------------------------------ voiceover + timeline
def spoken(text, cfg):
    for a, b in cfg.get("pronounce", {}).items():
        text = text.replace(a, b)
    return text


def vo(args):
    import hashlib
    import numpy as np, soundfile as sf
    P = args.project; spec = load(P); cfg = spec["config"]
    voice, speed = cfg.get("voice", "af_heart"), cfg.get("speed", 1.0)
    vdir = bdir(P, "vo"); kok = [None]
    LEAD, GAP = cfg.get("lead", .6), cfg.get("gap", .32)

    # every unique line, in order: build/voice/lines.txt (input for a cloned or recorded voice)
    uniq = list(dict.fromkeys(ln for scs in spec["cuts"].values() for sc in scs for ln in sc.get("lines", [])))
    open(os.path.join(bdir(P, "voice"), "lines.txt"), "w", encoding="utf-8").write("\n".join(spoken(l, cfg) for l in uniq) + "\n")
    if voice == "files":
        ref = os.path.join(P, "assets", "voice.wav")
        if os.path.exists(ref) and not os.path.exists(os.path.join(P, "build", "voice", "voice.wav")):
            shutil.copy(ref, os.path.join(P, "build", "voice", "voice.wav"))
        miss = [i for i in range(1, len(uniq) + 1) if not os.path.exists(os.path.join(P, "build", "voice", "vo", "%03d.wav" % i))]
        if miss:
            print(f"voice=files: {len(miss)} of {len(uniq)} lines have no recording yet (first: {miss[0]:03d}).")
            print("  Put voice.wav in build/voice/ (or assets/), then drag build/voice onto shortcuts\\16 Clone Voice.bat,")
            print("  or record build/voice/vo/001.wav, 002.wav ... (one per line of build/voice/lines.txt).")
            sys.exit(3)
    silent = voice in (None, "", "none") or (voice != "files" and not os.path.exists(os.path.join(CACHE, "kokoro-v1.0.onnx")))
    if silent: print("no voice model/voice=none -> captions-only timing (about 2.6 words/s)")

    def clip(text):
        if silent:
            return None, max(1.2, len(text.split()) / 2.6)
        if voice == "files":
            path = os.path.join(P, "build", "voice", "vo", "%03d.wav" % (uniq.index(text) + 1))
            return path, sf.info(path).duration
        key = hashlib.md5(f"{voice}|{speed}|{spoken(text, cfg)}".encode()).hexdigest()[:12]
        path = os.path.join(vdir, key + ".wav")
        if not os.path.exists(path):
            if kok[0] is None:
                from kokoro_onnx import Kokoro
                kok[0] = Kokoro(os.path.join(CACHE, "kokoro-v1.0.onnx"), os.path.join(CACHE, "voices-v1.0.bin"))
            s, sr = kok[0].create(spoken(text, cfg), voice=voice, speed=speed, lang=cfg.get("lang", "en-us"))
            idx = np.where(np.abs(s) > .01)[0]
            sf.write(path, s[max(0, idx[0] - 600): idx[-1] + 1800], sr)
        return path, sf.info(path).duration

    out = {}
    for name, scenes in spec["cuts"].items():
        t, tl = 0.0, []
        for sc in scenes:
            lines = sc.get("lines", [])
            lt = LEAD if lines else 0
            vos, caps = [], []
            for ln in lines:
                p, d = clip(ln)
                if p: vos.append(dict(file=os.path.relpath(p, P), t=round(t + lt, 3)))
                caps.append(dict(text=ln, t0=round(lt, 3), t1=round(lt + d, 3)))
                lt += d + GAP
            tail = sc.get("tail", .35 if sc.get("fast") else .75)
            dur = max(sc.get("min", 0), lt - (GAP if lines else 0) + tail)
            opt = {k: v for k, v in sc.items() if k not in ("id", "lines", "tail", "min")}
            tl.append(dict(id=sc["id"], start=round(t, 3), dur=round(dur, 3), vo=vos, caps=caps, opt=opt))
            t += dur
        asp = cfg.get("aspects", {}).get(name, cfg.get("aspect", "16:9"))
        if asp not in SIZES: sys.exit(f"cut {name}: aspect must be one of {', '.join(SIZES)} (got {asp})")
        w, h = SIZES[asp]
        out[name] = dict(total=round(t, 3), scenes=tl, w=w, h=h, aspect=asp)
        print(f"{name:8s} {t:6.1f}s  {len(tl)} scenes  {asp}")
    json.dump(out, open(bdir(P, "timeline.json"), "w"), indent=1)


# ------------------------------------------------------------------ stage + local server
def stage(P):
    st = bdir(P, "stage")
    for f in ["engine.js", "main.js", "render.html"]:
        shutil.copy(os.path.join(ENGINE, f), st)
    shutil.copy(os.path.join(P, "scenes.js"), st)
    shutil.copy(bdir(P, "timeline.json"), st)
    if os.path.isdir(os.path.join(P, "assets")):
        shutil.copytree(os.path.join(P, "assets"), os.path.join(st, "assets"), dirs_exist_ok=True)
    os.makedirs(os.path.join(st, "fonts"), exist_ok=True)
    for f in FONT_FILES:
        src = find_font(f)
        if src: shutil.copy(src, os.path.join(st, "fonts", f))
    return st


class Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a): pass


def serve(st):
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(Quiet, directory=st))
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv, f"http://127.0.0.1:{srv.server_address[1]}/render.html"


def cut_size(st, cut):
    t = json.load(open(os.path.join(st, "timeline.json"))).get(cut, {})
    return t.get("w", 1920), t.get("h", 1080)


def open_page(p, url, cut, caps, size=(1920, 1080)):
    b = p.chromium.launch(); pg = b.new_page(viewport={"width": size[0], "height": size[1]})
    errs = []
    pg.on("pageerror", lambda e: errs.append(str(e)))
    pg.on("console", lambda m: errs.append(m.text) if m.type == "error" else None)
    pg.goto(url); total = pg.evaluate(f"init('{cut}', {str(caps).lower()})")
    return b, pg, total, errs


GRAB = "(()=>{{frame({t}); return document.getElementById('c').toDataURL('image/jpeg',{q})}})()"


# ------------------------------------------------------------------ snapshots for QA
def snap(args):
    from playwright.sync_api import sync_playwright
    P = args.project; cfg = load(P)["config"]; st = stage(P); srv, url = serve(st)
    tl = json.load(open(bdir(P, "timeline.json")))[args.cut]
    ts = [float(x) for x in args.times] or [round(s["start"] + s["dur"] * args.at, 2) for s in tl["scenes"]]
    od = bdir(P, "snaps", args.cut); files = []
    with sync_playwright() as p:
        b, pg, _, errs = open_page(p, url, args.cut, cfg.get("captions", True), cut_size(st, args.cut))
        for t in ts:
            d = pg.evaluate(GRAB.format(t=t, q=.85))
            f = os.path.join(od, f"{t:07.2f}.jpg"); open(f, "wb").write(base64.b64decode(d[23:])); files.append(f)
        b.close()
    srv.shutdown()
    sheets = []
    for i in range(0, len(files), 6):
        out = os.path.join(od, f"sheet_{i // 6 + 1}.jpg")
        sh([sys.executable, os.path.join(SKILL, "scripts", "sheet.py"), out] + files[i:i + 6]); sheets.append(out)
    print("JS errors:", errs[:5] if errs else "none")
    print("sheets:", *sheets, sep="\n  ")


# ------------------------------------------------------------------ cues (sound effects list from scenes)
def cues(P, st, cutnames):
    from playwright.sync_api import sync_playwright
    srv, url = serve(st); out = {}
    with sync_playwright() as p:
        for c in cutnames:
            b, pg, _, errs = open_page(p, url, c, False, cut_size(st, c))
            out[c] = pg.evaluate("allCues()"); b.close()
            if errs: print("JS errors in", c, errs[:3])
    srv.shutdown()
    json.dump(out, open(bdir(P, "cues.json"), "w"))
    return out


# ------------------------------------------------------------------ audio
def audio(args):
    P = args.project; spec = load(P); cuts = args.cuts or list(spec["cuts"])
    st = stage(P); cues(P, st, cuts)
    sh([sys.executable, os.path.join(SKILL, "scripts", "audio.py"), P] + cuts, check=True)


# ------------------------------------------------------------------ render
def render_part(args):
    from playwright.sync_api import sync_playwright
    P = args.project; cfg = load(P)["config"]; fps = cfg.get("fps", 30)
    st = bdir(P, "stage"); srv, url = serve(st)
    ff = subprocess.Popen(["ffmpeg", "-y", "-loglevel", "error", "-f", "image2pipe", "-framerate", str(fps), "-c:v", "mjpeg",
                           "-i", "-", "-c:v", "libx264", "-preset", "medium", "-crf", "17", "-pix_fmt", "yuv420p",
                           "-r", str(fps), args.out], stdin=subprocess.PIPE)
    t0 = time.time()
    with sync_playwright() as p:
        b, pg, total, errs = open_page(p, url, args.cut, cfg.get("captions", True), cut_size(st, args.cut))
        f1 = min(args.f1, int(round(total * fps)))
        for f in range(args.f0, f1):
            ff.stdin.write(base64.b64decode(pg.evaluate(GRAB.format(t=f / fps, q=.94))[23:]))
            if f % 300 == 0: print(args.cut, f, "/", f1, round(time.time() - t0), "s", flush=True)
        b.close()
    ff.stdin.close(); ff.wait(); srv.shutdown()
    if errs: print("JS errors:", errs[:5])


def render(args):
    P = os.path.abspath(args.project); spec = load(P); cfg = spec["config"]
    fps = cfg.get("fps", 30); cuts = args.cuts or list(spec["cuts"])
    tl = json.load(open(bdir(P, "timeline.json"))); stage(P)
    parts, procs = bdir(P, "parts"), []
    jobs = []
    for c in cuts:
        n = int(round(tl[c]["total"] * fps)); k = max(1, min(args.workers, n // 600 or 1))
        step = -(-n // k)
        for i in range(k):
            jobs.append((c, i * step, min(n, (i + 1) * step), os.path.join(parts, f"{c}_{i}.mp4")))
    me = os.path.abspath(__file__)
    running = []
    for j in jobs:  # simple pool
        while len(running) >= args.workers:
            running = [r for r in running if r.poll() is None]; time.sleep(1)
        log = open(j[3] + ".log", "w")
        running.append(subprocess.Popen([sys.executable, me, "render-part", P, j[0], str(j[1]), str(j[2]), j[3]], stdout=log, stderr=subprocess.STDOUT))
    for r in running: r.wait()
    out = bdir(P, "out")
    for c in cuts:
        lst = os.path.join(parts, f"{c}.txt")
        open(lst, "w").write("".join(f"file '{os.path.basename(j[3])}'\n" for j in jobs if j[0] == c))
        vid = os.path.join(parts, f"{c}_video.mp4")
        sh(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", vid], check=True)
        name = cfg.get("names", {}).get(c, f"{cfg.get('title', 'video').replace(' ', '_')}_{c}")
        wav = os.path.join(P, "build", f"audio_{c}.wav")
        final = os.path.join(out, name + ".mp4")
        if os.path.exists(wav):
            sh(["ffmpeg", "-y", "-loglevel", "error", "-i", vid, "-i", wav, "-map", "0:v", "-map", "1:a", "-c:v", "copy",
                "-af", f"loudnorm=I={cfg.get('lufs', -14)}:TP=-1.5:LRA=11", "-ar", "48000", "-c:a", "aac", "-b:a", "256k",
                "-shortest", "-movflags", "+faststart", final], check=True)
        else:
            shutil.copy(vid, final)
        print("wrote", final)


# ------------------------------------------------------------------ verify
def verify(args):
    P = args.project; out = bdir(P, "out"); ok = True
    for f in sorted(os.listdir(out)):
        if not f.endswith(".mp4"): continue
        p = os.path.join(out, f)
        pr = sh(["ffprobe", "-v", "error", "-show_entries", "stream=codec_type,width,height:format=duration", "-of", "json", p],
                capture_output=True, text=True)
        info = json.loads(pr.stdout); dur = float(info["format"]["duration"])
        kinds = [s["codec_type"] for s in info["streams"]]
        lu = sh(["ffmpeg", "-hide_banner", "-i", p, "-af", "ebur128", "-f", "null", "-"], capture_output=True, text=True).stderr
        I = [l.split("I:")[1].strip() for l in lu.splitlines() if l.strip().startswith("I:")]
        sheet = os.path.join(out, f.replace(".mp4", "_check.jpg")); frames = []
        for k in range(6):
            fr = os.path.join(bdir(P, "parts"), f"chk_{k}.jpg")
            sh(["ffmpeg", "-y", "-loglevel", "error", "-ss", str(dur * (k + .5) / 6), "-i", p, "-frames:v", "1", fr]); frames.append(fr)
        sh([sys.executable, os.path.join(SKILL, "scripts", "sheet.py"), sheet] + frames)
        flag = "OK" if ("audio" in kinds and "video" in kinds) else "MISSING STREAM"
        ok &= flag == "OK"
        print(f"{flag:4s} {f}  {dur:6.1f}s  streams={kinds}  loudness={I[-1] if I else '?'}  sheet={sheet}")
    return ok



# ------------------------------------------------------------------ logo prep
def logo(args):
    """Make a dark-background-friendly logo: black/white backgrounds -> transparent, grey text -> white."""
    import numpy as np
    from PIL import Image
    im = Image.open(args.src).convert("RGBA"); a = np.asarray(im).astype(float)
    rgb, al = a[..., :3], a[..., 3] / 255
    mx, mn = rgb.max(2), rgb.min(2); sat = mx - mn
    if args.bg == "auto":
        corner = rgb[:5, :5].reshape(-1, 3).mean(0); args.bg = "white" if corner.mean() > 128 else "black"
    lum = (255 - mx) if args.bg == "white" else mx
    alpha = np.clip(lum / 75, 0, 1) * al
    grey = sat < 25
    out = np.zeros_like(a)
    out[..., :3] = np.where(grey[..., None], 255, np.clip(rgb, 0, 255))
    out[..., 3] = alpha * 255
    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    Image.fromarray(out.astype("uint8"), "RGBA").save(args.out); print("wrote", args.out, "(source bg:", args.bg + ")")

def build(args):
    vo(args); audio(args); render(args); verify(args)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="cmd", required=True)
    sp.add_parser("doctor").set_defaults(fn=doctor)
    a = sp.add_parser("new"); a.add_argument("project"); a.add_argument("--from", dest="from_", default="starter"); a.set_defaults(fn=new)
    a = sp.add_parser("vo"); a.add_argument("project"); a.set_defaults(fn=vo)
    a = sp.add_parser("snap"); a.add_argument("project"); a.add_argument("cut"); a.add_argument("times", nargs="*")
    a.add_argument("--at", type=float, default=.8, help="fraction into each scene when no times given"); a.set_defaults(fn=snap)
    a = sp.add_parser("audio"); a.add_argument("project"); a.add_argument("cuts", nargs="*"); a.set_defaults(fn=audio)
    a = sp.add_parser("render"); a.add_argument("project"); a.add_argument("cuts", nargs="*"); a.add_argument("--workers", type=int, default=2); a.set_defaults(fn=render)
    a = sp.add_parser("render-part"); a.add_argument("project"); a.add_argument("cut"); a.add_argument("f0", type=int); a.add_argument("f1", type=int); a.add_argument("out"); a.set_defaults(fn=render_part)
    a = sp.add_parser("build"); a.add_argument("project"); a.add_argument("cuts", nargs="*"); a.add_argument("--workers", type=int, default=2); a.set_defaults(fn=build)
    a = sp.add_parser("logo"); a.add_argument("src"); a.add_argument("out"); a.add_argument("--bg", default="auto", choices=["auto", "black", "white"]); a.set_defaults(fn=logo)
    a = sp.add_parser("verify"); a.add_argument("project"); a.set_defaults(fn=verify)
    args = ap.parse_args(); args.fn(args)


if __name__ == "__main__":
    main()
