#!/usr/bin/env python3
"""comfy.py - send shots to the local ComfyUI (Video Studio) and save the results. Stdlib only.

  comfy.py ping                              is ComfyUI up? shows the GPU and free VRAM
  comfy.py batch PROJECT/shots.json [--force] [--only ID,ID]
                                             every shot -> PROJECT/build/ai/<id>.mp4|.png (skips done ones)
  comfy.py run WORKFLOW --out DIR [--name N] [--set KEY=VALUE ...]
                                             one job; WORKFLOW = video | i2v | image | a .json path

shots.json:
  {"defaults": {"aspect": "16:9"},                     optional: any key below, for every shot
   "shots": [
     {"id": "bg1",  "kind": "image", "prompt": "..."},                   FLUX schnell still
     {"id": "s01",  "kind": "video", "prompt": "...", "frames": 73},     Wan 2.2 5B text to video
     {"id": "s02",  "kind": "i2v",   "prompt": "...", "image": "@bg1"}   animate a still (@id or a file path)
   ]}
  Keys: aspect (16:9 | 9:16 | 1:1), w, h, frames (4n+1; 24 fps, 73 = 3 s), steps, seed, fps, neg.
Server: env COMFY_URL, else 127.0.0.1:8188, else the Windows host seen from WSL.
"""
import json, os, random, sys, time, urllib.error, urllib.parse, urllib.request, uuid

HERE = os.path.dirname(os.path.abspath(__file__))
WF_DIR = os.path.join(os.path.dirname(HERE), "studio", "workflows")
WORKFLOWS = {"video": "wan22_5b.json", "i2v": "wan22_5b_i2v.json", "image": "flux_schnell.json"}
NEG = ("oversaturated, overexposed, static, blurry details, subtitles, text, watermark, logo, still image, "
       "grey, worst quality, low quality, JPEG artifacts, ugly, deformed, extra fingers, bad hands, bad face, "
       "fused fingers, messy background, three legs, crowded background, walking backwards")
SIZES = {  # (video w,h)  (image w,h)
    "16:9": ((1280, 704), (1344, 768)), "9:16": ((704, 1280), (768, 1344)), "1:1": ((960, 960), (1024, 1024))}
BASE = {"video": {"FRAMES": 73, "STEPS": 20, "FPS": 24}, "i2v": {"FRAMES": 73, "STEPS": 20, "FPS": 24},
        "image": {"STEPS": 4}}


def die(msg, code=1):
    print(msg); sys.exit(code)


def server():
    cands = [os.environ["COMFY_URL"]] if os.environ.get("COMFY_URL") else ["http://127.0.0.1:8188"]
    try:  # WSL (NAT mode): Windows is the default gateway
        for line in open("/proc/net/route").read().splitlines()[1:]:
            f = line.split()
            if f[1] == "00000000":
                g = bytes.fromhex(f[2])[::-1]
                cands.append("http://%d.%d.%d.%d:8188" % tuple(g))
                break
    except OSError:
        pass
    for u in cands:
        try:
            urllib.request.urlopen(u + "/system_stats", timeout=4).read()
            return u.rstrip("/")
        except (urllib.error.URLError, OSError):
            continue
    die("ComfyUI is not running. Double-click shortcuts\\14 Start Video Studio.bat and try again. (tried %s)"
        % ", ".join(cands), 3)


def call(url, data=None, headers=None, timeout=60):
    req = urllib.request.Request(url, data=data, headers=headers or {})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read()
    except urllib.error.HTTPError as e:
        die("ComfyUI said %s: %s" % (e.code, e.read().decode("utf-8", "replace")[:1500]))


def upload(base, path):
    b = uuid.uuid4().hex
    body = (("--%s\r\nContent-Disposition: form-data; name=\"overwrite\"\r\n\r\ntrue\r\n"
             "--%s\r\nContent-Disposition: form-data; name=\"image\"; filename=\"%s\"\r\n"
             "Content-Type: application/octet-stream\r\n\r\n") % (b, b, os.path.basename(path))).encode()
    body += open(path, "rb").read() + ("\r\n--%s--\r\n" % b).encode()
    r = json.loads(call(base + "/upload/image", body, {"Content-Type": "multipart/form-data; boundary=" + b}))
    return (r["subfolder"] + "/" if r.get("subfolder") else "") + r["name"]


def fill(node, vals):
    if isinstance(node, dict):
        return {k: fill(v, vals) for k, v in node.items()}
    if isinstance(node, list):
        return [fill(v, vals) for v in node]
    if isinstance(node, str) and len(node) > 2 and node[0] == node[-1] == "%":
        key = node[1:-1]
        if key not in vals:
            die("workflow needs %s but it was not set" % key)
        return vals[key]
    return node


def load_wf(name):
    p = name if name.endswith(".json") else os.path.join(WF_DIR, WORKFLOWS.get(name, name + ".json"))
    if not os.path.isfile(p):
        die("no workflow %s (have: %s)" % (name, ", ".join(WORKFLOWS)))
    return {k: v for k, v in json.load(open(p)).items() if not k.startswith("_")}


def run(base, wf, vals, out_dir, name, timeout):
    graph = fill(load_wf(wf), vals)
    pid = json.loads(call(base + "/prompt", json.dumps({"prompt": graph, "client_id": uuid.uuid4().hex}).encode(),
                          {"Content-Type": "application/json"}))["prompt_id"]
    t0 = time.time()
    while True:
        h = json.loads(call(base + "/history/" + pid)).get(pid)
        if h and (h.get("outputs") or h.get("status", {}).get("completed") is not None
                  or h.get("status", {}).get("status_str") == "error"):
            break
        if time.time() - t0 > timeout:
            call(base + "/interrupt", b"{}", {"Content-Type": "application/json"})
            die("timed out after %ds: %s" % (timeout, name))
        time.sleep(5)
    st = h.get("status", {})
    if st.get("status_str") == "error":
        msgs = [m[1].get("exception_message", "") for m in st.get("messages", []) if m[0] == "execution_error"]
        die("ComfyUI error on %s: %s" % (name, " | ".join(msgs)[:1500] or "see the ComfyUI window"))
    files = [f for o in h.get("outputs", {}).values() for v in o.values() if isinstance(v, list)
             for f in v if isinstance(f, dict) and f.get("filename")]
    if not files:
        die("no output file for %s" % name)
    os.makedirs(out_dir, exist_ok=True)
    saved = []
    for i, f in enumerate(files):
        q = urllib.parse.urlencode({"filename": f["filename"], "subfolder": f.get("subfolder", ""),
                                    "type": f.get("type", "output")})
        dst = os.path.join(out_dir, name + ("" if i == 0 else "_%d" % i) + os.path.splitext(f["filename"])[1])
        open(dst, "wb").write(call(base + "/view?" + q, timeout=600))
        saved.append(dst)
    return saved, round(time.time() - t0)


def shot_vals(kind, s):
    vid = kind != "image"
    w, h = SIZES.get(s.get("aspect", "16:9"), SIZES["16:9"])[0 if vid else 1]
    v = dict(BASE[kind], W=w, H=h, NEG=NEG, SEED=random.randint(1, 2**48))
    for k in ("w", "h", "frames", "steps", "seed", "fps", "neg", "prompt"):
        if k in s:
            v[k.upper()] = s[k]
    if vid and (v["FRAMES"] - 1) % 4:
        v["FRAMES"] = (v["FRAMES"] - 1) // 4 * 4 + 1  # Wan wants 4n+1 frames
    return v


def batch(path, force=False, only=None, timeout=3600):
    proj = os.path.dirname(os.path.abspath(path))
    spec = json.load(open(path))
    out_dir = os.path.join(proj, "build", "ai")
    base, done, fails = server(), {}, []
    shots = spec.get("shots", [])
    for n, raw in enumerate(shots, 1):
        s = dict(spec.get("defaults", {}), **raw)
        sid, kind = str(s.get("id") or "shot%02d" % n), s.get("kind", "video")
        if kind not in WORKFLOWS:
            fails.append("%s: kind must be video, i2v or image" % sid); continue
        old = [f for f in sorted(os.listdir(out_dir)) if os.path.splitext(f)[0] == sid and not f.endswith(".json")] if os.path.isdir(out_dir) else []
        if old and not force:
            done[sid] = os.path.join(out_dir, old[0]); print("skip %s (exists)" % sid); continue
        if only and sid not in only:
            continue
        v = shot_vals(kind, s)
        v["PREFIX"] = "hivemind/" + sid
        if kind == "i2v":
            img = str(s.get("image", ""))
            img = done.get(img[1:], "") if img.startswith("@") else os.path.join(proj, img)
            if not os.path.isfile(img):
                fails.append("%s: start image not found (%s)" % (sid, s.get("image"))); continue
            v["IMAGE"] = upload(base, img)
        print("[%d/%d] %s %s %sx%s ..." % (n, len(shots), sid, kind, v["W"], v["H"]), flush=True)
        try:
            saved, secs = run(base, kind, v, out_dir, sid, timeout)
        except SystemExit as e:
            fails.append("%s: %s" % (sid, e)); continue
        done[sid] = saved[0]
        json.dump({"kind": kind, "seconds": secs, **{k.lower(): v[k] for k in v if k != "NEG"}},
                  open(os.path.join(out_dir, sid + ".json"), "w"), indent=1)
        print("  saved %s (%ds)" % (os.path.relpath(saved[0], proj), secs), flush=True)
    print("batch: %d ok, %d failed%s" % (len(done), len(fails), "".join("\n  FAIL " + f for f in fails)))
    return 1 if fails else 0


def main(a):
    if not a or a[0] in ("-h", "--help"):
        print(__doc__); return 0
    if a[0] == "ping":
        b = server(); s = json.loads(call(b + "/system_stats"))
        for d in s.get("devices", []):
            print("%s: %s, VRAM free %.1f / %.1f GB" % (b, d.get("name"), d.get("vram_free", 0) / 1e9, d.get("vram_total", 0) / 1e9))
        return 0
    if a[0] == "batch" and len(a) > 1:
        only = a[a.index("--only") + 1].split(",") if "--only" in a else None
        return batch(a[1], "--force" in a, only)
    if a[0] == "run" and len(a) > 1:
        vals, out, name, i = {"NEG": NEG, "SEED": random.randint(1, 2**48), "PREFIX": "hivemind/run"}, ".", "out", 2
        while i < len(a):
            if a[i] == "--set": k, _, v = a[i + 1].partition("="); vals[k] = int(v) if v.isdigit() else v; i += 2
            elif a[i] == "--out": out = a[i + 1]; i += 2
            elif a[i] == "--name": name = a[i + 1]; i += 2
            else: die("unknown option " + a[i])
        base = server()
        if "IMAGE" in vals and os.path.isfile(str(vals["IMAGE"])):
            vals["IMAGE"] = upload(base, vals["IMAGE"])
        saved, secs = run(base, a[1], vals, out, name, 3600)
        print("saved %s (%ds)" % (", ".join(saved), secs)); return 0
    print(__doc__); return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
