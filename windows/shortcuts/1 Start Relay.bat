@echo off
title Relay (leave open)
rem Lets Claude (desktop app) send jobs to Codex and Antigravity. Leave this window open.
pushd "%~dp0..\.."
echo Starting the relay in Ubuntu...
rem keeps the PC awake while jobs run, hidden, stops by itself (config\awake.env)
start "" conhost.exe powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0..\keep-awake.ps1"
wsl.exe -- bash -lic "bash ./scripts/relay.sh"
popd
echo Relay stopped.
pause
