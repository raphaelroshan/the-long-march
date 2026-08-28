# Feedback export handoff

## Tester problem

The feedback form saves a useful local JSON report, but previously exposed its complete location only as a pointer tooltip. A keyboard or controller tester could create the report and still have no practical path from the in-game receipt to the file they were asked to share.

## Interaction contract

- Before the first successful save, no report-path action is shown.
- After saving, the action row exposes **Copy Report Path** between the safe return and Save Again actions.
- The button tooltip retains the complete absolute path, while the visible receipt names the report file and exact build.
- Copying writes only the path string to the operating-system clipboard. It does not upload, attach, move, rename, or open the report.
- A visible receipt confirms that the path was copied and explains where to paste it.
- Closing and reopening the form in the same stage restores the saved-report receipt and path action while the file still exists.
- If the report was moved or deleted, using the stale action removes it from the focus cycle, explains that the file is unavailable, and returns focus to Save Again.
- The result and pause entry paths share the same behavior.

## Privacy boundary

Nothing is sent automatically. The tester still decides whether to paste the path into a file browser, message, or another approved sharing surface. Clipboard content is not persisted in game state or included in later reports.

## Required evidence

- Save, action visibility, tooltip, controller order, copy receipt, reopen, and stale-file tests.
- A 1280×720 capture of the saved and copied states at 110% text.
- Existing feedback payload and local-only privacy assertions remain unchanged.
