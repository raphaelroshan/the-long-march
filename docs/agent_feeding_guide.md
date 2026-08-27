# Agent Feeding Guide — The Long March

Feed the implementation agent one slice at a time. Each prompt assumes the agent has read `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md`.

## Prompt 1 — Chassis placement

> Implement the smallest deterministic chassis-placement slice. Add module definitions with stable IDs, shape occupancy, rotation where supported, overlap checks, grid bounds, and the two exterior mount limit. Add headless tests for valid placement, overlap rejection, out-of-bounds rejection, rotation, and removal. Do not add combat or UI behavior yet.

## Prompt 2 — Dependency graph

> Add explicit dependency evaluation for fuel-to-engine, generator-to-power, ammunition-to-weapon, crew-to-workshop, visibility-to-signal, and parts-to-repair. Each dependency must return operational state, benefit, and failure reason. Add tests that isolate one dependency at a time. Keep all logic in `src/core/`.

## Prompt 3 — Power, heat, and movement

> Implement mass, power output, power draw, heat, heat limit, fuel use, route days, route risk, and travel reward. Make the summary explain which system is over budget. Add fixed-seed tests for safe road, exposed shortcut, and salvage detour. Do not add random behavior that cannot be replayed.

## Prompt 4 — First threat doctrine

> Implement Road Raiders as the first automatic threat. It should forecast a target category, resolve against cargo or exterior mounts, and produce a causal log. Add at least two counter-options: protect the cargo or show a weapon. Add a recoverable failure path.

## Prompt 5 — Vertical threats

> Add Climbers and Burrowers as separate doctrines. Climbers bypass the front and test signal coverage; Burrowers test lower-hull and workshop redundancy. The forecast must show likely target, timing, confidence, and counter-options. Add deterministic tests for each doctrine.

## Prompt 6 — Interventions

> Implement Shift Power, Seal Compartment, Vent Heat, and Cut Loose Cargo as explicit commands with command-point costs, visible results, and deterministic tests. An intervention must create a tradeoff rather than simply increase the player’s power.

## Prompt 7 — Settlement recovery

> Add two settlements with repair, refit, salvage, contract, and recruit actions. A damaged fortress must be able to trade a lower-value contract or repair before continuing. Add a test for recovery after a module loss.

## Prompt 8 — Campaign content

> Load the stable content manifest and implement one authored event from chapter one. Map its requirements and effects to explicit runtime commands. Do not interpret prose as code. Add a test that the event choices produce the documented state changes.

## Prompt 9 — Presentation

> Build one readable fortress screen over the existing simulation. Show the chassis grid, module names, dependencies, power, heat, mass, fuel, hull, threat forecast, and event log. Do not move logic into the UI. Add keyboard and controller paths to the same commands.

## Prompt 10 — Review and polish

> Run policy checks, content validation, headless tests, and the AI review contract. Explain any warnings. Check that every defeat has a causal explanation and a recovery route, and that the screenshot communicates the fortress’s spatial logic without requiring hidden knowledge.

## Prompt 11 — Facility catalog

> Implement one facility family from `content/gameplay_framework.json`, beginning with Boiler Heart, Coal Bunker, and Water Condenser. Add explicit dependency results, visible power/heat/mass effects, damage states, and one recovery path. Do not implement the entire catalog in one change.

## Prompt 12 — FTL-like node map

> Add an authored branching node graph for `ashgate_lowlands` with two or three visible choices per step. Each edge must expose travel days, fuel, route risk, and contract relevance. Add known, forecast, and unscouted visibility bands plus a deterministic closure-pressure clock that cannot remove the only recovery path.

## Prompt 13 — Settlement service hub

> Implement Ashgate Depot and Morrowline Camp as small service hubs. Add fuel, repair, recruit, trade, rumor, escort, and contract actions as explicit commands. Test that a damaged fortress can recover through at least two different settlement choices.

## Prompt 14 — Character pressure

> Add one specialist with a facility benefit and a conflicting campaign priority. Start with Mara Flint or Iven Pell. The character must change a command result, contract, route, or facility behavior; dialogue alone is insufficient. Add a deterministic test and a visible explanation.

## Prompt 15 — Regional chapter

> Add the Flooded Veyru as the next authored chapter. Introduce one new settlement, one new hazard, one new route branch, and one event. Keep regional pressure visible and preserve a guaranteed recovery node.

## Prompt 16 — Campaign review

> Review the full facility, map, settlement, faction, and character package against `design/fortress_facilities_and_mechanics.md`, `design/map_regions_and_settlements.md`, and `design/characters_factions_and_campaign.md`. Reject hidden costs, universal best layouts, unforecastable threats, and content that does not create a physical or route decision.
