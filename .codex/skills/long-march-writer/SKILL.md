---
name: long-march-writer
description: Write or revise The Long March's in-game narrative, event, specialist, settlement, route, tutorial, tooltip, and Debrief copy while tying every consequential line to implemented mechanics and preserving the game's humane industrial-fantasy voice. Use for authored player-facing game text in this repository; do not use for generic marketing copy or implementation-only work.
---

# Long March Writer

Write compact operational fiction in which the fortress, its people, and its promises all occupy real space. A line earns its place when it helps the player understand a decision, remember a consequence, or recognize this particular road.

## Establish the truth before writing

1. Read `AGENTS.md`, `design/design_prompt.md`, and the relevant section of `design/gameplay_framework.md`.
2. Locate the authoritative implementation for the touched mechanic. Prefer `src/core/fortress_state.gd` and focused state classes over content manifests or planning prose.
3. Read the adjacent presenter and existing player-facing copy to learn the surface's actual space, casing, and vocabulary.
4. Read only the relevant world sources:
   - people and promises: `design/characters_factions_and_campaign.md`, `content/people_promises.json`, and `content/campaign_memory.json`;
   - roads and settlements: `design/map_regions_and_settlements.md` and the matching regional JSON file;
   - endings and callbacks: `content/campaign_memory.json` and the Debrief presenter.
5. Mark every proposed cost, requirement, effect, item, person, place, and callback as **implemented**, **planned**, or **unknown**. Never present planned or unknown behavior as implemented.

When sources disagree, use this order: authoritative state and commands, focused content data, presenter behavior, repository design intent, then old prose.

## Build a mechanical spine

Before drafting prose, state the content unit in five lines:

- **Situation:** What physical problem is happening now?
- **Decision:** What must the player choose or do?
- **Price:** Which visible resource, capacity, time, exposure, or obligation changes?
- **Receipt:** What immediately confirms the result?
- **Callback:** Where can the world remember it later?

If one of these is absent, flag the gap instead of disguising it with atmosphere. Not every quiet road beat needs a choice, but it still needs an observable change or a specific sense of place.

## Write in the game's voice

- Prefer tools, materials, jobs, and actions: bearings, canvas, waterline, relay glass, chain, berth, brace, mark, vent, tow, ration.
- Make danger legible through a failing system or compromised promise, not a generic claim that the stakes are high.
- Keep people practical and humane. They disagree over what the fortress should carry, protect, reveal, repair, or become.
- Give regions distinct physical language. Follow [voice and world](references/voice-and-world.md).
- Let characters notice the same trade-off the player can inspect. Do not make them narrate hidden values or invented systems.
- Use sentence rhythm for clarity, not grandeur. One memorable image is stronger than three decorative metaphors.
- State known facts, forecasts, and unknowns separately. Uncertainty must be honest rather than coy.
- Use `snake_case` stable IDs and existing names. Text must not contain executable logic.

Avoid interchangeable catastrophe prose, prophecy, heroic slogans, abstract noun piles, and synthetic reversals such as “not merely X, but Y.” Do not use lore as a substitute for a choice.

## Fit the surface

Use the budgets and structures in [content shapes](references/content-shapes.md). Lead labels with a concrete verb. Put exact costs and requirements in structured UI fields when they exist; prose explains meaning and consequence rather than duplicating a dashboard.

For consequential choices, make the alternatives legitimately different. Do not write a compassionate option and an obviously foolish option. Each should preserve something and expose something else.

## Deliver and implement

For a writing-only request, return:

1. final copy in its intended UI structure;
2. a short mechanical mapping naming its real costs, effects, and callback;
3. any implementation or continuity assumptions that still require confirmation.

For repository changes:

1. change the smallest authoritative content or presenter surface;
2. preserve stable IDs, save compatibility, deterministic behavior, command boundaries, and accessibility settings;
3. update focused tests when labels or content contracts are asserted;
4. run `python3 tools/validate_content.py --manifest content/content_manifest.json` and the relevant focused checks;
5. invoke `$long-march-content-reviewer` for a final adversarial pass over substantive authored copy.
