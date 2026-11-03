#!/usr/bin/env bash
# Opens Codex in a project folder (needs a ChatGPT login).
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
cd "$DIR" && codex
