@echo off
rem Tells a running autopilot to stop after the current step.
type nul > "%~dp0..\..\relay\AUTOPILOT.stop"
echo Autopilot will stop after its current step. Close its window to stop right away.
timeout /t 5 >nul
