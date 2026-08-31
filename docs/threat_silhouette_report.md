# Threat Silhouette Pass

**Build:** `0.3.0-alpha.303`

## Purpose

Make contact actors recognizable before the player reads their names. The prior symbols established position but did not adequately distinguish a vehicle, climber, underground attacker, weather front, flood, beast, and civic machine.

## Implemented

- Added stable presentation profiles for all seven implemented threat families.
- Rebuilt Road Raiders as a wheeled harpoon rig and Climbers as grapnel-bearing multi-limbed attackers.
- Added an emerging armored head and road cracks for Burrowers.
- Strengthened Storm Front and Flood Surge silhouettes with distinct weather and water lanes.
- Split the former shared boss symbol into an armored quadruped Siege Beast and upright shield-bearing Civic Guardian.
- Added road-flank, upper-flank, under-road, weather-line, waterline, direct-road, and archive-gate approach marks.
- Kept target arrows, labels, response windows, impact effects, and consequence receipts above the new art.

## Boundaries

Threat profiles are presentation-only. Enemy arrival steps, target selection, damage, counters, intervention timing, random streams, and save data remain owned by the existing encounter state. Unknown future threats fall back to the raider-rig silhouette until given a reviewed profile.

## Verification

- Road-contact presentation coverage asserts every implemented threat exposes a stable form and lane.
- Existing phase, target, counter, impact, consequence, and reduced-motion tests remain intact.
- Full repository verification and both responsive journey profiles remain required before merge.
- Evidence: [`v0.3.0-alpha.303 threat silhouettes`](visual_evidence/v0.3.0-alpha.303-threat-silhouettes/).

## Remaining validation

Human sessions should test whether each threat can be identified from the center stage, whether route lanes make the likely target easier to anticipate, and whether the larger boss actors remain subordinate to the causal text.
