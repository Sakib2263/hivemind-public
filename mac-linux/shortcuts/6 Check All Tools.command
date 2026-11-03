#!/usr/bin/env bash
# Same check as setup step 5.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
bash ./scripts/verify.sh
pause_end
