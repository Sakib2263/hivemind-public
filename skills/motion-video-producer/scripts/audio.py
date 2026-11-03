# Builds the soundtrack per cut: VO + generated music + synthesized SFX, with ducking.
# usage: audio.py PROJECT [CUT ...]  (reads build/timeline.json, build/cues.json; writes build/audio_<cut>.wav)
import json, sys, os
import numpy as np, soundfile as sf
from scipy.signal import butter, sosfilt, resample_poly

SR = 48000
rng = np.random.default_rng(7)
PROJ = sys.argv[1]
B = lambda *p: os.path.join(PROJ, "build", *p)
TLS = json.load(open(B("timeline.json"))); CUES = json.load(open(B("cues.json")))
CFG = json.load(open(os.path.join(PROJ, "cuts.json")))["config"]
MUS = CFG.get("music", {})

def T(d): return np.arange(int(d * SR)) / SR
def env_exp(d, k): return np.exp(-T(d) * k)
def noise(d): return rng.standard_normal(int(d * SR))
def bp(x, lo, hi): return sosfilt(butter(2, [lo, hi], btype="band", fs=SR, output="sos"), x)
def lp(x, f): return sosfilt(butter(2, f, btype="low", fs=SR, output="sos"), x)
def hp(x, f): return sosfilt(butter(2, f, btype="high", fs=SR, output="sos"), x)
def glide(f0, f1, d, curve=1.0):
    t = T(d); f = f0 + (f1 - f0) * (t / d) ** curve
    return np.sin(2 * np.pi * np.cumsum(f) / SR)
def sweep_noise(d, f0, f1, q=0.6):
    n = noise(d); out = np.zeros_like(n); seg = 512
    for i in range(0, len(n), seg):
        u = i / len(n); fc = f0 * (f1 / f0) ** u
        out[i:i + seg] = bp(n[max(0, i - 2048):i + seg], max(40, fc * (1 - q / 2)), min(20000, fc * (1 + q / 2)))[-len(n[i:i + seg]):]
    return out
def norm(x, peak=1.0): m = np.max(np.abs(x)) + 1e-9; return x / m * peak

# ---------------- SFX ----------------
def s_whoosh(d=0.5, f0=300, f1=4000):
    x = sweep_noise(d, f0, f1); e = np.sin(np.pi * np.clip(T(d) / d, 0, 1)) ** 1.5; return norm(x * e, .8)
def s_pop(): d = .12; return norm(glide(700, 260, d) * env_exp(d, 40) + .3 * hp(noise(d), 3000) * env_exp(d, 300), .8)
def s_tick(): d = .05; return norm(np.sin(2 * np.pi * 2400 * T(d)) * env_exp(d, 120), .6)
def s_tickroll():
    out = np.zeros(int(1.2 * SR))
    for i in range(14):
        t = s_tick() * (.5 + .5 * rng.random()); o = int(i * .08 * SR); out[o:o + len(t)] += t * .6
    return out
def s_coin():
    a = np.sign(np.sin(2 * np.pi * 988 * T(.07))) * .3; b = np.sign(np.sin(2 * np.pi * 1319 * T(.35))) * .3 * env_exp(.35, 9)
    return lp(np.concatenate([a, b]), 6000)
def s_impact(): d = 1.4; return norm(np.sin(2 * np.pi * 52 * T(d)) * env_exp(d, 3.5) + .5 * lp(noise(d), 900) * env_exp(d, 9), 1)
def s_boom(): d = 1.8; return norm(glide(90, 32, d, .5) * env_exp(d, 2.2), 1)
def s_riser(d=1.7):
    t = T(d); x = .6 * sweep_noise(d, 400, 8000, .4) + .5 * glide(180, 900, d, 2) * .5
    return norm(x * (t / d) ** 2.2, .9)
def s_shimmer():
    d = 1.6; t = T(d); x = sum(np.sin(2 * np.pi * f * t + i) for i, f in enumerate([2093, 2637, 3136, 4186]))
    return norm(x * env_exp(d, 2.5) * (1 - np.exp(-t * 30)) * (.7 + .3 * np.sin(2 * np.pi * 9 * t)), .5)
def s_chime():
    d = 2.0; t = T(d); x = sum(a * np.sin(2 * np.pi * f * t) for f, a in [(1046.5, 1), (1568, .6), (2093, .4), (3136, .2)])
    return norm(x * env_exp(d, 2.6) * (1 - np.exp(-t * 200)), .6)
def s_click(): d = .02; return norm(hp(noise(d), 2000) * env_exp(d, 300), .7)
def s_thud(): d = .45; return norm(np.sin(2 * np.pi * 70 * T(d)) * env_exp(d, 9) + .3 * lp(noise(d), 500) * env_exp(d, 25), .9)
def s_error():
    a = np.sign(np.sin(2 * np.pi * 330 * T(.12))) * env_exp(.12, 10); b = np.sign(np.sin(2 * np.pi * 247 * T(.25))) * env_exp(.25, 8)
    return lp(np.concatenate([a, b]), 2500) * .35
def s_glitch():
    d = .4; x = noise(d); x = np.round(x * 3) / 3; gate = (np.sin(2 * np.pi * 23 * T(d)) > 0).astype(float)
    return norm(bp(x, 300, 5000) * gate * env_exp(d, 5), .7)
def s_crack(): d = .7; x = noise(d) * (rng.random(int(d * SR)) > .985) * 3 + .2 * hp(noise(d), 1500); return norm(x * env_exp(d, 3), .8)
def s_flashhit(): a = s_impact() * .8; b = s_shimmer(); n = max(len(a), len(b)); o = np.zeros(n); o[:len(a)] += a; o[:len(b)] += b * .6; return o
def s_sonar():
    d = 1.2; t = T(d); x = np.sin(2 * np.pi * 1180 * t) * env_exp(d, 5)
    o = x.copy(); dl = int(.22 * SR); o[dl:] += .35 * x[:-dl]; return norm(o, .5)
def s_blip(): d = .08; return norm(np.sin(2 * np.pi * 1560 * T(d)) * env_exp(d, 50), .5)
def s_drop(): d = .15; return norm(glide(520, 220, d) * env_exp(d, 22), .6)
def s_swipe(): d = .25; return norm(hp(noise(d), 2500) * np.sin(np.pi * T(d) / d), .5)
def s_type(): return s_click() * .8
def s_success():
    out = np.zeros(int(.9 * SR))
    for i, f in enumerate([784, 988, 1175, 1568]):
        d = .45; x = np.sin(2 * np.pi * f * T(d)) * env_exp(d, 9) + .3 * np.sin(4 * np.pi * f * T(d)) * env_exp(d, 14)
        o = int(i * .07 * SR); out[o:o + len(x)] += x * .4
    return out
def s_stamp(): a = s_thud(); b = s_click(); a[:len(b)] += b; return a
def s_swirl(): d = .9; return norm(sweep_noise(d, 600, 3000, .3) * np.sin(np.pi * T(d) / d), .5)
def s_send(): return s_whoosh(.35, 800, 6000) * .8
def s_spin(): return s_whoosh(1.3, 200, 2500) * .7
def s_boing(): d = .25; f = 300 + 300 * (T(d) / d) + 25 * np.sin(2 * np.pi * 18 * T(d)); return norm(np.sin(2 * np.pi * np.cumsum(f) / SR) * env_exp(d, 10), .5)
def s_beep(): d = .14; return lp(np.sign(np.sin(2 * np.pi * 1800 * T(d))), 5000) * .25 * env_exp(d, 6)
def s_down(): d = .7; return norm(glide(600, 140, d) * np.sin(np.pi * T(d) / d), .45)
SFX = dict(whoosh=s_whoosh, whoosh_big=lambda: s_whoosh(.75, 150, 3000) * 1.1, pop=s_pop, tick=s_tick, tickroll=s_tickroll, coin=s_coin,
           impact=s_impact, boom=s_boom, riser=s_riser, shimmer=s_shimmer, chime=s_chime, click=s_click, thud=s_thud, error=s_error,
           glitch=s_glitch, crack=s_crack, flashhit=s_flashhit, sonar=s_sonar, blip=s_blip, drop=s_drop, swipe=s_swipe, type=s_type,
           success=s_success, stamp=s_stamp, swirl=s_swirl, send=s_send, spin=s_spin, boing=s_boing, beep=s_beep, down=s_down)
CACHE = {}
def sfx(name):
    if name not in CACHE: CACHE[name] = SFX[name]()
    return CACHE[name]

# ---------------- MUSIC ----------------
def music_file(path, n, quiet_end):  # a real track: 48 kHz stereo via ffmpeg, looped to length, faded out at quiet_end
    import subprocess
    wav = B("music_" + os.path.splitext(os.path.basename(path))[0] + ".wav")
    if not os.path.exists(wav) or os.path.getmtime(wav) < os.path.getmtime(path):
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", path, "-ar", str(SR), "-ac", "2", wav], check=True)
    x, _ = sf.read(wav, always_2d=True)
    x = np.tile(x, (n // len(x) + 1, 1))[:n] if len(x) < n else x[:n]
    x = norm(x, .9); f = np.ones(n); q = int(min(quiet_end, n / SR) * SR); fl = int(2.5 * SR)
    f[q:] = np.clip(1 - (np.arange(n - q)) / fl, 0, 1)
    f[:int(.5 * SR)] = np.linspace(0, 1, int(.5 * SR))
    return x * f[:, None]

NOTE = lambda n: 440 * 2 ** ((n - 69) / 12)
def saw(f, t, h=12): return sum(np.sin(2 * np.pi * f * k * t) / k for k in range(1, h + 1))
def music(total, drop, quiet_end, bpm=112):
    n = int(total * SR) + SR; L = np.zeros(n); R = np.zeros(n)
    def add(sig, t0, gain=1.0, pan=0.0):
        o = int(t0 * SR)
        if o >= n or o + len(sig) <= 0: return
        if o < 0: sig = sig[-o:]; o = 0
        m = min(len(sig), n - o); L[o:o + m] += sig[:m] * gain * (1 - pan) ; R[o:o + m] += sig[:m] * gain * (1 + pan)
    beat = 60 / bpm; bar = 4 * beat
    # --- intro / problem ambient pad (Am - F), before drop ---
    if drop > 1:
        prog0 = [[57, 60, 64], [53, 57, 60]]
        t = 0.0; i = 0
        while t < drop:
            d = min(bar * 2, drop - t) + .6; tt = T(d)
            ch = sum(saw(NOTE(m - 12), tt, 6) for m in prog0[i % 2])
            e = np.minimum(1, tt / .8) * np.minimum(1, (d - tt) / .6)
            add(lp(ch, 900) * e * .05, t, pan=-.1); add(lp(ch * 1.003, 800) * e * .05, t, pan=.1)
            t += bar * 2; i += 1
        # ticking clock pulse
        t = 0.0
        while t < drop - .3:
            add(np.sin(2 * np.pi * 1500 * T(.03)) * env_exp(.03, 150) * .05, t); t += beat
    # --- main groove: C G Am F ---
    prog = [(48, [60, 64, 67]), (43, [55, 59, 62, 67]), (45, [57, 60, 64]), (41, [53, 57, 60, 65])]
    kick = np.sin(2 * np.pi * np.cumsum(55 + 100 * np.exp(-T(.35) * 30)) / SR) * env_exp(.35, 9)
    clap = bp(noise(.2), 900, 4000) * env_exp(.2, 25)
    hat = hp(noise(.05), 7000) * env_exp(.05, 80)
    nbars = int((total - drop) / bar) + 2
    for b in range(nbars):
        t0 = drop + b * bar
        if t0 > total: break
        root, ch = prog[(b // 2) % 4]
        ending = t0 >= quiet_end
        # pad (sustain whole bar)
        d = bar + .3; tt = T(d)
        pad = sum(saw(NOTE(m), tt, 8) * (1 + .002 * k) for k, m in enumerate(ch))
        pe = np.minimum(1, tt / .15) * np.minimum(1, (d - tt) / .3)
        add(lp(pad, 2200) * pe * .022, t0, pan=-.25); add(lp(pad, 2000) * pe * .022, t0 + .012, pan=.25)
        if ending: continue
        intro_build = b < 2  # first 2 bars after drop: lighter
        for k in range(4):
            tb = t0 + k * beat
            add(kick * .55, tb)
            if k in (1, 3) and not intro_build: add(clap * .22, tb, pan=.05)
            for h in (0, .5):
                add(hat * (.10 if h else .06), tb + h * beat, pan=.3)
            # bass 8ths w/ sidechain shape
            for h in (0, .5):
                d2 = beat * .48; t2 = T(d2); bs = (np.sin(2 * np.pi * NOTE(root - 12 + (12 if h else 0) * 0) * t2) + .3 * saw(NOTE(root - 12), t2, 5))
                be = np.minimum(1, t2 / .02) * np.exp(-t2 * 4) * (1 - np.exp(-t2 * 60))
                add(lp(bs, 700) * be * .16, tb + h * beat)
        # pluck arpeggio 16ths
        if not intro_build:
            arp = ch + [ch[0] + 12]
            for s in range(16):
                ts = t0 + s * beat / 4; f = NOTE(arp[(s * 3) % len(arp)] + 12)
                d3 = .22; t3 = T(d3); pl = (2 * np.abs(2 * ((f * t3) % 1) - 1) - 1) * np.exp(-t3 * 18)
                add(lp(pl, 4500) * .035 * (1.2 if s % 4 == 0 else .8), ts, pan=(-.4 if s % 2 else .4))
    # final ring + fade
    out = np.stack([L, R], 1)[:int(total * SR)]
    fade = np.ones(len(out)); fl = int(2.5 * SR); fade[-fl:] = np.linspace(1, 0, fl) ** 1.5
    return out * fade[:, None]

def build(cut):
    tl = TLS[cut]; total = tl["total"]; n = int(total * SR)
    # VO
    vo = np.zeros(n)
    for sc in tl["scenes"]:
        for v in sc["vo"]:
            x, sr = sf.read(os.path.join(PROJ, v["file"])); x = resample_poly(x, SR, sr)
            o = int(v["t"] * SR); m = min(len(x), n - o); vo[o:o + m] += x[:m]
    vo = norm(vo, .8)
    # voice EQ: gentle low cut + presence
    vo = hp(vo, 90); vo = vo + .15 * bp(vo, 2500, 5000)
    # duck envelope
    a = np.abs(vo); env = np.zeros(n); g = 0.0
    att, rel = np.exp(-1 / (.03 * SR)), np.exp(-1 / (.35 * SR))
    # vectorize-ish via block max
    blk = 240; bm = np.array([a[i:i + blk].max() for i in range(0, n, blk)]); be = np.zeros_like(bm)
    for i, v in enumerate(bm): g = v + (g - v) * (att ** blk if v > g else rel ** blk); be[i] = g
    env = np.repeat(be, blk)[:n]; env = np.clip(env / .2, 0, 1)
    scenes = {s["id"]: s for s in tl["scenes"]}
    ds, es = MUS.get("drop_scene"), MUS.get("end_scene")
    drop = scenes[ds]["start"] if ds in scenes else 0
    quiet = scenes[es]["start"] + 1.0 if es in scenes else total
    if MUS.get("file"):
        mus = music_file(os.path.join(PROJ, MUS["file"]), n, quiet)
    else:
        mus = music(total, drop, quiet, MUS.get("bpm", 112)) if MUS.get("enabled", True) else np.zeros((n, 2))
    mus *= MUS.get("level", 0.36) * (1 - .55 * env)[:, None]
    # SFX
    fx = np.zeros((n, 2))
    for t, name, gain in CUES[cut]:
        if name not in SFX: continue
        x = sfx(name) * gain * .55; o = int(t * SR)
        if o >= n: continue
        m = min(len(x), n - o); pan = .15 * np.sin(t * 3.1)
        fx[o:o + m, 0] += x[:m] * (1 - pan); fx[o:o + m, 1] += x[:m] * (1 + pan)
    mix = mus * 1.0 + fx * 1.2 + vo[:, None] * 1.0
    mix = np.tanh(mix * 1.1) / np.tanh(1.1)
    mix = norm(mix, .95)
    sf.write(B(f"audio_{cut}.wav"), mix.astype(np.float32), SR)
    print(cut, round(total, 1), "s written")

for c in (sys.argv[2:] or list(TLS)): build(c)
