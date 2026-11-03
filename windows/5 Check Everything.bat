@echo off
title Step 5 - Check everything
pushd "%~dp0.."
wsl.exe -- bash -lic "bash ./scripts/verify.sh"
popd
pause
