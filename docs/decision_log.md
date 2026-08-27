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

## 2026-08-27 — Playtest guidance teaches causality, not a winning recipe

The first-run briefing explains dependencies, route commitments, encounter reading, intervention limits, and recovery. A short phase-specific NEXT line remains visible after onboarding, but it does not prescribe a layout or route. Testers can reopen the briefing at any time, and completion is remembered locally.

## 2026-08-27 — Feedback collection is local and explicit

The prototype records a small local journal of gameplay decisions and outcomes. It contains no account, machine identifier, analytics SDK, or network upload. A tester may add two written answers and a replay score, then explicitly save a JSON bundle and decide whether to share it. This gives early playtests enough causal context without building production telemetry before consent and retention policies exist.

## 2026-08-27 — Tagged playtests produce desktop artifacts

Windows remains the primary product target. The repository also provides an unsigned macOS playtest preset so development sessions can run on the current platform. Tagged GitHub Actions runs build both artifacts; signing, notarization, Steam, and Epic publishing remain human-controlled release steps.

## 2026-08-27 — The alpha chapter is an authored five-encounter graph

The two-leg prototype is superseded by the Ashgate Lowlands alpha chapter. Every completed path now contains five encounters across an authored branching graph, with Morrowline as the guaranteed recovery settlement and Meridian Pass as the declared final commitment. Authored structure was chosen over procedural generation so pacing, route guarantees, content consequences, and deterministic tests remain legible while the core map loop is being proven.

## 2026-08-27 — Visibility is a promise, not cosmetic fog

Known nodes reveal exact threats, forecast nodes reveal hazard class and pressure, and unscouted nodes reveal only a broad warning. Reliable signal support or Iven Pell upgrades immediate information and reduces risk. The interface must not leak exact threat composition through labels, tooltips, or disabled controls when a node is unscouted.

## 2026-08-27 — Closure pressure removes advantage, not progression

Watch, Closing, and Break are visible regional pressure bands. At Break, the optional Signal Causeway may close without reliable forecasting, but Lower Ash Road remains available. This establishes the campaign rule that time pressure can remove a safer or more informative option but cannot silently delete the only recovery or progression route.

## 2026-08-27 — Contracts and specialists alter operating decisions

The first guard contract deliberately increases Morrowline encounter endurance in exchange for money and trust. Iven Pell requires a repaired relay, operational crew space, and supplies; in return he improves forecasts, storm mitigation, and late-route access. Both systems change loadout, route, and economy decisions rather than existing as dialogue-only rewards.

## 2026-08-27 — Non-final defeat retreats to a viable state

A failed regional encounter returns the fortress to its last secured node with explicit time, money, and pressure penalties. A road crew restores only enough hull, fuel, engine, and fuel-module durability to make another decision possible. Meridian Pass remains a hard endpoint because it is presented as the chapter's final commitment; earlier failures remain recoverable and retain their consequences.

## 2026-08-27 — The campaign map is an interactive graph

The alpha presents the entire regional route graph instead of reducing each choice to a list. Node labels and borders distinguish current, secured, available, decision-blocked, closed, and future states; color is supporting information rather than the only signal. Route details update on both pointer hover and keyboard/controller focus, and only immediately reachable nodes accept input.

Route selection and departure are separate actions. Selecting a node highlights the road and preserves the current state while the player reviews time, fuel, risk, pressure, visibility, and doctrine. A dedicated commit control begins travel, preventing accidental departures and making controller navigation predictable.

## 2026-08-27 — Combat presents causes before spectacle

The alpha battle view uses enemy cards, arrival timing, target labels, counters, a six-step timeline, and the latest causal report lines. Targeted modules receive a visible chassis outline and every module shows durability. Emergency orders state both their benefit and cost. Animation and effects should reinforce this information later rather than replace it.
