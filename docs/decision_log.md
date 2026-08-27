# Decision Log — The Long March

## 2026-08-27 — Fourth project direction

We selected the walking-fortress inventory auto-battler as the fourth game target and kept the dungeon-and-shop inventory battler as a separate follow-up concept. The fortress has a clearer visual identity and a stronger reason for spatial inventory rules to exist.

## 2026-08-27 — One primary inventory space

The first prototype uses one chassis grid plus a small number of exterior mounts. A second full crew inventory was rejected for the vertical slice because it would create bookkeeping before the chassis dependency loop is proven.

## 2026-08-27 — Auto-battle with limited intervention

Combat resolves automatically, but the player sets power priority, target doctrine, travel posture, and one or more emergency orders. Direct unit control was rejected because it would move the project toward an action or real-time tactics game and weaken the packing decision.

## 2026-08-27 — Mobility as a hard constraint

The fortress must keep moving. A static high-durability build cannot be the universal strategy. Weight, fuel, route timing, heat, and repair cost remain meaningful even when the player has strong modules.

## 2026-08-27 — Recovery over hard failure

A damaged fortress can lose cargo, modules, time, or route access and still reach a settlement, repair, salvage, or accept a lower-value contract. Hard failure is reserved for an explicitly explained collapse state.

## 2026-08-27 — Content and runtime separation

`content/` contains authored IDs, descriptions, events, and progression. `src/core/` contains explicit simulation commands. Narrative strings are never executable scripts.

## 2026-08-27 — Facilities are dependency machines

The expanded building catalog treats facilities as interacting systems rather than passive bonuses. Boiler Heart, Generator Core, Ammunition Lift, Workshop, Signal Mast, Crew Quarters, Cargo Hold, Refugee Berths, and Firebreak Bulkhead create readable benefits and vulnerabilities. The production catalog is broader than the first slice; each future facility must enter through a narrow implementation and test.

## 2026-08-27 — FTL-like route map adapted to an overland march

The campaign map uses authored branching nodes with known, forecast, and unscouted visibility. A visible regional closure-pressure clock changes optional routes without deleting the only recovery path. This preserves route tension while keeping campaign balance and narrative guarantees under authorial control.

## 2026-08-27 — Regions are mechanical teaching chapters

The Ashgate Lowlands teach speed and cargo, the Flooded Veyru teaches condition and information, the Cinder Spine teaches heat and repair, the White Salt Expanse teaches visibility and trust, and the Meridian Refuge Corridor tests the player’s operating philosophy. Each region has settlements, route archetypes, a pressure source, and a boss gate.

## 2026-08-27 — Characters create legitimate conflicts

Crew members and factions are defined by a useful specialty, a belief about the fortress, and a pressure that competes with another valid priority. Mara, Iven, Sela, Tomas, Nera, and Orris form the core crew; Eda, Caldus, Jun, Anika, and Ravel extend the campaign. Character arcs must alter facilities, routes, contracts, or endings rather than only add dialogue.

## 2026-08-27 — Refit uses select-and-place actions

The first interactive refit uses the same deterministic placement commands for mouse, keyboard, and controller input. The player selects a module, previews a green or red footprint, confirms an empty cell to place or move it, and uses explicit rotate and remove actions. Invalid moves are atomic: the installed module stays in its prior position. Refit locks after departure so battle state cannot be altered through the presentation layer.

The starter palette exposes one instance of each vertical-slice module. Exterior-tagged modules automatically consume one of two exterior mounts and retain a bright chassis edge in this prototype. Dedicated exterior-slot presentation and dependency effects remain later slices.

## 2026-08-27 — Dependencies use readable adjacency plus a shared power bus

The first dependency graph uses orthogonal adjacency for fuel-to-engine, ammunition-to-weapon, crew-to-workshop, parts-to-workshop, and interior-signal-to-exterior-visibility relationships. Power remains a shared visible budget because the design explicitly rejects a full wiring puzzle at this stage.

A missing hard dependency makes a module offline when it cannot perform its core job, such as an engine without fuel or a workshop without crew. A missing soft dependency makes it strained, such as a weapon using emergency ammunition or a workshop applying a limited patch without parts. The chassis renders these states and exposes their reasons so layout consequences are not hidden.

## 2026-08-27 — Routes and doctrines must change outcomes

Route risk now combines authored route danger with mass, heat, and signal readiness. Heavy fortresses consume extra fuel, Run Hot increases pressure and thermal damage, and a ready signal system can reduce uncertainty. Protect Cargo and Protect Crew redirect defensive effort toward their named obligations rather than acting as flavor text. Vent Heat lowers current heat but temporarily exposes exterior systems.

## 2026-08-27 — Spatial targeting and armor produce causal reports

Threats score targets using module role, exterior exposure, chassis row, durability, and the active doctrine. Adjacent armor can absorb part of an attack, and the battle report records downstream dependency changes when damage disables fuel, ammunition, crew, power, repair, or visibility relationships.

## 2026-08-27 — The prototype run ends at Meridian Pass

The focused prototype is a two-leg run: Ashgate to Morrowline, two limited settlement service actions plus refitting, then a final Siege Beast encounter at Meridian Pass. This is intentionally smaller than the five-region campaign but large enough to prove preparation, consequence, recovery, adaptation, and a final result.

## 2026-08-27 — Saves use an explicit schema and JSON-safe positions

Prototype saves include a schema version and serialize grid positions as integer pairs rather than engine-specific Variant strings. Newer unsupported save versions fail safely. The verification suite performs a real JSON save/load during the UI-level complete-run test.

The prototype also treats the starter palette as a finite inventory. Removing a module returns that same instance to storage with its durability intact; it does not create a fresh replacement or erase battle damage. This keeps refitting tactically useful without turning it into a free repair exploit.

The module picker exposes whether each system is installed, stored, or lost together with current durability. Choosing an installed system selects its actual chassis position for inspection or movement; choosing a stored system enters placement mode. Permanently lost systems remain visible as disabled entries so the player can understand what changed without being offered an impossible action. If the selected system is lost, the picker falls back to the first usable module. The same control therefore acts as inventory, navigation, and a compact record of attrition instead of creating a misleading second copy of an installed module.

## 2026-08-27 — Playtest guidance teaches causality, not a winning recipe

The first-run briefing explains dependencies, route commitments, encounter reading, intervention limits, and recovery. A short phase-specific NEXT line remains visible after onboarding, but it does not prescribe a layout or route. Testers can reopen the briefing at any time, and completion is remembered locally.

The briefing is four short stages rather than five prose-heavy pages. Each stage pairs one concept with a concrete next action and a visible Command → Chassis → Route → Survive progress rail. The final action says Enter Ashgate and hands focus directly to the live contract, preserving teaching without delaying the first decision.

The persistent desk instruction is derived from the exact campaign state rather than only the broad phase. It advances from the Ashgate contract to route selection, route commitment, encounter action, recovery, and results, so completed work is never presented as the player's next task. The left-side idle message uses “No encounter underway” to avoid confusing an unanswered contract with combat contact.

## 2026-08-27 — Feedback collection is local and explicit

The prototype records a small local journal of gameplay decisions and outcomes. It contains no account, machine identifier, analytics SDK, or network upload. A tester may add two written answers and a replay score, then explicitly save a JSON bundle and decide whether to share it. This gives early playtests enough causal context without building production telemetry before consent and retention policies exist.

The result screen explains its classification before asking for feedback. A Scarred March names each missed decisive threshold—hull, surviving final contacts, or contract failure—while failure identifies hull loss or loss of operational movement. A short next-run prompt turns the result into a testable strategy without claiming there is one correct build.

The results feedback form uses explicit local-only actions, returns to the debrief rather than generically closing, and replaces a successful save action with `Save Again`. Its receipt shows the generated filename while retaining the full path as a tooltip, giving playtesters useful proof without filling the modal with machine-specific directory text.

Every exported feedback bundle records the exact application build at the top level and repeats it in the visible save receipt. Reports can therefore be matched to behavior after the repository has moved on, without asking the tester to copy a version string manually.

Closing and reopening the feedback form retains the last successful local filename and keeps `Save Again` available while the file still exists. The form falls back to its unsaved message if that file has been removed, so its receipt reflects durable state rather than only the most recent button press.

Timestamped feedback exports also probe for an existing filename and add an incrementing suffix when needed. Pressing `Save Again` rapidly now creates a second durable report instead of silently replacing the first one.

## 2026-08-27 — Tagged playtests produce desktop artifacts

Windows remains the primary product target. The repository also provides an unsigned macOS playtest preset so development sessions can run on the current platform. Tagged GitHub Actions runs build both artifacts; signing, notarization, Steam, and Epic publishing remain human-controlled release steps.

## 2026-08-27 — The alpha chapter is an authored five-encounter graph

The two-leg prototype is superseded by the Ashgate Lowlands alpha chapter. Every completed path now contains five encounters across an authored branching graph, with Morrowline as the guaranteed recovery settlement and Meridian Pass as the declared final commitment. Authored structure was chosen over procedural generation so pacing, route guarantees, content consequences, and deterministic tests remain legible while the core map loop is being proven.

## 2026-08-27 — Visibility is a promise, not cosmetic fog

Known nodes reveal exact threats, forecast nodes reveal hazard class and pressure, and unscouted nodes reveal only a broad warning. Reliable signal support or Iven Pell upgrades immediate information and reduces risk. The interface must not leak exact threat composition through labels, tooltips, or disabled controls when a node is unscouted.

## 2026-08-27 — Closure pressure removes advantage, not progression

Watch, Closing, and Break are visible regional pressure bands. At Break, the optional Signal Causeway may close without reliable forecasting, but Lower Ash Road remains available. This establishes the campaign rule that time pressure can remove a safer or more informative option but cannot silently delete the only recovery or progression route.

## 2026-08-27 — Contracts and specialists alter operating decisions

The first guard contract deliberately increases Morrowline encounter endurance in exchange for money and trust. Iven Pell requires a repaired relay, operational crew space, and supplies; in return he improves forecasts, storm mitigation, and late-route access. Both systems change loadout, route, and economy decisions rather than existing as dialogue-only rewards.

Iven's recruitment control follows the same visible-prerequisite rule as authored events. When recruitment is unavailable, the action names the exact missing relay, crew-space, location, staffing, or supply condition in its disabled state rather than relying on hover-only help.

Journey doctrine is explained as mechanics at selection time. Protect Cargo and Protect Crew name their targeting, mitigation, and matchup effects; Run Hot names its damage gain and thermal liabilities. When Run Hot crosses the heat limit, both the doctrine text and route Commit control show the predicted overheat before the player departs.

Locked authored choices state their prerequisite directly in the control instead of relying on a hover tooltip. Refuge capacity, signal capability, and Ashmark requirements are therefore visible to mouse, keyboard, controller, and touch players alike, and unavailable choices become useful build information for a later run.

Resolving an authored event returns its human-readable mechanical result from the simulation. The stage promotes that result into the above-fold consequence line before focusing the next road, so changes to fuel, trust, day, pressure, and route risk are visible at the moment they occur instead of being buried in the historical log.

## 2026-08-27 — Non-final defeat retreats to a viable state

A failed regional encounter returns the fortress to its last secured node with explicit time, money, and pressure penalties. A road crew restores only enough hull, fuel, engine, and fuel-module durability to make another decision possible. Meridian Pass remains a hard endpoint because it is presented as the chapter's final commitment; earlier failures remain recoverable and retain their consequences.

Morrowline's service controls expose the remaining action budget in the heading and disable choices that cannot succeed because the selected module or hull is already whole, funds are insufficient, or no actions remain. Module repair names the selected system, restored durability, and exact cost. Focus skips unavailable services so arrival never lands on a dead-end action.

The complete Morrowline controller loop is rebuilt from usable services and currently open roads. Fully repaired modules, unaffordable services, exhausted service slots, and closed routes are omitted; route commitment joins the loop only after the player deliberately selects a road.

Completed and blocked services write an immediate above-fold receipt. Successful receipts name the restored resource or module, Ashmark cost, and remaining action budget; failures name the blocking condition. Metric changes and prose confirmation therefore arrive together.

## 2026-08-27 — The campaign map is an interactive graph

The alpha presents the entire regional route graph instead of reducing each choice to a list. Node labels and borders distinguish current, secured, available, decision-blocked, closed, and future states; color is supporting information rather than the only signal. Route details update on both pointer hover and keyboard/controller focus, and only immediately reachable nodes accept input.

Route selection and departure are separate actions. Selecting a node highlights the road and preserves the current state while the player reviews time, fuel, risk, pressure, visibility, and doctrine. A dedicated commit control begins travel, preventing accidental departures and making controller navigation predictable.

The stage status names the selected road during that review, and controller B or Escape cancels the preview without changing campaign state. Focus returns to the same route node so comparing another path requires one deliberate movement rather than restarting navigation from elsewhere.

Route inspection remains available when the fortress cannot move. The selected route, desk order, detail copy, and disabled Commit control all state the exact fuel shortfall or fuel-connected-engine requirement. This keeps “learn about the road” separate from “pay its cost and leave,” making recovery failures diagnosable instead of turning the map inert.

## 2026-08-27 — Combat presents causes before spectacle

The alpha battle view uses enemy cards, arrival timing, target labels, counters, a six-step timeline, and the latest causal report lines. Targeted modules receive a visible chassis outline and every module shows durability. Emergency orders state both their benefit and cost. Animation and effects should reinforce this information later rather than replace it.

Combat timing is expressed relative to the present state. Approaching enemy cards count down the steps until arrival, the timeline distinguishes Done from Next, the primary button names the exact step it will resolve, and the desk order mentions either the nearest arrival or the systems currently under threat. This avoids asking the player to inspect a target that does not exist yet.

During combat, Advance, every currently available emergency order, and Field Briefing form one explicit vertical and Tab loop. Once the encounter's single intervention is spent, its disabled actions leave that loop automatically, keeping controller focus on commands that can still respond.

## 2026-08-27 — The application shell starts outside the simulation

The packaged build opens on a title menu instead of constructing a run immediately. Start Game creates a fresh Ashgate stage, Continue restores the explicit local save, and Escape opens a pause layer with resume, restart, and return-to-title actions. The shell owns these lifecycle transitions while `Main.tscn` remains the playable stage and `LongMarchState` remains presentation-independent. This keeps menu state from leaking into deterministic campaign state and leaves the stage independently testable.

Save, load, and reset controls remain callable by the test harness but are hidden from the live stage because the application shell now owns those operations. The pause menu groups safe continuation, persistence, reference, settings, and destructive session actions; it can reopen the field briefing without abandoning or mutating the current run.

The settings overlay is shared by the title and pause menus, but it names the context it was opened from and changes its return action accordingly. This avoids telling a player that an in-run action will return to the title when it actually restores the paused march.

Cancel input is resolved by the foremost application overlay before the underlying session state. Esc or a controller back action therefore closes in-run Settings and restores pause instead of reopening pause behind a still-visible settings panel.

One-shot settings actions such as resetting the completed briefing or clearing the only save disable themselves after success. Focus moves to the enabled return action instead of remaining attached to a control that can no longer be activated, preserving a complete keyboard and controller path.

Settings also maintains explicit vertical focus neighbors as those one-shot actions appear or disappear. Controller navigation skips unavailable actions, includes available ones in their visual order, and wraps from the return action to the first setting instead of depending on layout heuristics.

Settings consequences are visible beside their controls rather than existing only in hover tooltips. Title and briefing legends name controller and keyboard equivalents together, so a controller-first tester does not need to infer that keyboard-only copy also applies to the gamepad.

Controller A and B are explicitly mapped to the same accept and cancel actions as Enter and Escape. Cancel handling uses the general unhandled-input path rather than the keyboard-only callback, so gamepad B can close overlays, clear a route preview, pause, and resume exactly where the interface promises.

The first-run briefing and the in-run Field Briefing reuse one layout but have distinct semantics. First-run controls say `Skip Briefing` and `Enter Ashgate` and persist completion; reference mode says `Close Briefing` and `Return to March` and records only that the reference was closed. Re-reading help therefore cannot masquerade as onboarding progress.

The pause menu compares the live campaign snapshot with the local save whenever it opens or saves. A current checkpoint gets a direct `Return to Title` action; changed state is labeled `Exit Unsaved` and retains the explicit discard confirmation. This makes warnings meaningful instead of showing the same destructive language after a successful save.

Pausing also dismisses transient checkpoint toasts and presents fuel, hull, and heat beside the route position. The modal therefore becomes a stable decision snapshot rather than allowing short-lived notifications to overlap it or forcing the player to resume just to check whether the fortress is in immediate danger.

When a valid local save exists, the primary Continue action names its day and location before loading; the supporting line carries phase and encounter progress. This keeps the choice scannable while giving returning playtesters enough context to recognize the run they are about to resume.

That checkpoint line also includes saved fuel, hull, and heat. These are the three conditions most likely to change whether resuming feels viable, and exposing them on the title screen lets a returning player recognize a precarious march before loading into it.

The title classifies that snapshot as Stable, Watch, or Critical using the same fuel, hull, and heat thresholds emphasized in play. Color reinforces the label but never carries the meaning alone, preserving the status for color-blind players and text-only test assertions.

New campaign saves include the application build that created them. The Continue tooltip exposes that provenance while older compatible saves fall back to `earlier build`, allowing playtest reports and unexpected behavior to be traced without invalidating existing schema-compatible progress.

The title also shows the checkpoint's relative age using a save timestamp, with the file modification time as a compatibility fallback for older saves. Returning testers can distinguish a current run from stale local progress without opening it, while saves remain portable and schema-compatible.

When a schema-compatible checkpoint comes from a different application build, the title names that build in visible status text. The run remains loadable, but the provenance is no longer hidden behind a pointer tooltip and can be included in controller-first playtest reports.

The fresh-start actions also switch from `Start` to `New` when Continue progress exists. Their confirmation names the preserved day and location and explains exactly when a future automatic checkpoint will replace it, so the title screen does not hide the relationship between starting over and the single local save slot.

The title menu separates a guided first run from a briefing-free Quick Start. Quick Start suppresses onboarding only for that stage and does not write the onboarding marker, alter the deterministic seed, or touch the save. A field-guide overlay states the intended five-part test flow so repeated playtests can reach the actual decisions quickly without introducing simulation-only debug shortcuts.

The title presents that material as a chapter and field guide rather than as internal test tooling. Its no-save line follows the autosave preference: automatic checkpoints are explained when enabled, while manual saving through pause is named when disabled. This keeps the first screen truthful without exposing implementation vocabulary.

The Field Guide describes the rules a player must actually read in the interface: system-state colors, finite stored parts, route visibility tiers, previewed costs, one emergency order, limited recovery actions, and result thresholds. It remains a five-step orientation rather than expanding into a second manual.

The pause menu is a session boundary rather than a decorative overlay. It reports the current day, location, phase, and secured encounters; supports Save and Save & Return; and asks for confirmation before restart or return without saving. The safe cancellation action receives focus by default. This makes repeated tests faster while keeping accidental loss visible and reversible through the existing local save.

The playable stage includes a persistent Pause control in its header with the matching Esc and controller-B shortcuts. Mouse-first testers can discover saving, settings, briefing, restart, and title navigation without already knowing a hidden keyboard command; the shell remains the owner of the actual pause state.

The pause menu reserves a muted warning treatment for actions that currently discard progress. Restart always carries it; Exit Unsaved carries it only while the live state differs from the checkpoint, then returns to neutral styling as soon as saving makes the title transition safe.

## 2026-08-27 — The stage shows the whole run without hiding the next decision

The Marchmaster's Desk carries a persistent five-milestone tracker: Prep, Roads, Recover, Final, and Result. Completed, current, and upcoming milestones use both symbols and color. The tracker is explanatory rather than a second simulation state; its current position derives from the deterministic campaign state and is verified across a complete run.

Mandatory local decisions appear immediately below the current objective. In particular, the opening Ashgate contract sits above doctrine and refit controls so a new tester can act without scrolling. Optional configuration remains available after the blocking choice rather than visually competing with it.

The large stage status line names constructive phases—Ashgate Preparation, Local Decision, Morrowline Recovery, and Route Planning—instead of announcing that no encounter exists. Empty-state language is reserved for actual absence; normal downtime tells the player what kind of work is underway and what action advances it.

## 2026-08-27 — Focus follows the decision flow

Menu and stage transitions explicitly hand keyboard/controller focus to the next meaningful action: the opening contract, the first available route, route confirmation, encounter advancement, or final feedback. Pause records the previously focused stage control and restores it on resume. A fallback focus resolver activates whenever a refresh hides or disables the current owner, preventing focus from remaining trapped on an invisible control.

The title screen additionally defines explicit directional neighbors across its vertical start actions and horizontal utility row. Controller movement therefore follows the reading order and loops back to the primary action instead of depending on engine heuristics that can change with label width or save-state text.

That navigation graph updates with save availability. With no valid checkpoint, movement bypasses disabled Continue and links Quick Start directly to the utility row; once a save exists, Continue is restored to the same route. Disabled state never creates a controller dead end.

The title applies the same state-aware graph to Tab traversal. A valid Continue or invalid-save recovery action is inserted in visual order, while absent actions are removed and the remaining controls wrap cleanly from Quit back to Guided Start.

An unreadable or incompatible local save exposes a dedicated `Remove Unreadable Save` action directly beneath disabled Continue. Removal requires a confirmation that distinguishes the broken file from settings and briefing data; success returns focus to Guided Start and removes the temporary action from the navigation graph.

If validation changes between drawing the title and attempting Continue—for example because the file was externally replaced—the failed load refreshes the title and focuses `Remove Unreadable Save`. The recovery path remains immediate even under that race instead of sending focus to an unrelated new-run action.

The field guide, pause menu, and confirmation dialog use the same explicit-neighbor rule for paired actions and stacked rows. Their safe or primary control still receives focus on entry, while directional input now follows the visible grouping consistently across every application-level modal.

Modal navigation is closed over both directional input and Tab traversal. The field guide and confirmation dialog cannot hand focus to covered title or pause controls; the pause menu loops through its own actions; and the briefing and feedback form include only their currently available controls in their focus cycles.

Stage-owned overlays follow the same rule. The briefing routes around its disabled Previous action on page one, restores it on later pages, and wraps between close and progression actions; the feedback form links its return and save actions in both horizontal directions.

Focus handoff also scrolls the Marchmaster's Desk until the target control is fully visible. Logical focus alone was insufficient because the route map and later encounter actions can sit below the 720p fold. Automated flow coverage now checks both focus ownership and viewport containment after the contract and first route commitment.

Focus scrolling waits for one layout frame after phase changes before choosing its final position. Controls hidden between preparation, route review, and battle otherwise leave stale geometry behind, which can produce visibly sliced headings or icon rows even when the focused action itself is technically on screen.

When the focused action and current-order text fit in the viewport together, scrolling preserves both rather than aligning only the control. This matters for taller commitment cards and doctrine warnings: the player should never have to choose between seeing what to press and why they are pressing it.

Nested stage actions use an explicit bottom-edge scroll target instead of relying on `ScrollContainer.ensure_control_visible`. Godot 4.4 can under-scroll controls nested inside the campaign map even after layout settles, while newer engines happen to place them correctly. Calculating the required offset from the viewport and control rectangles makes the 720p focus guarantee stable on the pinned CI engine as well as the development engine.

Refitting exposes a visible `Edit Chassis` handoff instead of requiring a controller player to discover the grid through incidental focus traversal. Activating it places focus and the gold cursor on the selected module; arrows move the cursor, confirm selects or places, and cancel returns to the same desk action. The spatial editor remains direct with a mouse while becoming a deliberate, reversible mode on keyboard and controller.

Every planning phase builds one navigation loop from controls that are both visible and currently usable. Contract choices, doctrine, route commitment, refit actions, settlement services, local decisions, recruitable specialists, route nodes, and the field briefing therefore remain reachable without crossing a hidden or disabled control. Morrowline keeps refitting inside that loop rather than trapping controller users among service and route actions.

The chassis preview states its verdict before placement. A valid cursor position reports that confirm will apply the move, while an invalid position names the actual overlap, bounds, mount, or mass constraint next to the grid. Green and red remain supporting cues; the player no longer has to submit an invalid move merely to learn why it cannot work.

Occupied cells are described as selection targets rather than invalid destinations, matching the actual click and confirm behavior. The colored placement ghost appears only over empty cells, so selecting another installed system and moving the current one are visually distinct actions.

## 2026-08-27 — Continue is offered only for a readable compatible save

The application shell inspects local save JSON, schema version, and required campaign fields before enabling Continue. Missing, malformed, incomplete, or version-incompatible files receive a concise title-screen explanation. The stage load operation also returns success explicitly; an unexpected load failure returns to the title instead of leaving the player in a fresh state that could be mistaken for the saved run.

After the lightweight file checks, Continue validates the complete payload through `LongMarchState.load_serialized`. The title summary includes day, location, phase, and encounter progress, so a returning tester knows which decision will be restored before opening the stage.

## 2026-08-27 — Playtest preferences remain local and outside campaign state

The title screen exposes fullscreen mode, persisted reduced transition motion, briefing reset, and confirmed local-save clearing. These preferences live in a separate local configuration file and never enter deterministic campaign serialization. Destructive save clearing reuses the safe confirmation layer, while briefing reset affects only whether the guided introduction appears on the next run.

Settings are also reachable from the paused stage. Opening them temporarily replaces the pause panel while leaving the stage disabled; closing them returns focus to the pause menu and preserves the stage control that will be restored on resume. A tester therefore does not need to abandon the current run to change display or motion preferences.

Fullscreen joins reduced motion and autosave as a persisted device preference. The settings label follows the stored intent rather than sampling a potentially asynchronous window transition, keeping controller feedback immediate while the display server applies the requested mode.

## 2026-08-27 — Results close the application loop

The results phase places Record Playtest Notes, Play Again, and Return to Title immediately below the current objective. Replay constructs a clean deterministic Ashgate state and restores focus to the opening contract. Return to Title is emitted as a stage lifecycle request handled by the application shell, keeping the playable scene independently testable while avoiding a dead end after the final encounter.

Those three result actions form an explicit directional and Tab loop. The debrief therefore preserves the same controller guarantees as application-level menus and cannot strand focus among hidden controls from the completed run.

The exact application version appears on both the title and pause screens. A tester can therefore include the build identifier in a screenshot or written report even when the stage is paused, without depending on filenames or external release notes.

The title menu changes its primary action based on verified local state. Start Game is highlighted and focused when no compatible save exists; Continue becomes highlighted and focused after a manual or automatic save. This shortens the common resume path without making a corrupt save actionable.

Starting a Guided or Quick run while a valid save exists requires confirmation. With autosave enabled, the copy states that the old save remains intact until the new run reaches its first checkpoint. The safe cancellation action is labelled Keep Save and receives focus by default.

The same confirmation also appears when autosave is disabled. Its copy explains that the old checkpoint remains until the player manually saves or later enables autosave and reaches a checkpoint. Save protection therefore follows every path that can eventually replace the single local slot, not only the default settings path.

## 2026-08-27 — Autosaves follow confirmed state changes

The application writes a silent local checkpoint after meaningful committed actions: refit changes, contract answers, route departures, authored event choices, specialist recruitment, encounter advancement, emergency interventions, and successful settlement services. Merely selecting a module or previewing a route does not save. The stage emits checkpoint intent while the application shell owns file persistence, preserving the separation between simulation and lifecycle policy. The pause summary names the latest checkpoint so testers can tell what Continue will restore.

Automatic checkpoints default to enabled but can be disabled as a persisted local preference. When disabled, checkpoint signals are ignored and the pause screen explicitly directs the tester to Save March. Manual save behavior remains available regardless of the autosave preference.

Successful automatic checkpoints display a short corner notice naming the committed action. The notice does not take focus, pause play, or replace the event log, and respects reduced-motion settings by omitting its fade animation.

The checkpoint notice occupies the clear header space between the game title and Pause control. It must not cover a persistent action while acknowledging a save, especially during the contract-to-route transition when the player is likely to pause and inspect the new state.

Checkpoint reasons are translated from internal event identifiers into player-facing action names such as `Route Committed`, `Battle Step`, and `Emergency Order`. The same vocabulary appears in the transient toast and pause summary, keeping implementation identifiers out of the playtest experience.
