#!/usr/bin/env bash
# Game project intake: new, existing or reskin; engine, targets, store, SDKs, portals, size.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
bash ./scripts/new-project.sh
pause_end
