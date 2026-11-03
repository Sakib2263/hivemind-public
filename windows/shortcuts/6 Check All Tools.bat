@echo off
title Check all tools
pushd "%~dp0..\.."
echo Starting Ubuntu: the check begins in a few seconds...
wsl.exe -- bash -lic "bash ./scripts/verify.sh"
popd
pause
