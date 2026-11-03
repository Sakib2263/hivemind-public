# Market Research Protocol
## reference: market-research.md

---

## STEP 1 — LIVE STORE LINK ANALYSIS

When the user provides a Google Play or App Store URL, fetch it immediately using `web_fetch`. Do not ask for permission — just fetch.

**What to extract from a store listing:**
```
GAME NAME:
PUBLISHER:
CATEGORY / SUBCATEGORY:
RATING: [score / review count]
DOWNLOADS / RANK: [estimated installs, chart position]
DESCRIPTION KEYWORDS: [extract top 5 gameplay verbs from description]
SCREENSHOT ANALYSIS: [describe board layout, tray/buffer visible?, item types]
REVIEW SENTIMENT: [scan recent reviews for "satisfying", "addictive", "frustrating", "too easy", "ads"]
LAST UPDATE: [is it actively maintained?]
```

**Output format after fetching:**
```
MARKET SIGNAL: [RISING / STABLE / DECLINING]
CORE MECHANIC: [one sentence]
TRAY/BUFFER SYSTEM: [YES/NO + description]
WIN CONDITION: [one sentence]
FAIL CONDITION: [TRAY SLOT FULL / NO MOVES / TIME OUT / OTHER]
CPI HOOK: [what would make the ad creative compelling?]
PUBLISHER PATTERN: [does this fit Voodoo, Supersonic, Homa, Rollic DNA?]
MASHUP OPPORTUNITY: [what does this game NOT have that could be its sequel twist?]
```

**If store link returns no useful data:** Use web_search with the game name + "gameplay mechanic" + "review" to supplement.

---

## STEP 2 — TREND ANALYSIS PROTOCOL

When asked "what's trending?" or "what's hot in puzzle?" without a specific URL:

1. Search for: `[current year] top hybrid casual puzzle games charts`
2. Search for: `[publisher name] new releases [year]` for Voodoo, Supersonic, Rollic, Homa, CrazyLabs
3. Search for: `color block jam competitors 2025` or replace with current benchmark game

**Trend Signal Categories to Identify:**
- **Mechanic Trends:** What action verbs appear most (sort, match, jam, unblock, connect, fill, stack)?
- **Theme Trends:** What visual skins are dominating (food, home, yarn, gems, cars, pets)?
- **Hybrid Combinations:** Are any new 2+1 mashups appearing in top 50?
- **Publisher Movements:** Has Voodoo/Supersonic published something new in last 90 days?

---

## STEP 3 — GAME DECONSTRUCTION FRAMEWORK

Use this template whenever asked to "analyze [GAME NAME]":

```
═══ GAME DECONSTRUCTION: [GAME NAME] ═══

PUBLISHER: 
GENRE TAG: [Jam / Sort / Conveyor / Match / Block / Hybrid]
DAILY REVENUE ESTIMATE: [if known from SensorTower/AppMagic data]

── MECHANIC ANALYSIS ──
Primary Action: [What does the player DO every 3 seconds?]
Secondary System: [What creates tension / pressure?]
Relief Moment: [What is the satisfying payoff animation?]
Tray/Buffer: [How many slots? What triggers fail?]

── SCREEN LAYOUT ──
Board Zone: [% of screen, description]
Tray Zone: [slot count, position]
Booster Zone: [what boosters, when available]
Info Bar: [what data shown]

── WIN / FAIL ──
Win Condition: [exact]
Fail Condition: [exact — which type?]
Fail Warning System: [how does the game telegraph approaching fail?]

── DIFFICULTY ──
First Hard Level: [level number]
APS on hard levels: [estimated]
New mechanic cadence: [every N levels]

── MONETIZATION ──
Ads start: [level number]
RV placements: [where and what]
IAP offer: [what and price]

── ONBOARDING ──
Tutorial style: [silent / text / hybrid]
FTUE length: [how many levels before first hard moment]

── CPI AD PATTERN ──
Visual hook: [what makes the thumbnail/ad arresting]
Common hook type: [fail bait / satisfying loop / chaos-to-order / challenge]

── SARA FIT ──
Score: [1–10]
Reason: [one sentence]

── PUBLISHER FIT ──
Best fit: [Voodoo / Supersonic / Homa / Rollic]
Reason: [one sentence]

── MASHUP WHITESPACE ──
What this game doesn't have: [one gap]
Opportunity: [one mashup concept using this as a base]

── RISK FLAGS ──
[One honest concern about long-term retention]
```

---

## MECHANIC TAXONOMY (Current Market Map)

### Tier 1 — Proven, Saturating (High competition, need strong twist)
- Horizontal block slide → shredder (Color Block Jam DNA)
- Color liquid sort (Water Sort DNA)
- Hexagonal tile stack (Hexa Sort DNA)
- Screw/bolt unscrew order-of-ops (Screw Jam DNA)
- Mahjong-style 3-match collection (Triple Tile DNA)

### Tier 2 — Proven, Less Saturated (Good entry window)
- Item routing to destination slots (Goods Sort DNA)
- Car/vehicle grid jam with hauler destinations (Hauler Sort DNA)
- Category-matching stacking posts (Bolt Sort / Connect Tower DNA)
- Word extraction from block grid (Word Block Jam DNA)

### Tier 3 — Emerging / Whitespace (First-mover advantage)
- Yarn/thread unwinding sort (no dominant hit yet)
- Conveyor belt ingredient routing (no dominant hit yet)
- Multi-destination block routing (beyond shredder)
- Set-collection block jam hybrid (3-of-a-kind + grid jam combined)
- Layered/peeling reveal puzzles

### Dead Ends (Do Not Pursue)
- Pure Match-3 without twist (Royal Match owns this)
- Timer-based speed puzzles (wrong demographic)
- Hidden object (wrong session length)
- Dark/horror themes (wrong demographic)

---

## COMPETITIVE BENCHMARKS (From Project Knowledge Base)

| Game | Publisher | Daily Rev Est | Core Mechanic | Sara Fit |
|---|---|---|---|---|
| Color Block Jam | Rollic/Zynga | $250K+/day | Directional block slide → shredder | 8/10 |
| Hexa Sort | Unknown | Top 20 persistent | Hex tile stacking by color | 9/10 |
| Block Jam 3D | Voodoo | Strong | 3D spatial unblocking | 7/10 |
| Goods Sort | YL Games | Mid-tier | Shelf organizing, item matching | 10/10 |
| Triple Tile | Tripledot | Strong | Mahjong 3-match collection | 9/10 |
| Water Sort Puzzle | IEC Global | Mature | Liquid color sort | 8/10 |
| Screw Jam | Rollic | Mature | Screw order-of-operations | 7/10 |
| Twisted Tangle | Rollic | Growing | Untangle ropes | 8/10 |

Source: Project knowledge base (Puzzle Game References for Voodoo Prototyping.pdf, Color Block Jam podcast transcript)
