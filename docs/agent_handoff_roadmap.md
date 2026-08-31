# The Long Road — GPT-Agent Handoff Roadmap

**Project repository:** The Long March
**Game identity:** The Long March, a moving-fortress strategy roguelite
**Current code baseline:** `0.3.0-alpha.330`
**Current playable slices:** Ashgate Lowlands from Ashgate Depot to Meridian Pass; Flooded Veyru from Lantern Quay to the Dry Archive
**Engine:** Godot 4.x, GDScript-first
**Target:** Premium single-player desktop strategy game
**Development posture:** Agent-first, deterministic, public source with owner-controlled alpha merges
**Current merged baseline:** `0.3.0-alpha.330`, preserving the complete causal journey while carrying the same fortress actor from the prologue into play, giving each implemented threat family a distinct approach warning and explicit risk if ignored, representing every bazaar station through a place-specific attendant, foreshadowing the committed destination during travel, distinguishing successful from blocked refit actions by sound, aligning impact audio with the visible impact beat, placing Mara and Iven inside the decisions they materially change, retaining the chosen specialist through later route planning, verifying Iven's branch through a complete player-facing run, distinguishing cost-free route browsing from selection, restating exact route costs beside the selected node before Commit, naming the counter the current fortress can actually use during contact, converting that readiness into a clear next-response posture, stating the exact automatic damage or impact buffer projected for the next beat, downgrading positional counters that do not affect the current target from ready to available, keeping all four emergency orders visible in a compact command grid, moving focus to target inspection when contact first assigns a target, exporting local contact-comprehension counts with tester feedback, rendering those counts plus the ordered contact trail in generated observer sheets, producing a local five-session cohort review that keeps the human gate explicit, asking testers to explain the run's cause plus one concrete replay change, preserving every written answer verbatim in cohort review order, and pairing those words with structured system and surviving-threat facts from the authoritative run state.
**Next build target:** Run consented, uncoached private-alpha sessions and make evidence-led comprehension, pacing, accessibility, and balance fixes. Do not add another region until observed failures justify the scope.
**Visual layout contract:** Keep values in a stable left rail, the fortress/map in the center stage, and one selected subject in the right dock according to [`design/fortress_visual_modes.md`](../design/fortress_visual_modes.md)

> **Core promise:** Build a moving fortress that is simultaneously a vehicle, settlement, workshop, refuge, and weapon. Every journey should make the player decide what the fortress is willing to carry, protect, expose, repair, or leave behind.

This document is the current handoff contract for GPT development agents. It supersedes the original prototype-first feeding sequence in `docs/agent_feeding_guide.md`; those prompts remain useful as historical context but must not be issued as if their systems are still unimplemented.

---

## 1. Current implementation baseline

The current code proves two isolated five-encounter journeys: Ashgate Lowlands and Flooded Veyru. The player configures a 6×4 fortress chassis with two exterior mounts, accepts or declines a regional contract, selects routes and travel doctrines, resolves automatic battles, uses explicit interventions, recovers mid-run, refits the fortress, and reaches a distinct final contact and debrief in each chapter.

The implemented slice includes the following capabilities:

| Area | Current behavior |
|---|---|
| Fortress construction | Shape-aware module placement, rotation where supported, overlap checks, grid bounds, exterior mount limits, removal, and dependency reporting. |
| Operating systems | Power, heat, mass, fuel, hull, condition, route days, crew capacity, and trust are visible and mechanically connected. |
| Dependencies | Fuel-to-engine, generator-to-power, ammunition-to-weapon, crew-to-workshop, signal-to-forecast, and parts-to-repair relationships are evaluated explicitly. |
| Threats | Ashgate implements Road Raiders, Climbers, Burrowers, Storm Fronts, and the Siege Beast; Veyru adds Flood Surge and the Civic Guardian through the same combat engine. |
| Battle | Automatic step-based encounters expose target selection, arrival/contact, response, damage, retreat, interventions, repair, and causal reporting. |
| Interventions | Shift Power, Seal Compartment, Vent Heat, and Cut Loose Cargo are explicit commands with visible trade-offs. |
| Route map | Ashgate Lowlands and Flooded Veyru have separate authored graphs with known, forecast, and unscouted information, visible regional pressure, route costs, and guaranteed recovery paths. |
| Settlements | Ashgate Depot, Morrowline Camp, Lantern Quay, and Evacuation Camp expose chapter-specific contracts, services, refit, fuel, and recovery decisions. |
| Character | Iven Pell changes forecasting and route safety; Mara Flint changes workshop recovery and a later route consequence. Other specialists remain designed extension points. |
| Recovery | Non-final defeats retreat to a valid regional anchor with explicit time, money, pressure, and limping-state costs. Meridian Pass and the Dry Archive are declared final commitments. |
| Persistence | Versioned saves, backup recovery, incompatible-save handling, isolated profiles, local playtest notes, and explicit Continue/New Run behavior exist. |
| Presentation | Ashgate Depot and Lantern Quay now open as fortress-centered bazaars with six stable stations. Plan Journey has a full-frame readiness/map/dossier layout, and route commitment enters a mandatory side-on moving-fortress road screen with exact cost receipts before combat. The UI also shows modules, dependencies, threat forecasts, encounter progress, services, and debrief information. |
| Packaging | Local and CI verification includes Godot tests, policy/content checks, Windows/macOS export scripts, packaged smoke coverage, offline boundaries, input, scaling, pause, save path, and teardown checks. |

The implemented journeys are deliberately narrow and isolated. Cross-region consequences, a complete cargo economy, a broad faction simulation, a full character-campaign layer, final audio, final animation, and storefront adapters are not yet complete merely because they appear in the design package.

The current vertical slice is presentation depth rather than campaign breadth. The starting-settlement bazaar, full-frame route planner, focused workshop mode, atomic route-commit boundary, mandatory side-on road bridge, animated fortress contact, arrival receipt, roadside event tableau, canonical First Watch tutorial, shared fortress silhouette, recovery tableaux, place-specific choices, terminal Debrief, and private-alpha evidence workflow are implemented in PR #41. The tutorial has an isolated checkpoint, three-page prologue, action-led placement and dependency lessons, a deterministic road contact using the normal combat rules, damage and repair teaching, lesson reset/replay, and a certification handoff into Ashgate. The remaining first-run work is human validation, bespoke art/audio, and revisions driven by observed confusion rather than additional explanatory copy.

---

## 2. The spirit of The Long Road

The Long Road should feel like **a difficult convoy-management puzzle expressed through a physical machine**. The player should not be arranging abstract cards and then watching a detached combat screen. They should look at the fortress and see why an engine is safe, why a weapon is starved, why a signal mast is exposed, why a workshop is indispensable, and why carrying one more human or cargo obligation changes the route.

The central player sensation is:

> **“I can see what this fortress depends on, I understand what the road will ask of it, and I am choosing which weakness to carry.”**

The following principles are binding unless the human owner explicitly changes them.

### 2.1 The fortress is a moving place

Every important resource should have a physical home. Fuel belongs near engines but may create fire risk. A workshop needs parts, crew, and access. A signal mast improves knowledge but announces presence. Refuge berths provide human capacity but compete with cargo and movement efficiency.

### 2.2 Modules are doctrines, not loot tiers

A module or equipment offer must change a layout, dependency, route, or operating posture. Do not add rarity ladders, duplicate grinding, or flat upgrades whose only purpose is to make an old module obsolete.

### 2.3 The road is a sequence of commitments

A route choice should expose cost, information, pressure, and likely threat before commitment. The player may accept uncertainty, but uncertainty must be legible. A shortcut can be dangerous; it must not be unknowable.

### 2.4 Damage should create a new problem, not erase the run

A damaged engine, signal mast, workshop, or cargo hold should create a changed journey. Non-final defeat should generally retreat, cost time or money, and produce a limping state. Hard failure belongs to an authored final commitment or an unmistakably warned condition.

### 2.5 Characters are operational pressures

A specialist is not a portrait and a dialogue tree attached to a passive bonus. A character must change a facility, route, contract, intervention, refuge obligation, or resource priority. Their personal belief should make a practical disagreement legible.

### 2.6 Events are disturbances in the same machine

An event must occur at a facility, road, settlement, contract, route, or crew relationship. It should ask what the player will protect or expose. Lore without a spatial, operational, social, or route consequence is optional flavor and should not interrupt the core loop.

### 2.7 Information is a resource, not a promise of certainty

Signals, rumors, scouts, Iven, route visibility, and contracts should improve decision quality without making the map deterministic. Forecasts must tell the player what is known, what is suspected, and what remains hidden.

### 2.8 Readability beats spectacle

A visible `BURROWER → BOILER HEART` route and a clear dependency explanation are more valuable than a large effect. Effects, sound, animation, and screen shake must never obscure the causal chain or change simulation timing.

### 2.9 Solo fairness comes first

The game is designed for one player with pause and inspection. There must be enough time to read a threat, understand a dependency, and choose an intervention. Do not balance around simultaneous multiplayer attention or require memorizing hidden interactions.

### 2.10 Do not turn the journey into a spreadsheet

Keep the number of strong budgets small. Power, heat, mass, condition, fuel, crew capacity, and trust are meaningful because they connect to physical decisions. Do not add currencies merely to support progression screens.

---

## 3. Architecture contract for agents

The repository currently separates design intent, content data, authoritative fortress state, presentation, support utilities, and verification. New agents must preserve this separation.

| Layer | Current location | Responsibility |
|---|---|---|
| Product intent | `design/design_prompt.md` | Defines the game identity, tone, target, and non-goals. |
| Mechanical framework | `design/gameplay_framework.md`, `design/fortress_facilities_and_mechanics.md` | Defines dependencies, budgets, threat questions, and physical design constraints. |
| Regional design | `design/ashgate_lowlands_alpha.md`, `design/map_regions_and_settlements.md` | Defines authored graphs, visibility, pressure, settlements, and future regions. |
| Campaign design | `design/characters_factions_and_campaign.md` | Defines specialists, factions, obligations, arcs, and future endings. |
| Human-readable events | `content/content_manifest.json` and the design documents | Defines narrative purpose, choices, requirements, effects, and consequences. |
| Machine-readable content | `content/content_manifest.json`, `content/gameplay_framework.json` | Stable IDs and validation-facing definitions. |
| Authoritative state | `src/core/fortress_state.gd` | Owns modules, dependencies, resources, routes, combat, settlement actions, events, persistence, and outcomes. |
| Presentation | `src/ui/app.gd`, `src/ui/main.gd`, `src/ui/campaign_map.gd`, `src/ui/combat_panel.gd` | Displays state, gathers input, and emits commands. It must not own rules. |
| Local support | `src/support/playtest_journal.gd` | Stores explicitly requested local playtest notes without network upload. |
| Verification | `tests/`, `tools/`, `scripts/verify.sh`, `.github/workflows/` | Protects deterministic behavior, content integrity, packaging, and release discipline. |

### 3.1 Authoritative command boundary

Every state-changing action must be explicit and return a structured result:

```text
ok: bool
reason: stable machine-readable failure ID
message: player-facing explanation
state_changes: compact structured summary when useful
```

Existing and expected command families include:

```text
place_module
remove_module
rotate_module
set_power_priority
select_route
commit_route
select_doctrine
start_encounter
advance_encounter
use_intervention
repair_module
repair_hull
refuel
salvage
trade
accept_contract
decline_contract
recruit_specialist
assign_specialist
resolve_event
choose_event_option
save_run
load_run
```

UI code may request these commands and display their results. It must not directly adjust hull, fuel, power, heat, trust, route closure, threat damage, or event flags.

### 3.2 Deterministic seed contract

All meaningful randomness must derive from a run seed and stable named streams. A visual effect, label refresh, or UI inspection must not alter a battle result. Recommended stream names include:

```text
route_visibility
route_pressure
pack_offer
encounter_schedule
threat_targeting
intervention_variance
event_occurrence
salvage_outcome
presentation_only
```

If a random stream changes, update the decision log and golden replay fixtures. Never use dictionary iteration order or an unscoped global random call for a gameplay decision.

### 3.3 Save contract

New persistent fields require a default for older saves, malformed-value validation, a migration test, a future-version rejection test, and a decision-log entry if semantics change. Prefer derived values over duplicated values. Never reinterpret an old save as a different route, fortress, specialist, or contract.

---

## 4. UX roadmap

The current UX already supports a functional journey. The next work should improve comprehension and reduce friction before adding major campaign breadth.

### 4.1 Title and onboarding

The title screen should make the current build’s scope explicit: **Ashgate Lowlands test journey**, not a promise of the full five-region campaign. It should offer:

| Action | Purpose |
|---|---|
| Guided First Run | Explains chassis, dependency, route, battle, recovery, and debrief decisions in short steps. |
| Quick Start | Enters the authored test journey with a known prepared fortress for fast comparison. |
| Continue | Loads only a validated compatible checkpoint and explains why it is unavailable otherwise. |
| Field Guide | Explains the five most important decisions without requiring a separate wiki. |
| Settings | Controls scaling, audio, reduced motion, contrast, input, and local save behavior. |

Onboarding should teach one relationship at a time: engine/fuel, weapon/ammunition, workshop/parts/crew, signals/forecast, then route pressure. Do not display every future facility at once.

### 4.2 Fortress preparation

The preparation screen must answer these questions above the fold:

1. What is the fortress trying to do on this journey?
2. Which modules are operational, strained, disabled, or dependent on a vulnerable neighbor?
3. What route and threat are next?
4. What will this placement make easier or harder?
5. What can be repaired, sold, refitted, staffed, or sacrificed before departure?

The 6×4 chassis remains the primary decision surface. The inspector should show footprint, mass, power, heat, fuel impact, dependencies, operating state, preferred placement, and one concrete trade-off. A valid placement should be quick; an invalid placement should say exactly why it fails.

### 4.3 Map and route selection

The route map should expose a layered information model:

```text
Known      exact encounter, cost, and immediate risk
Forecast   threat family and pressure, but not all timing or target detail
Unscouted  broad hazard and uncertainty, with at least one safe planning clue
```

A route card should state travel days, fuel expectation, closure pressure, likely threat, contract relevance, settlement access, and whether a retreat or recovery node follows. Before commit, show the practical consequence of the route. After commit, do not let the player pretend it was hidden.

### 4.4 Battle and inspection

The combat panel should lead with the causal question, not raw statistics:

```text
CURRENT PRESSURE
Threat: Burrower
Likely target: Boiler Heart
Why: lower-hull route is exposed
Visible answers: armor the lower hull, protect the engine, use Seal Compartment
Risk if ignored: slower movement and higher fuel demand
```

Every encounter step should make the following visible without requiring raw logs:

- Threat route and arrival/contact state.
- Current target and target reason.
- Next-hit estimate and applied damage.
- Module state and dependency changes.
- Available intervention and its cost.
- Whether the player is approaching retreat, recovery, or final commitment.

Pause must freeze simulation and presentation together. Speed changes presentation pacing only. Manual stepping must resolve exactly one authoritative step.

### 4.5 Settlement services

Services should be presented as a practical receipt, not a shop carousel. Each service needs a cost, restored system, remaining recovery budget, and consequence.

```text
REPAIR WORKSHOP
Cost: 8 Ashmarks and one service action
Restores: 2 Workshop condition
Why it matters: restores repair output and protects the next refit
Trade-off: leaves only one service action for fuel or hull
```

The player should be able to compare at least two reasonable recovery paths after damage. Avoid service menus where the correct answer is always “buy everything.”

### 4.6 Events and meetings

An event card should fit into the existing journey rather than replacing it. It should show location, participants, immediate question, choices, requirements, visible effect, and what the choice may change later.

A good event card has this form:

```text
THE WORKSHOP CAN WAIT
The repair crew can restore the engine mount or brace the refugee berth before nightfall.

[Repair engine mount]
Cost: 1 workshop action
Visible result: movement remains reliable; the berth stays strained.

[Brace the berth]
Cost: 1 workshop action
Visible result: shelter capacity improves; the engine enters the next road with a warning.

[Leave both]
No cost now; the next storm or retreat will expose the unresolved weakness.
```

Never hide a major cost in flavor text. Decline or defer should be legal when the event is optional, and the player should understand what is lost.

### 4.7 Debrief and replay

A result screen should explain the journey as a chain of causes:

```text
Route: Soot Orchard → Broken Relay → Morrowline → Signal Causeway → Meridian Pass
Doctrine: Protect Crew
Key success: signal forecast exposed the climber route
Key failure: damaged Boiler Heart increased fuel demand on the final road
Recovery used: 2 service actions
Replay experiment: try Lower Ash Road with a lower-hull brace and one fewer cargo module
```

Do not reduce the run to a single score. A replay goal should emerge from the actual state and not from generic advice.

---

## 5. Content expansion framework

New content must be added as a complete teaching slice. The minimum unit of expansion is not “one object”; it is:

```text
player question
→ content definition
→ visible counter
→ visible trade-off
→ authored teaching situation
→ deterministic test
→ save/replay coverage
→ UI explanation
→ balance review
```

### 5.1 New facilities and modules

When adding a module, the agent must define:

| Field | Requirement |
|---|---|
| Stable ID | `snake_case`; never casually rename after merge. |
| Physical role | What practical problem it solves. |
| Shape and mounts | Footprint, rotation support, interior/exterior rule. |
| Operating budgets | Power output/draw, heat, mass, fuel, crew, or condition effects. |
| Dependencies | At least one explicit dependency if appropriate. |
| Vulnerability | One readable threat or failure mode. |
| Counterplay | At least two layout, route, intervention, or staffing answers. |
| Recovery | How it is repaired, bypassed, sold, refitted, or abandoned. |
| Presentation | Icon, silhouette, state labels, inspector copy, and board status. |
| Tests | Definition, placement, dependency, damage, recovery, replay, save, and UI tests. |

Recommended next facility family:

1. **Water Condenser:** reduces supply drain and opens arid routes, but creates heat and maintenance pressure.
2. **Firebreak Bulkhead:** contains area damage but consumes valuable internal space and slows crew access.
3. **Salvage Crane:** improves recovery and heavy-object manipulation but occupies an exposed exterior mount.
4. **Refuge Berth:** enables rescue and trust contracts but adds human capacity and route obligations.

Implement only one or two in a slice. The purpose is to create a new layout question, not to fill a catalogue.

### 5.2 New crew specialists

A specialist requires:

```text
stable ID
primary facility
specific mechanical benefit
personal pressure or belief
recruitment condition
space/crew requirement
one event or contract hook
one visible downside or opportunity cost
```

Recommended order:

| Specialist | Primary question |
|---|---|
| Mara Flint | Do we repair efficiently, or preserve materials for people and cargo? |
| Sela Vonn | Do we maintain schedule and heat risk, or slow down for reliability? |
| Tomas Reed | What is a contract worth when the cargo hold is also a refuge? |
| Dr. Nera Quill | Who receives scarce supplies when crew and civilians both need care? |
| Orris Vale | Do we trust the engine reading, or spend resources before failure is visible? |

The next specialist should enter through a practical event or settlement choice, not a character menu.

### 5.3 New threats and doctrines

New threats should be introduced in pairs with their counters. Every threat needs a forecast vocabulary, route behavior, target policy, arrival/contact state, damage type, and recovery consequence.

Potential future threat families:

| Threat | Teaches | Visible counters |
|---|---|---|
| Ash Swarm | Small threats can overload attention and vents. | Suppression, sealed compartments, route speed. |
| Bridgebreaker | Cargo and mass create structural exposure. | Lighter load, brace, alternate route, sacrifice cargo. |
| Signal Hunter | Information systems can become targets. | Silent travel, redundant signals, decoy broadcasts. |
| Ember Drifter | Heat and weather interact over time. | Venting, condenser, slower posture, firebreak. |
| Chain Harrier | One dependency failure can propagate. | Redundancy, priority shift, compartment sealing. |
| Refuge Snatcher | Human obligations change what “safe” means. | Escort, berth protection, trust, route choice. |

Add one threat first, then a teaching encounter that isolates it, then a composition encounter that combines it with an existing question. Do not add six threats to one battle.

### 5.4 New routes and regions

A new region needs more than a different background. It must have:

- A different physical travel problem.
- A different facility or resource pressure.
- A different settlement pattern.
- A route graph with at least two viable approaches.
- One guaranteed recovery path.
- One local contract or meeting.
- One isolated teaching encounter.
- One combination encounter.
- One final commitment with clear stakes.

Recommended regional sequence after Ashgate:

| Region | Identity | New pressure |
|---|---|---|
| Flooded Veyru | Waterlogged roads, ferry choices, rescue capacity. | Water, refuge, and route timing. |
| The Glass Steppe | Long visibility, exposed approaches, scarce shade. | Heat, signal exposure, and fuel. |
| Hallowmere | Dense settlements and competing obligations. | Trust, contracts, and crew capacity. |
| The Red Narrows | Tight passes and difficult turning. | Mass, exterior mounts, and retreat. |
| The Crownless Reach | Political fragmentation and disputed safe roads. | Faction alignment and route legitimacy. |

Do not build a five-region map before at least two regions have independently proven distinct fortress decisions.

### 5.5 Events, occurrences, and random meetings

The authored event library should be implemented gradually through these event bands:

| Band | Frequency | Purpose |
|---|---:|---|
| Anchor | Authored | Establish a region, character, contract, or final consequence. |
| Operational | Common | Change one facility, resource, assignment, or route decision. |
| Forecast | Before travel or battle | Improve information while preserving uncertainty. |
| Meeting | Optional | Introduce a person, offer, recruit, refuge, or obligation. |
| Recovery | After damage | Turn repair into a meaningful priority conflict. |
| Rare | Seeded low frequency | Offer a strange opportunity without removing all counters. |
| Regional | Between runs | Reflect what the fortress changed beyond its hull. |

A future occurrence scheduler should use:

```text
run seed
+ occurrence pool version
+ region ID
+ phase index
+ route history
+ prior event IDs
+ player command sequence
```

It should filter hard requirements first, then choose from the eligible pool using a named random stream. It must enforce cooldowns, repeat policies, one primary event per phase, bounded history, valid choices, and save-safe state. Random events must never silently destroy the only forward route or remove the only visible counter to the next encounter.

### 5.6 Factions and regional developments

Factions should initially appear as competing practical pressures rather than reputation bars. Each faction needs a service, a demand, a warning, a cost, and a consequence visible on the map or fortress.

Potential groups include:

- **The Road Wardens:** preserve travel corridors and demand reliable contracts.
- **The Ash Choir:** spreads warnings through signal networks and dislikes secrecy.
- **The Silt Houses:** control ferries and supplies in Flooded Veyru.
- **The Free Carters:** offer speed and salvage but resist political promises.
- **The Crownless Companies:** protect settlements selectively and demand proof of value.
- **The Lantern Refuge:** moves civilians between safe rooms and routes.

Do not implement six faction reputation meters at once. Start with one regional faction, one visible trust variable, one contract, one betrayal or refusal, and one route consequence.

---

## 6. Revised milestone roadmap

### Long Road 0 — Baseline stabilization

**Objective:** Keep the current Ashgate journey reproducible and easy for agents to modify.

Required work includes documenting the current state schema, adding golden journey fixtures, ensuring every route/doctrine combination has a readable outcome, tracking non-fatal ObjectDB or teardown warnings, and keeping the local and packaged verification scripts aligned.

**Exit gate:** A fresh clone can run the full verification script, complete a five-encounter journey, save/load at each checkpoint, and reproduce the same result from the same command sequence.

### Long Road 1 — Fortress comprehension pass

**Objective:** Make module dependencies, route costs, and battle causes understandable without a wiki.

Add the preparation dependency inspector, route comparison cards, battle target rationale, next-hit preview, service receipts, and a debrief replay experiment. Do not add a large new content roster in this milestone.

**Exit gate:** Five new testers can explain the purpose of the engine, weapon, signal, and workshop modules after one guided run; they can identify at least one valid counter before a threat lands.

### Long Road 2 — One new facility family

**Objective:** Add Water Condenser plus either Firebreak Bulkhead or Salvage Crane.

Create a design card, content definition, dependency rules, placement rules, one isolated teaching encounter, one combination encounter, one recovery event, and a complete test matrix.

**Exit gate:** The new facility produces at least two viable layouts and does not dominate all existing choices.

### Long Road 3 — One new specialist and one event chain

**Objective:** Add Mara Flint or Sela Vonn through a three-step authored chain.

The chain should include a meeting, a practical choice, a facility or route consequence, a later callback, decline behavior, active-event save/load, and a causal debrief line.

**Exit gate:** The character changes a real operational decision and is understandable without a dialogue encyclopedia.

### Long Road 4 — Occurrence framework

**Objective:** Implement a bounded seeded scheduler for operational events and meetings.

Start with three operational events, one optional meeting, one rare occurrence, cooldowns, eligibility predicates, one primary event per phase, deterministic replay, and an event history panel. Avoid unrestricted procedural storytelling.

**Exit gate:** Multiple seeds produce variation while every tested seed retains a visible counter, valid save state, and understandable outcome.

### Long Road 5 — Flooded Veyru chapter

**Status:** Complete in `0.3.0-alpha.234`.

**Objective:** Add the first new region with a distinct physical identity.

Implement one authored map graph, one settlement, one new pressure, four or five encounters, one contract, one recovery route, and a final commitment. Reuse the fortress simulation; do not build a second combat engine.

**Exit gate:** Ashgate and Veyru require visibly different fortress designs and route decisions, and both remain playable as isolated chapters.

### Long Road 6 — Regional consequences

**Status:** Complete for the first bounded development in `0.3.0-alpha.235`.

**Objective:** Connect one completed journey to one regional development.

A settlement, route, or faction should change because of a previous contract, rescue, warning, or abandonment. Show the cause in the map and report. Keep the state small and migration-safe.

**Exit gate:** A tester can explain how a prior decision changed the next regional option without consulting hidden variables.

### Long Road 7 — Campaign structure and replay

**Status:** First bounded two-chapter shell complete in `0.3.0-alpha.236`; broader campaign structure remains future work.

**Objective:** Add a small campaign layer over at least two proven regions.

Use route history, contracts, regional developments, specialist arcs, and bounded unlocks. Prefer new choices, facilities, relationships, and information patterns over permanent numerical power.

**Exit gate:** The campaign makes individual journeys more meaningful rather than disposable, and a completed run offers a concrete reason to replay.

### Long Road 8 — Private alpha hardening

**Status:** In progress; the previous private-alpha hardening work plus the starting-settlement bazaar, full-frame route planner, focused workshop mode, mandatory road presentation, animated fortress-centered contact view, arrival/retreat receipt, Frontier-inspired roadside event tableau, reduced-motion behavior, last-secured-location travel semantics, automated First Watch tutorial, dedicated terminal Debrief, shared stateful fortress silhouette, staged attack replay, dedicated field recovery, three event-specific commitment tableaux, and the local five-session evidence workflow are complete through `0.3.0-alpha.279`.

**Objective:** Prepare a human-playtestable private alpha.

Complete clean reinstall/upgrade behavior, artifact identity, save migration, controller/scaling/accessibility validation, crash-safe close, offline boundaries, readable final art priorities, audio feedback, and structured playtest analysis.

**Exit gate:** The owner approves the private alpha scope explicitly. A Windows executable alone is not sufficient evidence of commercial readiness.

---

## 7. Testing framework

Every feature must be tested at the smallest applicable level and then through the full journey.

| Test layer | Requirement |
|---|---|
| State/unit | Placement, shape, rotation, budget, dependency, targeting, damage, repair, service, and command rejection. |
| Deterministic replay | Same seed and command sequence produce the same canonical state and result. |
| Content validation | Stable IDs, references, shapes, mounts, effect operations, route links, event requirements, and manifest parity. |
| Scenario matrix | Commander/doctrine/route/module layout/contract/intervention combinations reveal dominant or impossible choices. |
| Save/migration | Fresh save, older save, malformed save, future version, backup recovery, active event, active battle, recovery, and result checkpoints. |
| UI smoke | Title, guided run, quick start, preparation, map, battle, settlement, recovery, debrief, continue, replay, and field guide. |
| Input/accessibility | Mouse, keyboard, controller, remapping, scaling, reduced motion, high contrast, color-safe status, pause, and manual step. |
| Visual | Normal 1280×720, scaled window, narrow window if supported, preparation, map, battle, service receipt, event, and debrief. |
| Packaging | Windows/macOS export, clean launch, offline operation, isolated save path, close, stale artifact prevention, and reinstall/upgrade. |
| Review | Player question, counter visibility, trade-off clarity, solo fairness, narrative restraint, and no authority leak. |

### 7.1 Required tests for new content

For every new module, threat, specialist, route, settlement, event, faction, or region, add:

1. Stable definition loading.
2. Valid activation or placement.
3. At least one invalid or blocked case.
4. The intended counter interaction.
5. The intended weakness or cost.
6. Deterministic same-seed replay.
7. Save/load behavior if the content can be active.
8. UI purpose and state visibility.
9. A scenario or route inclusion test.
10. A balance comparison against the nearest existing option.

### 7.2 Golden journey fixtures

Fixtures should record:

```text
seed
starting chassis
module placement commands
contract choice
route commits
doctrine choices
interventions
service actions
recruitment/assignment commands
event choices
expected encounter sequence
expected retreat/recovery behavior
expected final result
canonical summary hash
```

If combat math changes intentionally, update the fixture and decision log in the same change. If only UI copy changes, the authoritative fixture must not change.

---

## 8. Agent operating protocol

The human owner should send one narrow vertical slice at a time. “Build the campaign” is not an acceptable task.

### Required agent sequence

1. Read `AGENTS.md`, `design/design_prompt.md`, this roadmap, the relevant design card, and `docs/decision_log.md`.
2. Inspect the current source, data, tests, and manifest before editing.
3. State the player-facing question in one paragraph.
4. Identify the authoritative state owner and command boundary.
5. Write the design decision and explicit non-goals.
6. Implement the smallest reversible slice.
7. Add deterministic tests before visual polish.
8. Run focused tests.
9. Run `bash scripts/verify.sh` and all applicable validators.
10. Capture the relevant screen states when UI or content visibility changes.
11. Inspect the diff for generated files, accidental assets, save changes, and authority leaks.
12. Report intent, files, verification, risks, and one next task.

### Current recommended agent feeds

#### Feed A — Fortress comprehension

```text
Starting from the current Ashgate Lowlands implementation, improve one dependency or route decision’s presentation without changing its simulation math. Read the current source and tests first. Add a visible inspector or causal explanation, preserve the command boundary, add UI/state assertions, run the full verification script, and capture the affected 1280x720 state. Do not add new content.
```

#### Feed B — Water Condenser

```text
Implement Water Condenser as one complete content slice. Add its stable definition, shape and placement constraints, heat/supply dependency, one visible vulnerability, two counters, one teaching encounter, recovery behavior, save/replay tests, content validation, UI inspector copy, and visual capture. Do not add a generic utility module or a new region in the same change.
```

#### Feed C — Mara Flint event chain

```text
Implement Mara Flint through one three-event authored chain: meeting, repair-versus-refuge choice, and later consequence. Use explicit typed commands and stable IDs. Add decline, scarcity, active-event save/load, deterministic replay, UI event-card smoke, and a causal debrief line. Do not create a dialogue-only reputation system.
```

#### Feed D — Bounded occurrence scheduler

**Status:** Complete in `0.3.0-alpha.233`.

```text
Implement a seeded occurrence scheduler with one primary event per phase, hard eligibility filters, cooldowns, repeat policy, bounded history, named random stream, and save-safe active state. Start with three operational events and one optional meeting. Preserve at least one visible counter for every tested seed. Do not add procedural prose generation or an unbounded event graph.
```

#### Feed E — Flooded Veyru

**Status:** Complete in `0.3.0-alpha.234`.

```text
Implement Flooded Veyru as an isolated authored chapter using the existing fortress state and map contracts. Add one new pressure, one settlement, two viable route branches, one contract, a guaranteed recovery path, an isolated teaching encounter, a combination encounter, and a final commitment. Add deterministic route, save, UI, and balance tests. Do not build the full five-region campaign.
```

#### Feed F — Regional consequence

**Status:** Complete in `0.3.0-alpha.235` through Public Archive Signal.

```text
Connect one completed Ashgate or Flooded Veyru decision to one visible regional development. Persist one small migration-safe consequence, show its cause on the map and in the debrief, and make it change a later option rather than grant a flat permanent stat bonus. Do not build the full campaign layer in the same change.
```

### Response format required from every agent

```text
Intent:
Player-facing question and why this slice matters.

Plan:
Authoritative owner, data shape, UI path, and non-goals.

Changes:
Files changed and behavior added.

Verification:
Focused commands, full verification command, visual states, and exact result.

Risks:
Known balance, UX, persistence, packaging, or maintainability risks.

Next task:
One bounded follow-up, not a broad feature list.
```

---

## 9. Release and private-alpha discipline

The source repository is public by owner decision. Playtest executables, storefront claims, credentials, and promoted releases remain human-controlled until the owner approves a broader test release.

Before commit, the agent must run:

```bash
cd /path/to/the-long-march
bash scripts/verify.sh
python3 -m json.tool content/content_manifest.json
python3 -m json.tool content/gameplay_framework.json
python3 tools/validate_content.py --manifest content/content_manifest.json
python3 tools/validate_gameplay_framework.py --data content/gameplay_framework.json
python3 tools/policy_check.py --repo .
git diff --check
```

When relevant, also run the packaged smoke, offline-boundary, input/scaling, and save-recovery checks documented in `docs/setup.md` and `docs/internal_test_release.md`.

Only create an immutable annotated prerelease tag after:

- Local focused and full tests pass.
- Visual states have been inspected.
- Main CI passes on Ubuntu and Windows.
- Packaging produces the current artifact, not a stale executable.
- Save, offline, input, pause, close, and recovery behavior are verified.
- Release notes state what is implemented, what is procedural, what remains placeholder, and that the build is private/internal.

Do not claim Steam or Epic availability merely because an executable was exported. Do not add credentials, analytics, multiplayer, monetization, or platform SDKs before the core journey and private playtest evidence justify them.

---

## 10. Definition of a successful future build

A successful Long Road build lets a new player configure a fortress, understand its most important dependency, compare two routes, forecast one threat, watch a battle with trustworthy pause and inspection, recover from damage, and finish with a debrief that suggests a concrete replay experiment.

A successful content addition introduces one new practical question and preserves the old questions’ readability. A successful event makes the fortress’s human and mechanical pressures collide in a visible place. A successful region changes what the fortress must carry or protect without requiring a new game.

A successful GPT-agent change is small enough for another agent to inspect, deterministic enough to replay, persistent enough to save safely, visible enough to explain, and bounded enough that its non-goals are obvious.

> **Long-term standard:** Keep the road dangerous, the fortress legible, the people consequential, and every sacrifice understandable before the player makes it.

---

## Repository references

- [`README.md`](../README.md) — current run instructions and implemented journey scope.
- [`design/functional_prototype_run.md`](../design/functional_prototype_run.md) — authoritative five-encounter functional slice.
- [`design/ashgate_lowlands_alpha.md`](../design/ashgate_lowlands_alpha.md) — Ashgate graph, pressure, contract, threats, and recovery contract.
- [`design/fortress_facilities_and_mechanics.md`](../design/fortress_facilities_and_mechanics.md) — facility dependencies, budgets, staffing, and future modules.
- [`design/map_regions_and_settlements.md`](../design/map_regions_and_settlements.md) — future regional map and settlement framework.
- [`design/characters_factions_and_campaign.md`](../design/characters_factions_and_campaign.md) — future specialists, factions, arcs, and campaign pressures.
- [`docs/agent_feeding_guide.md`](agent_feeding_guide.md) — short-form prompts for feeding bounded tasks to agents.
- [`docs/decision_log.md`](decision_log.md) — historical implementation decisions and UX rationale.
- [`docs/setup.md`](setup.md) — local validation and packaging instructions.

---

**Document owner:** Manus AI
**Review posture:** Update this roadmap whenever a milestone becomes implemented, deferred, or invalidated by playtest evidence.

> **Final reminder to agents:** Do not confuse a detailed design package with implemented code. Inspect the current source, manifest, tests, and release notes before claiming that a system exists.

---

## Appendix A — Long-road content candidates

The event and occurrence library should be treated as a reservoir, not a checklist. The following candidates are ordered by implementation value rather than narrative importance.

### A.1 Ashgate operational incidents

| ID | Situation | Decision | Primary consequence |
|---|---|---|---|
| `boiler_heartbeat` | Orris hears a second rhythm in the Boiler Heart. | Slow and inspect, or keep schedule. | Fuel/heat safety versus contract timing. |
| `lift_chain_sings` | The Ammunition Lift vibrates under load. | Brace the lift, shift weapons, or risk one road. | Ammunition reliability versus spatial flexibility. |
| `the_last_dry_room` | Refugees and spare parts both need the only dry compartment. | Store parts, shelter people, or divide the room. | Repair capacity versus trust/refuge capacity. |
| `crane_in_the_reeds` | A salvage crane can recover a generator casing from flooded ground. | Stop for salvage, send crew, or leave it. | Mass and heat opportunity versus pressure and time. |
| `the_unmarked_valve` | A valve reduces heat but vents a visible plume. | Vent now, travel cool, or remain hidden. | Heat safety versus route exposure. |
| `winter_screws` | A crate of fasteners fits the old chassis but not the new brace. | Modify the crate, preserve it, or trade it. | Immediate repair versus future module flexibility. |
| `a_floor_that_moves` | The chassis flexes when the fortress turns. | Remove a heavy module, reinforce, or accept slower turns. | Mass, hull, and route access. |
| `the_quartermasters_tally` | Cargo records contain a surplus no one remembers loading. | Claim it, investigate it, or return it. | Supplies now versus faction trust and future contract. |

### A.2 Road meetings

| ID | Visitor | Offer | Hidden pressure made visible |
|---|---|---|---|
| `cartographer_without_ink` | A mapmaker with no ink asks for a place in the signal room. | Reveal a route or gain a temporary navigator. | Information requires interior space and trust. |
| `two_children_and_a_lantern` | Two children insist a supposedly closed road is still passable. | Listen, dismiss, or send a scout. | Local knowledge versus time and forecast confidence. |
| `the_bridge_keepers_daughter` | A keeper offers a safe crossing if the fortress carries a sealed parcel. | Accept, inspect, or refuse. | Route safety versus unknown cargo and contract obligation. |
| `the_man_who_sells_silence` | A stranger offers a quiet route for one public warning withheld. | Buy silence, broadcast, or bargain. | Immediate safety versus future settlement trust. |
| `the_old_crew_list` | A survivor recognizes a specialist’s name on a missing convoy list. | Share the list, hide it, or investigate. | Character arc information versus morale and schedule. |
| `the_miller_with_a_broken_wheel` | A miller offers grain if the fortress lends its workshop. | Repair the cart, take the grain, or continue. | Supply versus workshop condition and time. |
| `the_silent_recruit` | A capable stranger refuses to speak but repairs a jammed mount. | Recruit, test, or release. | Crew capacity versus uncertain loyalty. |
| `the_ferry_of_names` | A ferryman records every passenger before crossing. | Give names, use a false manifest, or take the long route. | Trust, secrecy, and route closure. |

### A.3 Character development beats

| Character | Beat | Operational change |
|---|---|---|
| `mara_flint` | **The Useful Waste** — she refuses to discard a damaged module because she can rebuild its core. | Salvage improves, but the Workshop consumes more time during repairs. |
| `mara_flint` | **The Empty Bench** — civilians use the Workshop as shelter. | Refuge capacity rises while repair actions become slower until a new space is found. |
| `iven_pell` | **The Public Signal** — Iven wants to warn settlements even if the fortress becomes easier to locate. | Forecast and trust improve; route risk rises. |
| `iven_pell` | **The Unanswered Bell** — a warning reaches no one. | Iven requests a relay detour that costs time but may open a safer route. |
| `sela_vonn` | **One More Day** — Sela pushes to meet a contract before a road closes. | Schedule improves; heat and condition risk rise. |
| `tomas_reed` | **The Cargo That Breathes** — a contract item is revealed to be a living obligation. | Cargo space becomes refuge space or trust becomes a debt. |
| `nera_quill` | **The Triage Ledger** — Nera refuses to spend medical stores on a machine. | Crew recovery improves; one damaged facility remains strained. |
| `orris_vale` | **The Gauge Under the Cloth** — Orris hid a failing engine reading. | Immediate engine reliability improves if confronted; trust in Orris changes. |

### A.4 Regional developments

| Development | Trigger | Visible consequence |
|---|---|---|
| `ashgate_warning_network` | Broadcast two warnings and protect one relay. | Future forecast nodes become clearer; Signal Hunter pressure increases. |
| `morrowline_open_workshop` | Fulfill the parts guard and share salvage. | One repair service improves; rival caravans arrive earlier. |
| `flooded_veyru_refuge_corridor` | Rescue workers and carry refuge berths through the lowlands. | A safer route opens; cargo capacity is reduced on the next chapter. |
| `red_wheel_broken_toll` | Break the toll bridge and return seized coin. | Free Carters trust the fortress; Road Wardens demand a new contract. |
| `the_lantern_route` | Preserve three refuge signals. | Civilians appear as optional passengers; route information improves. |
| `the_quiet_road` | Repeatedly choose silence over public warnings. | Lower immediate pursuit; fewer settlement offers and less forecast help. |
| `winter_storehouses` | Invest in supply instead of a weapon pack. | Long routes become safer; early encounters are harder. |
| `the_missing_manifest` | Hide or expose the unclaimed cargo ledger. | Opens a faction arc and changes which settlements recognize the fortress. |

### A.5 Future authored scenario hooks

1. **The Water That Remembers:** A flooded route contains an intact condenser, but recovering it requires leaving a refuge convoy behind the main fortress for one encounter.
2. **The Bridge of Three Contracts:** Three settlements each claim the same crossing. The fortress can honor only one promise before closure pressure makes the other two hostile.
3. **The Furnace Choir:** A settlement uses synchronized signal lamps to move through ash storms. The fortress must choose between sharing its signal coil and protecting its own route forecast.
4. **The Passenger in the Cargo Hold:** A hidden passenger knows why the Siege Beast is following the fortress but occupies the only space that can carry spare fuel.
5. **The Road That Is Not on the Map:** A silent route avoids combat but damages the chassis each day. A fast fortress may survive it; a refuge fortress may not.
6. **The Last Workshop at Hallowmere:** The only repair facility serves an enemy-aligned settlement. Use it, sabotage it, or repair it for everyone.
7. **The Crownless Vote:** A regional council asks the fortress to endorse a road authority before opening a safe route. The decision changes who can recruit specialists.
8. **The Empty Fortress:** The player finds an abandoned moving keep whose modules are intact but whose log records a sequence of impossible route choices.
9. **The Lantern Child’s Map:** A child’s route map is accurate only when the fortress carries a refuge berth. Without it, the map leads to a dead end.
10. **The Day the Road Stops:** A final chapter forces the moving fortress to become a stationary defense. Every module built for movement becomes a different kind of liability.

These candidates should be implemented as isolated, testable slices. Their purpose is to make the moving fortress feel like a place with memory and obligations while keeping every consequence visible in the chassis, the map, the route, or the next battle.

---

## Appendix B — Content authoring checklist

Before asking an agent to implement a content object, provide a card containing:

```text
ID:
Display name:
Content type:
Player question:
Where it occurs:
What it changes:
Visible counter:
Visible cost:
Failure or weakness:
Eligibility:
Repeat/cooldown policy:
Seed stream:
Save fields:
UI surface:
Teaching scenario:
Focused tests:
Full verification command:
Explicit non-goals:
```

If any field is unknown, the content is not ready for implementation. A clever narrative premise is not enough; the agent must know what state changes, who owns the rule, how the player sees it, and how the behavior will be tested.

---

## Appendix C — Decision records future agents should update

Update `docs/decision_log.md` when a change affects:

- The order of movement, combat, repair, or event resolution.
- The meaning of a route, closure band, contract, retreat, or final commitment.
- The fields persisted in saves or local playtest notes.
- The definition of a specialist’s benefit or personal pressure.
- The relationship between map visibility and signal/forecast systems.
- The choice between a new module, event, facility, or faction variable.
- The boundary between authored content and seeded occurrence selection.
- Platform behavior, save paths, package identity, or offline operation.

The decision record should state the rejected alternatives and why the chosen option better preserves the moving-fortress identity.

---

## Appendix D — Do-not-build list for the next agent

Do not implement any of the following without an explicit owner decision and a preceding design review:

- A full five-region campaign map before Flooded Veyru is playable as an isolated chapter.
- A global faction reputation system with many hidden values.
- A procedural narrative generator or unbounded event graph.
- A conventional equipment rarity or duplicate-grind economy.
- Individual hunger, sleep, morale, or injury simulation for every crew member.
- Manual wiring of every power connection.
- Fully destructible physics for the fortress.
- Multiplayer or co-op balance.
- Steam/Epic SDK integration, achievements, cloud saves, or monetization.
- A second independent combat engine for a special region.
- UI replacement that hides the chassis or moves the decision surface into menus.
- New content without a teaching scenario, counter matrix, save/replay coverage, and visible causal report.

The Long Road should grow by making the moving fortress more legible, more consequential, and more emotionally inhabited—not by accumulating unrelated systems.

---

## Appendix E — First three recommended implementation tasks

### Task 1: Dependency comprehension card

**Status:** Complete.

Improve one existing module inspector so it names the module’s direct dependency, current state, next likely failure, and one legal counter. Add one UI regression and one state-preservation test. This task is the best immediate UX investment because it strengthens every future module.

### Task 2: Water Condenser teaching slice

**Status:** Complete in `0.3.0-alpha.231`.

Add Water Condenser to the Ashgate or a small isolated test scenario. It should reduce supply drain, add heat, require maintenance, and open one route option. Pair it with one weather or arid-road threat. Test a cool/light layout and a heavy/safe layout rather than declaring one correct answer.

### Task 3: Mara Flint recovery chain

**Status:** Complete in `0.3.0-alpha.232`.

Add Mara through an event at Morrowline or a route-side workshop. Her choices should make the player decide between repair efficiency, refuge capacity, and salvage. End the chain with a later report that names the consequence of the first decision. This provides the first bridge from mechanical event to character arc without requiring a campaign overhaul.

> If these three tasks are completed successfully, The Long Road will have a stronger UX foundation, one new physical system, and one human-scale content chain—exactly the right base for a larger occurrence scheduler and Flooded Veyru.

---

**End of handoff roadmap.**

References are internal repository documents listed in Section 10; no external source or copied game content is required for implementation.

[1]: ../README.md
[2]: ../design/functional_prototype_run.md
[3]: ../design/ashgate_lowlands_alpha.md
[4]: ../design/fortress_facilities_and_mechanics.md
[5]: ../design/map_regions_and_settlements.md
[6]: ../design/characters_factions_and_campaign.md
[7]: agent_feeding_guide.md
[8]: decision_log.md
[9]: setup.md

## References

[1] [The Long March README](../README.md)
[2] [Functional Prototype Run](../design/functional_prototype_run.md)
[3] [Ashgate Lowlands Alpha Chapter](../design/ashgate_lowlands_alpha.md)
[4] [Fortress Facilities and Interacting Mechanics](../design/fortress_facilities_and_mechanics.md)
[5] [Map, Regions, and Settlements](../design/map_regions_and_settlements.md)
[6] [Characters, Factions, and Campaign](../design/characters_factions_and_campaign.md)
[7] [Agent Feeding Guide](agent_feeding_guide.md)
[8] [Decision Log](decision_log.md)
[9] [Setup](setup.md)


---

# 10. Post-PR41 game-quality execution roadmap

PR #41 establishes the first coherent journey shell. It is not the final alpha. The next work must turn that shell into a convincing, replayable moving-fortress experience without expanding into a full continent prematurely.

The project should now optimize for **continuity of place, clarity of commitment, and human comprehension**. The player must feel that the same fortress leaves a settlement, crosses a dangerous road, suffers a specific consequence, reaches a place with its own needs, and returns to the next decision carrying history.

## 10.1 Long Road 9 — Human-proven first thirty minutes

**Objective:** Validate the existing First Watch and quick path with five consented, uncoached human sessions before adding major campaign breadth.

Use `docs/private_alpha_session_sheet.md` and one exact artifact cohort. Test both First Watch and the quick path across the documented input and display combinations. Record only observed behavior. Do not infer comprehension from completion, and do not replace human evidence with automated screenshots.

Triage findings through three questions: did the player know what to do, did they know why it mattered, and did they understand what happened? Fix repeated high-severity confusion before adding more explanatory text. Prioritize unclear current-order handoffs, route commitment, combat target interpretation, recovery choice, settlement service purpose, and final Debrief comprehension.

**Exit gate:** Five session records exist, repeated findings are summarized, the artifact identity is exact, and the owner has approved the disposition of each high-severity issue.

## 10.2 Long Road 10 — Fortress visual identity and continuity

**Objective:** Make the fortress feel like an inhabited moving place across rest, travel, contact, recovery, and Debrief.

**Status:** Long Road 10.1 is complete in `0.3.0-alpha.280`: the visual-state inventory, single-condition family bays, exterior target brackets, and first Ashgate/Veyru hull treatment are implemented. Bespoke authored art and human recognition testing remain open.


The current shared silhouette is the correct structural foundation. Improve it with a restrained authored 2D language: timber, patched plate, canvas, engine housings, signal hardware, cargo restraints, heat stains, dust, rain, and repair marks. Greywatch-like Ashgate should feel industrial and exposed; Flooded Veyru should feel damp, improvised, and crowded by water infrastructure. These are visual and place cues, not new simulation rules.

Create a visual state inventory for idle, selected, strained, disabled, damaged, overheated, breached, repaired, departing, traveling, under contact, retreating, and arrived. Each state must remain understandable at normal play distance and in high-contrast, large-text, and reduced-motion modes.

**Exit gate:** The player can recognize the same fortress in at least four journey chapters, identify the damaged system without reading raw logs, and distinguish Ashgate from Veyru by place treatment rather than only title text.

## 10.3 Long Road 11 — Journey rhythm and transitions

**Objective:** Make travel feel like a sequence of commitments instead of a chain of menus.

**Status:** The complete departure-to-arrival rhythm is implemented through `0.3.0-alpha.310`: departure preserves the origin/destination, accepted or declined promise, exact committed day/fuel/pressure/heat receipt, explicit phase, next contact decision, and focus across save/load. The short road beat now foreshadows each committed destination with its own landmark, contact resolves before arrival, and the destination receives its own arrival tableau.


The target rhythm is:

```text
settlement receipt
→ choose promise or route
→ refit and assign
→ commit exact cost
→ depart
→ short travel beat
→ contact, event, or arrival
→ consequence receipt
→ next commitment
```

Keep transitions short and skippable. The player should always know whether the fortress is preparing, leaving, traveling, under contact, recovering, or arriving. Use movement, weather, sound, and a small amount of contextual text to bridge chapters. Do not add cinematic sequences that delay the decision or remove control.

**Exit gate:** A tester can describe where the fortress is, what it has committed to, and what decision comes next after every transition. Save/load at each transition must restore the same authoritative phase and focus target.

## 10.4 Long Road 12 — Battle cause-and-effect pass

**Objective:** Make automatic encounters read as consequences of the chassis and route plan.

**Status:** The shared contact header and center-stage banner name Forecast, Approach, Target, Wind-up, Impact, Consequence, Response, and Settle without changing authoritative step resolution. All seven implemented threat families have distinct silhouettes, lanes, attack labels, and warning cues through `0.3.0-alpha.308`. Broader human timing and comprehension validation remain open.


Every meaningful encounter should stage forecast, approach, target commitment, attack wind-up, defender response, impact, dependency consequence, and settling beat. The player should see why a Burrower reached the Boiler Heart, why a Storm Front raised heat, or why a Flood Surge threatened the lower chassis. Threats need distinct silhouettes and attack signatures; target lines and effects must remain sparse enough to read.

The existing step-based simulation remains authoritative. Presentation may interpolate or stage around a resolved step, but it may not invent damage, alter target order, consume random streams, or change the replay key. Pause and manual step must freeze or advance simulation and presentation together.

**Exit gate:** Before the first meaningful impact, a tester can name the threat, likely target, visible counter, and risk if ignored. After the impact, they can identify the resulting module, budget, or route consequence.

## 10.5 Long Road 13 — Settlement identity and meaningful services

**Objective:** Make settlements feel like breathing spaces with distinct practical pressures rather than interchangeable service menus.

**Status:** Long Road 13.1 is complete across the four current settlements through `0.3.0-alpha.285`: Ashgate Depot uses black rails and depot signaling, Lantern Quay uses a raised flood dock and hanging lamps, Morrowline uses canvas repair bays and parts wagons, and Evacuation Camp uses waterworks and sealed cases. Their service copy frames existing local priorities without adding currencies or commands.


Ashgate Depot, Morrowline Camp, Lantern Quay, and Evacuation Camp should each have a visual motif, a dominant local problem, a recognizable service priority, and one human-facing consequence. Service receipts must state cost, restored system, remaining options, and trade-off. Players should be able to choose between at least two reasonable recovery paths instead of buying every service.

The next settlement work should deepen one existing location at a time. A place-specific character or event must alter a real operational decision—fuel, parts, refuge, trust, route safety, cargo, or schedule. Do not add a generalized relationship meter or service currency.

**Exit gate:** A player can explain why two settlements feel different and can describe what a service restores and what it leaves exposed.

## 10.6 Long Road 14 — Controlled content breadth

**Objective:** Add variety only after the existing journey is readable and human-proven.

The first expansion should add one facility family, one specialist, one threat family, and one small route branch. Each must be a complete teaching slice:

```text
player question
→ stable data definition
→ physical placement or route rule
→ visible counter
→ visible weakness or cost
→ isolated teaching situation
→ combination situation
→ recovery consequence
→ deterministic tests
→ save/replay coverage
→ visual evidence
```

Recommended order is Water Condenser, one specialist such as Sela Vonn, one threat such as Signal Hunter or Bridgebreaker, and a single new branch in an existing region. Do not add a third region until both current chapters remain independently understandable and replayable.

**Exit gate:** Each addition creates at least two viable fortress or route plans and does not obsolete an existing module, specialist, or intervention.

## 10.7 Long Road 15 — Campaign consequences and replay

**Objective:** Make the broader journey remember what the player protected, abandoned, carried, or promised without making individual chapters disposable.

Use a small number of regional dimensions—such as route access, refuge stability, trust, public knowledge, and pressure—rather than a large reputation matrix. A completed or failed contract should create a visible later condition: a safer route with a cost, a displaced settlement, a new broker, a shortage, a changed refuge obligation, or a new faction offer.

Failure should be a change of road, not a content vacuum. If a player declines a rescue, another group may organize relief; if they prioritize speed, a settlement may become more dependent on the fortress; if they hide a route danger, later travelers may pay the price. The replacement response must be causal, inspectable, and playable.

Endings should compose from accumulated conditions rather than require one exact chain. A mobile relief network, a self-sufficient regional settlement, a militarized corridor, or a commercially prosperous but opaque route can all be coherent outcomes.

**Exit gate:** At least two different decision histories produce distinct but understandable later states, and the player can identify what earlier decision caused the difference.

## 10.8 Long Road 16 — Private-alpha hardening

**Objective:** Package a stable internal build that can survive repeated human observation.

Complete the existing technical matrix for Windows and macOS packaging, offline play, save migration, malformed and future saves, backup recovery, clean reinstall, controller navigation, large text, high contrast, reduced motion, pause, safe close, route transitions, active events, recovery, and terminal Debrief. Add performance checks for the first thirty minutes at supported window sizes. Preserve local-only playtest notes and exact artifact provenance.

**Exit gate:** `bash scripts/verify.sh` and all applicable validators pass; package smoke is clean; the artifact has a manifest, observer brief, known-limitations list, rollback path, and exact source revision; the owner explicitly approves the private-alpha cohort.

## 10.9 Non-negotiable post-PR41 invariants

- `FortressState` remains the authority for modules, dependencies, resources, routes, combat, interventions, events, services, persistence, and outcomes.
- The same seed and command sequence produce the same authoritative result regardless of viewport, input device, speed, pause, text scale, contrast, or motion settings.
- The fortress remains the primary visual subject in preparation, travel, contact, recovery, and Debrief.
- Every route, service, threat, and event exposes its cost, uncertainty, or consequence before commitment when that information is available.
- Partial failure creates a changed but understandable journey whenever the authored contract permits recovery.
- New content introduces a question before it introduces complexity, and every new pressure has a readable counter.
- Automated tests prove deterministic behavior and package safety; they do not claim that humans understood or enjoyed the game.
- The repository may be public source, but the build remains private alpha until explicit owner approval. No storefront-ready or public-release claim is implied by CI success.

## 10.10 Recommended next task

The next evidence task is **Long Road 9: five consented, uncoached private-alpha sessions** using the published cohort and `docs/private_alpha_session_sheet.md`. Record where players hesitate, what they predict before route commitment or impact, what they recall after arrival, and whether the Debrief creates a concrete replay plan. Implement only repeated, high-severity comprehension, pacing, comfort, audio, or balance fixes before adding another region or progression layer.
