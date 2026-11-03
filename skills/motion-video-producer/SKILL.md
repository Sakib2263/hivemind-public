---
name: motion-video-producer
description: Plan, script and produce finished 2D motion-graphics videos (explainers, product promos, pitch and training videos, social cutdowns) as real MP4 files with animation, transitions, AI voiceover, music, sound effects and subtitles. Use whenever the user asks for a video script, storyboard, explainer or promo video, motion animation, an animated version of a pitch or product story, or 60s/30s/15s social cuts, even if they only say "make a video about X" or "turn this deck into a video". Also use to revise, re-voice or re-cut a video made earlier with this skill, and to check or upgrade the video toolchain.
---

# Motion Video Producer

Turns a brief into a script MD and then into rendered MP4 videos at 30 fps: 16:9 (1920×1080), 9:16 Shorts/Reels (1080×1920) or 1:1 (1080×1080), chosen per cut. Every frame is drawn by code in headless Chromium, so the output is deterministic, editable and re-renderable after each round of feedback.

**Paths.** `<skill>` is this skill's folder (the base directory shown when it loads). Never edit files inside `<skill>`. Work in a project folder in the working directory. To improve the skill itself, copy it somewhere writable first (see Step 8).

## The pipeline at a glance

```
brief ─► script MD (Gate 1) ─► cuts.json + scenes.js ─► vo ─► snap stills (Gate 2)
      ─► audio + render (background) ─► verify (Gate 3) ─► deliver MP4s ─► log lessons
```

The main command is `python3 <skill>/scripts/vidkit.py <command>`; run it with `-h` for usage.

## Step 0 — Health check (every session)

Run `vidkit.py doctor` before anything else. It installs missing Python modules and downloads the voice model and fonts. Read its last line:

- If it says "all good", carry on.
- If problems are listed, decide whether you can work around them. For example, if the voice model is unavailable, set `voice: "none"` and deliver a captions-only video, and tell the user.

Network note: only GitHub and the package registries are reachable from the shell. Cloud TTS services are blocked, which is why the skill uses Kokoro (an offline voice model).

## Step 1 — Brief and context

Pull the facts before you write anything:

- **Context skills:** if the work is for a company or client that has a context skill, load it first.
- **Project docs:** check them for product facts, real contact details, logos, colours and tone.
- **Missing information:** ask at most one short question, and only if it would change the video. Typical examples are the audience, the length, or the language of the voiceover. Otherwise pick sensible defaults:
  - a 2:30–3:00 master
  - 60s, 30s and 15s cuts
  - English VO with a warm female voice
  - the brand's own colours

## Step 2 — Script (Gate 1)

Write the script as an MD file using `references/script-template.md`, which also holds the writing rules and cutdown recipes.

1. **Deliver the MD.** The user likes to refine drafts, so send it and wait for their edits before building. The exception is when they asked for the video in the same breath; then carry on.
2. **Independent review.** For client-facing or long videos, have the `video-qa-reviewer` agent check the script (`agents/video-qa-reviewer.md`, gate `script`). Spawn it with the Agent tool when that tool exists; otherwise self-review against `references/qa-checklist.md`.

## Step 3 — Build the project

1. **Create the project folder.** Run `vidkit.py new <project> --from starter`. That starts from data-driven blocks: intro, title, points, steps, stat and endcard.
2. **Read `references/scene-cookbook.md`.** It covers the engine API, layout safe zones, transitions, sound-effect names and known gotchas.
3. **Fill in `cuts.json` from the script.**
   - Each VO sentence goes in its own string in `lines`, so animations and captions can sync to it.
   - Write a separate scene list for each cut.
   - Add `pronounce` entries for acronyms and brand names.
4. **Write `scenes.js`.**
   - Reuse starter blocks through `type` and options wherever they fit.
   - Write bespoke scenes where the story needs a real illustration.
   - Sync animations to the VO with `ct(sc, i, fallback)`.
5. **Add the logo.** Run `vidkit.py logo <src> <project>/assets/logo.png`, which turns a logo on a black or white background into a transparent one with white text. Never draw a placeholder logo in place of a real one. If the product has no logo, design a simple mark in scenes.js and say so at the end.

## Step 4 — Voice and stills (Gate 2)

1. **Generate the voiceover.** Run `vidkit.py vo <project>`. It voices each sentence once (cached) and prints each cut's length. If a cut is far from its target, adjust the lines or `tail`/`min` now.
2. **Render stills.** Run `vidkit.py snap <project> <cut>` for every cut. By default it renders one frame per scene at 80% of the scene. Add `--at 0.3` to check entrances, or pass times to check transitions.
3. **Look at every contact sheet with Read.** Fix overlaps, clipping, text under the caption zone and JS errors, then re-snap. This loop is where the quality comes from; expect two or three passes.
4. **Independent review.** For client work, run the reviewer agent on gate `stills` as well.

## Step 5 — Audio and render

Run these in the background (Bash `run_in_background`) and wait for the notification:

```
vidkit.py audio <project>                    # VO + generated music + SFX, music ducks under the voice
vidkit.py render <project> --workers 2       # frames → H.264, then mux audio at −14 LUFS
```

Timing: a 3-minute master takes about 7 minutes with 2 workers.

For changes later:
- Re-run only the cuts that changed: `render <project> 60s`.
- After a script change, re-run `vo` first. Clips are cached, so only changed lines get voiced again.

## Step 6 — Verify (Gate 3)

1. Run `vidkit.py verify <project>`. Every file must say `OK`, with video and audio streams, and loudness near −14 LUFS.
2. Open each `*_check.jpg` with Read.

You cannot hear the audio. Never claim the voice or music "sounds great"; ask the user to listen.

## Step 7 — Deliver

1. **Send the files.** Send the MP4s from `<project>/build/out/` with SendUserFile in one call.
2. **Write a short reply.** Cover:
   - what's in it: the structure, transitions, and audio approach
   - each cut's length
   - anything invented that needs confirming: example brands, numbers, a designed logo
   - what to check by ear
   - the offer of a recorded human voice or local-language version
3. **Keep the reply brief and plain.** No long recaps.

## Step 8 — Maintain and upgrade the skill

After each job, open `references/upgrade-log.md` and follow it:

1. **Log the job.** Add a dated entry covering what broke, what you fixed, and the lessons learned.
2. **Promote durable lessons.** Gotchas go into `scene-cookbook.md`; writing rules go into `script-template.md`.
3. **Upgrade the skill when a lesson repeats.** Triggers: the same lesson in two jobs, the same bespoke scene rebuilt twice, or a new format asked for twice.
   - Copy `<skill>` to a writable folder and apply the change there.
   - Re-test with `new`, `vo`, `snap` and one short-cut `render` + `verify`.
   - Bump the version in the log.
   - Package with skill-creator's `package_skill.py` and send the `.skill` file so the user can save it over the old one.
4. **Ask before shipping.** Never ship a skill upgrade without telling the user what changed.

## Voice, music and AI shots (v1.1)

- **Cloned or recorded voice:** set `"voice": "files"` in `cuts.json` config. `vo` writes every unique line to
  `build/voice/lines.txt` and stops (exit 3) until `build/voice/vo/001.wav ...` exist. Make them with
  Chatterbox (`windows\shortcuts\16 Clone Voice.bat` on `build/voice`, with `voice.wav` there or in `assets/`)
  or a real recording, one file per line. Then run `vo` again. Only clone a voice with written consent.
- **Real music file:** `"music": {"file": "assets/track.mp3", "level": 0.36, "end_scene": "endcard"}`.
  Looped or trimmed to length, faded in, faded out at `end_scene`, ducked under the voice. Use ACE-Step
  output (`windows\shortcuts\15 Start Music Studio.bat`) or licensed music only.
- **AI clips and stills:** `shots.json` in the project, run by the relay `comfy` worker (Wan 2.2 5B video,
  FLUX schnell images, on the Windows GPU). Results land in `build/ai/`. Format and prompts:
  `<hivemind>/stacks/video.md`. Showing clips inside scenes is planned (VIDEO-PLAN V2).
- **Hivemind relay:** `video` worker runs this pipeline (`build`, `vo`, `audio`, `render`, `verify`, `snap`).

## Agents

- `agents/video-qa-reviewer.md` — an independent reviewer for the script, stills and final gates. It reports MUST / SHOULD / NICE fixes and never edits.
- `agents/video-producer.md` — runs a whole job unattended: this workflow plus reviewer calls, ending with a report and an upgrade-log entry. Use it when the user wants the video made in the background or several videos at once.

To spawn either agent, pass the agent file's text as the prompt, plus the project path, the script path and the gate.

## Defaults and conventions

- **Deliverables:** a script MD first, then MP4s named from `config.names`. Size per cut: `config.aspect` (default "16:9") and `config.aspects` for overrides, e.g. `{"short": "9:16"}`. Starter blocks adapt to all three sizes; bespoke scenes must use `W`, `H` and `vy()` instead of fixed numbers (see the cookbook).
- **Header lines:** script MD headers carry only title, version, date and status.
- **Captions:** burned-in subtitles stay on by default (`captions: true`), because social video autoplays muted. Turn them off for the end card through `NO_CAPS`.
- **Transitions:** `flash` is used once, at the product reveal; the default is `slide`. Use `wipe` and `iris` to separate acts.
- **Music:** soft and tense before `music.drop_scene`, upbeat after, resolving at `end_scene`.
- **Facts and contact details:** pull them from project files or the user. Label example numbers on screen as "Illustrative".
