# Pause-accessible playtest notes

## Player problem

The alpha previously exposed its local feedback form only after a completed run. That is too late for a tester who becomes confused at a route, refit, event, recovery, or battle decision: the exact context is easy to forget, and abandoning the run to report it would distort the playtest.

## Interaction contract

- Pause exposes one **Record Playtest Notes** action before the destructive restart and title actions.
- Opening notes hides Pause, resumes UI processing for the modal, and does not advance or mutate the deterministic campaign state.
- The form names the active region, day, location, and phase so the tester can verify what will accompany the note.
- The privacy statement remains above the prompts: nothing is uploaded, and saving creates a local JSON file the tester may choose to share.
- Closing by button or controller cancel returns to the suspended Pause menu and focuses **Record Playtest Notes**.
- Resuming after that return restores the stage control that was focused before Pause first opened.
- Unsaved text remains in the form for the life of the current stage, allowing a tester to check the game and continue writing before export.
- The existing result-screen entry still returns directly to the debrief.

## Boundaries

This slice does not add analytics, background uploads, accounts, cloud storage, screenshots, or a second journal format. It reuses the existing local journal and exported feedback bundle, including its build and campaign snapshot.

## Required evidence

- App-shell coverage for focus order, exact context, controller cancel, state preservation, and same-stage draft retention.
- Result-flow coverage confirming its original Back to Results behavior and context.
- A 1280×720 capture of Pause and the notes modal with no clipped actions or prompts.
