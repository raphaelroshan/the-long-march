# Pointer Pause Resume Context

## Player problem

The fixed Pause button is intentionally available to pointer users in every stage state. A normal focusable button can take keyboard focus when clicked before the application records the pre-pause control, causing **Resume Here** to return to Pause itself instead of the contract, route, battle action, or chassis context the player was using.

## Input contract

- The persistent Pause button remains clickable and keeps its phase-aware label and tooltip.
- It does not participate in keyboard/controller focus navigation; Escape and the configured cancel button already provide the direct non-pointer pause path.
- Pointer activation preserves the currently focused stage control before the overlay opens.
- **Resume Here** restores that exact valid control.
- **Go to…** continues to ignore the prior focus and resolves the current mandatory action.
- If the retained control becomes hidden or disabled, the existing focus resolver chooses the authoritative current action.

## Scope

This changes no pause contents, shortcut mapping, process suspension, save behavior, confirmation flow, or gameplay state.

## Visual evidence

- `/tmp/long_march_alpha262_pointer_pause_110.png`
- `/tmp/long_march_alpha262_pointer_resume_110.png`
