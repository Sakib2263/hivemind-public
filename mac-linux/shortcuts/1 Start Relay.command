#!/usr/bin/env bash
# Lets Claude send jobs to the workers. Leave this window open while you work (Ctrl+C stops it).
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
nohup bash ./mac-linux/keep-awake.sh >/dev/null 2>&1 &   # awake only while jobs run (config/awake.env), no window
bash ./scripts/relay.sh; [ $? -eq 3 ] && { sleep 6; exit 0; }; echo "Relay stopped."
pause_end
