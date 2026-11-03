# [Project name]: rules for Claude (lead)

## Project
- What it is: [one line]
- Stack: [e.g. single HTML file + three.js / Vite / Unity]
- Target: [e.g. Playgama web, Android APK, website]
- Commands: build `[...]`  test `[...]`
- Never edit: [library files, generated files]

## How we work
Follow `ROUTING.md` in the Hivemind (task classes, relay jobs, gates, token rules).
- Open each task with: `class · lead model · workers · expected result`.
- Plan in PLAN.md and TASKS.md. Wait for the owner's approval before building.
- Send work through the relay. Check every result yourself (`.last`, then `.git`, `.diff` when reviewing).
- Run the gates by name: build when a row is done, security for money/accounts/saves/network, release before public.
- Commit with a `git-commit` job after review and gates pass.

## Before any task
- Read TASKS.md (board and Handoff). Read `graphify-out/GRAPH_REPORT.md` before exploring code.

## After any task
- Update TASKS.md: status, gate result, files, Handoff.

## Code rules
- Smallest change that fully solves the task. Reuse before writing.
- Never remove save/load, ads, IAP or validation code.

Keep this file under about 4k tokens. Project facts only; general rules live in the kit.
