#!/usr/bin/env bash
# Step 4: opens secrets/keys.env. Paste your keys after the = signs, save, close the editor.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
[ -f secrets/keys.env ] || cp secrets/keys.env.template secrets/keys.env
echo "Paste your keys after the = signs, then save and close the editor to continue."
if [ "$OS" = Darwin ]; then open -W -e secrets/keys.env; else "${EDITOR:-nano}" secrets/keys.env; fi
bash ./scripts/apply-keys.sh
pause_end
