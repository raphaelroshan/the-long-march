# The Long March — Early Access Requirements

**Status:** Planning contract for a skeletal but commercially credible Early Access build  
**Current baseline:** High-quality moving-fortress foundation with three five-encounter chapters, settlement hubs, route planning, committed travel, road contacts, events, recovery, Debrief, persistent fortress state, deterministic simulation, accessibility, controller support, and private-alpha hardening.

## Product decision

The Long March should enter Early Access as a **small campaign of distinct journeys**, not merely two demonstrations of the same route shell. The current Ashgate and Flooded Veyru chapters are the quality anchors. Beyond them, the game needs thinner but complete regions that make fortress loadout, movement cost, information, route commitment, recovery, and social choices matter in different combinations.

A skeletal region may reuse the shared fortress renderer, temporary Tiny Town tiles, temporary foley, and existing transition components. It must still have its own route promise, settlement identity, threat pressure, event consequence, and terminal record. It cannot be only a new background with the same encounter table.

## Early Access breadth floor

| System | Early Access floor | Quality expectation |
|---|---:|---|
| Playable regions/chapters | 4 | Ashgate Lowlands, Flooded Veyru, and two thinner but complete regions. |
| Encounters | 20–24 total | Each chapter has a readable route rhythm with preparation, travel, contact/event, recovery, and result beats. |
| Fortress chassis/templates | 3 | Different spatial or resource constraints, not only different names. |
| Modules | 18–24 | Engines, weapons, workshops, signals, armor, cargo, and support systems with dependency trade-offs. |
| Specialists | 6–8 | Each changes an operational decision or creates a limitation, not only a passive bonus. |
| Threat families | 10–12 | Different targeting, pressure, information, movement, or dependency questions. |
| Routes | 14–18 | Alternate risk/reward paths, closure pressure, forecast uncertainty, and recovery implications. |
| Settlements | 8–10 | Each offers a recognizable service, regional promise, and at least one local cost or obligation. |
| Events/meetings | 20–24 | Deterministic branches that alter resources, trust, route access, condition, or future information. |
| Regional developments | 4–6 | Failure-forward changes that remain legible and affect later journeys. |
| Endings | 6+ composable outcomes | Results derive from survival, obligations, fortress condition, regional consequences, and choices. |
| Playable session | 45–120 minutes | A player can complete a chapter, make several route decisions, recover, and see a consequential result. |
| Replay value | 3+ credible loadout/route plans per chapter | Different plans should change dependency risk, travel posture, and recovery decisions. |

These are floors for Early Access, not a demand for a fully finished campaign. Skeletal content is acceptable when the loop is complete, the decision is real, and the limitation is honestly documented.

## Required player paths

The Early Access build must support four meaningful approaches:

1. **Reliable convoy:** favor fuel, workshop support, and predictable routes while accepting slower or lower-reward progress.
2. **Fast and exposed:** run a lighter, hotter, less redundant machine to reach high-value destinations before closures or storms.
3. **Information-led march:** invest in signals, specialists, and scouting to reduce uncertainty without eliminating risk.
4. **Scarred survivor:** continue after a failed contact or hard recovery, adapting the damaged fortress rather than restarting immediately.

No single module, specialist, route, or event choice may be required for every chapter. The campaign should make trade-offs visible and let a player recover from a poor plan through changed obligations, not a hidden optimal build.

## Region contract

Each new region is accepted only when it has:

- A distinct environmental/material promise and route-map silhouette.
- A settlement hub with at least two useful services and one meaningful limitation.
- Three or more route decisions, including one optional or dangerous path.
- At least two threat/event families that interact with fortress dependencies differently.
- One recovery choice that carries into a later encounter or terminal record.
- One failure-forward regional development.
- A complete no-debug journey from chapter start through Debrief.
- Save/load coverage at settlement, route, travel, contact, event, recovery, arrival, and Debrief boundaries.
- Screenshots at 1280×720 and 1600×900 plus reduced-motion and large-text evidence.

## Quality gates before Early Access

The existing Ashgate and Flooded Veyru quality anchors must remain intact. The Early Access candidate must additionally pass:

- A fresh-save complete run for every chapter.
- At least two materially different valid loadout/route plans per chapter.
- Deterministic replay across route choices, events, contact outcomes, pause/speed changes, and save/resume.
- No soft-lock after retreat, damaged modules, insufficient fuel, route closure, failed event choice, or depleted recovery materials.
- Clear above-fold explanation of route promise, committed costs, threat, target, damage, recovery, and terminal consequence.
- Full 1280×720, 1600×900, large-text, reduced-motion, keyboard, and controller coverage.
- Clean offline Windows package, save migration, backup recovery, provenance, checksum, and rollback evidence.
- A known-limitations document identifying skeletal regions, temporary assets, and deferred animation/audio work.

Human playtesting can be added later for confidence and calibration. It is not a blocking prerequisite for agents to implement the Early Access floor.

## Content production rule

Every new chapter, region, settlement, module, specialist, threat, event, or route is implemented as one narrow vertical slice. It must include stable IDs, runtime content, presentation copy, visual treatment, audio/feel mapping, deterministic tests, save coverage, a complete-flow fixture, and evidence captures. New systems must not bypass the existing command boundary or introduce a second state authority.

## Recommended order

**LM-EA-1:** complete in `0.3.0-alpha.350`. Ashgate and Flooded Veyru now have four command-only full-run plans, 64 exact save/load boundary checks, responsive Veyru coverage, and explicit regression protection for completed-contact history after a legal refit. See [`lm_ea_1_anchor_lock_report.md`](lm_ea_1_anchor_lock_report.md).

**LM-EA-2:** complete in `0.3.0-alpha.351`. The Cinder Spine adds a Blackkiln forge bazaar, six complete route plans, mass/heat/generator pressure, three threat families, Old Lift recovery, an inferno-opened refuge route, 34 exact save/load checks, responsive UI coverage, and the persistent Communal Lift Plan. See [`lm_ea_2_cinder_spine_report.md`](lm_ea_2_cinder_spine_report.md).

**LM-EA-3:** add a fourth region and one alternate fortress chassis/template.

**LM-EA-4:** add two module families, two specialists, and two threat families that create new dependency questions.

**LM-EA-5:** add event/meeting breadth, regional memory, replay goals, and composable endings.

**LM-EA-6:** harden campaign persistence, migration, controller/accessibility, package lifecycle, performance, audio, and Early Access release documentation.

## Non-negotiable boundaries

`LongMarchState` remains authoritative. Presentation, audio, particles, transition animation, and temporary art cannot change route outcomes, fuel, heat, pressure, damage, target selection, or save data. Information should reduce uncertainty without removing it. The fortress must remain a place with spatial consequences, and skeletal content must retain a real operational question rather than becoming decorative filler.
