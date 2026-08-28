# Agent Feeding Guide — The Long March

Feed the implementation agent one slice at a time. Each prompt assumes the agent has read `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md`. The current post-alpha handoff contract is [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md); use it before issuing a new task so the agent starts from the implemented Ashgate Lowlands and Flooded Veyru baseline rather than the historical prototype sequence.

## Current post-alpha feed order

The original prompts below describe the build-up of the prototype and are retained as historical context. The current implementation baseline is `0.3.0-alpha.263`; Feeds A through AH are complete, so choose the next private-alpha hardening slice from repeated human playtest evidence.

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

### Current Feed Q — controller confirm convention

**Status:** Complete in `0.3.0-alpha.246` through the persistent A-confirm/B-confirm controller layout.

> Let a tester swap the south/east face buttons used for confirm and cancel. Apply the real `ui_accept`/`ui_cancel` bindings, preserve Enter/Escape, update every visible controller hint, pass the layout into newly opened stages, and provide a safe default through clean reset. Do not describe this bounded convention switch as a complete binding editor.

### Current Feed R — build and local-data transparency

**Status:** Complete in `0.3.0-alpha.247` through the read-only Build & Local Data panel.

> Give testers one title/paused Settings panel that names the exact build and platform, states the current offline boundary, reports each managed local-data category, counts exported reports, and exposes a copyable `user://` folder path. Preserve pause and focus context. Do not open external applications, inspect report contents, or add upload behavior.

### Current Feed S — action-aware journey preview

**Status:** Complete in `0.3.0-alpha.248` through the responsive title journey card.

> Make each title start, Continue, and recovery action explain the exact journey or checkpoint it will open. Update one existing card on focus or hover, restore keyboard/controller context after mouse exit, and name obligation, pressure, recovery, finale, or saved next decision. Do not add another confirmation step or change gameplay state.

### Current Feed T — pause-accessible March Record

**Status:** Complete in `0.3.0-alpha.249` through the read-only March Record.

> Give a paused or completed run one compact record of its seed identity, current order, secured path, pressure, commitments, authored decisions, occurrences, and fortress condition. Keep the stage suspended, make copy explicit and local-only, return focus to Pause, and include the same identity in debrief and feedback data. Do not change simulation state or imply that a seed alone reproduces player commands.

### Current Feed U — current-order jump

**Status:** Complete in `0.3.0-alpha.250` through the persistent Go to Order control.

> Let players return from any Marchmaster's Desk scroll position to the real mandatory control named by Current Order. Reuse the existing phase-aware focus resolver, update the visible label for contract, routes, commit, event, battle, recovery, and debrief, and never activate the destination automatically. Keep the route Commit/Cancel row readable at 110% text.

### Current Feed V — contextual Field Briefing

**Status:** Complete in `0.3.0-alpha.251` through phase-aware help and a directly navigable topic rail.

> Reopen Field Briefing at the topic matching the live contract, road, battle, recovery, or finale decision. Turn every visible topic into a mouse, keyboard, and controller action; distinguish viewed from untouched topics without claiming skipped pages were read; preserve first-run sequencing and deterministic state.

### Current Feed W — pause order return

**Status:** Complete in `0.3.0-alpha.252` through distinct Resume Here and Go to Order actions.

> Preserve exact pre-pause focus through Resume Here, while offering a second phase-labelled action that returns directly to the authoritative contract, route, event, battle, recovery, or feedback control. Keep both actions in one row at 110% text, maintain a closed controller focus graph, and never activate or mutate the destination.

### Current Feed X — settings information hierarchy

**Status:** Complete in `0.3.0-alpha.253` through visible sections and a focus-aware breadcrumb.

> Group the existing Settings actions into Display & Readability, Controls & Feedback, and Runs & Local Data without changing preference behavior. Keep section identity visible as controller focus scrolls, preserve dynamic disabled-action routing, and return the initial view to the first heading at 110% text.

### Current Feed Y — Field Guide chapter launches

**Status:** Complete in `0.3.0-alpha.254` through direct Ashgate and Flooded Veyru actions.

> Let the shared title Field Guide launch either playable chapter without returning to the title action stack. Reuse the existing start and save-replacement paths, restore focus to the exact guide action after cancellation, derive replay wording per regional Charter result, and keep all three footer actions readable at 110% text.

### Current Feed Z — title return receipt

**Status:** Complete in `0.3.0-alpha.255` through saved-versus-discarded title feedback.

> After leaving a live stage, show a temporary title receipt that names whether the exact checkpoint or debrief was saved, whether live changes were discarded while an older Continue checkpoint remains, or whether no checkpoint exists. Derive it from the existing full-state save comparison, clear it on the next launch, and keep the title readable at 110% text without changing persistence behavior.

### Current Feed AA — chassis interaction modes

**Status:** Complete in `0.3.0-alpha.256` through distinct passive inspection and active edit presentation.

> Make an untouched preparation screen describe the selected module as inspection, not an active move. Entering the chassis must switch the heading, status, cursor, focus treatment, and controller copy together; stored-module blockers must remain visible before entry. Preserve direct pointer editing and every authoritative placement rule.

### Current Feed AB — checkpoint toast clearance

**Status:** Complete in `0.3.0-alpha.257` through a reserved collision-safe header slot.

> Keep automatic checkpoint feedback visible and non-modal at 110% text without covering the game title or any contextual Pause label. Shorten the receipt without losing its reason, position it against the live Pause control with a stable reserved maximum, preserve immediate Pause dismissal, and add a route-review overlap regression.

### Current Feed AC — phase-aware chassis review

**Status:** Complete in `0.3.0-alpha.258` through truthful battle and debrief inspection handoffs.

> Make passive chassis guidance name the inspection action available in the current phase. Add a keyboard/controller-accessible final-chassis review to the debrief, keep system selection inside that review, return cancel to its visible action, and preserve every authoritative placement and simulation rule.

### Current Feed AD — debrief first action

**Status:** Complete in `0.3.0-alpha.259` through an inspect-then-feedback result handoff.

> Reset inherited battle scrolling when the debrief opens, keep March Debrief and Inspect Final Chassis visible together at 110% text, and make the current-order and Pause jumps point to chassis review first. After review begins, retarget both to feedback without serializing presentation-only progress.

### Current Feed AE — chassis inspector copy fit

**Status:** Complete in `0.3.0-alpha.260` through bounded phase-labelled inspector copy.

> Replace clipped one-line locked-phase chassis instructions with concise battle, result, and road-state hints that fit the 320-pixel detail column. Give battle and result inspection distinct detail headings, preserve refit terminology, and add deterministic width and semantic assertions.

### Current Feed AF — persistent stage header

**Status:** Complete in `0.3.0-alpha.261` through a fixed title and Pause row above stage evidence.

> Keep the contextual Pause action pointer-accessible while chassis focus scrolls the evidence column. Move the stage header outside the left scroll, preserve complete chassis visibility at 110% text, retire the decorative journey banner on results, and verify refit, battle, and debrief inspection states.

### Current Feed AG — pointer Pause resume context

**Status:** Complete in `0.3.0-alpha.262` through focus-neutral pointer activation.

> Keep the fixed Pause action clickable without allowing it to replace the player's active stage focus. Verify pointer-opened Pause retains the exact Resume Here target, while Go to Order still selects the authoritative required action and controller/keyboard pause shortcuts remain unchanged.

### Current Feed AH — playtest build identity

**Status:** Complete in `0.3.0-alpha.263` through one shared title and Pause convention.

> Replace redundant `ALPHA · v...alpha...` title wording and the bare Pause version with a consistent Playtest Build label. Preserve the exact authoritative version in both places, retain the two-region scope on the title, and do not imply release readiness.

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
