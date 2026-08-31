# Pre-contact Road Interruption Report

**Build:** `0.3.0-alpha.336`

## Outcome

The first eligible Ashgate journey now contains a real road decision between the moving-fortress presentation and hostile contact. On the road from Ashgate Depot to Rill Crossing, **The Lift Chain Sings** appears when the fortress has both an operational Ammunition Lift and weapon.

Route costs and the Road Raider contact are already committed. The interruption does not move the fortress to Rill Crossing, reroll the threat, or advance encounter time. The player must either spend 6 Ashmarks on a brace or accept 1 Ammunition Lift durability loss in exchange for 1 lower blockade pressure. The same configured contact opens immediately afterward.

## Implementation contract

- `FortressState` owns eligibility, the stable `pre_contact_1_rill_crossing` phase ID, the pending choice, its consequence, and the combat lock.
- `advance_encounter` and `use_encounter_intervention` reject commands while the interruption is active.
- Save data already carries the pending event, active occurrence phase, committed route, contact composition, and step-zero encounter state; no schema duplication was added.
- The march surface labels its next action as `REVIEW INTERRUPTION`. Skip and Reduced Motion may bypass animation time only.
- The roadside tableau shows `Ashgate Depot → Rill Crossing`, `CONTACT WAITING`, exact choice effects, and the live fortress.
- If the required lift-and-weapon dependency is absent, the phase is evaluated once and the road proceeds directly to contact rather than presenting an impossible choice.

## Verification

- Deterministic core coverage verifies scheduling, stable phase identity, save/load, origin retention, blocked combat commands, physical consequence application, post-choice handoff, and ineligible-loadout behavior.
- Full UI coverage saves while the interruption is visible, reloads through the road handoff, returns to the same choice, resolves it, and confirms focus on the untouched contact.
- Standard and responsive journey profiles verify 1600×900 and 1280×720 with 110% text, high contrast, reduced motion, and alternate controller labels.
- Tutorial and Flooded Veyru flows remain direct because this authored event belongs only to the eligible Ashgate opening.

## Evidence limits

The captures prove layout containment and deterministic state continuity. They do not prove that an uncoached player understands why the lift became vulnerable, finds the choice interesting, or considers the costs balanced. Those questions remain part of the private-alpha observation gate.
