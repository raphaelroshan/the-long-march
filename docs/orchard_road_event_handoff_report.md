# Orchard Road-event Handoff Report

**Build:** `0.3.0-alpha.338`

## Outcome

The Soot Orchard now follows the intended journey order:

```text
Commit route → march → Storm Front contact → Orchard decision → arrival receipt → route map
```

After the contact is cleared, the game enters a serialized `road_event` phase. The fortress remains at Ashgate Depot, The Soot Orchard remains the pending target, route reward is not paid, the path is not extended, and the secured-encounter count does not advance. The event tableau names both ends of the road and labels the state `ROAD SCENARIO · ARRIVAL PENDING`.

Choosing fuel or workers applies that consequence first, then completes arrival atomically. The normal arrival receipt opens with The Soot Orchard as the destination and carries the just-resolved decision in its road-effects list.

## Persistence and compatibility

Save schema version 11 recognizes the new phase. Version-10 checkpoints continue to load with no invented event state. A `road_event` checkpoint is accepted only for the Ashgate Soot Orchard decision with a completed contact, a pending destination, and the fortress still outside the destination.

## Verification

- Core tests verify state ordering, save/load, malformed-checkpoint rejection, delayed reward/path/progress, and atomic arrival.
- The dedicated UI flow reaches Soot Orchard through the normal route and Storm Front controls, saves and reloads at the event, resolves fuel recovery, checks the arrival receipt, and returns to the map.
- Rendered 1280×720 evidence covers both the unresolved road scenario and the resulting arrival receipt with its required action visible.

## Scope boundary

Only the existing Soot Orchard scenario uses `road_event` in this slice. Other location decisions retain their current arrival behavior until their fiction and recovery ordering justify the same state transition.
