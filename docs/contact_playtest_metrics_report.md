# Contact Playtest Metrics Report

**Build:** `0.3.0-alpha.325`

## Purpose

The next roadmap gate requires consented, uncoached sessions. Exported feedback now carries a small local-only summary that helps reviewers distinguish “the tester never inspected the target” from “the tester inspected it but still misunderstood the consequence.”

## Recorded events

- `encounter_step`
- `contact_target_locked`
- `contact_target_inspected`
- `intervention_used`, including the encounter step

The export includes aggregate `session_metrics` counts for those four event families while preserving the ordered raw event list for careful review.

## Privacy boundary

No account, network request, analytics SDK, automatic upload, keystroke capture, free-form observation, or personal identifier was added. Data remains in the existing local journal and enters a feedback bundle only when the tester explicitly saves one.

## Interpretation

Counts indicate interaction, not understanding. Review them together with observer notes and the tester's written answers. Do not treat an inspection count as evidence that the player understood the target, and do not treat a low count as a defect without observing the surrounding decision.

## Verification

- Journal tests verify exact aggregate counts in the exported JSON.
- The complete prototype flow verifies that a real visible journey produces target-lock, inspection, and emergency-order metrics.
- Offline-boundary and full repository verification remain required.
