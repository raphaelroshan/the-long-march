# L1 Complete Journey Handoff Report

**Build:** `0.3.0-alpha.288`

**Viewport:** 1600×900

**Engine:** Godot 4.4.1

**Scope:** Clean First Watch → live Ashgate journey → Debrief

## Result

PASS. A clean local profile can complete the canonical introduction and the full five-contact Ashgate route through player-facing controls. No debug-only state mutation is required. The deterministic run ends at Meridian Pass with 5/5 contacts secured and a Scarred March result.

## Proven path

1. Open the title and choose **Learn to Command**.
2. Complete the First Watch placement, dependency, route, contact, emergency-order, damage-inspection, repair, and certification lessons.
3. Enter Ashgate, accept the guard assignment, open Plan Journey, inspect Rill Crossing, and commit the road.
4. Relaunch the application and use **Continue**. The committed departure surface and its primary-action focus are restored.
5. Resolve the Rill Crossing contact and stop at its arrival receipt.
6. Relaunch again and use **Continue**. The secured arrival surface, pending Lift Chain occurrence, and focused action are restored.
7. Resolve Lift Chain Sings, Broken Relay, Dead Switchyard, Morrowline, Mara's offer, and the Morrowline recovery tableau.
8. Continue through Lower Ash Road and the final Meridian Pass commitment.
9. Acknowledge final arrival and enter the terminal Debrief.

## Product correction found during the run

The shared journey presentation previously leaked live Ashgate campaign language into First Watch: Ashgate Depot, Rill Crossing, a declined Morrowline promise, a Morrowline payout, and Morrowline Services. First Watch now consistently uses Ashgate Muster Yard, Muster Road, a training order, a training-road receipt, the Muster Road Recovery Siding, and Muster Yard Services. Simulation data and outcomes are unchanged.

## Automated contract

[`test_complete_journey_handoff.gd`](../tests/test_complete_journey_handoff.gd) owns the complete app-shell path. It asserts:

- clean-save title focus and tutorial entry;
- visible First Watch placement, departure, contact, repair, and certification actions;
- the First Watch-to-Ashgate handoff;
- route inspection and explicit commitment focus;
- exact departure and arrival save/resume surfaces;
- authored events and recovery through visible controls;
- five secured encounters, final arrival, and focused Debrief;
- required controls remaining inside the 1600×900 stage bounds.

The test is part of `scripts/verify.sh`. Setting `LONG_MARCH_CAPTURE_DIR` enables deterministic visual evidence without changing the normal headless test path.

## Visual evidence

The complete capture sequence is stored in [`visual_evidence/v0.3.0-alpha.288-l1-journey-handoff/`](visual_evidence/v0.3.0-alpha.288-l1-journey-handoff/):

- title and First Watch prologue;
- First Watch departure, arrival, and completion;
- Ashgate handoff and route commitment;
- departure, road contact, and arrival receipt;
- roadside event and Morrowline recovery;
- final arrival and Debrief.

## Interpretation and remaining work

This evidence proves reachability, deterministic continuity, process-boundary persistence, focus restoration, and visual availability at 1600×900. It does not prove that an uncoached human understands or enjoys the journey. The next implementation gate is L2 responsive fortress presentation across supported sizes, accessibility preferences, keyboard, and controller paths.
