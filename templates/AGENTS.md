# [Project name]: rules for workers (Codex, DeepSeek, Antigravity, others)

General worker rules are installed globally (Hivemind `rules/AGENTS-floor.md`).
This file adds only what is specific to this project. Keep it short.

## Project
- What it is: [one line]
- Stack: [stack]
- Commands: build `[...]`  test `[...]`  run `[...]`
- Never edit: [library files, generated files, graphify-out/]
- Entry points: [main files a newcomer should open first]

## Key rules (repeated here for tools that don't load the global rules, like Antigravity)
- You are a worker. Do only the task you were given. Problems go in your final message as blockers.
- Smallest change that fully solves it. Reuse before writing. Never remove save/load, ads, IAP or validation code.
- Do not commit. Leave changes uncommitted; the lead reviews and commits.
- Read `graphify-out/GRAPH_REPORT.md` before opening source files, if it exists.
- Final message: Done / Files / Ran or Not run / Blockers. Short.

## Project notes
- [gotchas, things that broke before]
