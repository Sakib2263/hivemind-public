#!/usr/bin/env bash
# Starts your ComfyUI (linked with 9 Optional - Video Studio). Leave it open while making videos.
cd "$(dirname "$0")" && ARG1="$1" && . ../_env.sh
STUDIO_DIR=""; [ -f config/studio.env ] && . config/studio.env
[ -f "$STUDIO_DIR/ComfyUI/main.py" ] || { echo "Video Studio is not linked. Run 9 Optional - Video Studio first."; pause_end; exit 1; }
cd "$STUDIO_DIR/ComfyUI"
PY=python3; for v in venv .venv ../venv; do [ -x "$v/bin/python" ] && PY="$v/bin/python" && break; done
echo "Open http://127.0.0.1:8188 to use it by hand. Claude and the relay use it too."
"$PY" main.py --listen 127.0.0.1 --port 8188
pause_end
