#!/usr/bin/env bash
# Lets Claude send jobs to the workers. Leave this window open while you work (Ctrl+C stops it).
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
bash ./scripts/relay.sh; echo "Relay stopped."
pause_end
