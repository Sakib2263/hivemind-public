#!/usr/bin/env bash
# Shared asset library: drop zips/folders on this file to add them; run it alone to file every zip in the Games folder.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
if [ $# -eq 0 ]; then python3 ./scripts/assets.py scan ../Games && python3 ./scripts/assets.py list
else for f in "$@"; do python3 ./scripts/assets.py add "$f"; done; fi
pause_end
