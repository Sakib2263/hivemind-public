# Plan: [what we are building or changing]

Written by: [model]
Status: waiting for approval

## Goal
[What and why, in 2-3 lines]

## Scope
- In: [features]
- Out: [what we are not doing]

## How (smallest change)
[Main steps, which files, what gets reused]

## Units (each becomes a TASKS.md row and one relay job)
| # | Unit | Class | Worker | Done when |
|---|---|---|---|---|
| 1 | [one job's worth of work] | plan / core / feature / mechanical / read | codex / deepseek / agy / Claude | [a check a gate can run] |

Class rules: see ROUTING.md. Keep each unit small enough for one job (one feature, a few files).

## Decisions for the owner
1. [question]

## Test plan
- [what to check, on which screen sizes or devices]
- Gates: build for every unit; security if [money / accounts / saves / network]; release before [target]

Keep this file under about 15k tokens. Bigger? Split into PLAN-1-*.md parts and point units at them.
