@echo off
title Step 2 - Install AI tools (10-20 min)
rem Installs Node, uv, Claude Code, Codex, Antigravity, graphify, PAL and the Codex plugin inside Ubuntu.
rem Stay at the window at the start: it asks for your Ubuntu password.
pushd "%~dp0.."
echo Starting Ubuntu...
wsl.exe -- bash -lic "bash ./scripts/install-tools.sh"
popd
echo.
echo Closing Ubuntu so the settings take effect...
wsl.exe --shutdown
pause
