#!/usr/bin/env bash
# Writes the shared worker rules (rules/AGENTS-floor.md) into each tool's global rules file,
# then installs the worker skills from skills/ (see skills/index.yaml).
# Only the block between the ai-setup-kit markers is replaced; anything else you wrote there stays.
# Runs from "2 Install AI Tools.bat" and after every "Sync - Pull.bat". Safe to run again.
KIT="$(cd "$(dirname "$0")/.." && pwd)"
FLOOR="$KIT/rules/AGENTS-floor.md"
[ -f "$FLOOR" ] || { echo "[FAIL] missing $FLOOR"; exit 1; }

put() {  # $1 = destination file
  mkdir -p "$(dirname "$1")"
  python3 - "$1" "$FLOOR" <<'PY'
import sys, re, os
dest, floor = sys.argv[1], sys.argv[2]
start, end = "<!-- ai-setup-kit:start -->", "<!-- ai-setup-kit:end -->"
block = start + "\n" + open(floor, encoding="utf-8").read().strip() + "\n" + end
old = open(dest, encoding="utf-8").read() if os.path.exists(dest) else ""
if start in old and end in old:
    new = re.sub(re.escape(start) + r".*?" + re.escape(end), lambda m: block, old, flags=re.S)
else:
    new = (old.rstrip() + "\n\n" if old.strip() else "") + block
new = new.rstrip() + "\n"
if new != old:
    open(dest, "w", encoding="utf-8").write(new)
    print("[OK]   rules updated:", dest)
else:
    print("[OK]   rules current:", dest)
PY
}

put "$HOME/.codex/AGENTS.md"
put "$HOME/.claude/CLAUDE.md"
put "$HOME/.config/opencode/AGENTS.md"

# Studio skills marked "workers: true" in skills/index.yaml -> ~/.agents/skills (Codex and opencode read it)
python3 "$KIT/scripts/install-skills.py"
