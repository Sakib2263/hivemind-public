#!/usr/bin/env bash
# Installs an APK on a phone plugged in by USB (Developer options > USB debugging on; tap Allow on the phone).
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
command -v adb >/dev/null || bash ./scripts/get-adb.sh
ADB="$(command -v adb || echo "$HM/tools/platform-tools/adb")"
APK="$(ask_path "APK file")"
[ -f "$APK" ] || { echo "File not found: $APK"; pause_end; exit 1; }
"$ADB" devices && "$ADB" install -r "$APK" && echo "Installed. Open it on the phone."
pause_end
