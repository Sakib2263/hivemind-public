#!/usr/bin/env bash
# Live usage view in this window, refreshed every minute (the Windows overlay's Mac/Linux version). Ctrl+C to close.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1
python3 ./scripts/usage.py watch
