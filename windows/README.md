# Hivemind on Windows

Everything here is for Windows. Mac and Linux: see `../mac-linux/README.md`. Overview: `../README.md`.

## Where to put this kit
Put the **hivemind** folder inside your main work folder, for example `D:\Work\hivemind`. Get it with
`git clone https://github.com/Sakib2263/hivemind-public.git` in `D:\Work` (or download the ZIP and unzip it there).
Your projects go next to it (`D:\Work\My Game`), never inside it. Projects elsewhere: list their parent folder in
`config\folders.env` (New Project does this for you). The relay works only in those folders. Which folders to
add in Claude: see GUIDE.md, "Where projects live".

## One-time setup (about 30-40 minutes)
In this `windows` folder, run these in order. Each window tells you the next step.

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

Then:
1. Run `7 Connect Claude.bat` and paste what it copies into a Claude Project's instructions.
2. Skills: run `shortcuts\9 Pack Skills.bat`, then upload the zips you want in your Claude skills settings.
   Claude only sees their names until a task needs one, so they cost almost nothing. The workers get them automatically.
Example prompts: ../GUIDE.md, "Starting a chat".

## Daily use
1. Double-click **`Start Hivemind.bat`** (here in `windows`). It starts the relay and the usage window.
   Right-click the usage window > "Start Hivemind with Windows" and it starts by itself at every login.
2. Claude: new chat per task > "+" > "Add folder" (work folder) > type the task.
Claude reads the Hivemind rules itself (Project instructions). Details and examples: GUIDE.md.

## Shortcuts (`windows\shortcuts\`)
Folder shortcuts: drag a project folder onto the .bat, or double-click and paste the path.

| File | What it does |
|---|---|
| 1 Start Relay.bat | Lets Claude send jobs to the workers. Leave open while working |
| 2 Continue Handoff - opencode.bat | Claude out of quota? A free model does the next step from the TASKS.md Handoff |
| 2 Codex - Continue Handoff.bat | Same, with Codex (needs a ChatGPT login) |
| 3 Codex - Open.bat | Opens Codex in a project (needs a ChatGPT login) |
| 4 Claude Code - Open.bat | Opens Claude Code (Sonnet) in a project |
| 5 Antigravity - Open.bat | Opens Antigravity in a project |
| 6 Check All Tools.bat | Same check as setup step 5 |
| 7 Fix PAL.bat | Fixes PAL if it stops connecting after an update |
| 8 New Project.bat | Starts a game project the right way: new, existing or reskin (copies a base game; can rename the folder). No game name asked: the title is decided before release, with ASO, engine (web or Unity), targets (Android, iOS, web), Android store or test APK, own or publisher SDKs, web portals, size. Writes `project.yaml`, which every later step reads, plus the project files, a .gitignore for the engine, and git |
| 10 Build Android App.bat | Drag a project on it: asks for app name, bundle id and icon if missing, confirms, then builds a test APK or a signed Play release (AAB + APK) into `builds\android\` |
| 11 Install APK on Phone.bat | Drag an APK on it: installs it on a phone plugged in by USB (USB debugging on) |
| 12 Add My Skills.bat | Brings in your own skills: drop skill folders or .skill / .zip files into `skills\inbox\`; they are checked, listed (private by default) and installed |
| 13 Export Public Version.bat | Owner only: makes the clean public copy (`..\hivemind-public`) and pushes it to the public repo in `config\public.env`. Runs after `Sync - Push` too when AUTO_PUBLISH is on |
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

## Your files stay yours
Keys (`secrets\`), usage logs and relay jobs never go to git (see `.gitignore`).
Client or NDA work: read "What may go where" in `templates\ROUTING.md` first.
