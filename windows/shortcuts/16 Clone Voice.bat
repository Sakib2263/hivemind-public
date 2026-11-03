@echo off
title Clone Voice - Chatterbox
rem Drag a folder onto this file. The folder needs: voice.wav (10-30 s of clean speech) and lines.txt (one sentence per line).
rem Output: <folder>\vo\001.wav, 002.wav ... (one file per line, ready for the video pipeline).
set "STUDIO=%~dp0..\..\..\Video Studio"
if exist "%~dp0..\..\config\studio.env" for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0..\..\config\studio.env") do if /i "%%A"=="STUDIO_DIR" set "STUDIO=%%B"
set "PY=%STUDIO%\voice\.venv\Scripts\python.exe"
if not exist "%PY%" ( echo Voice cloning is not installed. Run "9 Optional - Video Studio.bat" and answer Y to voice. & pause & exit /b 1 )
set "DIR=%~1"
if "%DIR%"=="" set /p DIR=Folder with voice.wav and lines.txt: 
"%PY%" "%~dp0..\..\studio\voice\say.py" "%DIR%"
pause
