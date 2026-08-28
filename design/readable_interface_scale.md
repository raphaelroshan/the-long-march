# Readable interface scale

## Player problem

The alpha targets a dense 1280×720 desktop decision surface. A player who needs larger text should not have to lower the display resolution, magnify the entire canvas until controls are cropped, or lose access to route and chassis context.

## Interaction contract

- Settings exposes **Text Size · 100% / 110%** as a local accessibility preference.
- The change applies immediately to inherited and explicitly sized interface text and persists across launches.
- The logical 1280×720 canvas stays unchanged. Enlarging text must not squeeze the fixed chassis and command-desk columns off-screen.
- At 110%, the title removes its redundant small control-summary line and decorative right-side spacer. All start, utility, chapter-summary, and input-guide content remains visible.
- Settings uses a vertical scroll area for preference rows while its context, status receipt, and Back action remain fixed.
- Keyboard and controller focus scroll the active setting fully into view.
- Newly created playable stages receive the selected text size as soon as they enter the application shell.

## Boundaries

This slice provides one deliberately conservative large-text step. It does not claim arbitrary UI zoom, operating-system screen-reader support, localization reflow, or a complete accessibility certification. Those require broader layout and human validation.

## Required evidence

- Preference write/read validation and invalid-value fallback to 100%.
- UI tests for immediate text-size changes, focus order, lower-setting scrolling, and standard-size restoration.
- 1280×720 captures of Settings at both sizes and of the 110% title, Field Guide, live stage, and Pause menu.
