#!/usr/bin/env bash
# Run if PAL stops connecting after an update.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
bash ./scripts/fix-pal.sh
pause_end
