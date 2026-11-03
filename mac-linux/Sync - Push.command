#!/usr/bin/env bash
# Saves your Hivemind changes and uploads them to your private GitHub repo (then publishes the public copy when AUTO_PUBLISH is on).
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
git status --short
read -r -p "Describe the change (Enter = 'update Hivemind'): " MSG; MSG="${MSG:-update Hivemind}"
git add -A && git add --chmod=+x -- 'mac-linux/*.command' 'mac-linux/shortcuts/*.command' 2>/dev/null
git commit -m "$MSG" || echo "Nothing new to save."
git ls-remote --exit-code --heads origin main >/dev/null 2>&1 && { git pull --rebase origin main || { echo "Pull failed. Ask Claude to help."; pause_end; exit 1; }; }
git push -u origin main || { echo "Upload failed. Check the sign-in, then try again."; pause_end; exit 1; }
echo "Uploaded. On your other computer, run Sync - Pull."
grep -qiE '^AUTO_PUBLISH="?yes' config/public.env 2>/dev/null && { echo; echo "Publishing the public version..."; bash "mac-linux/shortcuts/13 Export Public Version.command" auto; }
git log --oneline -3
pause_end
