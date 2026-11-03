@echo off
title Hivemind Autopilot (close this window or run 18 Stop Autopilot to stop)
rem Drag a project folder (one with TASKS.md) onto this file. Works through the board unattended,
rem one row per fresh session, until done, blocked, out of time, or stopped.
if not "%~1"=="" (set "DIR=%~1") else (set /p "DIR=Project folder - drag it here or paste the path: ")
set "DIR=%DIR:"=%"
if not exist "%DIR%\TASKS.md" (echo No TASKS.md in: %DIR% & pause & exit /b 1)
set /p "HRS=How many hours at most? [8]: "
if "%HRS%"=="" set HRS=8
pushd "%~dp0.."
wsl.exe -- bash -lic "bash ./scripts/autopilot.sh \"$(wslpath '%DIR%')\" %HRS%"
popd
pause
