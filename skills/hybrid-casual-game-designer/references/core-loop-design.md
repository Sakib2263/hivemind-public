# Core Loop Design Protocol
## reference: core-loop-design.md

---

## WHAT IS A CORE LOOP?

A core loop is the repeating 3–6 step sequence that a player executes every 4–8 seconds for the entire session. It must:
- Be learnable in 3 seconds without text
- Create genuine tension followed by genuine relief
- Be repeatable for 45–60 minutes without becoming boring
- Have a fail state that is always the player's fault (never random)

**The Loop Skeleton (All Jam/Sort/Conveyor Games):**
```
[CROWDED/CHAOTIC STATE] → [PLAYER IDENTIFIES MOVE] → [PLAYER ACTS (tap/drag)] →
[IMMEDIATE FEEDBACK (snap/click)] → [TRAY/BUFFER CHANGES] → [RELIEF OR TENSION ESCALATES] →
[CROWDED/CHAOTIC STATE (modified)] → repeat
```

---

## CORE LOOP DESIGN CHECKLIST

Work through this checklist sequentially. Every item must be answered before moving to GDD.

### ▸ PHASE 1 — THE PRIMARY ACTION

```
[ ] 1.1 PRIMARY ACTION DEFINITION
    - What is the single tap/drag action the player performs?
    - Write it as: "Player [VERB] [OBJECT] [DIRECTION/DESTINATION]"
    - Example: "Player TAPS a gem block and it SLIDES RIGHT out of the grid"
    - Anti-pattern check: Is the action completable in < 1 second? (Must be YES)

[ ] 1.2 INPUT TYPE
    - Tap only / Tap + Drag / Drag only / Tap-then-Tap (2-step)
    - For 2-step mechanics: is Step 1 clearly distinguished from Step 2 visually?
    - Mobile-first check: Is the tap target ≥ 48×48dp?

[ ] 1.3 ACCESSIBILITY RULES
    - Which items/pieces can the player interact with? Define the rule precisely.
    - "Accessible" items must be visually distinct from locked ones (glow / color / border)
    - Never more than 1 rule for accessibility in levels 1–15
    - Example: "Item is accessible if its left OR right horizontal path to grid edge is clear"

[ ] 1.4 MOVEMENT RULES
    - Where does the item go when tapped?
    - Is the destination deterministic? (Must be YES for Sara)
    - Does the item animate smoothly? (Must be YES — snap in 200–300ms ease-out)
    - Does the item give sound feedback? (Must be YES — even placeholder)
```

### ▸ PHASE 2 — THE TENSION SYSTEM (TRAY)

```
[ ] 2.1 TRAY DEFINITION
    - How many slots? (Supersonic standard: 5 unlocked, 2 locked via RV/SC)
    - What goes INTO the tray? (overflow items? player-parked items? auto-routed?)
    - What LEAVES the tray? (sent to destination / consumed by match / cleared by booster)
    - Is the tray always visible? (Must be YES)

[ ] 2.2 TRAY FILL RHYTHM
    - How quickly does the tray fill in a typical level? (Target: 3–4 fill cycles per level)
    - Is there a "tray danger" visual state? (Required: last slot blinks/turns red)
    - When does the player feel relief from tray pressure? (Define the exact trigger)

[ ] 2.3 FAIL STATE DEFINITION
    Primary fail type: [ ] TRAY SLOT FULL  [ ] NO AVAILABLE MOVES  [ ] TIME OUT
    - TRAY SLOT FULL: When all N slots are occupied AND [condition that makes it unsolvable]
    - NO AVAILABLE MOVES: When zero items meet the accessibility rule
    - TIME OUT: AVOID — creates wrong pressure for Sara demographic
    
    Fail state requirements:
    [ ] Player can ANTICIPATE the fail (≥2 tray slots fill before final slot)
    [ ] Fail animation is clear and immediate (screen flash/shake)
    [ ] Fail is always the player's fault (never feels random or unfair)
    [ ] Fail state is a natural RV_Revive moment (player WANTS to continue)

[ ] 2.4 SMALL VICTORIES
    Define 2–3 "micro-relief" moments within a level that happen BEFORE the full clear:
    - Example: "Completing one destination shelf triggers a STOCKED! burst"
    - Example: "3-of-a-kind fusion in tray triggers a sparkle clear"
    - Example: "Removing a locked item reveals 3 new accessible items"
    These small victories keep Sara motivated between the full-clear reward.
```

### ▸ PHASE 3 — THE WIN CONDITION

```
[ ] 3.1 WIN CONDITION DEFINITION
    Write it in one sentence. Format: "[BOARD STATE] is achieved."
    Examples:
    - "All blocks have been removed from the grid and cleared through shredders."
    - "All required gem sets (3-of-a-kind) have been completed."
    - "The quota of 6 cooking batches has been completed."
    
    Anti-patterns (fail these):
    [ ] Win condition is NOT "clear as many as possible" (must be definite end state)
    [ ] Win condition is NOT time-based
    [ ] Win condition IS visible in progress bar or completion indicator

[ ] 3.2 WIN ANIMATION
    What happens when the level clears? (Define the exact sequence)
    - Board clears (how? scatter / slide off / explode?)
    - "LEVEL COMPLETE!" text animates in (scale-up from 0 is standard)
    - Reward drops (coin rain / star burst)
    - Next level button appears
    The win animation is the emotional payoff. Budget animation time here.

[ ] 3.3 LEVEL DURATION TARGET
    Supersonic target: 5–7 minutes per level (average)
    Is the win condition achievable in 5–7 minutes for an average player? 
    If < 3 min: level is too easy (add density or constraints)
    If > 10 min: level is too long (reduce board size or item count)
```

### ▸ PHASE 4 — MECHANIC INTEGRITY CHECKS

```
[ ] 4.1 DEADLOCK CHECK
    Can the player create an unwinnable state through legal moves? 
    - If YES: is this the INTENDED fail state? (ok if it's the defined fail condition)
    - If YES and it's NOT the intended fail: redesign accessibility rules to prevent it
    
[ ] 4.2 DETERMINISM CHECK
    Does the same sequence of player actions ALWAYS produce the same outcome?
    - Must be YES. No random shuffles, no random item spawns in core puzzle.
    
[ ] 4.3 SOLVABILITY CHECK
    Can every level be solved without boosters on first try by a skilled player?
    - Must be YES. Design levels that are challenging but provably solvable.
    
[ ] 4.4 3-SECOND RULE CHECK
    Show the Level 1 board to a new player (mentally). 
    Can they identify what to tap within 3 seconds?
    - If NO: simplify board density, increase contrast, reduce item type count.
    
[ ] 4.5 SCALABILITY PREVIEW
    List 5 ways this mechanic can be made harder over 100 levels WITHOUT adding new input types:
    1. [Board size increase]
    2. [Item type count increase]
    3. [Locked/blocked item introduction]
    4. [Tray slot reduction (one fewer slot)]
    5. [Restricted path constraints]
    If you can't list 5: the mechanic may not scale to 100 levels.

[ ] 4.6 SARA EMOTIONAL JOURNEY PER LEVEL
    Map a single level's emotional arc:
    [Start: curious] → [Early: confident, winning small] → 
    [Middle: slight tension as tray fills] → [Late: urgency, last 2 tray slots] → 
    [Crisis: near-fail or save] → [Relief: tray clears + board opens] → 
    [Final: clear animation, reward, satisfaction]
    Every level must hit all 7 beats.
```

---

## GAMEPLAY RULES WRITING STANDARD

When writing the formal rules for a game mechanic:

**Format:**
```
RULE [N] — [RULE NAME IN CAPS]
Condition: [When does this rule apply?]
Action: [What happens?]
Exception: [Any edge case?]
Visual feedback: [What does the player see?]
Audio feedback: [What does the player hear?]
```

**Example:**
```
RULE 1 — ITEM ACCESSIBILITY
Condition: An item on the board is tapped by the player.
Action: If the item has a clear horizontal path to either the left OR right edge 
        of the grid (no other item occupying any cell in that row in that direction), 
        the item slides out toward the clear side.
Exception: Items marked as LOCKED (padlock icon) cannot move regardless of 
           path availability. Locked items require an adjacent item to be removed first.
Visual feedback: Accessible items have a pulsing white border glow (alpha 0.4→1.0 loop). 
                 Non-accessible items have no interactive highlight.
Audio feedback: Tapping an accessible item plays a soft "click" sound on movement start.
               Tapping a non-accessible item plays a subtle "thud" rejection sound.
```

Write all rules in this format. Never leave a rule ambiguous. Every edge case is a future bug.
