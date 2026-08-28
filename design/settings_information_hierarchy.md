# Settings Information Hierarchy

## Player problem

Settings accumulated twelve controls as private-alpha support improved. Every row explained itself, but the uninterrupted list mixed display, input, audio, checkpoint, support, and destructive reset concerns. At 110% text, a player could scroll to a control and lose the larger category that explained why it belonged there.

## Information architecture

The existing actions are grouped without changing their behavior or persistence:

1. **Display & Readability** — window mode, text size, and visual contrast.
2. **Controls & Feedback** — controller convention, transition motion, and interface audio.
3. **Runs & Local Data** — automatic checkpoints, build/data inspection, briefing state, Charter state, Continue data, and clean-playtest reset.

Each group has a compact non-interactive heading inside the scroll area. The fixed context line also names the section containing the focused action, so keyboard and controller users retain orientation when a long section header has scrolled away.

## Interaction contract

- Settings still opens on Display Mode and resets the scroll position to the first section.
- Focused buttons update the fixed title/paused breadcrumb before scrolling into view.
- Headings never enter the focus graph and do not add actions or hidden state.
- Existing dynamic disabled-action routing remains authoritative; unavailable reset actions are skipped exactly as before.
- Returning from Build & Local Data restores both the same button and its **Runs & Local Data** context.

## Scope

This is presentation hierarchy only. It does not add preferences, change defaults, move local files, alter confirmation behavior, or modify the settings schema.

## Visual evidence

- `/tmp/long_march_alpha253_settings_display_110.png`
- `/tmp/long_march_alpha253_settings_runs_110.png`

Both states are captured at 1280×720 with 110% text and High contrast.
