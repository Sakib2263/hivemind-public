@echo off
title Usage overview
rem How much each provider and model has used, and what is left. Also refreshed after every relay job (USAGE.md).
pushd "%~dp0.."
wsl.exe -- bash -lic "command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1; python3 ./scripts/usage.py"
echo.
set /p A=Type in readings the scripts cannot get (Flow credits)? [y/N] 
if /i "%A%"=="y" wsl.exe -- bash -lic "python3 ./scripts/usage.py ask"
popd
pause
