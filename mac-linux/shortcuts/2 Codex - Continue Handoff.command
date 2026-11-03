#!/usr/bin/env bash
# Claude out of quota? Codex continues the project from its TASKS.md Handoff (needs a ChatGPT login).
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
cd "$DIR" && codex "Claude is out of quota, so you lead for now. Read AGENTS.md and TASKS.md, continue from the Handoff section, run the build and tests, then update the TASKS.md Handoff."
pause_end
