# LM-GPT56-2 — Fortress Identity Across Modes

**Build:** `0.3.0-alpha.363`

**Status:** Complete as a presentation-only repository gate.

## Shared actor contract

[`content/fortress_presentation.json`](../content/fortress_presentation.json) declares one stable `long_march_fortress_v1` actor, its required snapshot fields, eight operational modes, eight visible conditions, five bounded cue families, accessibility equivalents, and the temporary-asset boundary. [`FortressPresentationRegistry`](../src/presentation/fortress_presentation_registry.gd) exposes that authored registry to the existing code-native silhouette renderer.

Rest, departure, travel, retreat, contact, event, recovery, and Debrief vary motion and stance without replacing the fortress identity. The renderer continues to derive family bays, condition, damage, sealing, targeting, repair, heat, and place treatment from the same presentation snapshot supplied by `Main`.

## Bounded cues

| Cue | Visual | Runtime audio family | Reduced-motion equivalent |
|---|---|---|---|
| Engine strain | Amber dependency pulse | Contact mechanism | Steady amber outline |
| Repair | Repair stitch and service light | Service | Repair stitch |
| Threat approach | Intent line and target bracket | Authored threat family | Static intent line |
| Impact | Damage crack and bounded recoil | Contact impact | Damage crack |
| Safe arrival | Settled legs and warm service lights | Arrival | Warm service lights |

High-contrast equivalents retain explicit text labels. Rendering and audio consume state but never write simulation state.

## Verification

- `tools/validate_fortress_presentation.py` validates the actor, mode, cue, asset, accessibility, and no-mutation contracts.
- `tests/test_fortress_presentation_registry.gd` runs one unchanged module snapshot through rest, travel, contact, recovery, and Debrief and verifies actor identity plus source immutability.
- Existing silhouette and semantic-audio tests still verify damage precedence, family aggregation, place treatment, reduced motion, temporary smoke attribution, and runtime cue availability.

## Visual evidence

- Standard 1600×900 modes: [`v0.3.0-alpha.363-gpt56-2-standard/`](visual_evidence/v0.3.0-alpha.363-gpt56-2-standard/)
- 1280×720, 110% text, high contrast, reduced motion: [`v0.3.0-alpha.363-gpt56-2-accessible/`](visual_evidence/v0.3.0-alpha.363-gpt56-2-accessible/)

Each set contains the same fortress at rest, traveling, at contact, in recovery, and at Debrief. Damage remains visible in later modes.

## Asset boundary

The fortress actor and UI geometry are original code-native project work. The documented Kenney smoke particle and semantic audio remain temporary breadth assets; Tiny Town remains reference-only and is not used as the fortress identity. No temporary asset is described as final production art or sound.

## Next packet

Execute **LM-GPT56-3 — Regional campaign skeleton** by validating each region's distinct operational promise, settlement trade-off, route hazard, threat lesson, recovery implication, development, isolated teaching contact, combined-pressure contact, and two viable loadouts.
