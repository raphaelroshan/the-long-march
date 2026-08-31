# Bazaar Attendant Identity

**Build:** `0.3.0-alpha.309`

## Purpose

Make Ashgate Depot and Lantern Quay feel like staffed working places rather than six abstract service buttons. The selected station should show who handles that work and what practical object identifies the role, while preserving the existing compact action dock.

## Implemented

- Added a compact code-native attendant portrait beside the selected station title.
- Gave workshop, quartermaster, signal, hiring, assignment, and departure stations distinct silhouettes or props.
- Authored separate role vocabularies for Ashgate Depot and Lantern Quay, including Rail-Side Engineer, Convoy Runner, Pumpwright, Medicine Courier, and Lantern Reader.
- Kept the portrait inside the existing title/status footprint so action buttons and service consequences retain priority at 1280×720.
- Propagated high-contrast treatment and exposed the current role through tooltip text.

## Boundaries

The attendants are presentation-only. They do not create character state, dialogue, prices, services, contracts, route access, or save fields. Station selection and every action still use the existing stable IDs and command handlers.

## Verification

- Ashgate and Veyru UI tests assert region-specific roles and selected-station updates.
- The settlement test confirms high-contrast propagation and unchanged station navigation.
- Four deterministic 1280×720 captures cover assignment and signal/workshop selections across both starting settlements.

## Remaining human question

Can an uncoached player remember where to return for repairs, route information, and assignments after seeing these compact attendants, or do final character designs need stronger silhouettes and names?
