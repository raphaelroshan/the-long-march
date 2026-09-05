# The Long March — Investment-Evaluation Roadmap

## Purpose

The next milestone is a **full creative vertical** that demonstrates the moving-fortress fantasy as a game, not merely a beautiful title screen or a pair of chapter demonstrations. An evaluator must understand the machine, make an operational choice, watch a consequence unfold, recover, and see how the road changes the next decision.

The game should feel like an original fortress-crawler about logistics, people, route uncertainty, and physical dependencies. Its identity comes from the walking settlement, visible chassis, regional roads, changing settlements, specialists with practical conflicts, staged contacts, recovery decisions, and failure-forward campaign memory.

## Verified baseline

The current implementation baseline is `0.3.0-alpha.364`. It contains four regions, three chassis, dependency breadth, causal obligation memory, composable endings, candidate hardening, native Linux cohorts, a title/First Watch tutorial, authored settlement and fortress modes, battle/contact presentation, recovery, Debrief, local evidence workflow, and extensive deterministic verification. LM-GPT56-0 through LM-GPT56-5 add rendered-frame evidence validation, the full creative-journey proof, shared fortress presentation contract, regional campaign skeleton, people-and-promises contract, and checksummed 30–90 minute candidate target. The automated suite passes; duration remains authored rather than human-observed.

**LM-I1 repository gate: complete.** The canonical Ashgate evaluation fixture now performs a legal chassis refit, recruits Iven Pell, forces an explicit signal-versus-repair specialist decision with Mara Flint, resolves the resulting forge-core dilemma, checks that promise after the fourth road, and carries the causal record into Debrief. The fixture covers save/resume at the unresolved crossroads, standard 1600×900 presentation, and a 1280×720 large-text/high-contrast/reduced-motion/alternate-controller profile. Evidence and remaining human questions are recorded in [`lm_i1_creative_vertical_report.md`](lm_i1_creative_vertical_report.md).

**LM-I2 repository gate: complete.** The Cinder Spine has three complete route fixtures, including the Inferno-opened Ash Chapel recovery path, plus a no-dead-end pressure sweep and 51 exact checkpoint round trips. Its player-command fixture now runs from Blackkiln through Old Lift refit and recovery to the Elevator Warden and terminal Debrief. Old Lift has Cinder-specific stakes, route guidance, scenery, and a visible no-cost chassis-workbench action. Evidence is recorded in [`lm_i2_cinder_gate_report.md`](lm_i2_cinder_gate_report.md).

**LM-I3 repository gate: complete.** White Salt now has two viable deterministic loadouts with different ammunition-versus-armor dependencies, upper-road priorities, contract choices, and terminal Debriefs. The Salt Skimmer comparison names its third exterior mount, lower mass ceiling, and paired cut-away against the Road Keep; previous-version Windbreak checkpoints preserve the chosen layout exactly. The complete UI fixture runs from Saltglass Haven through the Windbreak and Rival Approach to Salt Citadel. Evidence is recorded in [`lm_i3_white_salt_gate_report.md`](lm_i3_white_salt_gate_report.md).

**LM-I4 repository gate: complete.** The 20-module, six-specialist, and 15-threat candidate counts now resolve through one validated cross-content contract. Three complete White Salt journeys prove Sela/Command Deck, Nera/Infirmary, and Salvage Crane plans with distinct sacrifices, isolated and combined threat contacts, exact deterministic replay, and visible recovery consequences. Evidence is recorded in [`lm_i4_breadth_gate_report.md`](lm_i4_breadth_gate_report.md).

**LM-I5 repository gate: complete.** Ashgate's completed, declined, and failed Morrowline guard obligations now persist independently from best-result progression and create three attributed consequences in Flooded Veyru: an extra Evacuation Camp service action, a lower-pressure Sunken Tramworks route, or a lower-risk Pump Gallery approach. The histories survive exact save round trips, migrate safely from prior schemas, appear in route and Debrief presentation, and compose into three distinct ending networks. Evidence is recorded in [`lm_i5_memory_gate_report.md`](lm_i5_memory_gate_report.md).

**LM-I6 repository gate: complete.** Build & Local Data exposes the exact save-schema window and validates primary, backup, and tutorial checkpoint health. A corrupt or missing primary can be restored only through an explicit confirmation while its validated predecessor remains unchanged. Every declared save schema is exercised, release manifests now carry and verify compatibility plus the offline boundary, and clean-install/recovery presentation is covered at standard and accessible layouts. Evidence is recorded in [`lm_i6_hardening_gate_report.md`](lm_i6_hardening_gate_report.md).

The investment risk is not prototype fragility; it is whether the game currently offers enough **complete, varied, legible journey content** to feel like an Early Access product instead of a high-quality systems demonstration. The next roadmap must make the full creative vertical obvious and make every additional region contribute a new operational question.

## Definition of the full creative vertical

A reviewer must be able to complete, from a fresh save: title → First Watch tutorial → place or refit systems → choose a road → commit costs → travel → resolve a contact or roadside event → inspect damage → make a recovery decision → reach a settlement → see a consequence in the regional map → choose the next road → reach a regional finale → read the terminal Debrief.

The vertical must include one memorable fortress silhouette, three distinct settlement identities, three route types, two specialists with conflicting practical priorities, three module dependency questions, three threat families, one named contact, one roadside event, one recovery dilemma, one regional consequence, one alternate chassis or doctrine choice, layered travel/contact/recovery audio, and a Debrief that explains the causal chain. The vertical should be completable in 30–60 minutes while still allowing a second run with a different route or loadout.

## Skeletal Early Access floor

The current four-region structure must become four genuinely playable regions rather than four labels around a common loop. The Early Access floor is four regions, twenty to twenty-four encounters, three fortress chassis/templates, eighteen to twenty-four modules, six to eight specialists, ten to twelve threat families, fourteen to eighteen routes, eight to ten settlements, twenty to twenty-four events, four to six regional developments, and six or more composable endings.

Each region may reuse the fortress renderer, transition grammar, temporary art kit, audio buses, and common UI. Each region must still add one operational promise, one distinct settlement/service trade-off, one route hazard, one threat or event family, one recovery implication, and one failure-forward development. A region that only changes palette, prose, or enemy names does not count toward the floor.

## Ordered implementation gates

| Gate | Player-facing deliverable | Required evidence |
|---|---|---|
| **LM-I1 — Creative vertical lock** | One complete authored journey from First Watch through arrival and Debrief, with the fortress, road, contact, recovery, and consequence all visually coherent. | Clean-save full-flow fixture, deterministic replay, save/resume at each phase, controller/scaling/reduced-motion checks, and a 1600×900 capture. |
| **LM-I2 — Region three** | A third region with a new route promise, settlement identity, hazard, contact/event, recovery condition, and ending contribution. | Region manifest, three route fixtures, one failure-forward fixture, complete-flow capture, and no-dead-end test. |
| **LM-I3 — Region four and chassis choice** | A fourth region and an alternate chassis or doctrine that changes module placement and road priorities. | Two viable seeded loadouts, dependency matrix, route comparison, save migration, and Debrief comparison. |
| **LM-I4 — Module/specialist/threat breadth** | Enough modules, specialists, and threats to make the machine evolve across a run without stat-only additions. | Counter/weakness matrix, isolated and combined encounters, repair consequences, deterministic replay, and visual evidence. |
| **LM-I5 — Campaign memory and endings** | Completed, declined, and failed obligations change later routes, settlements, services, or refuges and compose into distinct endings. | Causal campaign fixtures, ending matrix, migration-safe state tests, post-consequence screenshots, and replay report. |
| **LM-I6 — Early Access hardening** | Repeatable 30–90 minute campaigns with reliable save recovery, clear limitations, offline operation, packaged launch, and honest update boundaries. | Full verification, performance budgets, clean install, save backup/migration, controller/scaling, package manifest, rollback, and release cohort. |

## Content authoring rule

Every region, road, settlement, specialist, module, threat, event, and finale must answer: what operational question does it create; what physical dependency or resource does it alter; what is the visible counter; what is the recovery cost; and what happens if the player ignores it? Narrative content is valuable when it changes the machine, the route, the people carried, the services available, or the ending—not when it adds only dialogue.

## Feel and presentation requirements

The fortress must remain legible as the same machine in rest, travel, contact, recovery, and Debrief. Travel needs anticipation and cost commitment, contacts need readable target and impact staging, recovery needs breathing room and explicit sacrifice, and Debrief needs a causal story. Audio and animation should reinforce the machine’s weight, stress, repair, and movement while remaining presentation-only.

## What not to build yet

Do not add multiplayer, a huge procedural continent, a generic loot rarity system, a large skill tree, combat spectacle that hides dependencies, or platform services before LM-I1 through LM-I3 pass. Do not add regions that have no distinct operational question. Do not use human testing as a development blocker; use deterministic fixtures, replay, screenshots, package checks, and known limitations as active gates.

## Agent task contract

Each task must name one player-facing journey or operational behavior, identify the authoritative state owner, define the presentation read model, add deterministic tests, cover save/resume and controller/scaling behavior, and capture the affected state at the exact build version. The final report must list changed files, verification output, screenshots, known limitations, and exactly one next task.

LM-I1 through LM-I6 and LM-GPT56-0 through LM-GPT56-5 are complete. The sole next packet is LM-H1: a consented, uncoached private-alpha cohort using the exact checksummed candidate. Human validation is now needed to calibrate pacing, comprehension, accessibility, and recognition; it is not replaced by repository automation.

## Decision

The investment target is a compact but complete campaign of moving-fortress journeys. We prefer four regions with real operational identities over a large empty continent, and a small number of consequences that visibly alter later play over a sprawling narrative layer with no mechanical memory.


## 2026-09-03 review checkpoint — evidence harness gate

The then-current `0.3.0-alpha.363` main build passed the full verification suite after the repository-owned version validator was made available at the wrapper’s expected sandbox path. The automated suite covered the creative vertical, complete journey handoff, responsive profiles, regional flows, breadth, memory, recovery, controller, accessibility, audio, performance, and hardening.

The three fresh 1280×720 smoke captures from this cycle are uniform grey frames. This is an invalid visual-evidence result, not a verified game-rendering failure. Therefore **LM-I1 is not complete for investment-evaluation scope** until the capture harness has a rendered-frame readiness handshake or a Godot-controlled viewport capture. The next agent must execute **LM-GPT56-0**: repair the evidence harness, capture a real title/First Watch state, and fail clearly when no rendered frame is available.

Once valid evidence exists, execute **LM-GPT56-1**: prove one clean-save journey through First Watch, refit, route, travel, contact/event, visible consequence, recovery, arrival, next route, and terminal Debrief. Do not add another region until the complete journey is visually and causally proven. The dated evidence is in `docs/latest_review_2026-09-03.md` and `docs/visual_evidence/v0.3.0-alpha.363-review-2026-09-03/`.

At that checkpoint, the prior statement that LM-I1 through LM-I6 and LM-GPT56-1 through LM-GPT56-5 were complete applied to automated repository scope only. The grey-frame finding temporarily superseded it for investment evaluation until the resolution below.

### Resolution

LM-GPT56-0 is complete in `0.3.0-alpha.364`. The exact failed grey frame is a negative regression fixture, and the new Godot viewport gate refuses null, wrong-size, blank, or visually uniform captures. LM-GPT56-1 was rerun through the gate at 1280×720 and 1600×900, producing complete checksummed state sequences. The evidence blocker above is closed; LM-H1 human observation is again the sole next packet.


## 2026-09-04 repeat-test checkpoint — complete journey remains the next gate

The current `0.3.0-alpha.364` main build passes the full verification suite. The repeat visual run now produces valid evidence: the title shows the moving-fortress identity, saved-run and region choices; First Watch reaches a real Siege Beast contact; and the follow-up reaches Contact Step 3 of 6 with a saved battle-step state, readable dossier, approach/advance controls, and fortress metrics.

The opening now reads as a credible game. The remaining investment gate is not more regions but one complete, clean-save journey through First Watch, refit, route, travel, contact/event, consequence, recovery, arrival, next route, and Debrief. At 1280×720 the side rail, fortress, dossier, emergency controls, and timeline are information-dense; the agent should reduce overload only after the full journey evidence is captured, without hiding causal detail.

Execute **LM-GPT56-1B** next. Capture the complete journey at 1600×900 and representative 1280×720 states, preserve deterministic replay and save/resume at each phase, and keep LM-H1 human observation optional rather than blocking. The current evidence is in `docs/latest_review_2026-09-04.md` and `docs/visual_evidence/v0.3.0-alpha.364-review-2026-09-04/`.

### Resolution

LM-GPT56-1B is complete. The existing Godot 4.4.1 full-journey sets contain 24 validated states at 1600×900 and 22 representative accessibility states at 1280×720. Their schema-2 manifests now bind the frames to a clean-save player-action contract, restored departure/interruption/arrival/specialist checkpoints, and a five-contact terminal Debrief at Meridian Pass. The deterministic fixture and mandatory rendered-frame test enforce the same contract. Evidence and limitations are recorded in [`lm_gpt56_1b_completion_evidence_report.md`](lm_gpt56_1b_completion_evidence_report.md).

LM-H1 is again the sole next packet. It is calibration work with consented human participants, not a repository feature gap and not permission to claim unobserved comprehension or pacing.


## 2026-09-05 audit checkpoint — LM-GPT56-1C verification profiling remains open

The current `0.3.0-alpha.364` build produces valid visual evidence beyond the title: an Arrival Receipt / Route Secured state and a Plan Journey route-map state with readiness metrics, risk forecast, prior receipt, and doctrine selection. The extended verification log records passes for the investment vertical, LM-GPT56-1, responsive profiles, complete journey handoff, Flooded Veyru, Cinder Spine, and other named fixtures, but the wrapper reaches its 900-second bound before completing the full suite. This is a release-process timeout, not an observed game assertion failure.

The next agent must execute **LM-GPT56-1C**: profile and split the verification wrapper into bounded per-suite groups, identify the slowest fixture, and report timing without weakening coverage. Then re-prove the clean-save journey through contact, recovery, arrival, next route, and Debrief with 1600×900 and representative 1280×720 evidence. Preserve the causal chain and deterministic replay; do not add another region until the timing and complete-journey evidence are clean. Evidence is recorded in `docs/audit_report_2026-09-05.md` and `docs/visual_evidence/v0.3.0-alpha.364-audit-2026-09-05/`.
