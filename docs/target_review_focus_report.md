# Target Review Focus Report

**Build:** `0.3.0-alpha.324`

## Player question

When a threat first chooses a target, can a keyboard or controller player accidentally resolve the next combat beat by pressing confirm twice?

## Change

Forecast entry still focuses `Advance`, preserving fast step-by-step travel. When the contact view changes from no target to an authoritative target while Advance has focus, focus moves to `Inspect Chassis`. Opening an already targeted contact also defaults to inspection.

The action is not modal: Advance remains visible and enabled, pointer input is unchanged, and no simulation step is inserted. The focus change simply makes the newly revealed target the deliberate next review point.

## Verification

- Road-contact tests cover forecast default focus, first-target focus transfer, and active-contact re-entry.
- Complete prototype and journey tests preserve direct action routing and arrival flow.
- The full repository verification suite remains the merge gate.

## Evidence

- [Inspect focused after target lock](visual_evidence/v0.3.0-alpha.324-target-review-focus/10_target_review_focus.png)

SHA-256: `e5ddd16b0b7d9b030cf11803d3fd5cd8533698fe904cbd883d10da5a6fec543c`
