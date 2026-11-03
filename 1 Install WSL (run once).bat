@echo off
title Step 1 - Install WSL + Ubuntu
rem Needs administrator rights: asks for them automatically.
net session >nul 2>&1 || (powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b)
echo Installing WSL2 and Ubuntu. If Ubuntu is already installed, Windows will say so.
echo.
wsl.exe --install -d Ubuntu
echo.
echo NEXT:
echo  1. Restart the PC.
echo  2. Open "Ubuntu" from the Start menu. Create a username (lowercase only) and a password.
echo  3. Close Ubuntu, then double-click "2 Install AI Tools.bat".
pause
