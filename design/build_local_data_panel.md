# Build & Local Data panel

## Tester problem

The title shows a build version and individual reset actions explain what they delete, but a tester still has no single in-game answer to three practical questions: exactly which build is running, which local state files currently exist, and where those files live. That makes support and feedback handoff depend on external instructions.

## Interaction contract

- Settings exposes **Build & Local Data** from both the title and a paused march.
- The panel identifies the exact application version and current desktop platform.
- It states the current prototype boundary: no account login, telemetry SDK, or automatic upload; feedback moves only when the tester explicitly shares an exported JSON report.
- It reports presence for Continue, recovery backup, March Charter, preferences, completed briefing, and the playtest journal, plus a count of tester-owned feedback exports.
- It displays the absolute Godot `user://` folder and provides **Copy Data Folder Path** for mouse, keyboard, or controller users.
- Copying writes only the folder path to the clipboard. It does not open a file browser, inspect file contents, upload data, or launch another application.
- Cancel or Back returns to the same Settings row. When opened during a run, the stage remains paused throughout.

## Scope boundary

The panel is read-only except for the explicit clipboard copy. Existing category-specific reset and recovery actions remain in Settings; this panel does not become a file manager, save-slot picker, cloud-sync UI, or support uploader.

The offline statement describes the current repository implementation. Future storefront adapters must update this contract if they introduce account, achievement, or cloud traffic.

## Required evidence

- Title and paused-context visibility, build/platform identity, file-presence reporting, path copy receipt, focus loop, and cancel-return tests.
- A 1280×720 capture at 110% text and High contrast.
- Existing privacy, reset, save recovery, and feedback-export tests remain green.
- Full verification under the minimum and current supported Godot versions.
