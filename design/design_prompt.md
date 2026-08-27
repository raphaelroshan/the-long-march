# The Long March — Agent-First Design Prompt

## Product identity

**The Long March** is a premium single-player Windows desktop strategy roguelite about operating a mobile fortress across a ruined continent. The fortress is a physical machine: its chassis, engines, weapons, workshops, crew rooms, cargo, and exterior mounts form a constrained spatial loadout. Battles resolve automatically, but the player controls the design, route, power priorities, target doctrine, and emergency interventions that determine whether the machine survives.

The game should feel like **a moving stronghold that must keep its promises**. It is not a generic backpack with a fortress skin. Space represents engineering: fuel must reach engines, ammunition must reach guns, workshops must reach repair points, signal equipment must see the road, and armor must be placed where it can buy time without immobilizing the entire vehicle.

The game is designed for Steam and Epic Games Store on Windows using Godot 4.x and GDScript. It is a single-player product with deterministic simulation, authored campaign scenarios, controller and keyboard/mouse support, cloud-safe saves, and a thin storefront adapter that remains outside the simulation layer.

## Central promise

The player should repeatedly make a decision of the following form:

> “This module is powerful, but where can I place it so that its benefit reaches the rest of the fortress without creating a fatal dependency?”

The player should understand why the fortress succeeded or failed. A battle result must explain whether the decisive problem was insufficient power, poor placement, an exposed module, weak route posture, bad target priority, heat overload, a missing crew role, or an unprotected dependency.

## Core loop

The campaign loop has seven steps:

1. **Choose a contract or route.** Settlements offer evacuation, escort, salvage, repair, supply, and intelligence contracts. The route preview shows terrain, weather, likely threats, distance, and reward.
2. **Refit the fortress.** Buy, salvage, install, rotate, remove, and connect modules in the chassis grid and exterior mounts.
3. **Assign operating priorities.** Choose power priority, target doctrine, travel posture, crew stations, and an emergency order.
4. **Travel.** The fortress advances through a short deterministic route with authored encounters and bounded uncertainty.
5. **Resolve encounters.** The battle or hazard runs automatically. The player may use limited interventions such as sealing a compartment, shifting power, venting heat, cutting loose cargo, or ordering a crew shift.
6. **Recover and trade.** At a settlement or salvage site, repair, sell, store, replace, recruit, accept a contract, or continue.
7. **Advance the March Charter.** Persistent progression unlocks new chassis pieces, routes, crew backgrounds, contracts, and doctrines. It should expand decisions rather than erase risk.

## Non-negotiable design constraints

The fortress must remain mobile. A perfect static build is a failure of the concept. Every strong module must create a visible cost in weight, heat, fuel, repair, crew, space, exposure, or opportunity cost.

The inventory must be readable. The first vertical slice should use a small grid, four module families, two exterior mounts, three enemy doctrines, and one boss. Do not add a second full inventory board for crew until the chassis loop proves fun.

Auto-combat must remain legible and interactive. The player does not manually aim every shot, but makes pre-resolution commitments and limited emergency interventions. Every battle exposes a timeline and causality report.

Persistent progression must not become a stat treadmill. Unlocks should make a new build or route possible, not simply provide more health or damage.

The game must support recovery. Losing a module, cargo, or route should create a new problem, not silently end the campaign. A damaged fortress can limp to a settlement, sell cargo, accept a lower-value contract, or rebuild around a different doctrine.

## Vertical slice

The first playable slice should include:

- A 6-by-4 chassis grid.
- Two exterior mount slots.
- Four module families: engine, weapon, workshop, and crew room.
- Sixteen modules with shape, mass, power draw, heat, durability, and tags.
- Three enemy doctrines: Road Raiders, Climbers, and Burrowers.
- One storm hazard and one Siege Beast boss.
- Two settlements and three route choices.
- One recruitable specialist and one guard contract.
- Four battle interventions: shift power, seal compartment, vent heat, and cut loose cargo.
- One complete five-encounter run with a recoverable failure state.
- A deterministic headless test suite covering placement, connections, travel, damage, power, heat, interventions, save/load, and outcome reproducibility.

## Tone and art direction

The visual direction is 2D-ish illustrated industrial fantasy: rusted plates, painted convoy markings, canvas, ash-stained steel, hand-written maintenance notes, and warm settlement lights against a pale hostile horizon. The fortress should be visually understandable as a layered machine. The player should recognize engines, lifts, workshops, crew rooms, and gun mounts at a glance.

Tone is humane, melancholy, and practical. The fortress carries families, tools, spare parts, and obligations. Avoid grimdark cruelty for its own sake. The story is about keeping a moving network alive when every route is a compromise.

## Agent operating rules

Agents must read `AGENTS.md`, this prompt, `design/gameplay_framework.md`, and the relevant content manifest before changing simulation code. They should work in narrow slices: one module family, one enemy doctrine, one route encounter, one intervention, or one UI panel at a time.

Simulation must remain presentation-independent. The core state should not import UI nodes or depend on frame timing. New features require deterministic tests and a serialized state update. Content belongs in `content/`; runtime logic belongs in `src/core/`; presentation belongs in `src/ui/` and `scenes/`.

Agents must preserve stable IDs in content files. They must not encode executable logic in narrative strings. Requirements and effects are data until explicit runtime commands map them to state changes.

## Initial implementation order

1. Validate the basic chassis grid, module placement, and connected dependency graph.
2. Add power, heat, durability, and movement cost calculations.
3. Add automatic threat resolution with a visible event log.
4. Add the four emergency interventions and one recoverable failure state.
5. Add route selection, settlement recovery, and contract rewards.
6. Add authored modules, crew hooks, and campaign progression only after the core simulation is stable.
