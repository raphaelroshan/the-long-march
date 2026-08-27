# Ashgate Lowlands Alpha Chapter

## Purpose

This document is the implementation contract for the first playable region. The chapter must feel like a short campaign rather than a sequence of disconnected battles: the player reads an uncertain map, commits to five encounters, resolves local problems, recovers at Morrowline, and reaches Meridian Pass with the consequences of earlier choices intact.

## Authored route graph

```text
Ashgate Depot
├── Rill Crossing ─────┬── Broken Relay ───────┐
└── The Soot Orchard ──┤                       ├── Morrowline Camp
                       └── Red Wheel Toll ─────┘

Morrowline Camp
├── Lower Ash Road ─────┐
└── Signal Causeway ─────┴── Meridian Pass
```

Every successful route contains exactly five encounters:

1. Rill Crossing or The Soot Orchard
2. Broken Relay or Red Wheel Toll Bridge
3. Morrowline Camp approach
4. Lower Ash Road or Signal Causeway
5. Meridian Pass

The graph is authored rather than procedural so encounter order, recovery access, and narrative consequences remain testable. Later regions may assemble authored node groups, but they should preserve the same guarantees.

## Information and pressure

Nodes are **known**, **forecast**, or **unscouted**. Known nodes reveal exact threats. Forecast nodes show their general hazard and pressure. Unscouted nodes disclose only a broad warning. A ready forecasting system or Iven Pell upgrades immediate choices to known and reduces route risk.

Closure pressure has three visible bands:

- **Watch** at 0–2
- **Closing** at 3–4
- **Break** at 5 or more

Travel and noisy decisions raise pressure. At Break, Signal Causeway closes unless the fortress has reliable forecasting. Lower Ash Road never closes, so pressure can remove an advantageous route but cannot silently delete the only path to the chapter end.

## First-region decisions

### Morrowline Parts Guard

Ashgate offers one contract before departure. Accepting it makes the Morrowline approach tougher by adding endurance to the attacking force. Delivering the convoy pays 30 Ashmarks and two settlement trust. Declining is a valid mobility-first choice and does not block progression.

### The Soot Orchard

The fortress can recover two fuel immediately or, with an operational refuge module, spend a day rescuing trapped workers. Rescue raises trust and shelter tendency; taking fuel lowers trust. Rescued workers produce an additional benefit when they reach Morrowline.

### Broken Relay and Iven Pell

An operational signal system can restore and broadcast the relay. Doing so improves trust and knowledge but raises closure pressure. Moving silently reduces road risk and pressure. After restoration, Iven Pell can join if the fortress has operational crew space and can spend 12 Ashmarks. Iven reveals exact immediate threats, reduces forecast risk, mitigates Storm Front pressure, and keeps Signal Causeway available at Break.

### Red Wheel Toll Bridge

The fortress can pay 10 Ashmarks to reduce pursuit pressure or break the toll post, recover seized coin, gain trust, and increase pressure. Both choices must state their immediate cost before confirmation.

## Threat coverage

- Rill Crossing teaches Road Raider targeting.
- The Soot Orchard introduces Storm Front pressure.
- Broken Relay tests Climbers and signal readiness.
- Red Wheel Toll combines Raiders and Climbers.
- Morrowline tests contract endurance and the value of recovery.
- Lower Ash Road tests Burrowers against engines and lower-hull protection.
- Signal Causeway rewards forecasting against a Storm Front and Climbers.
- Meridian Pass is the Siege Beast capstone and may gain an additional Climber at Break pressure.

Each threat keeps at least two counters through layout, doctrine, route knowledge, intervention, or specialist support.

## Recovery contract

A non-final defeat is a forced retreat, not an erased run. The fortress returns to its last secured node, loses one day and up to 10 Ashmarks, gains two closure pressure, and receives a limping recovery: at least three hull, two fuel, and one durability on installed engine and fuel modules. The player can then refit or choose another reachable route.

Failure at Meridian Pass ends the run because it is the chapter's declared final commitment. The result screen must retain the causal encounter report.

## Alpha exit criteria

- A fresh run can complete the authored graph through visible UI controls.
- The graph distinguishes current, secured, available, decision-blocked, closed, and future nodes without relying on color alone.
- Selecting a route previews its known costs and information before a separate commit action begins travel.
- Exactly five encounters are counted on a successful run.
- At least two distinct first-half paths and both Morrowline departures are viable with appropriate preparation.
- Contract, event, specialist, pressure, route visibility, retreat, and save state are deterministic and serializable.
- Pressure never removes the only forward route.
- A default prepared build has a viable path, while poor layouts can produce understandable recoverable failure.
- The battle report explains target selection, module damage, dependency loss, and final outcome.
- Combat presentation exposes enemy arrival timing, current targets, counters, step progression, and module durability without requiring the raw log.
