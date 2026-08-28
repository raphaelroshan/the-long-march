# Field Guide Chapter Launches

## Player problem

The title Field Guide explains Ashgate and Flooded Veyru together, but previously exposed only an Ashgate quick-start action. A player who understood the shared rules and wanted Veyru had to close the guide, relocate the chapter button, and re-establish intent. The action row therefore contradicted the guide's two-chapter framing.

## Interaction contract

- The Field Guide footer contains Back to Title, Quick Start Ashgate, and Start Flooded Veyru.
- Both chapter actions enter the prepared fortress directly. Ashgate skips the introductory overlay; Veyru retains its existing on-demand regional briefing.
- If a valid Continue checkpoint exists, either action uses the existing chapter-specific replacement confirmation.
- Cancelling a guide-launched confirmation restores focus to the exact Ashgate or Veyru action inside the still-visible guide.
- Replay wording is chapter-specific and derives from the March Charter result for that region, not from whether an unrelated Continue file happens to be complete.
- Launching from the guide uses the same `_request_new_game()` and `_open_stage()` paths as the title buttons.

## Focus and layout

The three footer actions form one closed left/right and Tab loop. Quick Start Ashgate remains the initial focus because the Field Guide is the title's fast replay path, while Flooded Veyru is one move to the right.

At 1280×720 with 110% text and High contrast, all three labels remain fully visible and the guide copy retains its intended line breaks.

## Scope

This adds no third chapter, unlock rule, save slot, or alternate launch behavior. It does not change region seeds, starting fortresses, onboarding persistence, or replacement-confirmation semantics.

## Visual evidence

- `/tmp/long_march_alpha254_field_guide_110.png`
