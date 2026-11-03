#!/usr/bin/env bash
# Works through a project's TASKS.md unattended, one row per fresh session, until done, blocked, out of time, or stopped.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
[ -f "$DIR/TASKS.md" ] || { echo "No TASKS.md in: $DIR"; pause_end; exit 1; }
read -r -p "How many hours at most? [8]: " HRS
bash ./scripts/autopilot.sh "$DIR" "${HRS:-8}"
pause_end
