# Named Specialist Identity

**Build:** `0.3.0-alpha.313`

## Purpose

Make the two implemented specialists feel like people attached to specific work, while keeping their decisions and costs more important than portrait art.

## Implemented

- Moved Iven Pell's existing recruitment control into the active Broken Relay journey planner.
- Groups Iven's name, signal-officer role, belief, exact route and combat effects, availability state, and recruitment action in one card.
- Gives an available Iven offer default controller focus; a locked offer remains readable without blocking route selection.
- Adds a stable code-native Iven silhouette with a relay mast and readiness lamp.
- Adds Mara Flint beside the open forge in her meeting, forge-core choice, and fourth-road promise check.
- Identifies Mara as forge master and states her repair-first position before recruitment.

## Boundaries

This pass changes presentation and control placement only. It adds no specialist slot, relationship meter, dialogue tree, recruitment rule, cost, route modifier, save field, or random decision.

## Verification

- Presenter coverage verifies that Iven appears only at the Broken Relay and does not mutate state.
- Full-flow coverage verifies the recruitment control is visible in the active planner, exposes its blocker and exact effects, and receives focus when legal.
- Roadside-event coverage verifies Mara's stable identity and meeting composition.
- 1280×720 captures cover Iven's locked and ready states and Mara's meeting.

## Remaining human question

Can a new player remember which specialist changes signals and which changes repairs after one uncoached run?
