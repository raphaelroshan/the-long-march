# LM-GPT56-1B — Completion-Aware Journey Evidence

**Build:** `0.3.0-alpha.364`

**Status:** Complete. The committed 4.4.1 evidence now proves that its frames belong to one completed clean-save journey, rather than only proving that each PNG is valid.

## Player-facing journey

The canonical `ashgate_lowlands_alpha` fixture uses the normal title, First Watch, refit, route, travel, contact, event, recovery, arrival, and Debrief controls. It starts without local save data and ends at Meridian Pass after five secured contacts. Iven Pell's forecast is exchanged for Mara Flint's repair capacity; the forge-core promise returns after the fourth road; the final Debrief attributes the scarred result to the unused Morrowline service action and low hull.

The 1600×900 set contains 24 states, including the moving-road beats. The representative 1280×720 accessibility set contains 22 states with 110% text, high contrast, reduced motion, and alternate controller confirmation. Both include the title, First Watch, live refit, route commitment, interruption, contact, arrival, specialist conflict, recovery, changed road, callback, finale, and Debrief.

## Completion contract

`tests/test_complete_journey_handoff.gd` now records manifest schema 2 with:

- the `LM-GPT56-1B` profile and `ashgate_lowlands_alpha` journey IDs;
- clean-save and normal-player-action declarations owned by the fixture;
- the exact captured-state count;
- restored departure, pre-contact interruption, arrival, and unresolved specialist-crossroads checkpoints;
- a terminal state at `meridian_pass`, in `results`, with five encounters complete.

`tests/test_rendered_frame_capture.gd` requires those fields for both committed viewport sets in addition to the existing dimensions, readiness attempt, non-uniform image inspection, filename coverage, and SHA-256 checks. `scripts/verify.sh` requires the new completion-evidence PASS marker.

## Evidence

- [`v0.3.0-alpha.364-gpt56-journey-1600x900/`](visual_evidence/v0.3.0-alpha.364-gpt56-journey-1600x900/)
- [`v0.3.0-alpha.364-gpt56-journey-1280x720/`](visual_evidence/v0.3.0-alpha.364-gpt56-journey-1280x720/)

The images were captured with Godot 4.4.1 and remain the candidate evidence. The current workstation has Godot 4.7.2; it can run the deterministic headless fixture but its headless renderer does not emit the frame signal used by the 4.4.1 capture harness. No replacement pixels were accepted from the mismatched engine.

At 1280×720 the contact screen is dense but complete: fortress state, target and counter, prepared response, advance, all four interventions, and the six-step timeline remain visible. This is a human-comprehension question for LM-H1, not grounds for hiding causal information before observation.

## Verification

Focused verification passes on the current source:

```text
PASS: The Long March complete journey handoff
PASS: The Long March investment evaluation vertical
PASS: The Long March LM-GPT56-1 full creative journey
PASS: The Long March LM-GPT56-1B completion evidence contract
PASS: The Long March LM-GPT56-0 rendered-frame evidence gate
```

The final full-suite result is recorded in the pull request that carries this report.

## Next packet

Run one consented, uncoached **LM-H1** private-alpha cohort against the exact checksummed candidate. Record observed pacing, comprehension, accessibility, and replay intent without treating authored timing or automation as human evidence.
