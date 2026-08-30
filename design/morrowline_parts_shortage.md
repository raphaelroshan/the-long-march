# Morrowline Parts Shortage

## Player question

Is the safer Morrowline approach worth arriving with fewer repair options?

## Contract

- Accept the convoy: enemies on the Morrowline approach gain 1 HP. Safe arrival pays 30 Ashmarks, adds 2 trust, and preserves 2 Morrowline service actions.
- Decline the convoy: approach enemies keep normal endurance. Morrowline receives no parts wagon and can provide only 1 service action.

Both outcomes are stated at Ashgate before the decision. The later recovery screen repeats the cause and the remaining action budget.

## Implementation boundary

`guard_contract_status` remains the causal record. On Morrowline arrival, `morrowline_service_capacity()` derives a capacity of two from `accepted` or `completed`, and one from any other resolved state. `settlement_actions_remaining` then persists the live budget through the existing save format.

The shortage changes a recovery choice, not combat math. It introduces no new resource, reputation track, random roll, or presentation-owned rule.

## Viability

The completed-contract route retains its existing two-service recovery. The declined route can still complete five encounters by choosing the service that supports its planned fourth road. Cinder Quarry offers an optional field repair, but the alternate Signal Causeway path remains viable without taking it.
