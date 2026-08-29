# Fortress Visual Modes

## Goal

The fortress should be the visual anchor of every playable mode. Values belong in a stable rail to its left, while the selected object, person, road, threat, or consequence belongs in a stable detail dock to its right. The center is reserved for the fortress, settlement, road, or map—not another column of prose.

The interface should borrow the clarity of FTL's persistent ship state and node-by-node travel without copying its screen composition or assets. The Long March remains an illustrated industrial-fantasy game about a heavy walking settlement.

## Shared 1280×720 frame

```text
+--------------------------------------------------------------------------------+
| CHAPTER / LOCATION / CURRENT ORDER                              PAUSE / BUILD  |
+-------------+-------------------------------------------+----------------------+
| VALUE RAIL  |                                           | DETAIL DOCK          |
|             |              CENTER STAGE                 |                      |
| Hull        |                                           | selected station,    |
| Fuel        |    fortress / bazaar / road / map         | route, module,       |
| Power       |                                           | threat, event, or    |
| Heat        |                                           | consequence          |
| Mass        |                                           |                      |
| Ashmarks    |                                           |                      |
| Context     |                                           |                      |
+-------------+-------------------------------------------+----------------------+
| MODE ACTIONS / TIMELINE / CONFIRMATION                                         |
+--------------------------------------------------------------------------------+
```

Recommended proportions at the reference resolution:

| Region | Width | Purpose |
|---|---:|---|
| Value rail | 190-220 px | Stable operational values and one contextual budget |
| Center stage | 700-760 px | Fortress, settlement, map, road, and threat movement |
| Detail dock | 300-340 px | One focused subject and its available actions |
| Header | 52-60 px | Location, current order, build ID, Pause |
| Action strip | 64-88 px | Commit, advance, intervention, back, or confirmation |

At 110% text the rails may widen slightly and the center may lose decorative margin, but the fortress must not be pushed below the fold. Long details scroll inside the right dock rather than moving the whole scene.

## Information hierarchy

### Left value rail

Values stay in fixed vertical slots so the player learns where to look. Each value uses an icon or short label, current value, safe/warning/critical state, and a tooltip or focus description.

Persistent values:

1. Hull
2. Fuel
3. Power used / available
4. Heat / safe limit
5. Mass / movement limit
6. Ashmarks

The final slot is contextual:

- settlement: service actions and trust;
- planning: regional pressure and nearest deadline;
- march: distance and pressure;
- encounter: command points and next contact step;
- result: final outcome and surviving systems.

Do not repeat these numbers in the right dock unless the selected action changes them. A transaction or route preview shows a before/after delta, not another static dashboard.

### Center stage

The center answers “where is the fortress and what is happening to it?” It contains one of four modes:

- fortress at rest in a settlement;
- regional route map;
- fortress moving on the road;
- fortress under contact.

The same fortress actor and module-anchor map should persist across rest, movement, and contact. A player should not have to relearn where an engine, weapon, workshop, signal system, or cargo module is represented.

### Right detail dock

The dock answers “what am I inspecting or deciding?” It shows exactly one subject:

- bazaar station and its actions;
- selected module and dependency;
- selected map location and current news;
- committed journey order;
- threat intent and predicted impact;
- roadside event and choices;
- arrival or consequence receipt.

Back closes the current detail and restores the originating focus. The dock should not contain the entire run history; March Record and debrief already own that job.

## Shared fortress actor

The fortress is composed from a stable exterior silhouette plus state overlays:

```text
FortressActor
├── RearLegAssembly
├── RearHull
├── InteriorModuleLayer
├── MainHull
├── FrontLegAssembly
├── ExteriorMountLayer
├── ExhaustAndHeatLayer
├── DamageLayer
├── TargetIntentLayer
└── SelectionLayer
```

The 6×4 simulation grid maps into a bounded interior rectangle on the side-view hull. Module art may begin as family silhouettes, but its placement and footprint must follow the real installed module. Exterior modules use dedicated mount anchors. This gives the cinematic fortress a truthful connection to the editable chassis.

Visual states:

| State | Treatment |
|---|---|
| Ready | Stable warm light and normal family color |
| Strained | Amber pulse at the dependency edge |
| Offline | Dim interior, broken outline, no active effect |
| Damaged | Durability marks, smoke or sparks proportional to severity |
| Selected | Cyan outline at rest; gold outline in edit mode |
| Targeted | Red intent line and labelled target bracket |
| Protected | Armor or intervention bracket between threat and target |

The module grid remains available as an inspection/edit overlay. The exterior fortress does not replace the spatial puzzle; it makes the consequences of that puzzle visible in the world.

## Mode 1: fortress at rest

At a settlement the fortress occupies the center of the yard with its legs planted, suspension settled, exhaust low, and crew-scale activity around it. The current settlement architecture surrounds the fortress without obscuring its silhouette.

```text
LEFT VALUES       ASHGATE BAZAAR / FORTRESS AT REST              DETAIL
--------------   -------------------------------------------   -----------
Hull 10/10          Workshop       Signal Broker                station
Fuel 6/8                 \          /                           name
Power 4/6             [ WALKING FORTRESS ]                      purpose
Heat 5/6                 /          \                           actions
Mass 13/14       Quartermaster   Assignment Board               costs
80 Ashmarks                 Departure Gate                      [Back]
Trust 0
```

Idle animation should be restrained: pressure valves breathe, lamps flicker, a crane moves, canvas shifts, and one leg adjusts weight. The fortress should appear inhabited and serviceable, not frozen or already marching.

Selecting a bazaar station focuses the right dock while the center keeps the station visibly highlighted. Selecting the Workshop may open the chassis cutaway in the center. Depart transitions the center to the regional map.

## Mode 2: FTL-like regional map

The map is a separate center-stage mode. It uses an authored node graph with limited forward visibility and one-hop commitment. It should feel like a route chart laid over the actual region, not a generic constellation.

```text
LEFT VALUES       ASHGATE LOWLANDS MAP                           DETAIL
--------------   -------------------------------------------   -----------
Fuel 6/8                       ? future                         Rill Crossing
Day 1                   o------o                                Known ambush
Pressure 0             /                                        1 day / 1 fuel
Deadline 3d      [FORTRESS]                                     Raider report
Assignments 1          \                                        Assignment path
Signal Ready            o------o locked                         Recovery: none
                                                                [Select]
                                                   [Commit Journey]
```

Map rules:

- The fortress token marks the true current location.
- Only directly connected next locations are selectable.
- Future topology may be visible, but future details follow Known, Forecast, and Unscouted rules.
- Hover or focus opens the right detail card; it does not select.
- Select highlights one route and shows all required orders.
- Commit is separate and always displays costs, deadline effects, and assignment relevance.
- Potential assignments use hollow grey markers plus `OFFER`.
- Accepted assignments use filled color markers plus `ACCEPTED`.
- Closed, locked, bypassed, and secured nodes retain distinct shapes and text.
- The map never advances the fortress token before the road's arrival resolves.

The map should not support multi-node autopilot in the initial slice. Choosing one edge at a time keeps events, pressure, recovery, and assignments readable.

## Mode 3: fortress moving

After Commit, the center crossfades from the map into a side-on road tableau. The fortress moves in place while background layers and road details pass right-to-left. The left rail switches from planning values to travel values; the right dock shows the committed order and next known interruption.

Movement layers:

1. distant sky and weather, nearly static;
2. far settlements, ridges, ruins, or gantries, slow parallax;
3. roadside structures and travelers, medium parallax;
4. road surface, debris, grass, water, or ash, fast parallax;
5. dust, rain, sparks, exhaust, and signal pulses tied to fortress state.

Fortress motion profiles:

| Profile | Motion | Mechanical source |
|---|---|---|
| Idle | Settled legs, low exhaust, occasional service movement | Settlement/rest mode |
| Scout | Slow gait, raised signal animation, searching light | Scout posture |
| Conserve | Even gait, low exhaust, reduced weapon activity | Conserve posture |
| Push | Longer stride, hotter exhaust, greater chassis bounce | Push posture |
| Limping | Uneven gait and reduced scenery speed | Damaged movement chain |
| Retreat | Reversed landmark order and urgent but unstable cadence | Recoverable failure |

At least one in-between beat must play before any arrival. Quiet beats are not empty loading screens: they show a landmark, weather change, passing convoy, module warning, assignment reminder, or short operational observation. These may be non-interactive, but they establish distance and context.

## Mode 4: moving encounter

Contact occurs in the same road tableau. The fortress remains visually moving unless the threat or chosen response forces it to brace or stop. The center opens an approach lane to the right and shifts the fortress slightly left of center without shrinking it into an icon.

The encounter presentation has three synchronized layers:

1. **World:** enemy or hazard movement relative to the fortress.
2. **Intent:** line, route, target bracket, and predicted damage.
3. **Mechanics:** step timeline, intervention availability, and causal receipt.

Threat movement is authored, not physics-driven:

- Raiders ride along the road and peel toward exposed cargo.
- Climbers close at wheel or leg height, then rise toward upper anchors.
- Burrowers travel as ground deformation beneath the selected lower-hull target.
- Storm and flood contacts move as environmental boundaries across the frame.
- Siege Beast occupies the road ahead and forces the fortress to brace while still showing its momentum.

When Advance Step is pressed, the core resolves exactly one step and returns structured events. The presentation director plays those events in order, then unlocks input. Skip finishes the current event animation and lands on its receipt; it never executes another step.

## Mode transitions

```text
BAZAAR
  Depart -> MAP

MAP
  Back -> BAZAAR
  Commit -> DEPARTURE TRANSITION -> MOVING

MOVING
  Quiet beat -> MOVING
  Event -> ROADSIDE EVENT -> MOVING
  Contact -> MOVING ENCOUNTER -> MOVING
  Arrival -> ARRIVAL TRANSITION -> LOCATION / BAZAAR
  Retreat -> RETREAT MOVEMENT -> RECOVERY LOCATION
```

The transitions should preserve spatial continuity. Departure shows the settlement receding; arrival introduces the destination before controls change. A hard cut is acceptable under Reduced Motion, but state and receipt order remain identical.

## Scene responsibilities

| Scene/script | Responsibility |
|---|---|
| `FortressActor.tscn` / `fortress_actor.gd` | Persistent exterior, module anchors, state overlays, idle/gait/brace/limp modes |
| `FortressValueRail.tscn` / `fortress_value_rail.gd` | Stable values and mode-specific final slot |
| `ContextDock.tscn` / `context_dock.gd` | One selected subject, action list, before/after deltas, and return focus |
| `SettlementHub.tscn` / `settlement_hub.gd` | Bazaar backdrop, station anchors, hub navigation, selected station |
| `JourneyPlanner.tscn` / `journey_planner.gd` | Node map, inspection, assignment markers, route orders, Commit |
| `MarchView.tscn` / `march_view.gd` | Parallax road, environment, fortress placement, progress, interruption surface |
| `ThreatActor.tscn` / `threat_actor.gd` | Authored approach lane and state animation for one threat |
| `JourneyPresentationDirector` | Plays structured events; never mutates simulation values |

The first implementation may draw the fortress and bazaar with Godot primitives and existing assets. Preserve these scene APIs so reviewed raster or skeletal art can replace placeholders without rewriting state or input logic.

## Presentation-only variables

These may live in view classes and must not enter saves:

```text
fortress_visual_mode       idle, scout, conserve, push, limping, braced
fortress_screen_anchor
fortress_visual_scale
module_anchor_map
focused_module_id
targeted_module_ids
environment_scroll_offset
environment_scroll_speed
active_parallax_profile
active_weather_strength
threat_actor_positions
active_intent_lines
animation_queue
animation_speed
animation_is_skippable
camera_impulse_strength
```

All mechanically meaningful route, assignment, encounter, damage, and arrival values remain in `LongMarchState` as specified by the journey presentation plan.

## First implementation checkpoints

1. Move the existing top-row metrics into a left value rail while keeping values and tooltips unchanged.
2. Center the existing fortress grid and place its dependency detail in the right dock.
3. Add a mode switch that can show Fortress at Rest or the regional map in the center without rebuilding state.
4. Build the Ashgate bazaar around the centered fortress using labelled code-native station silhouettes.
5. Extract the map into its center-stage mode with assignment marker inputs.
6. Replace the grid-only center with the shared exterior FortressActor once travel state exists.
7. Add moving and encounter modes through presentation events.

The first code checkpoint should accomplish items 1-4 without altering route or battle mechanics. It should already feel less like a dashboard: values stay left, the fortress dominates the center, and the right dock explains only the selected station or system.

## Implemented presentation checkpoint (`0.3.0-alpha.270`)

The playable slice now uses the same three-part composition in settlement, planning, contact, roadside decisions, and arrival. `RoadContactView` centers a code-native side-on fortress, stages every current enemy family in its authored approach lane, marks the authoritative target anchor, and repeats target rationale, predicted damage, and dependency cascades in the command dock. Inspect Chassis temporarily returns to the exact simulation-backed grid; cancel restores the contact scene and its visible focus target. `JourneyArrivalView` holds the resolved consequence receipt before the next phase becomes interactive. When an authored decision is pending, `RoadsideEventView` keeps the fortress in a wide frontier tableau beside the actual orchard, relay, toll, forge, machinery, floodworks, or archive subject while one right-hand dock exposes the authoritative choices.

This is a legibility checkpoint rather than final animation. Threat movement, attack anticipation, impact frames, fortress response, and authored biome effects remain presentation-only follow-up work. The deterministic encounter engine, route resolution, module targets, damage, and save format are unchanged.

## Shared silhouette continuity checkpoint (`0.3.0-alpha.280`)

The shared fortress now uses one primary condition mark per family bay instead of stacking damage cracks, sealed labels, dependency warnings, offline crosses, and target circles in the same small surface. Target intent remains outside the bay as corner brackets, preserving the authoritative target without hiding the family pictogram. The stable hull gains restrained timber, canvas, engine-housing, patch-plate, cargo-restraint, heat, dust, rain, and waterline cues; Ashgate and Veyru therefore read as different operating environments while retaining the same machine identity and module anchors.

The complete state and precedence contract is recorded in [`fortress_visual_state_inventory.md`](fortress_visual_state_inventory.md). Region and heat are presentation snapshot fields derived from the existing simulation. No target, damage, dependency, travel, recovery, or save rule moved into the renderer.

## Acceptance criteria

- The fortress is the largest meaningful object in rest, travel, and encounter modes.
- Key values remain in stable left-rail positions across mode changes.
- The right dock contains one current subject and does not duplicate the complete metric rail.
- At-rest animation reads differently from marching and contact animation.
- Map inspection, selection, and commitment remain three distinct actions.
- A contact's movement and intent line identify its authoritative module target.
- The exterior fortress and chassis grid describe the same installed modules.
- The full interaction remains usable at 1280×720 and 110% text.
- Pointer, keyboard, and controller reach identical actions.
- Reduced Motion, Pause, and Skip cannot alter deterministic state.

## Non-goals

- Real-time steering or manual aiming.
- Physics-based walking or collision.
- Free camera pan and zoom in the first map pass.
- Tiny animated crew agents.
- A separate decorative fortress whose modules do not match the chassis.
- Moving critical values to different screen regions for every mode.
- Using motion, color, or particle effects as the only explanation of state.
