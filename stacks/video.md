# Video stack: content videos (social, explainer, educational, documentary)

Read this for any request to make videos, a channel, shorts or a content series.
Skill: `skills/motion-video-producer` (script, scenes, voice, music, render). This file says which tool
does which part, on this PC, for free.

## The PC (desktop, November 2026)
Ryzen 5 5600G, 32 GB RAM, RTX 3060 12 GB, Windows 11. 12 GB VRAM: Wan 2.2 5B video, FLUX schnell
images, ACE-Step music, Chatterbox voice all fit. Run one GPU job at a time.

## Who makes what
| Part | Tool (free) | Where it runs | How Claude starts it |
|---|---|---|---|
| Script | Claude writes, owner edits (Gate 1) | chat | `references/script-template.md` |
| Motion graphics, text, charts, diagrams, UI, maps | motion-video-producer engine (canvas, headless Chromium) | WSL, CPU | relay `video` job |
| English voice, fast | Kokoro (built into the skill) | WSL, CPU | `voice: "af_heart"` etc. in cuts.json |
| Own voice, cloned | Chatterbox (MIT) | Windows GPU | `voice: "files"`, then `shortcuts\16 Clone Voice.bat` on `build\voice` |
| Recorded human voice | owner records | - | `voice: "files"`, put `001.wav ...` in `build\voice\vo\` |
| AI video clips (b-roll, hero shots) | Wan 2.2 TI2V 5B (Apache 2.0) in ComfyUI | Windows GPU | `shots.json` + relay `comfy` job |
| Stills (backgrounds, start frames, thumbnails) | FLUX.1 schnell fp8 (Apache 2.0) in ComfyUI | Windows GPU | `kind: "image"` in shots.json |
| Animate a still | Wan 2.2 5B image-to-video | Windows GPU | `kind: "i2v", image: "@<image shot id>"` |
| Music | ACE-Step 1.5 (MIT) or the skill's generated track | Windows GPU / WSL | ACE-Step: `shortcuts\15 Start Music Studio.bat`, save into `assets\`, set `music.file` |
| Sound effects | the skill's 30 built-in SFX | WSL | scene cues |
| Captions | burned in by the skill | WSL | on by default |
| Final edit, if needed | DaVinci Resolve or CapCut (owner) | Windows | - |

Paid, only when local can't do it: one hero shot from Kling or Veo (pay per clip), ElevenLabs voice.
Never Higgsfield-style subscriptions with credits.

## Setup (once)
1. `9 Optional - Video Studio.bat`: setup window, pick the install folder (outside hivemind, saved in
   `config\studio.env`) and the parts (video, images, music, voice).
2. After it: `wsl --shutdown` in a Windows terminal, then `shortcuts\1 Start Relay.bat` again (the relay
   reaches ComfyUI on localhost through mirrored networking).
3. Each video day: `shortcuts\14 Start Video Studio.bat` and leave it open.
4. Test: `python3 <hivemind>/scripts/comfy.py ping` from WSL shows the 3060.

## A content project
```
<work folder>/Content/<series>/<episode>/
  script.md        Gate 1 (owner edits)
  cuts.json        lines + scenes per cut       (from vidkit new <episode> --from starter)
  scenes.js        scene drawing code
  shots.json       AI stills and clips (optional)
  assets/          logo, voice.wav, music, screenshots, real footage
  build/ai/        ComfyUI results  (comfy worker)
  build/out/       finished MP4s    (video worker)
```
shots.json:
```json
{"defaults": {"aspect": "16:9"},
 "shots": [
  {"id": "city", "kind": "image", "prompt": "Dhaka street at dusk, rickshaws, cinematic, 35mm"},
  {"id": "city_move", "kind": "i2v", "image": "@city", "prompt": "slow push-in, light traffic moving"},
  {"id": "gears", "kind": "video", "prompt": "macro shot of brass gears turning, soft studio light", "frames": 73}
 ]}
```
Sizes: 16:9 = 1280x704 video / 1344x768 image; 9:16 and 1:1 also. 73 frames = 3 s at 24 fps.
Write prompts like a camera brief: subject, action, camera move, light, lens. Wan is silent: sound
comes from the voice, music and SFX.

## The loop (per episode)
1. Claude: script.md, owner approves.
2. Worker (opencode free, `feature` class): cuts.json + scenes.js from the script and starter blocks; shots.json.
3. Relay `comfy` (body: `shots.json`): clips and stills into `build/ai/`. Claude looks at the stills.
4. Relay `video` (body: `vo`, then `snap <cut>`): Claude checks contact sheets (Gate 2).
5. Relay `video` (body: `build`): audio + render + verify. Owner listens (Gate 3).
6. Owner uploads. Claude writes title, description, tags, chapters (ua-aso-manager for wording).
Batches: one job per episode; GPU jobs queue in ComfyUI by themselves.

## Speed on the 3060 (fill in after the first real runs)
| Job | Settings | Time |
|---|---|---|
| FLUX schnell still | 1344x768, 4 steps | measure |
| Wan 2.2 5B clip | 1280x704, 73 frames, 20 steps | measure |
| Wan 2.2 5B draft | 832x480 (`w`/`h`), 49 frames, 12 steps | measure |
| Motion-graphics render | 60 s cut, 2 workers | measure |
Draft first (small, few steps), keep the seed from `build/ai/<id>.json`, then redo the winners full size.

## Monetization rules (YouTube, Facebook, TikTok)
- YouTube does not pay for "inauthentic" content: mass-produced or repetitive videos, AI personas on
  sensitive topics, distressing clickbait. It judges the whole channel, not one video.
- So every episode carries a real angle: the owner's knowledge, real data, real footage or screen
  recordings, an opinion. Change the template between episodes. Never reuse the same AI clips.
- Turn on the "altered or synthetic content" label when realistic AI footage shows real-looking people
  or events.
- Voice: a cloned voice only from the owner or someone who agreed in writing. No voices of real public figures.
- Music: ACE-Step, the skill's own track, or a licensed file. No copyrighted songs.
- Licences: Wan 2.2, FLUX schnell (Apache 2.0), ACE-Step, Chatterbox, Kokoro (MIT/Apache) allow commercial
  use. Not allowed for monetized work: XTTS v2 and Bangla XTTS fine-tunes (Coqui non-commercial licence),
  MMS-TTS (CC BY-NC). FLUX.1 dev has a non-commercial model licence: we use schnell to keep it simple.

## Open items: `..\Local Gen Lab\TASKS.md` (tooling), `..\Content Studio\TASKS.md` (content)
