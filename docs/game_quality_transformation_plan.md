# The Long Road — Game-Quality Transformation Plan

**Repository:** The Long March
**Game identity:** The Long Road, a moving-fortress crawler
**Current baseline:** `0.3.0-alpha.295`
**Current implemented chapters:** Ashgate Lowlands and Flooded Veyru, each with a five-encounter authored journey
**Target:** Premium single-player desktop strategy game
**Development posture:** Agent-first, deterministic, private alpha, owner-controlled merges

> **Central diagnosis:** The Long Road has enough simulation to prove that a moving fortress can be a game. Its largest remaining gap is not the number of modules, regions, threats, or contracts. The gap is that the player must feel the journey as a sequence of human and mechanical commitments. The fortress needs to look like a place, travel needs to feel like travel, battles need to feel like consequences of the layout, and settlements need to feel like hard-won breathing spaces rather than service menus.

This plan is designed for GPT coding, UX, art, audio, and test agents. It describes how to bring the current technical prototype toward a convincing private alpha without rewriting the deterministic simulation.

---

## 1. Product identity to protect

The Long Road is not a normal roguelite inventory screen mounted on a vehicle. It is not a traditional tower-defense game with a map added afterward. It is a **moving fortress crawler** in which the chassis is both the player’s build and the player’s home.

The player is continually deciding:

```text
What must the fortress carry?
What can it protect?
What can it expose?
Which route can it afford?
Which promise can it keep?
What weakness can survive one more day?
```

The core loop is:

```text
choose a promise or route
→ refit the physical fortress
→ assign priorities and people
→ travel through uncertainty
→ watch an automatic encounter
→ intervene when the causal problem is visible
→ recover, trade, recruit, or sacrifice
→ carry the consequence to the next road
→ reach a final commitment
→ understand the march and try a different answer
```

The quality goal is not to make every screen busy or every journey cinematic. It is to make the player believe that **the same fortress they arranged is the thing that travels, suffers, shelters people, fulfills obligations, and survives**.

### 1.1 Binding design principles

| Principle | Required interpretation |
|---|---|
| The fortress is a place | Engines, weapons, workshops, crew, cargo, refugees, and signals occupy meaningful physical space. |
| Movement is a cost | A powerful static layout is not automatically a successful road layout. Mass, heat, fuel, and damage must alter route choices. |
| The map creates obligations | Routes, contracts, settlements, refugees, and pressure should make the player choose what to keep open. |
| Auto-combat is inspectable | The player chooses the structure and interventions; the simulation explains its target, timing, and outcome. |
| Damage becomes history | A damaged engine, room, specialist, or contract should change the next decision rather than simply reset. |
| Characters are operational | A specialist must change a facility, route, contract, intervention, or recovery decision. |
| Events belong to the machine | Narrative encounters must change a practical state, relationship, route, or obligation. |
| Information is partial | Signals, rumors, contracts, and forecasts improve decisions without removing uncertainty. |
| Progression adds choices | Unlocks should create new layouts, routes, obligations, or counters—not a flat stat treadmill. |
| The player is alone but not helpless | Pause, inspection, prediction, and recovery support a thoughtful solo experience. |
| Tone is humane and practical | The road is melancholy and dangerous, but the game is about keeping people and networks alive, not cruelty for spectacle. |
| Readability beats spectacle | The player should understand an engine dependency before admiring a smoke effect. |

---

## 2. Current technical foundation

The current remote baseline is already a meaningful functional slice. It includes two authored regions, each proving the same underlying moving-fortress loop with different hazards and settlements.

| System | Current state |
|---|---|
| Fortress | 6×4 chassis, two exterior mounts, shape-aware placement, rotation where supported, dependencies, budgets, and damage states. |
| Budgets | Power, heat, mass, fuel, hull, condition, crew capacity, trust, Ashmarks, and time/pressure are connected to practical choices. |
| Facilities | Engines, weapons, workshops, crew rooms, signals, cargo, and related dependency structures are implemented or represented in the data contract. |
| Travel | Authored FTL-like node graphs with current, secured, available, blocked, closed, known, forecast, and unscouted states. |
| Regions | Ashgate Lowlands and Flooded Veyru have separate authored journeys, route branches, settlements, pressure, contracts, and final commitments. |
| Encounters | Automatic step-based combat and hazards with target selection, timing, intervention, damage, retreat, and causal reporting. |
| Threats | Road Raiders, Climbers, Burrowers, Storm Fronts, Siege Beast, Flood Surge, and Civic Guardian use the existing combat model. |
| Specialists | Iven Pell affects forecasting and route safety; Mara Flint affects workshop recovery and later consequences. Other specialists remain extension points. |
| Services | Fuel, repair, refit, salvage, trade, contract, recruit, and recovery decisions at authored settlements. |
| Events | Typed authored events, event history, Workshop Can Wait, Wrong Wall, Mara Venn’s Second Door, Old Drain, and regional Low Mill/Ash Ford consequences. |
| Persistence | Versioned saves, backup recovery, malformed/future-version handling, isolated profiles, local feedback, and checkpoint semantics. |
| Onboarding | First Watch, guided briefing, Quick Start, Field Guide, phase-aware controls, pause, controller support, and accessibility settings. |
| Validation | Headless deterministic tests, content validators, policy checks, visual captures, packaged Windows smoke, offline checks, save recovery, scaling, input, pause, and teardown. |

The game is therefore past “make the systems exist.” It is at the point where the systems must be **composed into a legible emotional journey**.

---

## 3. The game-quality gap

### 3.1 The fortress does not yet feel sufficiently inhabited

The current chassis and module UI can explain a machine, but the player should also sense rooms, work crews, cargo, weather, heat, repairs, and the people depending on the road. The art pass should not add decorative clutter. It should give every important module a visual identity and every damaged state a visible consequence.

### 3.2 Travel does not yet have enough rhythm

The map graph is functional, but a node-to-node transition can still feel like a menu operation. A quality journey needs a short rhythm:

```text
preview road
→ commit promise
→ depart
→ travel beat
→ encounter or meeting
→ arrival/debrief
→ next decision
```

The player should feel that the fortress has left one place and arrived at another. This can be achieved with modest illustrated transitions, route movement, weather, sound, and receipts; it does not require a cinematic sequence.

### 3.3 The battle layer needs stronger cause-and-effect staging

The automatic battle is mechanically inspectable, but the presentation should make approach, target lock, response, impact, damage, dependency loss, retreat, and recovery feel like a chain. A threat should not appear to subtract numbers from a card. It should visibly reach a particular section of the moving fortress and create a new travel problem.

### 3.4 Settlements risk feeling like service menus

Ashgate Depot, Morrowline Camp, Lantern Quay, and Evacuation Camp need distinct identities. Their services should be presented as people and place pressures, not interchangeable buttons. A workshop should sound and look different from a ferry camp or refuge station.

### 3.5 Results need to close the journey emotionally

The result screen must explain not only whether the fortress held, but what it carried, what it promised, who benefited, what was damaged, and which future route or relationship changed. A score alone cannot make a road feel meaningful.

### 3.6 Human validation is still the decisive gate

Automated tests establish deterministic correctness. They do not prove that a first-time player understands why a route is dangerous, whether a settlement choice feels worthwhile, or whether the player wants to protect the people aboard the fortress. Human playtesting must begin before major campaign breadth is added.

---

## 4. Target first-thirty-minute experience

A game-quality private alpha should deliver a coherent first journey, not necessarily a complete continent.

A new player should be able to:

1. Start a guided march or quick run without confusion.
2. Understand that the fortress is a physical chassis, not a card inventory.
3. Place an engine, weapon, workshop, and crew room while seeing the dependency consequences.
4. Choose between two routes whose costs and threats are legible.
5. Accept or decline a contract and understand what promise is being made.
6. Watch a first automatic encounter and identify the threat’s target and counter.
7. Pause, inspect, and use one intervention without feeling rushed or arbitrary.
8. Reach a settlement and choose between at least two meaningful recovery priorities.
9. Carry visible damage, trust, pressure, or a rescued person into the next road.
10. Finish an authored chapter with a debrief that makes the next replay question obvious.

The first thirty minutes should make the player want to say:

> “Next time I will take the other road, move the workshop, and stop trying to protect everything at once.”

---

## 5. Journey flow and UX architecture

### 5.1 Main Menu — “The road is waiting”

The title should communicate the moving-fortress premise immediately. The fortress banner, title, and one-sentence promise should be stronger than technical status text.

Recommended hierarchy:

```text
fortress / road image
The Long Road
Keep a moving fortress alive across a broken continent.
New March
Continue
Learn to Play
Field Guide
Settings
small build/status label
```

The menu should not make New March, Continue, Quick Start, and tutorial modes look like unrelated products. The player should understand which action begins the intended first experience.

**Agent acceptance criteria:**

- A first-time tester identifies the recommended start within five seconds.
- A returning tester understands whether Continue will restore a route, battle, recovery phase, event, or debrief.
- The build label is honest but visually subordinate.
- Focus order works for mouse, keyboard, and controller.

### 5.2 Marchmaster’s Desk — “What are we carrying?”

The Desk should give the journey a human and operational context before the player sees dense controls. It should show:

- Current region and next reachable commitments.
- Fortress condition in plain language.
- Active promises and contracts.
- Available fuel, Ashmarks, materials, trust, and pressure.
- Current specialists and their concerns.
- One recommended question for the next decision.

Do not add a separate management spreadsheet. Use a compact summary that makes the next decision legible.

### 5.3 Chassis preparation — “Build a moving answer”

Preparation should make physical construction feel like arranging a vehicle under real constraints.

The main screen should show:

```text
left/center: fortress chassis
right: selected module or pack
top: current objective and budgets
bottom: primary commit action and concise warnings
```

The inspector for a module should show:

- Physical footprint and orientation.
- Facility role.
- Power, heat, mass, fuel, crew, and condition effects.
- Direct dependencies.
- What happens if the module is strained or disabled.
- Preferred placement.
- One advantage and one risk in the current layout.

A placement preview should highlight both the occupied cells and the dependency chain it changes. Invalid placement should explain a reason such as `requires_adjacent_fuel`, `overlaps_workshop`, `exterior_mount_used`, or `exceeds_mass_limit`.

### 5.4 Map — “Choose what the fortress promises”

The map must make routes feel like commitments rather than buttons.

Every route card should answer:

- Where does the road lead?
- How many travel days and how much fuel are expected?
- What threat or weather is forecast?
- What contract, person, cargo, or settlement is affected?
- What recovery option follows?
- What pressure or closure risk is accepted?

Use the existing visibility model:

```text
Known      exact encounter and practical cost
Forecast   threat family and likely pressure
Unscouted  broad warning plus one planning clue
```

The player may choose uncertainty, but should never be punished by information that the game gave no way to infer.

### 5.5 Travel transition — “The fortress moves”

Add a short, repeatable travel beat:

1. Route commitment receipt.
2. Fortress movement across the route line or a compact illustrated transition.
3. Fuel/time/pressure change.
4. Weather or signal observation.
5. Arrival card naming the next place and immediate question.

The transition should be skippable after the first view and should never create a second simulation authority. It is presentation around already resolved travel state.

### 5.6 Encounter and battle — “Watch the answer under pressure”

Every battle or hazard should have a consistent seven-beat presentation:

```text
forecast
→ approach
→ target lock
→ defender response
→ impact or counter
→ dependency/damage consequence
→ settle and next pressure
```

The player must be able to pause and answer:

- What is approaching?
- What will it hit?
- Why that target?
- What will my layout do about it?
- What can I change now?
- If I do nothing, what fails next?

The first battle of a region should stage this slowly. Later encounters can compress the beats.

### 5.7 Settlement — “Breathing space with a price”

Settlement screens should begin with place identity and immediate need:

```text
Morrowline Camp
The workshops are full, the roads are closing, and three caravans need the same parts.
Your fortress has two service actions before the next route.
```

Then offer services as cards with:

- Exact cost.
- Restored system.
- Remaining service budget.
- Immediate benefit.
- Trade-off.
- What next route it helps or hurts.

Different settlements should have one distinctive reason to visit. Morrowline is repair and guard obligation. Lantern Quay is water, evacuation, and ferry knowledge. Ash Ford is political trust and a defensive identity.

### 5.8 Event and meeting — “The road notices you”

Events should use the same visual language as the map and fortress. Each event card needs:

- Location and participants.
- What the fortress is being asked to carry, repair, reveal, or abandon.
- Two or more valid choices.
- Exact immediate cost.
- Visible immediate result.
- Possible later callback.
- Decline/defer behavior where appropriate.

Avoid long dialogue before the player understands the practical question.

### 5.9 Results — “What did the march mean?”

Results should have three levels:

```text
headline: Decisive / Scarred / Retreated / Failed
journey record: route, contracts, encounters, people, and damage
lesson: the most important causal chain
next experiment: one concrete alternative
```

A result should say, for example:

```text
The convoy reached Meridian Pass.
The Shell Cannon held the Siege Beast, but the exposed Signal Coil failed at Lower Ash Road.
The detour preserved the cargo contract and cost two days of pressure.
Next experiment: protect the signal route or take the lower-hull road with a lighter cargo load.
```

---

## 6. Visual transformation plan

The Long Road’s visual language should be **illustrated industrial fantasy with practical wear**: ash-stained steel, patched canvas, painted convoy marks, timber, brass instruments, rope, lanterns, mud, water, and warm settlement interiors against hostile pale roads.

The visual identity should communicate three things at a glance:

1. The fortress is heavy, physical, and inhabited.
2. The world outside is open, damaged, and uncertain.
3. Every system has a practical job and a visible vulnerability.

### 6.1 Asset priority ladder

#### Tier 1 — fortress readability

- Chassis frame and floor texture.
- Engine, generator, ammunition lift, workshop, crew quarters, cargo, signal, armor, and refuge silhouettes.
- Interior/exterior mounts.
- Fuel, power, heat, mass, and condition indicators.
- Ready, strained, disabled, breached, and abandoned variants.

#### Tier 2 — travel identity

- Ashgate Depot.
- Morrowline Camp.
- Lantern Quay.
- Evacuation Camp.
- Rill Crossing, Soot Orchard, Broken Relay, Red Wheel Toll, Lower Ash Road, Signal Causeway, Meridian Pass, and Dry Archive.
- Road, water, ash, storm, bridge, ferry, and closure treatments.

#### Tier 3 — actors

- Road Raider, Climber, Burrower, Storm Front, Siege Beast, Flood Surge, Civic Guardian.
- Pike, Fire Team, Scout Post, Repair Station, Crossbow Watch, Bell Guard, Shieldwall, and mobile-response units.
- Crew silhouettes for Iven Pell, Mara Flint, and future specialists.

#### Tier 4 — authored content

- Commander insignia.
- Pack cards.
- Contract and faction marks.
- Event illustrations for Workshop Can Wait, Wrong Wall, Mara’s Second Door, Old Drain, and future regional chains.

#### Tier 5 — atmosphere and feedback

- Engine steam.
- Signal flashes.
- Ash wind.
- Water spray.
- Sparks, smoke, lantern flicker, falling debris, torn canvas, repair dust, and route markers.

Do not create final art for every future region before the first two regions have a coherent visual system.

### 6.2 Asset implementation rules

Create an asset registry. Each asset needs:

```text
stable asset ID
role
source/provenance
logical size
state variants
fallback treatment
reduced-motion behavior
color-safe companion shape
```

Board and map geometry should remain data-driven. Art should skin the existing geometry rather than replacing it with incompatible freeform images.

### 6.3 Animation and motion

Motion should reinforce travel and consequence:

| State | Motion |
|---|---|
| Departure | Fortress settles, wheels/track/legs move, route line advances. |
| Travel | Small parallax or route movement; weather changes by region. |
| Threat approach | Enemy enters from a readable route or direction. |
| Target lock | Signal/aim/bracket resolves toward target. |
| Impact | Localized shake and material reaction at affected module or hull section. |
| Dependency loss | Connector dims or breaks; dependent module changes state. |
| Repair | Crew, tools, light, and condition restoration cue. |
| Settlement arrival | Lanterns, people, gates, ferry, workshop, or camp activity. |
| Result | Fortress remains visibly scarred or repaired rather than resetting immediately. |

Respect reduced-motion settings. Do not make travel transitions or combat effects block commands longer than necessary.

### 6.4 Audio identity

A minimal soundscape should distinguish:

- Fortress idle and engine room.
- Departure, travel, and arrival.
- Signal forecast and route closure.
- Module placement and invalid placement.
- Threat approach by family.
- Wind-up, impact, breach, repair, and retreat.
- Settlement room tone by place.
- Contract accepted, promise broken, rescue completed, and final outcome.

The audio system must be presentation-only, pooled, bounded, muteable, and safe under repeated battle ticks.

---

## 7. Flow and architecture implementation

The project already has significant UI behavior. The next work should reduce visual and maintenance risk without a wholesale rewrite.

### 7.1 Recommended presentation components

| Component | Responsibility |
|---|---|
| `TitlePanel` | New March, Continue, Learn, Field Guide, Settings, build status. |
| `DeskPanel` | Current order, commitments, fortress summary, specialist concerns. |
| `ChassisPanel` | Physical fortress editing, module inspector, placement preview. |
| `MapPanel` | Route graph, forecast, closure pressure, route preview, commit/cancel. |
| `TravelTransition` | Presentation-only departure/travel/arrival beat. |
| `EncounterPanel` | Forecast, battle/hazard timeline, target, intervention, impact. |
| `SettlementPanel` | Services, contract, recruit, recovery, receipts. |
| `EventPanel` | Event card, choices, requirements, typed effects, history. |
| `DebriefPanel` | Results, journey record, causal lesson, replay goal. |
| `FieldGuidePanel` | Persistent help and chapter topics. |
| `SettingsPanel` | Display, input, motion, audio, save, and privacy preferences. |
| `FortressRenderer` | Pure rendering and hit-testing over a presentation snapshot. |
| `FeedbackService` | Toasts, cues, sounds, semantic feedback, and non-blocking receipts. |

Extract one component at a time. Preserve existing command handlers and test them at the same boundaries before and after extraction.

### 7.2 Presentation snapshot

Create a read-only presentation snapshot with explicit sections:

```text
title_state
desk_state
fortress_state
map_state
travel_state
encounter_state
settlement_state
event_state
debrief_state
input_state
accessibility_state
```

The snapshot may be derived from authoritative state, but it must not mutate it. This will make visual captures, controller focus, and future art changes safer.

### 7.3 Primary action discipline

Each screen gets one dominant action:

| Screen | Dominant action |
|---|---|
| Title | New March or Continue. |
| Desk | Review current order or enter the next commitment. |
| Chassis | Commit fortress configuration. |
| Map | Commit route. |
| Travel | Continue after arrival. |
| Encounter | Pause/Inspect or resolve the next step. |
| Settlement | Choose a service or depart. |
| Event | Choose a valid option or decline. |
| Debrief | Review next experiment or begin replay. |

Agents must not add a new large button until they identify what it displaces.

---

## 8. Content development framework

Every new content object should answer a practical player question and be taught before it is randomized.

### 8.1 Facility/module slice

Required fields:

```text
stable ID
name and silhouette
physical footprint
interior/exterior rule
operating budgets
dependencies
failure state
at least two counters
recovery behavior
settlement/service interaction
route or contract interaction
inspector copy
teaching encounter
save/replay behavior
tests
```

Recommended next facility families:

1. **Water Condenser:** supply/range benefit, heat and maintenance cost, opens arid or drought routes.
2. **Firebreak Bulkhead:** contains damage, costs space, slows access.
3. **Salvage Crane:** improves recovery, consumes exterior exposure and mass.
4. **Refuge Berth:** expands rescue and shelter choices, competes with cargo.

### 8.2 Specialist slice

A new specialist must have a facility, benefit, personal pressure, recruitment condition, space/capacity requirement, event hook, and visible downside or opportunity cost.

Recommended sequence:

```text
Mara Flint → Sela Vonn → Tomas Reed → Dr. Nera Quill → Orris Vale
```

Do not add a dialogue-only relationship meter. A character arc is successful when a player changes a route, layout, service, contract, or intervention because of that person.

### 8.3 Threat slice

A new threat requires:

- Forecast vocabulary.
- Route/arrival behavior.
- Target policy.
- Attack/wind-up presentation.
- Damage or pressure type.
- At least two visible counters.
- A weak counter or trade-off.
- Recovery consequence.
- Isolated teaching encounter.
- Combination encounter.

Potential future threat families include Bridgebreaker, Signal Hunter, Ember Drifter, Chain Harrier, Ash Swarm, and Refuge Snatcher. Add one, not all six.

### 8.4 Region slice

A new region requires:

- A distinct physical travel problem.
- Two viable route approaches.
- One settlement with a unique identity.
- One contract or local obligation.
- One new hazard or threat pressure.
- One guaranteed recovery path.
- One teaching encounter.
- One combination encounter.
- One final commitment.
- Save, replay, UI, and balance coverage.

Recommended next region: **The Glass Steppe** or a deeper Flooded Veyru chapter, but only after the current Ashgate/Veyru presentation loop has human-playtest evidence.

### 8.5 Event and occurrence slice

Start with authored events, then add bounded seeded selection. Do not begin with a generic narrative generator.

A safe occurrence scheduler uses:

```text
run seed
region ID
phase index
route history
contract history
specialist history
prior event IDs
pool version
named random stream
```

It must filter eligibility before selecting, enforce cooldowns and repeat rules, keep history bounded, guarantee valid choices, preserve save state, and never silently remove the only recovery route.

### 8.6 Factions and regional consequences

Begin with one visible regional consequence rather than a large faction-reputation system. A good first consequence changes a route, settlement service, recruit opportunity, warning network, or recovery option.

Potential groups include Road Wardens, Ash Choir, Silt Houses, Free Carters, Lantern Refuge, and Crownless Companies. Each should be introduced through a practical request before a persistent relationship system is added.

---

## 9. Staged AI execution roadmap

### Phase 0 — Baseline lock

**Objective:** Measure the current demo before changing it.

Tasks:

- Capture title, desk, chassis, map, travel, encounter, settlement, event, and debrief states.
- Record current First Watch and Ashgate/Veyru journey click/scroll/step counts.
- Add a stable local-only capture harness.
- Confirm current logical viewport and supported scaling sizes.
- Record the current deterministic journey fixtures.
- Track non-fatal leaks or teardown warnings separately from test assertions.

**Exit:** Before/after evidence exists for every later UX or visual change.

### Phase 1 — Journey hierarchy

**Status:** Automated L1 gate complete in `0.3.0-alpha.288`: one clean-save app-shell run reaches First Watch, campaign handoff, route commitment, travel, contact, events, Morrowline recovery, final arrival, and Debrief through player-facing controls. Departure and arrival save/resume restore the same surface and focused action. Human comprehension remains optional calibration evidence.

**Objective:** Make the first chapter feel like one journey.

Tasks:

- Make First Watch the canonical first experience.
- Clarify Desk, Chassis, Map, Travel, Encounter, Settlement, and Debrief roles.
- Add one current-order summary per screen.
- Establish one primary action per phase.
- Reduce raw paragraphs into concise summaries with expandable detail.
- Make route commitment and arrival feel distinct.

**Exit:** Five testers can complete the first two commitments without coaching and can explain where they are in the journey.

### Phase 2 — Fortress visual identity

**Status:** The shared code-native silhouette, single-condition module-bay grammar, Ashgate/Veyru place treatment, and responsive three-region presentation contract are complete through `0.3.0-alpha.289`. The complete journey now holds its left status rail, center fortress/map, right action dock, primary focus, high contrast, large text, reduced motion, and alternate controller guidance at 1280×720 and 1600×900. Bespoke production art and human recognition testing remain open.

**Objective:** Make the chassis feel like a physical inhabited machine.

Tasks:

- Build layered chassis rendering.
- Add module silhouettes and consistent state grammar.
- Add ghosted placement and dependency highlighting.
- Add visible crew, workshop, engine, weapon, and cargo treatment.
- Show damage persisting into map, settlement, and Results.

**Exit:** A screenshot of the fortress communicates its operating identity without reading every label.

### Phase 3 — Map and travel game feel

**Status:** The save-safe settlement-to-route-to-departure handoff and complete L3 rhythm pass are complete through `0.3.0-alpha.290`. Commitment now leads through an immediately skippable Departed → Road in Motion → Contact Ahead beat; reduced motion resolves directly to Contact Ahead. Arrival separates applied consequences from the next order, and route planning retains the last committed contract, road, event, or service receipt. Broader route-specific authored motion remains open.

**Objective:** Make routes feel like roads with stakes.

Tasks:

- Improve route cards and preview hierarchy.
- Add departure, travel, and arrival transitions.
- Give each settlement and route archetype distinct visual treatment.
- Show pressure, fuel, days, trust, contract, and recovery consequences compactly.
- Add route-history and commitment receipts.

**Exit:** A tester can describe why they chose a road and what it risked.

### Phase 4 — Encounter game feel

**Status:** The first target-lock, threat-signature, impact, dependency-consequence, and explicit Forecast-to-Settle phase grammar is complete through `0.3.0-alpha.282`; audio cues and broader human timing validation remain open.

**Objective:** Make automatic encounters feel like the fortress is acting and suffering.

Tasks:

- Add staged approach, lock, wind-up, impact, dependency, repair, and retreat cues.
- Give each current threat family an attack signature.
- Improve local board emphasis without hiding the whole fortress.
- Decide whether the first step of a new threat or wave opens paused.
- Add focused audio cues.

**Exit:** A tester can explain the last impact and identify what system it changed.

### Phase 5 — Settlement and event presentation

**Status:** Dedicated Morrowline/Evacuation Camp recovery plus distinct Mara forge-core, Pump Gallery, and Last Dry Room commitments are complete through `0.3.0-alpha.278`; broader authored-event coverage and human memory validation remain open.

**Objective:** Make breathing spaces and obligations memorable.

Tasks:

- Redesign services as place-specific receipts/cards.
- Give Workshop Can Wait, Wrong Wall, Mara’s Second Door, Old Drain, and regional consequences distinct presentation.
- Show practical consequences before confirmation.
- Add one complete new event with art treatment and debrief callback.
- Extract Event and Settlement panels from the UI monolith.

**Exit:** Testers remember a settlement or meeting and can state what it cost them.

### Phase 6 — Debrief and replay

**Status:** The first dedicated terminal Debrief slice is complete in `0.3.0-alpha.272`; human comprehension and replay-intent validation remain open.

**Objective:** Make each completed or failed march teach the next march.

Tasks:

- Build dedicated terminal Debrief.
- Show route timeline, commitments, people carried, contracts, damage, pressure, and final outcome.
- Name the decisive causal chain.
- Generate one state-specific replay experiment.
- Make replay preserve chapter choice while allowing a changed layout/route/doctrine.

**Exit:** Testers can explain their outcome and choose a specific alternative.

### Phase 7 — Human private alpha

**Status:** The local five-session sheet, feedback-export summarizer, privacy boundary, capture matrix, checksummed artifact-cohort manifest, and one-command verifier are complete through `0.3.0-alpha.290`; five consented uncoached sessions and evidence-led fixes require human testers.

**Objective:** Replace assumptions with observed behavior.

Tasks:

- Run at least five uncoached sessions.
- Test First Watch, Ashgate, Flooded Veyru, Continue, recovery, and debrief.
- Observe first action, route comprehension, placement errors, battle predictions, service choices, and replay intent.
- Fix the top three comprehension failures.
- Do not add a region until the current loop is understandable.

**Exit:** Owner approves the first genuine private-alpha candidate.

### Phase 8 — Controlled content expansion

**Objective:** Add breadth without losing the journey.

Tasks:

- One new facility.
- One new specialist chain.
- One new occurrence family.
- One new threat attack style.
- One new region or deeper authored chapter.
- Full deterministic, save, UI, visual, and balance coverage for each slice.

**Exit:** New content creates new journey decisions, not new screens of disconnected options.

### Phase 9 — Packaging and alpha hardening

**Objective:** Make repeated internal testing safe and reproducible.

Tasks:

- Clean install and upgrade.
- Save migration and backup recovery.
- Offline and profile isolation.
- Controller, scaling, remapping, pause, close, and reduced motion.
- Artifact identity and provenance.
- Local feedback bundles and privacy review.
- Honest internal release notes.

**Exit:** A tester can install, play, save, close, resume, complete, and replay without developer assistance.

---

## 10. AI-agent task protocol

Every agent task must be a vertical slice with a player-facing question.

### 10.1 Required prompt format

```text
Task:
Improve one player-visible Long Road flow or feedback problem.

Baseline:
Start from current remote main. Read AGENTS.md, README.md,
design/design_prompt.md, design/functional_prototype_run.md,
docs/agent_handoff_roadmap.md, and the relevant visual notes.

Player question:
What should the player understand or feel after this change?

Authoritative owner:
Which class and command own the rule? What remains presentation-only?

Allowed files:
[List exact files.]

Non-goals:
[List systems, content, platforms, and refactors excluded.]

Acceptance criteria:
1. Visible player result.
2. Blocked or failure case.
3. Deterministic state/replay test.
4. Save/input/accessibility requirement.
5. Visual capture at supported sizes.

Verification:
Run focused tests, bash scripts/verify.sh, and git diff --check.

Report:
Intent, plan, changed files, exact verification, screenshots, risks,
and one bounded next task.
```

### 10.2 First ten recommended tasks

| Order | Task | Explicit non-goal |
|---:|---|---|
| 1 | Add baseline journey capture and local playtest metrics. | No gameplay changes. |
| 2 | Build dedicated terminal Debrief panel. | No new region or faction. |
| 3 | Add current-order summary to Desk, Chassis, Map, and Encounter. | No new budgets. |
| 4 | Extract one UI panel from the main UI script. | No full UI rewrite. |
| 5 | Improve chassis module silhouettes and dependency highlighting. | No new module family. |
| 6 | Add one complete travel departure/arrival presentation beat. | No new route graph. |
| 7 | Add attack wind-up and impact treatment for one existing threat. | No combat math changes. |
| 8 | Improve settlement receipts for Morrowline or Lantern Quay. | No new service currency. |
| 9 | Give Workshop Can Wait or Mara’s Second Door a complete authored presentation slice. | No generic random scheduler. |
| 10 | Run five-human-session First Watch/Ashgate playtest and fix top three issues. | No campaign expansion. |

### 10.3 Review questions

Before merging an AI change, ask:

- Does the player know where the fortress is in the journey?
- Does the map show what is known, forecast, and uncertain?
- Does the chassis show why the module belongs where it is?
- Does the battle show what is about to happen before it happens?
- Does a settlement choice show what it restores and what it costs?
- Does the event change a practical decision?
- Does the result preserve evidence of the actual run?
- Is the primary action unambiguous?
- Can a controller player discover the same path?
- Does the change still work at supported scaling?
- Is the player-facing screen a game state rather than a debug state?
- What human playtest question does this change answer?

---

## 11. Test and evidence gates

### 11.1 Automated requirements

Maintain coverage for:

| Layer | Required checks |
|---|---|
| State | Chassis, placement, dependencies, budgets, travel, threat, damage, recovery, services, events, contracts, and outcomes. |
| Replay | Same seed and commands produce identical canonical state, route, battle, event, and result. |
| Content | Stable IDs, valid references, route links, event requirements/effects, facility shapes, threat counters, and manifest parity. |
| Save | Preparation, map, travel, encounter, paused battle, settlement, recovery, event, debrief, malformed, future version, backup, and migration. |
| UI | Title, tutorial, Desk, chassis, map, travel, encounter, settlement, event, Debrief, Continue, replay, and settings. |
| Input | Mouse, keyboard, controller, focus order, remapping, pause, manual step, and scroll restoration. |
| Accessibility | Reduced motion, high contrast, scaling, audio mute, color-safe state grammar, and readable text at supported sizes. |
| Packaging | Clean launch, offline profile, save path, close, resume, stale artifact prevention, Windows export, and release manifest. |

### 11.2 New-content test contract

Every new facility, specialist, threat, route, settlement, event, or region needs:

1. Stable definition loading.
2. Eligibility or placement validation.
3. At least one invalid/blocked case.
4. Intended counter interaction.
5. Intended weakness or cost.
6. Same-seed replay.
7. Save/load if active or persistent.
8. UI purpose and state visibility.
9. Teaching encounter or authored scenario inclusion.
10. Human playtest question.

### 11.3 Visual evidence

Capture at minimum:

```text
Title or Desk
Chassis before commit
Map route preview
Travel departure/arrival
Encounter before impact
Encounter after impact
Settlement with one action remaining
Active event
Terminal Debrief
```

Record the logical viewport, display scaling, whether the capture is presentation inspection or human evidence, and any known limitations. A screenshot demonstrates visibility, not fun.

### 11.4 Human-playtest metrics

Record locally and only with explicit tester consent:

- Time to first action.
- Time to first placement.
- Number of invalid placements.
- Route comparison time.
- Whether forecast was used.
- First pause and first intervention.
- Battle prediction accuracy.
- Settlement service choice and explanation.
- Event choice and perceived cost.
- Completion/retreat/failure.
- Replay intent and proposed change.
- Screens or controls ignored.

Do not infer emotion from completion alone. Ask what the player thought would happen before and after each commitment.

---

## 12. Definition of game-quality private alpha

The Long Road is ready to move beyond technical pre-alpha when:

1. The first journey has a clear emotional and operational arc.
2. The player understands the fortress as a physical home and machine.
3. Routes communicate cost, information, obligation, and recovery.
4. Travel transitions make the fortress feel like it moves through a world.
5. Combat clearly stages approach, target, response, impact, and consequence.
6. Recovery and settlement choices feel like breathing space with a price.
7. Events create practical dilemmas and callbacks rather than stopping the game for lore.
8. Results explain why the march held, broke, retreated, or changed.
9. The board, map, actors, and damage states are recognizable without raw logs.
10. First Watch can be completed and replayed without developer coaching.
11. At least five human sessions have informed the next polish pass.
12. The deterministic, save, input, accessibility, packaged, offline, and content gates remain green.
13. New content is introduced as teaching slices rather than undigested catalogues.
14. The build’s art and audio are coherent enough that the player believes in the road, even if some assets remain placeholders.

> **The Long Road becomes a game when the player is not merely optimizing a chassis. They are deciding what kind of moving refuge this fortress will be, and then watching the road test that decision.**

---

## 13. Immediate task for the next AI agent

```text
Starting from `0.3.0-alpha.279`, run five consented, uncoached private-alpha
sessions using `docs/private_alpha_session_sheet.md`.

Include First Watch, at least two Ashgate runs, and at least two Flooded Veyru
runs across keyboard/mouse and controller. Generate a Markdown sheet from each
local feedback export, add only direct observations and tester quotes, and group
repeated failures by severity. Implement and verify the three highest repeated
comprehension fixes before adding another region or expanding the item catalog.

This gate requires human participants. Automated agents may prepare builds,
capture states, summarize local exports, and implement the resulting fixes, but
must not fabricate sessions, quotes, emotions, or qualitative conclusions.
```

---

## References

[1] [`README.md`](../README.md) — current Pack the Keep scope, code map, and implemented systems.
[2] [`docs/agent_handoff_roadmap.md`](agent_handoff_roadmap.md) — long-horizon Pack the Keep agent roadmap.
[3] [`docs/agent_feeding_guide.md`](agent_feeding_guide.md) — current staged agent prompts.
[4] [`design/design_prompt.md`](../design/design_prompt.md) — product identity, central promise, and design constraints.
[5] [`design/events_occurrences_bible.md`](../design/events_occurrences_bible.md) — future event and occurrence library.
[6] [`docs/private_alpha_session_sheet.md`](private_alpha_session_sheet.md) — five-session evidence sheet and capture matrix.

This document is an internal implementation plan. It does not claim that the listed visual, audio, UX, or campaign work is already implemented.
