@echo off
title Step 7 - Connect Claude (Project instructions)
rem Writes your Claude Project instructions with YOUR work folder filled in, copies them, and opens them.
pushd "%~dp0.."
powershell -NoProfile -Command "$w=(Resolve-Path '..').Path; $t=Get-Content -Raw 'templates\claude-project-instructions.md'; $k=(Resolve-Path '.').Path; $body=(($t -split '(?m)^---\s*$')[1]).Trim() -replace '<hivemind>',$k -replace '<work folder>',$w; Set-Content -Encoding UTF8 'my-claude-instructions.txt' $body; Set-Clipboard $body; Write-Host ('Work folder: ' + $w)"
echo.
echo Your Project instructions are copied (and saved in my-claude-instructions.txt). Now in the Claude desktop app:
echo   1. Projects ^> New project (for example "AI Team")
echo   2. Open it ^> Instructions ^> paste (Ctrl+V) ^> Save
echo   3. In every new chat of that Project: "+" ^> "Add folder" ^> your work folder (shown above)
echo   4. Then just type your task. See GUIDE.md, "Starting a chat".
start "" notepad "my-claude-instructions.txt"
popd
pause
