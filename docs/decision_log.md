# Decision Log — The Long March

## 2026-08-27 — Fourth project direction

We selected the walking-fortress inventory auto-battler as the fourth game target and kept the dungeon-and-shop inventory battler as a separate follow-up concept. The fortress has a clearer visual identity and a stronger reason for spatial inventory rules to exist.

## 2026-08-27 — One primary inventory space

The first prototype uses one chassis grid plus a small number of exterior mounts. A second full crew inventory was rejected for the vertical slice because it would create bookkeeping before the chassis dependency loop is proven.

## 2026-08-27 — Auto-battle with limited intervention

Combat resolves automatically, but the player sets power priority, target doctrine, travel posture, and one or more emergency orders. Direct unit control was rejected because it would move the project toward an action or real-time tactics game and weaken the packing decision.

## 2026-08-27 — Mobility as a hard constraint

The fortress must keep moving. A static high-durability build cannot be the universal strategy. Weight, fuel, route timing, heat, and repair cost remain meaningful even when the player has strong modules.

## 2026-08-27 — Recovery over hard failure

A damaged fortress can lose cargo, modules, time, or route access and still reach a settlement, repair, salvage, or accept a lower-value contract. Hard failure is reserved for an explicitly explained collapse state.

## 2026-08-27 — Content and runtime separation

`content/` contains authored IDs, descriptions, events, and progression. `src/core/` contains explicit simulation commands. Narrative strings are never executable scripts.

## 2026-08-27 — Facilities are dependency machines

The expanded building catalog treats facilities as interacting systems rather than passive bonuses. Boiler Heart, Generator Core, Ammunition Lift, Workshop, Signal Mast, Crew Quarters, Cargo Hold, Refugee Berths, and Firebreak Bulkhead create readable benefits and vulnerabilities. The production catalog is broader than the first slice; each future facility must enter through a narrow implementation and test.

## 2026-08-27 — FTL-like route map adapted to an overland march

The campaign map uses authored branching nodes with known, forecast, and unscouted visibility. A visible regional closure-pressure clock changes optional routes without deleting the only recovery path. This preserves route tension while keeping campaign balance and narrative guarantees under authorial control.

## 2026-08-27 — Regions are mechanical teaching chapters

The Ashgate Lowlands teach speed and cargo, the Flooded Veyru teaches condition and information, the Cinder Spine teaches heat and repair, the White Salt Expanse teaches visibility and trust, and the Meridian Refuge Corridor tests the player’s operating philosophy. Each region has settlements, route archetypes, a pressure source, and a boss gate.

## 2026-08-27 — Characters create legitimate conflicts

Crew members and factions are defined by a useful specialty, a belief about the fortress, and a pressure that competes with another valid priority. Mara, Iven, Sela, Tomas, Nera, and Orris form the core crew; Eda, Caldus, Jun, Anika, and Ravel extend the campaign. Character arcs must alter facilities, routes, contracts, or endings rather than only add dialogue.
