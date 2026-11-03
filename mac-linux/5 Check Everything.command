#!/usr/bin/env bash
# Step 5: tests every tool and model; send logs/verify.log to Claude if something fails.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/verify.sh
pause_end
