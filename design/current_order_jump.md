# Current-order jump

## Player problem

The Marchmaster's Desk can become taller than a 720p viewport. Focus-aware scrolling keeps individual controls visible, but after inspecting the chassis, reading route intelligence, or reviewing a long event, a player can lose the mandatory action named by **Current Order** and must search the desk again.

## Interaction contract

- A compact **Go to…** control remains beside the Run Flow heading at the top of the desk.
- Its label follows the actual phase: Contract, Routes, Commit, Decision, Battle Step, Recovery, Feedback, or Departure.
- Activating it calls the existing authoritative focus resolver. It moves focus and scrolls to the real control; it never chooses, commits, advances, purchases, or otherwise changes state.
- The action joins keyboard/controller focus cycles in planning, battle, and results.
- When a selected route is blocked, the label remains **Go to Routes** because the disabled Commit control cannot receive focus.
- The compact route-review cancel action remains fully readable beside Commit at 110% text.

## Scope boundary

This is navigation over existing controls. It does not create a second action path, bypass prerequisites, change focus priority, alter simulation state, or introduce keyboard shortcuts that conflict with chassis input.

## Required evidence

- Contract, route, route-commit, event, battle, recovery, and debrief states produce the correct label.
- Activating the jump focuses the same control chosen by `focus_current_action()` and leaves serialized state unchanged.
- Focus-triggered scrolling keeps the destination visible.
- The top control and route confirmation row remain readable at 1280×720 with 110% text and High contrast.
