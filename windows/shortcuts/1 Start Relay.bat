@echo off
title Relay (leave open)
rem Lets Claude (desktop app) send jobs to Codex and Antigravity. Leave this window open.
pushd "%~dp0..\.."
echo Starting the relay in Ubuntu...
wsl.exe -- bash -lic "bash ./scripts/relay.sh"
popd
echo Relay stopped.
pause
