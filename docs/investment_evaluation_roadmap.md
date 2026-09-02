# The Long March — Investment-Evaluation Roadmap

## Purpose

The next milestone is a **full creative vertical** that demonstrates the moving-fortress fantasy as a game, not merely a beautiful title screen or a pair of chapter demonstrations. An evaluator must understand the machine, make an operational choice, watch a consequence unfold, recover, and see how the road changes the next decision.

The game should feel like an original fortress-crawler about logistics, people, route uncertainty, and physical dependencies. Its identity comes from the walking settlement, visible chassis, regional roads, changing settlements, specialists with practical conflicts, staged contacts, recovery decisions, and failure-forward campaign memory.

## Verified baseline

The current implementation baseline is `0.3.0-alpha.357`. It contains four regions, three chassis, dependency breadth, campaign memory, composable endings, candidate hardening, native Linux cohorts, a title/First Watch tutorial, authored settlement and fortress modes, battle/contact presentation, recovery, Debrief, local evidence workflow, and extensive deterministic verification. The automated suite passes.

**LM-I1 repository gate: complete.** The canonical Ashgate evaluation fixture now performs a legal chassis refit, recruits Iven Pell, forces an explicit signal-versus-repair specialist decision with Mara Flint, resolves the resulting forge-core dilemma, checks that promise after the fourth road, and carries the causal record into Debrief. The fixture covers save/resume at the unresolved crossroads, standard 1600×900 presentation, and a 1280×720 large-text/high-contrast/reduced-motion/alternate-controller profile. Evidence and remaining human questions are recorded in [`lm_i1_creative_vertical_report.md`](lm_i1_creative_vertical_report.md).

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

The active sequence is **LM-I1 Creative vertical**, **LM-I2 Region three**, **LM-I3 Region four/chassis**, **LM-I4 module/specialist/threat breadth**, **LM-I5 campaign memory/endings**, and **LM-I6 Early Access hardening**. Human validation may later calibrate pacing and recognition but is not a prerequisite for implementation.

## Decision

The investment target is a compact but complete campaign of moving-fortress journeys. We prefer four regions with real operational identities over a large empty continent, and a small number of consequences that visibly alter later play over a sprawling narrative layer with no mechanical memory.
