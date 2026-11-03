@echo off
title New project (web or Unity, new / existing / reskin)
rem Asks engine, start type, targets, publisher and size, then creates or prepares the project folder.
pushd "%~dp0.."
wsl.exe -- bash -lic "bash ./scripts/new-project.sh"
popd
pause
