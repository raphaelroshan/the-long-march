# The Long March — Fortress Facilities and Interacting Mechanics

## Design goal

The fortress should feel like a **small town, workshop, and weapon system forced to remain in motion**. Buildings are not simply slots that add numbers. Each one solves a practical problem while creating a dependency, a vulnerability, or a social obligation. The player should be able to explain the fortress in one sentence: “We are a fast convoy with a vulnerable workshop,” or “We are a slow refuge with redundant power and too much cargo.”

The first implementation should use the 6×4 chassis grid plus two exterior mounts already defined in the prototype. The facility catalog below is the production-facing plan; the vertical slice should implement only the bolded core buildings and use the rest as authored future content.

## Facility taxonomy

| Facility | Core job | Main benefit | Main cost or risk | Typical counters |
|---|---|---|---|---|
| **Boiler Heart** | Primary engine | Enables movement and route access | Heat, fuel demand, Burrower vulnerability | Fuel store, lower-hull armor, venting |
| **Ash Runner Drive** | Fast engine | Shortens travel and improves escape odds | High heat and low durability | Cooling, spare drive, conservative posture |
| **Generator Core** | Power generation | Sustains weapons, signals, workshops, and life support | Mass and critical-failure risk | Redundant generator, protected placement |
| **Coal Bunker** | Fuel storage | Extends range and supports engines | Fire risk and cargo space | Separation, firebreak, cut-loose order |
| **Ammunition Lift** | Weapon logistics | Connects guns to internal ammunition | Occupies a vertical corridor; failure disables guns | Redundant small arms, protected lift |
| **Shell Cannon** | Heavy weapon | High burst damage against beasts and fortresses | Exterior exposure, heat, ammunition | Climbers, storms, armor trade-off |
| **Repeater Gallery** | Suppression | Controls raiders and climbers reliably | Lower peak damage; needs crew and ammunition | Power priority, sabotage, low ammo |
| **Field Workshop** | Recovery | Repairs modules and converts salvage | Consumes space, parts, and crew time | Burrowers, workshop guard, spare parts |
| **Salvage Crane** | Recovery and cargo | Recovers more from sites and can manipulate heavy objects | Exterior mount and slow travel | Storm cover, crane brace |
| **Signal Mast** | Forecasting | Reveals threat family, route weather, and settlement requests | Exterior exposure; broadcasts the fortress | Climbers, storm, signal discipline |
| **Relay Coil** | Shared information | Improves forecast confidence and faction trust | Consumes power and may reveal position | Silence posture, alternate signal routes |
| **Crew Quarters** | Life support | Houses specialists and creates command capacity | Power draw and vulnerable occupants | Armor, evacuation drill |
| **Infirmary** | Crew recovery | Converts medical stores into wound recovery | Cannot repair machines; takes valuable space | Apothecary supply, triage event |
| **Command Deck** | Doctrine | Adds a second intervention or target priority | High-value target; requires trusted crew | Climbers, morale pressure |
| **Cargo Hold** | Contracts and trade | Carries settlement goods, refugees, and salvage | Mass, raider incentive, slower unloading | Escort, hidden compartments, sacrifice |
| **Refugee Berths** | Human capacity | Unlocks shelter and evacuation contracts | Occupies space and changes moral stakes | Shelter supplies, route safety |
| **Water Condenser** | Sustain | Reduces supply drain and enables arid routes | Heat and maintenance | Storm capture, workshop repair |
| **Firebreak Bulkhead** | Damage containment | Prevents adjacent chain failures | No direct output; divides usable space | Seal orders, crew access |

## The facility dependency web

The game should model a small number of strong dependencies rather than dozens of hidden modifiers.

```text
Fuel Store ──> Boiler Heart ──> Movement ──> Route access
                  │                 │
                  v                 v
              Heat load       Travel posture

Generator ──> Power Bus ──> Weapons / Signals / Workshop / Life Support
    │             │              │          │          │
    v             v              v          v          v
  Mass        Priority       Ammunition  Forecast   Specialists

Workshop ──> Repair ──> Condition ──> Facility output ──> Recovery choices

Cargo / Refugees ──> Contracts and trust ──> Route obligations ──> Threat exposure
```

A failure should travel through this graph in a readable way. A Burrower that damages the Boiler Heart does not merely remove 10% movement. It increases travel time, consumes more fuel per day, delays a contract, and makes the next settlement harder to reach. The UI should present this as a causal chain.

## Spatial building rules

The player should arrange facilities according to physical relationships:

| Relationship | Benefit | Trade-off |
|---|---|---|
| Boiler Heart beside Coal Bunker | Efficient fuel transfer and one less crew action | A hit risks fire in both spaces |
| Generator close to Command Deck | Faster power reprioritization | A single breach can remove power and command |
| Ammunition Lift behind Firebreak Bulkhead | Protects the reload corridor | Adds distance and can slow emergency access |
| Workshop beside exterior mount | Faster repairs to guns, mast, or crane | The workshop becomes a predictable enemy target |
| Signal Mast above Command Deck | Better forecast confidence | Concentrates valuable systems on the exposed roof |
| Crew Quarters behind armor | Reduces specialist injury | Armor increases mass and reduces cargo capacity |
| Refugee Berths beside Infirmary | Better recovery and settlement trust | The fortress has a larger human supply burden |
| Cargo Hold near access hatch | Faster unloading and trade | Raiders can reach it before the crew responds |
| Firebreak Bulkhead between critical rooms | Contains area damage | Consumes cells and makes the fortress less flexible |

## Operating budgets

The fortress should have five visible budgets. A sixth, **trust**, is social rather than physical.

| Budget | What it measures | How it is spent | How the player recovers |
|---|---|---|---|
| **Power** | Whether installed systems can operate together | Weapons, signals, workshop, life support | Shut down systems, add generators, change priority |
| **Heat** | How close the machine is to an unsafe operating state | Engines, guns, condenser, volatile salvage | Vent, slow down, repair, discard fuel or cargo |
| **Mass** | Whether the fortress can move efficiently | Armor, generators, cargo, berths | Sell, cut loose, reshape, accept slower routes |
| **Condition** | How much useful life remains in a facility | Enemy hits, storms, overheat, poor repairs | Workshop, settlement repair, spare modules |
| **Crew capacity** | Whether specialists can staff critical facilities | Command, workshop, signals, infirmary | Recruit, cross-train, protect quarters |
| **Trust** | Whether settlements and crew will offer better options | Broken contracts, selfish choices, abandoned people | Fulfill promises, share warnings, rescue, repair |

The intended design is that no budget is always the correct one to maximize. A low-mass fortress may lack the armor to protect refugees. A high-trust fortress may broadcast its location. A cool fortress may be too slow to meet a contract.

## Crew and facility staffing

Crew should be a light assignment layer, not a second inventory. Each specialist has one primary facility and one personal pressure. A facility works at baseline without a specialist where possible, but staffing unlocks a specific behavior and creates an emergency choice when that person is wounded.

| Specialist | Primary facility | Mechanical signature | Personal pressure |
|---|---|---|---|
| **Mara Flint** | Field Workshop | Repairs one additional condition or salvages a broken module | Refuses wasteful sacrifice |
| **Iven Pell** | Signal Mast | Raises forecast confidence and shares route warnings | Wants information made public |
| **Sela Vonn** | Command Deck | Makes rush and detour postures more predictable | Pushes speed even when repair cost rises |
| **Tomas Reed** | Cargo Hold | Improves trade and protects one contract item | Sees every person as a negotiable obligation |
| **Dr. Nera Quill** | Infirmary | Converts supplies into crew recovery | Will prioritize civilians over machinery |
| **Orris Vale** | Boiler Heart | Reduces fuel waste on long routes | Hides early signs of engine failure |

## Damage and recovery states

Every major facility has four condition states: **ready**, **strained**, **disabled**, and **breached**. A strained facility still works with a visible cost. A disabled facility stops its benefit but may be repaired. A breached facility creates a secondary hazard until sealed or abandoned.

The player should usually have three recovery choices: spend time and parts, spend money and trust at a settlement, or sacrifice a different resource to keep moving. Hard failure should be rare and clearly authored.

## Building progression

Persistent progression should unlock **new relationships**, not merely stronger buildings. Examples include a modular Coal Bunker that can be split into two safer cells, a signal mast that can broadcast public warnings, a workshop crane that repairs exterior modules, and a refugee berth that can convert to cargo or infirmary space between journeys. Every unlock should create at least one new layout question.

## Future systems deliberately excluded

The project should not add a full power-grid wiring puzzle, individual crew hunger simulation, a freeform interior construction editor, or a separate housing inventory during the first production milestone. Those systems may be explored after the core building dependency loop produces readable victories and defeats.
