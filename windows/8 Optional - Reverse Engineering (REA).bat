@echo off
title Optional - Reverse engineering tools (REA)
rem Adds REA (github.com/morluto/rea) to the Claude desktop app and to the workers in Ubuntu.
rem Use it only on software you own or are allowed to analyse. Rules: templates\ROUTING.md section 10.
pushd "%~dp0.."
where node >nul 2>&1 || (echo Node.js for Windows is needed. Installing it... & winget install --id OpenJS.NodeJS.LTS -e --source winget & echo. & echo Node.js installed. Close this window and run this file again. & pause & exit /b)
echo.
echo STEP 1: Quit the Claude desktop app fully (tray icon, Quit), so it does not overwrite the new setting.
pause
echo STEP 2: REA setup for the Claude desktop app. Review the plan it shows and approve it.
cd /d "%USERPROFILE%"
call npx.cmd -y rea-agents@6.8.0 setup --client claude_desktop
pushd "%~dp0.."
echo.
echo STEP 3: REA for the workers in Ubuntu (Claude Code, opencode, Codex if installed)...
wsl.exe -- bash -lic "bash ./scripts/install-rea.sh"
echo.
echo Done. Open the Claude app again. Ask: "Use REA to explain how <feature> works in <my own app or build>".
popd
popd
pause
