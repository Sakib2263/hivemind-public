# Excess style words

Source: Kobak, González-Márquez, Horvát and Lause, "Delving into LLM-assisted
writing in biomedical publications through excess vocabulary", Science Advances
11(27), 2025. They compared word frequencies in 15.1M PubMed abstracts (2010-2024)
against a counterfactual projection from 2021-2022. Words far above the
projection are "excess words".

Findings that matter for editing:

- 454 excess words in 2024, against 190 at the Covid peak in 2021.
- Pre-2024 excess words were content nouns (covid, remdesivir). The 2024 set was
  almost entirely style words, 66% verbs and 14% adjectives.
- Sample ratios: `delves` 28x expected, `underscores` 13.8x, `showcasing` 10.7x.
- The 10 highest-impact common markers: across, additionally, comprehensive,
  crucial, enhancing, exhibited, insights, notably, particularly, within.

A hit is not proof of anything. These are ordinary English words and some are the
right word. Flag density, not single uses.

## Replacement table

| Excess word | Usually means |
|---|---|
| delve into | look at, examine, dig into |
| underscore, highlight, emphasize | show, or delete |
| showcase | show |
| leverage, harness, utilize | use |
| facilitate, enable | let, help |
| encompass, comprise | include, cover |
| elucidate | explain |
| demonstrate | show |
| ensure | make sure, or delete |
| pinpoint | find |
| streamline | simplify, speed up |
| foster, cultivate | build, grow, encourage |
| bolster | support, strengthen |
| garner | get, collect |
| necessitate | need, require |
| align with | match, fit |
| crucial, pivotal, vital, key | important, or delete |
| comprehensive, holistic | full, complete, or delete |
| robust | strong, reliable, or give the number |
| nuanced, intricate, multifaceted | complicated, or delete |
| seamless, seamlessly | smooth, or delete |
| innovative, groundbreaking, transformative | delete, say what it does |
| notable, remarkable, noteworthy | delete |
| realm, landscape, tapestry, arena | the actual noun |
| interplay | relationship, or how X affects Y |
| insights | findings, results, what we learned |
| meticulously, thoroughly | delete |

## The 291 rare excess style words (2024)

Verbatim from the paper's Figure S6. Useful as a grep list.

accentuates, acknowledges, acknowledging, addresses, adept, adhered, adhering,
advancement, advancements, advancing, advocates, advocating, affirming,
afflicted, aiding, akin, align, aligning, aligns, alongside, amidst,
assessments, attains, attributed, augmenting, avenue, avenues, bolster,
bolstered, bolstering, broader, burgeoning, capabilities, capitalizing,
categorized, categorizes, categorizing, combating, commendable, compelling,
complicates, complicating, comprehending, comprising, consequently,
consolidates, contributing, conversely, correlating, crafted, crafting,
culminating, customizing, delineates, delve, delved, delves, delving,
demonstrating, dependability, dependable, detailing, detrimentally, diminishes,
diminishing, discern, discerned, discernible, discerning, displaying, disrupts,
distinctions, distinctive, elevate, elevates, elevating, elucidate, elucidates,
elucidating, embracing, emerges, emphasises, emphasising, emphasize, emphasizes,
emphasizing, employing, employs, empowers, emulating, emulation, enabling,
encapsulates, encompass, encompassed, encompasses, encompassing, endeavors,
endeavours, enduring, enhancements, enhances, ensuring, equipping, escalating,
evaluates, evolving, exacerbating, examines, exceeding, excels, exceptional,
exceptionally, exerting, exhibiting, exhibits, expedite, expediting,
exploration, explores, facilitated, facilitates, facilitating, featuring,
formidable, fostering, fosters, foundational, furnish, garnered, garnering,
gauged, grappling, groundbreaking, groundwork, harness, harnesses, harnessing,
heighten, heightened, hinder, hinges, hinting, hold, holds, illuminates,
illuminating, imbalances, impacting, impede, impeding, imperative, impressive,
inadequately, incorporates, incorporating, influencing, inherent, initially,
innovative, inquiries, integrates, integrating, integration,
interconnectedness, interplay, intricacies, intricate, intricately, introduces,
invaluable, investigates, involves, juxtaposed, leverages, leveraging,
maintaining, merges, methodologies, meticulous, meticulously, multifaceted,
necessitate, necessitates, necessitating, necessity, notable, noteworthy,
nuanced, nuances, offering, optimizing, orchestrating, outlines, overlook,
overlooking, paving, persist, pinpoint, pinpointed, pinpointing, pioneering,
pioneers, pivotal, poised, pose, posed, poses, posing, predominantly,
preserving, pressing, promise, pronounced, propelling, realm, realms,
recognizing, refine, refines, refining, remarkable, renowned, revealing,
reveals, revolutionize, revolutionizing, revolves, scrutinize, scrutinized,
scrutinizing, seamless, seamlessly, seeks, serves, serving, shaping, shedding,
showcased, showcases, showcasing, signifying, solidify, spanned, spanning,
spurred, stands, stemming, strategically, streamline, streamlined, streamlines,
streamlining, struggle, substantiated, substantiates, surged, surmount,
surpass, surpassed, surpasses, surpassing, swift, swiftly, thorough,
transformative, typically, ultimately, uncharted, uncovering, underexplored,
underscore, underscored, underscores, underscoring, unexplored, unlocking,
unparalleled, unraveling, unveil, unveiled, unveiling, unveils, uphold,
upholding, urging, utilizes, varying, versatility, warranting, yielding

Note some entries are ordinary and unavoidable (hold, holds, involves, initially,
typically, broader, alongside). Weight the flashy ones: delve, showcase,
underscore, intricate, meticulous, pivotal, seamless, groundbreaking,
transformative, realm, unparalleled, unveil.
