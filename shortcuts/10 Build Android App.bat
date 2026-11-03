@echo off
title Build Android app
rem Drag a project folder onto this file. It asks for anything missing (name, bundle id, icon), shows it for a yes, then builds.
if not "%~1"=="" (set "DIR=%~1") else (set /p "DIR=Project folder - drag it here or paste the path: ")
set "DIR=%DIR:"=%"
if not exist "%DIR%\" (echo Folder not found: %DIR% & pause & exit /b 1)
echo.
echo 1 = Test APK (debug, to try on a phone)
echo 2 = Release for Google Play (signed AAB + APK)
set /p "T=Choose 1 or 2: "
set "MODE=debug"
if "%T%"=="2" set "MODE=release"
pushd "%~dp0.."
wsl.exe -- bash -lic "bash ./scripts/android-build.sh \"$(wslpath '%DIR%')\" %MODE%"
popd
if exist "%DIR%\builds\android\" start "" "%DIR%\builds\android"
pause
