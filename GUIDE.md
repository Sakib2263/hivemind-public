# Hivemind guide: what every file does, and what to use when

**Mac/Linux:** the same guide applies; where it names a `.bat`, use the `.command` with the same number in
`mac-linux/` (setup steps) or `mac-linux/shortcuts/`. Setup: [mac-linux/README.md](mac-linux/README.md).

Start here. The README has the deeper detail; this page tells you which file to open, in which order.

## What Hivemind is
- **Claude (desktop app)** is the lead: it plans, sends work out, and checks results.
- **Workers** do the building: free models through opencode (GLM, DeepSeek), Antigravity (Gemini), and
  Codex too, as soon as it's logged in (any ChatGPT account).
- **The relay** is the bridge. Claude drops a job file, the relay runs it with the right worker, and the
  result comes back. Claude never needs you to paste anything into a terminal.
- Everything runs inside Ubuntu (WSL) on Windows. You only double-click `.bat` files.

Two kinds of `.bat` files:
- **Root folder, numbered 0 to 6:** one-time setup steps, run in order.
- **`shortcuts\` folder, numbered 1 to 13:** everyday tools. Drag a project folder onto the ones that ask for one.

## Where projects live, and which folders to give Claude
- **Work folder:** the folder that holds Hivemind (for example `D:\Work`). Projects go next to Hivemind
  in it (`<work folder>\My Game`), never inside the Hivemind folder.
- **Projects somewhere else** (another drive, a client folder): fine. `8 New Project.bat` asks where to create
  the project and adds that place to `config\folders.env` for you. For an existing project elsewhere, add its
  parent folder to `config\folders.env` yourself (`WORK_FOLDERS="E:\Games;D:\Clients"`). The relay refuses
  any other folder, and anything inside Hivemind.
- **In each new Claude chat, add folders with "+" > "Add folder":**

| Your setup | Add |
|---|---|
| Project inside the work folder (normal) | Only the work folder. It covers Hivemind and every project in it |
| Project in another place | The work folder + that project's folder |
| You want Claude to see only one project | The Hivemind folder + that project's folder |
Claude needs Hivemind's `templates\ROUTING.md` and the `relay\` folder, so Hivemind must always be reachable,
either directly or through the work folder.

## Starting a chat: what you type, and what you don't
**Once (per Claude Project):** run `7 Connect Claude.bat` and paste what it copies into the Project's instructions
(it fills in your folders; the general text is `templates\claude-project-instructions.md`). From then on Claude knows Hivemind by itself: you never ask it to "read the
Hivemind folder". In each chat that needs it, Claude reads ROUTING.md and the project's files once, and checks
the relay is running (it asks you to start it if not).

**Every chat (30 seconds):**
1. Open the Project, start a **new chat** (one chat per task).
2. "+" > "Add folder": your work folder (see the table above). Do this in every new chat.
3. Coding or building today? Double-click `shortcuts\1 Start Relay.bat` (or let Claude remind you).
4. Type the task. Examples:

| Situation | Type |
|---|---|
| Continue a project | `My Game: continue from the Handoff.` |
| New feature | `My Game: add a daily reward screen. Plan first.` |
| A project with no plan yet | `Space Run: read project.yaml and make the PLAN.md for a Tier S prototype.` |
| Bugs from testing | `My Game: fix these: 1) ... 2) ...` |
| Release | `My Game: build a test APK.` / `prepare the Google Play release.` |
| Not a project (research, docs, a question) | Just ask. Claude only loads Hivemind when the work needs it |

Without the Project instructions (another Project, or a fresh account), start the first message with:
`Read <work folder>\hivemind\templates\ROUTING.md, then project <folder>: <task>.`

---

## 1. In what order: the five workflows

### A. First time on a PC (about 40 minutes, once)
**Before you start, you need:** Windows 10 or 11, the Claude desktop app with a Claude Pro or Max plan,
a Google account (Antigravity), a free account at opencode.ai (for its API key).

**Step 0: make the folders.**
1. Make a **work folder** for all your AI work, on a drive with space, for example `D:\AI-Work`.
2. Put Hivemind inside it: `D:\AI-Work\hivemind` (download and unzip the repo there, or `git clone` it there).
3. Your projects will go next to it later (`D:\AI-Work\My Game`). Never put projects inside `hivemind`.
   Projects on another drive are fine too (see "Where projects live").

```
D:\AI-Work\                 <- work folder: add THIS folder in Claude
  hivemind\                  <- this kit (setup files, shortcuts, rules, relay)
  My Game\                   <- a project (made by shortcuts\8 New Project.bat)
  Client Website\            <- another project
```

**Steps 1 to 7: double-click in this order** (root of the Hivemind folder):

| Step | Double-click | What it does |
|---|---|---|
| 1 | `1 Install WSL (run once).bat` | Installs Ubuntu inside Windows. Restart, open Ubuntu, make a username and password |
| 0 | `0 Optional - Move Ubuntu to another drive.bat` | Only if drive C: has under 15 GB free |
| 2 | `2 Install AI Tools.bat` | Installs Claude Code, Antigravity, opencode, graphify, PAL, Codex (optional), the worker rules and skills |
| 3 | `3 Log In.bat` | Logs in to Claude, Antigravity and opencode (free OpenCode Zen key). Codex: type s to skip |
| 4 | `4 Add API Keys.bat` | Optional: a free OpenRouter key for extra free models |
| 5 | `5 Check Everything.bat` | Tests every tool and model. Send `logs\verify.log` to Claude if anything fails |
| 6 | `6 Optional - Android Build Tools.bat` | Only if you build Android apps: Java, Android SDK, adb (1-2 GB) |
| 7 | `7 Connect Claude.bat` | Writes your Claude Project instructions with your folders filled in and copies them. Then in the Claude app: Projects > New project > Instructions > paste > Save |
| 8 | `8 Optional - Reverse Engineering (REA).bat` | Only if you analyse builds: adds REA to the Claude app and the workers (needs Node for Windows; it offers to install it) |
| 9 | `9 Optional - Video Studio.bat` | Only for videos: local AI video, images, music and voice cloning on the NVIDIA GPU (about 36-57 GB). Guide: `stacks\video.md` |

Done. From now on you only use workflow B and "Starting a chat".
Second PC: same steps; `Sync - Pull.bat` keeps both PCs on the same Hivemind version (your own private GitHub repo).

### B. Every working day
1. `Sync - Pull.bat`: get the latest Hivemind from GitHub (also refreshes worker rules and skills).
2. `shortcuts\1 Start Relay.bat`: leave the window open (minimised) while you work.
3. In Claude: new chat per task, add the work folder, type the task (see "Starting a chat" above).
4. Changed anything in Hivemind itself? `Sync - Push.bat` at the end of the day.

### C. A game project, from start to release
| When | Use | Result |
|---|---|---|
| Start a game (new, existing, or a reskin of a base game) | `shortcuts\8 New Project.bat` | Folder, `project.yaml` (engine, targets, SDKs), plan and task files, git. Only a folder name is asked; the title comes later |
| Plan and build | Claude chat (it follows `stacks\web.md` or `stacks\unity.md`) | Work done by the workers, reviewed and checked |
| Try it on a phone | `shortcuts\10 Build Android App.bat`, choose 1 (test APK), then `shortcuts\11 Install APK on Phone.bat` | Test APK in `<game>\builds\android\`, installed by USB. No questions asked |
| Before the first release | Ask Claude for the ASO and store listing (google-play-release skill) | Store title, bundle id, icon decided; ChatGPT prompt pack for the store art and text |
| Before release build and publish | Automatic: Claude runs the store assets check | Anything missing (icon, feature graphic, screenshots, texts, privacy policy) is asked for, or Claude writes the ChatGPT prompt for it |
| Release build | `shortcuts\10 Build Android App.bat`, choose 2 | Signed AAB for Google Play (+ APK). First time on a PC it asks for the signing details |
| Upload | You, in Play Console | Claude never uploads or publishes |

### D. Claude ran out of quota mid-task
`shortcuts\2 Continue Handoff - opencode.bat` and drag the project on it: a free model does the next step from TASKS.md. Repeat, or wait for the Claude reset.

### E. Skills: add yours, share them, publish Hivemind
| Want to | Use |
|---|---|
| Add your own skills | Put folders or `.skill` / `.zip` files in `skills\inbox\`, then `shortcuts\12 Add My Skills.bat` |
| Send a skill to someone, or upload it to claude.ai | `shortcuts\9 Pack Skills.bat` (zips in `skills-packages\shareable / company / private`). Never send private |
| Make a public copy of Hivemind (owner only) | `shortcuts\13 Export Public Version.bat` (makes `..\hivemind-public`, lists what still needs a generic rewrite) |

### F. Videos and content (desktop with an NVIDIA GPU)
Once:
1. `9 Optional - Video Studio.bat`: a setup window opens. Pick the install folder (a drive with space, outside hivemind;
   the choice is saved in `config\studio.env`) and tick the parts: video, images, music, voice. A progress window does
   the rest; run it again any time to add parts or resume a broken download.
2. In a Windows terminal: `wsl --shutdown`, then `shortcuts\1 Start Relay.bat` again.
3. `shortcuts\9 Pack Skills.bat`, then upload `motion-video-producer` from `skills-packages\` to your claude.ai skills
   (keeps the account copy of the video skill up to date for chats without the folder).

Each video day:
1. `shortcuts\1 Start Relay.bat` and `shortcuts\14 Start Video Studio.bat` (leave both open).
2. New chat in the Project, add the work folder, then type one of:

| Situation | Type |
|---|---|
| Continue the content plan | `Content Studio: continue from the Handoff.` |
| Improve the tools | `Local Gen Lab: continue from the Handoff.` |
| One video | `Make a 60-second Short and a 10-minute video about <topic>. Script first.` |
| AI shots only | `Make shots for <episode folder>: <what you want to see>.` |

Optional: `15 Start Music Studio.bat` (songs), `16 Clone Voice.bat` (your voice, one WAV per line).
Playbook with tools, licences and monetization rules: `stacks\video.md`. Content folders (`Content Studio`,
`Local Gen Lab`) sit next to hivemind and are not part of the git sync.

### G. Long unattended runs (autopilot)
For long jobs you don't want to babysit. Works on any project folder with a TASKS.md.
1. Start `shortcuts\1 Start Relay.bat` (and `14 Start Video Studio.bat` for video work).
2. Drag the project folder onto `shortcuts\17 Autopilot.bat`, enter the hours (default 8).
3. It runs one board row per fresh session, with no permission prompts: anything outside a safe list
   (deleting, pushing, uploading, spending) is refused automatically. When Claude runs out of quota, the
   free models take over. It stops when the board is done, a row needs you (question in the TASKS.md
   Handoff), the hours run out, or you run `shortcuts\18 Stop Autopilot.bat`.
4. Log: `logs\autopilot\`. Check the Handoff and the git log when you're back.

---

## 2. "I want to..." quick finder
| I want to... | Open |
|---|---|
| Let Claude work for hours without me | Drag the project onto `shortcuts\17 Autopilot.bat` (section G) |
| Make videos, Shorts or a content channel | `9 Optional - Video Studio.bat` once, then ask Claude: "Make a video about X" (playbook `stacks\video.md`) |
| Set up a new PC | Workflow A |
| Get the other PC's changes | `Sync - Pull.bat` |
| Save my Hivemind changes to GitHub | `Sync - Push.bat` |
| Let Claude send work to the models | `shortcuts\1 Start Relay.bat` (keep it open) |
| Check that everything works | `5 Check Everything.bat` or `shortcuts\6 Check All Tools.bat` (same thing) |
| Start or reshape a game project, rename its folder | `shortcuts\8 New Project.bat` |
| Build a test APK or a Play Store release | `shortcuts\10 Build Android App.bat` |
| Put an APK on my phone | `shortcuts\11 Install APK on Phone.bat` |
| Keep going when Claude is out of quota | `shortcuts\2 Continue Handoff - opencode.bat` |
| Open a tool in a project myself | `shortcuts\4 Claude Code - Open.bat`, `5 Antigravity - Open.bat`, `3 Codex - Open.bat` (Codex needs a ChatGPT login) |
| Fix PAL after an update | `shortcuts\7 Fix PAL.bat` |
| Change which model does what | `config\models.env` (models) and `templates\ROUTING.md` (rules) |
| Change the rules every worker follows | `rules\AGENTS-floor.md`, then `Sync - Pull.bat` (reinstalls them) |
| Change a check (build, security, release, review) | `gates\*.md` |
| Fix security or encryption problems | Ask Claude: it runs the `security` check, then fixes with the `security-hardening` skill |
| See what my own APK or web build exposes | Ask Claude to use REA on it (after `8 Optional - Reverse Engineering (REA).bat`) |
| Build my own version of another app | Ask Claude for the Replica skills (`replica-recon` first) |
| See how much usage I have left (Claude, opencode, Antigravity, OpenRouter, Flow) | `shortcuts\20 Usage Overlay.bat` (live window), `shortcuts\19 Usage.bat` (full report) |
| Change a usage limit or budget | `config\limits.env` |
| Know what's planned next | `NEXT.md`, `plans\UNITY-PLAN.md` |

---

## 3. Every file, by folder

### Root folder
| File | Purpose |
|---|---|
| `GUIDE.md` | This page |
| `README.md` | Full reference: requirements, relay job format, free models, troubleshooting |
| `NEXT.md` | The to-do list for building Hivemind further, in order |
| `0` to `8 *.bat` | Setup steps (workflow A); 0, 6 and 8 are optional |
| `my-claude-instructions.txt` | Made by `7 Connect Claude.bat`: your filled-in Project instructions (not on GitHub) |
| `Sync - Pull.bat` / `Sync - Push.bat` | Keep two PCs in step through your private GitHub repo |
| `.gitignore`, `.gitattributes` | What git leaves out (keys, logs, jobs, tools, zips) and line-ending rules |

### `shortcuts\` (everyday tools)
| File | Purpose |
|---|---|
| `1 Start Relay.bat` | Runs the relay. Needed whenever Claude should use the workers |
| `2 Continue Handoff - opencode.bat` | Free model continues a project when Claude is out of quota |
| `2 Codex - Continue Handoff.bat` | Same with Codex (needs a ChatGPT login) |
| `3 Codex - Open.bat` | Opens Codex in a project (needs a ChatGPT login) |
| `4 Claude Code - Open.bat` | Opens Claude Code in a project, in Ubuntu |
| `5 Antigravity - Open.bat` | Opens Antigravity in a project |
| `6 Check All Tools.bat` | Same check as setup step 5 |
| `7 Fix PAL.bat` | Repairs PAL (the OpenRouter bridge) when an update breaks it |
| `8 New Project.bat` | Game project intake: new / existing (rename folder) / reskin, engine, targets, Android store, SDKs, web portals, size |
| `9 Pack Skills.bat` | Zips every skill for upload or sharing |
| `10 Build Android App.bat` | Test APK (no questions) or signed release (asks only what is not decided yet) |
| `11 Install APK on Phone.bat` | Installs an APK on a USB-connected phone |
| `12 Add My Skills.bat` | Brings your own skills in from `skills\inbox\` |
| `13 Export Public Version.bat` | Owner only: makes the clean public copy and pushes it to the public repo (also runs after `Sync - Push` when AUTO_PUBLISH is on) |
| `14 Start Video Studio.bat` | Starts ComfyUI (AI clips and stills). Leave open while making videos |
| `15 Start Music Studio.bat` | Opens ACE-Step to make songs and background music |
| `16 Clone Voice.bat` | Drag a folder with voice.wav + lines.txt onto it: one WAV per line in your cloned voice |
| `17 Autopilot.bat` | Drag a project folder on it: works through its TASKS.md unattended for N hours |
| `18 Stop Autopilot.bat` | Stops the autopilot after its current step |
| `19 Usage.bat` | Full usage report per provider and model: today, 5-hour window, week, month, what's left, reset times. Lets you type in Flow credits |
| `20 Usage Overlay.bat` | Small always-on-top window with usage left per provider, live (Claude and Antigravity read every 5 min). Drag to move; right-click: Refresh, Open full report, Start with Windows, Close |

### `templates\` (copied into projects, or read by Claude)
| File | Purpose |
|---|---|
| `claude-project-instructions.md` | Paste once into your Claude Project: then Claude knows Hivemind in every chat |
| `ROUTING.md` | The lead's rulebook: task classes, which worker does what, relay jobs, token saving, Android builds, data rules |
| `project.yaml` | Project profile written by New Project: engine, targets, Android store, SDKs, web portals, store title (later) |
| `CLAUDE.md` | Project rules for Claude (copied into each project) |
| `AGENTS.md` | Project rules for workers (copied into each project) |
| `PLAN.md` / `TASKS.md` | Plan and task board with the Handoff section (copied into each project) |
| `android.env` | App facts for Android builds: name, bundle id, icon, version |
| `signing.env.example` | Example of the signing settings (the real file is in `secrets\android\`) |

### `stacks\` (how to build, per engine)
| File | Purpose |
|---|---|
| `README.md` | The intake questions and which engine to choose |
| `web.md` | three.js / Canvas / Vite: setup, SDKs per target, dev loop, QA, builds |
| `unity.md` | Unity: agent rules, setup, SDKs, dev loop, QA, builds |

### `gates\` (checks, run by the relay on request)
| File | Purpose |
|---|---|
| `README.md` | When each check runs, and the PASS / PASS (STATIC ONLY) / FAIL / NEEDS-REVIEW results |
| `build.md` | Build runs, tests pass, each "Done when" line checked |
| `security.md` | Coins, rewards, IAP, saves, secrets, input, accounts |
| `release.md` | Before anything public: version, debug code, ads, store rules, screen sizes |
| `review.md` | Code review checklist for the `review` worker |

### `config\`, `rules\`, `plans\`
| File | Purpose |
|---|---|
| `config\models.env` | Which model each worker uses, fallback chains, check and review engines. Dated decisions |
| `config\limits.env` | Usage limits and your own budgets per provider (Claude week reset, job budgets, Flow credits). Dated decisions |
| `config\folders.env` | Extra places where projects may live, outside the work folder (New Project fills it in) |
| `rules\AGENTS-floor.md` | Rules every worker loads (installed into opencode, Claude Code and Codex) |
| `plans\UNITY-PLAN.md` | The Unity plan: what is ready, what is planned (U1 to U10), decisions needed |

### `scripts\` (run by the .bat files; you don't open these)
| Script | Started by | Does |
|---|---|---|
| `install-tools.sh` | `2 Install AI Tools.bat` | Installs every tool in Ubuntu |
| `login.sh` | `3 Log In.bat` | Logs in to each tool |
| `apply-keys.sh` | `4 Add API Keys.bat` | Connects your keys to PAL |
| `verify.sh` | `5 Check Everything.bat`, `6 Check All Tools.bat` | Tests tools, models, rules, Android setup |
| `android-setup.sh` | `6 Optional - Android Build Tools.bat` | Java, Android SDK, adb |
| `install-rea.sh` | `8 Optional - Reverse Engineering (REA).bat` | Registers REA for Claude Code, opencode and Codex in Ubuntu |
| `install-rules.sh` | Install, `Sync - Pull.bat` | Writes the worker rules, then installs worker skills |
| `install-skills.py` | `install-rules.sh`, Add My Skills | Copies `workers: true` skills to `~/.agents/skills` |
| `relay.sh` | `1 Start Relay.bat` | The relay: runs jobs, falls back between models on limits |
| `handoff.sh` | `2 Continue Handoff - opencode.bat` | Free model continues from TASKS.md |
| `fix-pal.sh` | `7 Fix PAL.bat` | Pins PAL's library version |
| `new-project.sh` | `8 New Project.bat` | The project intake |
| `pack-skills.py` | `9 Pack Skills.bat` | Zips skills by visibility |
| `android-build.sh` | `10 Build Android App.bat`, relay `android` jobs | Builds test APKs and signed releases |
| `check-store-assets.py` | Release build, release check, Claude before publishing | Checks icon, name, bundle id, store art sizes, screenshots and listing text; lists what is MISSING |
| `add-skills.py` | `12 Add My Skills.bat` | Imports your skills |
| `export-public.py` | `13 Export Public Version.bat` | Makes the public copy |
| `usage.py` | `19`/`20` Usage, relay and autopilot after every job | Live Claude and Antigravity quota (clanker-usage), local token logs (Claude Code, opencode, Codex), the relay ledger, OpenRouter; writes `USAGE.md` and `USAGE.json` |
| `usage-overlay.ps1` | `20 Usage Overlay.bat` | The live usage window (Windows PowerShell) |

### `skills\`
| Item | Purpose |
|---|---|
| `index.yaml` | List of every skill: when to use it, who may see it (shareable / company / private), installed for workers or not |
| `README.md` | How skills work, how to add yours, how to share |
| `inbox\` | Drop zone for Add My Skills |
| one folder per skill | The skill itself (`SKILL.md` + references, scripts) |

### Working folders (made and filled by the tools)
| Folder | Holds | On GitHub? |
|---|---|---|
| `relay\inbox`, `outbox`, `done`, `locks` | Job files and results | No |
| `logs\` | Install, check and Android setup logs; `usage-ledger.csv` (every worker try) and `usage-readings.csv` (what you typed in) | No |
| `USAGE.md`, `USAGE.json` (root) | The usage overview (report, and data for the overlay) | No |
| `secrets\` | `keys.env` (API keys), `android\signing.env` + keystore | No. Back up `secrets\android` yourself |
| `tools\` | adb for Windows | No |
| `skills-packages\` | Zips made by Pack Skills | No |

---

## 4. Good habits
- New Claude chat for each task; long chats burn quota.
- Keep the relay window open while Claude works; close it when you're done.
- Pull before you start, push when you've changed Hivemind.
- Never paste keys or passwords into a chat. Keys go in `secrets\` through the .bat files.
- Client or NDA work goes to Claude and Antigravity only (see ROUTING.md section 8).
