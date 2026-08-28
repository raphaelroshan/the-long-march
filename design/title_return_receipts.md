# Title Return Receipts

## Player problem

Returning to the title crosses a persistence boundary. A player may have saved the exact live decision, discarded unsaved changes while an older Continue checkpoint remains, or left without ever creating a checkpoint. The generic Continue summary describes the file that exists, but it does not say what happened to the run the player just left.

## Interaction contract

- Every return from a live stage produces one temporary title receipt.
- A saved live decision names the chapter, day, and location that Continue will restore.
- A saved terminal result states that Continue reopens that chapter's debrief.
- An unsaved return names the discarded chapter and distinguishes an older retained checkpoint from having no Continue checkpoint at all.
- The receipt is derived before the stage is released, using the same full serialized-state comparison that protects the existing Return to Title action.
- Starting or continuing a run clears the receipt. It is never written to a save, preference, journal, or March Charter file.

## Presentation

The receipt occupies the title action panel's existing save-status position. While it is visible, the longer generic checkpoint summary is hidden; focusing Continue still exposes its validated decision, build, fortress condition, and replacement boundary in the journey preview.

Saved receipts use the established checkpoint treatment. Discarded receipts use the established warning treatment. Both state their meaning in text so color is only reinforcement.

At 1280×720 with 110% text and High contrast, both two-line states fit above the lower screen edge without shrinking the chapter actions.

## Scope

This change adds no toast queue, notification history, second save slot, automatic recovery, timestamp field, or save-schema change. It does not alter when autosave runs or whether a return requires confirmation.

## Visual evidence

- `/tmp/long_march_alpha255_saved_receipt_110.png`
- `/tmp/long_march_alpha255_discarded_receipt_110.png`
