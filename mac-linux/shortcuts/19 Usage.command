#!/usr/bin/env bash
# Full usage report: live Claude and Antigravity %, tokens and jobs per provider and model, what is left.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1
echo "Reading live usage from each provider: up to a minute..."
python3 ./scripts/usage.py
read -r -p "Live Claude or Antigravity reading failed? Type them in by hand [y/N] " A
[ "$A" = y ] || [ "$A" = Y ] && python3 ./scripts/usage.py ask
pause_end
