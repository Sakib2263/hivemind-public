# Level Design Protocol
## reference: level-design.md

---

## DIFFICULTY CURVE TARGETS

### Supersonic Standard
| Level Range | Win Rate Target | APS Target | Notes |
|---|---|---|---|
| 1–10 | ~100% | 1.0 | Silent tutorial zone — player always wins |
| 11–20 | ~90–95% | 1.0–1.5 | Mechanic reinforcement |
| 21–50 | ~80–90% | 1.5–2.0 | Gradual increase, recovery every 5 levels |
| 51–100 | ~70–80% | 2.0–3.0 | Boosters become meaningful |
| Hard levels | Target APS | 2–3 | First hard: Level 5–7 |

**Level duration target:** 5–7 minutes average.  
**Hard level duration:** Can go to 8–10 min — this is where RV_Revive earns.

### Voodoo Win Rate Curve (from Voodoo Strategy doc)
- Levels 1–10: ~100%
- Levels 11–20: 90–95%
- Levels 21+: 80–90% with breather levels every 5

---

## SILENT TUTORIAL RULES (Levels 1–10)

**The absolute rule: ZERO TEXT in levels 1–10. Zero arrows. Zero hand-holding UI.**
The level geometry IS the teacher. If you need text to explain it, the level fails.

```
LEVEL 1 REQUIREMENTS:
[ ] Teach exactly ONE action
[ ] Board has only 1–2 item types
[ ] Only 1 item is accessible at start (forces the right first tap)
[ ] That item's destination is obvious (only one valid slot)
[ ] Win in ≤ 3 taps
[ ] Celebrate generously — big win animation even for tiny level

LEVELS 2–5 REQUIREMENTS:
[ ] Reinforce the same action in slightly varied board layouts
[ ] Introduce 2nd item type at Level 3 (still very easy)
[ ] First tray use: plant 1 item in tray at start to show it exists (Level 3–4)
[ ] APS must stay ≤ 1.0 (everyone wins first try)

LEVELS 6–10 REQUIREMENTS:
[ ] Introduce the fail state for the first time (Level 6–7)
[ ] Make fail clearly the player's fault — not a trap
[ ] First tray management decision required (not just overflow)
[ ] Still very winnable — APS ≤ 1.3
[ ] Level 7: FIRST HARD LEVEL — APS target 2.0–2.5
[ ] Level 8: BREATHER — easier than Level 5
[ ] Levels 9–10: Establish full core loop rhythm
```

---

## 20-LEVEL ARC TEMPLATE

Use this structure for the Supersonic submission requirement of 20 unique levels.

```
| Level | Grid/Setup | Goal | New Mechanic | Solve Time | APS | Notes |
|---|---|---|---|---|---|---|
| 1 | [tiny board, 1 type] | [trivial] | Core tap action | 20–30s | 1.0 | Silent teach |
| 2 | [small, 2 types] | [easy] | 2nd item type | 30–45s | 1.0 | Reinforce |
| 3 | [small, 2 types] | [easy] | Tray visible | 40–60s | 1.0 | Tray introduction |
| 4 | [medium, 3 types] | [easy] | 3rd type | 60–90s | 1.0 | Tray strategy hint |
| 5 | [medium, 3 types] | [medium] | Tray management required | 90–120s | 1.3 | Rising tension |
| 6 | [medium, 3 types] | [medium] | First fail possible | 2min | 1.5 | Fail state teach |
| 7 | [medium, 4 types] | [hard] | FIRST HARD LEVEL | 3–5min | 2.5 | "One more try" installs |
| 8 | [small, 3 types] | [easy] | BREATHER | 60s | 1.0 | Recovery level |
| 9 | [medium, 4 types] | [medium] | 4th type | 2min | 1.5 | Building up again |
| 10 | [medium, 4 types] | [medium-hard] | Full loop mastery | 3min | 2.0 | Full loop established |
| 11 | [large, 4 types] | [medium] | Board size increase | 3min | 1.5 | New scale |
| 12 | [large, 4 types] | [hard] | First LOCKED item | 4min | 2.5 | Blocker teach |
| 13 | [medium, 4 types] | [easy] | BREATHER | 90s | 1.0 | Recovery |
| 14 | [large, 5 types] | [medium] | 5th type + ads start | 3min | 1.5 | AD MONETIZATION BEGINS |
| 15 | [large, 5 types] | [hard] | 2nd blocker type | 5min | 2.5 | Hard level |
| 16 | [medium, 4 types] | [easy] | BREATHER | 2min | 1.0 | Recovery |
| 17 | [large, 5 types] | [medium-hard] | Locked + direction | 4min | 2.0 | Combined challenge |
| 18 | [large, 5 types] | [hard] | Dense board | 5–7min | 3.0 | RV_Revive peak usage |
| 19 | [large, 5 types] | [medium] | BREATHER | 3min | 1.3 | Recovery |
| 20 | [large, 5 types] | [hard] | Mastery level | 5–7min | 2.5 | Satisfying climax level |
```

---

## LEVEL DESIGN CHECKLIST (Per Level)

```
[ ] Win condition is achievable in target time
[ ] Fail condition can be anticipated by player ≥ 2 moves before it triggers
[ ] No unwinnable states from legal moves (unless that IS the fail condition)
[ ] If new mechanic introduced: dedicated "teach" level before this
[ ] APS target is in the right range for this level's position
[ ] Level has at least 2 "small victory" moments before final clear
[ ] Sara emotional journey hits all 7 beats (see core-loop-design.md)
[ ] Tray cycles 3–5 times before level completes (for levels > 2 min)
[ ] Level is deterministic (same input = same output every restart)
[ ] If this is a hard level: breather level follows within 2 levels
```

---

## MECHANIC INTRODUCTION CADENCE (Post-Level 10)

Pattern: **Teach → Test → Master → Breather**

Never introduce a new mechanic AND increase board density in the same level. One challenge at a time.

```
NEW MECHANIC INTRODUCTION SCHEDULE (suggested):
Level 12: Blocker Type 1 (Locked Items)
Level 20: Blocker Type 2 (Chained Pairs or Directional)
Level 28: Blocker Type 3 (Layered/Double Items)
Level 36: Combined Blocker Puzzles
Level 45+: Complex multi-blocker combinations
```

---

## LEVEL DESIGN ANTI-PATTERNS

- **The Invisible Wall:** Player cannot figure out first move. Symptom: everyone fails Level 1. Fix: reduce item types to 1, reduce board to 3×4.
- **The Luck Level:** Player must guess randomly to find the right order. Symptom: APS > 5 but no skill improvement on retries. Fix: add visual accessibility cue or widen the valid solution set.
- **The Punishing Hard Level:** APS > 5, no recovery level after, player churns. Fix: reduce to APS 2–3, add breather immediately after.
- **The Fake Easy Level:** APS ≈ 1 but player felt no tension. Boring. Fix: add one near-tray-full moment even if it resolves easily.
- **Tutorial Creep:** New mechanic shown in level N, immediately used in level N+1 at full complexity. Fix: always have a dedicated teach level that cannot be failed.
