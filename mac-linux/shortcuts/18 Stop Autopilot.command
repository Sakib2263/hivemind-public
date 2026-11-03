#!/usr/bin/env bash
# Tells a running autopilot to stop after its current step.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
: > relay/AUTOPILOT.stop && echo "Autopilot will stop after its current step. Close its window to stop right away."; sleep 3
