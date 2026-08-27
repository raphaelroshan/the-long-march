# The Long March — Initial Journey Test Release

## Purpose

This is an internal, testable alpha chapter for The Long March. It proves a five-encounter run from **Ashgate Depot** through a branching Ashgate Lowlands map, **Morrowline Camp**, and **Meridian Pass**, with dependency-driven refitting, incomplete route information, an optional contract and specialist, deterministic encounters, recoverable failure, settlement recovery, and explicit run results.

## Test flow

1. Start at Ashgate Depot with the prepared fortress modules visible in the chassis grid.
2. Select an installed module to move, rotate, or remove it. Select a module from the palette and click an empty cell to install it. Exterior-tagged modules consume one of two mount slots.
3. Confirm that invalid overlap, bounds, mass, and exterior-capacity placements show a blocked preview without changing the old layout.
4. Move the Coal Cell away from the Steam Lance Engine and confirm the engine turns offline; reconnect it before departure. Move the Ammunition Lift away from the weapon and confirm the weapon becomes strained rather than silently retaining full damage.
5. Accept or decline the **Morrowline Parts Guard**, then compare the known/forecast/unscouted information for **Rill Crossing** and **The Soot Orchard**.
6. Select a doctrine—protect cargo, protect crew, or run hot—and begin the first encounter. Refit controls lock during travel and battle.
7. Advance the battle one step at a time. Use **Shift power to weapons** once if the weapon system needs priority, then read the causal report.
8. Choose **Broken Relay** or **Red Wheel Toll Bridge** for the second encounter. Resolve the node decision and verify its money, trust, risk, or pressure consequence.
9. If the relay was restored, inspect Iven Pell's crew-space and supply requirements; recruit him when the build permits and confirm exact threat names replace broad forecasts.
10. Complete the Morrowline approach as encounter three. If the guard contract was accepted, confirm its extra endurance and the 30-Ashmark/two-trust payment.
11. At Morrowline, spend up to two service actions on module repair, hull repair, or fuel; refit and compare **Lower Ash Road** with **Signal Causeway**.
12. Complete the fourth encounter, then depart for **Meridian Pass** and resolve the fifth encounter against the Siege Beast.
13. Verify a **Decisive March**, **Scarred March**, or **March Failed** result and confirm the final summary includes path, pressure, contract, specialist, and surviving systems.
14. On another attempt, allow a non-final encounter to disable the engine or hull. Confirm the fortress retreats to the last secured node with stated time, money, and pressure costs instead of ending the run.
15. Save and load during a map decision or Morrowline recovery and confirm the graph position, phase, resources, module state, contract, specialist, pressure, damage, and reports are preserved.
16. Open **Playtest feedback** after the result, answer the two short prompts, and save the local JSON bundle if the tester agrees to share it.

The first-run Marchmaster briefing explains the complete loop, while the phase-specific NEXT line keeps guidance available without hiding the current state. The refit interaction remains the input foundation for the spatial engineering loop. Fuel, ammunition, crew, parts, power, and visibility dependencies are evaluated explicitly and displayed as ready, strained, or offline.

## Implemented units and behaviors

| Module | Behavior |
|---|---|
| Steam Lance Engine | Enables movement and represents the critical engine dependency targeted by Burrowers |
| Shell Cannon | Burst damage against Road Raiders and Siege Beasts; stronger when weapon priority is selected; increases heat |
| Field Workshop | Repairs the weakest damaged operational module after contact |
| Signal Coil | Reveals the encounter target class before contact |
| Existing modules | Generator, armor, cargo, crew, repeater, wall lamp, and other authored modules remain available to the original prototype APIs |

## Visual kit

The integrated kit includes a Long March visual reference, Ashgate journey background, Steam Lance Engine icon, Shell Cannon icon, Field Workshop icon, and Signal Coil icon. Each is original generated project content and is registered in `assets/ASSETS.md`. Enemy presentation remains procedural and uses readable threat labels and route markers in this first test slice.

## Scope boundaries

This release includes one authored FTL-like regional graph and one recruitable specialist. It does not include later regions, procedural map generation, a complete cargo economy, final sound, sprite animation, Steam/Epic adapters, or commercial storefront packaging. The chapter is intentionally deterministic and inspectable so agents and testers can tune the map loop before adding campaign breadth.
