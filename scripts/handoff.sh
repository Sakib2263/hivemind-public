#!/usr/bin/env bash
# Claude is out of quota: a free model continues the project from its TASKS.md Handoff, one pass.
# Started by "windows\shortcuts\2 Continue Handoff - opencode.bat". $1 = project folder (WSL path).
KIT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
. "$KIT/config/models.env"
cd "$1" || { echo "Folder not found: $1"; exit 1; }
P="Claude is out of quota, so you lead for now. Read AGENTS.md and TASKS.md, continue from the Handoff section, do the next step only, run the build and tests, then update the TASKS.md Handoff. Do not commit."
for m in "$OPENCODE_FREE_MODEL" "$OPENCODE_FREE2_MODEL"; do
  echo "=== $m"; opencode run -m "$m" "$P" && break
  echo "That model failed or hit a limit; trying the next one."
done
echo; echo "Done. Run this again for the next step, or go back to Claude when its quota resets."
