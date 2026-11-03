#!/usr/bin/env bash
# Opens Antigravity (Gemini) in a project folder.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
cd "$DIR" && agy
