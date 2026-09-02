# The Cinder Spine — Early Access chapter contract

The Cinder Spine is the third five-contact journey. Its question is whether a fortress can remain useful while climbing faster than a moving fireline. It must feel materially different from Ashgate's blockade and Veyru's flooding: chassis mass, heat headroom, and generator continuity are the dominant constraints.

## Chapter rhythm

Blackkiln offers the Cinder Guild dynamo obligation. Accepting requires a working Generator Core and adds one heat to every committed road; delivering it creates an extra service action and the strongest powered ending. Declining gives one Mobility tendency and preserves heat margin.

The opening branch is Charcoal Monastery or Red Cut. The monastery costs time and creates a coals decision. Red Cut is quicker and more rewarding but punishes chassis mass above 12. Both converge on Old Lift Station, the chapter recovery point. From there the player chooses Long Slope, Slag Tunnel, or the pressure-opened Ash Chapel Bypass before Lift Engine House and Switchback Commune.

At Fireline 5, Slag Tunnel closes and Ash Chapel Bypass opens. This is intentional failure-forward routing: pressure changes the road and reward rather than deleting recovery or forcing a restart.

## Threat and counter language

- Ember Drakes pressure fuel, exterior, and sustain systems. Wall Lamp, Repeater Gun, Water Condenser, Shell Cannon, or Vent Heat answer them in different ways.
- Lift Saboteurs attack generator, workshop, and signal dependencies. Repeater fire, repair readiness, shell fire, or armor provide distinct counters.
- The Elevator Warden attacks movement and power together. Shell fire and armor are direct answers; cutting the switchback reduces its impact through an earlier social choice.

## Ending and memory

`spine_powered` records a surviving fortress that powers the lift. `spine_bypassed` records a surviving hand-cut crossing. `cinder_lost` is the terminal mobility or hull failure. Sharing the lift design after either surviving result earns `cinder_communal_lift_plan`, which reveals Slag Tunnel contacts on later Cinder runs without reducing their risk.

## Acceptance evidence

The chapter is accepted only when `tools/validate_cinder_spine.py`, the two complete command-only plans in `tests/test_cinder_spine.gd`, the UI flow in `tests/test_cinder_spine_flow.gd`, both responsive profiles, and the full repository verification suite pass. Automated evidence proves deterministic implementation and layout bounds; it does not prove human comprehension or enjoyment.
