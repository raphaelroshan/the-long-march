# Chassis Inspector Copy Fit

## Player problem

The fixed chassis detail column is 320 pixels wide. Its previous locked-phase helper sentences were drawn as one line and clipped before their action, leaving battle and debrief inspection instructions visibly unfinished. The generic **System Status** heading also failed to distinguish live targeting from final-result review.

## Presentation contract

- Battle inspection uses **Battle System** and a compact **Targeting** hint.
- Debrief inspection uses **Final System** and a compact **Review** hint.
- Travel and map inspection use **System Status** and explicitly state that refit returns at a road stop.
- Refit retains **Inspected System** while passive and **Refit Status** while the chassis owns focus.
- Locked-phase help is constrained to the existing 320-pixel detail column and may wrap to at most two lines.
- Copy names the available action; it does not restate unavailable placement controls.

## Scope

This is presentation-only. It changes no focus path, placement rule, target selection, damage calculation, result, or save data.

## Visual evidence

- `/tmp/long_march_alpha260_battle_inspector_110.png`
- `/tmp/long_march_alpha260_result_inspector_110.png`
