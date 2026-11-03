---
name: humanizer
description: |
  Edit text so it reads as human-written: measure it first, then fix what the
  measurements flag. Use when reviewing, rewriting, or de-slopping any draft,
  or when someone says text "sounds like AI". Combines Wikipedia's "Signs of AI
  writing" pattern list with findings from 2024-2026 research (Kobak et al.
  2025 excess vocabulary; Mizumoto/Herbold linguistic fingerprints; O'Sullivan
  2025 stylometry; burstiness and perplexity work). Fixes: excess style words,
  low sentence-length variation, over-nominalization, connector stacking,
  missing hedges and stance, inflated significance, rule of three, em dash
  overuse, and voiceless prose.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# Humanizer (v3.0)

Most "humanizing" advice is a list of banned words. That helps, but word swaps
alone do not work: stylometric studies separate AI from human text using
function words and sentence rhythm, not content vocabulary (O'Sullivan 2025).
So this skill works in two passes.

Pass 1 measures the draft. Pass 2 edits what the measurements flag, plus the
pattern list.

## What the research actually says

Read `references/research-notes.md` for sources and caveats. The short version,
because it changes what you edit:

1. AI text over-uses a specific set of style words. Kobak et al. analysed 15.1M
   PubMed abstracts and found 454 words with abnormally high frequency in 2024,
   about 66% of them verbs. `delves` appeared 28x more often than expected.
   Full list in `references/excess-words.md`.
2. AI writes with *more* lexical variety, *more* syntactic complexity and *more*
   nominalizations than humans, not less. Human writing has more modals,
   epistemic markers and discourse markers. Do not "elevate" the prose to
   humanize it. Go the other way: plainer nouns, more verbs, more stance.
3. AI sentences cluster around the same length. Human sentence length varies
   sharply, including inside a single paragraph. This is the strongest single
   signal in most comparisons.
4. AI leans on explicit connectors (Additionally, Moreover, Furthermore,
   Consequently) to hold paragraphs together. Humans more often let sequence and
   collocation do that work.
5. AI output is homogenised: same ideas, same structure, same references across
   different runs. Specificity is the cure, not vocabulary.

Important limit: AI detectors are unreliable and misfire on non-native English
writers, who naturally write with lower burstiness and lower perplexity. The
goal here is writing that is concrete and has a voice, not a score. Say so if
the user's real goal is beating a detector.

## Pass 1: measure

For anything longer than a paragraph, run `scripts/analyze.py` on the text if
Bash is available:

```
python3 scripts/analyze.py draft.md
```

It reports sentence-length mean and standard deviation, longest and shortest
sentence, excess-word hits with line numbers, connector density, nominalization
density, hedge and first-person counts, em dash count, and rule-of-three
candidates. No dependencies beyond the standard library.

If you cannot run it, eyeball the same things. Rough flags, not laws:

| Signal | Flag when | Fix |
|---|---|---|
| Sentence length SD | under about 5 words | Break one sentence in three; leave one long |
| Longest sentence | under 25 words in a 400+ word piece | Let one sentence run |
| Shortest sentence | over 10 words | Add a short one. Like this |
| Excess style words | more than 1 per 100 words | Swap for plain verbs |
| Connectors at sentence start | more than 1 in 5 sentences | Delete most; order carries the logic |
| Nominalizations (-tion, -ment, -ity, -ance) | more than 3 per 100 words | Turn back into verbs |
| Hedges and modals | near zero | Add real uncertainty where it exists |
| Em dashes | more than 1 per 300 words | Comma, full stop, or parentheses |
| Paragraph lengths | all within a sentence of each other | Vary them |

Report the numbers to the user before editing when they asked for a review
rather than a rewrite.

## Pass 2: edit

Work in this order. Earlier items change more text.

### 1. Cut the significance inflation

Claims about what something represents, symbolizes, underscores, or marks a
shift toward. Delete the claim, keep the fact.

Before: The 1989 founding marked a pivotal moment in the evolution of regional
statistics, reflecting a broader movement toward decentralization.
After: The institute was founded in 1989 to publish regional statistics
separately from the national office.

### 2. Replace excess style words

Check hits against `references/excess-words.md`. Most map to a plain verb:

delve into -> examine, look at
underscore, highlight, emphasize -> show, or delete
showcase -> show
leverage, harness, utilize -> use
facilitate, enable -> let, help
encompass -> include, cover
demonstrate -> show
ensure -> make sure, or delete
crucial, pivotal, key -> important, or delete
comprehensive, robust, nuanced -> delete or replace with the actual property
realm, landscape, tapestry -> the actual noun (field, market, industry)

Do not swap one excess word for another on the list.

### 3. Un-nominalize

"The implementation of the optimization resulted in an enhancement of
performance" -> "Optimizing it made it faster." Verbs carry the sentence.

### 4. Fix the rhythm

Read it aloud. If every sentence lands in the same 15-to-20-word range, break
some and merge others. Vary rhythm inside paragraphs, not just across them.
Human paragraphs often open wide, get specific, then land short.

### 5. Strip the connector scaffolding

Delete most sentence-initial Additionally, Moreover, Furthermore, Consequently,
Overall, In conclusion. If the paragraph stops making sense without them, the
order is wrong; fix the order.

### 6. Add stance and hedging back

This is the one most edits miss. Humans mark what they are unsure of, what they
think, and what they were surprised by. Add modals (might, seems, probably,
I think, as far as I can tell) where the writer genuinely does not know, and cut
hedges where they do. Both directions matter: over-hedging is also an AI tell.

### 7. Get specific

Replace "experts argue", "industry reports", "several studies" with a named
source, or drop the claim. Replace category words with instances: not "various
stakeholders" but "the two vendors and the finance team".

### 8. Kill the closing uplift

Delete "the future looks bright", "exciting times ahead", "a step in the right
direction". End on a fact, an open question, or nothing.

### 9. Surface patterns

Em dash overuse, mechanical boldface, bolded inline-header lists, title case in
headings, emojis, curly quotes, negative parallelism ("not just X, it's Y"),
rule of three, false ranges ("from X to Y" where X and Y aren't a scale),
synonym cycling for the same referent, chat artifacts ("I hope this helps",
"Great question"), knowledge-cutoff hedges.

Full catalogue with before/after examples: `references/patterns.md`.

## Voice

Clean is not the same as human. A draft with every banned word removed can still
read like nothing was at stake.

- Have a position. React to facts, don't only report them.
- Let mixed feelings show. "Impressive and a bit unsettling" beats "impressive".
- Use I where it fits. It is honest, not unprofessional.
- Leave some mess. An aside, a half-finished thought, a tangent.
- Be specific about feeling: not "concerning" but what exactly is worrying.

Do not fake this in text where it does not belong. A release note does not need
a soul; it needs to be short and correct. Match the register the user is in.

## Output

Default: the rewritten text, then a short list of what changed and why.

If the user asked for a review rather than a rewrite, lead with the Pass 1
numbers and the flagged lines, and offer the rewrite.

If the user gave a long file, edit it in place and summarise the edits rather
than reprinting the whole thing.

## Reference files

- `references/excess-words.md` — the 291 excess style words from Kobak et al.
  2024, plus the 10 common markers and replacement table.
- `references/patterns.md` — the full 24-pattern catalogue with examples.
- `references/research-notes.md` — sources, findings, and the detector caveat.
- `scripts/analyze.py` — the Pass 1 measurement script.
