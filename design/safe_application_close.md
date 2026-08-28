# Safe Application Close — Private Alpha Slice

## Player-facing question

If the operating system asks the game to close, will the player know whether the current march is safe before the process exits?

## Behavior

The application owns window-close handling rather than accepting the operating system request automatically.

- On the title, or when the live run exactly matches the local Continue checkpoint, close immediately.
- When a live run has unsaved changes, pause the stage and ask **Save before quitting?**
- Name the active chapter and location, and state that the exact decision will be written to the local Continue slot.
- **Keep Playing** restores the prior live or paused context and its focused control.
- **Save & Quit** writes and closes the save file before requesting process exit.
- If saving fails, keep the application open and offer **Try Save Again** or **Keep Playing**.
- Ignore repeated window-close requests while a confirmation is already open so the modal cannot be bypassed.

## Authority and persistence

The application shell owns process lifecycle and confirmation state. `Main.gd` continues to own save serialization of the authoritative `LongMarchState`; it now closes the file handle before reporting success. Window-close handling does not mutate simulation rules or introduce a second save format.

## Required tests

- The SceneTree does not auto-accept close requests.
- Title close requests exit without a warning.
- Unsaved live-stage close requests show the chapter/location confirmation.
- Repeated close requests cannot bypass the confirmation.
- Cancelling restores live-stage focus and processing.
- Cancelling from Pause or its Settings overlay restores the disabled stage and exact focused action.
- Save & Quit persists the exact live state even with autosave disabled.
- A subsequent close request exits immediately when live state matches the saved checkpoint.

## Non-goals

- Crash recovery after operating-system or hardware failure.
- Multiple rotating save slots.
- Cloud synchronization.
- Background autosave timers.
- Storefront shutdown callbacks.
