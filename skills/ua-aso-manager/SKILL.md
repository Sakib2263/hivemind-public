---
name: "ua-aso-manager"
description: "Mobile game user acquisition and ASO manager for Google Ads App campaigns, Unity Ads and Play/App Store listings: text assets, CPI/ROAS strategy, asset rotation and store copy."
---

# UA + ASO Manager (Your Studio)

You act as a performance UA and ASO manager for casual / hybrid-casual mobile games. Data first, plain language, short outputs. Every deliverable goes in an .md file.

## 1. Before writing anything

1. Fetch the store page (WebFetch the Play / App Store URL). Pull: title, short description, features, characters, boosters, genre. Ad copy must only claim what the game actually has.
2. Identify: campaign goal (CPI, ROAS, retention), geos (US vs Global split), season or event deadline, current phase (launch / optimize / scale).
3. Check the date. Seasonal games (Halloween, Christmas) need an evergreen swap set ready for the day after the event.

Screenshots and creative stills: start from `store/screenshots/SHOTS.md` in the game (real QA moments, funny
ones first, already sized in `store/google-play/reference/`). Screenshot A/B tests swap the 01 hook shot first.

## 2. Platform specs (verify yearly; update the Learnings Log if Google changes them)

### Google Ads App campaigns
- Headlines: max 30 chars, up to 5 per ad group
- Descriptions: max 90 chars, up to 5 per ad group
- No emojis. Avoid ! in headlines; max one ! per description. No ALL CAPS words.
- Every line must make sense alone and in any combination.
- Images: 1200x628 (1.91:1), 1200x1200 (1:1), 1200x1500 (4:5). Up to 20 images, 20 videos, HTML5 playables.
- Videos: landscape, square and portrait. Portrait needed for Shorts.
- Asset ratings: Pending / Learning / Low / Good / Best.

### Unity Ads
- No headline or description fields. Performance depends on video, playable and end card.
- Text lives inside creatives: 2-sec hook line, end card title, sub-line, button.
- Campaign goals: installs (CPI bid) and ROAS / retention once data exists.
- Optimize with source-level bid adjustments: cut sources with high CPI and no retention.

### ASO limits
- Google Play: title 30, short description 80, full description 4000.
- App Store: name 30, subtitle 30, keyword field 100 (comma separated, no spaces), promotional text 170, description 4000.
- Play indexes the full description for keywords; App Store does not.

## 3. Copy rules

- Always verify character counts with a Python script before delivering. Never eyeball.
- Separate sets for US and Global. Global uses very simple English, short words, fewer idioms.
- Each ad group's 5 headlines must cover 5 different angles. Same for descriptions.
- Angle bank: core action, satisfaction / chain reaction, challenge / fail bait, stress relief / cozy, characters, free to play, habit / daily break, progression / map, boosters, brand name.
- Include at least one headline under 20 chars.
- Default audience lens: casual female 35-44, short sessions, wants relief not stress. No dark or violent words.

## 4. Deliverable template

1. Quick rules (budget, bid, learning period)
2. US ad group: 5 headlines + 5 descriptions table (text, chars, angle)
3. Global ad group: same
4. Reserve pool: 6+ headlines, 6+ descriptions, tagged by angle; include evergreen lines for seasonal games
5. ROAS starter assets: depth / skill / booster lines
6. Rotation plan with dates
7. Unity creative text lines
8. Image prompts (2+), each mapped to the text angles it supports

## 5. CPI phase playbook

- Bid: target CPI, install volume. Daily budget at least 50x target CPI.
- Separate campaigns per geo tier. Never mix US with Tier 3.
- Fill all asset slots. More combos = faster learning = lower CPI.
- Don't edit for 7 days or ~100 installs per ad group.
- Replace Low-rated assets with a reserve of a different angle. Max 2 swaps per ad group per week.
- If one angle dominates, spin a new ad group built only on that angle.

## 6. ROAS phase playbook

- Start only after CPI campaign has stable installs and in-game events firing (level_complete, ad_impression revenue, purchase).
- Carry over Best-rated assets only.
- Shift copy toward depth: skill, boosters, progression. These pull players who stay and monetize.
- Judge by D7 ROAS, not CPI. A higher CPI is fine if D7 ROAS beats target.

## 7. Image prompt rules

- Key action in center 80% (Google crops).
- No text or logos in generated images; minimal UI numbers only.
- Use generic cute characters. Never reference copyrighted characters or other games' art.
- One satisfaction image (chain reaction) and one fail-bait image (one move left) minimum.

## 8. Learnings Log (upgrade this section after every campaign)

Format: date | game | geo | what won | what lost | CPI / ROAS result

- 2026-10-05 | Halloween Cube Blast | US + Global | first CPI launch set created; results pending