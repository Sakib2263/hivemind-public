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
echo "Make a free account at opencode.ai, copy your API key there, then pick 'OpenCode Zen'"
echo "below and paste the key. Add no other providers or keys (free-only setup)."
pause && opencode auth login

echo; echo "=== 4/4 Codex (only if you have a paid ChatGPT plan) - optional ==="
echo "No ChatGPT plan? Type s to skip. The free models do Codex's work until then."
if pause; then codex login || codex login --device-auth; fi

echo; echo "=== Login check ==="
[ -f "$HOME/.claude/.credentials.json" ] && echo "Claude: logged in" || echo "Claude: NOT logged in"
[ -d "$HOME/.gemini/antigravity-cli" ] && echo "Antigravity: logged in" || echo "Antigravity: check needed"
opencode auth list 2>/dev/null | grep -qi "opencode\|zen" && echo "opencode: logged in" || echo "opencode: check needed (run: opencode auth list)"
codex login status 2>/dev/null | head -1 | sed 's/^/Codex: /' || true
echo; echo "Next: double-click '4 Add API Keys.bat' (optional, for OpenRouter free models), then '5 Check Everything.bat'."
