# Live Counter Readiness Report

**Build:** `0.3.0-alpha.318`

## Player question

When a threat appears, can the player distinguish the general counter advice from what this fortress can actually use right now?

## Change

The contact dossier now includes one compact readiness receipt for the nearest active threat:

- `READY NOW` names operational counter modules carried by the fortress.
- `COUNTER OFFLINE` names installed counters that cannot currently operate.
- `NO LISTED MODULE COUNTER READY` makes an uncovered threat explicit.
- Iven Pell appears as a ready answer to Storm Fronts while assigned.

The projection reads existing module dependency state and specialist assignment. It does not change targeting, damage, enemy timing, intervention legality, or random streams.

## Verification

- Presenter tests cover missing module readiness and Iven's storm contribution.
- Road-contact presentation tests retain the readiness receipt through forecast and high-contrast states.
- The complete prototype flow verifies that Rill Crossing names the operational Repeater Gun.
- The full repository verification suite passes.

## Evidence

- [Road Raider with a ready Repeater Gun](visual_evidence/v0.3.0-alpha.318-live-counter-readiness/08_road_contact.png)

The capture verifies visibility and hierarchy at 1600×900. Human prediction accuracy remains a private-alpha observation task.
