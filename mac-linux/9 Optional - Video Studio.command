#!/usr/bin/env bash
# Optional: links your own ComfyUI install to Hivemind (the one-click installer is Windows only for now).
cd "$(dirname "$0")" && ARG1="$1" && . ./_env.sh
echo "On Mac/Linux, install ComfyUI yourself first: https://github.com/comfyanonymous/ComfyUI (Linux + NVIDIA, or Apple Silicon)."
echo "Then give the folder that CONTAINS the ComfyUI folder. Models: put FLUX schnell and Wan 2.2 5B in ComfyUI/models."
D="$(ask_path "Folder that contains ComfyUI")"
[ -f "$D/ComfyUI/main.py" ] || { echo "No ComfyUI/main.py in $D"; pause_end; exit 1; }
echo "STUDIO_DIR=\"$D\"" > config/studio.env && echo "Saved in config/studio.env. Start it with shortcuts/14 Start Video Studio."
pause_end
