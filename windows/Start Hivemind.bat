@echo off
title Start Hivemind
rem Open this before you start working: it starts the relay (so Claude can use the free workers) and the usage window.
rem Tip: right-click the usage window > "Start Hivemind with Windows" and you never have to remember it.
pushd "%~dp0.."
wsl.exe -- bash -c "h=$(cat relay/heartbeat 2>/dev/null); [ -n \"$h\" ] && [ $(( $(date +%%s) - h )) -lt 60 ]" && (echo The relay is already running.) || (start "Relay (leave open)" "%~dp0shortcuts\1 Start Relay.bat" & echo Relay started in its own window: leave it open, minimised.)
call "%~dp0shortcuts\20 Usage Overlay.bat"
echo.
echo Ready. In Claude: new chat in your Project, "+" ^> "Add folder" ^> your work folder, then type the task.
echo Updates: windows\Sync - Pull.bat now and then.
popd
timeout /t 10 >nul
