# Phase-Aligned Impact Audio

**Build:** `0.3.0-alpha.312`

## Purpose

Make a resolved hit sound when the road-contact presentation reaches its visible Impact beat rather than collapsing every combat sound onto the Advance command.

## Implemented

- Added one restrained temporary material-impact cue to the existing bounded audio pool.
- Emits the cue once when a changed encounter report crosses into the Impact phase.
- Keeps the immediate contact-step or threat-family warning at command acceptance, separating machinery acknowledgment from the later hit.
- Under Reduced Motion, emits the same resolved-hit cue immediately as the presentation moves to Consequence.
- Guards each transition so redraws and later frames cannot replay the impact.

## Boundaries

The cue follows already-authoritative damage. It does not delay a command, alter target selection, change damage, consume a random stream, or add serialized combat state. Muting Interface Audio suppresses it while all target, durability, and dependency information remains visible.

## Verification

- Road-contact presentation coverage advances across the Impact threshold and asserts exactly one cue request.
- The same test verifies that Reduced Motion collapses the cue to immediate consequence and still emits exactly once.
- Interface-audio coverage verifies the stable cue ID and temporary CC0 asset.
- Full repository verification must pass before merge.

## Remaining human question

Does the temporary impact sound reinforce the visual hit without overpowering the threat warning or becoming tiring during repeated contacts?
