# Bounded Occurrence Scheduler

## Player question

Can the fortress absorb an unplanned operational problem without losing sight of the route it was built to survive?

## Scope

This slice adds a small deterministic occurrence scheduler to the Ashgate campaign. It is not a procedural story generator. Every occurrence is authored, uses stable IDs and typed choices, and changes existing fortress state through explicit commands.

Authored milestone events retain priority: the Orchard choice, Broken Relay decision, Red Wheel toll, Mara meeting, and Mara callback are never displaced. The scheduler may fill an otherwise-empty post-encounter or Morrowline-arrival phase with at most one primary occurrence.

## State contract

- Named stream: `ashgate_operational_occurrences_v1`.
- Stream cursor: advances only when a new eligible phase is evaluated.
- Phase history: records evaluated phase IDs so reopening UI or loading a checkpoint cannot roll again.
- Occurrence history: records resolved event ID, choice ID, and phase ID.
- Cooldowns: store the next campaign encounter at which a repeatable event is eligible.
- Active phase: accompanies a scheduled `campaign_event_pending` value through save/load.
- History is capped at eight entries. Old entries may fall out of the audit trail, but one-shot policy remains enforced through `campaign_decisions`.

Save schema version 6 persists and validates all scheduler fields. Version-5 saves migrate with an empty scheduler state.

## Selection rules

1. Resolve the phase only once.
2. Do not schedule over an active or authored event.
3. Filter candidates by phase, node, repeat policy, cooldown, and live fortress requirements.
4. Sort candidate IDs before selection.
5. Use the named stream, world seed, phase ID, and cursor to select one candidate or an intentional empty slot.
6. Surface the selected occurrence through the existing blocking event card.

The empty slot prevents every road from feeling scripted. No choice text, outcome text, or rules are generated at runtime.

## Initial authored library

### `boiler_heartbeat`

- Type: operational incident.
- Eligibility: a damaged operational engine and a Ready repair system.
- Choice: stop and inspect, repairing one engine durability for one day and one pressure; or keep cadence, reducing pressure by one while the engine loses one durability.
- Counter: the inspection choice is always available while the event is eligible. Keeping cadence locks when it would disable the engine.

### `lift_chain_sings`

- Type: operational incident.
- Eligibility: an operational Ammunition Lift and at least one operational weapon.
- Choice: spend six Ashmarks to brace the chain and reduce future route risk by two points; or carry the load, reduce pressure by one, and lose one lift durability.
- Counter: carrying the load remains available even without money; the resulting ammunition dependency failure is visible and recoverable.

### `the_last_dry_room`

- Type: operational incident.
- Eligibility: operational Refugee Bunk and Parts Crate.
- Choice: shelter people, gaining trust and Shelter while the Parts Crate loses one durability; or preserve the parts and repair the weakest damaged module while losing trust.
- Counter: shelter is always available. Preserving parts locks when no installed system is damaged.

### `the_miller_with_a_broken_wheel`

- Type: optional roadside meeting, not a recruit or relationship system.
- Eligibility: a Ready Field Workshop.
- Choice: lend the bench for fuel and trust at the cost of time, pressure, and one workshop durability; or keep moving, reducing pressure and losing trust.
- Counter: both choices are explicit and neither creates an unresolved character state.

## UI and debrief

Occurrences use the existing event card, keyboard/controller focus loop, and blocking departure rule. The card must show complete costs before commitment. The debrief lists resolved road occurrences in order so a tester can connect route state to the final fortress condition.

## Tests

- Same seed and eligible state produce the same selection.
- Different seeds can produce different selections or the intentional empty slot.
- Ineligible content is filtered before selection.
- A phase cannot roll twice.
- One-shot and cooldown rules are enforced.
- History remains bounded.
- Active occurrence, cursor, cooldowns, and histories survive save/load.
- Malformed scheduler state is rejected before mutation.
- Every selected occurrence has at least one enabled, visible counter.
- The event card and final debrief render scheduler content.

## Non-goals

- Procedural prose or generated choices.
- An unbounded event graph.
- A global relationship or reputation simulation.
- Replacing authored route events.
- More than one primary event in a phase.
- New resources created only for the scheduler.
