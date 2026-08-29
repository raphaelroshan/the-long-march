# Guided Tutorial Vertical Slice

## Purpose

The first playable experience should teach The Long March by letting the player command a real fortress through one short, authored journey. It must begin at a clean game menu, establish the setting and win condition, teach module placement and dependencies, teach route and enemy analysis, resolve a readable encounter, repair the resulting damage, and end by handing the player into the normal Ashgate campaign.

The tutorial is not a slideshow, a debug sandbox, or a parallel simplified combat engine. Every completed lesson must use the same module placement, dependency, route, target, damage, intervention, repair, save, focus, and accessibility rules as the main game.

Target first-run duration: **12–18 minutes**. A player who reads slowly should finish within 25 minutes. Returning players may skip the prologue without changing their normal campaign seed or save.

## Product outcome

A new player should leave the tutorial able to answer these questions without opening a manual:

1. What is the walking fortress, and what am I trying to preserve?
2. How do I place, rotate, inspect, and move a module?
3. Why does an engine need fuel adjacency?
4. Why does a weapon need power and ammunition support?
5. How do I compare a route before committing it?
6. How do enemies approach, choose targets, and deal damage?
7. What information should I read before pressing Advance?
8. What does an emergency order change, and why is it limited?
9. How do damage and dependency failures affect other systems?
10. What can be repaired during contact, and what requires a settlement?
11. What constitutes winning an encounter and securing a road?
12. What should I do next when the normal campaign begins?

## Current-state assessment

The current build already contains most required mechanics and presentation:

- a title menu with Guided First Run and Quick Start;
- a seven-card Marchmaster briefing;
- deterministic module placement and dependency inspection;
- fortress-centered bazaars, planning, travel, contact, arrival, and roadside-event views;
- exact enemy target, reason, damage, counter, and dependency-cascade previews;
- emergency orders, automatic workshop repair, settlement services, and recoverable retreat;
- controller, keyboard, pointer, high-contrast, reduced-motion, save, and pause support.

The main gap is pedagogy. The current briefing explains seven topics before interaction, while the first normal Ashgate screen exposes a contract, bazaar, workshop, route map, multiple budgets, and the full campaign structure. The tutorial should replace front-loaded explanation with a sequence of small, real actions.

## Experience principles

### Teach through action

Each lesson has one required action, one visible reason, and one immediate response. Never ask the player to memorize three future systems on one card.

### Keep the fortress present

The fortress remains the visual subject in the muster yard, road, contact, damage inspection, repair stop, and completion screen. A tutorial should strengthen the game's identity rather than feel like a separate settings utility.

### Use real rules

Tutorial placement is validated by normal placement rules. Enemy targeting uses normal target selection. Damage uses the normal encounter engine. Repair uses normal repair commands. The director may choose the scenario and restrict unavailable actions, but it may not silently manufacture a different result.

### Explain cause before consequence

Before the player commits an action, show what it will change. After it resolves, show a short receipt that names what changed and why.

### Allow recovery

An invalid placement, early Advance, or misunderstood intervention should produce a clear correction, not a failed tutorial. The player can reset the current lesson without restarting the prologue.

### Keep production and test language separate

The default game flow should not say `test`, `debug`, `playtest build`, `fixture`, `seed`, `state`, or `feedback report`. Build identity and diagnostic tools remain available in Pause or Settings, but they are not the fantasy presented to a first-time player.

## Complete first-run flow

```text
TITLE MENU
  -> LEARN TO COMMAND
  -> PROLOGUE INTRODUCTION
  -> MUSTER YARD: PLACE ENGINE
  -> MUSTER YARD: ARM THE FORTRESS
  -> FORTRESS INSPECTION
  -> PLAN TRAINING ROAD
  -> TRAVEL PRESENTATION
  -> READ THE CONTACT
  -> ADVANCE AND RESPOND
  -> DAMAGE AND DEPENDENCY
  -> SECURE THE ROAD
  -> RECOVERY STOP
  -> TUTORIAL DEBRIEF
  -> BEGIN ASHGATE JOURNEY / RETURN TO TITLE
```

## Screen 1 — Production title menu

### Goal

Start from a menu that reads as a game, not an internal test launcher.

### Primary actions

1. **Continue** — visible only when a valid campaign or tutorial checkpoint exists.
2. **New Journey** — opens the chapter selection with Ashgate as the recommended first campaign.
3. **Learn to Command** — begins or resumes the guided prologue.

### Secondary actions

- Field Guide
- Settings
- Credits
- Quit

### Presentation changes

- Retain the large title, promise, moving-fortress background, and focused chapter preview.
- Replace `Guided First Run`, `Quick Start`, and `Two Playable Regions · Playtest Build` in the main hierarchy with player-facing language.
- Move build version, local data status, reset tools, and feedback export into Settings or a compact development footer.
- Do not present Ashgate and Veyru as equivalent first choices. Ashgate is `Recommended`; Veyru remains selectable but is labelled `For experienced Marchmasters` until the tutorial is completed.
- Selecting an action updates a visual preview, not a dense list of test assertions.

## Screen 2 — Prologue introduction

### Fiction

**Ashgate Muster Yard.** The roads are closing, and a half-finished walking fortress must be made ready before the convoy can leave.

### Structure

Three short pages, each with one illustration and no more than 45 words:

1. **A moving settlement** — the fortress carries engines, weapons, workshops, crew, and promises in one physical chassis.
2. **A chain of dependencies** — systems work because fuel, power, ammunition, crew, and protection are arranged around them.
3. **Your job is continuity** — choose a road, read what approaches, survive contact, repair what matters, and keep moving.

The final action is **Enter the Muster Yard**. Skip is available from the first page and requires no confirmation when no tutorial progress exists.

## Tutorial scenario — The First Watch

The tutorial is a deterministic, canonical prologue located at Ashgate's muster yard and nearby practice road. It uses a separate tutorial checkpoint and cannot overwrite an active campaign Continue slot.

### Starting fortress

Preinstalled:

- Generator Core
- Coal Cell
- Ammunition Lift
- Crew Quarters
- Field Workshop

Stored for the player:

- Steam Lance Engine
- Repeater Gun

The layout leaves several legal placements, but highlights one recommended placement for each lesson. Completion is based on dependency state, not an exact coordinate, so a valid alternate arrangement is accepted.

### Tutorial resources

- generous mass and power headroom;
- enough fuel for the training road;
- fixed Ashmarks for one repair demonstration;
- one emergency order;
- no contract, specialist, regional closure, or optional market decisions until the tutorial is complete.

### Tutorial opponent

One weakened **Road Raider** and, if needed for the damage lesson, one authored training contact that cannot destroy the fortress. The normal targeting and damage code remains authoritative; the curated chassis and enemy values make the desired teaching result deterministic.

## Lesson 1 — Place the engine

### Player action

Select the stored Steam Lance Engine, enter chassis placement, rotate if desired, and place it orthogonally adjacent to the Coal Cell.

### UI

- Center: large chassis grid and exterior silhouette.
- Left: Hull, Power, Heat, Mass only; other campaign values remain hidden.
- Right: one objective card, `Install the Steam Lance Engine`.
- Valid cells receive a restrained brass ghost footprint.
- Invalid cells explain overlap, bounds, mass, or missing mount requirements in plain language.
- The dependency card updates live from `Offline` to `Ready` and names `Coal Cell adjacent` as the reason.

### Completion condition

An installed engine has a `ready` dependency state and the fortress can depart.

### Teaching receipt

`ENGINE READY · The adjacent Coal Cell feeds movement. If either system is disabled, the fortress may be unable to leave.`

## Lesson 2 — Arm the fortress

### Player action

Place the Repeater Gun on a legal exterior mount where the Ammunition Lift supports it.

### Teaching points

- exterior systems use the fortress's limited outer mounts;
- the gun consumes shared power;
- ammunition adjacency changes its output;
- the player does not manually aim during battle.

### Completion condition

The installed Repeater Gun is operational, supported by the Ammunition Lift, and within the power budget.

### Teaching receipt

`WEAPON READY · The Repeater Gun will fire automatically at valid contacts. Your work is preparation, target analysis, and emergency command.`

## Lesson 3 — Inspect the machine

The player selects the engine, weapon, workshop, and one dependency provider in any order. The tutorial objective tracks inspected roles rather than exact modules.

Each inspection card has four stable lines:

- **Role** — what the system contributes;
- **Depends on** — the direct operating requirement;
- **If lost** — the first downstream failure;
- **Counter** — one legal preparation or repair response.

Completion requires inspecting one movement chain and one weapon chain. Workshop and repair are introduced briefly but used later.

## Lesson 4 — Plan the training road

The dedicated map shows two destinations:

- **Muster Road** — known, low risk, Road Raider, Repeater Gun counter;
- **Ash Channel** — visibly locked until the prologue is complete.

The player must:

1. inspect Muster Road;
2. identify fuel and day cost;
3. identify the known contact and current ready counter;
4. select a doctrine;
5. commit separately.

The route panel uses normal planning UI but removes campaign-only noise. A short knowledge prompt may ask `Which ready system answers the Road Raider?`; the player answers by selecting the highlighted Repeater Gun counter, not through a quiz modal.

## Lesson 5 — Travel

The moving fortress crosses a short Ashgate road. Scenery moves while the fortress remains near the left third, following the existing Frontier-inspired journey staging.

The screen repeats committed fuel and time costs and states:

`CONTACT AHEAD · Arrival is not secured until the road is clear.`

Continue enters contact. Reduced Motion presents the same receipt and final composition without continuous movement.

## Lesson 6 — Read the contact

The contact scene pauses before step one. The player must focus or inspect the Road Raider dossier.

The tutorial highlights these fields in order:

1. **Approach** — how many steps remain;
2. **Seeks** — cargo and exterior systems;
3. **Counter** — Repeater Gun;
4. **Target** — assigned only after arrival;
5. **Why** — the targeting rationale;
6. **Next** — predicted damage and dependency consequences.

The Advance action is enabled throughout, but the first premature use opens a concise reminder rather than silently skipping the lesson. The second use is accepted so the tutorial never traps an impatient player.

## Lesson 7 — Advance and respond

### Beat 1

Advance one step. The raider moves closer and the Repeater Gun fires automatically. The causal report names weapon, ammunition state, and damage.

### Beat 2

Advance to contact. The raider selects a system. The fortress marks the exact target anchor and the dossier names the reason and next hit.

### Emergency order

The player inspects the targeted module and chooses one curated response:

- **Seal Compartment** for a module target; or
- **Shift Power** when the authored state demonstrates increased weapon output.

Only the recommended order is emphasized, but all legal orders remain inspectable. The result receipt explains the redirect, heat change, or output change before another Advance.

## Lesson 8 — Damage and dependencies

The encounter produces one safe, deterministic damage event. The target survives, but its condition or dependent system changes visibly.

The player must:

1. inspect the damaged module;
2. compare durability before and after;
3. read any Ready → Strained or Ready → Offline cascade;
4. identify whether the Field Workshop can repair it during contact.

If automatic workshop repair triggers, the presentation shows it as a distinct response beat: source, amount restored, and why the workshop was operational. If the lesson requires settlement repair, the contact clearly says `Field repair insufficient · restore at the yard`.

## Lesson 9 — Win the encounter

The player advances until the Road Raider is defeated or the six-step road is survived. The tutorial explicitly teaches that victory is not always killing every enemy:

- defeating all contacts early secures the road;
- surviving the full contact timeline may secure a scarred arrival;
- losing movement or hull can force retreat;
- final commitments can end a run.

The arrival tableau reports:

- road outcome;
- Hull change;
- damaged systems;
- fuel/time already spent;
- why the road counts as secured.

## Lesson 10 — Repair and prepare again

The fortress returns to the muster yard for one recovery action.

The player selects the damaged module and uses the real settlement repair preview. The action shows:

- exact Ashmark cost;
- durability before and after;
- service action before and after;
- downstream systems restored by the repair.

The tutorial then contrasts three recovery actions without requiring all of them:

- module repair restores a system;
- hull repair restores fortress integrity;
- refuel restores route capacity;
- refit movement is free at a valid workshop but may change dependencies.

Completion requires repairing the authored damaged system and confirming that its dependency state is restored.

## Tutorial completion

The final screen is an in-world Marchmaster certification, not a test report.

### Summary

- Engine chain: Ready
- Weapon chain: Ready
- Road analyzed: Muster Road
- Contact countered: Road Raider
- System restored: named module
- Core lesson: `Keep movement alive; every other victory depends on it.`

### Actions

1. **Begin the Ashgate Journey** — starts the normal Ashgate campaign with the prepared legal chassis and full campaign resources.
2. **Repeat a Lesson** — opens a compact lesson list without replaying the entire introduction.
3. **Return to Title**.

Completing the tutorial removes Veyru's first-run caution label and marks the Field Guide topics as introduced. Veyru is never mechanically locked, and tutorial completion must not grant numerical campaign power.

## Tutorial UI architecture

### `TutorialDirector`

Owns tutorial progression, not gameplay outcomes.

Responsibilities:

- current lesson ID and objective copy;
- allowed and emphasized controls;
- completion predicates based on authoritative state or command results;
- lesson reset snapshots;
- transitions between standard game views;
- tutorial checkpoint serialization;
- analytics-free local completion marker.

It may observe `module_installed`, `module_inspected`, `route_committed`, `encounter_advanced`, `intervention_used`, `damage_applied`, `repair_completed`, and `arrival_acknowledged`. It may not adjust Hull, damage, durability, resources, enemy targets, or route outcomes directly.

### `TutorialScenario`

A deterministic content definition containing:

- starting modules and stored modules;
- allowed route and enemy schedule;
- tutorial-safe resources;
- expected teaching facts;
- legal recovery target;
- completion handoff.

The core should expose a narrow `start_tutorial_scenario()` initializer or accept validated scenario data. Do not scatter tutorial-specific state mutations through `main.gd`.

### `TutorialObjectiveView`

A compact right-dock component with:

- lesson title;
- one-sentence reason;
- one required action;
- optional `Show me` focus jump;
- `Reset this lesson`;
- `Skip tutorial` in a secondary menu.

It should not cover the module, route, enemy, or repair information the player is being asked to read.

### Callouts

Use anchored callouts sparingly:

- one active callout at a time;
- point to a real control or visual anchor;
- disappear after the action is understood;
- never use color alone;
- remain inside 1280×720 at 110% text;
- use the player's current input labels.

### Persistence

Use a separate tutorial checkpoint, for example `user://the_long_march_tutorial.save`, containing:

- serialized tutorial fortress state;
- tutorial lesson ID;
- completed lesson IDs;
- active lesson reset snapshot;
- build version and save timestamp.

The normal campaign Continue slot remains untouched until **Begin the Ashgate Journey** is confirmed.

## Production UI pass

The tutorial work should include a broader pass that removes the remaining debug-tester character from the default experience.

### Keep

- fixed left value rail;
- centered fortress, map, road, contact, event, and arrival subjects;
- one right-hand context dock;
- explicit previews and receipts;
- visible Pause;
- deterministic causal explanations;
- keyboard, controller, pointer, high contrast, text scaling, and reduced motion.

### Replace or demote

- `Playtest Build` as the primary title identity;
- `Record Playtest Notes` in the normal debrief action hierarchy;
- raw logs, seed language, debug-like counters, and implementation terms;
- long all-purpose scrolling desks;
- tutorial cards that explain actions before the relevant screen exists;
- duplicate labels that repeat the same state in several columns.

### Visual direction

- weathered brass, soot-dark iron, canvas, paper route charts, warm furnace light;
- large illustrated silhouettes and restrained motion rather than dashboard density;
- module states shown with condition, shape, connection, and icon—not only text chips;
- threats shown in the same physical road space as the fortress;
- receipts styled as orders, manifests, repair slips, and after-action reports;
- no copied layouts, iconography, terminology, or assets from Frontier, FTL, or Slay the Spire.

### Copy rules

- one imperative per objective;
- explain `why` before detailed lore;
- use authored system and place names, never internal IDs;
- prefer `Engine offline: no adjacent Coal Cell` over `dependency validation failed`;
- avoid generic phrases such as `make strategic choices`, `manage resources`, or `prepare wisely`;
- every warning names the threatened thing and the legal response;
- every consequence receipt names the changed value or system.

## Required art, audio, and human work

### Art

- final title background and logo treatment;
- one reusable exterior fortress actor with idle, march, brace, damage, and rest poses;
- readable module icons and placement ghosts;
- Ashgate muster yard and training-road layers;
- Road Raider approach/impact/defeat poses;
- repair-yard props and damaged/repaired module states;
- tutorial callout frame, objective card, receipts, and completion seal.

### Audio

- title ambience and restrained menu cues;
- module pick-up, rotate, valid place, invalid place, and dependency-ready cues;
- heavy march loop with reduced-motion-safe behavior;
- enemy warning, weapon fire, impact, repair, arrival, and lesson-complete cues;
- no required voice acting for the first implementation.

### Writing and UX

- final prologue copy edit;
- tutorial objective and receipt pass by one human editor;
- controller-first and mouse-first usability sessions;
- 100%, 110%, and high-contrast visual review;
- comprehension interviews after the run, not only completion telemetry.

## Implementation sequence

### Milestone 1 — Tutorial contract and isolated state

- add validated tutorial scenario data;
- add separate tutorial checkpoint and completion marker;
- add `TutorialDirector` with lesson IDs, predicates, reset, skip, and handoff;
- protect the normal campaign Continue slot;
- add state-level tests for deterministic setup and legal completion.

### Milestone 2 — Production title and introduction

- simplify the main menu hierarchy;
- add Learn to Command and tutorial Continue states;
- move developer/playtest utilities out of the primary flow;
- build the three-page prologue with final copy boundaries;
- verify all input modes and save-replacement confirmations.

### Milestone 3 — Interactive placement lessons

- build the muster-yard tutorial layout;
- add objective view, anchored callouts, valid placement ghosts, and lesson receipts;
- teach engine/fuel and weapon/ammunition/power using normal commands;
- accept any legal dependency-ready arrangement;
- provide per-lesson reset.

### Milestone 4 — Route and contact lessons

- add the two-node training map;
- teach route inspection, counter recognition, doctrine, and Commit;
- reuse travel and contact views with tutorial objective hooks;
- teach approach, target, why, next damage, automatic weapons, and one emergency order.

### Milestone 5 — Damage, victory, and recovery

- author the deterministic safe damage result;
- present dependency cascade and workshop response;
- complete arrival and victory teaching;
- teach one settlement repair and restored dependency;
- build the certification/handoff screen.

### Milestone 6 — Production polish and playtest

- replace remaining tutorial placeholders with reviewed assets;
- add audio cues and motion tuning;
- remove debug/test language from the default path;
- run the complete automated matrix;
- conduct at least five first-time human sessions before expanding tutorial content.

## Automated full-flow test

Add `tests/test_guided_tutorial.gd`. It must drive visible controls and normal command paths rather than mutating core values to skip lessons.

### Required coverage

1. A clean launch focuses **Learn to Command** or the recommended first-run action.
2. Introduction pages do not mutate fortress or campaign state.
3. Skip returns safely to title or begins the documented default campaign path.
4. Invalid engine placement is rejected with a player-facing reason.
5. A legal engine placement satisfies the fuel dependency and advances the lesson.
6. A legal exterior weapon placement satisfies power and ammunition requirements.
7. Inspecting engine and weapon chains completes the inspection lesson.
8. Route inspection does not commit resources.
9. Route Commit spends the displayed fuel/time exactly once.
10. Travel must appear before contact.
11. Enemy analysis shows approach, target preference, counter, and later target reason.
12. Advance uses the normal encounter command and automatic weapon response.
13. The selected emergency order produces its exact previewed result.
14. Damage changes the named module and any predicted dependency state.
15. Victory produces an arrival receipt before recovery.
16. Repair spends the shown cost/action and restores the expected durability/dependency.
17. Tutorial completion does not alter campaign progression rewards.
18. Begin Ashgate creates the normal campaign at its opening decision with a legal chassis.
19. Save/Continue restores placement, contact, recovery, and completion checkpoints.
20. Lesson reset restores only the current tutorial snapshot.
21. Pointer, keyboard, and both controller layouts reach identical required actions.
22. High contrast, 110% text, and reduced motion retain all required information.
23. No tutorial screen exposes internal IDs, debug actions, or raw state language.

## Human full-flow test

Recruit at least five players who have not read the design documents. Do not coach unless they are blocked for two minutes.

Record:

- time to first valid engine placement;
- number and reason of invalid placements;
- whether the player can explain the fuel and ammunition chains;
- whether they inspect the route before Commit;
- whether they can identify the Raider's counter and intended target;
- whether they understand that weapons fire automatically;
- whether they predict the next damage correctly;
- whether they understand the one-order limit;
- whether they can repair the correct system without prompting;
- whether they can state why the encounter was won;
- whether the Ashgate handoff feels like continuation rather than a reset;
- any screen described as a menu, form, test panel, or debug screen.

### Exit gates

- 4/5 players complete the tutorial without facilitator action.
- 5/5 can explain the engine/fuel relationship.
- 4/5 can explain weapon/ammunition support and automatic fire.
- 4/5 identify one enemy counter before the hit lands.
- 4/5 repair the intended system and can name what the repair restored.
- No required control is clipped at 1280×720 with 110% text.
- No player mistakes a preview for a committed action.
- No player describes the primary flow as a debug tool or test harness.

## Explicit non-goals

- teaching every module, enemy, doctrine, region, event, or specialist;
- a voiced cinematic campaign introduction;
- a separate tutorial-only combat engine;
- exact-cell placement puzzles with only one accepted solution;
- rewards that make tutorial completion mechanically mandatory;
- analytics, account login, or automatic feedback upload;
- hiding exact rules in favor of atmosphere;
- finalizing all campaign art before the tutorial flow is proven.

## First implementation task

Build Milestone 1 and the first half of Milestone 2: introduce the isolated tutorial scenario and checkpoint, add **Learn to Command** to the production title hierarchy, and open the three-page prologue into a muster-yard scene with the first objective visible. Do not begin combat animation or final art until a player can launch, leave, resume, skip, and reset the tutorial without affecting the normal campaign save.
