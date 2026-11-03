@echo off
title Codex - continue from handoff
rem Use when Claude is out of quota. Drag a project folder onto this file.
if not "%~1"=="" (set "DIR=%~1") else (set /p "DIR=Project folder - drag it here or paste the path: ")
set "DIR=%DIR:"=%"
if "%DIR%"=="" (echo No folder given. & pause & exit /b 1)
if not exist "%DIR%\" (echo Folder not found: %DIR% & pause & exit /b 1)
wsl.exe --cd "%DIR%" -- bash -lic "codex \"Claude is out of quota, so you lead for now. Read AGENTS.md and TASKS.md, continue from the Handoff section, run the build and tests, then update the TASKS.md Handoff. You may commit finished, checked work.\""
pause
