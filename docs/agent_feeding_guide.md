# Agent Feeding Guide — The Long March

Feed the implementation agent one slice at a time. Each prompt assumes the agent has read `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md`. The current post-alpha handoff contract is [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md); use it before issuing a new task so the agent starts from the implemented Ashgate Lowlands and Flooded Veyru baseline rather than the historical prototype sequence.

## Current post-alpha feed order

The original prompts below describe the build-up of the prototype and are retained as historical context. The current implementation baseline is `0.3.0-alpha.245`; Feeds A through P are complete, so choose the next private-alpha hardening slice from repeated human playtest evidence.

### Current Feed A — fortress comprehension

**Status:** Complete through dependency cards, route comparison, and deterministic target explanations.

> Starting from the current Ashgate Lowlands implementation, improve one dependency or route decision’s presentation without changing simulation math. Add a visible inspector or causal explanation, preserve the command boundary, add UI/state assertions, run the full verification script, and capture the affected normal-resolution state. Do not add new content.

### Current Feed B — Water Condenser teaching slice

**Status:** Complete in `0.3.0-alpha.231`.

> Implement Water Condenser as a complete content slice. Add its stable definition, shape and placement constraints, heat/supply dependency, one visible vulnerability, two counters, one teaching encounter, recovery behavior, save/replay tests, content validation, UI inspector copy, and visual capture. Do not add a generic utility module or a new region in the same change.

### Current Feed C — specialist event chain

**Status:** Complete in `0.3.0-alpha.232` through Mara Flint's Morrowline recovery chain.

> Add Mara Flint or Sela Vonn through a three-event authored chain: meeting, practical repair-versus-refuge or schedule-versus-reliability choice, and later consequence. Use explicit typed commands and stable IDs. Add decline, scarcity, active-event save/load, deterministic replay, UI event-card smoke, and a causal debrief line. Do not create a dialogue-only reputation system.

### Current Feed D — bounded occurrence scheduler

**Status:** Complete in `0.3.0-alpha.233` with three operational incidents, one optional meeting, and a save-safe named random stream.

> Implement a seeded occurrence scheduler with one primary event per phase, hard eligibility filters, cooldowns, repeat policy, bounded history, named random stream, and save-safe active state. Start with three operational events and one optional meeting. Preserve at least one visible counter for every tested seed. Do not add procedural prose generation or an unbounded event graph.

### Current Feed E — Flooded Veyru chapter

**Status:** Complete in `0.3.0-alpha.234`.

> Implement Flooded Veyru as an isolated authored chapter using the existing fortress state and map contracts. Add one new pressure, one settlement, two viable route branches, one contract, a guaranteed recovery path, an isolated teaching encounter, a combination encounter, and a final commitment. Add deterministic route, save, UI, and balance tests. Do not build the full five-region campaign.

### Current Feed F — one regional consequence

**Status:** Complete in `0.3.0-alpha.235` through Public Archive Signal.

> Connect one completed Ashgate or Flooded Veyru decision to one visible regional development. Persist one small migration-safe consequence, show its cause on the map and in the debrief, and make it change a later option rather than grant a flat permanent stat bonus. Do not build the full campaign layer in the same change.

### Current Feed G — two-chapter replay flow

**Status:** Complete in `0.3.0-alpha.236` through the March Charter and March On flow.

> Record each proven region's best terminal result outside the Continue slot, show the bounded two-chapter Charter on the title, and let a debrief continue into the other region through an explicit save-aware confirmation. Preserve normal chapter seeds and starting state. Do not carry numerical run resources between regions or imply that the five-region campaign exists.

### Current Feed H — safe application close

**Status:** Complete in `0.3.0-alpha.237` through save-aware window-close handling.

> Intercept operating-system close requests. Quit immediately only from the title or an exactly checkpointed run; otherwise pause, name the current chapter and location, and offer Save & Quit or Keep Playing. Flush the existing save before exit, restore exact focus on cancel, and keep the app open after save failure. Do not add background timers or another save slot.

### Current Feed I — explicit Charter reset

**Status:** Complete in `0.3.0-alpha.238` through title-only March Charter reset.

> Give testers an explicit way to clear persistent chapter results and regional developments without touching Continue, settings, briefing progress, or exported feedback. Require exact confirmation copy, disable the action during an active run, restore focus on cancel, and refresh the title immediately on success.

### Current Feed J — local save backup recovery

**Status:** Complete in `0.3.0-alpha.239` through validated predecessor recovery.

> Before overwriting a valid Continue checkpoint, preserve and validate its predecessor. When the primary is missing or corrupt, offer an explicit title recovery instead of only deletion; identify the backup chapter, day, and location, preserve unrelated local data, and keep normal Continue bound to the primary file. Do not add multiple selectable save slots or cloud sync.

### Current Feed K — pause-accessible playtest notes

**Status:** Complete in `0.3.0-alpha.240` through the context-preserving Pause handoff.

> Let a tester open the existing local-only Playtest Notes form from Pause at any live decision. Name the region, day, location, and phase; preserve draft text and deterministic run state; return controller focus to Pause; and keep the result-screen path unchanged. Do not add analytics, uploads, accounts, or another feedback format.

### Current Feed L — readable interface text

**Status:** Complete in `0.3.0-alpha.241` through the bounded 100%/110% text-size preference.

> Add one persistent large-text option without shrinking the logical canvas or losing the two-column decision surface. Make Settings scroll focused rows into view, adapt secondary title spacing, apply the preference to newly opened stages, and inspect title, guide, stage, and pause at 1280×720. Do not claim arbitrary zoom or full accessibility certification.

### Current Feed M — clean playtest reset

**Status:** Complete in `0.3.0-alpha.242` through the title-only local-state reset.

> Add one confirmed title action that returns the build to a genuine first-launch test state: remove Continue and backup, Charter/developments, briefing completion, device preferences, and the current journal; restore defaults immediately; preserve exported feedback; and reject the action during a live run. Keep the narrower reset actions.

### Current Feed N — feedback export handoff

**Status:** Complete in `0.3.0-alpha.243` through the copyable local report path.

> After a successful local feedback export, expose its complete path through a controller-accessible action and visible copy receipt. Restore it while the file exists, remove stale actions safely, and preserve the explicit no-upload boundary. Do not open external applications or add automatic sharing.

### Current Feed O — interface audio feedback

**Status:** Complete in `0.3.0-alpha.244` through generated local interface cues and bounded volume control.

> Add restrained focus, activation, warning, and checkpoint audio cues across the title, overlays, and dynamically created stage controls. Provide a persistent Muted/40%/70%/100% setting, keep every cue paired with existing visual feedback, and verify clean reset. Do not imply that music, ambience, combat sound, or final mixing is complete.

### Current Feed P — high-contrast interface

**Status:** Complete in `0.3.0-alpha.245` through the persistent Standard/High visual contrast mode.

> Add one bounded high-contrast preference that darkens image-backed surfaces, brightens muted copy, and strengthens interactive, map, and combat outlines. Preserve every written status label and symbol, restore authored colors when disabled, verify 110% text at 1280×720, and avoid claiming full accessibility certification.

## Historical prototype feed sequence

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
