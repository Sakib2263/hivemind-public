@echo off
title Optional - Move Ubuntu off the C: drive
rem Use if C: has little free space. Run after step 1, before step 2.
set /p "TARGET=Folder to move Ubuntu to (e.g. D:\WSL\Ubuntu): "
if "%TARGET%"=="" exit /b
wsl.exe --shutdown
wsl.exe --manage Ubuntu --move "%TARGET%"
echo.
echo If it says the distro was not found, run "wsl -l -v" to see its name.
pause
