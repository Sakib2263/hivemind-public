@echo off
title Step 3 - Log in to Claude, Antigravity, opencode (and Codex if you have it)
pushd "%~dp0"
wsl.exe -- bash -lic "bash ./scripts/login.sh"
popd
pause
