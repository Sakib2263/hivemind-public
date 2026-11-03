@echo off
title Fix PAL
rem Run if PAL stops connecting after an update.
pushd "%~dp0..\.."
wsl.exe -- bash -lic "bash ./scripts/fix-pal.sh"
popd
pause
