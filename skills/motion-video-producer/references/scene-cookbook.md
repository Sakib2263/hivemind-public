# Scene Cookbook — engine API, layout rules, gotchas

Read this before writing or editing any `scenes.js`.

## Contents
1. Project files
2. cuts.json reference
3. Scene contract
4. Engine API
5. Layout grid and safe zones
6. Transitions
7. Sound-effect names
8. Gotchas learned the hard way

## 1. Project files

```
PROJECT/
  cuts.json        config + every cut's scene list with VO lines and options
  scenes.js        scene drawing code (starter blocks or bespoke scenes)
  assets/logo.png  optional; white/transparent version for dark backgrounds (loaded as LOGO)
  build/           generated: vo/, timeline.json, stage/, snaps/, parts/, audio_*.wav, out/
```

## 2. cuts.json reference

```json
{
 "config": {
  "title": "...", "voice": "af_heart", "speed": 1.0, "fps": 30, "captions": true, "lufs": -14,
  "lead": 0.6, "gap": 0.32,
  "pronounce": {"NOVA": "No-va"},
  "music": {"drop_scene": "reveal", "end_scene": "endcard", "bpm": 112, "level": 0.36, "enabled": true},
  "names": {"master": "Product_Explainer_Full_16x9"}
 },
 "cuts": { "master": [ {"id": "hook", "type": "title", "lines": ["..."], "min": 3, "tail": 0.8, "fast": false, "...": "scene options"} ] }
}
```

- `lines`: VO sentences. One clip per sentence, so captions and animations sync exactly to each one.
- `min`: minimum scene length (for scenes without VO). `tail`: hold after the last line (default 0.75; 0.35 if `fast`).
- Any other key becomes `sc.opt` inside the scene.
- `pronounce`: text swaps applied only to what the voice says (captions keep the real spelling). Use for acronyms and brand names.
- `music.drop_scene`: the beat drops when this scene starts (usually the product reveal). Before it, a soft tense pad plays.
- `voice: "none"` → captions-only timing, no VO track.
- Voices (Kokoro): `af_heart` (warm female, best), `af_bella`, `am_michael` (male), `am_adam`, `bm_george` (British male), `bf_emma`.

## 3. Scene contract

```js
SC.my_scene = {
  draw(ctx, lt, d, sc) { ... },     // lt = seconds into scene, d = duration, sc.caps[i].t0 = start of VO line i
  cues(d, sc) { return [[0.5, 'pop', .4]]; }  // [localTime, sfxName, gain]
};
const TRANS = { 'a>b': 'flash' }; const TRANS_DEFAULT = 'slide'; const NO_CAPS = ['endcard'];
```

- Drawing must be a pure function of time (no state carried between frames) so frames can render in any order and in parallel workers.
- Sync to speech with `ct(sc, i, fallback)` = start time of VO line i. Always give a fallback so the same scene works in short cuts with fewer lines.
- Make timing scale with `d` for scenes reused in short cuts (`opt.fast`), e.g. `const k = d / 9`.
- Scenes may run slightly past `d` or start before 0 during transitions; `P()` clamps, so that is safe.
- Optional `onInit()` in scenes.js runs after fonts and timeline load (the starter uses it to register blocks).

## 4. Engine API (scripts/engine/engine.js)

| Group | Functions |
|---|---|
| Timing | `P(t, a, b, ease)` 0→1 progress; eases `eoc` (out), `eio` (in-out), `eob` (back/overshoot), `eel` (elastic), `lin`; `clamp`, `lerp`, `rnd(i)` deterministic random |
| Color | palette `C` (brand, violet, teal, amber, red, dark, card, card2, muted, dim, surface…), `hexA(hex, alpha)` |
| Shapes | `rr`, `fillRR(x,y,w,h,r,fill,stroke)`, `circle`, `glowDot(x,y,r,col,a)`, `arrow(x1,y1,x2,y2,col,lw,head,progress)`, `check(x,y,s,col,progress)`, `cross` |
| Text | `txt(s,x,y,size,{f,w,c,a,ls,alpha,glow})`, `tw()` measure, `wrap()` lines, `headline(lines,x,y,size,t0,lt,{a:'center'})` slide-up reveal, `sceneTag()` pill label, `chip(s,x,y,col,{icon,size,a})` |
| Transform | `withT(ctx,x,y,scale,rot,fn,alpha)` — use for every pop-in |
| Objects | `card(x,y,w,h,{fill,stroke})`, `phone(x,y,w,h,drawScreen(w,h))`, `person(x,y,scale,shirt,{left,right:'up'|'phone'|'point'|'hold', sad, long})`, `icon(name,x,y,size,col)` |
| Icons | game quiz ai msg trophy chart qr phone shop user users db heart gear rocket doc target coin scan shield live down up loop ticket board |
| Background | `bg(ctx,{blobs:[[col,alpha]...]})` animated gradient + dot grid + motes; `softLogo(ctx,x,y,w,a)` draws assets/logo.png |
| Fonts | `FD` = Poppins (display), `FB` = Inter (body) |

Bespoke helpers for one project (brand marks, HUDs) belong in that project's scenes.js, not the engine.

## 5. Layout grid and safe zones (1920×1080)

- Side margin 120 px. Headline y ≈ 170–220. Left text column x 120–760; illustration area x 820–1800.
- Captions occupy y ≈ 940–1050 (two lines). Keep anything important above y ≈ 900, or it sits under the subtitle.
- Small brand bug top-right at (W-170, 72).
- Minimum readable text: 18 px for labels on phone screens, 22 px elsewhere, 30+ px for anything the viewer must read.
- Cards that grow from the centre use `withT` + `eob` for a little overshoot; stagger lists by 0.12–0.3 s.

### Portrait and square (v1.2)
- `W`, `H` are set per cut (1920×1080, 1080×1920, 1080×1080); `VERT` is true in portrait.
- Centre with `W / 2`. Convert a y from the 1920×1080 design with `vy(y)` (portrait centres a bit higher and spreads 1.3×).
- `fitSize(ctx, lines, size, maxW)` shrinks a headline until it fits. Use it for any big text in portrait.
- Portrait safe zone: keep content above `H - 460` (captions sit there, the Shorts/Reels buttons and title cover the bottom ~440 px) and 60 px from the sides. The right edge also has like/comment buttons from about y 1100 down: keep key text centred.
- Lay rows out as columns in portrait (see starter `points` and `steps`).

## 6. Transitions

Window 0.6 s centred on the cut. Types: `slide` (push with teal edge, default), `fade`, `zoom` (scale through), `iris` (circle reveal), `wipe` (diagonal brand-colour bands), `flash` (white flash; use once, for the product reveal), `cut`.
Whooshes are added automatically for slide/zoom/wipe/iris; flash gets an impact.

## 7. Sound-effect names (scripts/audio.py)

whoosh, whoosh_big, swipe, send, spin, swirl · pop, tick, tickroll, click, type, blip, beep, drop, boing · coin, success, chime, shimmer, stamp · impact, boom, thud, flashhit, riser, crack, glitch, error, down, sonar.
Gain 0.3–0.5 for UI pops, 0.6–1.0 for hits. Put a `riser` 1.6 s before a big reveal.

## 8. Gotchas learned the hard way

- `ctx.filter` (grayscale/blur) costs about 2 s per frame in headless software canvas. Desaturate with a `globalCompositeOperation = 'saturation'` grey fill instead.
- Centered `headline()` must clip the full width; it does now, but any custom clip rect around centred text must start at x = 0.
- Light sweeps over a logo: draw the logo on an OffscreenCanvas, sweep with `source-atop` there, then draw it in. Sweeping on the main canvas paints a visible box.
- Text that sits on top of moving items collides; check every scene at 80% of its duration with `snap`.
- Counters/panels from a previous beat must fade out before new big text lands in the same place.
- The shell's network is allowlisted: GitHub and package registries work; most TTS/cloud APIs (edge-tts, gTTS, Hugging Face) are blocked. Kokoro (from GitHub releases) is the working voice.
- `fetch()` needs http, not file://; vidkit serves the stage folder itself, no separate server needed.
- Don't `rm -rf` build folders with globs from a script; write to fresh subfolders instead.
- Render speed ≈ 0.07 s/frame per worker; a 3-minute 30 fps master takes about 7 minutes with 2 workers.
