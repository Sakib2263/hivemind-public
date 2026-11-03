#!/usr/bin/env bash
# Puts OPENCODE_API_KEY into opencode and the other API keys from secrets/keys.env into PAL and connects PAL to Claude Code and Codex.
# Started by "4 Add API Keys.bat". Run again any time you change a key.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
KEYS="$KIT/secrets/keys.env"
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
PAL="$HOME/pal-mcp-server"; PY="$PAL/.pal_venv/bin/python"
. "$KIT/scripts/progress.sh"
mask() { sed -E 's/(sk-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1***/g'; }

python3 "$KIT/scripts/providers.py" sync-template
sed -i 's/\r$//' "$KEYS"
python3 "$KIT/scripts/providers.py" opencode-auth   # OPENCODE_API_KEY and NVIDIA_API_KEY go to opencode itself, not to PAL
mapfile -t PAIRS < <(grep -E '^[A-Z_]+_API_KEY=.+' "$KEYS" | grep -vE '^(OPENCODE|NVIDIA)_API_KEY=')
if [ ${#PAIRS[@]} -eq 0 ]; then echo "No PAL keys filled in (OpenRouter, Gemini, ...): PAL left as it is."; echo; python3 "$KIT/scripts/providers.py" status; exit 0; fi
[ -x "$PY" ] || { echo "[FAIL] PAL is not installed. Run '2 Install AI Tools.bat' first."; exit 1; }

cp "$PAL/.env.example" "$PAL/.env"
sed -i -E 's/^([A-Z_]*API_KEY=)/# \1/; s/^(CUSTOM_API_URL=)/# \1/' "$PAL/.env"
printf '%s\n' "${PAIRS[@]}" >> "$PAL/.env"; chmod 600 "$PAL/.env"
echo "[OK]   PAL .env updated with: $(printf '%s\n' "${PAIRS[@]}" | cut -d= -f1 | tr '\n' ' ')"

CENV=(); XENV=(); for p in "${PAIRS[@]}"; do CENV+=(-e "$p"); XENV+=(--env "$p"); done
busy "removing the old PAL entry from Claude Code" claude mcp remove pal -s user
busy "adding PAL to Claude Code" claude mcp add pal -s user "${CENV[@]}" -- "$PY" "$PAL/server.py" && echo "[OK]   PAL added to Claude Code"
if command -v codex >/dev/null; then
  busy "removing the old PAL entry from Codex" codex mcp remove pal
  busy "adding PAL to Codex" codex mcp add pal "${XENV[@]}" -- "$PY" "$PAL/server.py" && echo "[OK]   PAL added to Codex"
fi

echo; busy "checking PAL's connection" claude mcp list; grep -E "^pal" "$BUSY_OUT" | mask
if grep -q '^OPENROUTER_API_KEY=' "$KEYS"; then
  K="$(grep -E '^OPENROUTER_API_KEY=' "$KEYS" | cut -d= -f2-)"
  echo; echo "OpenRouter key check:"; curl -s --max-time 20 https://openrouter.ai/api/v1/key -H "Authorization: Bearer $K" | grep -oE '"(limit_remaining|is_free_tier|usage)":[^,]*' | tr '\n' ' '; echo
fi
echo; python3 "$KIT/scripts/providers.py" status
echo; echo "Next: double-click '5 Check Everything.bat'."
