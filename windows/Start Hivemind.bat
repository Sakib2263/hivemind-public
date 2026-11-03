@echo off
title Start Hivemind
rem Open this before you start working: it starts the relay (so Claude can use the free workers) and the usage window.
rem Tip: right-click the usage window > "Start Hivemind with Windows" and you never have to remember it.
pushd "%~dp0.."
echo Starting Hivemind: checking the relay...
wsl.exe -- bash -c "h=$(cat relay/heartbeat 2>/dev/null); [ -n \"$h\" ] && [ $(( $(date +%%s) - h )) -lt 60 ]" && (echo The relay is already running.) || (start "Relay (leave open)" "%~dp0shortcuts\1 Start Relay.bat" & echo Relay started in its own window: leave it open, minimised.)
call "%~dp0shortcuts\20 Usage Overlay.bat"
echo.
rem which workers are connected; a missing one is listed with how to add it
echo Checking which workers are connected...
wsl.exe -e python3 ./scripts/providers.py status
set MISSING=%errorlevel%
echo.
echo Ready. In Claude: new chat in your Project, "+" ^> "Add folder" ^> your work folder, then type the task.
echo Updates: windows\Sync - Pull.bat now and then.
popd
if "%MISSING%"=="0" (timeout /t 15 >nul) else (echo. & echo A needed worker is missing: see above. & pause)
