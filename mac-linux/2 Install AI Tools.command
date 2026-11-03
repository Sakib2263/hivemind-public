#!/usr/bin/env bash
# Step 2: installs Claude Code, Antigravity, opencode, Codex, graphify, PAL, clanker-usage, worker rules and skills.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/install-tools.sh
pause_end
