#!/usr/bin/env python3
"""Measure AI-writing signals in a text file.

Usage: python3 analyze.py draft.md [--json]

Reports sentence-length variation, excess style word hits, connector density,
nominalization density, hedging and first-person counts, em dashes, and
rule-of-three candidates. Standard library only.

Flags are heuristics, not verdicts. Read them alongside the text.
"""

import json
import re
import statistics
import sys
from pathlib import Path

# High-signal subset of the Kobak et al. 2025 excess style words, plus the
# 10 common markers. Full list in references/excess-words.md.
EXCESS = """
accentuate adept adhering akin align aligning aligns alongside amidst
bolster bolstering burgeoning capabilities comprehensive comprising
crucial cultivating delineate delve delved delves delving discern
discerning elevate elevating elucidate embracing emphasize emphasizing
empower enabling encompass encompassing endeavor enduring enhance
enhancing ensuring evolving exhibited facilitate facilitating foster
fostering foundational garner garnered groundbreaking harness harnessing
heighten hinder holistic illuminate imperative innovative insights
integral interconnectedness interplay intricacies intricate intricately
invaluable landscape leverage leveraging meticulous meticulously
multifaceted navigate navigating necessitate notable notably noteworthy
nuanced paving pinpoint pioneering pivotal poised profound pronounced
realm realms remarkable renowned resonate revolutionize robust
scrutinize seamless seamlessly showcase showcases showcasing solidify
spanning streamline streamlining tapestry testament thorough
transformative uncharted underscore underscores underscoring unlocking
unparalleled unravel unveil unveiling utilize utilizing vibrant
""".split()

CONNECTORS = [
    "additionally", "moreover", "furthermore", "consequently", "however",
    "therefore", "thus", "overall", "in conclusion", "importantly",
    "notably", "ultimately", "indeed", "nevertheless", "in addition",
]

HEDGES = [
    "might", "maybe", "probably", "seems", "seem", "i think", "i suspect",
    "roughly", "about", "sort of", "kind of", "not sure", "unclear",
    "could", "may", "perhaps", "apparently", "as far as",
]

FIRST_PERSON = re.compile(r"\b(i|i'm|i've|i'd|my|me|we|we're|our|us)\b", re.I)

NOMINAL = re.compile(r"\b\w{4,}(tion|ment|ity|ance|ence|ness|ization|isation)s?\b", re.I)
SENT_SPLIT = re.compile(r"(?<=[.!?])\s+")
RULE_OF_THREE = re.compile(r"\b[\w'-]+, [\w'-]+,? and [\w'-]+\b")


def sentences(text):
    parts = [s.strip() for s in SENT_SPLIT.split(text) if s.strip()]
    return [s for s in parts if len(s.split()) > 1]


def count_terms(lower, terms):
    hits = {}
    for t in terms:
        n = len(re.findall(r"\b" + re.escape(t) + r"\b", lower)) if " " not in t \
            else lower.count(t)
        if n:
            hits[t] = n
    return hits


def analyze(text):
    lower = text.lower()
    words = re.findall(r"[A-Za-z']+", text)
    wc = len(words) or 1
    sents = sentences(text)
    lengths = [len(s.split()) for s in sents] or [0]

    excess = count_terms(lower, EXCESS)
    connectors = count_terms(lower, CONNECTORS)
    hedges = count_terms(lower, HEDGES)
    nominals = NOMINAL.findall(text)
    first_person = len(FIRST_PERSON.findall(text))

    starts = sum(
        1 for s in sents
        if any(s.lower().startswith(c) for c in CONNECTORS)
    )

    per100 = lambda n: round(n * 100 / wc, 2)

    report = {
        "words": wc,
        "sentences": len(sents),
        "sentence_len_mean": round(statistics.mean(lengths), 1),
        "sentence_len_sd": round(statistics.pstdev(lengths), 1),
        "shortest_sentence": min(lengths),
        "longest_sentence": max(lengths),
        "paragraphs": len([p for p in text.split("\n\n") if p.strip()]),
        "excess_words_per_100": per100(sum(excess.values())),
        "excess_hits": dict(sorted(excess.items(), key=lambda x: -x[1])),
        "connector_starts": starts,
        "connector_start_rate": round(starts / max(len(sents), 1), 2),
        "connector_hits": connectors,
        "nominalizations_per_100": per100(len(nominals)),
        "hedges_per_100": per100(sum(hedges.values())),
        "first_person_mentions": first_person,
        "em_dashes": text.count("\u2014") + text.count("--"),
        "em_dashes_per_300": round(
            (text.count("\u2014") + text.count("--")) * 300 / wc, 2),
        "curly_quotes": sum(text.count(c) for c in "\u2018\u2019\u201c\u201d"),
        "bold_spans": len(re.findall(r"\*\*[^*]+\*\*", text)),
        "rule_of_three": RULE_OF_THREE.findall(text)[:10],
    }

    flags = []
    if report["sentence_len_sd"] < 5:
        flags.append("Low sentence-length variation (SD < 5). Break some, keep one long.")
    if report["longest_sentence"] < 25 and wc > 400:
        flags.append("No long sentence in a long piece.")
    if report["shortest_sentence"] > 10:
        flags.append("No short sentence anywhere.")
    if report["excess_words_per_100"] > 1:
        flags.append("Excess style words above 1 per 100 words.")
    if report["connector_start_rate"] > 0.2:
        flags.append("Connector scaffolding: over 1 in 5 sentences opens with one.")
    if report["nominalizations_per_100"] > 3:
        flags.append("Nominalization-heavy. Turn nouns back into verbs.")
    if report["hedges_per_100"] < 0.3 and wc > 300:
        flags.append("Almost no hedging or stance markers.")
    if report["em_dashes_per_300"] > 1:
        flags.append("Em dash overuse.")
    if report["curly_quotes"]:
        flags.append("Curly quotes present.")
    report["flags"] = flags
    return report


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print(__doc__)
        sys.exit(1)
    text = Path(args[0]).read_text(encoding="utf-8")
    r = analyze(text)

    if "--json" in sys.argv:
        print(json.dumps(r, indent=2))
        return

    print(f"words {r['words']}  sentences {r['sentences']}  paragraphs {r['paragraphs']}")
    print(f"sentence length: mean {r['sentence_len_mean']}  SD {r['sentence_len_sd']}"
          f"  range {r['shortest_sentence']}-{r['longest_sentence']}")
    print(f"excess style words: {r['excess_words_per_100']} per 100")
    if r["excess_hits"]:
        print("  " + ", ".join(f"{k} x{v}" for k, v in r["excess_hits"].items()))
    print(f"connector openings: {r['connector_starts']} "
          f"({r['connector_start_rate']} of sentences)")
    print(f"nominalizations: {r['nominalizations_per_100']} per 100")
    print(f"hedges: {r['hedges_per_100']} per 100   first person: {r['first_person_mentions']}")
    print(f"em dashes: {r['em_dashes']}  bold spans: {r['bold_spans']}"
          f"  curly quotes: {r['curly_quotes']}")
    if r["rule_of_three"]:
        print("rule-of-three candidates: " + "; ".join(r["rule_of_three"]))
    print()
    if r["flags"]:
        print("FLAGS")
        for f in r["flags"]:
            print("  - " + f)
    else:
        print("No flags.")


if __name__ == "__main__":
    main()
