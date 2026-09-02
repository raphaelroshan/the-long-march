# LM-I4 — Module, specialist, and threat breadth gate

**Build:** `0.3.0-alpha.360`

LM-I4 is complete as a repository-verifiable gate. The candidate's 20 modules, six specialists, and 15 threat families now resolve through one cross-content validator. Three complete White Salt plans prove that the LM-EA-4 additions create different operational decisions rather than extra names or flat upgrades.

## Dependency matrix

| Plan | New dependency | Threat question | What the plan gives up | Proven consequence |
|---|---|---|---|---|
| **Command Feint** | Sela Vonn requires a powered Command Deck beside operational Crew Quarters | Salt Mine combines Salt Storm and Signal Hunters; Command Deck attacks the hunters while Sela reduces their Run Hot crew hit | Forecasting, ammunition, exterior firepower, and one mass point | Two-day Run Hot roads become one day at +4 risk points; losing either staffed room removes the benefit |
| **Medical Watch** | Nera Quill requires a powered Field Infirmary beside operational Crew Quarters | Signal Hunters now threaten their operators as well as signal and command equipment | Command acceleration, ammunition, armor, and exterior firepower | Nera removes exactly one damage from crew/refuge hits; breaking the Infirmary dependency removes that mitigation |
| **Demolition Recovery** | A powered Salvage Crane consumes one of the Salt Skimmer's three exposed mounts | Empty Mile isolates Bridgebreakers; Cannon, armor, and crane remain different practical answers | Crew facilities, armor, and full-ammunition cannon fire | A cleared Empty Mile restores one durability to the weakest damaged system, or sells recovered fittings for 8 Ashmarks when nothing needs repair |

The command and medical plans each carry 12 mass and spend the same staffed-room footprint on different doctrine. The crane plan fills all 13 mass and all three exterior mounts. No plan is a strict upgrade: each removes a counter or dependency used by another.

## Automated evidence

- `tools/validate_early_access_systems.py` reconciles the base and expansion manifests to exactly 20 unique modules, six candidate specialists, and 15 regional threats; every threat has at least two authored counters.
- `tests/test_breadth_gate.gd` completes each plan twice from the same seed and command sequence. All six journeys serialize identically and cross 80 exact save/load checkpoints.
- Salt Mine supplies a combined Salt Storm plus Signal Hunter contact. Empty Mile supplies an isolated Bridgebreaker contact.
- The fixture proves facility-gated specialist assignment, Sela's disclosed day/risk trade, Nera's exact damage reduction, the crane's exterior-capacity cost, and both repair and cash branches of its recovery rule.
- `tests/test_breadth_flow.gd` uses player-facing controls for specialist assignment, route selection, contact, and arrival. It also runs at 1280×720 with 110% text, high contrast, reduced motion, and alternate controller prompts.
- White Salt forecasts now name the actual target classes for Salt Storms, Rival Scouts, the Rival Fortress, Signal Hunters, and Bridgebreakers rather than falling back to generic cargo wording.

## Visual evidence

The tracked 1600×900 captures come from the deterministic LM-I4 UI fixture:

- [`00_sela_offer.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/00_sela_offer.png)
- [`01_sela_assigned.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/01_sela_assigned.png)
- [`02_command_mine_dossier.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/02_command_mine_dossier.png)
- [`03_command_combined_contact.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/03_command_combined_contact.png)
- [`04_nera_offer.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/04_nera_offer.png)
- [`05_nera_assigned.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/05_nera_assigned.png)
- [`06_crane_empty_mile_dossier.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/06_crane_empty_mile_dossier.png)
- [`07_bridgebreaker_contact.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/07_bridgebreaker_contact.png)
- [`08_crane_recovery_receipt.png`](visual_evidence/v0.3.0-alpha.360-breadth-gate/08_crane_recovery_receipt.png)

## Honest boundary

Automation proves mechanical distinction, deterministic viability, recovery causality, persistence, interface reachability, and supported-size containment. It does not establish that new players value all three plans equally or understand the facility adjacency without the existing inspector and tutorial; those remain human playtest questions.

## Next task

Lock LM-I5 by making completed, declined, and failed obligations visibly alter later routes or settlement services, then prove the causal histories compose into distinct migration-safe endings.
