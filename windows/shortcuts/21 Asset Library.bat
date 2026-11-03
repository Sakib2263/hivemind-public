@echo off
title Asset Library
rem Drag zips or folders onto this file to add them to the shared asset library (Games\_Assets).
rem Double-click: files every zip lying in the Games folder, then lists the library.
pushd "%~dp0..\.."
if not "%~1"=="" goto loop
echo Filing every zip in the Games folder...
wsl.exe -- bash -lic "python3 ./scripts/assets.py scan ../Games && python3 ./scripts/assets.py list"
goto done
:loop
if "%~1"=="" goto done
echo Adding %~nx1 ...
wsl.exe -- bash -lic "python3 ./scripts/assets.py add \"$(wslpath -u '%~1')\""
shift
goto loop
:done
popd
echo.
echo Index: Games\_Assets\INDEX.md
pause
