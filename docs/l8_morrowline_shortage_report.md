# L8 — Morrowline Parts Shortage

**Build:** `0.3.0-alpha.295`

## Result

PASS. Declining Ashgate's convoy now creates a visible mechanical shortage at Morrowline instead of ending as reward text.

## Behavior

- The assignment board discloses that accepting preserves two Morrowline services and declining leaves one.
- The declined receipt retains that consequence before departure.
- Morrowline derives its service capacity from the authoritative contract state: two after delivery, one after decline or failure.
- Arrival reporting and the recovery tableau name the absent convoy as the cause.
- The Debrief records whether the march received two convoy-supported actions or one shortage action.

No new save field was added. The existing contract status survives the road, and the existing settlement-action budget persists after arrival.

## Verification

Focused state coverage proves disclosure, save/load before arrival, deterministic consequence resolution, one successful service, a blocked second service, and a complete declined-contract five-encounter path. Presentation coverage proves the assignment, recovery, and Debrief projections remain read-only and agree with live state. The complete journey profile exercises the same visible controls from Ashgate through Meridian Pass.

Visual evidence is stored in [`visual_evidence/v0.3.0-alpha.295-l8-morrowline-shortage/`](visual_evidence/v0.3.0-alpha.295-l8-morrowline-shortage/).
