# March Charter Reset — Local Data Control

## Player-facing question

Can a tester deliberately return persistent regional history to a clean state without also losing the current Continue checkpoint, accessibility settings, or briefing preference?

## Behavior

Title Settings exposes a separate **Reset March Charter** action whenever the local profile file exists. It requires a confirmation that names both categories being removed:

- best Ashgate and Flooded Veyru results;
- authored regional developments such as Public Archive Signal.

The confirmation also names what remains: Continue, settings, and briefing progress. After success, Settings reports the preserved data, disables the now-empty Charter action, and returns focus to an enabled control. The title immediately returns to `0/2` regions survived and removes development-specific guidance.

## Active-run boundary

The action is disabled in Settings opened from Pause. An active run contains a deterministic snapshot of its regional developments; deleting the profile underneath that stage would make the title and run disagree about what is active. The player must return to the title before resetting persistent history.

## Ownership and failure behavior

`CampaignProgress` owns deletion of its profile path and clears its in-memory collections only after file removal succeeds. The application shell owns confirmation, Settings status, focus, and title refresh. A deletion error leaves the record intact and keeps the reset action available.

## Required tests

- Profile clearing removes both developments and region results from disk and memory.
- No-record Settings disables the action and omits it from controller focus.
- Paused Settings disables the action even when a Charter exists.
- Confirmation distinguishes Charter, Continue, settings, and briefing data.
- Cancel preserves the file and restores focus.
- Confirm preserves the Continue save and settings file.
- Title Charter and Veyru development guidance refresh immediately.

## Non-goals

- Clearing every local file in one action.
- Resetting an active run's deterministic snapshot.
- Deleting exported playtest feedback.
- Multiple profiles or cloud progression.
