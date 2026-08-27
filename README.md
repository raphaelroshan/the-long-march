# The Long March

The Long March is a premium single-player Godot 4.x strategy roguelite about operating a mobile fortress across a ruined continent. The fortress is a spatial loadout: engines, weapons, workshops, crew rooms, armor, signals, and cargo must fit together while the machine remains light and reliable enough to move.

The battles resolve automatically, but the player chooses the fortress layout, route, power priority, target doctrine, travel posture, and emergency interventions. The intended question is not “Which item has the biggest number?” but **“Where can I place this useful part without making the whole fortress depend on it?”**

## Current prototype

The repository contains an agent-first Godot project with:

- A playtest-focused title flow with guided Start Game, briefing-free Quick Start, save-aware Continue, and a concise run guide.
- A session-safe pause menu with live run status, Save, Save & Return, and confirmation before discarding progress.
- A persistent five-milestone run tracker, with the current mandatory decision kept above optional controls.
- Deliberate focus handoff across start, contracts, routes, encounters, results, and pause/resume for keyboard and controller playtests.
- Automatic viewport scrolling that keeps newly focused route, combat, recovery, and feedback actions visible.
- Prominent post-run actions for feedback, replaying from Ashgate, or returning to the title screen.
- Exact build identifiers on title and pause screens for reproducible playtest reports.
- Save validation on the title screen, with incompatible or malformed saves explained instead of loaded as misleading fresh runs.
- Local playtest settings, reachable from title or pause, for fullscreen, reduced transition motion, briefing reset, and confirmed save clearing.
- A playable opening stage at Ashgate Depot that begins with the fortress refit, convoy contract, and first route choice.
- A deterministic `LongMarchState` simulation.
- A 6-by-4 chassis grid and two exterior mount slots.
- Interactive Ashgate refitting: select, place, rotate, move, and remove modules with mouse, keyboard, or controller navigation.
- Explicit dependency states for fuel-fed engines, ammunition-fed weapons, crew/parts-supported workshops, shared power, and signal visibility.
- Module placement, overlap checks, mass, power, heat, durability, and dependencies.
- An interactive visual campaign map showing current position, secured paths, available roads, closures, and known, forecast, or unscouted information, with explicit route review and confirmation.
- A test-focused command interface with resource cards, chapter and encounter progress, contextual next-action guidance, and distinct mouse/keyboard/controller focus states.
- Combat cards showing enemy arrival, health or storm pressure, current targets, counters, a six-step timeline, and recent cause-and-effect.
- Visible Watch, Closing, and Break pressure that can close an optional road without removing the only recovery path.
- Road Raiders, Climbers, Burrowers, Storm Fronts, and Siege Beasts.
- Shift Power, Seal Compartment, Vent Heat, and Cut Loose Cargo interventions.
- Repair and save/load behavior.
- A lightweight UI prototype showing the fortress and state summary.
- Structured campaign content in `content/content_manifest.json` and `content/gameplay_framework.json`.
- Deterministic headless tests in `tests/test_fortress_state.gd`.
- A complete five-encounter Ashgate Lowlands chapter with branching routes through Rill Crossing, The Soot Orchard, Broken Relay, Red Wheel Toll Bridge, Morrowline Camp, Lower Ash Road, and Signal Causeway.
- Stepwise encounter battle behavior for Road Raiders, Climbers, Burrowers, and Siege Beasts, including module counters, target selection, intervention, repair, and arrival/retreat outcomes.
- An Ashgate guard contract, three local route decisions, recruitable signal officer Iven Pell, and persistent settlement trust.
- Recoverable non-final defeats that retreat to the last secured node with explicit costs and a viable limping state.
- A Morrowline recovery phase with limited paid repairs/refueling, continued refitting, and a fifth Meridian Pass battle with decisive, scarred, or failed run results.
- Versioned JSON save/load and an automated UI-level complete-run test.
- A first-run Marchmaster briefing, phase-specific guidance, and a local-only playtest feedback bundle.
- An original visual kit in `assets/` for the journey background, Steam Lance Engine, Shell Cannon, Field Workshop, Signal Coil, and internal art direction.

## Run locally

Open the project in Godot 4.x or use:

```bash
bash scripts/verify.sh
```

Running the project opens on the title menu. Choose **Start Game · Guided First Run** for the Marchmaster briefing, **Quick Start · Skip Briefing** for repeated flow tests, or **Continue Saved March** when a local save exists. **View Test Flow** summarizes the five decisions a complete playtest should exercise. Press Escape during the stage to pause, inspect run progress, save, or safely return to the title.

With Godot export templates installed, create desktop playtest builds with:

```bash
bash scripts/export_playtest.sh windows
bash scripts/export_playtest.sh macos
```

The internal journey slice has been verified locally with Godot 4.4.1. On a development machine, install the pinned Godot version and run the same verification command before editing.

## Agent workflow

Read `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md` before editing. Work in a narrow vertical slice, keep the simulation presentation-independent, update stable content IDs, add deterministic tests, and explain the player-facing result.

The recommended sequence is:

1. Stabilize placement, shape, rotation, and dependency checks.
2. Implement power, heat, fuel, and movement as visible state.
3. Add one threat doctrine and its counters.
4. Add one emergency intervention and recovery path.
5. Add settlement contracts, refit, salvage, and campaign transitions.
6. Expand modules, crew stories, and routes only after the core loop is reliable.

## Initial journey test release

The current focused test flow begins at Ashgate Depot, branches through five encounters, recovers at Morrowline Camp, and ends at Meridian Pass. The chapter contract is in [`design/ashgate_lowlands_alpha.md`](design/ashgate_lowlands_alpha.md); the release checklist is in [`docs/internal_test_release.md`](docs/internal_test_release.md). The generated asset roles and provenance notes are in [`assets/ASSETS.md`](assets/ASSETS.md).

The authoritative implemented-loop contract is [`design/functional_prototype_run.md`](design/functional_prototype_run.md).
The tester workflow, privacy contract, and interview questions are in [`docs/playtest_guide.md`](docs/playtest_guide.md).

## Related follow-up concept

The dungeon-and-shop inventory battler remains a separate follow-up concept. It is not part of this repository. The Long March should first prove that a moving fortress creates a compelling spatial and strategic identity.

## Expanded design package

The broader fortress plan is documented separately so agents can implement it in controlled slices:

- [`design/fortress_facilities_and_mechanics.md`](design/fortress_facilities_and_mechanics.md) — buildings, dependencies, budgets, staffing, damage, and recovery.
- [`design/map_regions_and_settlements.md`](design/map_regions_and_settlements.md) — FTL-like node map, visibility, closure pressure, regions, settlements, and route archetypes.
- [`design/characters_factions_and_campaign.md`](design/characters_factions_and_campaign.md) — crew, rivals, factions, campaign pressures, regional arcs, and endings.

The machine-readable campaign manifest now includes regions, settlements, extended character hooks, map rules, and authored events. The Ashgate Lowlands graph, pressure model, guard contract, Iven recruitment, and recovery loop have runtime behavior and deterministic tests; later regions remain design targets until implemented to the same standard.
