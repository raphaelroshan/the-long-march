# Checkpoint Toast Clearance

## Player problem

Automatic checkpoint feedback shares the stage header with the game title and the persistent Pause control. At 110% text, Route Review expands the Pause label leftward after a contract checkpoint appears, causing the old `CHECKPOINT SAVED` toast to cover part of the button.

## Interaction contract

- Checkpoint feedback remains brief, visible, non-modal, and does not take focus.
- The compact copy is `SAVED · <reason>`; the reason still names the committed contract, route, battle step, intervention, event, refit, or recovery action.
- The toast reserves a 250-pixel header slot beginning at x=330 in the 1280×720 reference layout.
- Positioning may move farther left when required, but keeps a minimum 12-pixel gap before the live Pause button.
- The reserved slot is safe for both the normal Pause label and the wider Route Review label, so later stage copy changes cannot slide beneath an already-visible toast.
- Opening Pause still dismisses the toast immediately.

## Accessibility and layout

The receipt retains its green border and text but states `SAVED` explicitly, so color is not the only signal. The shorter line remains readable at 110% text without covering the title, Pause action, resource row, or command desk.

## Scope

This changes no checkpoint timing, save contents, audio cue, duration, focus behavior, or persistence rule. It does not introduce a notification queue or move checkpoint feedback into the gameplay scroll areas.

## Visual evidence

- `/tmp/long_march_audit_route_review_110.png`
- `/tmp/long_march_audit_battle_approach_110.png`
- `/tmp/long_march_audit_battle_step_110.png`
