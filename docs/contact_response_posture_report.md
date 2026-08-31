# Contact Response Posture Report

**Build:** `0.3.0-alpha.320`

## Player question

After reading a threat, can the player tell whether the fortress is already answering it and what interaction should happen next?

## Change

The live contact dossier now converts counter readiness into one of four explicit response postures:

- `PREPARED RESPONSE` / `DEFENSE ANSWERING` when an operational module or specialist will answer automatically on Advance.
- `COUNTER LOST` when a relevant installed module is offline.
- `IMPROVISED RESPONSE` when no listed module counter is operational.
- `ORDER SPENT` after the encounter's emergency order has already been used.

Each posture points toward the existing next decision—Advance, inspect the target, compare enabled emergency orders, or review the predicted consequence. It does not select an order, change intervention legality, alter damage, or add simulation state.

## Verification

- Presenter tests cover ready, offline, missing, and spent-order projections.
- Road-contact tests require the posture beside all seven implemented threat families.
- High-contrast coverage verifies that the posture remains readable.
- The complete repository verification suite remains the release gate.

## Evidence

- [Road Raider prepared response](visual_evidence/v0.3.0-alpha.320-response-posture/01_road_raiders_response.png)

The capture verifies layout and information hierarchy at 1600×900. It does not establish uncoached comprehension.

SHA-256: `d9b87b3157e9440a239582cb80a5c0adcbdf4c16e835fa63a5a98375d37c5fc4`
