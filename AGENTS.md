# AGENTS.md — The Long March

## Mission

Build The Long March as a premium single-player Godot 4.x strategy roguelite about operating a mobile fortress across a hostile continent. The core experience is spatial engineering under movement pressure: every module gives a useful capability and creates a visible dependency.

## Before editing

Read `design/design_prompt.md`, `design/gameplay_framework.md`, the relevant `content/` manifest, and the current files in `src/core/`, `tests/`, and `docs/`. Do not assume a feature is complete because it appears in a design document.

## Architecture contract

Keep simulation in `src/core/fortress_state.gd` and keep it independent of nodes, rendering, frame timing, and input events. Keep presentation in `src/ui/` and `scenes/`. Keep authored content in `content/` and human-readable rationale in `design/` and `docs/`.

Use stable IDs for modules, threats, routes, characters, locations, events, progression nodes, and endings. Do not encode executable logic in narrative strings. Translate content requirements and effects into explicit runtime commands.

## Development slices

Work on one narrow slice at a time: placement and rotation, dependency graph, power and heat, travel, one threat doctrine, one intervention, one settlement contract, or one UI panel. Each slice must include a deterministic test and a clear player-facing explanation.

The first slice is intentionally limited to a 6-by-4 chassis grid, two exterior mounts, four initial module families, three core enemy doctrines, one storm, one Siege Beast, four interventions, two settlements, and five encounters. Do not add a second full crew inventory, multiplayer, storefront APIs, or a large item catalog until the primary loop is stable.

## Quality requirements

A valid change must preserve fixed-seed reproducibility, serializable state, recovery after partial failure, readable causality, and controller/keyboard/mouse parity. A threat must have at least two reasonable counters. A strong module must carry a meaningful cost in mass, heat, power, exposure, crew, fuel, or space.

Run `python tools/validate_content.py --manifest content/content_manifest.json` and `bash scripts/verify.sh` before opening a pull request. If Godot is unavailable locally, report the environment limitation honestly; do not treat it as a passing test.

## Safety and source control

Never commit API keys, Steam or Epic credentials, generated binaries, private saves, or unreviewed third-party dependencies. Do not modify a different repository from this project. Keep commits small, descriptive, and reversible.

## Agent QA contract

Before changing code, also read `docs/qa_playbook.md`, `docs/agent_qa_decision.md`, the active roadmap, and the latest audit report. Run `bash scripts/agent_qa.sh` and record the exact version, commit, Godot version, viewport, and result classification.

Use semantic commands and named readiness states for new journeys; never treat sleeps, coordinate clicks, or a screenshot taken before readiness as proof. Preserve `artifacts/agent-qa/` on success and failure.

A result must be classified as `PASS`, `FAIL`, `BLOCKED_ENVIRONMENT`, `TIMEOUT_PARTIAL`, or `INVALID_EVIDENCE`. A timeout or missing tool is not a pass. Report changed files, commands, durations, state sequence, screenshot paths, known limitations, and one next task. Human testing is optional unless the active roadmap explicitly assigns an owner approval gate; agents should continue improving automated evidence without waiting.
