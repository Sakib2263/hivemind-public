#!/usr/bin/env bash
# Windows adb (platform-tools) into hivemind\tools, once per computer. Used by the relay install worker
# and by shortcuts\11 Install APK on Phone.bat. Safe to run again.
KIT="$(cd "$(dirname "$0")/.." && pwd)"; T="$KIT/tools"
if ! grep -qi microsoft /proc/version 2>/dev/null; then   # macOS/Linux: the native adb (SDK or PATH first)
  command -v adb >/dev/null || [ -x "$HOME/android-sdk/platform-tools/adb" ] || [ -x "$T/platform-tools/adb" ] && exit 0
  os=linux; [ "$(uname -s)" = Darwin ] && os=darwin
  mkdir -p "$T" && curl -fsSL -o "$T/pt.zip" "https://dl.google.com/android/repository/platform-tools-latest-$os.zip" \
    && unzip -q -o "$T/pt.zip" -d "$T" && rm -f "$T/pt.zip"
  [ -x "$T/platform-tools/adb" ] && echo "adb ready: tools/platform-tools/adb"; exit 0
fi
[ -f "$T/platform-tools/adb.exe" ] && exit 0
echo "Getting adb for Windows (once per computer)..."
mkdir -p "$T" && curl -fsSL -o "$T/pt.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip \
  && unzip -q -o "$T/pt.zip" -d "$T" && rm -f "$T/pt.zip"
[ -f "$T/platform-tools/adb.exe" ] && echo "adb ready: tools/platform-tools/adb.exe"
