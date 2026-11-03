#!/usr/bin/env bash
# PAL crashes when its mcp library updates to version 2+. This pins it back and re-checks.
export PATH="$HOME/.local/bin:$PATH"; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
PAL="$HOME/pal-mcp-server"; PY="$PAL/.pal_venv/bin/python"
uv pip install --python "$PY" "mcp>=1.0,<2" 2>&1 | tail -2
"$PY" -c "import importlib.metadata as m; print('mcp now', m.version('mcp'))"
claude mcp list 2>&1 | grep -E "^pal"
