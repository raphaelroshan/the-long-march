# Pause Order Return

## Player problem

Pause correctly remembered the exact control a player left, which is important during chassis inspection or option comparison. That same behavior could be disorienting after a longer break: Resume returned to the old focus even when the player wanted the required contract, route, event, battle, recovery, or debrief action. The March Record exposed the current order, but reaching it required opening another panel and then navigating again.

## Interaction contract

- The primary Pause row offers two distinct actions:
  - **Resume Here** returns to the exact valid stage control focused before Pause.
  - **Go to Contract / Routes / Commit / Decision / Battle Step / Recovery / Feedback** resumes and focuses the current required control without activating it.
- The short explanation above the run summary names this distinction. The cancel shortcut remains equivalent to Resume Here.
- The order-return label derives from the same resolver and phase rules as the in-stage Go to Order control.
- The order path clears stale pre-pause focus before delegating to `focus_current_action()`.
- Focus resolution prioritizes authoritative phase and pending-decision state, preventing a stale visible control from winning over a debrief or battle action.
- Neither resume path changes serialized simulation state.

## Focus and layout

The two actions share the existing 54-pixel primary row, so Pause does not become taller. Left/right switches between them; each points down to its corresponding save action; the destructive bottom row points back to the matching column. Tab includes both actions and remains trapped inside Pause.

At 1280×720 with 110% text and High contrast, both `GO TO CONTRACT` and the longer `GO TO BATTLE STEP` remain fully visible without reducing the rest of the menu.

## Scope

This is presentation and input routing only. It does not change pause timing, autosave, save format, campaign state, or action authority.

## Visual evidence

- `/tmp/long_march_alpha252_pause_contract_110.png`
- `/tmp/long_march_alpha252_pause_battle_110.png`
