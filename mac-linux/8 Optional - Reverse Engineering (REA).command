#!/usr/bin/env bash
# Optional: registers REA (reverse engineering of your own builds) for Claude Code, opencode and Codex.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/install-rea.sh
pause_end
