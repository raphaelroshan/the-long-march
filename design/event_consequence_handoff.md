# Event Consequence Handoff

## Player problem

Completed authored events explained their mechanical consequence above the fold, but that receipt stopped before naming the next action. When focus immediately moved to a road or recovery service, the scrollable Current Order could be outside the viewport, leaving the player to infer the transition from the newly visible controls.

## Copy contract

- A completed event receipt keeps its exact authored consequence.
- The receipt adds one **Next** line derived from the same authoritative guidance used by the Marchmaster's Desk.
- Route events direct the player to select, preview, and commit a road.
- Settlement events state the live service-action budget and the recovery/refit/route options.
- Chained events continue to name the next event instead; they do not prematurely advertise routes or services.
- The handoff does not choose, activate, or mutate the next action.

## Scope

This changes event-result presentation only. It does not alter event effects, route availability, service budgets, focus order, checkpoint timing, or deterministic state.

## Visual evidence

- `/tmp/long_march_alpha267_event_resolved_110.png`
- `/tmp/long_march_alpha267_morrowline_services_110.png`
