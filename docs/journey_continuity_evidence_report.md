# Journey-Continuity Evidence Report

**Build:** `0.3.0-alpha.339`

## Purpose

The published vertical slice now contains two important road boundaries: a pre-contact interruption and the Soot Orchard's post-contact decision before arrival. Human sessions need to show whether players understand where the fortress is and what remains blocked at each boundary. This change makes the authoritative transition order visible in the existing opt-in, local-only feedback export.

## Recorded transitions

- `campaign_node_started` or `route_started`: a route was committed.
- `road_event_reached`: contact or travel reached a mandatory scenario while arrival remained pending.
- `road_event_resolved`: the player selected the scenario consequence.
- `road_arrival_completed`: the destination or retreat anchor became the secured current location.

Route commitment records the origin, destination, doctrine, and exact day, fuel, and pressure deltas. Road-event records preserve the event ID and both endpoints. Arrival records the resolved destination and outcome.

## Observer output

The per-session sheet renders an ordered journey-continuity trail beside the existing contact trail. The cohort report totals commitments, scenarios reached, scenarios resolved, and arrivals, and identifies exports that ended after reaching a road scenario but before recording arrival.

Those facts do not explain why a session ended. The report explicitly requires observer notes to distinguish confusion, a deliberate stop, a crash, or an agreed boundary. No score, classification, upload, cursor tracking, dwell-time tracking, or identity collection was added.

## Compatibility and verification

- Journal schema 2 adds optional aggregate journey counts while retaining the raw event list.
- Session and cohort tools derive counts for schema-1 exports that lack the new aggregate fields.
- Focused UI coverage proves the Soot Orchard trail is ordered as scenario reached → scenario resolved → arrival completed.
- Unit coverage checks aggregate integrity, mismatches, legacy exports, and an export ending before arrival.
- Full repository verification and offline-boundary checks remain required before release.
