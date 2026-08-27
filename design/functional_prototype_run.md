# Functional Prototype Run

## Purpose

This document defines the implemented alpha-prototype boundary. It is narrower than the full five-region campaign, but it proves a complete regional loop: configure a moving fortress, read a branching map, accept a contract or local trade-off, understand automatic battles, recover from damage, adapt the layout, and survive a final test.

## Run structure

1. **Ashgate refit and contract** — arrange the 6×4 chassis, then accept or decline the Morrowline Parts Guard.
2. **Opening route** — choose Rill Crossing or The Soot Orchard and one doctrine: Protect Cargo, Protect Crew, or Run Hot.
3. **Regional branch** — continue through Broken Relay or Red Wheel Toll Bridge and resolve its local decision.
4. **Morrowline approach and recovery** — complete the third encounter, resolve the guard contract, use up to two paid service actions, and refit freely.
5. **Closing road** — choose Lower Ash Road or Signal Causeway while reading the visible closure-pressure band.
6. **Meridian Pass** — complete the fifth encounter against the Siege Beast and receive a Decisive March, Scarred March, or March Failed result.

## Dependency rules

- Engines require an orthogonally adjacent fuel module.
- Weapons without an adjacent Ammunition Lift remain operational but use weaker emergency ammunition.
- Workshops require adjacent Crew Quarters; adjacent Parts Crates improve repair output.
- Powered modules use the shared power budget. This prototype does not implement manual wiring.
- Interior signal equipment needs an adjacent operational exterior signal source to provide an exact target forecast.

Modules show **ready**, **strained**, or **offline** state. Damage must update related modules immediately and add a dependency-change line to the encounter report.

## Map, visibility, and doctrine contract

- Every successful path contains five encounters and passes through Morrowline Camp.
- Nodes expose known, forecast, or unscouted information. Ready forecasting or Iven Pell reveals exact immediate threats and reduces risk.
- Closure pressure is always visible as Watch, Closing, or Break. It may close Signal Causeway but never the only remaining forward route.
- Rill is the clearest opening; Soot trades safety for fuel or a worker rescue; Broken Relay enables Iven; Red Wheel offers a money-versus-pressure decision.
- Lower Ash Road tests lower-hull and engine redundancy against a Burrower. Signal Causeway rewards forecasting and storm mitigation.
- A near-capacity fortress consumes additional fuel.
- **Protect Cargo** improves fire against Raiders and mitigates cargo damage.
- **Protect Crew** improves fire against Climbers and the Siege Beast and mitigates crew damage.
- **Run Hot** increases weapon output and encounter pressure; unresolved overheat damages the hull.

## Recovery contract

Morrowline provides two service actions. Each module repair restores up to two durability for four Ashmarks per point. Refueling adds two fuel for eight Ashmarks. Hull repair restores two hull for ten Ashmarks. Refit actions do not consume service actions. A completed guard contract pays 30 Ashmarks and two trust.

A non-final defeat retreats to the last secured node with time, money, and pressure penalties plus a minimal engine, fuel, and hull patch. The final march may begin without spending both Morrowline actions, but it requires an operational fuel-connected engine and sufficient fuel.

## Definition of functional

The prototype is functional when a fresh clone can run the automated verification script and a player can complete all five encounters using only visible UI controls. Branching, visibility, pressure closure, the guard contract, Iven recruitment, local decisions, and recoverable retreat must be deterministic and serializable. At least one route/doctrine combination must succeed, at least one must create recoverable damage or retreat, placement must change outcomes, and the final screen must report the run result.

The detailed first-region contract is in [`ashgate_lowlands_alpha.md`](ashgate_lowlands_alpha.md).
