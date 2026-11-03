#!/usr/bin/env bash
# Step 1: Mac = Xcode tools + Homebrew + GNU tools; Linux = git, curl, Python, build tools.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/install-tools.sh --basics
pause_end
