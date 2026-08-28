# Interface audio feedback

## Player problem

The title, overlays, and playable stage already preserve keyboard, controller, and pointer parity, but every action is silent. Focus changes, confirmations, save checkpoints, and destructive warnings therefore rely on sight alone and the build feels less responsive than its interaction model actually is.

## Interaction contract

- A short, quiet rising cue confirms focus movement between buttons.
- A distinct confirmation cue follows ordinary button activation.
- Checkpoint receipts use a slightly longer notice cue alongside the existing visible toast.
- Confirmation dialogs use a low warning cue alongside their explicit title, copy, safe default, and focus trap.
- Buttons created inside a newly opened playable stage receive the same behavior as title and overlay controls.
- Audio never replaces text, color, focus, or receipts. Muting leaves the complete visual interaction contract intact.

## Comfort and settings

Settings exposes one local **Interface Audio** control with four bounded levels: Muted, 40%, 70%, and 100%. The default is 70%. Moving from Muted to an audible level previews the selected volume, and clean playtest reset restores the default.

The cues are generated from deterministic short PCM envelopes at runtime. They require no asset download, network access, middleware, or third-party license. A small player pool prevents quick focus and activation sounds from cutting each other off.

## Scope boundary

This is interaction feedback for a test build, not the final audio direction. It does not add music, ambience, combat effects, voice, dynamic mixing, spatial audio, device selection, or a master-volume promise. Those require authored assets and human listening tests on the release platforms.

## Required evidence

- Generated cue, bounded-volume, mute, dynamic-button, persistence, and clean-reset tests.
- Title and live-stage shell tests proving the same controller reaches buttons created after launch.
- A 1280×720 Settings capture at 110% text with Interface Audio focused and fully visible.
- Full Godot 4.4.1 and current-engine verification.
