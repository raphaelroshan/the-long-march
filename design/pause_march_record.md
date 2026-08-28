# Pause-accessible March Record

## Player problem

A returning tester can identify the next action from Continue and the live current-order line, but the route, contract, doctrine, authored decisions, damage, and deterministic seed remain scattered across the stage. Reconstructing why the fortress is in its current condition is especially difficult after resuming a checkpoint or pausing midway through a longer test.

## Interaction contract

- Pause exposes **March Record** alongside Field Briefing and Settings.
- The record opens above the still-suspended stage and begins at the top every time.
- The first viewport names the stable chapter-and-seed run ID, exact chapter/day/location/phase, and current next order.
- The complete scrollable record includes secured progress, path, regional pressure, contract and carrier, doctrine, specialist, authored decisions, seeded occurrences, resources, dependency counts, and named damaged or unavailable systems.
- **Copy March Record** copies the visible text only and gives an explicit local-only receipt. It never opens another application or sends data.
- Back or controller cancel returns focus to **March Record** in Pause without resuming or mutating the run.
- The same run code appears in the compact Pause summary, final debrief record, and exported feedback summary.

## Run identity

The code is intentionally simple and inspectable: `ASH-<seed>` for Ashgate and `VEY-<seed>` for Flooded Veyru. It is a support identifier, not a password or globally unique session ID. Reproducing a full outcome still requires the recorded chapter, seed, decisions, chassis, doctrine, and commands.

## Scope boundary

This slice reads existing authoritative state. It does not change seeds, random streams, save schema, campaign rules, telemetry, or feedback consent. It does not claim that copying the summary alone can reproduce every command sequence.

## Required evidence

- Ashgate and Veyru expose distinct stable run codes.
- Pause open/copy/cancel preserves the exact serialized state and suspended process mode.
- Debrief and exported feedback carry the same run code and seed.
- Pause and March Record remain readable at 1280×720 with 110% text and High contrast.
