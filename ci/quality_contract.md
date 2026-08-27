# The Long March Quality Contract

Reviewers must treat The Long March as a deterministic single-player mobile-fortress strategy roguelite. Changes should preserve visible cause and effect: module placement, mass, power, heat, fuel, durability, exposure, crew, route risk, threat doctrine, and recovery must be explainable from state and authored content.

## Gameplay review criteria

A change is suspect when it turns the fortress into a static optimal grid; makes heavy modules universally better; hides power, heat, fuel, or dependency failure; makes auto-battle a passive verdict with no meaningful preparation; introduces an enemy with only one mandatory counter; or creates a failure state with no repair, salvage, refit, or lower-value recovery option.

Review whether every module provides a useful benefit and a visible cost, whether exterior systems are powerful but exposed, whether interior systems are protected but space-constrained, and whether the player can understand why a route or intervention succeeded or failed. Review whether the first slice remains a single chassis grid rather than accumulating parallel inventory systems.

## Architecture and QA criteria

Keep fortress logic presentation-independent, deterministic under a fixed seed, serializable, and covered by focused headless tests. Prefer explicit commands and result objects over hidden mutation. Add regression tests for placement, shape occupancy, dependency isolation, power and heat limits, fuel and travel, threat selection, interventions, module damage, recovery, invalid actions, and save/load whenever those systems change.

## Content criteria

Stable IDs in `content/` must remain the source of truth for modules, routes, threats, events, crew, progression, and endings. Narrative text is not executable logic. Each threat requires at least two reasonable counter-options, and each authored encounter must explain its target, timing, uncertainty, and recovery result.

## Release-quality criteria

Do not add storefront integrations, network requirements, or credentials to the simulation layer. Controller and keyboard/mouse paths should reach the same commands. A visual or UI change must not silently alter deterministic outcomes. Avoid adding a full crew inventory, multiplayer, or large module catalog until the chassis loop has passed playtesting.
