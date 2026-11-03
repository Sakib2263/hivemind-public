@echo off
title Sync - get the latest Hivemind from GitHub
rem Downloads the latest kit from your private GitHub repo. Your keys (secrets\keys.env) are never touched.
rem Needs Git for Windows (git-scm.com). The first time, a GitHub sign-in window opens in your browser.
set "REPO=https://github.com/YOUR_GITHUB_USER/hivemind.git"
pushd "%~dp0.."
where git >nul 2>&1 || (echo Git is not installed. Get it from https://git-scm.com/download/win & pause & exit /b 1)
if not exist ".git" (
  echo First sync on this PC: linking this folder to GitHub...
  git init -q -b main
  git remote add origin "%REPO%"
  git fetch origin || (echo Could not reach GitHub. & pause & exit /b 1)
  git checkout -f -B main origin/main
  git branch -u origin/main >nul
) else (
  git pull --ff-only || echo Pull failed: you may have local changes. Run "Sync - Push.bat" first.
)
echo Updating the worker rules inside Ubuntu...
wsl.exe -- bash -lic "bash ./scripts/install-rules.sh" || echo Ubuntu is not set up yet on this PC: rules skipped.
git log --oneline -3
popd
pause
