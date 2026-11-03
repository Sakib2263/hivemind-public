#!/usr/bin/env bash
# Open this before you start working: starts the relay (so Claude can use the free workers) and, on a Mac,
# the live usage view in a second window. Leave this window open while you work (Ctrl+C stops the relay).
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
h="$(cat relay/heartbeat 2>/dev/null)"
if [ -n "$h" ] && [ $(( $(date +%s) - h )) -lt 60 ]; then echo "The relay is already running."; pause_end; exit 0; fi
[ "$OS" = Darwin ] && open -a Terminal "$HM/mac-linux/shortcuts/20 Usage Live.command"
echo "Starting the relay. Leave this window open. In Claude: new chat in your Project (Linux: run claude in"
echo "your work folder), add the work folder, type the task. Updates: mac-linux/Sync - Pull now and then."
echo
bash ./scripts/relay.sh
