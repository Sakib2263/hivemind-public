#!/usr/bin/env bash
# Claude out of quota? A free model does the next step from the project's TASKS.md Handoff.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
bash ./scripts/handoff.sh "$DIR"
pause_end
