# Ashgate Depot → Morrowline Camp: initial journey battle

## Purpose

This slice turns The Long March from a fortress-loadout shell into a small, testable journey. The fortress departs **Ashgate Depot**, travels through the Ashgate Lowlands, and reaches **Morrowline Camp** after one authored road encounter. The player prepares the moving fortress, chooses a route posture, watches the threat approach, and uses a limited intervention before the automatic battle resolves.

The slice is intentionally small. It proves that the game’s spatial fortress identity survives contact with an encounter without adding a full campaign map, procedural generation, recruitment economy, or storefront integrations.

## Journey contract

| Stage | Player-facing question | Runtime result |
|---|---|---|
| Ashgate Depot | What can the fortress carry into the road? | Starter modules are visible; player may choose a route posture and target doctrine |
| Departure | Is the safe road worth the extra day, or is the exposed cut worth the risk? | Fuel and day cost are paid; an encounter forecast is generated deterministically |
| Road encounter | Which unit behavior answers the threat? | Threats advance through approach, contact, and resolution steps |
| Morrowline Camp | Did the fortress arrive with enough cargo and hull to help the convoy? | Success grants money and camp access; damage opens repair/cargo tradeoffs |

The initial playable journey uses `ashgate_depot`, `rill_crossing`, and `morrowline_camp` as authored nodes. The safe road travels through Rill Crossing and produces a manageable **Road Raider** encounter. The exposed cut skips the crossing, costs one day, and produces a harder mixed encounter. The salvage detour remains available as a preview route but is not required to complete the first test.

## Battle model

The battle is deterministic from the campaign seed, route ID, journey day, and selected target doctrine. It resolves in six readable steps. The player can advance one step at a time and use one intervention per encounter while the threat is active.

1. **Forecast:** the player sees the principal threat family and a broad target class.
2. **Approach:** enemies move toward the fortress; signal units can reveal exact targets.
3. **Contact:** the first enemy reaches its preferred module tag.
4. **Intervention:** the player may Shift Power, Seal Compartment, Vent Heat, or Cut Loose Cargo.
5. **Adaptation:** active units use their authored behavior against valid targets, with counters receiving bonuses.
6. **Outcome:** the convoy is protected, damaged, or the fortress is forced to retreat.

## Units and behaviors

| Unit/module | Behavior | Counter relationship |
|---|---|---|
| Steam Lance Engine | Generates movement momentum; when prioritized for engines, it reduces the next route’s threat pressure | Protects the journey, but becomes a Burrower target |
| Shell Cannon | Fires a burst at the leading hostile contact; strong against Road Raiders and Siege Beasts | Needs generator power and creates heat |
| Repeater Gun | Suppresses a raider or climber each battle step, reducing contact damage | Reliable but low damage; consumes power |
| Field Workshop | Repairs one damaged module after each resolved contact if it remains operational | Sappers/Burrowers seek it out |
| Signal Coil | Reveals the exact target and lowers surprise risk before contact | Weak on its own; protects against Climbers and Storm Fronts |
| Front Armor Plate | Absorbs the first front-facing impact and reduces hull loss | Adds mass and makes the fortress less agile |
| Refugee Bunk | Preserves convoy capacity and gives Morrowline a positive outcome if intact | Vulnerable to Road Raiders |

The current codebase already contains these modules; the battle layer should promote their behaviors into explicit encounter data rather than relying only on generic tag matching.

## Enemy behaviors

| Enemy | Movement/target behavior | Player lesson |
|---|---|---|
| Road Raiders | Advance toward cargo or exterior mounts; steal or damage the most exposed valuable module | Protect cargo and avoid overloading the exterior |
| Climbers | Bypass the lower hull and target signal/exterior modules | Signal coverage and wall-mounted redundancy matter |
| Burrowers | Ignore exterior defenses and seek engine/workshop/lower-hull tags | Keep a repair path and avoid one critical engine |
| Siege Beast | Slow contact with heavy armor/crew pressure; damages hull if not stopped | A single high-damage threat needs a burst answer and emergency intervention |

The first encounter is a two-Raider road ambush on the safe road. The exposed cut combines a Raider with a Climber. The detour can reveal a Burrower in later testing, but no random enemy should appear without a visible forecast.

## Success and failure

- **Protected arrival:** the fortress reaches Morrowline Camp with hull at or above 7 and at least one convoy/cargo module intact. Grant 24 Ashmarks and unlock the camp report.
- **Damaged arrival:** hull remains above 0 but a critical module or cargo is lost. Reach Morrowline with a smaller reward and a repair choice.
- **Forced retreat:** hull reaches 0 or the engine is disabled. Return to Ashgate Depot, preserve the deterministic battle report, and expose recovery rather than silently ending the run.

## Acceptance criteria

A new tester must be able to start at Ashgate Depot, select one of two route postures, see a forecast, advance the encounter step by step, understand which unit attacked or was targeted, use one intervention, and either reach Morrowline Camp or receive an explicit forced-retreat result. The same seed, route, module layout, and commands must produce the same report. The UI must visibly distinguish the four primary unit behaviors and the Road Raider/Climber/Burrower/Siege Beast threat families.

Out of scope for this slice are a full FTL-like node map, multiple settlements with services, crew recruitment, procedural map generation, platform APIs, multiplayer, and final audio/animation production.
