@echo off
title Sync - send your Hivemind changes to GitHub
rem Saves your changes and uploads them to your private repo. The first time, it also links this folder.
rem Needs Git for Windows (git-scm.com). The first upload opens a GitHub sign-in window in your browser.
set "REPO=https://github.com/YOUR_GITHUB_USER/hivemind.git"
pushd "%~dp0"
where git >nul 2>&1 || (echo Git is not installed. Get it from https://git-scm.com/download/win & pause & exit /b 1)
if not exist ".git" (
  echo First upload from this PC: linking this folder to GitHub...
  git init -q -b main
  git remote add origin "%REPO%"
)
git config user.name >nul 2>&1 || git config user.name "YOUR_GITHUB_USER"
git config user.email >nul 2>&1 || git config user.email "you@example.com"
git status --short
set "MSG="
set /p "MSG=Describe the change (Enter = 'update Hivemind'): "
if "%MSG%"=="" set "MSG=update Hivemind"
git add -A
git commit -m "%MSG%" || echo Nothing new to save.
git ls-remote --exit-code --heads origin main >nul 2>&1 && (git pull --rebase origin main || (echo Pull failed. Ask Claude to help. & pause & exit /b 1))
git push -u origin main || (echo Upload failed. Check the sign-in window, then try again. & pause & exit /b 1)
echo.
echo Uploaded. On your other PC, run "Sync - Pull.bat".
git log --oneline -3
popd
pause
