# Journey Presentation Vertical Slice

## Purpose

The next vertical slice should make the fortress feel as though it is crossing a dangerous place rather than moving instantly from a route button to a combat report. The player should plan a journey, understand the commitment, watch the machine travel, see a threat approach the part of the fortress it intends to attack, and then read the exact mechanical consequence.

The useful lessons from games such as *FTL* and *Slay the Spire* are structural: give route choices a dedicated planning surface, make commitment explicit, keep threat intent readable, and make movement between decisions feel consequential. The Long March should retain its own industrial-fantasy visual language and must not reproduce another game's layout, iconography, assets, or terminology.

## Current gap

The current prototype already has the hard part: deterministic routes, forecasts, target selection, interventions, damage, recovery, saves, and two complete chapters. Its presentation compresses three different moments into the Marchmaster's Desk:

1. selecting a node;
2. committing resources and doctrine;
3. entering an encounter whose enemies are represented by cards.

`LongMarchState.begin_campaign_route()` currently pays the route cost, moves the fortress to the destination, and configures the encounter in one command. `CampaignMapView` and `CombatPanel` are useful controls, but both are embedded in the same scrolling command surface. This makes the loop functional without giving departure, travel, contact, and arrival distinct visual identities.

## Target player loop

```text
SETTLEMENT / CURRENT NODE
        |
        v
PLAN JOURNEY
route + posture + doctrine + readiness
        |
        v
COMMIT REVIEW
costs, risks, known threats, recovery warning
        |
        v
MARCH
fortress movement + terrain + travel beats
        |
        +----> ROADSIDE SCENARIO ----> choice consequence ----+
        |                                                     |
        +----> HOSTILE CONTACT -----> step-based encounter ---+
        |                                                     |
        v                                                     v
ARRIVAL / RECOVERY / NEXT NODE <------------------------------+
```

Planning is reversible. Commit is the single authoritative boundary. March animation communicates already-determined state; it never decides combat through frame timing or physics.

## Vertical-slice boundary

The first implementation should prove two contrasting first legs from Ashgate Depot:

| Road | Presentation purpose | Contact |
|---|---|---|
| Rill Crossing | Readable hostile approach on an open ash road | One Road Raider approaches cargo or an exterior mount |
| The Soot Orchard | Environmental travel and a non-combat interruption | Storm Front plus the existing orchard decision |

This is enough to test route planning, commitment, marching, enemy movement, a hazard, a scenario, damage presentation, and arrival. Do not redraw all encounters before this pair feels good.

The slice is complete when a tester can:

1. compare the two roads on a dedicated Plan Journey screen;
2. choose all required orders and understand why Commit is enabled or blocked;
3. commit once and see the exact resource changes;
4. watch or skip a short march without changing the result;
5. see a Raider or storm enter through a distinct visual route;
6. connect the threat's movement to a highlighted fortress target;
7. advance the existing deterministic battle one step at a time;
8. use an intervention and see its visual and mechanical consequence;
9. resolve the orchard scenario without leaving the journey presentation;
10. arrive at the next node and return to planning with a valid checkpoint.

## Screen structure

### 1. Plan Journey

This should be a separate reusable Godot scene, not another section appended to the command-desk scroll.

```text
+-----------------------------------------------------------------------+
| ASHGATE LOWLANDS        DAY 1   FUEL 6   PRESSURE WATCH      [PAUSE]  |
+----------------------+---------------------------+--------------------+
| REGIONAL MAP         | SELECTED ROAD             | MARCH ORDERS       |
|                      | Rill Crossing             | Route        READY |
|   current -> o       | 1 day / 1 fuel            | Posture      READY |
|            / \       | Known: Road Raiders       | Doctrine     READY |
|           o   o      | Cargo is likely target    | Fortress     READY |
|                      |                           |                    |
| inspect/select nodes | counters + recovery note  | [COMMIT JOURNEY]   |
+----------------------+---------------------------+--------------------+
```

The screen has three responsibilities:

- **Map:** shows the current node, reachable roads, secured path, closures, and visibility.
- **Road dossier:** explains the selected route's cost, uncertainty, known pressure, likely contact, and what follows it.
- **March orders:** collects the required choices and reports fortress readiness before Commit.

The first slice requires three deliberate selections:

1. **Road:** one reachable destination.
2. **Travel posture:** Scout, Conserve, or Push.
3. **Battle doctrine:** Protect Cargo, Protect Crew, or Run Hot.

The existing emergency interventions remain reactive during contact. They should not be consumed or mechanically locked during planning. A later slice may let the player mark one as the prepared order for faster access, but preparation must not remove the decision of when or where to use it.

### 2. Commit review

Commit should be one explicit, atomic action. The button remains disabled until the route, posture, doctrine, and fortress readiness are valid. Its final review should show deltas rather than vague warnings:

```text
COMMIT RILL CROSSING
Day 1 -> 2      Fuel 6 -> 5      Pressure 0 -> 1
Posture: Scout  Doctrine: Protect Cargo
Known contact: Road Raider
Likely target: Parts Crate
Recovery after this road: none guaranteed
```

Cancel returns to the unchanged plan. Confirm creates a committed journey snapshot, pays costs once, checkpoints, and transfers to the March view.

### 3. March view

The march should use a wide side-on illustrated diorama. The fortress remains near the left third of the frame while road and scenery move right-to-left. This gives strong motion with a modest asset budget and keeps enemy approach distances readable.

```text
+-----------------------------------------------------------------------+
| RILL CROSSING · 62%       SCOUT       CONTACT: 2 STEPS       [PAUSE] |
+-----------------------------------------------------------------------+
| pale horizon / distant structures / weather layer                    |
|                                                                       |
|   [FORTRESS] ===== road foreground =====>      [RAIDER SILHOUETTE]   |
|    target glow: Parts Crate                   flank approach arrow    |
|                                                                       |
+-----------------------------------------------------------------------+
| CONTACT ORDER  Raider -> Parts Crate  WHY: exposed cargo             |
| [Inspect Chassis] [Interventions]                   [Advance Step]    |
+-----------------------------------------------------------------------+
```

The fortress needs to feel heavy, not fast. A short loop can sell this through alternating leg compression, chassis rise/fall, exhaust, loose canvas, wheel or track secondary motion, and foreground parallax. The camera should mostly remain stable; large shake would weaken legibility.

Recommended travel timing:

- departure beat: 1.0-1.5 seconds;
- uninterrupted road beat: 2-3 seconds;
- contact reveal: 1 second;
- each player-advanced battle beat: 0.8-1.5 seconds;
- arrival beat: 1.0-1.5 seconds.

The player may skip any non-interactive beat. Reduced Motion replaces parallax, camera impulse, and continuous gait with short crossfades and position changes while preserving all labels and causal highlights.

### 4. Contact presentation

Combat remains paused and step-based. Enemy actors move only when the player advances the encounter or commits an intervention. They do not use free-running AI, physics, or real-time collision.

Each threat receives a distinct approach grammar:

| Threat | Visual route | Target relationship |
|---|---|---|
| Road Raider | Enters from the road edge and closes horizontally | Cargo or exterior target receives a line and highlight |
| Climber | Appears low, then arcs toward the upper hull | Signal, mount, or crew anchor is highlighted |
| Burrower | Ground ripple travels beneath the fortress before emergence | Lower-hull, engine, or workshop anchor pulses |
| Storm Front | Weather layer overtakes the entire road | Exposed and sustain systems highlight together |
| Siege Beast | Large frontal silhouette advances slowly | Armor or crew target is shown before the impact |
| Flood Surge | Waterline rises through foreground layers | Lower-hull and cargo exposure are emphasized |
| Civic Guardian | Holds the road and marks a selected obligation | The named cargo/signal/crew target remains visible |

When the core selects a target, presentation draws a labelled intent line from the threat to the corresponding fortress module anchor. On impact, the visual sequence should be:

1. attacker telegraph;
2. defender response or weapon fire;
3. impact at the authoritative target;
4. durability change;
5. dependency cascade, if any;
6. updated next order.

The existing textual cause-and-effect report stays visible. Animation reinforces the report and may not replace target name, reason, expected damage, or dependency change.

### 5. Roadside scenarios

A scenario interrupts the march in the same physical place rather than opening an unrelated full-screen text menu. The march pauses, the fortress idles, and a foreground tableau or illustrated card enters from the right. The choice panel states:

- what was encountered;
- which fortress system or obligation makes each response possible;
- exact known costs;
- uncertain consequences;
- the route state after the choice.

After selection, show the consequence over the same tableau, then the authoritative next action: resume marching, enter contact, or arrive.

## Godot scene architecture

The current `scenes/Main.tscn` can remain the playable-stage root, but the major modes should become separate child scenes with narrow APIs.

```text
Main.tscn / MarchStageController
├── PersistentHeader
├── JourneyPlannerView       scenes/journey/JourneyPlanner.tscn
│   ├── CampaignMapView
│   ├── RouteDossier
│   ├── MarchOrders
│   └── CommitReview
├── MarchView                scenes/journey/MarchView.tscn
│   ├── ParallaxBackdrop
│   ├── RoadLayer
│   ├── FortressActor
│   ├── ThreatLayer
│   ├── ScenarioLayer
│   └── EncounterHUD
├── ChassisView              existing grid/inspector presentation
└── OverlayLayer             pause, briefing, feedback, confirmation
```

Recommended scripts:

| File | Responsibility |
|---|---|
| `src/ui/journey_planner.gd` | Owns draft selections, validation display, focus order, and Commit request. No resource mutation. |
| `src/ui/march_view.gd` | Renders the current travel/contact snapshot and coordinates presentation playback. |
| `src/ui/fortress_actor.gd` | Maps installed modules to side-view anchors and displays gait, damage, target, and dependency states. |
| `src/ui/threat_actor.gd` | Displays one threat from authored visual metadata and applies approach/attack/defeat animations. |
| `src/ui/journey_presentation_director.gd` | Converts structured core events into animation sequences, supports skip/reduced motion, and reports playback completion. |
| `src/ui/scenario_view.gd` | Displays authored event tableau, requirements, choices, and consequences. |

`src/ui/main.gd` should become the coordinator between these views rather than continuing to construct every control and visual directly. Extraction should happen incrementally; rewriting the entire 3,700-line controller in one change would be unnecessarily risky.

## Authoritative state and data

### Draft plan: presentation-owned and reversible

The uncommitted plan does not belong in the save file:

```text
selected_route_id
selected_travel_posture
selected_target_doctrine
selected_power_priority
```

Changing these fields previews costs and outcomes but does not spend resources, advance time, change pressure, or seed an encounter.

### Committed journey: simulation-owned and saved

The core should add a real `travel` phase and a versioned committed snapshot:

```text
journey_segment_id
journey_from_node
journey_destination
journey_route_id
journey_travel_posture
journey_target_doctrine
journey_power_priority
journey_total_beats
journey_beat_index
journey_distance_units
journey_distance_completed
journey_contact_schedule
journey_scenario_schedule
journey_resolved_contacts
journey_visual_context_id
```

Only mechanically meaningful fields belong in `LongMarchState`. Camera position, tween progress, dust particles, current animation frame, and parallax offsets are presentation-only and must not be serialized.

The first implementation may use three travel beats per road:

1. **Depart** — costs and commitment are already recorded.
2. **Road** — scenario or quiet-road beat is resolved.
3. **Contact/Arrival** — encounter begins or the fortress reaches the node.

Saving during an animation restores the most recent completed authoritative beat. It may replay the current visual transition; it must never apply its cost or damage twice.

### Travel posture

Travel posture adds a useful road decision without creating another currency:

| ID | Benefit | Cost | Visual identity |
|---|---|---|---|
| `scout` | Improves one forecast band or reduces surprise pressure | +1 day on eligible roads | Signal pulses, slower gait, searching lights |
| `conserve` | Reduces fuel cost by 1 when the route permits it | Lower weapon opening pressure or +1 contact step | Low exhaust, steady gait, dimmer weapons |
| `push` | Saves 1 day or reduces closure pressure gain | +heat and greater engine exposure | Faster gait, hot exhaust, stronger vibration |

Exact values must be tuned against the existing routes before implementation. Every route must offer at least two reasonable postures; a route may reject one with a visible reason.

### Presentation event contract

Core commands should return structured events alongside their normal result. A minimal event shape is:

```text
event_id          stable event instance ID
event_type        depart, travel, reveal, approach, fire, impact,
                  dependency_change, intervention, defeat, scenario, arrive
source_id         route, threat, module, or event ID
target_id         module, hull, node, or empty
beat_index        authoritative sequence index
before            relevant values before the command
after             relevant values after the command
message           player-facing causal receipt
visual_cue_id     authored presentation lookup only
```

The simulation creates the event ordering. The presentation director chooses durations and effects. Skipping animation consumes no random number and issues no extra simulation command.

## Content additions

Add a validated presentation catalog rather than scattering texture paths through state code:

```text
content/journey_presentation.json
├── biome_visuals
├── route_visuals
├── fortress_visuals
├── threat_visuals
├── scenario_visuals
├── effect_visuals
└── audio_cues
```

Suggested authored fields:

| Object | Required fields |
|---|---|
| Biome | `id`, background layers, palette, road layer, weather layer, ambient cue |
| Route visual | `route_id`, biome, time of day, landmarks, travel speed band |
| Fortress visual | body, front/rear gait layers, exhaust anchors, module-grid transform |
| Threat visual | `threat_id`, silhouette, approach lane, scale, contact anchor, telegraph cue, defeat cue |
| Scenario visual | `event_id`, tableau, foreground props, optional character portrait, ambience |
| Effect visual | `visual_cue_id`, sprite/animation, duration band, reduced-motion fallback |

The validator should reject missing stable IDs, unknown threat/event references, absent reduced-motion fallbacks, and paths outside reviewed asset directories.

## Art and audio inventory

The first visual pass can use authored silhouettes and limited frame animation. It does not need skeletal animation or full character sprites.

### Required for the first slice

- One original side-view fortress body with separate front leg, rear leg, chassis, exhaust, canvas, and damage-overlay layers.
- One 6×4-to-side-view anchor map so installed modules can be highlighted where they physically sit.
- Ashgate sky, distant ruin, roadside midground, and road foreground layers that tile cleanly.
- One Road Raider silhouette with approach, attack, hit, and defeat states.
- One Storm Front overlay with reduced-motion fallback.
- One Soot Orchard scenario tableau.
- Muzzle flash, impact spark, dust, signal pulse, heat vent, and module-disabled effects.
- Node-type icons and posture icons designed for the existing high-contrast palette.
- Short loops/cues for heavy gait, wind/road ambience, contact warning, weapon response, impact, and arrival.

### Human review required

- Final fortress proportions and animation key poses.
- Originality review against references; no traced or near-copy layouts.
- Palette and silhouette review at 1280×720, 100%, and 110% text.
- Sound mix and fatigue testing, especially the repeating gait loop.
- Scenario illustration composition and character continuity.
- Readability check for target lines, flashes, weather, and high-contrast mode.

Generated concept art may accelerate exploration, but production assets need a human-selected direction, documented provenance, and cleanup by an artist or designer.

## Interaction and accessibility rules

- Map, order selectors, Commit, encounter controls, and scenario choices must support pointer, keyboard, and controller.
- Planning always has an explicit Back path and does not mutate state before Commit.
- Pause remains fixed and available during travel and contact.
- A visible Skip Animation action appears during non-interactive playback.
- Reduced Motion removes continuous parallax, large translation, shake, and flashing; it does not shorten reading time.
- Threat intent is expressed through label, shape, line, and color together.
- High contrast strengthens silhouettes and intent lines without erasing biome identity.
- Interface audio reinforces contact and impact but never carries exclusive information.
- The encounter never advances while the player is reading a scenario, inspecting the chassis, or paused.

## Test plan

### Core tests

- A draft plan cannot mutate authoritative state.
- Commit validates all required selections atomically.
- Invalid fuel, engine, route, or posture leaves the complete state unchanged.
- Commit charges day, fuel, heat, and pressure exactly once.
- A fixed seed and plan produce the same contact/scenario schedule.
- Saving and loading in `travel` preserves the committed plan and completed beat index.
- Replaying a presentation event cannot apply damage or cost twice.
- Reduced Motion and Skip Animation do not alter serialized state or outcomes.
- Existing battle target selection and damage results remain unchanged.

### UI-flow tests

- Plan Journey opens in a separate view and preserves map focus on cancel.
- Commit remains disabled until route, posture, doctrine, and readiness are valid.
- Commit review names exact before/after resources and the final-commit rule.
- March view receives the committed snapshot and exposes Pause immediately.
- Threat target lines point to the correct installed module anchor.
- Advance Step plays one authoritative result and then re-enables input.
- Scenario choice returns to march, contact, or arrival as directed by core state.
- Save/Continue from travel and battle restores the correct mode and current order.
- All relevant controls fit at 1280×720 with 100% and 110% text.

### Playtest questions

1. Did planning feel like assembling an order rather than filling a form?
2. Before Commit, could the player state what the chosen road would cost?
3. Did the moving fortress feel heavy and inhabited rather than decorative?
4. Could the player predict where each threat was going?
5. Did animation clarify the causal report or delay it?
6. Was Skip Animation discoverable without becoming the default response?
7. Did the scenario feel physically located on the road?
8. After arrival, did the player understand what changed and what to do next?

## Implementation sequence

### Slice 1 — Extract Plan Journey

- Create `JourneyPlanner.tscn` and move the existing map, comparison, doctrine, Commit, and Cancel presentation into it.
- Add travel-posture selection as preview-only UI backed by pure core preview calculations.
- Keep the current route command underneath initially.
- Preserve all existing focus, scaling, save, and route tests.

This slice improves architecture and planning clarity without adding a new phase.

### Slice 2 — Add committed travel state

- Add `travel` to valid phases and bump the save version.
- Split route commit from encounter start.
- Store the committed plan and deterministic beat schedule.
- Add `advance_travel_beat()` and explicit depart/contact/arrival results.
- Cover atomic commit, save/load, migration, and replay determinism.

This is the necessary simulation seam. Do not begin polished animation before it exists.

### Slice 3 — Build the Ashgate March view

- Add a side-on fortress actor, layered Ashgate road, parallax, gait loop, Pause, Skip, and reduced-motion behavior.
- Drive it from committed travel snapshots and presentation events.
- Use reviewed placeholder silhouettes before commissioning final art.

### Slice 4 — Visualize one hostile contact

- Implement the Road Raider approach lane, target intent line, attack, fortress response, impact, defeat, and dependency highlight.
- Keep Advance Step as the only battle progression command.
- Prove that the visual event sequence matches the existing causal report exactly.

### Slice 5 — Visualize one hazard and scenario

- Implement Storm Front takeover, exposure highlights, and the Soot Orchard tableau.
- Resolve the existing orchard choice in place and resume the march or arrive cleanly.
- Compare a hostile route and a scenario route in a five-tester session.

### Slice 6 — Generalize only after evidence

- Add Climber, Burrower, Flood Surge, Siege Beast, and Civic Guardian visual grammars.
- Add Veyru biome layers and waterline behavior.
- Extract any repeated animation contracts only after two distinct routes use them.

## Explicit non-goals

- Real-time combat or physics-driven outcomes.
- A free-roaming fortress controlled with movement keys.
- Procedural terrain generation.
- A full five-region visual asset set.
- Animated individual crew members.
- Fully destructible fortress sprites.
- A second combat simulation for the cinematic view.
- Hiding route costs or target reasons for spectacle.
- Replacing the chassis grid with a decorative fortress image.

## Recommended first build task

Start with **Slice 1: Extract Plan Journey**. It creates the separate node the new flow needs, reduces pressure on `main.gd`, and lets us test the planning interaction before changing save semantics. The first implementation checkpoint should end at Commit and still enter the current battle panel. Once that is stable, Slice 2 can introduce the real travel phase without mixing architectural extraction, new simulation, and animation in one risky change.
