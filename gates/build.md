# Gate: build

You are checking someone else's work. Do not fix anything. Report only.

1. Read the "Done when" lines in the task below (or TASKS.md for this task). Check only those, nothing extra.
2. First say in one line what you CAN run here (node, npm, python, headless browser...) and what you CANNOT
   (Unity, Android SDK, real device, Xcode).
3. Run the project's build command from BUILD.md, CLAUDE.md or package.json. Then its tests, if any.
4. Check each "Done when" line by running something. If it can't be run here, mark it STATIC ONLY and say why.
5. Quick scan of changed files (git diff --stat, then only the changed parts): debug code left in
   (console.log spam, debugger, test cheats, unlocked-everything flags), hardcoded keys, broken imports.

Output, short:
- Can run / cannot run: one line each
- Build: PASS or FAIL (with the first error line, file:line)
- Each "Done when" line: PASS / STATIC ONLY / FAIL, one line each
- Last line: `GATE build: PASS | PASS (STATIC ONLY) | FAIL | NEEDS-REVIEW`
