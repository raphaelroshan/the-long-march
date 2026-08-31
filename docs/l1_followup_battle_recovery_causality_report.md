# L1 Follow-up — Battle and Recovery Causality

**Build:** `0.3.0-alpha.299`

## Purpose

Complete the strategy update added after alpha.298: preserve the verified full journey while making the decisive combat beat and the recovery handoff readable without consulting raw logs.

## Implemented

- Added a persistent combat receipt that keeps threat, target, counter, exact durability change, and dependency cascade together through wind-up, impact, and consequence.
- Added an impact burst at the authoritative target; the effect only visualizes already-resolved state.
- Extended the contact presentation summary with durability before/after and downstream dependency state changes.
- Added an arrival repair-priority card naming the most damaged system, its durability, operating state, capability, and failure risk.
- Carried the same repair target into recovery, where the service dock and fortress tableau now point to one authoritative system.
- Tightened the recovery action stack so the route action remains visible at 1280×720 with 110% text.

## Boundaries

The simulation, random streams, damage order, route costs, save schema, and player commands are unchanged. The new visuals and copy are derived from existing encounter impacts, dependency status, module definitions, and recovery previews.

## Verification

- Full `scripts/verify.sh`: PASS with Godot 4.4.1.
- Complete First Watch and Ashgate journey: PASS.
- Complete prototype flow and Flooded Veyru flow: PASS.
- Cinder Quarry, declined-convoy, replayable-mastery, 1280×720 responsive, and 1600×900 responsive profiles: PASS.
- Focused road-contact and recovery tests assert the exact threat → target → durability → dependency → repair chain.
- Captures: [`1600×900`](visual_evidence/v0.3.0-alpha.299-battle-recovery-causality-1600x900/) and [`1280×720 accessibility profile`](visual_evidence/v0.3.0-alpha.299-battle-recovery-causality-1280x720/).

## Remaining validation

Automated evidence proves deterministic causality, reachability, and supported-layout bounds. Uncoached sessions should still test whether players notice the target before impact, understand why a dependent system changed state, and choose recovery based on the capability at risk.
