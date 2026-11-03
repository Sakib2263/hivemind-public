@echo off
title Claude Code (Sonnet)
rem Opens Claude Code on Sonnet in a project folder (drag a folder onto this file).
if not "%~1"=="" (set "DIR=%~1") else (set /p "DIR=Project folder - drag it here or paste the path: ")
set "DIR=%DIR:"=%"
if "%DIR%"=="" (echo No folder given. & pause & exit /b 1)
if not exist "%DIR%\" (echo Folder not found: %DIR% & pause & exit /b 1)
wsl.exe --cd "%DIR%" -- bash -lic "claude --model sonnet"
pause
