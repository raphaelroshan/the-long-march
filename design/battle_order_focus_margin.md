# Battle Order Focus Margin

## Player problem

At 110% text, moving keyboard or controller focus from encounter advancement into the emergency orders could leave only the clipped bottoms of the run-flow cards at the top of the Marchmaster's Desk. Current Order, Encounter Order, and the focused command were still usable, but the viewport boundary looked accidental.

## Interaction contract

- The scrollable desk reserves a small non-interactive trailing margin so lower actions can be positioned without clipping the preceding section.
- Emergency-order focus retains Current Order as its context anchor.
- Current Order, the complete Encounter Order heading, and the focused command remain visible together when the viewport permits.
- The trailing margin does not receive pointer, keyboard, or controller input.
- Normal battle entry remains at the top of the desk with the run tracker visible.

## Scope

This changes command-desk spacing only. It does not change intervention availability, previews, costs, targeting, battle timing, focus order, or simulation state.

## Visual evidence

- `/tmp/long_march_alpha265_battle_entry_settled_110.png`
- `/tmp/long_march_alpha265_battle_order_focus_110.png`
