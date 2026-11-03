@echo off
rem Small always-on-top window: usage left per provider, live. Drag to move; right-click for Refresh, Start with Windows, Close.
pushd "%~dp0..\.."
wsl.exe -- bash -lic "command -v clanker-usage >/dev/null || uv tool install clanker-usage >/dev/null 2>&1; python3 ./scripts/usage.py quiet"
rem conhost: Windows 11 Terminal ignores "hidden", so use the classic console host, which honours it (no stray window)
start "" conhost.exe powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0..\..\scripts\usage-overlay.ps1"
popd
