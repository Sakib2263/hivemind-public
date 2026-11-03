#!/usr/bin/env bash
# Installs what Android builds need inside Ubuntu: Java 21, the Android SDK command-line tools,
# adb (platform-tools), an SDK platform and build-tools. Safe to run again.
# Started by "6 Optional - Android Build Tools.bat".
KIT="$(cd "$(dirname "$0")/.." && pwd)"
exec > >(tee "$KIT/logs/android-setup.log") 2>&1
SDK="$HOME/android-sdk"
ok() { echo "[OK]   $*"; }; fail() { echo "[FAIL] $*"; FAILED=1; }

echo "=== 1/4 Java 21 (type your Ubuntu password if asked) ==="
if [ "$(uname -s)" = Darwin ]; then   # macOS: Homebrew Java 21 (mac-linux/_env.sh adds it to PATH)
  brew list openjdk@21 >/dev/null 2>&1 || brew install openjdk@21
  export PATH="$(brew --prefix)/opt/openjdk@21/bin:$PATH"
else
command -v javac >/dev/null && javac -version 2>&1 | grep -q " 21" || sudo apt-get install -y openjdk-21-jdk-headless unzip
command -v rsync >/dev/null && command -v unzip >/dev/null || sudo apt-get install -y rsync unzip
fi
javac -version 2>&1 | grep -q " 21" && ok "$(javac -version 2>&1)" || fail "Java 21"

echo; echo "=== 2/4 Android command-line tools ==="
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  tmp="$(mktemp -d)"
  # newest first; Google changes the build number now and then
  for v in 15859902 13114758 11076708; do
    curl -fsSL -o "$tmp/t.zip" "https://dl.google.com/android/repository/commandlinetools-$([ "$(uname -s)" = Darwin ] && echo mac || echo linux)-${v}_latest.zip" && break
  done
  mkdir -p "$SDK/cmdline-tools" && unzip -q -o "$tmp/t.zip" -d "$tmp" && rm -rf "$SDK/cmdline-tools/latest" && mv "$tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
  rm -rf "$tmp"
fi
[ -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ] && ok "sdkmanager" || fail "command-line tools (download blocked? see developer.android.com/studio, 'Command line tools only')"

echo; echo "=== 3/4 Paths ==="
if ! grep -q "ANDROID_HOME" "$HOME/.bashrc"; then
  printf '\nexport ANDROID_HOME="$HOME/android-sdk"\nexport PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"\n' >> "$HOME/.bashrc"
fi
export ANDROID_HOME="$SDK"; export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$PATH"
ok "ANDROID_HOME=$ANDROID_HOME"

echo; echo "=== 4/4 SDK packages (accepts the Android SDK licences) ==="
yes | sdkmanager --licenses >/dev/null 2>&1
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" >/dev/null && ok "platform-tools, android-36, build-tools 36" || fail "SDK packages"
command -v adb >/dev/null && ok "$(adb version | head -1)" || fail "adb"

echo; [ -z "$FAILED" ] && echo "ALL OK. Build with windows\shortcuts\\10 Build Android App.bat" || echo "Something failed: send logs\\android-setup.log to Claude."
