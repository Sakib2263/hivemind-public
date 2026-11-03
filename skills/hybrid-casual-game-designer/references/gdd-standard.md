# GDD Standard — Supersonic 4-Element Format
## reference: gdd-standard.md

---

## 10-CHAPTER GDD STRUCTURE

Every GDD for Supersonic PPP must contain these chapters in this order.
Flag gaps with: `[NEEDS DESIGN DECISION: X]`
Never use placeholder text — write real content or ask.

### CH1 — EXECUTIVE SUMMARY
- Elevator pitch (2 sentences)
- Genre / Platform / Publisher target  
- Three differentiators vs. existing top-20 games
- Player promise: "After Level 1, Sara should feel ___"
- DREAM BIG: Can this exceed 20% D30 after 1 year?

### CH2 — CORE MECHANIC
- Primary action: [Verb] [Object] [Direction/Destination]
- Input type: Tap / Drag / 2-Step Tap
- Movement rules (exact — no vague language)
- Accessibility rule
- The relief moment (exact payoff animation)

### CH3 — WIN & FAIL CONDITIONS
- Win: [Exact board state]
- Fail Primary: TRAY SLOT FULL [exact trigger]
- Fail Secondary: NO AVAILABLE MOVES [exact trigger]
- Preferred fail type and reason
- Fail warning system

### CH4 — SCREEN LAYOUT (Supersonic 4-Element)
- Zone 1 Info Bar: elements and proportions
- Zone 2 Board: size %, grid dimensions
- Zone 3 Tray: slot count, danger state visual
- Zone 4 Boosters: V1 empty / V2+ specs

### CH5 — LEVEL DESIGN GUIDELINES
- Silent tutorial rules (Levels 1–10, zero text)
- Difficulty curve table
- Mechanic introduction cadence
- 20-level arc spec table

### CH6 — BLOCKERS & BOOSTERS
- V1: No boosters. RV_Slot + RV_Revive only.
- Blocker rollout: which blockers, which levels
- V2+ booster plan with compatibility checks

### CH7 — MONETIZATION
- V1 economy (400 gold start, 20/level)
- Ads: Level 14 start
- V2+ IAP offers with prices

### CH8 — ART DIRECTION
- Visual style + 3 comparable game references
- Color palette (warm pastels for Sara)
- UI: rounded corners, 48×48dp min tap targets
- Animation priority list

### CH9 — AUDIO DESIGN
- SFX for every interaction
- Priority order: snap → match/clear → tray → fail → win
- Music: lo-fi, warm, loopable

### CH10 — PRODUCTION MILESTONES
| Milestone | Target | Week |
|---|---|---|
| First Playable | Core loop functional | 2 |
| Alpha | 10 levels + FTUE | 3 |
| Beta | 20 levels + RV + ads | 4 |
| Submission | 6 CPI videos + store listing | 5 |
