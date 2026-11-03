# Shared by every Mac/Linux launcher (not used on Windows). Sets one PATH so the shared scripts behave
# the same as on Windows/WSL: on macOS, Homebrew's GNU tools and bash 5 come first. Then helpers.
HM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OS="$(uname -s)"
if [ "$OS" = Darwin ]; then
  for b in /opt/homebrew /usr/local; do [ -x "$b/bin/brew" ] && eval "$("$b/bin/brew" shellenv)" && break; done
  if command -v brew >/dev/null 2>&1; then
    P="$(brew --prefix)"
    for g in coreutils gnu-sed findutils grep gawk; do [ -d "$P/opt/$g/libexec/gnubin" ] && PATH="$P/opt/$g/libexec/gnubin:$PATH"; done
    [ -d "$P/opt/openjdk@21/bin" ] && PATH="$P/opt/openjdk@21/bin:$PATH"
  fi
fi
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
export PATH="$HOME/.local/bin:$ANDROID_HOME/platform-tools:$PATH"
cd "$HM" || exit 1

pause_end() { echo; read -r -p "Press Enter to close. " _; }
open_path() { if [ "$OS" = Darwin ]; then open "$1"; else xdg-open "$1" >/dev/null 2>&1 || echo "Open: $1"; fi; }
clean_path() {  # a path dragged into Terminal: strip quotes, "\ " escapes and trailing spaces
  local p="$1"; p="${p%"${p##*[![:space:]]}"}"; p="${p#\"}"; p="${p%\"}"; p="${p#\'}"; p="${p%\'}"; p="${p//\\ / }"; echo "${p%/}"
}
ask_path() {  # $1 = what to ask; uses the launcher's first argument if given
  local p="$ARG1"; [ -n "$p" ] || read -r -p "$1 - drag it here or paste the path: " p; clean_path "$p"
}
