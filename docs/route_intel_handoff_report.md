# Route Intel Handoff Report

**Build:** `0.3.0-alpha.335`

## Change

When a player buys the Orchard Weather Report and commits the Soot Orchard road, the mandatory march handoff now retains:

- the exact Storm Front contact;
- **Ashgate Signal Reader** as the source;
- **Reliable** as the confidence label.

The transition consumes the same read-only route preview used before Commit. It does not recalculate information, alter costs, or create a second intel state.

## Why

Purchased information should remain attributable at the moment it becomes operationally relevant. Dropping source and confidence immediately after Commit made the route planner and march presentation feel like separate systems and weakened the player's ability to judge why the contact was known.

## Verification

Presenter coverage buys the report through `FortressState`, builds the Soot Orchard transition, asserts exact source/confidence copy, and verifies that transition presentation remains a pure read-only projection.
