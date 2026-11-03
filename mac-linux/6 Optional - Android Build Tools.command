#!/usr/bin/env bash
# Optional: Java 21 and the Android SDK, for building APKs. Downloads about 1-2 GB. Safe to run again.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
bash ./scripts/android-setup.sh
pause_end
