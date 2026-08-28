# The Long March — Map, Regions, and Settlements

## Map thesis

Use an **FTL-like node map**, but make it feel like a living overland route rather than a starship chart. The fortress advances from one visible landmark to another through a layered network of roads, passes, river crossings, relay lines, and settlement corridors. The player sees the next few choices, not the whole campaign. The map should create tension through **time, fuel, exposure, obligations, and information** rather than surprise alone.

The map is not a random maze. Each chapter is an authored region assembled from deterministic node templates. The player chooses among two or three connected destinations, while an advancing regional pressure clock closes or transforms nodes behind them. A run can therefore diverge without becoming impossible to balance or narrate.

## The node-map model

Each node has a type, region, forecast tags, reward, risk, travel cost, and relationship hooks. Edges have terrain and posture modifiers. A node is visible when it is within signal range or has been revealed by a scout. Unknown nodes show only a silhouette and a broad hazard category.

| Node type | Player purpose | Typical cost | Typical reward |
|---|---|---:|---|
| **Settlement** | Repair, recruit, trade, accept contracts, change doctrine | Time and money | Recovery and new options |
| **Relay** | Improve map knowledge and broadcast warnings | Power, parts, or trust | Forecast confidence and route reveals |
| **Salvage site** | Search for modules, parts, fuel, and contract goods | Time, condition, or cargo space | Refitting resources |
| **Hazard** | Cross a storm, flood, ash field, or unstable pass | Fuel, heat, or condition | Shortcut or chapter progress |
| **Ambush** | Resolve a forecasted hostile encounter | Condition, ammunition, or command points | Salvage, reputation, safe edge |
| **Convoy** | Escort, trade, recruit, or abandon travelers | Speed and cargo capacity | Trust, crew, or contract leverage |
| **Choice site** | Make a moral or strategic campaign decision | Opportunity cost | Faction shift or alternate node |
| **Boss gate** | Test the region’s current fortress plan | Major risk | New region and permanent consequence |

Every route edge displays **travel days, fuel consumption, likely threat families, heat pressure, and contract relevance**. The player can choose a safer edge and arrive late, or a dangerous shortcut and preserve the contract window.

## Visibility and information

The map should use three levels of knowledge:

1. **Known:** node type, reward class, route cost, and principal threat are visible.
2. **Forecast:** one detail is uncertain, such as secondary threat, condition hazard, or faction response.
3. **Unscouted:** only terrain silhouette, distance band, and a broad warning are shown.

Signal facilities, crew abilities, settlement rumors, and prior route history improve knowledge. They should not reveal every event. A strong cartographer gives the player better questions, not perfect answers.

## Pressure clock

Each region has a **closure pressure** that advances when the player spends days, retreats, or takes noisy actions. The pressure may close a node, move a convoy, intensify a threat, or change a settlement’s demand. This replaces FTL’s fixed pursuit with a fiction-appropriate pressure: ash weather, rival claims, floodwater, or a hostile patrol net.

The pressure clock must be visible as a regional band with three thresholds:

| Pressure | Map effect | Player experience |
|---|---|---|
| **Watch** | Some optional nodes become uncertain | Plan and scout |
| **Closing** | One branch changes or disappears | Commit to a route |
| **Break** | A hazard or faction takes control | Recover through a new, worse option |

The clock should never quietly delete the only viable route. If a node closes, a lower-value recovery path opens elsewhere.

## Campaign regions

### Region I — The Ashgate Lowlands

This is the tutorial region of rail embankments, depot towns, dry canals, and raider toll roads. The player learns that moving faster can be safer than fighting, but carrying useful cargo attracts attention.

Key map features include **Ashgate Depot**, **Rill Crossing**, **The Soot Orchard**, **Broken Relay**, and **Morrowline Camp**. The region’s pressure is a growing raider blockade. The boss gate is a fortified toll bridge controlled by the **Red Wheel Company**.

### Region II — The Flooded Veyru Undercroft

The road descends into waterlogged civic ruins. Nodes are closer together but more condition-sensitive. Fragile cargo, signal access, and lower-hull integrity matter more than raw weapon strength.

Key settlements are **Lantern Quay** and **The Dry Archive**. Optional sites include **Drowned Registry**, **Sunken Tramworks**, **Glass Orchard**, and **Mara’s Evacuation Camp**. The pressure is rising water and collapsing routes. The boss gate is a sealed archive defended by a civic guardian and competing salvage crews.

### Region III — The Cinder Spine

A volcanic ridge creates steep grades, high heat, and narrow passes. Heavy armor and generators become expensive to move. The player can mine rare components, but every detour increases heat and fuel pressure.

Settlements include **Blackkiln** and **The Switchback Commune**. Sites include **Charcoal Monastery**, **Red Cut**, **Old Lift Station**, and **The Long Slope**. The pressure is a spreading fireline. The boss gate is an abandoned industrial elevator that must be powered, defended, or bypassed.

### Region IV — The White Salt Expanse

The fortress crosses open salt flats where visibility is excellent but cover is absent. Signals travel far, convoys are visible, and water becomes the main constraint. Settlement trust determines whether the player receives escort beacons or misleading rumors.

Settlements include **Saltglass Haven** and **The Windbreak**. Sites include **Buried Observatory**, **Quiet Caravan**, **Salt Mine**, and **The Empty Mile**. The pressure is an approaching ash front. The boss gate is a rival fortress confrontation where doctrine and redundancy matter more than surprise.

### Region V — Meridian Refuge Corridor

The final region is not a single road but a branching network of shelters, refugee trains, relay stations, and contested passes. Earlier choices determine which nodes appear and which faction claims them.

Key destinations include **Meridian Refuge**, **Relay Crown**, **The Last Shelter**, and **The Narrowing Road**. The pressure is the final storm season and the collapse of the old road. The ending route depends on whether the player optimized mobility, shelter, information, or trust.

## Settlement design

Settlements should be compact service hubs with a recognizable identity and one meaningful conflict. They offer a limited set of actions so visiting one does not become a menu chore.

| Settlement | Identity | Services | Conflict |
|---|---|---|---|
| **Ashgate Depot** | Crowded repair and departure yard | Buy fuel, recruit, refit, first contracts | Who receives the last working parts? |
| **Morrowline Camp** | Moving convoy shelter | Trade cargo, escort, share rumors | Protect the convoy or preserve speed |
| **Lantern Quay** | Flood-edge market | Repair condition, buy water, hire divers | Sell relics or save the archive |
| **The Dry Archive** | Knowledge settlement | Forecasts, map upgrades, identify artifacts | Share information or keep route secrecy |
| **Blackkiln** | Industrial forge town | Build heat tools, repair armor, process salvage | Production demands dangerous extraction |
| **Switchback Commune** | Cooperative mountain settlement | Crew training, alternate routes, shelter | Take a slow safe pass or abandon others |
| **Saltglass Haven** | Water and signal hub | Refill supplies, relay contracts, recruit guides | Trust is priced through promises |
| **Meridian Refuge** | Campaign destination | Final refit, shelter, ending choices | Decide what the fortress becomes |

## Settlement state

Each settlement has three persistent values: **trust**, **capacity**, and **scarcity**. Trust determines whether the settlement offers better contracts and honest forecasts. Capacity determines whether it can shelter refugees, store cargo, or repair large modules. Scarcity changes prices and available services after regional events.

Settlement state should change through explicit player choices. A broken contract might reduce trust but create a salvage opportunity. Delivering a heavy machine may increase capacity while consuming the player’s own mass budget. The map is therefore a network of reciprocal obligations, not a sequence of vendors.

## Settlement bazaar interface

A settlement should open as a recognizable illustrated place rather than a single scrolling stack of unrelated controls. Each hub exposes a small set of labelled people or stations—typically a quartermaster, workshop, information broker, hiring post, assignment board, and departure gate. Activating one station opens one focused task panel; Back returns to the same station in the hub.

The bazaar is not a hidden-object scene. Every interactive location needs a visible label, input focus state, and short purpose. Pointer, keyboard, and controller users must reach the same actions. The persistent header shows only common settlement resources; detailed prices, requirements, and consequences appear inside the selected station.

The first trade model should use small authored stock. Buying previews money, storage, mass, and dependency effects. Selling begins with stored, uninstalled modules so a market action cannot silently dismantle the working fortress. Information purchases reveal named route facts with a visible source and confidence rather than purchasing complete certainty.

## Assignment-aware departure map

Assignments are accepted at the settlement and planned on the map, but they do not choose a route automatically. A potential assignment destination uses a hollow grey marker labelled `OFFER`; an accepted destination uses a filled color marker labelled `ACCEPTED`. Completed and failed assignments retain distinct historical markers. Shape and text must preserve the distinction without color.

Focusing or hovering a reachable location opens a compact card containing route days, fuel, visibility, current news, source confidence, assignment relevance, closure or deadline consequence, and downstream recovery. Inspection never selects the node. Selection moves the route into a review state, and one explicit Commit action is still required to leave.

## In-between roads

Committing to a destination starts a road, not an arrival. The fortress remains at its origin in authoritative state until departure, at least one visible in-between beat, mandatory events or hostile contacts, and arrival have resolved. Longer routes may contain several landmarks, meetings, hazards, or quiet operational beats.

Skipping presentation may accelerate a non-interactive beat but cannot bypass an event, battle, assignment check, or arrival receipt. A battle or event that does not cause retreat returns to the same committed road. This keeps travel meaningful while allowing players to shorten repeated animation.

## Route archetypes

Every chapter should present a familiar set of route questions:

| Route archetype | Safe advantage | Hidden cost |
|---|---|---|
| **Main road** | Reliable forecast and settlement access | Slower and more politically visible |
| **Shortcut** | Saves days and fuel | Higher ambush, heat, or condition risk |
| **Relay line** | Better information and faction trust | Requires protecting exposed signals |
| **Salvage loop** | More parts and modules | More cargo pressure and closure risk |
| **Convoy route** | Trust, crew, or refugee progress | Less room for a pure combat build |
| **Dead ground** | Low visibility to enemies | No repairs, poor information, hard extraction |

## Map generation and testing

The map generator should be deterministic from campaign seed, chapter, and route history. Templates define valid node counts, branch width, guaranteed recovery access, and boss-gate reachability. A validator should reject maps with no settlement before the first hard gate, no extraction path after a failure, duplicate stable IDs, or a closure clock that can remove all viable edges.

The first implementation should use one authored chapter graph with deterministic variations in rewards and secondary threats. Procedural map generation can expand after the authored graph proves readable in playtests.
