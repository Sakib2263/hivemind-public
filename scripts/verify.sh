#!/usr/bin/env bash
# Checks versions, logins, the free models and PAL, and sends a tiny "reply OK" test to each worker.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
exec > >(sed -u -E 's/(sk-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1***/g' | tee "$KIT/logs/verify.log") 2>&1   # -u: show each line at once
. "$KIT/scripts/progress.sh"
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
. "$KIT/config/models.env" 2>/dev/null
PAL="$HOME/pal-mcp-server"
ok_test() {  # $1 label, rest = command; prints the last line of the answer and the time it took
  local l="$1"; shift
  busy "$l: asking the model (up to 2 min)" timeout 120 "$@"
  local r; r="$(tail -1 "$BUSY_OUT")"; printf '%-15s %s (%ss)\n' "$l:" "${r:-no answer}" "$BUSY_SECS"
}

echo "Checking every tool and model. This takes about 2 to 6 minutes: each step shows a live timer."
echo; echo "=== 1/6 Versions ==="
for t in claude agy opencode graphify uv node codex clanker-usage; do
  if command -v $t >/dev/null; then busy "$t" $t --version; v="$(head -1 "$BUSY_OUT")"; else v=MISSING; fi
  printf '%-14s %s\n' "$t" "$v"
done
case "$(command -v claude)" in /home/*) echo "claude is the Linux version: good";; *) echo "WARNING: claude is not the Linux version";; esac

echo; echo "=== 2/6 Logins and keys ==="
python3 "$KIT/scripts/providers.py" status

echo; echo "=== 3/6 Worker tests (each should say OK) ==="
ok_test "opencode free" opencode run -m "$OPENCODE_FREE_MODEL" "Reply with exactly: OK"
ok_test "opencode free2" opencode run -m "$OPENCODE_FREE2_MODEL" "Reply with exactly: OK"
ok_test "antigravity" agy -p "Reply with exactly: OK"
if grep -q '^NVIDIA_API_KEY=.' "$KIT/secrets/keys.env" 2>/dev/null; then
  busy "NVIDIA: checking the model list" python3 "$KIT/scripts/providers.py" nvidia-check; cat "$BUSY_OUT"
  ok_test "nvidia nv" opencode run -m "$NVIDIA_MODEL" "Reply with exactly: OK"
  ok_test "nvidia nv2" opencode run -m "$NVIDIA_MODEL2" "Reply with exactly: OK"
else echo "nvidia:         off (optional, free key at build.nvidia.com)"; fi
if codex login status >/dev/null 2>&1; then ok_test "codex" codex exec --skip-git-repo-check "Reply with exactly: OK"
else echo "codex:          off (optional, any ChatGPT login)"; fi
echo "deepseek:       off (pay-per-use; the free DeepSeek model runs through opencode instead)"
echo "If a free model fails: run 'opencode models opencode', pick a new '-free' id, put it in config/models.env"

echo; echo "=== 4/6 Android builds (optional) ==="
if [ -x "$HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "java: $(javac -version 2>&1)   sdk: $HOME/android-sdk   adb: $("$HOME/android-sdk/platform-tools/adb" version 2>/dev/null | head -1)"
  [ -f "$KIT/secrets/android/signing.env" ] && echo "release signing: set up" || echo "release signing: not set up yet (asked on the first release build)"
  if grep -qi microsoft /proc/version 2>/dev/null; then
  [ -f "$KIT/tools/platform-tools/adb.exe" ] && echo "adb for Windows: ready" || echo "adb for Windows: missing (run 6 Optional - Android Build Tools.bat)"
  else command -v adb >/dev/null || [ -x "$HOME/android-sdk/platform-tools/adb" ] && echo "adb: ready" || echo "adb: missing (run 6 Optional - Android Build Tools)"; fi
else echo "not set up (only needed for Android builds: run 6 Optional - Android Build Tools.bat)"; fi

echo; echo "=== 5/6 Worker rules and skills ==="
for f in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"; do
  grep -q "ai-setup-kit:start" "$f" 2>/dev/null && echo "installed: $f" || echo "MISSING: $f (run scripts/install-rules.sh)"
done
echo "worker skills: $(ls "$HOME/.agents/skills" 2>/dev/null | tr '\n' ' ')"

echo; echo "=== 6/6 PAL (OpenRouter free models, optional) ==="
"$PAL/.pal_venv/bin/python" -c "import importlib.metadata as m; v=m.version('mcp'); print('mcp', v, '(ok)' if v.split('.')[0]=='1' else '(TOO NEW: run Fix PAL)')" 2>&1
busy "checking Claude Code's connections" claude mcp list
grep -E "^pal" "$BUSY_OUT" || echo "PAL not registered (optional: run 4 Add API Keys.bat with an OpenRouter key)"
echo; echo "Done. Log saved to logs/verify.log"
