@echo off
title Step 4 - Add API keys (optional)
rem Opens secrets\keys.env in Notepad. Paste your keys, save, close Notepad.
pushd "%~dp0.."
if not exist "secrets\keys.env" copy "secrets\keys.env.template" "secrets\keys.env" >nul
rem adds key lines that are new in the template (for example OPENCODE_API_KEY) to an older keys.env
wsl.exe -e python3 ./scripts/providers.py sync-template
echo Paste your keys after the = signs, then SAVE and CLOSE Notepad to continue.
start /wait notepad "secrets\keys.env"
wsl.exe -- bash -lic "bash ./scripts/apply-keys.sh"
popd
pause
