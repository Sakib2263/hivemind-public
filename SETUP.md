# Set up Hivemind (new PC or new person)

Hivemind turns the Claude desktop app into the lead of a small AI team: Claude plans and reviews, free models
(opencode, Antigravity) do most of the coding, and scripts do chores (builds, uploads, commits).
After setup, every chat in your Claude Project already knows the rules and has the skills. Nothing to paste again.

## What you need
| Need | Why |
|---|---|
| Windows 10/11, 8 GB RAM, about 15 GB free | Ubuntu (WSL) and the tools |
| Claude desktop app, Claude Pro or Max | The lead |
| Google account | Antigravity worker (free tier works) |
| OpenCode account (free) | Main free coding models |
| Git for Windows (git-scm.com) | Getting and updating the kit |
| Optional: OpenRouter key, NVIDIA GPU | Extra free models; local images, video and music |

## 1. Get the kit (5 min)
Pick a work folder, for example `D:\Work`. Your projects go in it; Hivemind goes inside it:
```
cd /d D:\Work
git clone https://github.com/YOUR_GITHUB_USER/hivemind.git
```
Want your own changes saved on GitHub? Fork the repo first and clone your fork. `Sync - Pull.bat` and
`Sync - Push.bat` then keep your PCs in step.

## 2. Install (once, about 40 min)
In `D:\Work\hivemind`, double-click in order: `1 Install WSL` (restart when asked) > `2 Install AI Tools` >
`3 Log In` > `4 Add API Keys` (skip if you have none) > `5 Check Everything`.
Optional: `6` Android builds, `8` reverse engineering of your own builds, `9` Video Studio (NVIDIA GPU).

## 3. Connect Claude (once, 2 min)
1. Double-click `7 Connect Claude.bat`. It fills in your folders and copies the Project instructions.
2. Claude desktop app > Projects > New project (for example "AI Team") > Instructions > paste > Save.

That's what makes it automatic: each new chat reads one short rules file (`templates\ROUTING.md`, about
2.8k tokens) once, and opens other files only when the task needs them.

## 4. Add the skills (once, 5 min)
1. Double-click `shortcuts\9 Pack Skills.bat`. It makes one zip per skill in `skills-packages\`.
2. In Claude (claude.ai or the desktop app), open your skills settings and upload each zip you want.

Uploaded skills cost almost nothing until used: Claude sees only their names and one-line descriptions, and
loads a skill only when a task needs it. The free workers get the same skills automatically (setup and every
`Sync - Pull`). Your own skills: drop them in `skills\inbox\` and run `shortcuts\12 Add My Skills.bat`.

## 5. Every day
1. New chat in your Project, one per task.
2. "+" > "Add folder" > your work folder.
3. `shortcuts\1 Start Relay.bat` (leave it open; Claude reminds you).
4. Type the task, for example `My Game: continue from the Handoff.` or `New game: a gear puzzle. Plan first.`

Handy: `shortcuts\20 Usage Overlay.bat` shows how much quota each provider has left.
Out of Claude quota: `shortcuts\2 Continue Handoff - opencode.bat`. Everything else: `GUIDE.md`.

## Your files stay yours
Keys (`secrets\`), usage logs and relay jobs never go to git (see `.gitignore`).
Client or NDA work: read the "What may go where" table in `templates\ROUTING.md` first.
