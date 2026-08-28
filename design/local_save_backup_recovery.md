# Local Save Backup Recovery — Private Alpha Slice

## Player-facing question

If the current Continue file is damaged, can the player recover the previous valid decision instead of being told only to delete progress?

## Save behavior

Before overwriting a valid Continue checkpoint, the stage copies its complete serialized text to `user://the_long_march_prototype.backup.save` and validates that backup through the authoritative `LongMarchState` loader. An invalid primary file is never promoted over a valid backup. If backup creation or validation fails, the new save is refused before the primary checkpoint is opened for writing.

The backup is a recovery copy, not a second selectable campaign slot. Normal Continue always targets the primary save.

## Title recovery flow

When the primary save is missing or invalid and the backup validates:

- Continue remains unavailable;
- the title status retains the primary validation error and adds the backup chapter, day, and location;
- the recovery action becomes **Restore Backup** instead of **Remove Unusable Save**;
- confirmation names the exact recovered checkpoint and states that March Charter, settings, and briefing progress remain unchanged;
- success restores the backup bytes to the primary path and focuses Continue.

If no valid backup exists, the existing explicit removal flow remains available.

## Clearing local saves

**Clear Local Save** removes both the primary Continue file and its recovery backup. It does not remove March Charter history, settings, briefing progress, the local playtest journal, or exported feedback.

## Required tests

- A second valid save creates a loadable predecessor backup.
- Corrupting the primary exposes Restore Backup and keeps Continue disabled.
- Cancelling preserves both files and restores focus.
- Confirming restores the exact backup and re-enables Continue.
- Invalid primary data is not copied over an existing valid backup.
- Clearing local saves removes both primary and backup files.
- Ashgate and Veyru flows still load only the primary save during normal Continue.

## Non-goals

- Multiple named save slots.
- Cloud or storefront synchronization.
- Automatic rollback without player confirmation.
- Recovery of March Charter, settings, or feedback files.
