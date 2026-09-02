# LM-GPT56-3 — Regional Campaign Skeleton

**Build:** `0.3.0-alpha.363`

**Status:** Complete as a four-region campaign contract.

## Bounded campaign

[`content/regional_campaign_skeleton.json`](../content/regional_campaign_skeleton.json) defines the implemented campaign as 20 contacts, three chassis, twenty modules, six specialists, fifteen threat IDs grouped into ten player-facing pressure families, sixteen route families, eight working settlements/recovery stops, twenty-one decisions or meetings, five developments, and sixty composable ending combinations.

The ten pressure families reconcile the packet's readable 10–12-family target with the existing fifteen concrete threat IDs. No threat was removed or renamed; related variants are grouped only for campaign-level teaching.

## Regional identities

| Region | Operational promise | Teaching contact | Combined pressure | Recovery and failure-forward state | Viable plans |
|---|---|---|---|---|---|
| Ashgate Lowlands | Carry an obligation while the blockade closes behind the fortress. | Rill Crossing · Road Raiders | Cinder Quarry · Raiders + Burrowers | Morrowline capacity; Wreckers' Warning | Reliable / Exposed |
| Flooded Veyru | Carry medicine through rising water while protecting the lower hull. | Pump Gallery · Flood Surge | Drowned Registry · Flood + Climbers | Evacuation Camp; Public Archive Signal | Reliable / Salvage |
| Cinder Spine | Climb volcanic grades while mass, heat, and the dynamo compete for margin. | Charcoal Monastery · Ember Drakes | Slag Tunnel · Drakes + Saboteurs | Old Lift refit; Refuge Chain | Powered / Bypass |
| White Salt Expanse | Cross open salt with an exposed signal line and visible rival convoy. | Buried Observatory · Salt Storm | Salt Mine · Storm + Signal Hunters | Windbreak refit; Shared Cisterns | Command / Medical |

Each region also declares a distinct settlement trade-off, route hazard, threat lesson, recovery implication, two settlements, and four route families. The manifest is descriptive content; authoritative costs, contacts, and state transitions remain in `LongMarchState`.

## Verification

- `tools/validate_regional_campaign_skeleton.py` validates totals, uniqueness, node references, threat grouping, teaching/combined contacts, settlement count, route-family count, and two loadout proofs per region.
- `tests/test_regional_campaign_skeleton.gd` asks the live state for each teaching and combined node and verifies the declared threat composition without mutating encounter results.
- `tests/test_early_access_anchor_runs.gd`, `tests/test_cinder_spine.gd`, `tests/test_white_salt_expanse.gd`, and `tests/test_breadth_gate.gd` remain the complete deterministic loadout proofs.
- Existing versioned region evidence remains in the LM-I2, LM-I3, LM-I4, Veyru, and GPT56-1 galleries.

## Honest boundary

This proves four mechanically distinct chapter structures and viable deterministic plans. It does not make them one seamless numerical-resource campaign, prove equal human-perceived depth, or imply that fifteen threat variants need fifteen separate tutorials.

## Next packet

Execute **LM-GPT56-4 — People, promises, and memory** by declaring every specialist's capability, dependency limitation, conflict or promise, and visible consequence, then proving active-event persistence plus replay differences for completed, declined, and failed obligations.
