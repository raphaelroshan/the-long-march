# The Long March — Initial Journey Test Release

## Purpose

This is an internal, testable vertical slice for The Long March. It proves one authored journey from **Ashgate Depot** to **Morrowline Camp**, with a route choice, a deterministic road encounter, distinct mobile-fortress module behaviors, an intervention window, and explicit arrival or forced-retreat outcomes.

## Test flow

1. Start at Ashgate Depot with the prepared fortress modules visible in the chassis grid.
2. Select an installed module to move, rotate, or remove it. Select a module from the palette and click an empty cell to install it. Exterior-tagged modules consume one of two mount slots.
3. Confirm that invalid overlap, bounds, mass, and exterior-capacity placements show a blocked preview without changing the old layout.
4. Move the Coal Cell away from the Steam Lance Engine and confirm the engine turns offline; reconnect it before departure. Move the Ammunition Lift away from the weapon and confirm the weapon becomes strained rather than silently retaining full damage.
5. Choose **The Long Road**, **The Exposed Cut**, or **The Salvage Detour**.
6. Select a journey doctrine: protect cargo, protect crew, or run hot.
7. Depart and read the forecast. Refit controls lock once the fortress leaves Ashgate.
8. Advance the journey battle one step at a time. Use **Encounter: Shift Power** once if the weapon system needs priority.
9. Read the report to see which module behaved, which enemy was targeted, and which module or hull section was damaged.
10. Verify that the fortress reaches Morrowline Camp, arrives damaged, or returns to Ashgate Depot after a forced retreat.

The refit interaction is the input foundation for the spatial engineering loop. Fuel, ammunition, crew, parts, power, and visibility dependencies are now evaluated explicitly and displayed as ready, strained, or offline. More complex facility bonuses and chain-damage rules remain later slices.

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

This release does not include the full FTL-like node map, multiple settlement service screens, recruitment, a complete cargo economy, procedural map generation, final sound, sprite animation, controller navigation, Steam/Epic adapters, or commercial storefront packaging. The battle is intentionally deterministic and inspectable so agents and testers can tune the core loop before adding campaign breadth.
