# LM-I2 — Cinder Spine gate report

**Build:** `0.3.0-alpha.358`

LM-I2 is complete as a repository-verifiable gate. The Cinder Spine is a five-contact chapter with a distinct heat-and-mass question, Blackkiln forge market, Old Lift recovery stop, three threat families, three upper-road choices, a Dynamo contract, two chained lift decisions, a failure-forward refuge, a regional development, and three terminal results.

This pass fixed the gap found by running the chapter through its player interface: Old Lift claimed to offer a full refit window but its recovery screen had no workbench action and displayed Flooded Veyru language. Recovery now exposes a no-cost **Refit Chassis** action, returns cleanly to the same recovery state, and gives Old Lift its own chain-hoist, cooling-trough, forge-crew, route-sign, pressure, and contract presentation. The canonical UI run uses that workbench to exchange crew and a light weapon for the Shell Cannon needed on the upper grade.

## Automated evidence

- `content/cinder_spine.json` and `tools/validate_cinder_spine.py` validate nine nodes and six acyclic five-contact routes.
- `tests/test_cinder_spine.gd` runs three complete plans: powered Long Slope, declined-contract Long Slope, and the Inferno-opened Ash Chapel refuge. It crosses 51 exact save/load checkpoints.
- The same state suite sweeps Old Lift through pressure 0–7, verifies at least one legal road at every value, and requires Ash Chapel once Inferno closes Slag Tunnel.
- `tests/test_cinder_spine_flow.gd` now drives the complete player UI from Blackkiln to Switchback Commune, including contract, travel, Ember Drake contact, Charcoal Vow, Old Lift services and refit, upper-grade contacts, Lift Engine choice, Commune design, Elevator Warden, and a Cinder-specific causal Debrief.
- The complete UI fixture runs at 1600×900 and at 1280×720 with 110% text, high contrast, reduced motion, and alternate controller prompts.
- `tests/test_recovery_panel.gd` verifies the new workbench action, focus loop, and compact layout.

## Visual evidence

The tracked evidence was captured by the deterministic full-flow fixture at 1600×900 from this exact build:

- [`00_blackkiln.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/00_blackkiln.png)
- [`01_charcoal_departure.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/01_charcoal_departure.png)
- [`02_ember_contact.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/02_ember_contact.png)
- [`06_old_lift_recovery.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/06_old_lift_recovery.png)
- [`06b_old_lift_refit.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/06b_old_lift_refit.png)
- [`10_lift_engine_choice.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/10_lift_engine_choice.png)
- [`12_warden_contact.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/12_warden_contact.png)
- [`14_cinder_debrief.png`](visual_evidence/v0.3.0-alpha.358-cinder-gate/14_cinder_debrief.png)

## Honest boundary

The tests prove reachability, deterministic state, checkpoint integrity, supported-size containment, and a complete interface path. They do not prove that new players understand Fireline, judge the three upper roads fairly, enjoy the encounter pace, or recognize the temporary visual language without labels.

## Next task

Lock LM-I3 by proving the White Salt chapter and Salt Skimmer create two materially different viable loadouts, route priorities, persistent checkpoints, and legible Debrief outcomes through a complete player-command flow.
