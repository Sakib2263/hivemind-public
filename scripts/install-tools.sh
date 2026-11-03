#!/usr/bin/env bash
# Installs every AI tool inside Ubuntu (WSL), then the shared worker rules. Safe to run again: it skips what is already there.
# Started by "2 Install AI Tools.bat". Includes the fixes found during the first setup:
#  - Ubuntu must not use Windows programs (otherwise it picks up a Windows Claude Code)
#  - Gemini CLI is replaced by Antigravity CLI (Google retired Gemini CLI personal logins)
#  - PAL needs the mcp library below version 2

KIT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$KIT/logs/install-tools.log"
exec > >(tee "$LOG") 2>&1
ok()   { echo "[OK]   $*"; }
step() { echo; echo "=== $* ==="; }
fail() { echo "[FAIL] $*"; FAILED="$FAILED\n- $*"; }
FAILED=""
OS="$(uname -s)"; WSL=0; grep -qi microsoft /proc/version 2>/dev/null && WSL=1   # Windows: WSL. Also runs on macOS and Linux

step "1/11 Base packages (type your password when asked)"
if [ "$OS" = Darwin ]; then   # macOS: Xcode command-line tools, Homebrew, GNU tools + bash 5 (mac-linux/_env.sh puts them first)
  xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Finish the Xcode tools window, then run this again."; exit 1; }
  command -v brew >/dev/null || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ] \
    || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for b in /opt/homebrew /usr/local; do [ -x "$b/bin/brew" ] && eval "$("$b/bin/brew" shellenv)" && break; done
  brew install git python coreutils gnu-sed findutils grep gawk bash unzip rsync && ok "base packages (Homebrew)" || fail "base packages"
  . "$KIT/mac-linux/_env.sh"
elif command -v apt-get >/dev/null; then
  sudo -v && sudo apt-get update -y && sudo apt-get install -y git curl build-essential python3 python3-pip python3-venv unzip \
    && ok "base packages" || fail "base packages"
else   # other Linux: check instead of install
  miss=""; for t in git curl make gcc python3 unzip; do command -v $t >/dev/null || miss="$miss $t"; done
  [ -z "$miss" ] && ok "base packages" || fail "base packages: install$miss with your package manager, then run this again"
fi
[ "$1" = "--basics" ] && { echo; [ -n "$FAILED" ] && echo -e "FAILED:$FAILED" || echo "Basics OK. Next: 2 Install AI Tools."; exit 0; }

step "2/11 Stop Ubuntu from using Windows programs"
if [ "$WSL" = 1 ]; then
grep -q "appendWindowsPath" /etc/wsl.conf 2>/dev/null || printf '\n[interop]\nappendWindowsPath=false\n' | sudo tee -a /etc/wsl.conf >/dev/null
grep -q "appendWindowsPath=false" /etc/wsl.conf && ok "wsl.conf" || fail "wsl.conf"
else echo "[SKIP] not Windows"; fi
export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd:)"
export PATH="$HOME/.local/bin:$PATH"

step "3/11 Node.js"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
. "$NVM_DIR/nvm.sh"
if ! command -v node >/dev/null || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 22 ]; then nvm install --lts && nvm alias default 'lts/*'; fi
command -v node >/dev/null && ok "node $(node --version)" || fail "node"

step "4/11 uv (Python tool installer)"
command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
command -v uv >/dev/null && ok "$(uv --version)" || fail "uv"

step "5/11 Claude Code (main agent)"
[ -x "$HOME/.local/bin/claude" ] || curl -fsSL https://claude.ai/install.sh | bash
hash -r; [ -x "$HOME/.local/bin/claude" ] && ok "claude $(claude --version 2>/dev/null)" || fail "claude code"

step "6/11 Antigravity CLI (worker) and Codex CLI (optional, for a ChatGPT plan later)"
command -v codex >/dev/null || npm install -g @openai/codex
command -v agy >/dev/null || curl -fsSL https://antigravity.google/cli/install.sh | bash
hash -r
command -v codex >/dev/null && ok "codex $(codex --version 2>/dev/null) (optional)" || echo "[SKIP] codex (optional)"
command -v agy   >/dev/null && ok "agy $(agy --version 2>/dev/null | head -1)" || fail "antigravity"

step "7/11 opencode (main free builder: GLM and DeepSeek free models)"
command -v opencode >/dev/null || npm install -g opencode-ai
hash -r; command -v opencode >/dev/null && ok "opencode $(opencode --version 2>/dev/null | head -1)" || fail "opencode"

step "8/11 graphify (shared project memory)"
command -v graphify >/dev/null || uv tool install "graphifyy[pdf,office]"
uv tool update-shell >/dev/null 2>&1; hash -r
command -v graphify >/dev/null && graphify install >/dev/null && ok "graphify + Claude Code skill" || fail "graphify"

step "Extra: clanker-usage (live Claude and Antigravity quota for the usage overview)"
command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1
hash -r; command -v clanker-usage >/dev/null && ok "clanker-usage" || echo "[SKIP] clanker-usage (usage overview falls back to typed-in readings)"

step "9/11 PAL MCP server (OpenRouter / DeepSeek bridge)"
PAL="$HOME/pal-mcp-server"
[ -d "$PAL/.git" ] || git clone https://github.com/BeehiveInnovations/pal-mcp-server.git "$PAL"
cd "$PAL" && [ -x .pal_venv/bin/python ] || uv venv --python 3.12 .pal_venv
uv pip install --python "$PAL/.pal_venv/bin/python" -r "$PAL/requirements.txt" "mcp>=1.0,<2" >/dev/null \
  && ok "PAL installed (keys are added in step 4)" || fail "PAL install"

step "10/11 Codex plugin for Claude Code (optional)"
claude plugin marketplace add openai/codex-plugin-cc >/dev/null 2>&1
claude plugin install codex@openai-codex >/dev/null 2>&1
claude plugin list 2>&1 | grep -q "codex@openai-codex" && ok "codex plugin" || echo "[SKIP] codex plugin (optional)"

step "Extra: taste-skill plugin for Claude Code (design for websites and app screens)"
claude plugin marketplace add Leonxlnx/taste-skill >/dev/null 2>&1
claude plugin install taste-skill@taste-skill >/dev/null 2>&1
claude plugin list 2>&1 | grep -q "taste-skill" && ok "taste-skill plugin" || echo "[SKIP] taste-skill plugin (retry after logging in to Claude Code)"

step "11/11 Shared worker rules (Codex, Claude Code, opencode)"
bash "$KIT/scripts/install-rules.sh" || fail "worker rules"

step "Summary"
if [ -n "$FAILED" ]; then echo -e "FAILED:$FAILED"; else echo "ALL STEPS OK"; fi
echo
if [ "$WSL" = 1 ]; then echo "Next: close this window, then double-click '3 Log In.bat'."; else echo "Next: run '3 Log In' in mac-linux."; fi
