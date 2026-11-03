@echo off
title Music Studio - ACE-Step 1.5
set "STUDIO=%~dp0..\..\Video Studio"
if exist "%~dp0..\config\studio.env" for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0..\config\studio.env") do if /i "%%A"=="STUDIO_DIR" set "STUDIO=%%B"
for /d %%D in ("%STUDIO%\ACE-Step*") do (
  if exist "%%D\start_gradio_ui.bat" ( cd /d "%%D" & call start_gradio_ui.bat & exit /b )
)
echo ACE-Step is not installed. Run "9 Optional - Video Studio.bat" and answer Y to music.
pause
