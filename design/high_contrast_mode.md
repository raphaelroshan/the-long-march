# High-contrast interface mode

## Player problem

The prototype names its states in text, but the standard industrial palette intentionally uses muted secondary copy and narrow outlines. On dim displays or against the illustrated title background, that can make focus, disabled controls, route status, and combat detail harder to scan than the underlying decision deserves.

## Interaction contract

- Settings exposes **Visual Contrast · Standard/High** as a persistent local accessibility preference.
- High contrast darkens the title image veil and interactive backgrounds, brightens muted copy through a reviewed palette, and increases normal, disabled, hover, and focus outline thickness.
- The setting applies immediately to the title, every overlay, the live command desk, regional map nodes and paths, combat timeline/cards, and controls created after a stage opens.
- Route knowledge, risk, dependency health, pressure, combat contact, and run progress retain their written labels and existing symbols. Color reinforces those states but never becomes their only identifier.
- Switching back restores the latest authored standard colors, including a status that changed while high contrast was active.
- Clean playtest reset restores Standard contrast.

## Implementation boundary

The mode changes presentation only. It does not alter simulation values, route visibility, save compatibility, focus order, input actions, or event timing. A shared palette helper tracks authored base colors so repeated application is idempotent and later status updates can be restored safely.

This is a bounded high-contrast mode, not a claim of WCAG certification, color-vision coverage, screen-reader support, or a complete accessibility audit. Those require instrumented contrast measurement and human testing across representative displays.

## Required evidence

- Palette mapping, idempotence, changing-status, restoration, and transparency tests.
- Preference persistence, Settings focus order, stage inheritance, and clean-reset coverage.
- 1280×720 captures of Settings and a live stage at 110% text.
- Full verification under the minimum and current supported Godot versions.
