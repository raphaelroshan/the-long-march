# LM-EA-1 — Ashgate and Flooded Veyru Anchor Lock

**Build:** `0.3.0-alpha.350`

**Status:** Automated acceptance complete; human comprehension and final-art review remain separate work.

## What is locked

The two existing chapters now have four complete, deterministic plans driven only through public `LongMarchState` commands. The fixture never assigns route position, phase, fuel, pressure, damage, encounter outcome, or final result.

| Chapter | Plan | Material commitments | Terminal proof |
|---|---|---|---|
| Ashgate | Reliable convoy | Accept the parts guard, restore Broken Relay, recruit Iven, refuel at Morrowline, take Signal Causeway | Five contacts and a surviving march result |
| Ashgate | Fast and exposed | Decline the guard, take Soot Orchard and Red Wheel, buy passage, decline Mara, repair the Wall Lamp | Five contacts and a surviving march result without convoy or specialist |
| Flooded Veyru | Medicine carrier | Accept the carrier, drain Pump Gallery, preserve recovery actions, take Archive Causeway, seal the archive | Five contacts and `archive_kept` |
| Flooded Veyru | Scarred survivor | Decline the carrier, take mass-sensitive Sunken Tramworks, repair at camp, fit a lighter engine and armor, seal the archive | Five contacts and `archive_scarred` |

The test performs 64 exact serialization round trips across settlement, route commitment, contact resolution, pending and resolved events, recovery, refit, and results. A restored state must serialize to the identical payload before play continues.

## Defects found and fixed

- Recalculating a loaded overheated fortress appended a duplicate heat warning. Warnings are now emitted only on the transition above the safe limit.
- A completed encounter retained its historical target, but a legal later refit could remove that module and make the next save fail validation. Missing targets remain invalid during active contacts; completed contact records may refer to systems that have since been stored.

## Presentation acceptance

Flooded Veyru's full UI journey now runs at both 1280×720 and 1600×900 under the compact accessibility profile: 110% text, high contrast, reduced motion, and east-button confirm. Assertions cover Lantern Quay, route planning, committed travel, contact, Evacuation Camp recovery, the archive decision, and Debrief. Ashgate retains the equivalent responsive full-journey coverage in `test_complete_journey_handoff.gd`.

Existing authored evidence remains the visual baseline:

- [Ashgate and Lantern Quay settlement identity](visual_evidence/v0.3.0-alpha.285/)
- [1280×720 responsive journey evidence](visual_evidence/v0.3.0-alpha.289-l2-responsive-1280x720/)
- [1600×900 responsive journey evidence](visual_evidence/v0.3.0-alpha.289-l2-responsive-1600x900/)
- [Threat silhouettes, including Flood Surge and Civic Guardian](visual_evidence/v0.3.0-alpha.303-threat-silhouettes/)

No replacement art was added merely to satisfy LM-EA-1. The current temporary kit remains useful for feel and comprehension testing; final character art, environment art, animation, ambience, music, mix, signing, storefront integration, and broad hardware validation remain out of scope.

## Verification contract

`scripts/verify.sh` now runs:

- `tests/test_early_access_anchor_runs.gd` for the four no-debug journeys and 64 exact checkpoints;
- the existing Ashgate responsive journey at 1280×720 and 1600×900;
- the complete Veyru UI flow in its normal profile; and
- Veyru responsive profiles at 1280×720 and 1600×900.

Passing this gate establishes deterministic completeness and layout containment. It does not establish that an uncoached player understands, enjoys, or can balance either chapter.
