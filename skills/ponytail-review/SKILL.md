---
name: "ponytail-review"
description: "Senior-dev code review of a change or audit of a whole repo, ranked findings in plain English; also lists shortcut: comments as a debt ledger. Report only, changes nothing."
---

# Ponytail review, audit and debt

Adapted from github.com/dietrichgebert/ponytail (MIT, (c) 2026 DietrichGebert).

Pick the mode from the request:
- **Review**: a change, a diff, a commit, a PR, or named files ("review this", "code review", "is this over-engineered").
- **Audit**: a whole repo, folder or file the user inherited ("audit this codebase", "find bloat", "what can I delete").
- **Debt**: "list the shortcuts", "what did we defer", "shortcut debt".

Review and audit work like the senior developer who will be paged when it breaks. Order of importance: correct, safe, holds under load, tested, fast, lean. Lean still matters: every extra line must be read, tested and fixed later. This is a report the user asked for, so give it in full. It changes no code.

## 1. Understand first

Review:
- Review what the user names. Nothing named: the uncommitted changes, or the last commit if there are none.
- Read the diff, then the code it touches: callers of every changed function, the functions it calls, the tests, the README.
- A change can break code it does not touch. When a signature, return value or behavior changes, grep every caller.

Audit:
- Audit what the user names. Nothing named: the whole repo.
- Read the README, the deploy and build config, the dependency list, the entry points (main, routes, handlers, jobs, CLI commands) and the tests.
- Big repo: go deep where a mistake costs the most, not file by file. Say which parts you did not read.

Both:
- Trace the real flow: where data comes in, what is stored, what goes out. Read the risky paths fully: input from users, money, auth, data writes, background jobs, anything shared between processes.
- Find the expected load: one person running a script, or many users and processes at once. Judge scale against that, and say which load you assumed.

## 2. Look for

1. **Bug:** wrong result, crash, missed edge case (empty, zero, last item, rounding, time zones), a caller broken by the change, the same rule applied differently in two places, a fix applied in one caller while the shared function stays broken.
2. **Risk:** security holes (injection, weak randomness, secrets in code, missing checks on input from users), data loss (errors swallowed, writes in the wrong order, no transaction).
3. **Scale:** fine for one user, wrong for many: check-then-write races, the same work done by every process, memory or lists that only grow, a query per item, O(n^2) on big input, per-process state that must be shared.
4. **Missing test:** risky logic (a branch, a parser, money, security, data writes, a bug fix) with no test that fails when it breaks. One good test, not coverage.
5. **Speed:** big slowdowns are problems. Small wins (work repeated in a hot loop) are suggestions; some software counts every millisecond, games included.
6. **Lean:** code that should not exist or should be smaller.
   - delete: dead code, unused options, flags and config, speculative features
   - reuse: the repo already has this helper (name the path)
   - stdlib / native: the standard library or platform already does it; a new dependency for a few lines
   - yagni: abstraction with one implementation, factory with one product, wrapper that only passes calls through
   - merge: near-copies that must change together
   - split: one function doing several unrelated jobs, so it is hard to read or test. Split by job, never by line count, and never into helpers that exist only to make a function shorter.

For games and interactive pages also check: input state that can get stuck (pointer released off-screen, pointercancel, multi-touch), objects created per frame or per level and never freed, and UI that leaves the screen on a 320px-wide phone.

## 3. Check before you report

- Every finding needs a concrete case: "this input or situation leads to this wrong result". No case, no finding.
- Re-read the lines and confirm: the caller exists, the value can really be empty, the code really is unused. Before calling code unused, grep the whole tree, including tests, fixtures, config, and string or dynamic references.
- A shortcut marked with a `shortcut:` comment that names its limit is a decision, not a finding, unless the expected load already crosses it.
- Propose the smallest fix that works. Prefer fixes that delete code. Never add layers, frameworks or config the problem does not need.
- No style taste, no "consider", no vague worries.

## 4. Output

Very simple English: short sentences, everyday words. Explain a technical term the first time you use it. The reader may never have seen this code.

Start with `What this change does:` (review) or `What this repo does:` (audit) in two or three sentences, plus the load you assumed.

Then the findings in three groups, most important first, skip empty groups:
- **Must fix:** bug, security, data loss, breaks at the expected load.
- **Should fix:** risky code without a test, real slowness, duplication, a function that mixes jobs, code that should not exist.
- **Nice to have:** small speed-ups, shorter forms.

Number findings across all groups, so the user can say "fix 2 and 5". Audit: at most 20 findings; if you left smaller ones out, say how many. Every finding has all four parts, each one or two short sentences:

2. **Orders land on the wrong day** (`billing/close_day.py:L40-52`)
   - **What this is:** At midnight this job closes the day and bills all orders of that day.
   - **Problem:** It takes "today" from the server clock, which runs in UTC. An order placed at 00:30 in Berlin is billed on the day before.
   - **Fix:** Compute the day once in the shop's time zone: `datetime.now(ZoneInfo("Europe/Berlin")).date()`. One line, nothing else changes.
   - **If we skip it:** Late orders show the wrong date, and accounting fixes them by hand.

End with:
- `Verdict: Ship.` or `Verdict: fix 1 and 3 first.` (audit: healthy, or what to fix first)
- `Lean: -<N> lines possible.` when lean findings exist (audit: also `-<M> dependencies`).
- `Not checked:` one line, if something mattered and you could not check it.

Nothing found: the opening summary, then `Looks good. Ship.` (or `Healthy. Nothing to fix.`) and one line on what you checked.

## Debt mode

Every deliberate shortcut is marked with a `shortcut:` comment naming its limit and upgrade path (older code may say `ponytail:`). Collect them so a deferral can't quietly become permanent.

Scan, skipping `node_modules`, `.git` and build output:

`grep -rnE --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build '(#|//|/[*]) ?(shortcut|ponytail):' .`

If the user names their own marker word, grep for that word instead. Skip hits that are not a deferral, like a note about a keyboard shortcut.

One row per marker, grouped by file:

`<file>:<line>, <what was simplified>. ceiling: <the limit named>. upgrade: <the trigger to revisit>.`

Any marker that names no upgrade path or trigger gets a `no-trigger` tag; those are the ones that silently rot. End with `<N> markers, <M> with no trigger.` Nothing found: `No shortcut debt. Clean ledger.` Write the ledger to a file only if the user asks.