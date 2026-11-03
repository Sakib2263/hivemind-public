@echo off
title Optional - Video Studio setup
rem Opens a setup window: pick the install folder (outside hivemind, on a drive with space) and the parts.
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\video-studio-gui.ps1"
