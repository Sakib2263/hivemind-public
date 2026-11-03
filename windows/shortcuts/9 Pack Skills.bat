@echo off
title Pack skills into zips
rem Makes one zip per skill in skills-packages\<visibility>\ for uploading to claude.ai or sharing.
pushd "%~dp0..\.."
wsl.exe -- bash -lic "python3 ./scripts/pack-skills.py"
start "" "skills-packages"
popd
pause
