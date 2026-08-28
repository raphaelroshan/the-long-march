# Controller confirm/cancel layout

## Player problem

The prototype previously assumed one A-confirm/B-cancel convention in both its action map and instructional copy. Players accustomed to the opposite face-button convention could not change it, and changing only the labels would have made the interface dishonest.

## Interaction contract

- Settings exposes **Controller Confirm · A/B** as a persistent local preference.
- A-confirm maps the south face button to `ui_accept` and the east face button to `ui_cancel`.
- B-confirm swaps those two controller actions.
- Enter and Escape remain confirm and cancel in both layouts. Directional navigation, Tab traversal, mouse input, and simulation commands are unchanged.
- The title legend, Pause shortcut, field briefing, route-review cancellation, chassis tooltip/status, and live-stage helper copy update immediately.
- A stage opened after the setting changes inherits the selected action map and labels before its first focus handoff.
- Clean playtest reset restores A-confirm.

## Scope boundary

This is a bounded face-button convention preference, not a complete binding editor. It does not remap directions, mouse buttons, keyboard keys, triggers, bumpers, stick axes, or platform-specific glyph art. A broader binding UI needs conflict detection, per-device identification, inaccessible-binding recovery, and platform testing.

## Required evidence

- Action-map tests for both layouts and preserved Enter/Escape events.
- Invalid-preference normalization, persistence, remapped cancel behavior, visible-copy updates, stage inheritance, and clean-reset tests.
- 1280×720 Settings and live-stage captures at 110% text.
- Full verification under the minimum and current supported Godot versions.
