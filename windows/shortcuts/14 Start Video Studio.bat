@echo off
title Video Studio - ComfyUI (leave open while making videos)
set "STUDIO=%~dp0..\..\..\Video Studio"
if exist "%~dp0..\..\config\studio.env" for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0..\..\config\studio.env") do if /i "%%A"=="STUDIO_DIR" set "STUDIO=%%B"
if not exist "%STUDIO%\ComfyUI_windows_portable\ComfyUI\main.py" (
  echo Video Studio is not installed. Double-click "9 Optional - Video Studio.bat" first.
  pause & exit /b 1
)
cd /d "%STUDIO%\ComfyUI_windows_portable"
echo Open http://127.0.0.1:8188 in a browser to use it by hand. Claude and the relay use it too.
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --listen 127.0.0.1 --port 8188
pause
