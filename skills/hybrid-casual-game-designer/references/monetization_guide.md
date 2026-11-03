# Monetization Guide
## Supersonic + Voodoo Economy Standards for Hybrid-Casual Prototypes

---

## SUPERSONIC V1 MONETIZATION (from Playbook — exact standards)

### Starting Economy
- Starting gold: **400 coins**
- Per level reward: **20 coins**
- Multiplication RV: available "further down the road" (not V1)
- **No boosters needed in V1** — this is explicitly stated in Supersonic playbook

### RV Placement Names (EXACT — do not alter spelling or casing)
```
RV_Slot     — Watch ad to add one additional tray slot
RV_Revive   — Watch ad to continue from a failed state
RV_Toolbox  — Watch ad to activate a booster item
```
These exact strings are required by Supersonic's SDK integration.

### Toolboxes / Targets
- 4 toolboxes visible: 2 unlocked, 2 locked (unlockable via RV/SC/Progression)
- Locked toolboxes "offer a way out from a dead end" — Supersonic playbook
- Sense of "freedom" from having multiple matching destinations

### Completion Bar
- Required: Let the player understand level progress throughout play
- Updates on each item cleared / each set completed

---

## VOODOO V1 MONETIZATION (from Prototyping Strategy)

### Soft Currency (Coins)
Sources:
- Generous level completion rewards
- Bonus objectives (complete in X moves)
- Watching Rewarded Video ads

Sinks:
- **Continues** — primary sink. Allow retry from failed state.
- **Boosters** — in-level power-ups (Hammer) or pre-level advantages (+3 Moves)
- **Cosmetics** (optional, later stages)

### Hard Currency (Gems)
Sources:
- Almost exclusively from IAP packs
- Tiny amount for major milestones (teaches value)

Sinks:
- Convenience: skipping difficult levels
- Bundles: large packs of boosters or coins
- Premium cosmetics

### IAP Tiers (Standard Starting Point)
- **No Ads offer**: $2.99 or $4.99 (test both — this is most important IAP for prototype)
- **Gem pack Small**: $1.99
- **Gem pack Medium**: $4.99
- **Gem pack Large**: $9.99
- **Gem pack XL**: $19.99

### RV Placements (Voodoo Standard)
```
On Fail:       "Watch an ad for a second chance?"  — HIGH value, HIGH engagement
End of Level:  "Watch an ad to double/triple your coin reward!" — classic, effective
Boosters:      "Get a free booster for this level by watching an ad."
Gated Content: "Watch an ad to unlock this special theme for 24 hours."
```

---

## AD MONETIZATION TIMING

### Interstitial Ads
- **First ad appears: Level 14** (Rollic/Color Block Jam benchmark — confirmed in Supersonic playbook)
- Frequency: every level after Level 14 (interstitials after every level)
- No ads before Level 14 — "space to play" principle

### Rewarded Video
- Available from earlier levels (player choice, not forced)
- Placement UI: visible but not intrusive
- Must feel like a fair value exchange (reward must be substantial)

### eCPM Quality
- D0 playtime target: 2,700-3,600 seconds (45-60 minutes) — critical for eCPM
- Higher playtime = higher eCPM from ad networks
- ARPDAU target: $0.05-$0.15 (IAA-heavy game)
- RV engagement rate target: >15% of sessions

---

## ECONOMY BALANCE RULES

### Anti-Patterns to Avoid
- **Paywalls**: Game must be 100% completable free. IAPs = shortcuts, not gates.
- **Forced ads**: Never show unskippable interstitials before Level 14
- **Weak RV value**: If the reward for watching an ad doesn't feel substantial, CTR drops
- **Currency confusion**: Only have one soft currency and one hard currency in V1
- **IAP overload**: Max 4-5 IAP SKUs in prototype. More = analysis paralysis.

### Level Economy Scaling
```
Levels 1-10:    20 coins/level (tutorial, no ads)
Levels 11-13:   20 coins/level (ramp-up, no ads)
Level 14+:      20 coins/level + interstitial after every level
Hard levels:    Same coins — no punishment for failing (soft currency still flows)
```

### Booster Economy (V2+ only)
```
Common booster cost (soft currency): 50-100 coins
Rare booster cost (soft currency):   150-250 coins
Booster watch-to-earn (RV):          Free with ad watch
Booster pack (IAP):                  $0.99 / $2.99 / $4.99
```

---

## PRODUCTION KPI TARGETS

| KPI | Supersonic | Voodoo |
|---|---|---|
| CPI (Android) | $1.00 initial | $2.00 maximum |
| CPI (iOS) | $1.50 initial | $2.00 maximum |
| D1 Retention | >40% | >40% |
| D7 Retention | >20% | >20% |
| D30 Retention | >20% | 20% ("DREAM BIG" test) |
| Daily Playtime | ≥30 minutes | ≥30 minutes |
| D0 Playtime | 2,700-3,600 sec | 2,700-3,600 sec |
| App Size | <100MB | <100MB |

---

## CPI VIDEO PRODUCTION (5 Videos Required)

### Video Types (test all 5 angles)
1. **Problem-Solving** — Show a difficult puzzle being solved satisfyingly
2. **Emotional Relief** — Frame the game as stress-relieving ("unwind your day")
3. **Funny Fail** — Show a humorous fail state (fail bait — very high CTR)
4. **Impossible Puzzle** — Create a very hard-looking puzzle to challenge the viewer
5. **Satisfying Loop** — Pure gameplay loop, no narrative — shows the "aaah" moment

### Creative Elements That Lower CPI (from Supersonic playbook)
- Showing unique levels with eye-catching layouts and items
- Emphasizing the main mechanic clearly
- Using bright and vivid colors
- Camera zoom/focus on the key interaction moment
- Simple narratives (no voiceover needed)

### Video Technical Requirements
- Length: 30 seconds each
- Format: 9:16 vertical (mobile)
- Resolution: 1080x1920 minimum
- Sound: all videos must work without audio (assume muted)
- Branding: store icon in last 3 seconds with CTA button
