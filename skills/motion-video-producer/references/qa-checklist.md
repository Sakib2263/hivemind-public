# QA Checklist

Run at three gates. Fix everything marked before moving on.

## Gate 1 — Script (before any code)
- [ ] Opens on the viewer's problem; product reveal by ~15% of runtime
- [ ] One idea per scene; every claim has a concrete visual
- [ ] VO word count fits the length (≈150 wpm); short cuts have their own VO
- [ ] Facts, names, contacts and prices come from project files or the user, not invented
- [ ] Invented examples (brand names, numbers) are flagged as illustrative
- [ ] Clear single CTA and tagline on the end card

## Gate 2 — Stills (`vidkit.py snap PROJECT CUT` for every cut, then look at every sheet)
- [ ] No text overlapping other text, cards, or characters
- [ ] Nothing important under the caption zone (y > 900)
- [ ] No clipped headlines or words cut off at card edges
- [ ] Colours consistent with the brand; contrast readable on dark background
- [ ] Logo renders (not the "Your Brand" fallback) when a logo was supplied
- [ ] Each scene's state at 80% looks finished (use `--at 0.3` too, to check entrances)
- [ ] Transition moments: snap at a scene start ± 0.1 s for flash/wipe/iris
- [ ] "JS errors: none"
- [ ] Short cuts: compressed scenes still readable

## Gate 3 — Final files (`vidkit.py verify PROJECT`)
- [ ] Every MP4 shows `OK`, has video + audio streams, duration matches the timeline
- [ ] Loudness about −14 LUFS (−16 to −13 is fine)
- [ ] Check sheet frames look like the stills (fonts loaded, logo present)
- [ ] File names match `config.names`

Things Claude cannot check alone (tell the user to check): how the voice sounds and pronounces names, music taste, overall pacing feel.
