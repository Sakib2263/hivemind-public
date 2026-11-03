#!/usr/bin/env bash
# Makes one zip per skill in skills-packages/<visibility>/ for uploading to Claude or sharing.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
python3 ./scripts/pack-skills.py && open_path skills-packages
pause_end
