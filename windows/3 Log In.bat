@echo off
title Step 3 - Log in to Claude, Antigravity, opencode (and Codex if you have it)
pushd "%~dp0.."
echo Starting Ubuntu...
wsl.exe -- bash -lic "bash ./scripts/login.sh"
popd
pause
