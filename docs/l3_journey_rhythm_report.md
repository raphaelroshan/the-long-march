# L3 Journey Rhythm Report

**Build:** `0.3.0-alpha.290`

**Evidence viewport:** 1600×900

## Result

PASS. The existing Ashgate journey now distinguishes preparation, commitment, departure, motion, contact, consequence, arrival, recovery, and Debrief without changing authoritative state or adding content.

## Implemented rhythm

- Assignment decisions leave a concise receipt before the player moves to the departure gate.
- The route table retains the last committed contract, road, event, or service receipt; route hover and selection messages do not replace it.
- Route commitment still applies time, fuel, pressure, and save state atomically.
- The road view advances through **Departed**, **Road in Motion**, and **Contact Ahead** as a one-second presentation beat.
- The contact action is available from the first frame, so the player may skip the beat immediately.
- Reduced motion starts at **Contact Ahead** with no timed presentation.
- Arrival explicitly separates the resolved outcome, already-applied consequences, and next order.
- Roadside-event consequences remain visible when the route table reopens.

## Persistence and determinism

The last committed journey receipt is presentation state stored with the existing checkpoint. Reloading a committed departure restarts only its short visual beat and restores the same focused action; route cost and encounter state are unchanged. No animation callback mutates `FortressState`.

## Evidence

The capture sequence in [`visual_evidence/v0.3.0-alpha.290-l3-journey-rhythm/`](visual_evidence/v0.3.0-alpha.290-l3-journey-rhythm/) includes:

- assignment handoff and route commitment;
- Departed, Road in Motion, and Contact Ahead;
- road contact and arrival consequence receipt;
- roadside occurrence and its retained route-table receipt;
- recovery and terminal Debrief.

## Next gate

L4 should prove the complete cause-and-effect phase grammar for every existing major threat family, including readable intent, target, counter, impact, dependency change, and settle.
