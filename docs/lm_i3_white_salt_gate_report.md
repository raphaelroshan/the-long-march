# LM-I3 — White Salt and chassis gate report

**Build:** `0.3.0-alpha.359`

LM-I3 is complete as a repository-verifiable gate. The White Salt Expanse now has a full five-contact player flow, two viable deterministic builds, an explicit Salt Skimmer versus Road Keep geometry contract, previous-version checkpoint coverage, distinct route priorities, two terminal Debrief outcomes, and a Windbreak recovery scene that belongs to the salt flats.

## The chassis decision

The Salt Skimmer is not a statistical upgrade. Compared with the Road Keep, it loses one point of mass capacity and both lower corner cells, but gains a third exterior mount. That makes exposed tools easier to combine while making interior packing and protection harder.

| Plan | Physical dependency | What it gives up | Preferred road | Result |
|---|---|---|---|---|
| **Beacon Skimmer** | Signal Coil beside an exterior Wall Lamp; Shell Cannon beside an Ammunition Lift | No lower-hull armor at the 13-mass ceiling | Beacon Road, where ready forecasting lowers risk and counters Salt Storms | `expanse_allied` after public beacons and Compact escort |
| **Armored Skimmer** | Signal Coil beside an exterior Wall Lamp; Side Armor Skirt covers the lower approach | No Ammunition Lift, leaving the Shell Cannon strained on emergency rounds | Empty Mile, where armor and cannon answer Bridgebreakers | `expanse_crossed` after declining the escort and racing the rival |

Both plans use the same 13-mass hull for different dependency graphs. The comparison against the Road Keep separately proves the trade: 13 versus 14 mass, three versus two exterior mounts, and two cut-away lower corners versus a complete lower deck.

## Automated evidence

- `content/white_salt_expanse.json` declares ten nodes, eight acyclic five-contact routes, the exact chassis trade, and both seeded loadouts.
- `tools/validate_white_salt.py` validates the graph, pressure fallback, threats, decisions, development, contract, chassis comparison, and isolated ammunition-versus-armor loadout difference.
- `tests/test_white_salt_expanse.gd` completes the Beacon and Armored plans through different roads and results, crosses 30 exact save/load checkpoints, and restores both Windbreak layouts from save version 14.
- The Armored plan verifies that **Seal Compartment** protects its engine during the final contact and restores it before arrival viability is evaluated.
- `tests/test_white_salt_flow.gd` drives the player UI from Saltglass Haven through Buried Observatory, The Windbreak, Beacon Road, Rival Approach, Salt Citadel, and the causal `EXPANSE ALLIED` Debrief.
- The full UI fixture runs at 1600×900 and at 1280×720 with 110% text, high contrast, reduced motion, and alternate controller prompts.
- `tests/test_recovery_panel.gd` verifies The Windbreak visual signature and four-road sign alongside the existing Morrowline, Veyru, and Cinder presentations.

## Visual evidence

The tracked evidence was captured by the deterministic full-flow fixture at 1600×900 from this exact build:

- [`00_saltglass_haven.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/00_saltglass_haven.png)
- [`01_observatory_departure.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/01_observatory_departure.png)
- [`02_salt_storm_contact.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/02_salt_storm_contact.png)
- [`06_windbreak_recovery.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/06_windbreak_recovery.png)
- [`06b_skimmer_workbench.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/06b_skimmer_workbench.png)
- [`07b_beacon_selected.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/07b_beacon_selected.png)
- [`10_rival_terms.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/10_rival_terms.png)
- [`11_rival_fortress.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/11_rival_fortress.png)
- [`13_salt_debrief.png`](visual_evidence/v0.3.0-alpha.359-white-salt-gate/13_salt_debrief.png)

## Honest boundary

The fixtures prove deterministic viability, route distinction, checkpoint preservation, supported-size containment, and complete interface reachability. They do not prove that new players understand the Salt Skimmer trade without coaching, value the two plans equally, or find the chapter pacing enjoyable.

## Next task

Lock LM-I4 by mapping every expanded module and specialist to a visible dependency decision, proving each new threat has at least two practical counters in complete journeys, and removing any option that adds breadth without changing play.
