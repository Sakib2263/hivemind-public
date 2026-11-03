# Gates

Checks a worker runs by name at the right moment. They never run on their own.
Claude sends them through the relay (`worker: gate`, `gate: build|security|release`). Code review is
`worker: review` (checklist: `review.md`). Which models run them, in order: GATE_ENGINES and REVIEW_ENGINES
in `config/models.env` (free models now; Codex first when a ChatGPT plan is added).
For a lean / over-engineering pass, Claude uses the ponytail-review skill.

| Gate | Run when | Sandbox (Codex only) |
|---|---|---|
| build | a task or feature is marked done | workspace-write (it must run the build) |
| security | code touches money, coins, IAP, ads rewards, accounts, saves, network or user data | read-only |
| release | before any store upload, Playgama publish, APK, or deploy | workspace-write |

Every gate ends with one status line:
- `PASS` checked by running it
- `PASS (STATIC ONLY)` checked by reading only, because it could not be run here. Must say what was not run and who should run it
- `FAIL` at least one check failed
- `NEEDS-REVIEW` unclear, the owner decides

Never write PASS for something that was not run.
