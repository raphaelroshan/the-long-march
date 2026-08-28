# Journey Presentation Vertical Slice

## Purpose

The next vertical slice should make the fortress feel as though it is crossing a dangerous place rather than moving instantly from a route button to a combat report. The player should use a settlement, choose an assignment, plan a journey, understand the commitment, watch the machine cross every road segment, see road events where they occur, face threats approaching the part of the fortress they intend to attack, and only then arrive at the destination.

The useful lessons from games such as *FTL* and *Slay the Spire* are structural: give route choices a dedicated planning surface, make commitment explicit, keep threat intent readable, and make movement between decisions feel consequential. The requested frontier-style reference is interpreted as a side-on caravan tableau between hubs: the road remains visible while scenery, travelers, hazards, and enemies enter it. The Long March should retain its own industrial-fantasy visual language and must not reproduce another game's layout, iconography, assets, or terminology.

## Current gap

The current prototype already has the hard part: deterministic routes, forecasts, target selection, interventions, damage, recovery, saves, and two complete chapters. Its presentation compresses three different moments into the Marchmaster's Desk:

1. selecting a node;
2. committing resources and doctrine;
3. entering an encounter whose enemies are represented by cards.

`LongMarchState.begin_campaign_route()` currently pays the route cost, moves `current_location` to the destination, and configures the encounter in one command. Settlement contracts, services, recruitment, map planning, and departure also compete for space in the same scrolling command surface. This makes the loop functional without giving the settlement, departure, road, contact, and arrival distinct visual identities.

## Target player loop

```text
SETTLEMENT BAZAAR
trade + information + hiring + assignments
        |
        v
DEPART / PLAN JOURNEY
map + assignment markers + route + posture + doctrine
        |
        v
COMMIT REVIEW
costs, news, assignments, known threats, recovery warning
        |
        v
IN-BETWEEN MARCH
fortress movement + terrain + landmarks + travel beats
        |
        +----> ROADSIDE EVENT ----> choice consequence ----+
        |                                                 |
        +----> HOSTILE CONTACT ---> step-based encounter --+
        |                                                 |
        +----> QUIET / LANDMARK BEAT -----------------------+
        |                                                 |
        v                                                 v
ARRIVAL TABLEAU -> SETTLEMENT / LOCATION <-----------------+
```

Planning is reversible. Commit is the single authoritative boundary. The fortress remains at its origin until all mandatory intermediate beats are resolved and the arrival command succeeds. March animation communicates already-determined state; it never decides combat through frame timing or physics.

## Vertical-slice boundary

The first implementation should prove one settlement and two contrasting first legs from Ashgate Depot:

| Surface | Presentation purpose | Content |
|---|---|---|
| Ashgate bazaar | Prove service discovery without a wall of controls | Quartermaster, signal broker, hiring post, assignment board, workshop, Depart gate |
| Rill Crossing road | Readable hostile approach on an open ash road | One Road Raider approaches cargo or an exterior mount |
| The Soot Orchard road | Environmental travel and a non-combat interruption | Storm Front plus the existing orchard decision |

This is enough to test a location hub, assignments, purchased information, route planning, commitment, marching, enemy movement, a hazard, a scenario, damage presentation, and arrival. Do not redraw every settlement or encounter before these surfaces feel good.

The slice is complete when a tester can:

1. enter Ashgate as a recognizable bazaar rather than a long control list;
2. inspect trade, information, hiring, assignment, workshop, and departure locations one at a time;
3. accept or leave an assignment and see its destination marker change on the map;
4. compare Rill Crossing and The Soot Orchard on a dedicated Plan Journey screen;
5. choose all required orders and understand why Commit is enabled or blocked;
6. commit once and see the exact resource changes;
7. cross at least one visible in-between road beat before contact or arrival;
8. see a Raider or storm enter through a distinct visual route;
9. connect the threat's movement to a highlighted fortress target;
10. advance the existing deterministic battle one step at a time;
11. resolve the orchard scenario without leaving the road presentation;
12. reach an arrival tableau before `current_location` changes and the next hub opens.

## Screen structure

### 1. Settlement bazaar

A settlement should be a place before it is a menu. Use a wide illustrated yard, market, quay, camp, or archive hall with five or six visible interaction points. Focus or hover identifies a person or place; activation opens one compact task panel over the scene. Back always returns to the bazaar with the same hotspot focused.

```text
+-----------------------------------------------------------------------+
| ASHGATE DEPOT           DAY 1   80 ASHMARKS   TRUST 0        [PAUSE] |
+-----------------------------------------------------------------------+
|                                                                       |
| [WORKSHOP]       [QUARTERMASTER STALL]       [SIGNAL BROKER]          |
|     repair          buy / sell modules         buy road information  |
|                                                                       |
| [HIRING POST]       [ASSIGNMENT BOARD]        [DEPARTURE GATE]       |
|     recruit          accept obligations         open regional map     |
|                                                                       |
+-----------------------------------------------------------------------+
| Focus: Assignment Board                                               |
| Two roads need a carrier. No assignment is accepted.                  |
+-----------------------------------------------------------------------+
```

The first bazaar exposes these stations:

| Station | First-slice responsibility |
|---|---|
| Quartermaster | Buy from a small fixed stock and sell stored, uninstalled modules; always preview money, mass, space, and dependency impact |
| Signal broker | Buy one authored piece of road information that upgrades a specific uncertainty rather than revealing the whole map |
| Hiring post | Inspect available or rumored specialists, their required facility, price, and operational pressure |
| Assignment board | Compare, accept, and track destination-bound obligations |
| Workshop | Repair, refuel, and enter the existing chassis refit surface |
| Departure gate | Open Plan Journey; never depart immediately |

Only one station panel is open at a time. The persistent settlement header shows the few resources that matter to every station. Detailed module, contract, or route information appears only after choosing the relevant station. This replaces the current long vertical stack without hiding actions behind unlabeled scenery.

The first implementation can map existing content into the hub:

- Ashgate's Morrowline Parts Guard becomes an assignment-board offer.
- Existing fuel and repair actions move to Quartermaster and Workshop.
- Existing Iven and Mara requirements establish the hiring-card format, even where a candidate is only rumored.
- One purchasable Ashgate road report upgrades one selected immediate route from Forecast to Known or reveals one hidden risk factor.

Buying and selling should begin with a bounded stock rather than a procedural economy. Selling is limited to stored modules so the transaction cannot silently dismantle the live fortress. Refit remains the only place that installs or removes a module.

### 2. Plan Journey

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

- **Map:** shows the current node, reachable roads, secured path, closures, visibility, and assignment markers.
- **Road dossier:** explains the selected route's cost, uncertainty, current news, known pressure, likely contact, assignment relevance, and what follows it.
- **March orders:** collects the required choices and reports fortress readiness before Commit.

Assignment markers have explicit semantics:

| Marker | Meaning |
|---|---|
| Hollow grey assignment badge | An assignment offered at the current settlement concerns this destination, but it has not been accepted |
| Saturated assignment badge | An accepted assignment has this destination or waypoint |
| Checked muted badge | The assignment was completed here and remains only as route history |
| Broken red badge | The deadline or required cargo can no longer be met; details explain why |

Grey is not the only signal: potential assignments use a hollow shape and `OFFER`; accepted assignments use a filled shape and `ACCEPTED`. The same information must survive high-contrast mode.

Focus or pointer hover opens a small, stable information card without selecting or committing the node. It contains:

- location name and type;
- road days and fuel cost;
- known, forecast, or unscouted threat information;
- current regional news, its source, and confidence;
- accepted and potential assignment relevance;
- closure or deadline consequence;
- recovery availability after the road.

Clicking or confirming the node selects it and moves the dossier into the March Orders column. A second explicit Commit action is still required to leave.

The first slice requires three deliberate selections:

1. **Road:** one reachable destination.
2. **Travel posture:** Scout, Conserve, or Push.
3. **Battle doctrine:** Protect Cargo, Protect Crew, or Run Hot.

The existing emergency interventions remain reactive during contact. They should not be consumed or mechanically locked during planning. A later slice may let the player mark one as the prepared order for faster access, but preparation must not remove the decision of when or where to use it.

### 3. Commit review

Commit should be one explicit, atomic action. The button remains disabled until the route, posture, doctrine, and fortress readiness are valid. Its final review should show deltas rather than vague warnings:

```text
COMMIT RILL CROSSING
Day 1 -> 2      Fuel 6 -> 5      Pressure 0 -> 1
Posture: Scout  Doctrine: Protect Cargo
Known contact: Road Raider
Assignment: Morrowline Parts Guard · 3 days remain
News: Red Wheel outriders seen at the east culvert · reliable
Likely target: Parts Crate
Recovery after this road: none guaranteed
```

Cancel returns to the unchanged plan. Confirm creates a committed journey snapshot, pays costs once, checkpoints, and transfers to the in-between March view. It does not change `current_location` to the destination.

### 4. March view

The march should use a wide side-on illustrated frontier diorama. The fortress remains near the left third of the frame while road and scenery move right-to-left. This gives strong motion with a modest asset budget and keeps travelers, landmarks, weather, and enemy approach distances readable.

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

Every authored intermediate beat occurs even if its animation is skipped. Skip Animation fast-forwards only the current non-interactive presentation and must stop at scenarios, hostile contacts, assignment decisions, and arrival. Reduced Motion replaces parallax, camera impulse, and continuous gait with short crossfades and position changes while preserving all labels and causal highlights.

### 5. Contact presentation

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

### 6. Roadside scenarios

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
├── SettlementHubView        scenes/settlement/SettlementHub.tscn
│   ├── BazaarBackdrop
│   ├── StationHotspots
│   └── ActiveStationPanel
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
| `src/ui/settlement_hub.gd` | Displays the bazaar, station hotspots, active task panel, and return focus. Emits service requests without changing prices or inventory itself. |
| `src/ui/assignment_board.gd` | Presents offered and accepted assignments, their requirements, destinations, deadlines, and consequences. |
| `src/ui/market_panel.gd` | Presents fixed stock and stored-module sales with authoritative transaction previews. |
| `src/ui/journey_planner.gd` | Owns draft selections, validation display, focus order, and Commit request. No resource mutation. |
| `src/ui/march_view.gd` | Renders the current travel/contact snapshot and coordinates presentation playback. |
| `src/ui/fortress_actor.gd` | Maps installed modules to side-view anchors and displays gait, damage, target, and dependency states. |
| `src/ui/threat_actor.gd` | Displays one threat from authored visual metadata and applies approach/attack/defeat animations. |
| `src/ui/journey_presentation_director.gd` | Converts structured core events into animation sequences, supports skip/reduced motion, and reports playback completion. |
| `src/ui/scenario_view.gd` | Displays authored event tableau, requirements, choices, and consequences. |

`src/ui/main.gd` should become the coordinator between these views rather than continuing to construct every control and visual directly. Extraction should happen incrementally; rewriting the entire 3,700-line controller in one change would be unnecessarily risky.

## Authoritative state and data

### Settlement visit and assignment state

The bazaar is presentation, but offers and transactions are authoritative. The first durable model should include:

```text
settlement_visit_id
settlement_service_actions_remaining
settlement_market_stock_ids
settlement_information_offer_ids
settlement_recruit_offer_ids
settlement_assignment_offer_ids
accepted_assignment_ids
completed_assignment_ids
failed_assignment_ids
acquired_intel_ids
```

An assignment definition needs enough structure to affect both the settlement and map:

```text
id
origin_location_id
destination_location_ids
waypoint_location_ids
status                 offered, accepted, completed, failed
required_module_tags
required_cargo_ids
deadline_day
reward
failure_consequence
map_marker_id
```

The initial assignment catalog should reuse `morrowline_parts_guard` and the Veyru medicine obligation before adding more contracts. One assignment may point to several legal destinations, but it may not silently choose the route for the player.

Purchased information is an authored record, not a permanent global reveal:

```text
intel_id
subject_location_id or subject_edge_id
source_id
confidence             reliable, partial, rumor
revealed_fields
acquired_day
expires_day             optional
```

The map merges base visibility, operational signal capability, regional developments, and acquired intel into one preview. The UI should be able to explain which source revealed each detail.

Market previews and commands must state item ID, buy or sell price, current ownership, storage capacity, and dependency impact. Stock is fixed for the first slice so a shop refresh cannot become another hidden random system.

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
journey_status              departing, road, event, contact, arriving
```

Only mechanically meaningful fields belong in `LongMarchState`. Camera position, tween progress, dust particles, current animation frame, and parallax offsets are presentation-only and must not be serialized.

`current_location` remains the origin throughout departure, road events, and hostile contacts. `journey_destination` names the intended next location. Only `complete_journey_arrival()` moves `current_location`, clears the committed segment, applies arrival events, and opens the destination's hub or node state. Retreat uses the same rule by naming and completing a return destination rather than teleporting during combat resolution.

The first implementation should use at least four visible travel beats per road:

1. **Depart** — costs and commitment are already recorded.
2. **Road** — a landscape, landmark, traveler, or quiet operational beat establishes distance.
3. **Interruption** — a scenario, assignment checkpoint, hazard, or hostile contact is resolved.
4. **Arrival** — the destination becomes current only after the arrival beat completes.

Longer roads may have more than one road or interruption beat. Every schedule must preserve at least one in-between road beat; a route may not consist only of departure followed immediately by contact or arrival.

If an interruption starts battle, encounter completion returns to `travel` for the remaining beats unless the fortress retreats or the route explicitly ends at the battle site. If an event requires a choice, travel remains blocked until that choice resolves.

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
├── settlement_visuals
├── station_visuals
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
| Settlement visual | `location_id`, backdrop, station anchors, ambient cue, arrival cue |
| Station visual | `station_id`, label, actor or prop, focus bounds, panel type, unavailable treatment |
| Biome | `id`, background layers, palette, road layer, weather layer, ambient cue |
| Route visual | `route_id`, biome, time of day, landmarks, travel speed band |
| Fortress visual | body, front/rear gait layers, exhaust anchors, module-grid transform |
| Threat visual | `threat_id`, silhouette, approach lane, scale, contact anchor, telegraph cue, defeat cue |
| Scenario visual | `event_id`, tableau, foreground props, optional character portrait, ambience |
| Effect visual | `visual_cue_id`, sprite/animation, duration band, reduced-motion fallback |

The validator should reject missing stable IDs, unknown threat/event references, absent reduced-motion fallbacks, and paths outside reviewed asset directories.

Assignment, market, recruitment, and information offers belong in their existing gameplay/content catalogs or a dedicated validated settlement-offers catalog. Visual files may reference those stable IDs but may not define prices, deadlines, requirements, rewards, or route effects.

## Art and audio inventory

The first visual pass can use authored silhouettes and limited frame animation. It does not need skeletal animation or full character sprites.

### Required for the first slice

- One Ashgate bazaar backdrop with distinct Quartermaster, Signal Broker, Hiring Post, Assignment Board, Workshop, and Departure Gate anchors.
- Two or three readable character/merchant silhouettes with idle states; a station may use a strong prop where no named character exists.
- Assignment states for offered, accepted, completed, and failed destinations.
- A compact map news card with source and confidence treatments.
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
- Bazaar stations must have visible labels and focus states; scenery alone cannot be the hit target.
- Back from a station returns to its hotspot, and Depart returns from the map to the Departure Gate.
- Planning always has an explicit Back path and does not mutate state before Commit.
- Pause remains fixed and available during travel and contact.
- A visible Skip Animation action appears during non-interactive playback.
- Reduced Motion removes continuous parallax, large translation, shake, and flashing; it does not shorten reading time.
- Threat intent is expressed through label, shape, line, and color together.
- High contrast strengthens silhouettes and intent lines without erasing biome identity.
- Interface audio reinforces contact and impact but never carries exclusive information.
- The encounter never advances while the player is reading a scenario, inspecting the chassis, or paused.
- Skip Animation may shorten motion but must never skip an interactive road event, assignment checkpoint, hostile contact, or arrival receipt.

## Test plan

### Core tests

- Settlement offers and fixed market stock reproduce from the same chapter state.
- Buy, sell, information, hire, and assignment commands validate atomically and leave state unchanged on failure.
- Accepting an assignment changes only its authoritative status and map relevance; it does not select a route.
- Purchased intel reveals only its authored fields and retains its source/confidence metadata.
- A draft plan cannot mutate authoritative state.
- Commit validates all required selections atomically.
- Invalid fuel, engine, route, or posture leaves the complete state unchanged.
- Commit charges day, fuel, heat, and pressure exactly once.
- `current_location` remains the origin until arrival completes.
- Every route schedule contains at least one in-between road beat.
- Completing a mid-road battle or event resumes the same committed journey when appropriate.
- A fixed seed and plan produce the same contact/scenario schedule.
- Saving and loading in `travel` preserves the committed plan and completed beat index.
- Replaying a presentation event cannot apply damage or cost twice.
- Reduced Motion and Skip Animation do not alter serialized state or outcomes.
- Existing battle target selection and damage results remain unchanged.

### UI-flow tests

- Settlement opens as a bazaar and exposes only one station panel at a time.
- Back from every station restores the originating hotspot and does not close the settlement.
- Potential assignment destinations use hollow grey markers; accepted destinations use filled color markers plus text.
- Hover/focus news never selects a route, spends money, or changes assignment status.
- Plan Journey opens in a separate view and preserves map focus on cancel.
- Commit remains disabled until route, posture, doctrine, and readiness are valid.
- Commit review names exact before/after resources and the final-commit rule.
- March view receives the committed snapshot and exposes Pause immediately.
- Skip Animation stops at the next interactive interruption instead of jumping to the destination.
- Threat target lines point to the correct installed module anchor.
- Advance Step plays one authoritative result and then re-enables input.
- Scenario choice returns to march, contact, or arrival as directed by core state.
- Save/Continue from travel and battle restores the correct mode and current order.
- All relevant controls fit at 1280×720 with 100% and 110% text.

### Playtest questions

1. Could the player find trade, information, hiring, assignments, workshop, and departure from the bazaar without scanning a long list?
2. Did potential versus accepted assignment markers read correctly before opening their details?
3. Did planning feel like assembling an order rather than filling a form?
4. Before Commit, could the player state what the chosen road would cost and which promise it served?
5. Did the in-between road make the destination feel travelled to rather than loaded instantly?
6. Did the moving fortress feel heavy and inhabited rather than decorative?
7. Could the player predict where each threat was going?
8. Did animation clarify the causal report or delay it?
9. Was Skip Animation discoverable without bypassing meaningful content?
10. Did the scenario feel physically located on the road?
11. After arrival, did the player understand what changed and what to do next?

## Implementation sequence

### Slice 1 — Build the settlement hub shell

- Create `SettlementHub.tscn` with the six labelled bazaar stations and one active station panel.
- Move existing Ashgate contract, repair, refuel, refit, recruitment status, and departure entry points into the matching stations without changing their mechanics.
- Preserve fixed header information, focus return, pointer/keyboard/controller parity, Pause, and 110% text behavior.
- Keep unimplemented trade or information actions visibly unavailable rather than presenting fake choices.

This immediately reduces information density while preserving the proven simulation.

### Slice 2 — Extract Plan Journey

- Create `JourneyPlanner.tscn` and move the existing map, comparison, doctrine, Commit, and Cancel presentation into it.
- Add travel-posture selection as preview-only UI backed by pure core preview calculations.
- Add potential/accepted assignment marker inputs using the existing regional contract as the first real assignment.
- Add the non-mutating hover/focus information card with route cost, news source, confidence, and recovery note.
- Keep the current route command underneath initially.
- Preserve all existing focus, scaling, save, and route tests.

This slice improves architecture and planning clarity without adding a new phase.

### Slice 3 — Add bounded settlement offers

- Add fixed market stock, stored-module selling, one Ashgate information offer, and assignment status commands.
- Map Morrowline Parts Guard and the Veyru medicine obligation into the shared assignment contract.
- Keep hiring limited to existing specialist requirements until the hub interaction is proven.
- Validate every offer ID and transaction result through content tools and deterministic tests.

### Slice 4 — Add committed travel state

- Add `travel` to valid phases and bump the save version.
- Split route commit from encounter start.
- Keep `current_location` at the origin throughout the road.
- Store the committed plan and deterministic beat schedule.
- Add `advance_travel_beat()`, battle/event resume, and explicit depart/contact/arrival results.
- Require at least one in-between road beat for every route.
- Cover atomic commit, save/load, migration, and replay determinism.

This is the necessary simulation seam. Do not begin polished animation before it exists.

### Slice 5 — Build the Ashgate March view

- Add a side-on fortress actor, layered Ashgate road, parallax, gait loop, Pause, Skip, and reduced-motion behavior.
- Drive it from committed travel snapshots and presentation events.
- Use reviewed placeholder silhouettes before commissioning final art.

### Slice 6 — Visualize one hostile contact

- Implement the Road Raider approach lane, target intent line, attack, fortress response, impact, defeat, and dependency highlight.
- Keep Advance Step as the only battle progression command.
- Prove that the visual event sequence matches the existing causal report exactly.

### Slice 7 — Visualize one hazard and scenario

- Implement Storm Front takeover, exposure highlights, and the Soot Orchard tableau.
- Resolve the existing orchard choice in place and resume the march or arrive cleanly.
- Compare a hostile route and a scenario route in a five-tester session.

### Slice 8 — Generalize only after evidence

- Add Climber, Burrower, Flood Surge, Siege Beast, and Civic Guardian visual grammars.
- Add Veyru biome layers and waterline behavior.
- Extract any repeated animation contracts only after two distinct routes use them.

## Explicit non-goals

- Real-time combat or physics-driven outcomes.
- A free-roaming fortress controlled with movement keys.
- Teleporting to the destination when Commit is pressed.
- Skip controls that bypass authored events, contacts, assignment checks, or arrival.
- Procedural terrain generation.
- A full five-region visual asset set.
- Animated individual crew members.
- Fully destructible fortress sprites.
- A second combat simulation for the cinematic view.
- Hiding route costs or target reasons for spectacle.
- Replacing the chassis grid with a decorative fortress image.

## Recommended first build task

Start with **Slice 1: Build the settlement hub shell**. It addresses the current information overload with the lowest simulation risk and establishes the location-to-map transition. The first implementation checkpoint should let a tester enter Ashgate, move among six clearly labelled bazaar stations, use the existing contract and service actions, choose Depart, and reach the unchanged current map. Slice 2 then extracts that map into Plan Journey before any save-format or travel-phase change.
