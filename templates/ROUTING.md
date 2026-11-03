# Routing: who does what

Claude (desktop app) reads this at the start of every task. It is the lead; the relay workers build.
Model names: `config/models.env`. Worker rules: `rules/AGENTS-floor.md`. Checks: `gates/`.

**Plan policy (October 29, 2026): free tiers first.**
- Paid: Claude Pro only (the lead). Its quota is the scarcest thing in the system.
- Free: Antigravity (Gemini), opencode with OpenCode Zen free models (GLM-5.3-Flash, DeepSeek V4.1 Flash),
  OpenRouter free models through PAL (optional).
- Every provider that can run is used, paid plan or not: Codex (any ChatGPT login, free included), DeepSeek and
  others sit in the fallback chains. One that isn't logged in, has no key or is out of quota fails in seconds,
  and the relay skips it for an hour. Never leave a provider out just because it's on a free tier.
- A plan or key added later: move that provider earlier in the chains in `config/models.env`.

**Mac/Linux:** shortcut names in these rules are the Windows `.bat` ones. On Mac/Linux the same number and name is
in `mac-linux/` or `mac-linux/shortcuts/` as a `.command` file, and a relay `dir:` is the normal path (`/Users/me/Work/My Game`).

**Relay first.** Before any work the workers could do: `relay/heartbeat` must be under a minute old. If not, stop,
ask the owner to open `windows\Start Hivemind.bat` (Mac/Linux: `mac-linux/Start Hivemind.command`), and wait.
Never quietly do worker jobs in Claude because the relay is off. Check again before each new batch of jobs.

## 1. Open every task with one line
`class · lead model · workers · expected result`
Example: `feature · Sonnet · opencode + review + gate build · level select screen in src/ui/levels.js`

## 2. Task classes

| Class | Examples | Builds | Automatic fallback | Review |
|---|---|---|---|---|
| plan | new game or big feature, economy, save format, architecture, unclear request | Claude Opus, owner approves | none, wait for Claude | owner |
| core | save/load, coins and economy, IAP and ads, netcode, shared engine | opencode free (GLM) drafts; Claude (Sonnet) reads every line and fixes. Claude writes it only after two failed drafts | opencode free2 | `review` worker + gate security when money, accounts or saves |
| feature | settled spec, a few files, easy to undo | opencode free (GLM) | free2 (DeepSeek) > Antigravity | `review` (Antigravity) + Claude skims `.last` and `.git` |
| mechanical | renames, level/data tables, configs, boilerplate, test cases, text strings | opencode free2 (DeepSeek) | free (GLM) > Antigravity | Claude spot-checks `.git` stat |
| read | big folders, docs, logs, "how does X work" | graph question first, then Antigravity | Antigravity hard > opencode free | none |
| second opinion | a bug still open after two tries | Antigravity hard (Gemini Pro) | opencode free | Claude |

Rules:
- Save Claude: other providers' quota is used first. Anything a free worker can do goes to a free worker.
  Claude plans, reviews `.last`, decides. Claude writes code itself only for: a tiny change (below), a core unit
  after two failed free drafts, or a fix that needs context only this chat already holds.
- Lowest Claude that does the job (the owner switches models; Claude names the right one in the opening line):
  Haiku: dispatching settled rows, reading STATUS/`.last`, ticking TASKS.md, small text edits.
  Sonnet: core review, debugging, writing job handoffs that need decisions. Opus: plan class only, then back down.
  Effort low for dispatch and status; high only for plan and a bug still open after two tries.
- Going lower never lowers the bar: the same "Done when", review and gates apply. Work that fails a check moves
  up one step (free model > Claude Sonnet > Opus), never ships as is.
- Start cheap, check, then move up. A unit that fails its check twice moves up one class
  (mechanical > feature > core > plan). Plan never goes to a free model.
- Review is cross-vendor: GLM or DeepSeek builds, so Antigravity (Gemini) reviews, and the other way round.
- Model switches in the desktop app are the owner's. Claude says "this needs Opus" and waits.
- Tiny change (one file, about 20 lines): Claude does it directly. A relay job costs more than it saves.
- Deleting files, uploads, phone installs, commits, Android builds: script workers (files, upload, install, git-commit,
  android), never a model. Free models stall on chores; an opencode job with no output and no file change for 6 min is stopped and falls back; a model that hit a limit or stalled in the last hour is skipped (config/models.env).

## 2b. Assets: best tool per type
| Asset | Use | Notes |
|---|---|---|
| Sprites, icons, backgrounds, store art | ComfyUI FLUX schnell (`comfy` worker); prompts and specs from the `game-asset-designer` skill | Free, local GPU. Sizes: `scripts/check-store-assets.py` |
| Video clips, B-roll | ComfyUI Wan 2.2 5B (`comfy`) | Free |
| Hooks and hero shots | Google Flow, Veo 3.1 Fast (owner runs it) | Credits: Quality (100) only with the owner's OK |
| Motion graphics, captions, explainers | `motion-video-producer` skill (`video` worker) | Free |
| Music, jingles | ACE-Step (`15 Start Music Studio`) | Free |
| Voiceover | Chatterbox clone (`16 Clone Voice`) | Free, owner's own voice |
| UI screens, mockups, layout | Claude (design or HTML): where Claude is clearly better | Keep it to the screen asked for |
| Store and ASO text, short copy | Claude Haiku/Sonnet with the `ua-aso-manager` skill | Short, quality matters |
| Anything else | Free local tool first; a paid generator only when free can't reach the quality and the owner OKs the cost | |

## 3. The loop
1. Plan (Opus): PLAN.md and TASKS.md, one row per unit with its class and "Done when". Owner approves.
2. Dispatch (Sonnet): one relay job per row (format below). Up to 2 jobs run at once, in different
   project folders. Jobs for the same folder wait their turn.
3. Build: the workers.
4. Review: a `review` job (cross-vendor engine, set in config/models.env).
5. Gates: `build` when a row is done; `security` when it touches money, coins, IAP, ads rewards,
   accounts, saves or network; `release` before anything public.
6. Commit: a `git-commit` job after review and gates pass. Workers never commit.
7. Update TASKS.md: status, gate result, Handoff. Back to Opus only if the plan has to change.

## 4. Relay jobs
Write `relay/inbox/<id>.job`. The body is a handoff: decisions only, not reasons, and nothing the worker
already has from its rules or the project's AGENTS.md. Longer than about 10 lines? Put it in PLAN.md
and point to the section.
```
worker: opencode
dir: /mnt/d/Work/My Game
model: free
---
Task: <one line: what done looks like>
Scope: in: <...>  out: <...>
Start from: <files, function, or PLAN.md section>
Done when: <checks a gate can run>
Constraints: <project extras only; usually none>
```

| worker | Extra header | Notes |
|---|---|---|
| opencode | model: free (GLM) / free2 (DeepSeek) / a model id | Main builder. Free models through OpenCode Zen |
| agy | model: hard (optional) | Antigravity (Gemini): reading, second opinions, reviews |
| review | base: main, or commit: <sha> (optional) | Reviews uncommitted changes with `gates/review.md`. Engines: REVIEW_ENGINES |
| gate | gate: build / security / release | Runs `gates/<gate>.md`. Engines: GATE_ENGINES |
| graph | none | Body "update" builds or refreshes graphify-out/; any other text is a question to the graph |
| git-commit | none | Body = one-line message; commits all changes in that repo |
| android, files, upload, install, comfy, video | none | Scripts, no model: APK builds, deletes, uploads, phone installs, AI shots, video renders. Body formats: `templates/routing/workers.md` |
| codex, codex-review, deepseek | effort (codex) | Codex: any ChatGPT login. DeepSeek: API key. In the fallback chains; skipped automatically when not usable |

**Automatic fallback.** If a worker fails because of a rate limit, quota, login or a missing tool, the relay
tries the next one in its chain by itself (chains in `config/models.env`, or a `fallback:` header in the job;
`fallback: none` turns it off). Real failures, like a broken build, are reported, not retried.
`.last` ends with `worker used: ...` so Claude knows who did the work.

## 5. Reading results (this is where tokens go)
- Waiting: read `relay/STATUS.md` (one line per job: RUNNING, or DONE with exit and worker used).
  Builds take minutes: check about every 2 minutes, and send independent jobs together so one check covers them.
- Read `.last` first (the worker's short final message), then `.git` (status and diff stat).
- Read `.diff` only when reviewing yourself. Read `.out` only when something failed.
- Never paste a whole `.out` or `.diff` into the chat.

## 6. Saving tokens
- Usage left: read `USAGE.md` "At a glance" (made by `scripts/usage.py`, refreshed after every relay job) before
  a batch of jobs. Skip a worker marked LIMIT HIT or OUT and use its fallback. Claude LOW: say so in one line and
  lean harder on free workers. Claude and Antigravity % are live (cached 5 min). Limits: `config/limits.env`.
- New chat per task. Long chats cost far more.
- Before exploring code: read `graphify-out/GRAPH_REPORT.md`, or send a `graph` question. Run a
  `graph` "update" job after big changes.
- Keep CLAUDE.md and AGENTS.md short (aim under 4k tokens each).
- TASKS.md holds current work only. Move finished rows to DONE.md when the board passes about 15 rows.
- Split any spec over about 15k tokens into parts, and point jobs at the part they need.
- Don't re-read what a worker already summarised. Don't re-read a file after editing it.
- One heavy job (build, render, headless browser test) on the machine at a time.

## 7. When Claude runs out
Drag the project onto `windows\shortcuts\2 Continue Handoff - opencode.bat`: a free model does the next step from
the TASKS.md Handoff. Repeat per step, or wait for the Claude reset. Antigravity can also be opened
directly for reading and planning help.

## 8. What may go where
| Material | Allowed |
|---|---|
| Our own games and code | every worker |
| Company work (your company / Your Studio, no client NDA) | Claude, Antigravity (work Google account), opencode GLM and DeepSeek free (zero data retention) |
| Client or NDA work | Claude and Antigravity. opencode GLM/DeepSeek free only if the owner OKs it. Never OpenRouter free or Zen models that train on data (Big Pickle, Flint, MiMo, Nemotron) |
| A contract that bans AI tools | nothing: no AI on it at all, not even anonymised |
| API keys, passwords, player or customer personal data | never in a prompt, file or log |

## 9b. Videos and content series
Any video, channel, Shorts or content-series request: read `stacks/video.md` (tools, project layout, loop,
monetization rules) and use the `motion-video-producer` skill. Renders and AI shots go to the `video` and
`comfy` workers, never to a model.

## 9a. Game projects: intake first
Before planning any game work, read the project's `project.yaml`. Missing? Ask the intake questions from
`stacks/README.md` in one message (start, engine, targets, Android store, own or publisher SDKs, web portal, tier), suggest an answer for each,
and write the file (template: `templates/project.yaml`), or tell the owner to run `windows\shortcuts\8 New Project.bat`.
Then follow the playbook it names: `stacks/web.md` or `stacks/unity.md`. A project's engine is decided once;
switching engines is a plan-class decision for Opus and the owner.

## 9. Read only when the task needs it
| Task | File |
|---|---|
| Android APK or Play release | `templates/routing/android.md` |
| Security fixes, reverse engineering (REA) | `templates/routing/security.md` |
| Autopilot steps | `templates/routing/autopilot.md` |
| Sending a script worker job (android, files, upload, install, comfy, video) | `templates/routing/workers.md` |
| Videos, Shorts, content | `stacks/video.md` (section 9b) |
