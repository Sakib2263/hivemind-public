#!/usr/bin/env bash
# Puts the API keys from secrets/keys.env into PAL and connects PAL to Claude Code and Codex.
# Started by "4 Add API Keys.bat". Run again any time you change a key.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
KEYS="$KIT/secrets/keys.env"
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
PAL="$HOME/pal-mcp-server"; PY="$PAL/.pal_venv/bin/python"
mask() { sed -E 's/(sk-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1***/g'; }

sed -i 's/\r$//' "$KEYS"
mapfile -t PAIRS < <(grep -E '^[A-Z_]+_API_KEY=.+' "$KEYS")
if [ ${#PAIRS[@]} -eq 0 ]; then echo "No keys filled in secrets/keys.env. Nothing to do."; exit 0; fi
[ -x "$PY" ] || { echo "[FAIL] PAL is not installed. Run '2 Install AI Tools.bat' first."; exit 1; }

cp "$PAL/.env.example" "$PAL/.env"
sed -i -E 's/^([A-Z_]*API_KEY=)/# \1/; s/^(CUSTOM_API_URL=)/# \1/' "$PAL/.env"
printf '%s\n' "${PAIRS[@]}" >> "$PAL/.env"; chmod 600 "$PAL/.env"
echo "[OK]   PAL .env updated with: $(printf '%s\n' "${PAIRS[@]}" | cut -d= -f1 | tr '\n' ' ')"

CENV=(); XENV=(); for p in "${PAIRS[@]}"; do CENV+=(-e "$p"); XENV+=(--env "$p"); done
claude mcp remove pal -s user >/dev/null 2>&1
claude mcp add pal -s user "${CENV[@]}" -- "$PY" "$PAL/server.py" >/dev/null && echo "[OK]   PAL added to Claude Code"
codex mcp remove pal >/dev/null 2>&1
codex mcp add pal "${XENV[@]}" -- "$PY" "$PAL/server.py" >/dev/null && echo "[OK]   PAL added to Codex"

echo; claude mcp list 2>&1 | grep -E "^pal" | mask
if grep -q '^OPENROUTER_API_KEY=' "$KEYS"; then
  K="$(grep -E '^OPENROUTER_API_KEY=' "$KEYS" | cut -d= -f2-)"
  echo; echo "OpenRouter key check:"; curl -s https://openrouter.ai/api/v1/key -H "Authorization: Bearer $K" | grep -oE '"(limit_remaining|is_free_tier|usage)":[^,]*' | tr '\n' ' '; echo
fi
echo; echo "Next: double-click '5 Check Everything.bat'."
