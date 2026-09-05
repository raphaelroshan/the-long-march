# Agent-First QA Playbook

This repository uses a layered QA contract. The existing game-specific verifier remains authoritative for simulation, content, release, and acceptance behavior. The shared agent QA wrapper adds evidence truth, timing, and artifact preservation; it does not replace domain tests.

## Required agent loop

Before editing, run the semantic scenario into a named baseline directory. The result records the commit, dirty state, game version, Godot version, viewport, renderer, locale, seed, input trace, captured states, duration, terminal state, and evidence limitations. Preserve the baseline even when it fails.

Select one unfinished roadmap task. State the player-facing objective, authoritative owner, presentation owner, non-goals, acceptance criteria, expected state sequence, screenshot states, save checkpoints, and time budget before changing code. Large tasks are acceptable, but they must expose independently verifiable checkpoints.

After editing, run the focused test, the relevant `scripts/verify.sh` group, and the semantic scenario into a separate final directory. A result must be classified as `PASS`, `FAIL`, `BLOCKED_ENVIRONMENT`, `TIMEOUT_PARTIAL`, or `INVALID_EVIDENCE`. Do not call a timeout a pass.

## Evidence contract

Every QA output must identify the game, commit, version, engine, viewport, renderer, locale, seed, input trace, state identifiers, screenshot paths, duration, exit code, and known limitations. The runner rejects a planned or malformed scenario, missing PASS marker, wrong command trace, wrong checkpoint sequence, incomplete terminal state, missing image, wrong dimensions, or checksum mismatch. The Godot fixture rejects blank or visually uniform frames at its named rendered-frame boundary.

Simulation authority must remain in the core layer. UI, audio, animation, screenshot timing, and visual effects may not decide prices, damage, targeting, route outcomes, persistence, or endings.

## Commands

```bash
# Preserve a pre-change baseline.
AGENT_QA_OUTPUT_DIR=artifacts/agent-qa/baseline bash scripts/agent_qa.sh

# Run the post-change journey separately.
AGENT_QA_OUTPUT_DIR=artifacts/agent-qa/final bash scripts/agent_qa.sh

# Select an explicit Godot binary when it is not on PATH.
GODOT_BIN=/path/to/Godot bash scripts/agent_qa.sh
```

The Long March adapter executes `tests/test_complete_journey_handoff.gd` through normal player-facing controls. Its responsive 1280×720 run captures 22 named states from title through Debrief, restores four save checkpoints, and validates the scenario's exact terminal state. The ordinary deterministic verifier remains a separate required layer; agent QA does not rerun it.

## PR report format

Agents must report changed files, baseline and final result tables, exact commands, durations, screenshot paths, state traces, deterministic hashes where available, remaining limitations, and one next task. Visual changes require an intentional-baseline note describing what changed and what contract remains unchanged.

## Current game-specific priorities

Market of Ash: add a semantic ordinary-trade round trip from first purchase through route, departure, event, arrival, return market, and terminal receipt. Pack the Keep: add a semantic Greywatch run from War Council through placement, three waves, intervention, damage, Recovery, and Results. The Long March adapter is implemented; its next use is to preserve comparable evidence around one narrow change derived from LM-H1 observation.
