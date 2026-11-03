#!/usr/bin/env bash
# Windows adb (platform-tools) into hivemind\tools, once per computer. Used by the relay install worker
# and by shortcuts\11 Install APK on Phone.bat. Safe to run again.
KIT="$(cd "$(dirname "$0")/.." && pwd)"; T="$KIT/tools"
[ -f "$T/platform-tools/adb.exe" ] && exit 0
echo "Getting adb for Windows (once per computer)..."
mkdir -p "$T" && curl -fsSL -o "$T/pt.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip \
  && unzip -q -o "$T/pt.zip" -d "$T" && rm -f "$T/pt.zip"
[ -f "$T/platform-tools/adb.exe" ] && echo "adb ready: tools/platform-tools/adb.exe"
