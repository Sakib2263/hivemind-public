@echo off
title Add my skills
rem Put your skill folders, or .skill / .zip files, into skills\inbox first. Then run this.
pushd "%~dp0..\.."
if not exist "skills\inbox" mkdir "skills\inbox"
start "" "skills\inbox"
echo Put your skills into the folder that just opened, then press a key here.
pause >nul
wsl.exe -- bash -lic "python3 ./scripts/add-skills.py"
popd
pause
