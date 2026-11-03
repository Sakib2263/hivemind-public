# Monetization Design Protocol
## reference: monetization.md

---

## V1 ECONOMY (Prototype Submission Standard)

Per Supersonic Playbook — keep it simple for V1:
- **Starting currency:** 400 Gold
- **Per level reward:** 20 Gold
- **Booster cost:** None (V1 has no boosters)
- **RV placements (V1):** `RV_Slot` and `RV_Revive` only
- **Interstitials:** Begin at Level 14. Every level after that.
- **No IAP required for V1**

---

## RV PLACEMENT DESIGN (Non-Negotiable Names)

Write these EXACTLY as shown — Supersonic SDK requirement:

| Placement | Name | Trigger Moment | Value Prop |
|---|---|---|---|
| Tray slot | `RV_Slot` | When last tray slot fills (danger state active) | "+1 tray slot for this level" |
| Revive | `RV_Revive` | Immediately after fail state triggers | "Continue from 3 moves before fail" |
| Toolbox | `RV_Toolbox` | V2+ only — when player stuck 45+ sec | "Unlock one booster/wildcard" |

**RV Offer Timing Rules:**
- `RV_Slot`: Only offer when ≤ 1 tray slot remains. Offering when 3+ slots free = low uptake.
- `RV_Revive`: Offer ONCE per fail. Do not loop the offer.
- Both: Never offer before Level 5 — too early, player hasn't invested enough to care.

---

## V2+ FULL ECONOMY (Post-KPI Build)

### Soft Currency (Gold/Coins)
- **Sources:** Level completion (20/level), bonus objectives, RV coin multiplier
- **Sinks:** Continues (150–250 coins), Boosters (100–200 coins each), Slot expansion (200 coins)
- **Balance target:** Player earns enough to retry 1 hard level per session without paying

### Hard Currency (Gems)
- **Sources:** IAP packs only (tiny amount for milestones to teach value)
- **Sinks:** Skip level (convenience), booster bundles, premium cosmetics
- **V1 purpose:** Test purchase intent, not revenue

### IAP Offers
| Offer | Price | Contents |
|---|---|---|
| No Ads | $2.99–$4.99 | Remove interstitial ads |
| Starter Pack | $0.99 | 5× Hammers + 500 coins (one-time) |
| Booster Bundle | $2.99 | 10× each booster type |
| Gem Pack | $4.99 | 1000 gems |

**The most important IAP is "No Ads"** — always offer it, always test $2.99 vs $4.99.

---

## D0 PLAYTIME ENGINEERING

Target: 2,700–3,600 seconds (45–60 minutes) on Day 0.

This is critical for eCPM quality on ad networks. Hit this by:
1. Level duration: 5–7 min average (20 levels = 100–140 min total possible)
2. Retry loop: Hard levels at L5–7 generate 3–8 retry sessions (adds 10–30 min)
3. RV friction: RV_Revive viewed = +2–3 min session extension per viewing
4. FTUE length: Keep tutorial under 5 min total — get to gameplay fast

---

## ARPDAU TARGETS

| Metric | Prototype Target | Scaled Target |
|---|---|---|
| ARPDAU (IAA-heavy) | $0.05–$0.08 | $0.10–$0.15 |
| RV engagement rate | > 15% of sessions | > 25% |
| IAP conversion | 1–3% (test signal) | 3–5% |
