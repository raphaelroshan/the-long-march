# L6 Presentation Boundaries Report

**Build:** `0.3.0-alpha.293`

## Result

PASS. Settlement, route, contact, recovery, and debrief view-model construction is extracted from the monolithic stage script into five focused, read-only presenters.

## Ownership

- `LongMarchState` still owns every route, contract, target, random draw, damage result, service result, and save field.
- `main.gd` still owns orchestration, focus handoff, and command dispatch.
- Presenters only translate authoritative state and existing control status into dictionaries consumed by the current panels.
- The extraction removes roughly 270 lines of view composition from `main.gd` without adding another state machine.

## Verification

`tests/test_presentation_builders.gd` verifies stable assignment, route, and intervention IDs; bounded encounter reports; route receipts; recovery controls; debrief timelines; and serialized-state purity for all five builders.

The four L5 settlement captures were regenerated after extraction and compared byte-for-byte with the checked-in alpha.292 images. All four matched, demonstrating pixel-identical settlement and recovery output across the boundary change. Existing full-flow tests cover route, contact, recovery, and debrief integration.

## Next gate

L7 should add one bounded route branch in an existing region, using existing threats and facilities and the extracted presentation contracts.
