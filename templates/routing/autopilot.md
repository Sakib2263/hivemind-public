# Autopilot (unattended runs)

`scripts/autopilot.sh` (shortcut 17) runs one TASKS.md row per fresh headless session and ends each with a
status line: `AUTOPILOT: CONTINUE`, `ALL DONE`, `NEEDS OWNER <question>` or `BLOCKED <reason>`. In an autopilot
step: never ask the owner, skip rows that need them, keep the Handoff current, commit tested work locally only.
