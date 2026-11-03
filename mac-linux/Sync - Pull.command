#!/usr/bin/env bash
# Gets the latest Hivemind from GitHub (keys in secrets/keys.env are never touched), then refreshes the worker rules.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
REPO="$(tr -d '\r' < "windows/Sync - Pull.bat" 2>/dev/null | sed -n 's/^set "REPO=\(.*\)"/\1/p')"
command -v git >/dev/null || { echo "Install git first (1 Install Basics)."; pause_end; exit 1; }
if [ ! -d .git ]; then
  echo "First sync on this computer: linking this folder to $REPO"
  git init -q -b main && git remote add origin "$REPO" && git fetch origin && git checkout -f -B main origin/main && git branch -u origin/main >/dev/null
else
  git pull --ff-only || echo "Pull failed: you may have local changes. Run Sync - Push first."
fi
bash ./scripts/install-rules.sh || echo "Tools not set up yet on this computer: rules skipped."
git log --oneline -3
pause_end
