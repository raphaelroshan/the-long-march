# Roadside Occurrence Identity Report

**Build:** `0.3.0-alpha.306`

## Purpose

Three recurring Ashgate occurrences still shared a generic circular road-machine symbol. Their prose and effects differed, but the center stage did not help the player remember what had physically interrupted the march.

## Added tableaux

- **The Boiler's Second Heartbeat:** a damaged boiler face sits between an opened casing and the signal to keep cadence.
- **The Lift Chain Sings:** a loaded ammunition chain hangs beside the brace that can stabilize it.
- **The Miller With a Broken Wheel:** a stopped wagon, displaced wheel, and waiting miller frame the workshop-time decision.

Each motif names the same two-sided decision in the center stage and right-hand story card. Existing choice buttons remain the only way to commit.

## Architecture boundary

`main.gd` derives concise story metadata from the existing event and choice effects. `ScenarioCanvas` renders that metadata and the stable event ID. `FortressState` remains authoritative for occurrence scheduling, eligibility, costs, damage, pressure, trust, time, cooldowns, history, and saves.

## Verification

- Focused roadside-presentation tests assert all three stable motif signatures.
- Captures confirm both choices remain visible at 1280×720.
- Existing high-contrast and 110% text checks still cover the same shared event layout.
- Complete prototype flow remains deterministic and green.

## Remaining human question

Ask players to describe the physical problem and trade-off before reading the buttons aloud. If they cannot distinguish the boiler, lift, and wagon decisions, revise silhouette and composition rather than adding more prose.
