@echo off
title Check all tools
pushd "%~dp0.."
wsl.exe -- bash -lic "bash ./scripts/verify.sh"
popd
pause
