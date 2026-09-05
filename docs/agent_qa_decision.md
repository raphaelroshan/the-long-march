# Agent QA Decision Record

## Decision

Adopt a shared repository-owned agent QA layer across Market of Ash, Pack the Keep, and The Long March. The Long March layer consists of `docs/qa_playbook.md`, `tools/agent_qa_runner.py`, `scripts/agent_qa.sh`, an executable scenario manifest under `qa/scenarios/`, the existing Godot journey fixture, and one CI evidence artifact.

## Why this design

The repositories already contain valuable game-specific acceptance suites. Replacing them with a generic framework would risk losing domain knowledge. The Long March adapter therefore invokes its existing complete-journey fixture, then validates the semantic command trace, state sequence, save checkpoints, terminal state, rendered-frame metadata, PNG dimensions, and SHA-256 digests. The normal verifier remains authoritative and separate.

## Trade-offs

The initial generic editor-surface capture was removed because non-uniform editor pixels could be mislabeled as a game title. The Long March now uses its game-specific fixture and rendered-frame readiness gate. This is preferable to a fake universal driver that relies on sleeps, coordinates, or assumptions about each game’s scene tree.

The capture script rejects empty, wrong-size, and visually uniform frames. This can expose renderer or startup problems earlier, but it may require per-game readiness signals for scenes whose first frame is intentionally sparse. Such exceptions must be explicit in the manifest rather than weakening the global check.

Third-party frameworks remain optional. If a framework is adopted, pin a Godot 4.4.1-compatible version and pilot it in one repository. The custom verifier remains authoritative for simulation, content, release, save, and campaign acceptance.

## Status vocabulary

`PASS` means the implemented semantic fixture completed and every required evidence field validated. `FAIL` means the fixture or project import failed. `TIMEOUT_PARTIAL` means the scenario exceeded its declared budget and partial logs or captures remain available; it is never equivalent to pass. `BLOCKED_ENVIRONMENT` means Godot or another required tool was unavailable. `INVALID_EVIDENCE` means the scenario, trace, checkpoint, terminal state, screenshot, or manifest could not prove the claim.

## Next decisions

1. Port the executable-adapter pattern to Market of Ash and Pack the Keep without assuming their scene trees match.
2. Use LM-H1 findings to choose any additional state-specific visual comparison; do not manufacture a baseline without a player-facing question.
3. Pilot a compatible Godot test framework only if it reduces maintenance.
