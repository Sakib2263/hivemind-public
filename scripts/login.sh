#!/usr/bin/env bash
# Logs in to each AI tool, one after another. Started by "3 Log In.bat".
# Ubuntu cannot open your browser: copy each link it shows into your browser and approve.
# Skip any tool you don't have an account for: press Ctrl+C at its step, then run this again later.
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
pause() { echo; read -r -p "Press Enter to continue (or type s and Enter to skip): " a; [ "$a" != "s" ]; }

echo "=== 1/4 Claude (your Claude Pro or Max plan) - needed ==="
echo "Choose 'Claude account with subscription', open the link in your browser, approve,"
echo "paste the code back if asked. When you see the chat box, type /exit"
pause && claude

echo; echo "=== 2/4 Antigravity (your Google account, free tier works) - needed ==="
echo "Open the link, sign in, paste the code back. Then type /quit (or press Ctrl+C)."
pause && agy

echo; echo "=== 3/4 opencode (free models through OpenCode Zen) - needed ==="
KIT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Make a free account at opencode.ai and copy your API key there (opencode.ai > API keys)."
echo "Paste it below: right-click pastes in a Windows console (Ctrl+V may not). Nothing shows while you paste;"
echo "after Enter you see how many characters were saved. Already set and want to keep it? Type s to skip."
if pause; then
  python3 "$KIT/scripts/providers.py" set OPENCODE_API_KEY && python3 "$KIT/scripts/providers.py" opencode-auth \
    || { echo "Or use opencode's own login: pick 'OpenCode Zen' and paste the key."; opencode auth login; }
fi

echo; echo "=== 4/4 Codex (any ChatGPT login, free works) - optional ==="
echo "No ChatGPT account? Type s to skip. The free models do Codex's work until then."
if pause; then codex login || codex login --device-auth; fi

echo
python3 "$KIT/scripts/providers.py" status
echo; echo "Next: double-click '4 Add API Keys.bat' (optional, for OpenRouter free models), then '5 Check Everything.bat'."
