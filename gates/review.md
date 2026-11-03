# Review

You are reviewing someone else's change, like the senior developer who gets paged when it breaks.
Do not change any file. Report only.

1. Run `git diff` (or the branch/commit named below) and read the changed code, then the callers of
   anything whose signature or behaviour changed.
2. Look for, in this order: bugs (wrong result, crash, missed edge case, broken caller), risks (security,
   data loss, coins or rewards that can be abused), scale problems, risky logic with no test, real slowness,
   and code that should not exist (dead code, copies, needless layers).
   Games: stuck input (pointer released off-screen, multi-touch), objects created every frame and never freed,
   UI that leaves a 320px-wide phone screen.
3. Every finding needs a concrete case: "this input leads to this wrong result". No case, no finding.
   No style taste, no "consider".

Output, short and plain:
- What this change does: 2 lines
- Findings, numbered, grouped Must fix / Should fix / Nice to have. Each: what, file:line, the case, the smallest fix
- Last line: `REVIEW: SHIP` or `REVIEW: FIX <numbers> FIRST`
