# Result-Aware Refit Audio

**Build:** `0.3.0-alpha.311`

## Purpose

Give the First Watch placement lessons and later workshop refits concise physical feedback. Players should hear whether a module latched into place, changed orientation, returned to storage, or was rejected without needing sound to discover the reason.

## Implemented

- Added temporary CC0 cues for successful placement/movement, rotation, removal, and blocked refit commands.
- Routes successful sounds through the existing checkpoint boundary so they follow the authoritative state change.
- Routes rejected commands through a presentation-only signal after the simulation returns its failure reason.
- Suppresses generic button clicks on rotation and removal to avoid double feedback.
- Retains the full visual placement preview and written blocker in every case.

## Boundaries

Audio does not validate placement, move modules, rotate footprints, change storage, consume resources, write saves, or advance the tutorial. It remains pooled, volume-controlled, muteable, and independent of input method.

## Verification

- Interface-audio tests cover the four cue IDs, asset routing, fallback behavior, and mute suppression.
- Guided First Watch coverage verifies an invalid placement produces the warning cue and a valid engine placement produces the latch cue.
- Full repository verification must pass before merge.

## Remaining human question

Do the temporary sounds make accepted and rejected chassis edits immediately understandable at comfortable volume, or do final recorded effects need a heavier industrial character?
