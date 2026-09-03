---
name: long-march-visual-reviewer
description: Inspect The Long March's rendered screenshots and capture manifests for hierarchy, legibility, spatial continuity, state truth, regional identity, and accessibility defects. Use for evidence-backed visual audits or before changing presentation code; do not treat screenshots as proof of player comprehension or emotional response.
---

# Long March Visual Reviewer

Review the game as a sequence of decisions, not a gallery of isolated frames. A strong screen makes the current place, fortress state, threat or promise, primary action, and next consequence readable in that order.

## Select trustworthy evidence

1. Read `AGENTS.md`, `design/fortress_visual_modes.md`, `docs/presentation_boundaries.md`, and the current milestone in `docs/agent_handoff_roadmap.md`.
2. Prefer a committed cohort under `docs/visual_evidence/` with `capture-manifest.json` and a passing rendered-frame gate.
3. Compare the same state at 1600×900 and the supported 1280×720 accessibility profile when both exist.
4. Inspect actual images before reading the implementation. Code cannot prove hierarchy, overlap, or visual continuity.
5. After identifying a defect, trace only the relevant scene, presenter, state source, and tests before proposing a fix.

Use [the screen review grid](references/screen-review-grid.md) for consistent findings.

## Review the journey, not just frames

Inspect these transitions when the cohort contains them:

```text
title → tutorial → settlement → map browse → route selection → commit
→ travel → contact/event → impact → arrival → recovery → Debrief
```

Check whether the same fortress remains recognizable, the phase visibly changes, applied costs remain distinct from previews, and the next action follows the player's eye. An attractive frame can still fail if it breaks the journey's causal handoff.

## Report only supported findings

Classify each finding:

- **Blocker:** clipped required control, unreadable state, misleading phase/cost, missing focus, or a visual that contradicts authoritative state.
- **Concern:** competing hierarchy, avoidable density, overlapping labels or paths, weak place/threat distinction, or loss of fortress continuity.
- **Nit:** localized spacing or polish issue with no decision risk.

For every finding, name the image, visible evidence, player decision at risk, and smallest likely source area. Separate observations from hypotheses. Never claim that a player understood, enjoyed, noticed, or preferred something without human evidence.

If implementing a fix, change one visual problem at a time. Preserve state logic, input parity, 110% text, high contrast, reduced motion, and the deterministic capture contract. Add a screenshot assertion or focused visual signature only when it checks meaningful state or geometry—not exact decorative wording.

Run Godot flow and capture tests serially. Several fixtures intentionally reset the same `user://` saves and preferences, so parallel Godot processes can corrupt one another's setup and produce cascading false failures.

Stop when remaining questions require taste, emotional judgment, or uncoached observation. Route those questions to `$long-march-playtest-triage` after verified packets exist.
