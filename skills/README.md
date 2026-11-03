# Skills library

Skills that work in any AI tool, kept here so they survive outside claude.ai and can be shared.
The list, with when to use each one and who may see it: `index.yaml`.

## What a skill is
A folder with a `SKILL.md` file. The file starts with a short YAML header (`name`, `description`), then
plain instructions. Some skills also have `references/`, `scripts/` or `assets/` folders. This is the
Agent Skills open standard, so the same folder works in Claude, Codex, opencode and other tools.

## Add your own skills
1. Put skill folders, or `.skill` / `.zip` files, into `skills\inbox\`
   (from claude.ai: download the skill as a zip; from Claude Code: copy the folder from `~/.claude/skills`).
2. Double-click `windows\shortcuts\12 Add My Skills.bat`. It checks each one, moves it here, adds it to `index.yaml`
   (private by default) and installs the ones you mark for the coding workers.

## Who may see what (the `visibility` field in index.yaml)
| Value | Share with |
|---|---|
| shareable | anyone; goes into the public version of Hivemind |
| company | your team only |
| private | nobody: personal context, confidential figures, your own voice. Never exported |

## Use them in each tool
| Tool | How |
|---|---|
| Codex, opencode | Done for you: `workers: true` skills are copied into `~/.agents/skills` on setup and on every Sync - Pull |
| Claude (claude.ai, desktop) | Upload the skill's zip (make zips with `windows\shortcuts\9 Pack Skills.bat`) |
| Claude Code | Copy the skill folder into `~/.claude/skills/` |
| Any other agent | "Read skills/index.yaml, and open a skill's SKILL.md only when the task matches its use_when" |

## Share or publish
- One skill: `windows\shortcuts\9 Pack Skills.bat` makes zips in `skills-packages\<visibility>\`. Never send `private` ones.
- The whole kit: `windows\shortcuts\13 Export Public Version.bat` (owner only) makes a clean copy with only the
  shareable skills that contain no personal or company words, and lists what still needs a generic rewrite.
