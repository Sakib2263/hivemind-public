@echo off
title Continue handoff with a free model (opencode)
rem Use when Claude is out of quota. Drag a project folder onto this file.
if not "%~1"=="" (set "DIR=%~1") else (set /p "DIR=Project folder - drag it here or paste the path: ")
set "DIR=%DIR:"=%"
if "%DIR%"=="" (echo No folder given. & pause & exit /b 1)
if not exist "%DIR%\" (echo Folder not found: %DIR% & pause & exit /b 1)
pushd "%~dp0..\.."
wsl.exe -- bash -lic "bash ./scripts/handoff.sh \"$(wslpath '%DIR%')\""
popd
pause
