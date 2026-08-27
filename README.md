# The Long March

The Long March is a premium single-player Godot 4.x strategy roguelite about operating a mobile fortress across a ruined continent. The fortress is a spatial loadout: engines, weapons, workshops, crew rooms, armor, signals, and cargo must fit together while the machine remains light and reliable enough to move.

The battles resolve automatically, but the player chooses the fortress layout, route, power priority, target doctrine, travel posture, and emergency interventions. The intended question is not “Which item has the biggest number?” but **“Where can I place this useful part without making the whole fortress depend on it?”**

## Current prototype

The repository contains an agent-first Godot project with:

- A deterministic `LongMarchState` simulation.
- A 6-by-4 chassis grid and two exterior mount slots.
- Module placement, overlap checks, mass, power, heat, durability, and dependencies.
- Routes with distance, fuel, reward, and threat risk.
- Road Raiders, Climbers, Burrowers, Storm Fronts, and Siege Beasts.
- Shift Power, Seal Compartment, Vent Heat, and Cut Loose Cargo interventions.
- Repair and save/load behavior.
- A lightweight UI prototype showing the fortress and state summary.
- Structured campaign content in `content/content_manifest.json` and `content/gameplay_framework.json`.
- Deterministic headless tests in `tests/test_fortress_state.gd`.

## Run locally

Open the project in Godot 4.x or use:

```bash
bash scripts/verify.sh
```

The sandbox used to prepare this scaffold may not include Godot. In that environment the script exits with status `2` and explains the missing dependency. GitHub Actions installs the pinned Godot version and runs the actual tests on Ubuntu and Windows.

## Agent workflow

Read `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md` before editing. Work in a narrow vertical slice, keep the simulation presentation-independent, update stable content IDs, add deterministic tests, and explain the player-facing result.

The recommended sequence is:

1. Stabilize placement, shape, rotation, and dependency checks.
2. Implement power, heat, fuel, and movement as visible state.
3. Add one threat doctrine and its counters.
4. Add one emergency intervention and recovery path.
5. Add settlement contracts, refit, salvage, and campaign transitions.
6. Expand modules, crew stories, and routes only after the core loop is reliable.

## Related follow-up concept

The dungeon-and-shop inventory battler remains a separate follow-up concept. It is not part of this repository. The Long March should first prove that a moving fortress creates a compelling spatial and strategic identity.
