# Soot Orchard Tableau Report

**Build:** `0.3.0-alpha.337`

## Outcome

**The Orchard Burns** now has a dedicated code-native tableau rather than the generic ruin symbol. The scene shows:

- rows of blackened orchard trees and active fire pockets;
- a visible firebreak dividing the decision;
- a recoverable fuel cache on one side;
- stranded workers on the other;
- separate `RECOVER · +2 FUEL` and `RESCUE · +1 DAY` directions.

The right dock retains the complete authoritative effects: fuel and trust for recovery, or trust, time, pressure, and the Refugee Bunk requirement for rescue.

## Boundaries

This is presentation only. It does not alter event eligibility, rewards, route risk, Storm Front behavior, save data, or deterministic outcomes. The tableau consumes the existing stable `salvage_choice` ID and the live event choices exposed by `FortressState`.

The event still opens after the Soot Orchard contact and arrival receipt in the current state machine. Moving it into a post-contact/pre-arrival road phase is a separate simulation and persistence change and should not be implied by this visual pass.

## Verification

- The roadside presentation test asserts the `BURNING ORCHARD · FUEL OR PEOPLE` signature and both exact consequences.
- The settlement integration test verifies that the live event presenter maps `salvage_choice` to the same authored motif and copy.
- A 1280×720 rendered capture confirms that the fortress, orchard subjects, both actions, and required text remain visible together.

## Evidence limits

The screenshot proves layout and authored subject coverage, not final illustration quality or player comprehension. A future uncoached session should ask players what each side of the firebreak represents before they read the buttons.
