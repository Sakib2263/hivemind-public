@echo off
title Install APK on phone
rem Drag an .apk onto this file. Phone: Settings, Developer options, USB debugging on; plug in by USB; tap Allow on the phone.
set "ADB=%~dp0..\..\tools\platform-tools\adb.exe"
if not exist "%ADB%" (
  echo Getting adb for Windows, once per computer...
  powershell -NoProfile -Command "New-Item -ItemType Directory -Force '%~dp0..\..\tools' | Out-Null; Invoke-WebRequest https://dl.google.com/android/repository/platform-tools-latest-windows.zip -OutFile '%~dp0..\..\tools\pt.zip'; Expand-Archive -Force '%~dp0..\..\tools\pt.zip' '%~dp0..\..\tools'; Remove-Item '%~dp0..\..\tools\pt.zip'"
)
if not exist "%ADB%" (echo adb download failed: get "SDK Platform-Tools for Windows" from developer.android.com and unzip it into hivemind\tools & pause & exit /b 1)
if not "%~1"=="" (set "APK=%~1") else (set /p "APK=APK file - drag it here or paste the path: ")
set "APK=%APK:"=%"
if not exist "%APK%" (echo File not found: %APK% & pause & exit /b 1)
"%ADB%" devices
"%ADB%" install -r "%APK%" && echo Installed. Open it on the phone.
pause
