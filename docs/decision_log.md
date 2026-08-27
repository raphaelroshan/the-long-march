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

## 2026-08-27 — Refit uses select-and-place actions

The first interactive refit uses the same deterministic placement commands for mouse, keyboard, and controller input. The player selects a module, previews a green or red footprint, confirms an empty cell to place or move it, and uses explicit rotate and remove actions. Invalid moves are atomic: the installed module stays in its prior position. Refit locks after departure so battle state cannot be altered through the presentation layer.

The starter palette exposes one instance of each vertical-slice module. Exterior-tagged modules automatically consume one of two exterior mounts and retain a bright chassis edge in this prototype. Dedicated exterior-slot presentation and dependency effects remain later slices.

## 2026-08-27 — Dependencies use readable adjacency plus a shared power bus

The first dependency graph uses orthogonal adjacency for fuel-to-engine, ammunition-to-weapon, crew-to-workshop, parts-to-workshop, and interior-signal-to-exterior-visibility relationships. Power remains a shared visible budget because the design explicitly rejects a full wiring puzzle at this stage.

A missing hard dependency makes a module offline when it cannot perform its core job, such as an engine without fuel or a workshop without crew. A missing soft dependency makes it strained, such as a weapon using emergency ammunition or a workshop applying a limited patch without parts. The chassis renders these states and exposes their reasons so layout consequences are not hidden.

## 2026-08-27 — Routes and doctrines must change outcomes

Route risk now combines authored route danger with mass, heat, and signal readiness. Heavy fortresses consume extra fuel, Run Hot increases pressure and thermal damage, and a ready signal system can reduce uncertainty. Protect Cargo and Protect Crew redirect defensive effort toward their named obligations rather than acting as flavor text. Vent Heat lowers current heat but temporarily exposes exterior systems.

## 2026-08-27 — Spatial targeting and armor produce causal reports

Threats score targets using module role, exterior exposure, chassis row, durability, and the active doctrine. Adjacent armor can absorb part of an attack, and the battle report records downstream dependency changes when damage disables fuel, ammunition, crew, power, repair, or visibility relationships.

## 2026-08-27 — The prototype run ends at Meridian Pass

The focused prototype is a two-leg run: Ashgate to Morrowline, two limited settlement service actions plus refitting, then a final Siege Beast encounter at Meridian Pass. This is intentionally smaller than the five-region campaign but large enough to prove preparation, consequence, recovery, adaptation, and a final result.

## 2026-08-27 — Saves use an explicit schema and JSON-safe positions

Prototype saves include a schema version and serialize grid positions as integer pairs rather than engine-specific Variant strings. Newer unsupported save versions fail safely. The verification suite performs a real JSON save/load during the UI-level complete-run test.

The prototype also treats the starter palette as a finite inventory. Removing a module returns that same instance to storage with its durability intact; it does not create a fresh replacement or erase battle damage. This keeps refitting tactically useful without turning it into a free repair exploit.
