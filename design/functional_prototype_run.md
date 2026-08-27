# Functional Prototype Run

## Purpose

This document defines the implemented prototype boundary. It is narrower than the full five-region campaign, but it must prove the complete decision loop: configure a moving fortress, accept a route trade-off, understand an automatic battle, recover from damage, adapt the layout, and survive a final test.

## Run structure

1. **Ashgate refit** — arrange one copy of each available prototype module on the 6×4 chassis, respecting mass, overlap, rotation, and two exterior mounts.
2. **First route** — choose the Long Road, Exposed Cut, or Salvage Detour and one doctrine: Protect Cargo, Protect Crew, or Run Hot.
3. **Road encounter** — resolve the forecast one step at a time and spend at most one intervention.
4. **Morrowline recovery** — use up to two paid service actions, refit freely, and choose the final doctrine.
5. **Meridian Pass** — survive or defeat a Siege Beast and Climber attack.
6. **Results** — receive a Decisive March, Scarred March, or March Failed result with the causal battle record preserved.

## Dependency rules

- Engines require an orthogonally adjacent fuel module.
- Weapons without an adjacent Ammunition Lift remain operational but use weaker emergency ammunition.
- Workshops require adjacent Crew Quarters; adjacent Parts Crates improve repair output.
- Powered modules use the shared power budget. This prototype does not implement manual wiring.
- Interior signal equipment needs an adjacent operational exterior signal source to provide an exact target forecast.

Modules show **ready**, **strained**, or **offline** state. Damage must update related modules immediately and add a dependency-change line to the encounter report.

## Route and doctrine contract

- **Long Road** has the lowest pressure and is the teaching route.
- **Exposed Cut** saves time but strengthens the mixed Raider/Climber encounter.
- **Salvage Detour** tests lower-hull and engine redundancy against a Burrower.
- A near-capacity fortress consumes additional fuel.
- A ready signal system reduces route pressure.
- **Protect Cargo** improves fire against Raiders and mitigates cargo damage.
- **Protect Crew** improves fire against Climbers and the Siege Beast and mitigates crew damage.
- **Run Hot** increases weapon output and encounter pressure; unresolved overheat damages the hull.

## Recovery contract

Morrowline provides two service actions. Each module repair restores up to two durability for four Ashmarks per point. Refueling adds two fuel for eight Ashmarks. Hull repair restores two hull for ten Ashmarks. Refit actions do not consume service actions.

The final march may begin without spending both actions, but it requires an operational fuel-connected engine and sufficient fuel.

## Definition of functional

The prototype is functional when a fresh clone can run the automated verification script and a player can complete the entire run using only visible UI controls. At least one route/doctrine combination must succeed, at least one must create recoverable damage or retreat, placement must change outcomes, JSON save/load must preserve mid-run state, and the final screen must report the run result.
