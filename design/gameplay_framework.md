# The Long March — Gameplay Framework

## Design thesis

The Long March is about arranging a machine whose parts need one another. The player is not looking for the largest collection of bonuses. They are balancing **capacity, connectivity, power, heat, exposure, crew, cargo, and movement** while the fortress crosses a dangerous world.

The best build is never universally best. It is best for a route, a weather condition, a contract, a threat doctrine, and a current state of damage.

## The fortress as an inventory

The fortress uses one primary 6-by-4 chassis grid and a small number of exterior mount points. A module occupies one or more cells and may have a connection type. Modules can be rotated when their shape permits it.

| Module property | Player-facing question |
|---|---|
| **Shape** | Can it fit without breaking a useful layout? |
| **Mass** | Can the fortress still travel at a useful speed? |
| **Power draw** | Can the current generators sustain it? |
| **Heat** | How long can it operate before requiring a vent or cooldown? |
| **Durability** | What happens when this part takes damage? |
| **Dependency tags** | What must be nearby or connected for it to work? |
| **Exposure** | Is it protected inside the chassis or vulnerable outside? |
| **Crew requirement** | Does it need a specialist, a station, or an unoccupied room? |
| **Cargo value** | Is the space carrying a current tool, a future sale, or a contract item? |

## Spatial rules

The rules should be thematic but not opaque.

| Placement relationship | Benefit | Cost |
|---|---|---|
| Engine adjacent to fuel store | Reduced fuel consumption or faster travel recovery. | A chain fire or engine hit can damage both. |
| Weapon connected to ammunition lift | Faster reload and higher sustained pressure. | The lift becomes a critical dependency. |
| Workshop near an exterior mount | Faster repairs to exposed equipment. | Workshop space is not available for armor or cargo. |
| Armor around crew room | Protects a valuable specialist. | Armor increases mass and reduces room for utility. |
| Signal equipment on high exterior mount | Earlier forecasts and better route information. | Storms and Climbers can disable it. |
| Cargo near an access hatch | Faster unloading and salvage. | Raiders can reach it more easily. |
| Redundant generator links | Prevents one hit from disabling all systems. | Redundancy consumes space and mass. |

A relationship should be shown through a direct visual line, icon, or short phrase such as **“Ammunition lift connected: reload improved”**. The player should not need to infer hidden adjacency rules from repeated failure.

## Operating priorities

Before travel or combat, the player chooses a small number of priorities:

- **Power priority:** engines, weapons, shields, repairs, or life support.
- **Target doctrine:** disable weapons, protect the convoy, focus the largest threat, or preserve ammunition.
- **Travel posture:** rush, scout, conserve, or detour.
- **Emergency order:** seal a compartment, vent heat, cut loose cargo, or shift crew.

These choices should alter how the same fortress behaves. They are not permanent build decisions and should provide a final moment of agency before auto-resolution.

## Auto-battle structure

Every encounter is divided into readable phases:

1. **Forecast:** the threat, likely target, uncertainty, and available preparation window are shown.
2. **Approach:** the enemy advances or the hazard develops while the fortress begins its default routine.
3. **Contact:** attacks begin and the first dependencies are tested.
4. **Intervention window:** the player can use one or more limited commands depending on crew readiness and command points.
5. **Adaptation:** the enemy responds to the fortress’s exposed weakness or changes target doctrine.
6. **Outcome:** the player receives damage, salvage, delay, route change, or recovery options.

The event timeline should include the causal chain: **Signal Post detected Climbers → Wall Lamp exposed landing point → player shifted power to lamps → Pike Crew reached the mount → cargo remained intact**.

## Module families

### Engines and movement

Engines determine travel speed, fuel consumption, and the ability to choose a longer or safer route. An engine build should be efficient but vulnerable to Burrowers and fuel scarcity.

### Weapons and pressure

Weapons apply pressure to enemies, suppress approaches, and create openings. Guns should differ by range, reload, target preference, heat, ammunition, and mount exposure rather than only damage per second.

### Workshops and recovery

Workshops repair modules, fabricate temporary parts, and turn salvage into useful components. They are strategically powerful because they improve recovery, but they consume interior space and become priority targets.

### Crew rooms and specialists

Crew rooms provide staffing and emergency capacity. Specialists alter one or two clear systems. For example, a Signal Officer increases forecast confidence, while a Forge Master improves repairs but increases charcoal use.

### Cargo and contracts

Cargo is not a fourth inventory board. It occupies reserved cells or external racks and creates route and contract decisions. A cargo crate may be worth selling, required for a settlement, or usable as emergency scrap.

## Threats

| Threat | Primary pressure | Counterplay |
|---|---|---|
| **Road Raiders** | Steal cargo and attack access hatches. | Protect access, keep a reserve crew, and avoid carrying all value on the exterior. |
| **Climbers** | Bypass the front and attack mounts or upper crew stations. | Signal coverage, interior response, wall lamps, and controlled access. |
| **Burrowers** | Surface near engines, workshops, and lower hull seams. | Spread critical systems, reinforce the floor, and maintain repair capacity. |
| **Storm Fronts** | Reduce visibility, increase heat, and damage exposed systems. | Weather preparation, covered mounts, low-heat operation, and route detours. |
| **Siege Beasts** | Deal area damage to armor and adjacent modules. | Avoid brittle clusters, use sacrificial plates, and preserve recovery routes. |
| **Rival Fortresses** | Attack the player’s most valuable dependency. | Build redundancy and choose a doctrine that protects the actual weakness. |

Threats should be forecast by intent and confidence. The game can surprise the player about exact timing or secondary targets, but not about the existence of a counterable pressure.

## Progression

Persistent progression is represented by the **March Charter**, a network of settlements that remembers what the fortress did and offers new possibilities.

| Track | Unlocks | Does not do |
|---|---|---|
| **Engineering** | Joints, armor patterns, repair cranes, modular generators. | Does not remove weight or damage entirely. |
| **Cartography** | Safer routes, weather forecasts, salvage sites, alternate contracts. | Does not reveal every encounter. |
| **Diplomacy** | Settlement contracts, neutral escorts, faction access. | Does not make factions universally friendly. |
| **Crew Trust** | Specialist pairs, emergency commands, personal missions. | Does not turn the crew into passive stat bonuses. |

Within a run, salvage and contract rewards should unlock temporary modules, temporary crew positions, and refit opportunities. A player who loses a weapon should still be able to pursue a repair, cargo, escort, or alternate route.

## Campaign structure

The campaign is organized into five regional chapters:

1. **The Road Out:** establish the fortress, learn the chassis, and deliver a first contract.
2. **The Broken Relay:** choose whether to repair a communication network or rush through a dangerous gap.
3. **The Ash Meridian:** weather and Burrowers force a redesign around movement and recovery.
4. **The Weight of Shelter:** the fortress carries refugees or strategic cargo, making space a moral and logistical decision.
5. **The Last March:** a rival fortress or Siege Beast tests whether the player built a machine that can survive without one perfect dependency.

The endings should reflect the player’s operating philosophy: a fast convoy, a fortified refuge, a trusted network, or a scarred but surviving machine.

## Vertical slice

The first slice should be deliberately small:

| Area | Scope |
|---|---|
| Chassis | 6-by-4 grid with two exterior mounts. |
| Modules | Four families and sixteen modules. |
| Routes | Three routes: safe long road, exposed shortcut, and salvage detour. |
| Settlements | Two settlements with repair, trade, contract, and recruit options. |
| Threats | Raiders, Climbers, Burrowers, one Storm Front, and one Siege Beast. |
| Interventions | Shift Power, Seal Compartment, Vent Heat, Cut Loose Cargo. |
| Run | Five encounters with one recoverable failure and one final decision. |
| Presentation | One clear fortress scene, one route scene, and one readable combat timeline. |

## Quality tests

The simulation should have deterministic tests for:

- Valid and invalid module placement.
- Rotation and shape occupancy.
- Connection and dependency detection.
- Mass, power draw, heat, fuel, and travel calculations.
- Damage propagation and isolated module failure.
- Threat target selection under a fixed seed.
- Each emergency intervention and its resource cost.
- Recoverable failure and settlement repair.
- Save/load round trips.
- Identical state and outcome under repeated fixed-seed runs.

## Anti-patterns

Do not create a large board where a mathematically dominant layout is obvious. Do not add several hidden currencies. Do not make the best weapon always the heaviest weapon. Do not make every enemy attack the nearest module. Do not let the player lose without a post-battle explanation or recovery option. Do not add a second full crew inventory until the primary chassis space is already compelling.

## Expanded design package

The production-facing facility catalog, dependency web, operating budgets, staffing model, damage states, and building progression are specified in [`fortress_facilities_and_mechanics.md`](fortress_facilities_and_mechanics.md). The FTL-like overland node map, visibility bands, closure-pressure clock, five regions, settlement services, and route archetypes are specified in [`map_regions_and_settlements.md`](map_regions_and_settlements.md). The expanded crew, rival characters, factions, campaign tendencies, regional arcs, and character-driven contracts are specified in [`characters_factions_and_campaign.md`](characters_factions_and_campaign.md).

These documents are deliberately broader than the current vertical slice. The first playable implementation should keep the existing 6×4 chassis, two exterior mounts, three route choices, two settlements, five encounter scope, and deterministic simulation contract. New buildings, regions, and characters enter only through narrow tested slices.
