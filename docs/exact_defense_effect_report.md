# Exact Defense Effect Report

**Build:** `0.3.0-alpha.321`

## Player question

When the dossier says a counter is ready, can the player see what that defense will actually contribute on the next combat beat?

## Change

`FortressState.encounter_summary()` now carries a read-only defense projection for each undefeated threat. It identifies:

- exact automatic damage on Advance;
- the authored module or specialist names producing that damage;
- exact adjacent-armor absorption against an arrived contact; and
- the armor module providing that buffer.

The response posture displays those values. If a listed counter is operational but current target geometry produces neither attack damage nor an impact buffer, the posture changes to `COUNTER AVAILABLE` and asks the player to inspect placement. This prevents readiness copy from overstating a positional defense.

No combat timing, target selection, damage rule, intervention, random stream, or save field changed.

## Verification

- Fortress-state coverage checks automatic output and adjacent-armor absorption.
- Presenter coverage checks exact damage copy and the no-direct-effect fallback.
- Road-contact coverage retains all seven threat families and high-contrast behavior.
- The deterministic full journey produced the integrated evidence capture below.

## Evidence

- [Road Raider exact automatic defense](visual_evidence/v0.3.0-alpha.321-defense-effect/08_road_contact.png)

SHA-256: `61cc37c96c3f5a36935886b652be190ba31b36df594097908ee4f198a100c65a`
