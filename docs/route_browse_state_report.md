# Route Browse-State Clarity

**Build:** `0.3.0-alpha.316`

## Purpose

Keep controller or keyboard focus from looking like a committed route selection.

## Implemented

- The right dock is titled `ROAD DOSSIER` while the player browses focused map nodes.
- The map stage states `BROWSE ROAD · NO COST · SELECT TO REVIEW` before activation.
- Activating a node changes the dock to `SELECTED ROAD` and the stage to `ROUTE SELECTED · REVIEW COSTS → COMMIT`.
- Commit and Cancel behavior, route costs, focus movement, and simulation state are unchanged.

## Verification

- Settlement-hub flow covers both labels before and after selecting Rill Crossing.
- Complete-journey coverage asserts the same browse-to-selection transition.
- A 1280×720 capture confirms the focused dossier, map, readiness rail, and disabled Commit action remain visible together.

## Remaining human question

Do first-time players now understand that moving focus previews a road while activation selects it and Commit begins travel?
