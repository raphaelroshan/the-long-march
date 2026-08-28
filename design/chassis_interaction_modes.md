# Chassis Inspection and Edit Modes

## Player problem

The opening stage focuses the mandatory contract while also selecting the Steam Lance Engine for its dependency explanation. Previously the chassis rendered that passive selection as `SELECTED · MOVE TO AN EMPTY CELL`, making an untouched run look as though a module was already being carried or repositioned.

## Interaction contract

- A selected installed module is passive inspection until the chassis itself owns focus or the player clicks the grid.
- Passive presentation uses `CHASSIS OVERVIEW`, `INSPECTED SYSTEM`, and `INSPECT` language. It does not show a keyboard/controller cursor or movement instructions.
- Activating Edit Chassis moves focus to the selected module and switches to `CHASSIS EDIT MODE`, `REFIT STATUS`, a gold cursor, and explicit movement/confirm/return instructions.
- Pointer entry may preview a cell; clicking the grid enters the same focused edit path before selection or placement resolves.
- A stored module remains visibly pending for placement. Global blockers such as mass capacity remain visible before edit mode instead of being hidden behind neutral inspection copy.
- The visible Edit Chassis action uses the active controller confirm label as well as the detailed tooltip.

## Focus and presentation

The selected module keeps a muted cyan inspection outline when the desk owns focus. Edit mode strengthens that outline and adds the gold cursor and full-panel focus border. Returning to the desk removes the active cursor without forgetting which system the inspector describes.

At 1280×720 with 110% text, the passive opening keeps its complete status line visible. Entering edit mode scrolls the left pane just enough to reveal the full grid, mode heading, placement status, and controls.

## Runtime safety

Refreshing the stage while the non-button chassis control owns focus now type-checks the focus owner before comparing it with the typed route-button list. This removes an engine error without changing route inspection behavior.

## Scope

This changes no placement, rotation, capacity, dependency, save, or simulation rule. It adds no drag-and-drop mode and does not remove direct pointer placement.

## Visual evidence

- `/tmp/long_march_audit_ashgate_opening_110.png`
- `/tmp/long_march_audit_ashgate_edit_mode_110.png`
- `/tmp/long_march_audit_veyru_opening_110.png`
