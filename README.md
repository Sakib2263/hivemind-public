# Hivemind: one lead AI, a team of models, on Windows (formerly ai-setup-kit)

**New here? Start with [SETUP.md](SETUP.md).** Everyday use and every file: GUIDE.md.

**New here? Start with [GUIDE.md](GUIDE.md):** which file does what, and what to use after what.

Claude (desktop app) is the lead agent. Free models do the building: GLM and DeepSeek through opencode,
and Gemini through Antigravity. Codex (ChatGPT) can join later as a paid worker.
This kit installs everything and gives you double-click shortcuts. Works on any Windows 10/11 PC.

## What you need
| Need | Why |
|---|---|
| Windows 10 or 11, 8 GB RAM, about 10 GB free disk | Ubuntu + tools |
| Claude desktop app, Claude Pro or Max | Lead agent (the only paid plan needed) |
| Google account | Antigravity worker (free tier works) |
| Free opencode.ai account + its API key | Main builders: GLM-5.3-Flash and DeepSeek V4.1 Flash free models |
| OpenRouter key (optional, free) | Extra free models through PAL |
| ChatGPT Plus or Pro (optional, later) | Codex worker |

## Where to put this kit
Put the **Hivemind** folder inside your main work folder, for example `D:\Work\Hivemind`.
Your projects go next to it (`D:\Work\My Game`), never inside it. Projects elsewhere: list their parent folder in
`config\folders.env` (New Project does this for you). The relay works only in those folders. Which folders to
add in Claude: see GUIDE.md, "Where projects live".

## One-time setup (about 30-40 minutes)
Run these in order. Each window tells you the next step.

| # | Double-click | What happens | You do |
|---|---|---|---|
| 1 | `1 Install WSL (run once).bat` | Installs WSL2 + Ubuntu (asks for admin) | Restart PC, open "Ubuntu" from Start, create a lowercase username + password |
| 0 | `0 Optional - Move Ubuntu to another drive.bat` | Moves Ubuntu off C: | Only if C: has under 15 GB free |
| 2 | `2 Install AI Tools.bat` | Installs Claude Code, Antigravity, opencode, graphify, PAL, Codex (optional), the shared worker rules and skills (10-20 min) | Type your Ubuntu password at the start |
| 3 | `3 Log In.bat` | Logs in to Claude, Antigravity, opencode, then Codex (optional) one by one | Copy each link into your browser and approve. For opencode: make a free account at opencode.ai, copy its API key, pick "OpenCode Zen" and paste it. Type s to skip Codex |
| 4 | `4 Add API Keys.bat` | Opens `secrets\keys.env` in Notepad, then connects PAL | Optional: paste a free OpenRouter key, save, close Notepad |
| 5 | `5 Check Everything.bat` | Tests every tool; both free models and Antigravity reply "OK" | Read the result; send `logs\verify.log` to Claude if something fails |
| 6 | `6 Optional - Android Build Tools.bat` | Installs Java 21, the Android SDK and adb (1-2 GB) | Only if you build Android apps |
| 7 | `7 Connect Claude.bat` | Writes your Claude Project instructions with your folders filled in, copies them, opens them | Paste into a Claude Project's instructions (Projects > New project > Instructions) |
| 8 | `8 Optional - Reverse Engineering (REA).bat` | Adds REA (reverse engineering, github.com/morluto/rea) to the Claude app and the workers | Only if you analyse builds you own or may analyse |

Then run `7 Connect Claude.bat` and paste what it copies into a Claude Project's instructions.
Daily use and example prompts: GUIDE.md, "Starting a chat".

## Daily use
New chat per task > "+" > "Add folder" (work folder) > `shortcuts\1 Start Relay.bat` > type the task.
Claude reads the Hivemind rules itself (Project instructions). Details and examples: GUIDE.md.

## Shortcuts (`shortcuts` folder)
Folder shortcuts: drag a project folder onto the .bat, or double-click and paste the path.

| File | What it does |
|---|---|
| 1 Start Relay.bat | Lets Claude send jobs to the workers. Leave open while working |
| 2 Continue Handoff - opencode.bat | Claude out of quota? A free model does the next step from the TASKS.md Handoff |
| 2 Codex - Continue Handoff.bat | Same, with Codex (only with a ChatGPT plan) |
| 3 Codex - Open.bat | Opens Codex in a project (only with a ChatGPT plan) |
| 4 Claude Code - Open.bat | Opens Claude Code (Sonnet) in a project |
| 5 Antigravity - Open.bat | Opens Antigravity in a project |
| 6 Check All Tools.bat | Same check as setup step 5 |
| 7 Fix PAL.bat | Fixes PAL if it stops connecting after an update |
| 8 New Project.bat | Starts a game project the right way: new, existing or reskin (copies a base game; can rename the folder). No game name asked: the title is decided before release, with ASO, engine (web or Unity), targets (Android, iOS, web), Android store or test APK, own or publisher SDKs, web portals, size. Writes `project.yaml`, which every later step reads, plus the project files, a .gitignore for the engine, and git |
| 10 Build Android App.bat | Drag a project on it: asks for app name, bundle id and icon if missing, confirms, then builds a test APK or a signed Play release (AAB + APK) into `builds\android\` |
| 11 Install APK on Phone.bat | Drag an APK on it: installs it on a phone plugged in by USB (USB debugging on) |
| 12 Add My Skills.bat | Brings in your own skills: drop skill folders or .skill / .zip files into `skills\inbox\`; they are checked, listed (private by default) and installed |
| 13 Export Public Version.bat | Owner only: makes a clean public copy (`..\hivemind-public`) without keys, personal skills, plans or company details |
| 19 Usage.bat | Full usage report: live Claude and Antigravity %, tokens and jobs per provider and model (today, 5-hour window, week, month), what's left, reset times |
| 20 Usage Overlay.bat | Small always-on-top window with usage left per provider, live. Right-click: Refresh, Start with Windows, Close |
| 9 Pack Skills.bat | Zips each skill into `skills-packages\` for uploading to claude.ai or sharing (shareable / company / private folders) |

Tip: right-click a shortcut > Send to > Desktop (create shortcut).

## Keep two PCs in sync (private GitHub repo)
The kit lives in a private repo. Needs Git for Windows (git-scm.com) on each PC; the first sync opens a GitHub sign-in in your browser.

| When | Double-click |
|---|---|
| New PC, or before you start working | `Sync - Pull.bat` (the first time it links the folder to GitHub) |
| After you changed something in the kit | `Sync - Push.bat`, then `Sync - Pull.bat` on the other PC |

New PC from scratch: create your work folder, download the repo into `<work folder>\Hivemind` (or copy this folder there), run `Sync - Pull.bat`, then setup steps 1-5.
Your keys (`secrets\keys.env`), logs and relay jobs never go to GitHub.

## How the team works
1. **Plan:** Claude Opus writes PLAN.md and TASKS.md, one row per unit with a task class. You approve.
2. **Build:** Claude sends each unit to the right worker through the relay (opencode GLM / DeepSeek, Antigravity).
3. **Review:** another vendor reviews the work (Gemini reviews GLM's and DeepSeek's work; Claude checks the result).
4. **Gates:** build, security and release checks, run by name (`gates\`).
5. **Commit:** a `git-commit` job after review and gates pass. Workers never commit.
6. **Out of Claude quota:** drag the project onto `2 Continue Handoff - opencode.bat`.

Who does what, and how to save tokens: `templates\ROUTING.md`.

## What is in the kit
| Folder | What |
|---|---|
| `stacks\` | Which engine to use (README.md) and a playbook per stack: setup, SDKs, dev loop, QA, builds (`web.md`, `unity.md`) |
| `templates\` | ROUTING.md (the lead's rules) and the project files CLAUDE.md, AGENTS.md, PLAN.md, TASKS.md |
| `rules\AGENTS-floor.md` | Rules every worker loads. Installed into opencode, Claude Code and Codex by `scripts\install-rules.sh` (runs on setup and on every Sync - Pull) |
| `gates\` | The build, security and release checks, and the review checklist |
| `skills\` | Local copies of your skills, with `index.yaml` (what each one is for, who may see it). Worker skills install into Codex and opencode automatically. See `skills\README.md` |
| `templates\android.env` | App facts for Android builds (name, bundle id, icon, version). Copied into each project |
| `secrets\android\` | `signing.env` (keystore, alias, password, bundle start) and the keystore that signs every app. Asked for on the first release build. Never goes to GitHub: back both up yourself. Example: `templates\signing.env.example` |
| `config\models.env` | Which model each worker uses, with the date it was decided. Edit here when a model is renamed |
| `relay\` | Job inbox and results |
| `secrets\keys.env` | Your keys. Never goes to GitHub |

## The relay: how jobs reach the models
Claude writes a job file to `relay\inbox\<id>.job`; the relay (`shortcuts\1 Start Relay.bat`) runs it with the
worker the job names and puts the results in `relay\outbox\`. It is not Codex-only: it runs every worker below.
```
worker: opencode         (opencode, agy, review, gate, graph, git-commit, android; codex and deepseek when paid)
dir: /mnt/d/Work/My Game (WSL form of a folder inside the work folder)
model: free              (opencode: free = GLM, free2 = DeepSeek. agy: hard = Gemini Pro)
gate: build              (gate only: build, security, release)
fallback: none           (optional: turn off automatic fallback, or give your own chain)
---
<handoff: Task / Scope / Start from / Done when>
```
- **Automatic fallback:** if a model hits a limit or quota, isn't logged in, or isn't installed, the relay
  tries the next one by itself (for example GLM > DeepSeek > Gemini). Real errors are reported, not retried.
  Chains live in `config\models.env`.
- **Who picks the worker:** Claude, using `templates\ROUTING.md`. The relay only switches on failures.
- **Results:** `.done` (exit code) > `.last` (short answer + "worker used", read this first) > `.git`
  (status, diff stat) > `.diff` > `.out` (full log, only on failure).
- **Limits:** only folders inside the work folder, 45 min per job, up to 2 jobs at once, never two in the same folder.

## Free models (opencode)
Step 3 logs opencode in to OpenCode Zen with your free account key. The two free models are already set in
`config\models.env`: GLM-5.3-Flash (main builder) and DeepSeek V4.1 Flash (second builder, mechanical work).
Both keep no data and don't train on it. Free periods end: if `5 Check Everything.bat` shows one failing, run
`opencode models opencode` in Ubuntu, pick a new id ending in `-free`, and paste it into `config\models.env`.
Avoid Big Pickle, Flint, MiMo and Nemotron free models for real work: they keep or train on data.
Later, with paid plans: a ChatGPT plan turns Codex on (see ROUTING.md), GitHub Copilot or a Google AI Studio key
fill the `copilot` / `gemini` lines. Don't log ChatGPT or Claude into opencode itself.

## Rules worth keeping
- Your Claude subscription login is only used in Claude Code and the Claude app. Never paste it into other tools.
- Client or NDA work: Claude and Antigravity only, unless you OK the zero-retention GLM/DeepSeek free models. Never OpenRouter free models.
- Never paste API keys into chat. Use `4 Add API Keys.bat`.
- Start a new chat per task: long chats cost far more tokens.

## Troubleshooting
| Problem | Fix |
|---|---|
| A command "not found" right after setup | Close all Ubuntu windows, run `5 Check Everything.bat` again |
| Claude Code in Ubuntu shows the Windows version | Run `2 Install AI Tools.bat` again, then restart the PC |
| A job hangs | The relay stops it after 45 min; restart the relay if needed |
| A free model stops working | Its free period ended: `opencode models opencode`, pick a new `-free` id, update `config\models.env` |
| PAL "failed to connect" | `shortcuts\7 Fix PAL.bat` |
| Gemini CLI login refused | Expected: Google retired it. The kit uses Antigravity instead |
| Login link won't open | Ubuntu can't open your browser: copy the link manually |
| Codex ignores part of a project's AGENTS.md | Codex stops reading project AGENTS.md files past 32 KiB in total, without a warning. Shorten them |
| Codex shows the same skill twice | Codex reads both `~/.codex/skills` and `~/.agents/skills`. Keep a skill in one of them only |
| Codex job can't install packages | Its sandbox has no network by default. Install packages yourself, or ask Claude to |
| deepseek job says no key | Add DEEPSEEK_API_KEY with `4 Add API Keys.bat` |
| A job waits in the inbox | Another job is running in the same folder, or 2 jobs are already running. It starts on its own |
| Anything else | Ask Claude to read `logs\` and `relay\outbox\` |
