# Route-Specific Travel Landmarks

**Build:** `0.3.0-alpha.310`

## Purpose

Make the mandatory in-between road screen reflect the route the player actually committed to. The brief travel beat should foreshadow the destination and reinforce map memory before contact rather than displaying the same generic object on every road.

## Implemented

- Added a stable presentation profile for every current Ashgate and Veyru destination plus the First Watch training road.
- Added distinct code-native motifs for bridge crossings, blackened orchard, relay pylons, blockade gantry, convoy or raised camp, lower-hull cut, buried cisterns, quarry terraces, Meridian pennants, pump machinery, submerged tram rails, Pilgrim gantry, and archive approaches.
- Kept the shared fortress in the foreground and the route landmark behind it so machine state remains the primary subject.
- Updated the travel caption to name the passing landmark while retaining the destination and pending-contact language.

## Boundaries

The destination visual ID is presentation data copied from the already-authoritative committed route. Landmarks do not change days, fuel, pressure, encounters, target order, saves, or the one-second travel sequence. Reduced Motion still bypasses the moving beat and enters the existing Contact Ahead state.

## Verification

- Presenter coverage verifies live routes retain their destination visual ID and First Watch receives its own muster-road profile.
- Settlement and Veyru flows verify Rill Crossing and Pump Gallery landmarks through the normal route commitment path.
- The profile inventory covers all current destinations without introducing a fallback for shipped routes.
- Full repository verification must pass before merge.

## Remaining human question

Do players begin to associate landmark silhouettes with later arrivals and route risks, or do the final authored backgrounds need stronger scale, weather, and material differences?
