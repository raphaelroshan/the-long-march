# Route Context Scroll

## Player problem

At 110% text, resolving the opening contract correctly moved focus to the first available road, but the Marchmaster's Desk could begin midway through the preceding doctrine explanation. The focused route remained usable, yet the clipped sentence made the handoff look accidental and separated the road from its map heading.

## Interaction contract

- Focusing an available campaign node uses the visible regional map heading as its preferred scroll anchor.
- Focusing Commit or Cancel during route review uses the selected-road summary as its preferred scroll anchor.
- If the complete anchored context cannot fit, the focused control remains the priority and is kept visible.
- Earlier desk sections must not be left partially clipped merely because focus moved into route planning.
- The behavior applies to keyboard, controller, and programmatic current-order focus handoffs without changing route selection or campaign state.

## Scope

This changes presentation and focus scrolling only. It does not change route availability, risk, costs, doctrine effects, confirmation, save data, or deterministic simulation behavior.

## Visual evidence

- `/tmp/long_march_alpha264_routes_audit_110.png`
- `/tmp/long_march_alpha264_route_review_audit_110.png`
