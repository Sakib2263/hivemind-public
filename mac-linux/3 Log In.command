#!/usr/bin/env bash
# Step 3: logs in to Claude, Antigravity, opencode and Codex, one by one.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/login.sh
pause_end
