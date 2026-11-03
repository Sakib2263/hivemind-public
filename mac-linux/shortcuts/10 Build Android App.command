#!/usr/bin/env bash
# Builds a test APK or a signed Play release for a project. Asks for anything missing.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
DIR="$(ask_path "Project folder")"
[ -d "$DIR" ] || { echo "Folder not found: $DIR"; pause_end; exit 1; }
echo "1 = Test APK (debug)   2 = Release for Google Play (signed AAB + APK)"
read -r -p "Choose 1 or 2: " T; MODE=debug; [ "$T" = 2 ] && MODE=release
bash ./scripts/android-build.sh "$DIR" "$MODE"
[ -d "$DIR/builds/android" ] && open_path "$DIR/builds/android"
pause_end
