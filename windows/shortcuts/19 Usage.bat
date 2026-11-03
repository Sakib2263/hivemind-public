@echo off
title Usage overview
rem How much each provider and model has used, and what is left. Also refreshed after every relay job (USAGE.md).
pushd "%~dp0..\.."
echo Reading live usage from each provider: up to a minute...
wsl.exe -- bash -lic "command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1; python3 ./scripts/usage.py"
echo.
set /p A=Live Claude or Antigravity reading failed? Type them in by hand [y/N] 
if /i "%A%"=="y" wsl.exe -- bash -lic "python3 ./scripts/usage.py ask"
popd
pause
