# Upgrade Log and Self-Maintenance

## How the skill keeps itself healthy

1. **Every session, before work:** run `python3 scripts/vidkit.py doctor`. It checks ffmpeg, the Python modules, headless Chromium, the Kokoro voice model and the fonts, and installs or downloads anything missing. If something can't be fixed, it says what still works (for example captions-only video when the voice model can't be downloaded).
2. **During a job:** when a tool fails or a workaround is needed, fix the script in your working copy of the skill, note it below, and keep going.
3. **After every job:** add an entry below (date, project, what broke, what changed, new lessons). Move durable lessons into `scene-cookbook.md` (gotchas) or `script-template.md` (writing rules).
4. **Shipping an upgrade:** the installed skill folder is read-only. Copy the skill to a writable folder, apply changes, bump the version here, and repackage with skill-creator's `package_skill.py`. Give the user the new `.skill` file to save over the old one. Keep the name `motion-video-producer`.
5. **When to upgrade (triggers):** a gotcha repeated in two projects; a scene block rebuilt from scratch twice (promote it to the starter blocks); a new deliverable format requested twice (for example 9:16); doctor reporting a new failure.

## Ideas backlog (not built yet)

- 9:16 and 1:1 render modes (canvas size + safe-zone re-layout per scene).
- Bangla voiceover: Kokoro has no Bangla voice; needs another offline TTS or a human recording dropped into `build/vo/`.
- Option to use a supplied VO recording plus a timing file instead of TTS.
- Licensed music file option (`music.file`) instead of the generated track.
- Character variety (more poses, skin and hair options) in `person()`.

## Versions

### 1.2 — 2026-11-02 — 9:16 and 1:1
- `config.aspect` + `config.aspects` (per cut); timeline carries w/h; engine `W`/`H` are set per cut; viewport, canvas, captions, iris transition and contact sheets follow the size.
- Starter blocks rewritten for any size: centred with `W / 2` and `vy()`, headlines auto-fit, `points` and `steps` stack vertically in portrait, captions bigger and above the Shorts UI in portrait.
- Tested: starter master snapped at 16:9, 9:16, 1:1 (no clipping after two fixes: portrait centre moved up, step spacing scales with width); 15 s 9:16 cut rendered, verify OK (1080×1920, −14.9 LUFS).

### 1.1 — 2026-11-02 — own voice, real music, AI shots
- `voice: "files"`: cloned (Chatterbox) or recorded lines from `build/voice/vo/NNN.wav`; `vo` exports `build/voice/lines.txt`.
- `music.file`: real track (ACE-Step or licensed) instead of the generated one, with fades and ducking.
- Hivemind: `comfy` relay worker + `scripts/comfy.py` for Wan 2.2 5B / FLUX schnell shots, `video` worker for vidkit.
- Tested: vo with files (missing-line stop, then timeline), music_file loop/fade, comfy.py batch against a fake ComfyUI.
- Backlog moved to `<hivemind>/plans/VIDEO-PLAN.md` (9:16, clip and image blocks, series runner, Bangla voice).

### 1.0 — 2026-10-19 — first release
Built from a product explainer job: a 3:05 master plus 60s, 30s and 15s cuts, all 16:9.
- Pipeline: Kokoro TTS per sentence → timeline → canvas scenes in headless Chromium → JPEG frames → x264, plus a numpy soundtrack (generated music with ducking + 30 synthesized SFX) → loudnorm −14 LUFS mux.
- Fixed during the job: slow `ctx.filter` grayscale (2 s/frame → 0.07 s); centred headline clipping; logo sweep box; overlap of problem statements with counters; phone/orbit collisions with captions; music 3–4 dB too loud under VO (now level 0.36 with ducking).
- Network notes: edge-tts, gTTS and Hugging Face are blocked; GitHub release downloads work.
