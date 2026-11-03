#!/usr/bin/env bash
# Step 7: makes your Claude Project instructions with this computer's folders, copies them and opens them.
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
python3 - "$HM" "$OS" <<'PY'
import os, re, sys
hm, osname = sys.argv[1], sys.argv[2]
t = open(os.path.join(hm, "templates", "claude-project-instructions.md"), encoding="utf-8").read()
body = re.split(r"(?m)^---\s*$", t)[1].strip()
body = body.replace("<hivemind>", hm).replace("<work folder>", os.path.dirname(hm)).replace("\\", "/")
body = body.replace("shortcuts/1 Start Relay.bat", "mac-linux/shortcuts/1 Start Relay.command")
system = "macOS" if osname == "Darwin" else "Linux"
body += f"\nThis computer: {system}. Shortcuts are in mac-linux/ and mac-linux/shortcuts/ (.command, same numbers as the\nWindows .bat names in the rules). Relay job dir: the normal path, e.g. {os.path.dirname(hm)}/My Game."
open(os.path.join(hm, "my-claude-instructions.txt"), "w", encoding="utf-8").write(body + "\n")
print("Work folder:", os.path.dirname(hm))
PY
for c in pbcopy wl-copy "xclip -selection clipboard"; do command -v ${c%% *} >/dev/null && $c < my-claude-instructions.txt && echo "Copied to the clipboard." && break; done
echo
echo "Your Project instructions are saved in my-claude-instructions.txt. In the Claude desktop app:"
echo "  1. Projects > New project (for example \"AI Team\")"
echo "  2. Open it > Instructions > paste > Save"
echo "  3. In every new chat of that Project: \"+\" > \"Add folder\" > your work folder (shown above)"
if [ "$OS" != Darwin ]; then   # no Claude desktop app on Linux: Claude Code leads, and reads CLAUDE.md in the work folder
  W="$(dirname "$HM")"
  if [ -f "$W/CLAUDE.md" ]; then echo "Linux: $W/CLAUDE.md already exists; add the instructions to it yourself if needed."
  else cp my-claude-instructions.txt "$W/CLAUDE.md" && echo "Linux: saved as $W/CLAUDE.md. Start Claude Code in $W (cd \"$W\" && claude) and it reads them."; fi
fi
open_path my-claude-instructions.txt
pause_end
