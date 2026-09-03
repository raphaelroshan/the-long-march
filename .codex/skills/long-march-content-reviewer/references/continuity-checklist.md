# Continuity checklist

## Canonical sources

- Design thesis: `design/design_prompt.md`, `design/gameplay_framework.md`
- People and factions: `design/characters_factions_and_campaign.md`
- Map and settlement intent: `design/map_regions_and_settlements.md`
- Implemented state and commands: `src/core/fortress_state.gd` and focused state classes
- Player-facing assembly: `src/presentation/`
- Shared event manifest: `content/content_manifest.json`
- Implemented specialists and promises: `content/people_promises.json`
- Cross-region memory and endings: `content/campaign_memory.json`
- Regional proof: `content/flooded_veyru.json`, `content/cinder_spine.json`, `content/white_salt_expanse.json`
- Behavioral evidence: focused files under `tests/`

Planning documents describe intent. They do not prove runtime availability.

## People

- Name and ID match current implementation.
- Capability has its real facility, readiness, crew-connectivity, resource, and berth requirements.
- Limitation appears whenever the benefit is offered.
- The character argues from role and belief, not authorial omniscience.
- A promise's later result reflects the recorded choice and survival conditions.

Pay special attention to legacy planning names versus implemented names, including Orris Vale / Orla Nine. Resolve against current state before writing.

## Places and roads

- Origin, destination, current location, and phase agree.
- Region-specific pressure and threat family are correct.
- Days, fuel, heat, risk, visibility, assignment status, and closure consequences match the selected road.
- Forecast confidence does not become certainty without the implemented source.
- A closed route leaves the guaranteed recovery path intact.

## Obligations and endings

- Status is one of the implemented states, such as completed, declined, failed, unresolved, or unbound.
- The later condition has an explicit causal source.
- The same obligation is not simultaneously completed and failed.
- Ending facets compose only from recorded survival, network, and promise state.
- No line turns an operating trade-off into a secret morality score.

## Persistence and presentation

- Stable IDs are unique and migration-safe.
- Active events, selected choices, and later receipts survive save/load where required.
- The same fact is consistent across map, event, settlement, pause record, and Debrief.
- Skipping presentation never skips an event, contact, assignment check, or arrival receipt.
- Textual labels preserve meaning without relying on color, animation, sound, or pointer hover.
