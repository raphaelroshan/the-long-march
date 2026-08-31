# The Long March — AI Game-Quality Execution Plan

**Applies to:** `0.3.0-alpha.314` and later

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
| **L10 — complete in alpha.297** | Harden the private alpha | Verify saves, migration, clean install, controller, scaling, audio, performance, package provenance, offline behavior, and complete-flow evidence. Human sessions may be run afterward for calibration but do not block the artifact. |
| **L11 — complete in alpha.298** | Improve presentation clarity | Strengthen fortress state, travel rhythm, threat-to-target causality, settlement atmosphere, roadside framing, route decision hierarchy, and Debrief causality without changing authoritative simulation. |
| **L1 follow-up — complete in alpha.299** | Prove battle-to-recovery causality | Preserve the complete journey while keeping threat, target, wind-up, impact, dependency loss, arrival priority, and recovery action in one readable chain. |
| **Temporary sensory pass — complete in alpha.300** | Test journey acknowledgment and damage feel | Integrate a restrained, licensed subset of semantic audio and resolved-state VFX without allowing presentation to drive simulation. |
| **Travel atmosphere — complete in alpha.301** | Give the march physical phases | Separate gathering departure, full-march parallax, and static contact brace while suppressing motion effects under reduced motion. |
| **Arrival identity — complete in alpha.302** | Make reaching a place visible | Render destination-specific crossing, camp, relay, salvage, industrial, pass, and archive silhouettes from the authoritative destination ID. |
| **Threat silhouettes — complete in alpha.303** | Make contact actors readable | Give every implemented threat a stable physical form and approach lane while preserving the shared target and consequence grammar. |
| **Inhabited fortress at rest — complete in alpha.304** | Make the fortress feel like a working settlement | Add crew-scale service work, a crane, cart, valve exhaust, and restrained lamp motion while preserving reduced-motion behavior and simulation ownership. |
| **Route-map visual grammar — complete in alpha.305** | Make map state readable before dossier text | Add non-color node glyphs, directional route marks, future-route dashes, selected-route emphasis, and assignment badges derived from existing contract state. |
| **Roadside occurrence identity — complete in alpha.306** | Make every road decision physically specific | Replace the final generic occurrence symbol with authored boiler, ammunition-lift, and broken-wheel tableaux tied to the existing choices. |
| **Tutorial fortress continuity — complete in alpha.307** | Introduce the actual machine the player will command | Replace the prologue's placeholder box with the shared fortress actor, real module-family bays, dependency overlays, and departure stance. |
| **Threat-family audio identity — complete in alpha.308** | Make approaching contacts recognizable without watching a generic click | Route one restrained family cue at the readable warning step for all seven implemented threats, preserving the generic mechanism cue for other combat steps. |
| **Bazaar attendant identity — complete in alpha.309** | Make settlement services feel staffed rather than purely menu-driven | Give each of the six stable stations a compact attendant portrait, role, and prop that changes between Ashgate Depot and Lantern Quay. |
| **Route-specific travel landmarks — complete in alpha.310** | Make the in-between road foreshadow the chosen destination | Replace the generic passing object with stable crossing, orchard, relay, blockade, camp, lower-cut, cistern, quarry, pass, pump, tram, gantry, and archive motifs. |
| **Result-aware refit audio — complete in alpha.311** | Make physical editing outcomes legible without duplicate button sounds | Add distinct placement, rotation, removal, and blocked-action cues after the corresponding command result. |
| **Phase-aligned impact audio — complete in alpha.312** | Make a resolved hit land with the visible contact sequence | Trigger one material impact cue when the presentation reaches Impact, or immediately at Consequence under Reduced Motion. |
| **Named specialist identity — complete in alpha.313** | Make specialist choices feel like decisions about people, not detached bonus buttons | Put Iven's offer in the active Broken Relay planner and show Mara beside the forge throughout her authored decision chain. |
| **Specialist continuity — complete in alpha.314** | Keep a recruited specialist present after the choice resolves | Retain an assigned Iven or Mara card in route planning and leave an explicit Iven recruitment receipt. |

## Acceptance tests for every AI task

The agent must run the complete verification wrapper and the relevant focused tests. The same seed and command sequence must produce the same authoritative result across viewport size, text scale, contrast, motion setting, input device, pause, speed, manual-step, and screenshot capture. UI tests must assert focus reachability and visible bounds, not merely node existence.

A task is incomplete if a transition hides the current commitment, if a threat’s target or counter is unexplained, if an animation determines an outcome, if the fortress disappears behind a menu, if a required action clips at a supported viewport, or if content breadth is used to avoid fixing the journey loop. Automated evidence proves behavior and reproducibility; it does not claim human enjoyment.

## Recommended next prompt

> The automated roadmap, battle/recovery follow-up, temporary sensory feedback, route-specific travel landmarks, arrival identity, threat silhouettes, inhabited resting fortress, route-map visual grammar, roadside occurrence identity, tutorial fortress continuity, threat-family audio identity, bazaar attendant identity, result-aware refit audio, phase-aligned impact audio, named specialist identity, and specialist continuity are complete in `0.3.0-alpha.314`. The next work is evidence-led calibration from consented private-alpha sessions using `docs/private_alpha_session_sheet.md`. Fix observed comprehension, pacing, audio, or balance failures before adding another region or progression layer.

## Definition of game-quality readiness

The Long March is ready for private alpha when the complete journey is playable and understandable without debug actions, the fortress remains visually continuous across every mode, route and threat consequences are legible, recovery changes the next decision, settlements feel distinct, at least two viable journey plans exist, and the packaged artifact is reproducible. Human validation is an optional later confidence layer, not the condition for starting or completing this work.

## Historical evidence

The latest baseline is recorded in [`latest_visual_review_2026-08-31.md`](latest_visual_review_2026-08-31.md) and [`latest_test_report_2026-08-31.md`](latest_test_report_2026-08-31.md), and the versioned captures are in `docs/visual_evidence/`. The broader roadmap remains [`agent_handoff_roadmap.md`](agent_handoff_roadmap.md).

## References

[1]: agent_handoff_roadmap.md "The Long March Agent Handoff Roadmap"
[2]: game_quality_transformation_plan.md "The Long March Game-Quality Transformation Plan"
[3]: latest_test_report_2026-08-31.md "The Long March Latest Main Test Report"


## Latest verification update — 2026-08-31

The current `main` build `0.3.0-alpha.298` passes `scripts/verify.sh`, including the responsive journey profile, complete journey handoff, complete prototype flow, and Flooded Veyru flow. Fresh 1280×720 captures show the strongest opening presentation of the three projects: the moving-fortress premise, primary actions, First Watch framing, and introduction handoff are clear and coherent.

**Next mandatory task: L1 follow-up — Full journey evidence and battle causality.** Preserve the strong opening while proving the clean First Watch → refit → route → commitment → travel → contact/event → recovery → arrival → Debrief path. Then strengthen threat-to-target, wind-up, impact, dependency, and recovery explanation before adding another region or progression layer. Human testing remains optional and non-blocking.

## L1 follow-up completion — 2026-08-31

Build `0.3.0-alpha.299` completes the mandatory follow-up. The verified journey remains intact; contact now holds threat, target, counter, durability, and dependency change in one causal receipt, while arrival and recovery carry the exact damaged system and capability risk into the next player order. Full verification and both supported responsive profiles pass. The next evidence source is uncoached private-alpha observation, not additional campaign breadth.

## Temporary sensory-feedback completion — 2026-08-31

Build `0.3.0-alpha.300` integrates the licensed temporary kit selectively: semantic transition audio, a resolved-impact spark, and damage smoke. Tiny Town remains unused because it conflicts with the current art direction. Full verification passes, including mute and reduced-motion behavior.
