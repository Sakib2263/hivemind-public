@echo off
title Relay (leave open)
rem Lets Claude (desktop app) send jobs to Codex and Antigravity. Leave this window open.
pushd "%~dp0..\.."
wsl.exe -- bash -lic "bash ./scripts/relay.sh"
popd
echo Relay stopped.
pause
