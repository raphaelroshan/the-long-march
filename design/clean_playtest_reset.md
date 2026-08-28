# Clean playtest reset

## Tester problem

A returning tester previously had to clear Continue, reset the March Charter, reset briefing completion, and manually restore device preferences through separate actions. That is useful for targeted debugging but unreliable when the next session must reproduce a genuine first launch.

## Interaction contract

- Title Settings exposes one **Reset Playtest Data** action when any managed local state exists.
- The action is disabled from paused Settings so an active deterministic run cannot disagree with the shell state beneath it.
- Confirmation names every removed category: Continue and backup, March Charter developments/results, briefing completion, preferences, and the current local playtest journal.
- Confirmation also states that separately exported playtest reports remain available.
- Cancel preserves every file and restores focus to **Reset Playtest Data**.
- Confirm removes each managed file, rebuilds empty in-memory campaign progress, restores windowed/100% text/standard motion/autosave defaults, and immediately presents the guided first-launch title flow.
- A partial filesystem failure is reported instead of claiming a clean state; in-memory preferences and Charter are reloaded from whatever files remain.

## Preserved data

Files named `the_long_march_feedback_*.json` are tester-owned exports. The reset never discovers or deletes them. Storefront data and cloud saves do not exist in this alpha.

## Boundaries

The individual Clear Local Save, Reset March Charter, and Reset Completed Briefing actions remain available for narrower testing. This action does not uninstall the executable, remove OS-level logs, or delete arbitrary files from the Godot user-data directory.

## Required evidence

- Confirmation/cancel/focus coverage.
- Exact deletion checks for every managed path.
- Byte-preservation check for an exported feedback report.
- Preference and title-state restoration checks.
- 1280×720 captures of the lower Settings action and confirmation at 110% text.
