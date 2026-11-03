#!/usr/bin/env bash
# Checks versions, logins, the free models and PAL, and sends a tiny "reply OK" test to each worker.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
exec > >(sed -E 's/(sk-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1***/g' | tee "$KIT/logs/verify.log") 2>&1
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
. "$KIT/config/models.env" 2>/dev/null
PAL="$HOME/pal-mcp-server"
ok_test() {  # $1 label, rest = command; prints the last line of the answer
  printf '%-15s ' "$1:"; shift
  local r; r="$(timeout 120 "$@" < /dev/null 2>&1 | tail -1)"; echo "${r:-no answer}"
}

echo "=== Versions ==="
for t in claude agy opencode graphify uv node codex clanker-usage; do printf '%-9s %s\n' "$t" "$(command -v $t >/dev/null && ($t --version 2>&1 | head -1) || echo MISSING)"; done
case "$(command -v claude)" in /home/*) echo "claude is the Linux version: good";; *) echo "WARNING: claude is not the Linux version";; esac

echo; echo "=== Logins ==="
[ -f "$HOME/.claude/.credentials.json" ] && echo "Claude: logged in" || echo "Claude: NOT logged in (run 3 Log In.bat)"
opencode auth list 2>&1 | grep -qi "opencode" && echo "opencode: logged in" || echo "opencode: NOT logged in (run 3 Log In.bat)"

echo; echo "=== Worker tests (each should say OK) ==="
ok_test "opencode free" opencode run -m "$OPENCODE_FREE_MODEL" "Reply with exactly: OK"
ok_test "opencode free2" opencode run -m "$OPENCODE_FREE2_MODEL" "Reply with exactly: OK"
ok_test "antigravity" agy -p "Reply with exactly: OK"
if codex login status >/dev/null 2>&1; then ok_test "codex" codex exec --skip-git-repo-check "Reply with exactly: OK"
else echo "codex:          off (optional, needs a paid ChatGPT plan)"; fi
echo "deepseek:       off (pay-per-use; the free DeepSeek model runs through opencode instead)"
echo "If a free model fails: run 'opencode models opencode', pick a new '-free' id, put it in config/models.env"

echo; echo "=== Android builds (optional) ==="
if [ -x "$HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "java: $(javac -version 2>&1)   sdk: $HOME/android-sdk   adb: $("$HOME/android-sdk/platform-tools/adb" version 2>/dev/null | head -1)"
  [ -f "$KIT/secrets/android/signing.env" ] && echo "release signing: set up" || echo "release signing: not set up yet (asked on the first release build)"
  [ -f "$KIT/tools/platform-tools/adb.exe" ] && echo "adb for Windows: ready" || echo "adb for Windows: missing (run 6 Optional - Android Build Tools.bat)"
else echo "not set up (only needed for Android builds: run 6 Optional - Android Build Tools.bat)"; fi

echo; echo "=== Worker rules and skills ==="
for f in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"; do
  grep -q "ai-setup-kit:start" "$f" 2>/dev/null && echo "installed: $f" || echo "MISSING: $f (run scripts/install-rules.sh)"
done
echo "worker skills: $(ls "$HOME/.agents/skills" 2>/dev/null | tr '\n' ' ')"

echo; echo "=== PAL (OpenRouter free models, optional) ==="
"$PAL/.pal_venv/bin/python" -c "import importlib.metadata as m; v=m.version('mcp'); print('mcp', v, '(ok)' if v.split('.')[0]=='1' else '(TOO NEW: run Fix PAL)')" 2>&1
claude mcp list 2>&1 | grep -E "^pal" || echo "PAL not registered (optional: run 4 Add API Keys.bat with an OpenRouter key)"
echo; echo "Log saved to logs/verify.log"
