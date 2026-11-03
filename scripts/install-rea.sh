#!/usr/bin/env bash
# Installs REA (Reverse Engineer Anything, github.com/morluto/rea, MIT) for the workers inside Ubuntu:
# its MCP server + workflow skill for Claude Code and opencode (and Codex if installed).
# Started by "8 Optional - Reverse Engineering (REA).bat". Safe to run again. Version is pinned on purpose:
# change REA_VERSION after reading the release notes.
REA_VERSION="6.8.0"
KIT="$(cd "$(dirname "$0")/.." && pwd)"
exec > >(tee "$KIT/logs/install-rea.log") 2>&1
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
command -v npx >/dev/null || { echo "[FAIL] Node is missing: run '2 Install AI Tools.bat' first"; exit 1; }
command -v ps >/dev/null || sudo apt-get install -y procps   # REA needs ps for process checks on Linux
CLIENTS=(--client claude_code --client opencode)
command -v codex >/dev/null && CLIENTS+=(--client codex)
echo "=== REA $REA_VERSION for: ${CLIENTS[*]//--client /}"
cd "$HOME" || exit 1   # run the package from a trusted folder, never inside a project being analysed
npx -y "rea-agents@$REA_VERSION" setup --yes "${CLIENTS[@]}" --json > "$KIT/logs/rea-setup.json" \
  && echo "[OK]   REA registered (details: logs/rea-setup.json). Restart open agents." \
  || echo "[FAIL] REA setup: see logs/rea-setup.json"
echo
echo "Native-binary analysis (Ghidra / Hopper / IDA) is optional and not installed here."
echo "JavaScript, Electron, web and many package formats work without it. See rea.tools/guides."
