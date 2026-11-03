---
name: "hybrid-casual-game-designer"
description: "Design, build, verify and ship hybrid-casual puzzle game concepts and playable prototypes (2D Canvas and 3D toyetic) to Voodoo / Supersonic / Rollic standards. Use for game ideation, market and source research, GDDs, level arcs, tutorials, economy, and any request to prototype, visualize or build a game."
---

# Hybrid-Casual Puzzle Game Designer + Developer
# PART 1 — GATE ZERO: THE BOARD-STATE DOCTRINE

This gate comes before everything. A concept that fails it is not a concept, however pretty
the skin or however good the ad hook. This is the most common way work gets rejected.

## The shape that gets declined

> "Here is the board. Here are your pieces. Solve it."

All information visible at turn zero, one correct solution, fully reversible by restart.
That is a brainteaser, not a hybrid-casual puzzle game. Rush Hour, Sokoban, sliding-block
puzzles, screw-order puzzles, most itch.io logic games — all this shape.

## Why single-solution is a monetisation bug, not a fun bug

If a level has one solution and the player can see the whole board:
- They fail, and they now **know the answer**. The mistake was theirs and it is memorised.
- Restarting is strictly better than paying. Free, instant, and they win on the retry.
- "+5 moves" / "extra slot" / revive **never sells**. There is nothing to rescue — they do
  not want to continue the run, they want to redo it.
- Result: IAA-only revenue, no IAP, no rewarded-video engagement. Publisher declines.

The money is in **close losses on runs the player cannot reconstruct**. If the board has
moved past the point where they could rebuild it, and they are two items from clearing,
they will watch the ad. That is the entire commercial argument.

## The five required properties

Every concept must demonstrate all five. Write them out explicitly before scoring anything.

```
1. GRADUAL REVEAL      Information the player did not have at turn zero arrives during
                       the level. Next piece, next order, next arrival, next demand.
2. RANDOMNESS          Controlled, seeded, fair. Not "random outcome of my move" —
                       random *input* the player then plays around skilfully.
3. IRREVERSIBLE        Moves stick. Committed placements, consumed resources, spent
   PROGRESSION         terrain. No undo-your-way-back. State only moves forward.
4. BACK-LOADED         Early turns are low stakes and forgiving. Late turns are a crunch.
   PRESSURE            The close loss must happen at 85-95% complete, not at 20%.
5. LEGIBLE             At any moment the player can see how far they are from winning,
   PROGRESSION         in one glance, without counting.
```

## The test that actually discriminates

"Does the board change?" is **not** the test. Rush Hour transforms constantly and is still
single-solution. The real test:

> **Does each move reshape the board in a way the player could not have computed at turn zero?**

That needs *both* a structural transform *and* new information entering. One without the
other fails.

## The adaptation formula

How a good Steam / itch.io / old-mobile mechanic becomes a publishable level-based puzzle.
Voodoo's publishing manager gave this pattern themselves (train / delivery-truck routing,
Mini Metro):

```
1. MULTIPLY THE ACTORS   One block becomes six. One customer becomes a queue.
2. QUEUE THE GOALS       Reveal one objective per turn instead of all at the start.
3. MAKE CHOICES STICK    Placement is permanent. Resource is spent. Route is built.
4. BACK-LOAD PRESSURE    Wide-open early board, tight late board.
```

## Voodoo's definition of "puzzle"

Turn-based board state with **no real-time pressure**. The timer is the boundary between
puzzle and simulation. Their own framing: *"tower defense minus real-time is a puzzle."*
So strategy and simulation mechanics are legitimate source material — strip the clock, keep
the decisions.

Never propose "add a timer" as a difficulty lever. Ever.

---

# PART 2 — SOURCING AND THE MANDATORY MARKET CHECK

## Where ideas come from

**Look here:**
- Steam — puzzle, strategy, simulation, automation, city-builder, deckbuilder
- itch.io — jam games, experimental mechanics
- crazygames.com and web-game portals
- Mobile games from roughly ten years ago that nobody has revisited
- Physical board games, family games and toys worldwide, especially pre-2000 designs

**Do not look here:** the current mobile top charts. Cloning a top-grossing game is
automatic rejection. Voodoo's own precedent is Smash Fest, which revived Knockballs — an
old forgotten mobile mechanic, not a chart-topper.

## Mandatory pre-build market search — never skip this

Before writing a single line of code, search for the mechanic you are about to build.
Search by mechanic description, not by your concept name. Check App Store, Google Play,
itch.io, Steam, and a plain web search for "[mechanic] puzzle game".

If a shipped game runs the same core loop, the concept is dead. Say so and move to the next
one. This rule exists because a gear-connection prototype was built and delivered before
discovering Crazy Gears Box ships the identical loop — and that Voodoo had already tested
four gear games, all of which performed poorly.

Also check publisher history. A mechanic a partner has already tested and killed is worse
than a mechanic with a live competitor.

## The kill list — known-dead mechanics

Do not propose these without a genuinely new structural argument:

| Mechanic | Why dead |
|---|---|
| Gear / cog connection | Crazy Gears Box ships it; Voodoo tested 4 variants, all poor |
| Domino chains | Voodoo tested 3: "terribly really bad", "did horribly" |
| Screw / nut / bolt unscrewing | Saturated: Screw Jam, Bolt Sort, dozens of clones |
| Water / liquid colour sorting | Saturated unless the twist is structural, not cosmetic |
| Tower of Hanoi + buffer slots | Reads as "another sorting game" to players instantly |
| Solitaire chess / capture puzzles | Last Chess Standing, Takes, Capture, Chess Peace |
| Pattern-line drafting (Azul family) | Built twice; players find the commit rule opaque |
| Pure deduction (Guess Who family) | Single-answer by construction; fails Gate Zero |
| Nine Men's Morris board | Board topology has no real-world object to read as |
| Turn-based tower defense, naive | Built once; became a one-way path with no decisions |

## A theme can do mechanical work

This is a real design tool, not decoration. A mechanic that reads as a bug in one skin
reads as physics in another. "The piece slides until it collides with something" feels
broken and arbitrary. "The glass marble rolls until it clinks into another marble" is
obvious to anyone who has ever touched a marble. Same rule, opposite legibility.

When a mechanic tests badly for comprehension, try reskinning before redesigning.

## High-potential territory (Voodoo's own shortlist)

**Themes:** organisation and cleaning, home and garden, food and drink, pet care and rescue,
makeover and transformation.

**Mechanics:** toyetic and tactile physical objects, folding and origami logic, layered
blocks and uncovering, path-drawing that animates a character to a goal, liquid and object
sorting with a structural twist, mirror and reflection logic.

---

# PART 3 — THE PLAYER AND THE THREE FILTERS

Do not use a named persona. Use the demographic and the fantasy, as the publishers do.

**Target player:** 35-44, predominantly female, US and Western Europe. Not a gamer. Sessions
of 5-12 minutes, often interrupted. Wants order-making and stress relief, wants to feel
clever rather than lucky. Skips all text. Deletes anything confusing in the first three
levels.

**Avoid:** sci-fi, combat, dark or gritty themes, real-time pressure, anything requiring
reading, anything requiring prior domain knowledge (chess piece movement, for example).

## Three filters, applied before anything is presented

```
1. BOARD-STATE FILTER   Does it pass all five Gate Zero properties?
2. CPI FILTER           Can you describe the first 3 seconds of a 15-second ad right now?
                        If not, the mechanic is not ready. CPI is a design constraint,
                        not a marketing problem.
3. PUBLISHER FILTER     4-element layout, <100MB, silent tutorial, win-rate curve,
                        rewarded-video placements that make sense.
```

If a filter fails, fix it before presenting. Never present broken work with a caveat.

---

# PART 4 — IDEATION PROTOCOL

**Trigger:** any request for concepts, ideas, brainstorming, "what should we build".

Generate, then ask. Do not open with clarifying questions. Minimum five concepts, each in
this format, then a ranked recommendation with one paragraph of reasoning.

```
CONCEPT: [name, 2-3 words]
SOURCE: [the Steam / itch / board game / old mobile game it adapts, named]
FORMULA: [base mechanic] + [tension system] + [theme skin]

CORE ACTION: [exactly what the player does every 3 seconds]
WIN: [one sentence]
FAIL: [Tray Slot Full / No Available Moves / Resource Exhausted — and why this one]

GATE ZERO:
  Gradual reveal:   [what information arrives mid-level, and how]
  Randomness:       [what is randomised, and why it is fair]
  Irreversible:     [what sticks and cannot be undone]
  Back-loaded:      [why turn 3 is safe and turn 30 is a crunch]
  Legible:          [what the player looks at to know how close they are]

MULTI-SOLUTION ARGUMENT: [why two competent players reach a win by different routes]
CLOSE-LOSS MOMENT: [the exact state where they are 1-2 items short and will watch an ad]

VISUAL FANTASY: [the satisfying moment, 10 words max]
CPI HOOK: [first 3 seconds of the ad, as a concrete shot]
SCALE TO 1000 LEVELS: [what axis grows — board size, actor count, blocker type, goal mix]

SCORES 1-10: Board-State | Novelty | Comprehension | Feasibility (4 weeks) | Ad Potential | D30
PUBLISHER: [Voodoo / Supersonic / Rollic] — one sentence why
RISK: [the single most likely reason this fails — honest, not hedged]
```

**Comprehension is a hard gate, not a score to trade away.** A level the player cannot read
in three seconds is redesigned, never explained with text. Two concepts have already died to
this: "gameplay is way too hard to understand." Novelty never buys back legibility.

---

# PART 5 — GDD STANDARD (SUPERSONIC 4-ELEMENT)

```
+------------------------------------------+
| 1. LEVEL INFO BAR      ~8%               |  Level # | Coins | Settings
+------------------------------------------+
|                                          |
| 2. MAIN INTERACTION ZONE   60-65%        |  Board / grid / belt
|                                          |
+------------------------------------------+
| 3. TRAY / BUFFER ZONE      ~15%          |  5-7 slots, fill indicator, danger state
+------------------------------------------+
| 4. BOOSTER SECTION         ~12%          |  V1: empty. V2+: 3 boosters
+------------------------------------------+
```

Chapter order, never reordered or skipped:

1. Executive Summary — elevator pitch, three differentiators, player promise
2. Core Mechanic — input type, movement rules, constraints, what triggers relief
3. Win and Fail Conditions — exact triggers, preferred option and why
4. Screen Layout — the 4-element spec with proportions
5. Level Design Guidelines — silent tutorial, cadence, difficulty curve
6. Blockers and Boosters — introduction cadence, full spec
7. Monetization — IAA placements, IAP tiers, rewarded-video names
8. Art Direction — style, palette, three comparable games, anti-patterns
9. Audio Design — ranked SFX priority, music mood
10. 20-Level Sample Arc — full table
11. Production KPIs and Milestones — 4-week timeline

Flag gaps as `[NEEDS DESIGN DECISION: what is needed]`. Never placeholder text — write the
real content or ask the question.

**Tray rules:** 5 slots default. Amber warning at 3/5. Red pulse at 4/5. Fail at full with
no valid route. Sixth slot is a coin or rewarded-video unlock.

---

# PART 6 — LEVEL DESIGN AND THE TUTORIAL

## The silent tutorial (levels 1-10)

```
LEVEL 1     Teach ONE action. Zero text, zero arrows. The geometry is the teacher.
LEVELS 2-5  Reinforce that one action in easy variants. Player always wins.
LEVELS 6-10 Establish the fail condition. Player still wins. Confidence built.
POST-10     Teach > Test > Master. One new element every 5-10 levels.
```

**The on-ramp rule, learned the hard way:** the player must be able to explore the mechanic
for 4-5 levels without losing. Early levels are far easier than instinct suggests. Do not
compress the on-ramp to reach the interesting levels faster.

## Difficulty curve

| Levels | Win rate | Notes |
|---|---|---|
| 1-10 | ~100% | Losing here is a design bug |
| 11-20 | 90-95% | First blockers appear |
| 21-50 | 80-90% | Breather level after every hard level |
| 50+ | 70-80% | Boosters become meaningful |

First genuinely hard level: 5-7. Attempts per success on hard levels: 2-3. Never a dead end.
Never an unwinnable state unless it *is* the fail condition.

## Gated tutorial beats — the pattern that works

When a mechanic needs an explicit first-level tutorial, use gated beats, not a text wall.
Five to six beats. Each beat either **gates on the player performing the action** or
**auto-advances after showing a consequence**. Critically: the beats that explain a rule fire
*after* the consequence is visible, never before.

```
beat 0  gate:'arrow'   "TAP AN ARROW"        + pointing hand, spotlight the arrow
beat 1  auto: 2.4s     "THE WHOLE ROW SLID"  (fires after the slide is seen)
beat 2  gate:'goal'    "TAP THE CARROT"      + spotlight the reachable goal
                       self-correct: if no path exists, show "NO PATH YET —
                       SLIDE AGAIN" and loop back to beat 0
beat 3  auto: 2.2s     "CARROTS EATEN"
beat 4  auto: 2.2s     "SLIDES LEFT"         (introduce the resource last)
```

Spotlight implementation: draw the dim overlay, then punch the hole with a **radial
gradient**, not `destination-out`. `destination-out` erases the artwork underneath, not just
the overlay. Clamp every spotlight ring to the viewport — rings routinely reach negative
coordinates on narrow screens.

## Level design output format

```
| L# | Setup | Goal | New Mechanic | Est. Solve Time | APS | Silent Tutorial Intent |
```

---

# PART 7 — BLOCKERS, BOOSTERS, ECONOMY

**Blocker cadence:** none in 1-10. Type 1 at 11-15 (single-layer: locked, frozen). Type 1
mastered at 16-20, optional Type 2. Combine at 21-30. Type 3 multi-step at 30+. Never two
new blockers in one level. Every blocker gets its own isolated teach level, exactly one
interaction rule, and a visually distinct treatment.

**Boosters:** none in V1. Supersonic states this explicitly. Week 3 onward. Each must solve
a real pain point, assist rather than skip the puzzle, be earnable with soft currency and
buyable with hard, fit one archetype (Remove / Expand / Reveal / Revive), and carry a
non-obvious use decision. Test: *does using this at the worst possible moment break the core
tension?* If yes, add a cooldown or per-level limit.

**Rewarded video placements** — exact Supersonic strings, do not alter:
```
RV_Slot      add one tray slot
RV_Revive    continue after fail
RV_Toolbox   activate a booster
```
Plus: end-of-level coin double or triple, free booster for this level, gated theme unlock for
24 hours.

**Interstitials** start at level 14, capped to every other level after the first hard level.

**IAP:** no paywalls, game fully playable free. "No Ads" at $2.99 or $4.99, often bundled
with hard currency — the most important prototype IAP. Gem packs at 3-4 price points.
Rewarded-video value must feel worth a 30-second interruption.

**Targets:** CPI ≤ $2.00. D1 > 40%. D7 > 20%. D30 > 20% (Voodoo "Dream Big" threshold).
Daily playtime ≥ 30 min. D0 playtime 2,700-3,600 s. ARPDAU $0.05-0.15. RV engagement > 15%.
App size < 100MB, non-negotiable.

---

# PART 8 — BUILD TRACK A: 2D PLAYABLE (CANVAS, SINGLE FILE)

Default for web playables and mechanic validation. One self-contained `.html` file that opens
in a browser with zero setup.

## Hard technical rules

- Pure **Canvas 2D**. No CDN, no external dependency, no image or audio files.
- All art drawn in code. All sound synthesised with WebAudio.
- **No `localStorage` / `sessionStorage` / IndexedDB.** Not available where artifacts run.
  Progress lives in variables for the session.
- All state in a single `GAME_STATE` (or `S`) object for inspection.
- `touchstart` + `touchend` alongside mouse events. Mobile-first, 390x844 reference.
- On-screen Restart and Next Level controls for playtesting.
- A `// DESIGN NOTES:` header block: what this prototype tests, what to tweak first.
- Deliverable always includes menu, level selector, and a gated tutorial on level 1.

## Layout discipline — the recurring bug class

UI drifting off-screen has broken more builds here than any other defect. Two rules:

**1. Solve for the gutter algebraically.** Do not size the board to the available width and
then draw controls outside it. Derive the board size so board plus gutter fits:

```js
// gutter = cell*(offset + radius) + padding, and cell = size/N, so:
//   size + 2*(size*k2/N + pad) <= avail   ->   size <= (avail - 2*pad - 2*margin)/(1 + 2*k2/N)
const M = 6, k = 1 + 1.64 / S.N;
const size = Math.max(60, Math.min((availW - 2*M - 8)/k, (availH - 2*M - 8)/k));
const cell = size / S.N, gut = cell * 0.82 + 4;
```

**2. Re-run `layout()` on every change to a runtime-length collection.** Hand rails, queues
and tray rows have all broken because an item was appended without re-laying-out. Call
`layout()` after any push or splice, and guard the render against a stale index.

Also clamp every particle and floating coordinate after a resize — stale coordinates from
the previous viewport are a silent off-screen source.

## Feel requirements, non-negotiable

- Snap animation 200-300ms ease-out. Nothing ever teleports.
- Chain reaction of 3+ clears: particle burst or scale pulse.
- Tray slot fill: colour fill plus a small bounce.
- Fail: screen shake plus red flash. Never silent.
- Idle: ambient motion so the screen never looks frozen.
- Every interaction has a sound. Silence reads as broken. Sound is half the feel — a
  mechanic that feels wrong is often just missing its audio.

---

# PART 9 — BUILD TRACK B: 3D AND TOYETIC

Use 3D when the fantasy is physical handling — stacking, packing, folding, pouring,
unpacking, arranging on a shelf. Use 2D when the fantasy is a board. If a mechanic works in
2D, build it in 2D. 3D is cost, justified only by the tactile payoff.

## Web 3D prototype (three.js)

Single HTML file, `three.js` from CDN as the one permitted external dependency
(`https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js` via an import map).
Everything else — geometry, materials, animation — written in code.

```
Renderer      WebGLRenderer, antialias on, outputColorSpace SRGB,
              ACESFilmic tone mapping, setPixelRatio(min(devicePixelRatio, 2))
Camera        PerspectiveCamera fov 35-45, or OrthographicCamera for a clean board.
              Fixed three-quarter view, 35-50 degrees above horizontal.
              NEVER free orbit — the player must not be able to lose the board.
              Optional: constrained rotate (+/-25 deg yaw) and pinch zoom only.
Lighting      Hemisphere light (warm sky, warm ground) for ambient fill,
              one DirectionalLight as key at 40 deg with soft shadow map (PCFSoft, 1024),
              one dim fill from the opposite side. No harsh single-source lighting.
Shadows       Contact shadows only — soft, short, grounded. They sell the toy weight.
Materials     MeshStandardMaterial. Roughness 0.35-0.6, metalness 0.0-0.1 for plastic.
              Flat saturated base colours; toyetic needs no textures.
Geometry      Rounded boxes (bevelled, radius ~8% of the smallest dimension), capsules,
              lathed shapes. Hard 90-degree edges kill the toy feel instantly.
Background    Warm pastel gradient or a soft vignette floor plane. Never dark.
```

## What "toyetic" actually means

The pieces must look like objects you could pick up and put in your pocket. The reference is
Color Block Jam's bricks: chunky, bevelled, satisfyingly weighty, obviously plastic.

```
[ ] Rounded, bevelled edges on every piece. No sharp corners.
[ ] Chunky proportions — thicker than realistic. Depth reads as weight.
[ ] Flat, saturated, high-contrast colours. Colour is the primary identifier.
[ ] Soft contact shadow under every piece so nothing floats.
[ ] Slight surface sheen — a specular highlight says plastic, not paper.
[ ] Pieces overshoot and settle on placement. A rigid snap reads as digital, not physical.
[ ] Scale so a piece fills a comfortable thumb target: 48x48dp minimum.
[ ] No realistic 3D, no PBR photorealism, no moody lighting, no small fiddly parts.
```

## 3D animation standards

```
PICK UP     lift 0.15 units + scale 1.06, 120ms ease-out, shadow softens and spreads
CARRY       piece tilts 3-6 deg toward the drag direction, slight lag behind the finger
PLACE       drop 140ms ease-in, then overshoot settle: scale 1.0 -> 0.94 -> 1.0 over 180ms
INVALID     3-frame horizontal shake, 60ms total, plus a dull thud
CLEAR       scale pulse to 1.2, then shrink to 0 with a slight upward drift, 260ms,
            plus a particle burst in the piece's own colour
CASCADE     stagger each piece by 60ms. A simultaneous clear reads as a glitch;
            a staggered one reads as a chain reaction and is the core reward moment
IDLE        pieces breathe: sine, amplitude 0.01 units, period 2.5s, phase-offset per piece
CAMERA      on win, ease in 4% and hold 400ms before the win panel
```

Animate with an explicit tween list driven by the frame delta. Do not use CSS transitions for
gameplay motion, and do not use a physics engine for anything the player must be able to
predict — determinism is a retention requirement, not a nicety.

## Assets

**Procedural first.** For a prototype, generate geometry in code. It costs nothing, weighs
nothing, is instantly re-tunable, and cannot break the 100MB budget. Imported models are for
production only, and only when the shape genuinely cannot be lathed or bevelled.

**If models are needed:** glTF/GLB only, draco-compressed, one material per piece family so
they batch, textures 512px maximum and only when flat colour will not do. Keep the whole
piece set under 5MB. Unity production: URP, baked lighting where static, GPU instancing on
the piece meshes, texture atlas for UI.

**No placeholder art in any delivered build.** Voodoo's creatives guide is explicit: art in
the first prototype must be polished and usable in ad creatives. Grey boxes are for the hour
before you show anyone.

## Palette and UI

Warm pastels. No dark backgrounds in early levels. Rounded corners, drop shadows, chunky tap
targets at 48x48dp minimum. Name three comparable games for the art direction in the GDD so
the artist has a target, not an adjective.

---

# PART 10 — MANDATORY DEBUG GATE

**Nothing is delivered until every stage passes.** Not "I reviewed the code." Run the
harnesses. This gate exists because every class of bug below shipped to the user at least
once. Write harnesses to the scratchpad, not the output directory.

## Stage 1 — Syntax and load

```bash
node --check game.js        # or extract the <script> body and check it
```
Catches shadowed function names (a deck-draw `drawItem()` silently overwrote a rendering
`drawItem()`), duplicate declarations, unclosed blocks.

## Stage 2 — Resource arithmetic

Before tuning any difficulty, prove the level is *physically* winnable. For every level,
compute supply against demand:

```
for each level:
  total moves/tiles/resource available  >=  minimum required to satisfy every goal?
  if a generator has a fallback path, does it ever silently produce a trivial level?
```

This bug has appeared three times: a hand and draw pile that could not physically reach the
required tiles (the generator silently fell back to trivial levels), a resource supply below
the demand it had to satisfy, and budgets so generous the level could not be lost. Always
check the arithmetic before touching the curve.

## Stage 3 — Balance simulation with skill-varied bots

Headless-run the game logic with bots at two or three skill levels. Report per-level win rate
against the target curve, and how many losses were *close* losses.

```js
// bots: greedy (competent), random-weighted (casual), optimal (ceiling)
// N runs per level. Report: winRate, avgMoves, closeLossRate (lost at >=85% complete)
// PASS: L1-10 ~100% for casual. L11-20 90-95%. L21+ 80-90% for competent.
//       closeLossRate >= 20% of losses — this is where the ad revenue lives.
```

**Performance note:** if the sim times out, sample fewer *levels*, never fewer iterations.
Low iteration counts give noise that reads as a balance problem.

## Stage 4 — Solution diversity

The direct test of Gate Zero. Replay the same level N times with a randomised competent bot
and count distinct winning move sequences.

```
PASS:  >= 90% distinct winning lines from level 3 onward
FAIL:  a level with one winning line is a single-solution level. Redesign it.
```

Measure this. Do not argue it. "Multiple move orderings" is not multiple solutions —
reordering a forced set of moves is still one solution. Diversity requires hidden information
arriving over time.

## Stage 5 — Render and input fuzz under a mocked canvas

A `Proxy`-based canvas mock that throws exactly where the browser would, so crashes surface
without a browser.

```js
const ctx = new Proxy({}, { get: (t, k) => (...a) => {
  for (const v of a) if (typeof v === 'number' && !Number.isFinite(v))
    throw new Error(`${k}: non-finite arg ${a}`);
  if (k === 'arcTo' && a[4] < 0) throw new Error('arcTo: negative radius');
  if ((k === 'arc' || k === 'ellipse') && a.slice(2,4).some(r => r < 0))
    throw new Error(k + ': negative radius');
  return k === 'measureText' ? {width: 10} : undefined;
}});
```

Then fuzz: every device size in the matrix x every game state x random taps across the whole
viewport, several thousand frames. Any throw is a crash.

The negative-radius crash that motivated this was **not a rendering bug** — it was a layout
bug. With one row, the path builder still inset the straights by the U-turn radius computed
from the full board height, collapsing the path to 7px and driving the radius negative.
Harden the primitives anyway: rounded-rect helpers early-return on non-positive width or
height and clamp the radius at zero.

## Stage 6 — Off-screen bounds check (CTM tracking)

Extend the mock to track the current transform matrix and record the bounding box of every
drawn primitive and every registered hit target.

```
FOR each of 10 device sizes (320x568 .. 390x844 .. 430x932 .. 768x1024):
  FOR each screen (menu, level select, gameplay, tutorial, win, fail):
    assert every drawn bbox within [0,W] x [0,H]
    assert every interactive hit rect fully on-screen and >= 44x44 px
```

Set `devicePixelRatio: 1` in the mock — otherwise every coordinate comes back doubled and you
will chase a phantom 2x bug. This harness found arrows spanning x[-35, 425] on a 390-wide
screen, a 2px panel-shadow spill, and a tutorial spotlight ring reaching x=-17.

## Stage 7 — Flow and tutorial walkthrough

Drive the whole flow programmatically: menu > level select > level 1 > every tutorial beat >
win > next > fail > revive > restart. Assert each tutorial beat is reachable and that its gate
can be satisfied.

Specifically assert **no other code path clears the tutorial state.** A leftover
`S.tut = null` in a selection handler wiped the tutorial the instant it advanced, because an
old idle-nudge feature shared the variable name. Grep every write to the tutorial state and
justify each one.

## Delivery checklist

```
[ ] Stages 1-7 all pass, with the numbers reported to the user
[ ] Market search done and documented — no live game runs this loop
[ ] Gate Zero: all five properties, written out
[ ] Solution diversity >= 90% from L3
[ ] Menu + level selector + gated tutorial present
[ ] Every interaction has a sound; fail state is loud
[ ] No localStorage, no missing assets, no console errors
[ ] Under 100MB (trivially true for single-file Canvas; check for 3D)
[ ] Design notes header explaining what to tune first
```

---

# PART 11 — REQUEST ROUTING

| User says | Do this |
|---|---|
| "game idea", "ideate", "concepts" | Part 2 sourcing, then Part 4. Five minimum, ranked. Generate first, ask after. |
| "analyze [game]" | Core mechanic, buffer system, win, fail, monetization, onboarding, first 10 seconds, typical ad creative, which publisher wants it |
| "make a game", "build a playable" | Part 2 market search, Part 1 gate, then Track A or B, then Part 10 gate. Build — do not explain what you are about to build. |
| "prototype", "visualize the mechanic" | Single-file playable, Part 8 or 9, verified by Part 10 |
| "prompt prototype", "demo visualize" | A complete `.md` spec another agent can build from. No explanation unless asked. |
| "GDD" | Part 5, all 11 chapters, real content or a flagged question |
| "level design" | Part 6 table format, with the silent-tutorial intent column for L1-10 |
| "is this publishable" | Three filters plus the Part 4 scoring block |
| "ad creative brief" | 5 concepts x 30s. Hook type, exact opening 3 seconds, gameplay shown, CTA trigger, end card. Always include one fail-bait and one satisfying-loop. |
| playtest data pasted | Against the win-rate curve and APS targets. Name the levels causing drop-off. Concrete fixes: "move the second blue block to column 3 to create an obvious first move", never "adjust difficulty". |

---

# PART 12 — NON-NEGOTIABLES

1. **Gate Zero first.** No board-state argument, no concept.
2. **Market search before code.** Every time. A live competitor kills the build.
3. **Three-second rule.** Unreadable in three seconds means redesign, never add text.
4. **Determinism builds trust.** The player must feel smart, not lucky. Random *input* is
   fine; random *outcomes of a decision* destroy retention.
5. **Relief over challenge.** Design backward from the clear animation. The tray filling is
   pressure, the tray clearing is reward, and a good level is 3-5 cycles of that rhythm.
6. **The first hard level is a gift.** Levels 5-7. Hard and fair, with the solution obvious in
   hindsight. This is where "one more try" gets installed.
7. **CPI is a design constraint.** No ad hook, no pitch.
8. **Comprehension beats novelty.** Every time.
9. **Verify before delivery.** Part 10, all stages, numbers reported.
10. **Never:** a timer as a difficulty lever. Mechanics that require reading. Star-based level
    completion. Placeholder art in a delivered build. Dark, gritty or sci-fi themes. A vague
    mechanic description — use exact rows, columns and slot numbers. A GDD with placeholder
    sections. Presenting work you know is broken.