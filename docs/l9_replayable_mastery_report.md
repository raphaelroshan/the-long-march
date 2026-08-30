# L9 — Replayable Mastery

**Build:** `0.3.0-alpha.296`

## Result

PASS. Ashgate now offers two optional, save-safe field experiments that make replay intent concrete without adding grind or permanent progression.

## Player-facing flow

The Signal Broker stall now opens the Marchmaster's Desk. Before the first road, the player may choose Quarry Adaptation or Signal Discipline. The selected order appears in the settlement receipt, route-planning order, recovery priority, and terminal Debrief. It is evaluated as Active, Proven, or Incomplete.

Neither order changes resources, encounter rules, rewards, unlocks, or ending thresholds.

## Multiple solutions

- Quarry Adaptation is proven both by a Run Hot speed plan and by Protect Cargo with lower-hull armor.
- Signal Discipline is proven both with Iven Pell and with an operational Wall Lamp without Iven.

The tests execute all four approaches through the existing deterministic campaign rules. The order checks only the authored destination proof, so alternate layouts remain valid.

## Persistence and evidence

The stable order ID is included in current saves, defaults cleanly for older saves, rejects unknown IDs, and is evaluated from the authoritative campaign path. Presentation builders remain read-only.

Visual evidence is stored in [`visual_evidence/v0.3.0-alpha.296-l9-replayable-mastery/`](visual_evidence/v0.3.0-alpha.296-l9-replayable-mastery/).
