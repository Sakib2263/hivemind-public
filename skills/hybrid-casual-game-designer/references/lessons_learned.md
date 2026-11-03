# Lessons Learned Log
## Self-Improvement Record for hybrid-casual-game-designer skill
## Appended automatically after each task via Section 9 protocol

---

## HOW THIS FILE WORKS
After every completed task, the skill appends a log entry here documenting
what worked, what failed, and what rule changes should apply going forward.
When 3+ entries point to the same pattern, the relevant SKILL.md section
is updated and the version number is bumped.

---

## KNOWN FAILURE PATTERNS (seed entries from initial skill creation)

### Pattern 001 — Vague core action descriptions
Observed: When asked to describe a core loop, output used language like
"players strategically interact with the board to achieve their goals"
Root cause: Section 4 loop validator not being applied strictly enough
Fix applied: Added "Test: Can you draw this loop on a napkin in 30 seconds?"
             as a hard quality gate in Section 4
Status: Fixed in v2.0

### Pattern 002 — Missing fail state specificity
Observed: Fail conditions described as "tray fills up and game ends"
without specifying the exact trigger condition (full + no valid route)
Root cause: Win/fail checklist items not granular enough
Fix applied: Added exact trigger specification requirement in Section 4
             win/fail checklist
Status: Fixed in v2.0

### Pattern 003 — Booster plans that break core tension
Observed: Booster designs that let players skip the core puzzle entirely
(e.g., "clear all items of one type instantly" on a sort game)
Root cause: No explicit booster-mechanic compatibility test
Fix applied: Added Booster-Mechanic Compatibility Test in Section 6
             with "worst possible moment" evaluation requirement
Status: Fixed in v2.0

### Pattern 004 — Level 1 complexity
Observed: Level 1 designs introducing 2 mechanics simultaneously
Root cause: Designer wanting to "teach more faster"
Fix applied: Silent Tutorial Standard in Section 5 explicitly states
             "ONE action. Zero text. Zero arrows." for Level 1
Status: Fixed in v2.0

### Pattern 005 — Sara theme violations in initial concepts
Observed: Concepts generated with sci-fi or abstract themes before
Sara filter was applied
Root cause: Theme generation happening before persona filter applied
Fix applied: Pre-Ideation Checklist in Section 3 requires Sara persona
             check BEFORE concept generation begins
Status: Fixed in v2.0

---

## ACTIVE LOG ENTRIES
(New entries appended here after each task)

[Entries will be added automatically after each completed task]

---

## IMPROVEMENT TRIGGERS
When 3+ log entries share the same root cause, update the skill:

| Pattern | Count | Threshold | Action Required |
|---------|-------|-----------|-----------------|
| (none yet — awaiting real task logs) | 0 | 3 | — |
