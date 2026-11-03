# Research notes

Why the skill edits what it edits. Read this when a user pushes back on an edit,
or when deciding how hard to apply a rule.

## 1. Excess vocabulary

Kobak et al., Science Advances 2025 (arXiv 2406.07016). 15.1M PubMed abstracts,
2010-2024. 454 excess words in 2024 vs 190 during Covid; the 2024 set was almost
all style words, 66% verbs. Lower bound estimate: at least 13.5% of 2024
abstracts went through an LLM, up to about 40% in some subcorpora.

Editing consequence: verbs are the tell, not adjectives. Most word-swap advice
targets adjectives and misses the bigger signal.

Related: Gray 2024 found roughly 2x increases in `intricate` and `meticulously`
in 2023. Liang et al. 2024 flagged `pivotal`, `intricate`, `showcasing`, `realm`.

## 2. Linguistic fingerprints

Mizumoto et al. 2024 (Research Methods in Applied Linguistics) and Herbold et al.
2023, replicated in later corpus work. Comparing student essays to ChatGPT
essays, the AI text had:

- higher lexical diversity
- higher syntactic complexity
- more nominalizations (complex nominals)
- far fewer errors
- higher word counts

Human text had more modals, more epistemic markers, more discourse markers. A
random forest on these features hit 100% classification accuracy on their set.

Editing consequence, and it is counterintuitive: humanizing means simplifying.
Cut nominalizations, shorten, allow a plainer word, and add stance and hedging.
Advice to "use richer vocabulary" makes text read more like AI, not less.

## 3. Stylometry

O'Sullivan 2025 (Humanities and Social Sciences Communications 12:1708) applied
Burrows' Delta to human, GPT-3.5, GPT-4 and Llama-70b short stories. Human and
LLM texts occupy separate regions of stylometric space. Burrows' Delta works on
the most frequent words, mostly function words, so the difference is not about
topic vocabulary at all.

Zaitsu et al. 2025 (PLOS One) ran the same question across seven models in
Japanese: stylometric features separated LLM from human text, and in some
integrated features the separation was perfect. They also found newer models
sitting closer to human writing than older ones, so the gap is narrowing.

Editing consequence: swapping content words is not enough. Sentence structure,
function-word distribution and rhythm carry the signature.

## 4. Rhythm and burstiness

Burstiness is the variation in sentence length and structure across a text. AI
output has consistently lower burstiness and lower perplexity than human writing.
Detectors like GPTZero were built on exactly this pair. Human writers also vary
rhythm inside a paragraph, while AI holds one rhythm throughout.

Editing consequence: sentence-length standard deviation is the cheapest, most
reliable thing to check and fix.

## 5. Cohesion style

Corpus multidimensional analyses find AI text leaning on overt logical connectors
and referential markers to achieve cohesion, producing text that is coherent but
formulaic. Human text uses more implicit devices: collocation, ellipsis,
sequence.

Editing consequence: delete most sentence-initial connectors and check that the
paragraph still holds. If it does not, the ordering was doing no work.

## 6. Homogenisation

Padmakumar and He 2023 showed writing with an LLM reduces content diversity.
Kobak et al. raise the same worry for science: LLM-written introductions on a
topic converge on the same ideas and the same references.

Editing consequence: the strongest humanizing move is a specific detail no model
would have produced. A named person, a number from the actual data, a small
concrete failure.

## The detector caveat

Say this plainly to users who ask about detector scores.

Perplexity and burstiness detectors misclassify non-native English writers,
because learner writing is naturally lower-perplexity and lower-burstiness
(Pangram, 2025; Liang et al. 2023 found similar bias). Neurodivergent writers and
writers with disabilities are exposed to the same false positives. Detector
output is evidence of a style, not of authorship.

Two consequences:

1. Do not promise that edited text will pass a detector. Nothing can promise that.
2. If the user's aim is to pass off AI work where disclosure is required, say no
   and explain why. If the aim is better writing, or defending work they wrote
   themselves that got flagged, help fully.

## Sources

- Kobak, González-Márquez, Horvát, Lause (2025). Delving into LLM-assisted
  writing in biomedical publications through excess vocabulary. Science Advances
  11(27), eadt3813. arXiv:2406.07016. Word lists:
  github.com/berenslab/llm-excess-vocab
- O'Sullivan (2025). Stylometric comparisons of human versus AI-generated
  creative writing. Humanities and Social Sciences Communications 12:1708.
- Zaitsu et al. (2025). Stylometry can reveal artificial intelligence authorship,
  but humans struggle. PLOS One, 10.1371/journal.pone.0335369.
- Mizumoto et al. (2024). Identifying ChatGPT-generated texts in EFL students'
  writing. Research Methods in Applied Linguistics.
- Herbold et al. (2023). A large-scale comparison of human-written versus
  ChatGPT-generated essays. Scientific Reports.
- Padmakumar and He (2023). Does writing with language models reduce content
  diversity? arXiv:2309.05196.
- Wikipedia:Signs of AI writing, WikiProject AI Cleanup.
