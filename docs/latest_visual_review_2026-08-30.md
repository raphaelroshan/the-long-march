# The Long March — Latest Visual Review

**Build:** `0.3.0-alpha.297`

**Branch:** `origin/main`

**Engine:** Godot 4.4.1

**Capture:** 1280×720 Xvfb display; title and First Watch introduction flow captured from a real launch.

## Verification

The full repository verification suite passed, including version consistency, content, release manifest, fortress state, campaign, playtest journal, interface audio, visual contrast, silhouette, road contact, events, recovery, controller, settlement, shell, tutorial, complete-flow, and Flooded Veyru UI suites. The project launches successfully and reaches First Watch introduction.

## Evidence

- [Title](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_01_title.png)
- [First Watch introduction](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_02_first_action.png)
- [Follow-up](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_03_followup.png)

## Findings

The Long March is currently the strongest of the three at 1280×720. The title has a coherent visual identity, clearly exposes First Watch and the two journey chapters, and provides readable control hints. The First Watch introduction is also clear, with a convincing moving-fortress silhouette and a strong moving-settlement premise.

The important remaining evidence gap is not the opening screen. The smoke test does not yet prove the complete player-facing handoff from tutorial to live refit, route planning, commitment, travel, road contact or event, recovery, arrival, and Debrief in one run.

## Next roadmap sequence

1. Prove the complete First Watch → live refit → route → commitment → travel → contact/event → recovery → arrival → Debrief handoff from a clean save without debug actions.
2. Capture the complete journey at 1600×900 and compare it with the 1280×720 evidence.
3. Improve transition rhythm so settlement receipt, route commitment, departure, march, contact, consequence receipt, and arrival are distinct, concise, skippable, and deterministic.
4. Stage road contact as forecast, approach, target lock, wind-up, response, impact, dependency consequence, and settle; make the threat intent, counter, and result understandable from the main presentation.
5. Give Ashgate, Morrowline, Lantern Quay, and Evacuation Camp distinct visual, service, and operational identities.
6. Extract settlement, route, contact, recovery, and Debrief presentation boundaries without changing fortress state ownership.
7. Add one controlled specialist, threat, facility, or route branch only after the complete journey and responsive presentation contracts pass.
8. Add one failure-forward campaign consequence and bounded replay variation, then harden saves, controller, scaling, audio, packaging, and provenance.

Human testing is optional follow-up calibration and is not a prerequisite for these implementation steps. Automated tests, deterministic replay, full-flow launches, layout checks, and screenshot evidence are the active gates.
