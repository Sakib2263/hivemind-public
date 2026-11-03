# Gameplay Rules Specification Template
## Full Use-Case Format for Hybrid-Casual Puzzle Games

---

## HOW TO USE THIS TEMPLATE
Fill every section. Do not leave items blank — either write the spec or mark
[NEEDS DESIGN DECISION: description]. Incomplete rules specs cause prototype
agents to make incorrect assumptions and produce broken demos.

---

## SECTION A — GAME OVERVIEW

```
GAME NAME: [Title]
MASHUP:    [Base Mechanic] + [Tension System] + [Theme]
PLATFORM:  iOS + Android
ENGINE:    Unity / HTML prototype
VERSION:   V[1.0]
```

---

## SECTION B — CORE ACTION SPEC

### B1. Input Type
```
PRIMARY INPUT: [Tap / Drag / Swipe] — describe exact gesture
  - Touch target minimum size: 48x48dp (accessibility standard)
  - Response time requirement: visual feedback within 16ms of tap
  - Invalid tap behavior: [shake animation / no response / sound cue]

SECONDARY INPUT (if any): [describe]
  - When available: [condition]
  - Visual indicator: [how player knows this input is available]
```

### B2. Accessibility Rules
```
ACCESSIBLE STATE: An item is tappable/interactive WHEN:
  Condition 1: [specific geometric/logical condition]
  Condition 2: [if multiple conditions exist]

NON-ACCESSIBLE STATE: An item CANNOT be interacted with WHEN:
  Condition 1: [specific condition]
  Condition 2: [if multiple]

VISUAL DISTINCTION:
  Accessible items: [highlight style — border glow / color shift / scale pulse]
  Non-accessible items: [dim style — opacity / desaturate / no glow]
  Transition animation: [how does accessible state change look?]
```

### B3. Movement Rules
```
ON VALID TAP:
  1. [Step 1 of what happens — be exact: "item slides horizontally toward clear edge"]
  2. [Step 2 — "item arcs into next available tray slot"]
  3. [Step 3 — "grid accessibility recalculates"]
  Animation duration: [200-300ms ease-out — never teleport]

ON INVALID TAP:
  1. [What happens — "item shakes briefly"]
  2. [Visual feedback — "red border flash for 200ms"]
  3. [State change — "returns to normal, no items moved"]
```

---

## SECTION C — TRAY SYSTEM SPEC

```
TRAY CAPACITY: [5 slots default / 7 for set-collection games]
SLOT FILL ORDER: [left-to-right / auto-group matching items]

SLOT FILL ANIMATION:
  - Item arrival: scale bounce (1.0 > 1.2 > 1.0 in 200ms) + "thunk" visual
  - Fill indicator: [dots / color fill / progress bar]

TRAY STATES:
  EMPTY (0 filled):    [visual description]
  NORMAL (1-2 filled): [visual description]
  CAUTION (3 filled):  [amber warning — background color shift]
  DANGER (4 filled):   [red pulse + blinking — Unravel Master standard]
  FULL (5 filled):     [bright red + shake — imminent fail]

TRAY ITEM INTERACTION:
  Can player interact with tray items? [Yes / No]
  If Yes: tap tray item > [what happens?]
  Tray item routing: [to where? under what conditions?]

TRAY CLEAR CONDITIONS:
  Items are removed from tray when: [condition — e.g., "3-of-a-kind match"]
  Clear animation: [describe particle burst / fly-off animation]
```

---

## SECTION D — WIN CONDITION SPEC

```
WIN TRIGGER: [exact condition — "all blocks removed from grid" / "X batches cooked" etc.]
WIN VISUAL:
  1. [Immediate feedback — "remaining items scatter off screen"]
  2. [Celebration — "coin rain from top, 20 particles"]
  3. [Text — "LEVEL COMPLETE!" scale-up animation from center"]
  4. [UI — "[Next Level] button appears after 1.5 seconds"]

WIN AUDIO: [describe sound — fanfare, specific notes, duration]

PROGRESS INDICATOR:
  Type: [progress bar / counter / percentage]
  Location: [info bar / completion bar]
  Update trigger: [on each item cleared / on each set completed]
```

---

## SECTION E — FAIL CONDITION SPEC

```
PRIMARY FAIL TYPE: [TRAY SLOT FULL / NO AVAILABLE MOVES]

TRAY SLOT FULL FAIL:
  Exact trigger: [all N slots filled AND [specific additional condition]]
  Warning system: [see tray danger state above — player has warning at 3/5 filled]

NO AVAILABLE MOVES FAIL:
  Exact trigger: [zero accessible items remain in grid]
  Check frequency: [after each player action]

FAIL VISUAL:
  1. [Screen edge — "red pulse, alpha 0>0.6>0 over 400ms"]
  2. [Screen shake — "camera shake 300ms, 0.01 intensity"]
  3. [Text — "LEVEL FAILED / [specific themed text]" center screen, bold red"]
  4. [UI — "[Try Again] button + optional RV_Revive offer"]

FAIL AUDIO: [screen shake sound / buzzer / specific SFX]

FAIL STATE FAIRNESS CHECK:
  [ ] Can player see the fail approaching? (warning state must exist)
  [ ] Is fail caused by player decision, not random grid configuration?
  [ ] Is there at least 2-3 player actions between warning state and fail?
  [ ] Does the fail state make sense thematically? ("Kitchen Chaos!" / "Tray Overflow!" etc.)
```

---

## SECTION F — BLOCKER SPECS (POST-LEVEL 10)

### For each blocker type, fill this spec:

```
BLOCKER NAME: [Name — e.g., "Locked Item" / "Frozen Cell" / "Chained Pair"]
VISUAL APPEARANCE: [icon, border style, color modifier]
TEACH LEVEL: [which level number introduces this blocker in isolation]

INTERACTION RULE:
  Standard item: [one tap to move]
  This blocker: [describe exact interaction — "tap twice" / "clear adjacent first"]
  Unlock animation: [what visual plays when blocker is removed?]
  Sound: [specific SFX]

EFFECT ON ACCESSIBILITY RULES:
  Does this blocker affect which other items are accessible? [Yes/No — describe]

COMBINATION RULES:
  Can appear with Blocker Type 2? [Yes / No / Level 21+]
  Breaking both simultaneously possible? [Yes/No]

LEVEL DESIGN NOTE:
  Maximum blockers per level (early): [number]
  Maximum blockers per level (late game): [number]
```

---

## SECTION G — BOOSTER SPECS (V2+)

For each booster, fill this spec:

```
BOOSTER NAME: [Name]
ARCHETYPE: [Remove / Expand / Reveal / Revive]
THEMATIC FIT: [how does it fit the game skin? e.g., "Scissors = cut a yarn loop"]

EFFECT: [Exact mechanical effect — precise, no vague language]
  - Target: [what does it affect?]
  - Quantity: [how many items/cells affected?]
  - Duration: [instant / N seconds]

TRIGGER METHOD:
  [ ] Costs soft currency (coins): [amount]
  [ ] Watch RV (free use): RV_[Name] — exact Supersonic string
  [ ] Costs hard currency (gems): [amount]

VISUAL:
  - Activation animation: [describe]
  - Effect animation: [describe]
  - Sound: [describe]

BALANCE CONSTRAINTS:
  Uses per level: [unlimited / max N]
  Cooldown: [none / N seconds]
  Does not apply when: [any restrictions?]

COMPATIBILITY TEST RESULT:
  Used at worst possible moment: [describe worst case]
  Does it break core tension? [Yes/No — if Yes, add constraint]
```

---

## SECTION H — USE CASE MATRIX

Document every edge case that could occur during gameplay.

```
USE CASE 1: Player taps a non-accessible item
  Trigger: [condition]
  Expected: [what happens]
  Visual: [what player sees]
  Audio: [what player hears]
  State change: [none / describe]

USE CASE 2: Player taps accessible item, tray is empty
  Expected: [item slides out, enters slot 1]

USE CASE 3: Player taps accessible item, tray has 4/5 filled
  Expected: [item slides out, enters slot 5, DANGER state activates]

USE CASE 4: Player taps accessible item, tray is full (5/5)
  Expected: [item cannot leave grid, tap rejected, shake animation]
  OR Expected: [item leaves grid, FAIL triggers — choose and document]

USE CASE 5: 3-of-a-kind (or matching set) reached in tray
  Expected: [matching items pulse, merge animation, 3 slots clear]
  Timing: [200ms delay after 3rd item lands, then burst]

USE CASE 6: Last item cleared from grid (WIN)
  Expected: [win sequence triggers — see Section D]

USE CASE 7: Booster activated on empty board (edge case)
  Expected: [booster has no effect / is unavailable / partial effect]

USE CASE 8: Restart mid-level
  Expected: [grid resets to original state, tray clears, coins not spent]

USE CASE 9: [Game-specific edge case 1]
USE CASE 10: [Game-specific edge case 2]
[Add as many as needed — cover all branching states]
```

---

## QUALITY GATES FOR RULES SPEC

Before handing rules spec to developer or prototype agent:

- [ ] Every player action has an expected outcome documented
- [ ] Every failure path is documented
- [ ] No vague language ("item goes somewhere appropriate" is not acceptable)
- [ ] All animation durations are specified in milliseconds
- [ ] All edge cases have defined behavior (no "TBD" in edge case column)
- [ ] Rules pass the "Zero-Context Test": a developer who has never seen the game
      can implement the core loop correctly from this spec alone
