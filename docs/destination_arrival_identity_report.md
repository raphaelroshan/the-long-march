# Destination Arrival Identity Pass

**Build:** `0.3.0-alpha.302`

## Purpose

Make arrival complete the physical journey. Before this pass, every secured road ended against the same generic wall, so the destination name changed while the center stage did not.

## Implemented

- Added stable `origin_id`, `destination_id`, and `destination_kind` fields to the saved arrival presentation snapshot.
- Mapped every implemented Ashgate and Veyru destination to a concise visual motif and marker.
- Added crossing, camp, relay, salvage, industrial, final-pass, archive, and fallback outpost compositions.
- Added regional approaches: rail sleepers and dry-road marks in Ashgate; water arcs and raised structures in Veyru.
- Added a dedicated First Watch recovery siding identity.
- Replaced the generic center caption with the actual destination reached, while preserving separate retreat language.
- Clipped the arrival canvas so center-stage drawing cannot enter the receipt or action rails.

## Boundaries

The destination ID is copied from the already-resolved route result. Arrival rendering does not decide whether a road succeeds, where a retreat lands, what rewards apply, which event follows, or which action becomes available. The existing arrival receipt, checkpoint, Continue behavior, and fortress snapshot remain authoritative.

## Verification

- Complete-journey coverage checks that every arrival exposes a stable destination motif.
- Save/resume coverage verifies Rill Crossing restores as the same crossing tableau.
- Final Ashgate coverage verifies Meridian Pass uses the final-threshold motif.
- Flooded Veyru coverage verifies every resolved arrival motif matches its authoritative destination ID.
- Full repository verification and supported responsive profiles remain required before merge.

## Remaining validation

The silhouettes are intentionally restrained code-native alpha art. Human sessions should test whether players can recognize a return to a known place, distinguish settlement from hazard arrival, and anticipate whether Continue leads to a local event, recovery, route map, or Debrief.
