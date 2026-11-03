@echo off
rem Small always-on-top window: usage left per provider, live. Drag to move; right-click for Refresh, Start with Windows, Close.
pushd "%~dp0..\.."
rem conhost: Windows 11 Terminal ignores "hidden", so use the classic console host, which honours it (no stray window)
rem The window opens at once (it says "loading..." and fills in by itself); the line below just makes sure the live reader is installed.
start "" conhost.exe powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0..\..\scripts\usage-overlay.ps1"
echo Usage window opened. Checking the usage reader is installed...
wsl.exe -- bash -lic "command -v clanker-usage >/dev/null || { echo Installing the usage reader, about a minute...; uv tool install clanker-usage >/dev/null 2>&1; }"
popd
