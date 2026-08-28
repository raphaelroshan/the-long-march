# Persistent Stage Header

## Player problem

The title and Pause action previously lived inside the left evidence scroll. Focusing a lower chassis panel could therefore scroll the session control completely off-screen, even though Pause is meant to remain immediately pointer-accessible in every state. The result screen made this easiest to reproduce because its decorative journey banner consumed vertical space above final-chassis review.

## Layout contract

- The stage title and contextual Pause action form a fixed header above the left evidence scroll.
- Resource metrics, phase, route, combat/result evidence, chassis, and reports continue to scroll beneath that header.
- Chassis auto-scroll still reveals the complete 6×4 inspector at 1280×720 with 110% text.
- The Pause label may change for route review or active chassis input, but the control itself never scrolls out of the viewport.
- Results retire the decorative journey banner. The completed path, result, resources, chassis, and debrief are the useful evidence at that point.
- Preparation and non-result travel states retain the journey banner and authored visual identity.

## Input behavior

This changes no shortcut priority. B/Escape still leaves a nested chassis or route interaction before opening Pause, while clicking the fixed Pause action opens it immediately.

## Scope

This is a presentation hierarchy change only. It does not alter simulation state, save data, focus destinations, route logic, or debrief outcomes.

## Visual evidence

- `/tmp/long_march_alpha261_opening_110.png`
- `/tmp/long_march_alpha261_battle_inspector_110.png`
- `/tmp/long_march_alpha261_debrief_110.png`
- `/tmp/long_march_alpha261_result_inspector_110.png`
