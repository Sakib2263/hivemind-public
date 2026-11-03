#!/usr/bin/env bash
# Brings in your own skills: put skill folders or .skill/.zip files in skills/inbox, then continue.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
mkdir -p skills/inbox && open_path skills/inbox
read -r -p "Put your skills into skills/inbox, then press Enter. " _
python3 ./scripts/add-skills.py
pause_end
