# The Long March — AI Game-Quality Execution Plan

**Applies to:** `0.3.0-alpha.296` and later

**Purpose:** Advance the moving-fortress journey from a strong systems prototype to a game-quality private-alpha slice. Automated verification, deterministic replay, scripted full-flow launches, controller/scaling checks, and screenshot review are the active gates. Human sessions are optional later validation and must not block implementation.

## Operating contract

The simulation remains authoritative and deterministic. Presentation may interpolate already-determined movement, contact, impact, recovery, and arrival, but it may not invent damage, alter target order, consume random streams, change route costs, or change replay keys. Fortress state, route state, event state, and save state must remain presentation-independent.

The fortress is the protagonist. Every journey decision should explain what the machine can carry, protect, expose, repair, or abandon. The player must be able to understand the current order, route commitment, threat intent, dependency consequence, recovery cost, and next decision without opening raw debug records.

## Execution order

| Step | Objective | Required outcome |
|---|---|---|
| **L1 — complete in alpha.288** | Prove the complete journey handoff | Run clean First Watch → live refit → route planning → commitment → travel → road contact/event → recovery → arrival → Debrief. No hidden debug action may be required and save/resume must preserve the same phase and focus. |
| **L2 — complete in alpha.289** | Finish responsive fortress presentation | At 1280×720, 1600×900, large text, high contrast, reduced motion, keyboard, and controller paths, the left status rail, center fortress/map, right selected-subject dock, and required actions remain readable and reachable. |
| **L3 — complete in alpha.290** | Improve journey rhythm | Make settlement receipt, route commitment, departure, short march beat, contact/event, consequence receipt, and arrival visually distinct, concise, skippable, and deterministic. |
| **L4 — complete in alpha.291** | Complete road-contact cause and effect | Stage forecast, approach, target lock, wind-up, response, impact, dependency consequence, and settle. Every major threat must have a visible intent, counter, and consequence. |
| **L5 — complete in alpha.292** | Strengthen settlement and route identity | Ashgate, Morrowline, Lantern Quay, and Evacuation Camp must differ in visual motif, service priority, operational pressure, and route meaning. Avoid menu-only reskins. |
| **L6 — complete in alpha.293** | Extract presentation boundaries | Refactor the monolithic presentation code into focused settlement, route, contact, recovery, and debrief presenters or panels. Preserve state ownership and command contracts. |
| **L7 — complete in alpha.294** | Add one controlled content slice | Add one specialist, threat, facility, or route branch only after L1–L6. Specify the player question, counter, weakness, data schema, deterministic encounter, recovery consequence, and evidence captures. |
| **L8 — complete in alpha.295** | Add failure-forward campaign texture | Turn one completed, declined, or failed promise into a visible later route, settlement, faction, shortage, refuge, or service consequence. Keep it small, deterministic, inspectable, and capable of supporting multiple endings. |
| **L9 — complete in alpha.296** | Build replayable mastery | Offer bounded route, doctrine, specialist, and recovery variations. Avoid grind and forced build orders; each expanded teaching scenario needs at least two viable solutions. |
| **L10** | Harden the private alpha | Verify saves, migration, clean install, controller, scaling, audio, performance, package provenance, offline behavior, and complete-flow evidence. Human sessions may be run afterward for calibration but do not block the artifact. |

## Acceptance tests for every AI task

The agent must run the complete verification wrapper and the relevant focused tests. The same seed and command sequence must produce the same authoritative result across viewport size, text scale, contrast, motion setting, input device, pause, speed, manual-step, and screenshot capture. UI tests must assert focus reachability and visible bounds, not merely node existence.

A task is incomplete if a transition hides the current commitment, if a threat’s target or counter is unexplained, if an animation determines an outcome, if the fortress disappears behind a menu, if a required action clips at a supported viewport, or if content breadth is used to avoid fixing the journey loop. Automated evidence proves behavior and reproducibility; it does not claim human enjoyment.

## Recommended next prompt

> Read `docs/agent_handoff_roadmap.md`, `docs/game_quality_transformation_plan.md`, this document, and `docs/l9_replayable_mastery_report.md`. Implement **L10 Private-Alpha Hardening** only. Verify clean install, current and older saves, backup recovery, controller, scaling, audio, performance, package provenance, offline behavior, safe close, and the complete journey. Produce one honest candidate manifest and evidence report; do not claim storefront readiness or public release.

## Definition of game-quality readiness

The Long March is ready for private alpha when the complete journey is playable and understandable without debug actions, the fortress remains visually continuous across every mode, route and threat consequences are legible, recovery changes the next decision, settlements feel distinct, at least two viable journey plans exist, and the packaged artifact is reproducible. Human validation is an optional later confidence layer, not the condition for starting or completing this work.

## Historical evidence

The latest baseline is recorded in [`latest_test_report_2026-08-30.md`](latest_test_report_2026-08-30.md), and the versioned captures are in `docs/visual_evidence/`. The broader roadmap remains [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md).

## References

[1]: agent_handoff_roadmap.md "The Long March Agent Handoff Roadmap"
[2]: game_quality_transformation_plan.md "The Long March Game-Quality Transformation Plan"
[3]: latest_test_report_2026-08-30.md "The Long March Latest Main Test Report"
