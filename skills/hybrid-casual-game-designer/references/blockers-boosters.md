# Blockers & Boosters Design Protocol
## reference: blockers-boosters.md

---

## CORE PRINCIPLE

**Blockers create tension. Boosters provide relief.**
Both must serve the mechanic — not fight it.

The golden rule: **A booster that removes the challenge also removes the satisfaction.** Design boosters that EXTEND the player's agency, not bypass the puzzle.

---

## BLOCKER TAXONOMY

Blockers are obstacles that modify the accessibility rules or increase board complexity. Introduce ONE blocker type at a time, no earlier than Level 12.

### Universal Blockers (Work in Any Mechanic Type)

```
BLOCKER TYPE: LOCKED ITEM
Visual: Padlock icon overlaid on item
Rule: Item cannot be tapped until an adjacent item is removed
Reveal: When adjacent item clears, lock icon bursts with a "click-release" animation
Introduce at: Level 12–15
Complexity budget: Start with 1–2 locked items. Scale to 5–6 by Level 30.
Sara check: Fair — player can SEE why it's locked
```

```
BLOCKER TYPE: CHAINED PAIR
Visual: Two items linked by a chain visual
Rule: Both items in the pair must be tapped in sequence before either moves
      First tap "activates" the chain (glows), second tap releases both
Reveal: Both items fly out simultaneously with a chain-snap animation
Introduce at: Level 18–22
Sara check: Fair — visual chain makes constraint obvious
```

```
BLOCKER TYPE: LAYERED / DOUBLE ITEM
Visual: Two items stacked (top item partially visible above bottom item)
Rule: Only the top item can be tapped. Bottom item becomes accessible after top is removed.
Reveal: Top item lifts away to reveal bottom item in a satisfying "unpeel" animation
Introduce at: Level 20–25
Sara check: Fair — visual stack makes constraint obvious
Supersonic reference: Used in their Unravel Master / block puzzle variants
```

```
BLOCKER TYPE: DIRECTIONAL-ONLY ITEM
Visual: Arrow icon on item showing allowed direction
Rule: Item can ONLY slide in the direction shown by its arrow
Board design: Requires at least one valid path in the allowed direction
Introduce at: Level 25–30
Sara check: Requires player to learn new rule — introduce with a dedicated "teach" level
Color Block Jam reference: This mechanic is confirmed in CBJ and scales well
```

```
BLOCKER TYPE: FROZEN / ENCASED ITEM
Visual: Ice crystal overlay, semi-transparent
Rule: Must be tapped TWICE (or 2 adjacent items cleared) to unfreeze
      First tap cracks the ice (crack animation), second tap frees the item
Introduce at: Level 25–30
Sara check: Fair — visual state clearly shows "not yet ready"
```

### Conveyor-Specific Blockers

```
BLOCKER TYPE: STACKED BELT ITEM
Visual: Two items stacked vertically on one belt cell
Rule: Only top item is tappable; bottom revealed after top is routed
Introduce at: Level 12+
```

```
BLOCKER TYPE: EXPRESS ZONE
Visual: Highlighted belt cells with speed arrow
Rule: Items in express zone move at 2× speed
Introduce at: Level 20+
Sara check: RISK — speed pressure. Only use if belt is already very slow base speed.
```

### Sort/Stack-Specific Blockers

```
BLOCKER TYPE: SPOOL WEIGHT LIMIT
Visual: Spool shows MAX capacity
Rule: Cannot add more than N items of same type to a spool at once
Introduce at: Level 15+
```

```
BLOCKER TYPE: RESTRICTED DESTINATION
Visual: Destination slot has a "type reject" icon for one item type
Rule: This destination refuses one specific item type (forces creative routing)
Introduce at: Level 20+
```

---

## BLOCKER INTRODUCTION CADENCE

Follow the Teach → Test → Master pattern from the Voodoo Level Design Guidelines:

```
INTRODUCE A NEW BLOCKER:
  Level N (TEACH): 
    - Only 1 instance of the new blocker on an otherwise simple board
    - Solution is obvious — player cannot miss the new mechanic
    - Win guaranteed if they interact with the blocker correctly
    
  Level N+1 (TEST):
    - 2–3 instances of new blocker combined with familiar mechanics
    - Slightly more complex routing required
    - Player should still succeed on first or second attempt
    
  Level N+3 (MASTER):
    - 4–6 instances, combined with other existing blockers
    - Requires planning ahead to solve
    - This is an intentional hard level (APS target: 2–3)
    - Follow with a BREATHER level (easy, no new blockers)
```

---

## BOOSTER DESIGN RULES

### V1 Protocol (First Submission — NO BOOSTERS)
Per Supersonic Playbook: "No need for boosters on V1!"
V1 should prove the core mechanic without booster interference.
Only RV placements needed in V1: `RV_Slot` and `RV_Revive`.

### V2+ Booster Design (Post-KPI Validation)

**Booster Compatibility Matrix — run this check for every proposed booster:**

```
FOR EACH PROPOSED BOOSTER, ANSWER ALL 5:

1. MECHANIC INTEGRITY: Does this booster work WITH the core mechanic or BYPASS it?
   - BYPASS = BAD (e.g., "Clear all items instantly" removes the puzzle)
   - WITH = GOOD (e.g., "Add one tray slot" extends the puzzle)

2. SARA MOTIVATION: Will Sara watch an RV for this? 
   - YES: Booster solves the EXACT frustration she just experienced
   - NO: Booster is generic and doesn't feel earned

3. TENSION PRESERVATION: Does this booster remove tension or redirect it?
   - REDIRECT = GOOD (e.g., "Swap two items" creates new decision)
   - REMOVE = BAD (e.g., "Pause timer" only works if there's a timer, which Sara hates)

4. VISUAL CLARITY: Is the booster effect immediately understandable?
   - Hammer = breaks one item (clear)
   - Vacuum = removes several items (clear)
   - "Enhance" = unclear (bad)

5. OVERUSE RISK: Can this booster be spammed to trivialize all levels?
   - If YES: add a cooldown, cost, or limited-use constraint
```

### Standard Booster Archetypes (Proven Across Genre)

```
BOOSTER: SLOT EXPANSION (RV_Slot)
Effect: Adds +1 tray slot for the current level
Cost: Watch RV (free) OR 200 coins
When offered: When tray has 1 slot remaining (danger state)
Mechanic fit: Works for ALL tray-based games
Anti-pattern: Never offer when tray is empty (bad timing = low RV uptake)

BOOSTER: REVIVE (RV_Revive)  
Effect: Restores game state to 3 moves before the fail state
Cost: Watch RV (free) OR 250 coins
When offered: Immediately after fail state triggers
Mechanic fit: ALL games
Note: Only offer ONCE per level fail — do not loop

BOOSTER: TOOLBOX / WILDCARD (RV_Toolbox)
Effect: Unlocks a locked/blocked item OR converts one item to any type
Cost: Watch RV (free) OR 150 coins
When offered: Pre-level offer OR when player has been stuck for 45+ seconds
Mechanic fit: Games with locked items or type-matching

BOOSTER: HAMMER / REMOVE
Effect: Removes 1 item from any position on the board, regardless of accessibility
Cost: 100–200 coins (never free — core strategy item)
When offered: Available in booster bar (limited charges)
Mechanic fit: Grid-based jam games
Warning: Do NOT make this available for all items — limit to one per level or it trivializes

BOOSTER: SHUFFLE / REORGANIZE
Effect: Rearranges all non-locked items in the board while preserving locked positions
Cost: 200 coins
When offered: Available in booster bar
Mechanic fit: Games where dead-end states are possible
Warning: Shuffle should feel exciting, not punishing. Add a dramatic animation.
```

---

## BLOCKER ↔ BOOSTER COMPATIBILITY TABLE

For each blocker, only offer boosters that directly address it. Mismatched boosters feel random and don't drive RV uptake.

| Blocker Type | Compatible Booster | Incompatible Booster |
|---|---|---|
| Locked Item | Toolbox (unlock), Hammer (remove) | Shuffle, Slot Expansion |
| Chained Pair | Hammer (break chain), Toolbox | Slot Expansion |
| Layered Item | Hammer (remove top layer) | Shuffle |
| Directional-Only | Shuffle (re-routes item), Toolbox | Slot Expansion |
| Frozen Item | Toolbox (instant thaw), Hammer | Shuffle |
| Tray Overflow | Slot Expansion, Revive | Hammer, Toolbox |
| No Available Moves | Shuffle, Hammer, Toolbox | Slot Expansion |

---

## BOOSTER INTRODUCTION TIMELINE

```
V1 (Prototype submission): No boosters. RV_Slot and RV_Revive only.
V2 (Post-KPI validation):  Add Toolbox/Wildcard as first booster
V3 (Scaling phase):         Add Hammer, then Shuffle if mechanic supports it
Meta (Long-term):           Add daily booster pack offers, bundle pricing
```

**Never introduce a booster before Level 14** — this is when ads begin and when the economy becomes relevant. Before Level 14, Sara should feel like the game is fair and free.
