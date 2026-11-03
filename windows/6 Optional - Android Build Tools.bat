@echo off
title Optional - Android build tools (Java, Android SDK, adb)
rem Needed only to build Android apps. Downloads about 1-2 GB. Safe to run again.
pushd "%~dp0.."
echo Starting Ubuntu...
wsl.exe -- bash -lic "bash ./scripts/android-setup.sh"
echo.
echo Getting adb for Windows (installs APKs on a phone over USB)...
if not exist "tools\platform-tools\adb.exe" powershell -NoProfile -Command "New-Item -ItemType Directory -Force tools | Out-Null; Invoke-WebRequest https://dl.google.com/android/repository/platform-tools-latest-windows.zip -OutFile tools\pt.zip; Expand-Archive -Force tools\pt.zip tools; Remove-Item tools\pt.zip"
if exist "tools\platform-tools\adb.exe" (echo adb ready: tools\platform-tools\adb.exe) else (echo adb download failed: get "SDK Platform-Tools for Windows" from developer.android.com and unzip it into the tools folder)
popd
pause
