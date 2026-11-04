# Hivemind on Mac and Linux

Same kit, same rules, same numbers as Windows (whose `.bat` files are in `../windows/`). Your launchers are
here, as `.command` files, and they work on both macOS and Linux. Everything they run is shared.

- **Mac:** double-click a `.command` file. The first time, macOS may block it: right-click it > Open > Open.
- **Linux:** run it from a terminal (`./"1 Install Basics.command"`), or allow "run executable files" in
  your file manager and double-click.
- Folder questions ("drag it here"): drag the folder into the terminal window and press Enter.

## What you need
| Need | Why |
|---|---|
| macOS 13+ (Apple Silicon or Intel), or Linux (Ubuntu/Debian easiest; others work with your package manager) | The tools |
| About 10 GB free | Tools and models' helpers |
| Claude Pro or Max: the Claude desktop app on Mac; Claude Code on Linux (no desktop app there) | The lead |
| Google account, OpenCode account (free) | Antigravity and the free coding models |
| Optional: ChatGPT login, OpenRouter key | Codex and more free models |

## Set up (once)
1. Get the kit into a work folder, for example `~/Work`:
   ```
   mkdir -p ~/Work && cd ~/Work
   git clone https://github.com/Sakib2263/hivemind-public.git
   chmod +x hivemind/mac-linux/*.command hivemind/mac-linux/shortcuts/*.command
   ```
   (No git yet on a Mac? Run `xcode-select --install` first.)
2. In `hivemind/mac-linux/`, run in order:

| # | Launcher | What happens |
|---|---|---|
| 1 | `1 Install Basics` | Mac: Xcode tools, Homebrew, GNU tools. Linux: git, curl, Python, build tools |
| 2 | `2 Install AI Tools` | Claude Code, Antigravity, opencode, Codex, graphify, PAL, clanker-usage, worker rules and skills (10-20 min) |
| 3 | `3 Log In` | Logs in to each tool; open each link in your browser |
| 4 | `4 Add API Keys` | Opens `secrets/keys.env`: paste keys, save, close (skip if you have none) |
| 5 | `5 Check Everything` | Tests every tool; send `logs/verify.log` to Claude if something fails |
| 7 | `7 Connect Claude` | Makes your Project instructions with this computer's paths and copies them |

3. Mac: Claude desktop app > Projects > New project > Instructions > paste > Save.
   Linux: step 7 saves them as `CLAUDE.md` in your work folder; run `claude` there and it leads the same way.
4. Skills: run `shortcuts/9 Pack Skills`, then upload the zips in your Claude skills settings.

Optional: `6 Optional - Android Build Tools` (APKs), `8 Optional - Reverse Engineering (REA)`,
`9 Optional - Video Studio` (links your own ComfyUI).

## Every day
1. Mac: new chat in your Project, one per task; "+" > "Add folder" > your work folder.
   Linux: `cd ~/Work && claude` (one session per task).
   Before that, every time: open **`Start Hivemind`** (here in `mac-linux`). It starts the relay (and on a Mac the
   live usage window). Leave it open. Without it, Claude does everything itself and burns its own quota.
2. Type the task, for example `My Game: continue from the Handoff.`

## Shortcuts (`mac-linux/shortcuts/`)
| Launcher | Does |
|---|---|
| 1 Start Relay | Lets Claude send jobs to the workers. Leave it open |
| 2 Continue Handoff - opencode | Claude out of quota: a free model does the next step |
| 2 Codex - Continue Handoff | Same with Codex (ChatGPT login) |
| 3 Codex - Open / 4 Claude Code - Open / 5 Antigravity - Open | Opens that tool in a project |
| 6 Check All Tools | Same as setup step 5 |
| 7 Fix PAL | Repairs PAL after an update |
| 8 New Project | Game project intake |
| 9 Pack Skills | Zips the skills for Claude or sharing |
| 10 Build Android App | Test APK or signed Play release |
| 11 Install APK on Phone | Installs an APK on a USB phone |
| 12 Add My Skills | Brings in your own skills from `skills/inbox` |
| 14 Start Video Studio | Starts your linked ComfyUI |
| 17 Autopilot / 18 Stop Autopilot | Unattended work through a TASKS.md, and stopping it |
| 19 Usage | Full usage report |
| 20 Usage Live | Live usage view in a terminal window |
| 21 Asset Library | Drop asset zips or folders on it (or run it to file every zip in the Games folder). Shared library + INDEX.md in Games/_Assets |
| Sync - Pull / Sync - Push (main folder here) | Keep your computers in step through your GitHub repo |

## Not on Mac/Linux yet
- Video Studio installer: install ComfyUI yourself (Linux + NVIDIA, or Apple Silicon), then `9 Optional - Video
  Studio` links it. Music (ACE-Step) and voice cloning (Chatterbox): install by hand for now.
- The floating usage window is Windows only; `20 Usage Live` shows the same numbers in a terminal.
- Not yet tested on a real Mac. If a launcher fails, send Claude what the window shows.

Everything else (rules, skills, workers, checks, Android builds, autopilot): see `../GUIDE.md`. Where it names a
`.bat`, use the launcher here with the same number.
