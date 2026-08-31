# The Long March

The Long March is a premium single-player Godot 4.x strategy roguelite about operating a mobile fortress across a ruined continent. The fortress is a spatial loadout: engines, weapons, workshops, crew rooms, armor, signals, and cargo must fit together while the machine remains light and reliable enough to move.

The battles resolve automatically, but the player chooses the fortress layout, route, power priority, target doctrine, travel posture, and emergency interventions. The intended question is not “Which item has the biggest number?” but **“Where can I place this useful part without making the whole fortress depend on it?”**

## Current prototype

The repository contains an agent-first Godot project with:

- A playtest-focused title flow with guided Ashgate, Flooded Veyru, chapter-aware Continue, and a concise Field Guide that can launch either chapter directly.
- An action-aware title preview that compares each chapter's obligation, pressure, recovery point, and finale, then turns Continue into an exact saved-decision summary.
- A session-safe pause menu with distinct Resume Here and phase-aware Go to Order paths, live run status, Save, Save & Return, field briefing, context-aware local playtest notes with a copyable export path, settings, and confirmation before discarding progress.
- A pause-accessible March Record that consolidates the current order, path, commitments, damage, and deterministic run ID without changing state.
- A persistent 100%/110% text-size preference with scroll-safe Settings and responsive title spacing at 1280×720.
- A persistent high-contrast mode that strengthens backdrops, muted copy, map/combat outlines, and focus without replacing written status labels.
- A persistent A-confirm/B-confirm controller preference that remaps accept/cancel and updates every visible shortcut while preserving Enter/Escape.
- Restrained focus, confirmation, warning, and checkpoint cues with a persistent mute/volume setting; every cue retains a visible equivalent.
- A read-only Build & Local Data panel exposing exact artifact identity, offline boundaries, local-file presence, and a copyable storage-folder path.
- A title-only clean-playtest reset that restores first-launch state while preserving tester-exported feedback reports.
- A fixed in-stage Pause action above the evidence scroll, keeping session controls pointer-accessible even while chassis focus scrolls the stage at large text.
- Pointer-opened Pause preserves the exact active stage control for Resume Here instead of replacing it with the Pause button itself.
- A persistent five-milestone run tracker, with the current mandatory decision kept above optional controls.
- A context-aware Go to Order control that returns focus and scroll position to the required contract, route, event, battle, recovery, or debrief action without activating it.
- Deliberate focus handoff across start, contracts, routes, encounters, results, and pause/resume for keyboard and controller playtests.
- Section-aware viewport scrolling with trailing focus room that keeps route, combat, recovery, and feedback actions visible without clipping the preceding context.
- Prominent post-run actions for feedback, replaying from Ashgate, or returning to the title screen.
- Exact build identifiers on title and pause screens for reproducible playtest reports.
- Consistent **Playtest Build** wording around those identifiers without duplicating the alpha channel or implying release readiness.
- Visible checkpoint age on the title screen so returning testers can recognize stale local progress.
- Silent local checkpoints after confirmed contracts, route departures, event choices, encounter steps, interventions, and settlement services.
- Brief phase-aware checkpoint notices that distinguish battle steps, secured roads, recovery arrivals, and ended runs without replacing gameplay explanations or covering Pause at large text.
- Full simulation-level save validation on the title screen, with incompatible or malformed saves explained instead of loaded as misleading fresh runs.
- Contextual title-menu priority: Start is primary for a new player, while a valid Continue save becomes the highlighted default.
- Confirmation before a new autosaved run can supersede an existing saved march.
- Local playtest settings, reachable from title or pause, for fullscreen, reduced transition motion, autosave, briefing reset, and confirmed save clearing.
- Settings grouped into Display & Readability, Controls & Feedback, and Runs & Local Data, with a fixed section breadcrumb that follows keyboard/controller focus.
- A playable opening stage at Ashgate Depot that begins with the fortress refit, convoy contract, and first route choice.
- A fortress-centered settlement bazaar at Ashgate Depot and Lantern Quay with six stable stations, plus a dedicated full-frame route planner with readiness on the left, the regional node graph in the center, and the selected-road dossier on the right.
- A dedicated field-recovery tableau at Morrowline and Evacuation Camp with the resting fortress centered, critical values held in a left ledger, exact before/after service commitments on the right, and a persistent post-service receipt.
- A mandatory side-on road presentation after route commitment that shows exact day, fuel, pressure, and heat receipts before the player enters the deterministic contact.
- A seven-step guided briefing that teaches command, engine/fuel, weapon/ammunition, workshop staffing/parts, signal visibility, routes, and contact response one relationship at a time.
- A directly navigable Field Briefing that reopens at the live contract, route, battle, recovery, or finale topic and preserves the run while players browse.
- A deterministic `LongMarchState` simulation.
- A 6-by-4 chassis grid and two exterior mount slots.
- Interactive refitting with a passive chassis-inspection state, an installed/stored durability-aware module picker that marks lost systems, and an explicit chassis-edit mode for place, rotate, move, and remove actions with mouse, keyboard, or controller navigation.
- Explicit dependency states for fuel-fed engines, ammunition-fed weapons, crew/parts-supported workshops, shared power, and signal visibility.
- Module placement, overlap checks, mass, power, heat, durability, and dependencies.
- An interactive visual campaign map showing current position, secured paths, available roads, closures, and known, forecast, or unscouted information, with route previews available even when fuel or movement blocks commitment.
- A test-focused command interface with resource cards, chapter and encounter progress, state-aware current orders, and distinct mouse/keyboard/controller focus states.
- Player-facing persistence and restart actions live in the pause menu instead of being duplicated among the campaign controls.
- Combat cards showing live enemy arrival countdowns, health or storm pressure, named targets, exact next-hit damage, counters, an explicit six-step timeline, and recent cause-and-effect.
- A controller-accessible battle inspection action that enters the chassis, jumps to active targets, and returns a selected system directly to the Seal Compartment order.
- Phase-aware chassis guidance plus a controller-accessible final-chassis review that lets debrief players inspect the surviving machine without implying that refit is still available.
- Compact Battle System, Final System, and refit-locked inspector hints that remain complete inside the fixed chassis detail column.
- Visible Watch, Closing, and Break pressure that can close an optional road without removing the only recovery path.
- Authored event choices that show unmet chassis or resource prerequisites directly on locked options.
- Specialist recruitment that names its unmet relay, crew-space, or supply requirement directly in the action.
- Immediate decision-consequence reports that state exact mechanical changes and the authoritative next route or recovery action above the fold.
- Mara Flint's one-core workbench decision now has a distinct machine-versus-shelter tableau, a fourth-road held/failed callback, and a matching forge-core record in the terminal Debrief.
- Pump Gallery frames its old-drain decision as one day held against two points of rising water, then carries that choice into the Veyru route record and Debrief.
- The Last Dry Room shows its single compartment split between families and repair stock, with exact trust, shelter, module-durability, and terminal-record consequences.
- Road Raiders, Climbers, Burrowers, Storm Fronts, and Siege Beasts.
- Shift Power, Seal Compartment, Vent Heat, and Cut Loose Cargo interventions.
- Doctrine descriptions that disclose targeting, damage, heat, and risk tradeoffs before route commitment.
- Repair and save/load behavior.
- A lightweight UI prototype showing the fortress and state summary.
- Structured campaign content in `content/content_manifest.json` and `content/gameplay_framework.json`.
- Deterministic headless tests in `tests/test_fortress_state.gd`.
- A complete five-encounter Ashgate Lowlands chapter with branching routes through Rill Crossing, The Soot Orchard, Broken Relay, Red Wheel Toll Bridge, Morrowline Camp, Lower Ash Road, and Signal Causeway.
- A separate five-encounter Flooded Veyru chapter with rising-water closures, a named medicine carrier, Evacuation Camp recovery, Flood Surge and Civic Guardian contacts, and a Dry Archive commitment.
- One bounded regional development: surviving after broadcasting the Dry Archive establishes a persistent Public Archive Signal that reveals Drowned Registry contacts on later Veyru runs without reducing their risk.
- A local two-chapter March Charter records each region's best terminal result and lets a debrief continue directly into the other playable chapter without conflating durable history with the Continue slot.
- Save-aware window closing: an unsaved live march pauses for a local Save & Quit decision, while a safe title or fully checkpointed run closes immediately.
- A temporary title return receipt distinguishes a saved checkpoint or debrief from discarded live changes and names whether an older Continue checkpoint remains.
- Separate title-only controls for resetting the March Charter, clearing Continue, and resetting the briefing without silently deleting unrelated local data.
- A validated predecessor backup for Continue, with explicit title recovery when the primary checkpoint is missing or corrupt.
- Stepwise encounter battle behavior for Road Raiders, Climbers, Burrowers, and Siege Beasts, including module counters, target selection, intervention, repair, and arrival/retreat outcomes.
- An Ashgate guard contract, three local route decisions, recruitable signal officer Iven Pell, and persistent settlement trust.
- Recoverable non-final defeats that retreat to the last secured node with explicit costs and a viable limping state.
- A Morrowline recovery phase with a visible two-action budget, availability-aware paid services, damaged-system repair guidance, free refitting, and a fifth Meridian Pass battle with decisive, scarred, or failed run results.
- Above-fold service receipts showing the exact restoration, Ashmark cost, and remaining recovery budget.
- A result debrief that opens with final-chassis review, then names missed success thresholds, retains the route and final operating record, and offers one concrete replay goal before feedback or replay.
- Versioned JSON save/load and an automated UI-level complete-run test.
- A first-run Marchmaster briefing, phase-specific guidance, and an opaque local-only playtest feedback form and bundle.
- An original visual kit in `assets/` for the journey background, Steam Lance Engine, Shell Cannon, Field Workshop, Signal Coil, and internal art direction.

## Run locally

Open the project in Godot 4.x or use:

```bash
bash scripts/verify.sh
```

Running the project opens on the title menu. Choose **Learn to Command** for the canonical First Watch tutorial, **Start Journey · Ashgate Lowlands** for the first full chapter, or **Flooded Veyru · Advanced Journey** for the second chapter. Tutorial progress uses its own checkpoint and cannot replace campaign **Continue**. Press Escape during a stage to pause, inspect the march record, save, restart, or safely return to the title.

With Godot export templates installed, create desktop playtest builds with:

```bash
bash scripts/export_playtest.sh windows
bash scripts/export_playtest.sh macos
```

The internal journey slice has been verified locally with Godot 4.4.1. On a development machine, install the pinned Godot version and run the same verification command before editing.

## Agent workflow

The current post-alpha agent handoff contract is [`docs/agent_handoff_roadmap.md`](docs/agent_handoff_roadmap.md). The game-quality transformation plan is [`docs/game_quality_transformation_plan.md`](docs/game_quality_transformation_plan.md), with the execution-first task order in [`docs/ai_game_quality_execution_plan.md`](docs/ai_game_quality_execution_plan.md); read them before prioritizing visual, UX, battle-feel, travel, settlement, or human-playtest work. Human testing is optional validation, not a prerequisite for the deterministic and presentation work. The versioned internal captures are preserved in [`docs/visual_evidence_gallery.md`](docs/visual_evidence_gallery.md), the standalone backer-facing archive concept is in [`docs/kickstarter_bonus_content.md`](docs/kickstarter_bonus_content.md), and the latest main-branch test findings are in [`docs/latest_test_report_2026-08-31.md`](docs/latest_test_report_2026-08-31.md) and [`docs/latest_visual_review_2026-08-31.md`](docs/latest_visual_review_2026-08-31.md). Read both together with `AGENTS.md`, `design/design_prompt.md`, and `design/gameplay_framework.md` before editing. Work in a narrow vertical slice, keep the simulation presentation-independent, update stable content IDs, add deterministic tests, and explain the player-facing result.

The recommended sequence is:

1. Stabilize placement, shape, rotation, and dependency checks.
2. Implement power, heat, fuel, and movement as visible state.
3. Add one threat doctrine and its counters.
4. Add one emergency intervention and recovery path.
5. Add settlement contracts, refit, salvage, and campaign transitions.
6. Expand modules, crew stories, and routes only after the core loop is reliable.

## Playable journey test release

The current build contains two isolated five-encounter test journeys. Ashgate begins at Ashgate Depot, recovers at Morrowline Camp, and ends at Meridian Pass. Flooded Veyru begins at Lantern Quay, recovers at Evacuation Camp, and ends at the Dry Archive. Their contracts are in [`design/ashgate_lowlands_alpha.md`](design/ashgate_lowlands_alpha.md) and [`design/flooded_veyru_alpha.md`](design/flooded_veyru_alpha.md); the release checklist is in [`docs/internal_test_release.md`](docs/internal_test_release.md). The generated asset roles and provenance notes are in [`assets/ASSETS.md`](assets/ASSETS.md).

The authoritative implemented-loop contract is [`design/functional_prototype_run.md`](design/functional_prototype_run.md).
The implemented presentation vertical slice—settlement hubs, dedicated journey planning, committed travel, contact staging, roadside events, and arrival tableaux—is specified in [`design/journey_presentation_vertical_slice.md`](design/journey_presentation_vertical_slice.md).
Its shared fortress layout and at-rest, map, moving, and encounter modes are specified in [`design/fortress_visual_modes.md`](design/fortress_visual_modes.md).
The current code-native fortress silhouette now carries module-family identity and ready, strained, offline, sealed, damaged, and targeted state across settlement, travel, contact, events, arrival, and Debrief.
Road contacts replay each resolved step through target lock, threat-specific wind-up, impact, and concise dependency consequence cues; Reduced Motion moves directly to the final consequence.
The tester workflow, privacy contract, and interview questions are in [`docs/playtest_guide.md`](docs/playtest_guide.md). The repeatable five-session sheet and capture matrix are in [`docs/private_alpha_session_sheet.md`](docs/private_alpha_session_sheet.md).

## Related follow-up concept

The dungeon-and-shop inventory battler remains a separate follow-up concept. It is not part of this repository. The Long March should first prove that a moving fortress creates a compelling spatial and strategic identity.

## Expanded design package

The current GPT-agent roadmap is [`docs/agent_handoff_roadmap.md`](docs/agent_handoff_roadmap.md); it records the implemented Ashgate and Flooded Veyru baseline and the next bounded regional-consequence, replay, UX, and alpha-hardening tasks.

The broader fortress plan is documented separately so agents can implement it in controlled slices. The game-quality plan should be used to decide how those systems become understandable and enjoyable in the player-facing journey:

- [`design/fortress_facilities_and_mechanics.md`](design/fortress_facilities_and_mechanics.md) — buildings, dependencies, budgets, staffing, damage, and recovery.
- [`design/map_regions_and_settlements.md`](design/map_regions_and_settlements.md) — FTL-like node map, visibility, closure pressure, regions, settlements, and route archetypes.
- [`design/characters_factions_and_campaign.md`](design/characters_factions_and_campaign.md) — crew, rivals, factions, campaign pressures, regional arcs, and endings.

The machine-readable campaign manifest now includes regions, settlements, extended character hooks, map rules, and authored events. Ashgate Lowlands and Flooded Veyru each have runtime graphs, regional pressure, contracts, recovery, finales, save validation, and deterministic tests; the remaining regions are design targets until implemented to the same standard.


## Temporary asset kit

The testing-only art, audio, VFX, and animation kit is documented in [`docs/temporary_asset_kit.md`](docs/temporary_asset_kit.md). Curated CC0 files are under [`assets/temporary/`](assets/temporary/), with machine-readable provenance in [`assets/temporary/manifest.json`](assets/temporary/manifest.json). The integrated transition sounds are listed in [`docs/audio_cue_map.md`](docs/audio_cue_map.md). These assets support journey breadth, transition timing, and feel testing; they are not the final moving-fortress or settlement art direction.
