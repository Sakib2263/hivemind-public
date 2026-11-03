# Playtest Analysis Protocol
## reference: playtest-analysis.md

---

## HOW TO ANALYZE PLAYTEST DATA

When the user pastes KPI numbers, retention curves, or level metrics, apply this framework:

### STEP 1 — KPI STATUS CHECK

```
For each metric, mark: ✅ PASSING / ⚠️ AT RISK / ❌ FAILING

CPI: Target ≤ $2.00
  ✅ < $1.50 | ⚠️ $1.50–$2.50 | ❌ > $2.50
D1 Retention: Target > 40%
  ✅ > 45% | ⚠️ 35–45% | ❌ < 35%
D7 Retention: Target > 20%
  ✅ > 22% | ⚠️ 15–22% | ❌ < 15%
D30 Retention: Target > 20%
  ✅ > 22% | ⚠️ 15–22% | ❌ < 15%
D0 Playtime: Target 2,700–3,600 sec
  ✅ In range | ⚠️ 2,000–2,700 | ❌ < 2,000
```

### STEP 2 — CHURN LOCATION ANALYSIS

Map churn against level numbers:
- **D0 churn at Level 1–3:** FTUE failure. Level 1 doesn't teach correctly.
- **D0 churn at Level 5–7:** Hard level spike. APS too high (> 3.5). Reduce complexity.
- **D1 churn:** Session too short. Check D0 playtime < 2,700 sec.
- **D7 churn:** Mechanic depth insufficient. Check new mechanics post-Level 10.

### STEP 3 — LEVEL FIX RECOMMENDATIONS FORMAT

Never say "adjust difficulty." Give exact changes:

```
LEVEL [N] FIX:
Current state: [APS = X, churn = Y%]
Problem: [specific description]
Fix: [exact change — column/row/item numbers]
Expected APS after fix: [target]
```

### STEP 4 — KPI IMPROVEMENT ACTIONS

| Failing KPI | Likely Root Cause | Primary Fix |
|---|---|---|
| CPI too high | Visual hook not compelling | Iterate ad creative (different hook type) |
| D1 low | FTUE confusion | Redesign Level 1 (fewer items, fewer types) |
| D7 low | Mechanic shallow | Introduce new blocker at Level 12 |
| D30 low | No long-term goal | Add meta-loop (collection/decoration) |
| D0 playtime low | Levels too short | Increase board density from Level 10 |
| APS too high (> 4) | Level unfair | Add accessibility cue for first move |
| APS too low on hard levels | Level too easy | Add one more blocker |
