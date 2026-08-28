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

Choosing `Play Again` from results immediately creates a fresh Ashgate checkpoint when autosave is enabled. A crash or return to title before the next contract choice can therefore resume the new attempt instead of reopening the completed debrief the player explicitly left behind.

The debrief card retains a compact run record beside that explanation: the complete secured path, final closure pressure, contract state, specialist, and ready/strained/offline system counts. These facts remain readable next to the replay prompt instead of requiring the tester to reconstruct the run from separate status regions or the raw log.

A failed final road distinguishes secured progress from the place where the fortress stopped. Its summary identifies hull collapse, a destroyed engine, or the engine dependency that went offline; its replay prompt then recommends a matching hull or movement experiment. Failure guidance must follow the recorded cause rather than repeat a generic build tip.

The results feedback form uses explicit local-only actions, returns to the debrief rather than generically closing, and replaces a successful save action with `Save Again`. Its receipt shows the generated filename while retaining the full path as a tooltip, giving playtesters useful proof without filling the modal with machine-specific directory text.

The feedback form uses an opaque bordered modal surface rather than relying on the full-screen shade alone. Long prompts, text-entry fields, privacy copy, and save controls remain visually isolated from the dense result screen beneath them at the target 1280×720 resolution.

Every exported feedback bundle records the exact application build at the top level and repeats it in the visible save receipt. Reports can therefore be matched to behavior after the repository has moved on, without asking the tester to copy a version string manually.

Closing and reopening the feedback form retains the last successful local filename and keeps `Save Again` available while the file still exists. The form falls back to its unsaved message if that file has been removed, so its receipt reflects durable state rather than only the most recent button press.

Timestamped feedback exports also probe for an existing filename and add an incrementing suffix when needed. Pressing `Save Again` rapidly now creates a second durable report instead of silently replacing the first one.

## 2026-08-27 — Tagged playtests produce desktop artifacts

Windows remains the primary product target. The repository also provides an unsigned macOS playtest preset so development sessions can run on the current platform. Tagged GitHub Actions runs build both artifacts; signing, notarization, Steam, and Epic publishing remain human-controlled release steps.

The project version, Windows file/product versions, macOS bundle version, and CI release manifest are checked by one deterministic validator before Godot tests run. A version bump must update all packaged surfaces together so screenshots, saves, feedback reports, and release artifacts identify the same build.

## 2026-08-27 — The alpha chapter is an authored five-encounter graph

The two-leg prototype is superseded by the Ashgate Lowlands alpha chapter. Every completed path now contains five encounters across an authored branching graph, with Morrowline as the guaranteed recovery settlement and Meridian Pass as the declared final commitment. Authored structure was chosen over procedural generation so pacing, route guarantees, content consequences, and deterministic tests remain legible while the core map loop is being proven.

## 2026-08-27 — Visibility is a promise, not cosmetic fog

Known nodes reveal exact threats, forecast nodes reveal hazard class and pressure, and unscouted nodes reveal only a broad warning. Reliable signal support or Iven Pell upgrades immediate information and reduces risk. The interface must not leak exact threat composition through labels, tooltips, or disabled controls when a node is unscouted.

Forecast and unscouted route details state how the player can improve that information: ready forecasting gear or Iven Pell reveals exact contacts, lowers route risk by up to eight percentage points, and reduces encounter pressure by one. Closed Signal Causeway guidance names the same two recovery paths, turning uncertainty into a build or recruitment objective without revealing the hidden contact list.

Route inspection also breaks the current risk into authored baseline and player-controlled modifiers: blockade pressure, excess mass, overheat, earlier decisions, and forecasting. The heavy-fortress factor also names its additional fuel cost. Unscouted roads omit their hidden baseline and total while still naming visible modifiers, preserving uncertainty without obscuring the consequences of the player's own build and prior choices. Selecting a road collapses this explanatory detail so the map and Commit action remain adjacent.

## 2026-08-27 — Closure pressure removes advantage, not progression

Watch, Closing, and Break are visible regional pressure bands. At Break, the optional Signal Causeway may close without reliable forecasting, but Lower Ash Road remains available. This establishes the campaign rule that time pressure can remove a safer or more informative option but cannot silently delete the only recovery or progression route.

## 2026-08-27 — Contracts and specialists alter operating decisions

The first guard contract deliberately increases Morrowline encounter endurance in exchange for money and trust. Iven Pell requires a repaired relay, operational crew space, and supplies; in return he improves forecasts, storm mitigation, and late-route access. Both systems change loadout, route, and economy decisions rather than existing as dialogue-only rewards.

The two Ashgate contract actions are stacked full-width and carry their complete tradeoff. Guard explicitly previews one extra HP for every Morrowline enemy and the conditional 30-Ashmark/two-trust payout; Travel Unbound states that it avoids the extra endurance and forfeits that reward. The introductory prose now frames the decision instead of carrying mechanics that disappear once focus reaches a button.

Resolving the contract returns the same concrete combat and reward consequences from the simulation and promotes them into the stage's above-fold event receipt. Once the choice cards disappear, the player can still verify the commitment without reconstructing it from the status line or waiting to reach Morrowline.

Iven's recruitment control follows the same visible-prerequisite rule as authored events. When recruitment is unavailable, the action names the exact missing relay, crew-space, location, staffing, or supply condition in its disabled state rather than relying on hover-only help.

The recruitment control also carries Iven's mechanical offer in full: exact contact reveals, up to eight points of route-risk reduction, one less encounter pressure, and two anti-Storm damage. The benefits remain visible beside a lock reason, allowing a player who cannot recruit him to understand what that alternate build path would have changed.

Journey doctrine is explained as mechanics at selection time. Protect Cargo and Protect Crew name their targeting, mitigation, and matchup effects; Run Hot names its damage gain and thermal liabilities. When Run Hot crosses the heat limit, both the doctrine text and route Commit control show the predicted overheat before the player departs.

Locked authored choices state their prerequisite directly in the control instead of relying on a hover tooltip. Refuge capacity, signal capability, and Ashmark requirements are therefore visible to mouse, keyboard, controller, and touch players alike, and unavailable choices become useful build information for a later run.

Resolving an authored event returns its human-readable mechanical result from the simulation. The stage promotes that result into the above-fold consequence line before focusing the next road, so changes to fuel, trust, day, pressure, and route risk are visible at the moment they occur instead of being buried in the historical log.

Authored event buttons also show those exact resource changes before commitment. The consequence line remains visible even when a choice is locked, followed by its unmet prerequisite, so an unavailable option still teaches what the relevant module or resource would unlock on a later run.

## 2026-08-27 — Non-final defeat retreats to a viable state

A failed regional encounter returns the fortress to its last secured node with explicit time, money, and pressure penalties. A road crew restores only enough hull, fuel, engine, and fuel-module durability to make another decision possible. Meridian Pass remains a hard endpoint because it is presented as the chapter's final commitment; earlier failures remain recoverable and retain their consequences.

The retreat after-action line is generated from a structured simulation receipt rather than a fixed description. It names the actual Ashmarks removed, pressure and day added, hull and fuel before-and-after values, and every disabled mobility system raised to limping durability. This keeps partial charges and already-healthy resources truthful while making the next viable state auditable in the same place as the defeat.

Morrowline's service controls expose the remaining action budget in the heading and disable choices that cannot succeed because the selected module or hull is already whole, funds are insufficient, or no actions remain. Module repair names the selected system, restored durability, and exact cost. Focus skips unavailable services so arrival never lands on a dead-end action.

Disabled fuel, hull, and module services state whether the player has insufficient Ashmarks or has exhausted the shared service-action budget. These blockers appear in the controls themselves, not only in hover text, so controller and keyboard players can understand why a tempting recovery option is unavailable.

The complete Morrowline controller loop is rebuilt from usable services and currently open roads. Fully repaired modules, unaffordable services, exhausted service slots, and closed routes are omitted; route commitment joins the loop only after the player deliberately selects a road.

When the selected chassis system is already healthy but another installed system is damaged, the disabled Repair row names the most damaged candidate and its current durability. If nothing needs work it says `All systems full`. Recovery therefore points the player back to the exact Module entry that will enable repair instead of reporting only the irrelevant health of the current selection.

Completed and blocked services write an immediate above-fold receipt. Successful receipts name the restored resource or module, Ashmark cost, and remaining action budget; failures name the blocking condition. Metric changes and prose confirmation therefore arrive together.

## 2026-08-27 — The campaign map is an interactive graph

The alpha presents the entire regional route graph instead of reducing each choice to a list. Node labels and borders distinguish current, secured, available, decision-blocked, closed, and future states; color is supporting information rather than the only signal. Route details update on both pointer hover and keyboard/controller focus, and only immediately reachable nodes accept input.

Route selection and departure are separate actions. Selecting a node highlights the road and preserves the current state while the player reviews time, fuel, risk, pressure, visibility, and doctrine. A dedicated commit control begins travel, preventing accidental departures and making controller navigation predictable.

That Commit control sits directly beneath the campaign map. Earlier layouts placed it near doctrine controls at the top of the scrollable desk, visually separating the confirmation from the selected node and leaving a disabled route action above unrelated refit controls. Keeping preview, graph, and commitment together makes the sequence read as one decision.

Selecting a road also pins that road's detail above the map after focus moves to Commit. A previously focused node can no longer overwrite the selected destination during the same refresh, preventing a dangerous mismatch between the route named in the intel panel and the route named on the confirmation action.

The stage status names the selected road during that review, and controller B or Escape cancels the preview without changing campaign state. Focus returns to the same route node so comparing another path requires one deliberate movement rather than restarting navigation from elsewhere.

Route inspection remains available when the fortress cannot move. The selected route, desk order, detail copy, and disabled Commit control all state the exact fuel shortfall or fuel-connected-engine requirement. This keeps “learn about the road” separate from “pay its cost and leave,” making recovery failures diagnosable instead of turning the map inert.

## 2026-08-27 — Combat presents causes before spectacle

The alpha battle view uses enemy cards, arrival timing, target labels, counters, a six-step timeline, and the latest causal report lines. Targeted modules receive a visible chassis outline and every module shows durability. Emergency orders state both their benefit and cost. Animation and effects should reinforce this information later rather than replace it.

Enemy cards state the module classes each contact seeks as well as its counter. When Protect Cargo or Protect Crew changes the matching enemy's target scoring, the card names that guard directly. Target selection is therefore readable with keyboard or controller and does not hide its rule in a pointer-only tooltip.

The latest causal report preserves one complete incoming chain: mitigation immediately before the hit, the hit itself, and up to three subsequent dependency, repair, heat, or outcome lines. It scopes that receipt to the latest combat step and only falls back to recent general activity when no enemy impact occurred, preventing verbose weapon behavior from pushing the decisive failure off screen.

Combat timing is expressed relative to the present state. Approaching enemy cards count down the steps until arrival, the timeline distinguishes Done from Next, the primary button names the exact step it will resolve, and the desk order mentions either the nearest arrival or the systems currently under threat. This avoids asking the player to inspect a target that does not exist yet.

During combat, Advance, every currently available emergency order, and Field Briefing form one explicit vertical and Tab loop. Once the encounter's single intervention is spent, its disabled actions leave that loop automatically, keeping controller focus on commands that can still respond.

The encounter-order help also changes after that one intervention is spent. It stops instructing the player to choose an order, directs them back to the predicted damage and Advance action, and reminds them that the budget returns next encounter; a simultaneous hull threat keeps its exposed-hull warning.

Battle controls include a dedicated `Inspect Chassis` action in that loop. Keyboard and controller players can enter the grid, choose the system they intend to seal, and return directly to the matching Seal order; cancelling inspection returns to its visible desk action. Once the order is spent, the same control remains useful for reviewing damage without implying that refitting is available on the road.

The focused chassis names its mode explicitly. Planning phases say `Chassis Edit Mode`, while battles say `Chassis Inspection` and describe A/Enter as selection rather than editing. The same grid interaction can therefore serve both phases without promising an unavailable move or placement action.

Locked chassis guidance is phase-specific as well: battles mention damage and seal targets, results invite inspection of the surviving fortress, and map decisions explain that refitting resumes only at a road stop. The persistent chassis no longer labels every non-refit state as combat.

When contact is already active, the inspection action names the first threatened system and opens the chassis cursor on that module. Before contact it remains a neutral seal-target picker. The urgent target is therefore one action away for controller users while the full grid remains available for choosing a different defensive sacrifice.

When a new non-hull target first becomes active, it also becomes the default selected system for the Seal order. Subsequent refreshes do not overwrite a player's deliberate alternate selection; the automatic handoff happens only when the active target changes. The current order, Inspect Target action, chassis highlight, and Seal action therefore agree at first contact without removing tactical choice.

An active contact's preview shows the target's current and predicted durability, flags a disabling hit or hull collapse, and names any damage absorbed by adjacent armor. The player can therefore compare advancing with sealing or another emergency order before the deterministic step resolves.

If that predicted hit disables a dependency source, the same card names up to two downstream systems and their resulting Ready, Strained, or Offline state, with a count for any additional cascade. The preview temporarily evaluates the damaged layout and restores it immediately, so its warning uses the real dependency rules without changing the run before Advance is confirmed.

The persistent Current Order promotes the most severe imminent consequence from those previews: hull collapse first, then a disabled module and its dependency cascade, then a breaking armor plate. Its action language changes when the emergency order has already been spent, so a critical warning never recommends a control the player can no longer use.

When armor intercepts that hit, the preview names the specific plate and shows its own before-and-after durability, including a break warning. Armor is a second damaged system rather than an invisible subtraction, so sacrificing a plate to preserve a dependency is visible before the step resolves.

Hull-directed attacks explicitly state that sealing a module cannot prevent the current hit. Chassis inspection remains available for reviewing the surviving layout, but its action and encounter-order help describe the exposed hull so the player is steered toward a relevant intervention rather than a false defensive promise.

`Cut Loose Cargo` names the exact installed module that its deterministic priority will sacrifice before the player commits the once-per-encounter order. Its visible label also warns whether that means losing shelter, repair supply, or a fuel feed; the result report repeats the discarded module. A desperate mobility action should be costly, not opaque.

Combat describes the intervention budget consistently as one emergency order rather than exposing the underlying two-point legacy value beside a once-per-encounter lock. After any order, the immediate report names its concrete outcome: power and heat change, sealed module and downtime, heat removed and exposure, or discarded cargo and reduced incentive.

That exact outcome is authored once by the simulation and reused by both the immediate status line and the lasting encounter report. The explanation therefore survives the next input, enters saved deterministic state and playtest evidence, and cannot drift between two UI-specific summaries.

The combat header names the next action as `Next step 1/6` rather than presenting the internal zero-based count as `Step 0/6`. Header, timeline, and Advance button now agree before and after every resolution.

The Advance button previews immediate contact. When an approaching threat reaches the fortress on the next step, the action names it before confirmation; once contact is active, it names the threatened system. Ordinary travel steps remain concise. This puts the irreversible consequence on the control itself without replacing the fuller enemy cards and current-order guidance.

The matching timeline cell changes from `Next` to `Contact` and uses the danger treatment when that step contains an arrival. This creates one consistent warning across the enemy countdown, timeline, and Advance action instead of making the player reconcile three differently phrased clocks.

Enemy contact cards translate simulation target IDs into the installed system's authored display name. The warning now says `TARGET COAL CELL` rather than leaking `coal_cell`, matching the Advance action and chassis labels while leaving deterministic combat state unchanged.

Once contact is active, each enemy card also shows the exact next-hit damage after pressure, adjacent armor, doctrine mitigation, overheating, vent exposure, and Siege Beast armor rules. The preview and damage application share one simulation calculation, preventing a reassuring estimate from drifting away from the result that the next Advance will apply.

Campaign progress distinguishes an active encounter from completed progress. During the first fight the header says `Encounter 1/5 underway`; between roads it says `1/5 encounters secured`. The progress bar continues to represent secured encounters, avoiding the previous `Encounter 0/5` label while the player was visibly already in combat.

The blockade summary uses the same vocabulary and reports `secured 0/5` during that first fight. Its count tracks the progress bar rather than the active encounter number, so the two simultaneous values describe different states explicitly instead of appearing to disagree.

During battle, the road breadcrumb includes the active destination before that node is marked secured in simulation state. `Ashgate Depot → Rill Crossing` therefore matches the separately named current node throughout the fight; completing it still remains the moment that permanently extends the campaign path.

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

The title presents that material as a chapter and field guide rather than as internal test tooling. Its no-save line follows the autosave preference: automatic checkpoints are explained when enabled, while manual saving through pause is named when disabled. Continue is omitted until a readable checkpoint exists, so the primary action stack contains choices the player can actually take instead of spending a full row restating the no-save message.

A saved results screen appears on the title as `View Result` with its Decisive, Scarred, or Failed outcome instead of masquerading as an active `Continue` checkpoint. It remains reopenable for debrief and feedback, while the adjacent new-run actions make the next campaign path explicit.

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

That navigation graph updates with save availability. With no valid checkpoint, Continue is absent and Quick Start links directly to the utility row; once a save exists, Continue is restored at the top of the same route. Missing state never creates a controller dead end or a dead visual action.

The title applies the same state-aware graph to Tab traversal. A valid Continue or invalid-save recovery action is inserted in visual order, while absent actions are removed and the remaining controls wrap cleanly from Quit back to Guided Start.

An unreadable or incompatible local save replaces Continue with a dedicated `Remove Unreadable Save` action. Removal requires a confirmation that distinguishes the broken file from settings and briefing data; success returns focus to Guided Start and removes the temporary action from the navigation graph.

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

Every module definition also carries a concise capability statement grounded in implemented rules. The selected-module summary names actual damage values, forecasting, repair, armor, movement, power, rescue, and adjacency behavior beside size and operating state, so refitting does not require memorizing the field guide or inferring purpose from tags.

Module power uses signed player-facing notation in both refit summaries: producers show `+N`, consumers show `−N`, and passive systems show `0`. A Generator Core no longer appears to have zero power value merely because the previous line read only its consumption field.

Occupied cells are described as selection targets rather than invalid destinations, matching the actual click and confirm behavior. The colored placement ghost appears only over empty cells, so selecting another installed system and moving the current one are visually distinct actions.

The chassis heading reports exterior mounts used against the two-mount limit in both refit and inspection modes. The bright module edge still identifies which systems consume those mounts, while the numeric count lets a player assess remaining capacity before selecting another exterior weapon or signal unit.

Selecting a stored module moves the chassis cursor to the first geometrically open footprint, even when mass or mount capacity still blocks installation. The grid therefore shows the relevant placement failure immediately instead of leaving the cursor on an unrelated installed system; the text summary independently names how much mass must be removed or whether an exterior mount must be freed.

Every interactive control in the Marchmaster's Desk requests contextual scrolling when it receives focus, including focus reached through ordinary keyboard or controller navigation. Programmatic phase handoffs and manual navigation now share the same visibility rule, and deferred scroll requests are ignored if focus has already moved elsewhere.

Chassis cancel is scoped to the refit mode. During preparation or recovery it returns from the grid to `Edit Chassis`; while refitting is locked, the grid does not consume B or Escape, leaving the application shell free to open the pause menu as its persistent control hint promises.

Entering chassis edit mode scrolls the left-hand workspace until the complete grid is visible. This is independent from the right-hand command-desk scrolling, so a player can move between route or recovery controls and spatial refitting without inheriting an obscured chassis from earlier report browsing.

Route hover and focus publish their full scouting report into a dedicated summary immediately above the regional chart. The map no longer reserves a hidden footer for that information, making the chart shorter and keeping route cost, risk, pressure, visibility, and threat detail close to the node being inspected.

Unscouted routes preserve their uncertainty through commitment. Their preview and Commit action reveal known time, fuel, broad danger, and projected fortress heat, but withhold exact risk, pressure gain, reward, and enemy composition until the road begins. Forecast and known routes continue to expose the information their scouting level permits.

Exact risk values are paired with Low, Guarded, or High bands. The percentage remains available for deliberate planning, while the worded band makes the relative danger legible at a glance and does not introduce false precision on unscouted roads.

Route-intel text also carries a consistent scan color: green for Low, amber for Guarded, red for High or blocked departure, and violet for genuinely unknown information. The written state remains mandatory, so color accelerates comparison without becoming the only way to read risk.

Reachable map nodes include a compact scouting-and-risk line before the player focuses either road. Known and forecast routes show their Low, Guarded, or High band; unscouted roads say Unknown. The full intel panel remains the source for exact costs and consequences, but the graph itself now supports a first-pass comparison instead of forcing players to memorize one hover state at a time.

The route Commit action carries the same semantics as the intel it confirms: green for Low, amber for Guarded, red for High or a blocked/overheated departure, and violet for Unknown. Its text still names the state, so the color reinforces the consequence without becoming a hidden code.

Once the player completes the Marchmaster briefing, the title collapses Guided Start and Quick Start into one direct Ashgate action. The two buttons otherwise launch the same unbriefed stage because the completion marker suppresses onboarding; hiding the duplicate keeps the first menu honest and shorter. Reset Briefing in Settings immediately restores both first-run choices and their controller navigation.

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

When Continue becomes primary, it also moves to the top of the visible action stack and the controller/Tab order follows that layout. A returning player no longer lands on a highlighted action below two fresh-run choices, while new players still see Guided Start first.

Starting a Guided or Quick run while a valid save exists requires confirmation. With autosave enabled, the copy states that the old save remains intact until the new run reaches its first checkpoint. The safe cancellation action is labelled Keep Save and receives focus by default.

The same confirmation also appears when autosave is disabled. Its copy explains that the old checkpoint remains until the player manually saves or later enables autosave and reaches a checkpoint. Save protection therefore follows every path that can eventually replace the single local slot, not only the default settings path.

## 2026-08-27 — Autosaves follow confirmed state changes

The application writes a silent local checkpoint after meaningful committed actions: refit changes, contract answers, route departures, authored event choices, specialist recruitment, encounter advancement, emergency interventions, and successful settlement services. Merely selecting a module or previewing a route does not save. The stage emits checkpoint intent while the application shell owns file persistence, preserving the separation between simulation and lifecycle policy. The pause summary names the latest checkpoint so testers can tell what Continue will restore.

Automatic checkpoints default to enabled but can be disabled as a persisted local preference. When disabled, checkpoint signals are ignored and the pause screen explicitly directs the tester to Save March. Manual save behavior remains available regardless of the autosave preference.

Successful automatic checkpoints display a short corner notice naming the committed action. The notice does not take focus, pause play, or replace the event log, and respects reduced-motion settings by omitting its fade animation.

The checkpoint notice occupies the clear header space between the game title and Pause control. It must not cover a persistent action while acknowledging a save, especially during the contract-to-route transition when the player is likely to pause and inspect the new state.

Checkpoint reasons are translated from internal event identifiers into player-facing action names such as `Route Committed`, `Battle Step`, and `Emergency Order`. The same vocabulary appears in the transient toast and pause summary, keeping implementation identifiers out of the playtest experience.

## 2026-08-28 — Sealing a target redirects threats immediately

Seal Compartment resolves its targeting consequence in the same committed action. Any arrived threat aimed at the sealed system immediately chooses a valid replacement, and the emergency-order receipt names each redirection. Enemy cards, chassis highlighting, current guidance, and impact forecasts therefore agree before the player advances; the next combat step no longer silently corrects stale information that was presented as a prediction.

## 2026-08-28 — The Seal order previews its redirected threat

The selected module's Seal Compartment control previews every active threat that would be redirected and its replacement target before the order is spent. The forecast is calculated without mutating the encounter and uses the same deterministic targeting rules as resolution. Sealing a system that is not currently targeted remains available and is explicitly described as preventative rather than implying an immediate benefit.

## 2026-08-28 — Cargo sacrifice resolves targeting immediately

Cut Loose Cargo now applies the same atomic targeting rule as Seal Compartment. If the discarded module was under attack, affected threats choose their replacement targets during the emergency order, and both the receipt and persistent combat report name the redirection. The chassis, enemy cards, current order, and next-hit forecast cannot point at cargo that no longer exists.

## 2026-08-28 — Cargo sacrifice previews both losses

The emergency-order guidance now previews Cut Loose Cargo alongside Seal Compartment. It names the deterministic cargo module that will be removed, the capability lost with it, and any active threat's replacement target. This keeps the permanent build cost and immediate defensive benefit visible together before the once-per-encounter order is committed.

## 2026-08-28 — Vent Heat reports the actual exchange

Vent Heat derives its displayed cooling from the live fortress state instead of promising a fixed three-point reduction when less heat is present. Before commitment, the order guidance also names every active exterior target whose next hit will gain one damage and shows the before-and-after damage. The completed-order receipt retains that exposure, keeping the immediate benefit and combat liability together.

## 2026-08-28 — Shift Power previews total attack output

Shift Power compares each surviving contact's current incoming fortress damage with the weapon-priority result and reports the exact heat change before commitment. Duplicate contacts with the same result are collapsed in the command-desk copy. The completed-order receipt preserves those totals, clarifying that the one-point bonus applies to each operational weapon rather than once to the fortress as a whole.

## 2026-08-28 — Emergency-order detail follows focus and hover

The command desk no longer displays four dense forecasts simultaneously. Its resting copy explains how to inspect an order and names the current Seal target; focusing or hovering Shift Power, Seal Compartment, Vent Heat, or Cut Loose Cargo replaces that copy with only the selected action's exact benefit and cost. Keyboard, controller, and pointer interactions use the same preview data, and leaving the order controls restores the concise overview.

## 2026-08-28 — Recovery services report delivered value

Morrowline's hull service calculates the actual durability restored before presenting or recording the action. A fortress at 9/10 hull therefore sees and receives `+1 hull` for the fixed service cost rather than being told that two points were delivered. This keeps the scarce two-action recovery budget numerically trustworthy at the health cap.

## 2026-08-28 — Repair recommendations are actionable handoffs

When the currently inspected module is healthy but another installed system is damaged, the Morrowline repair row becomes a no-cost selection action instead of a disabled instruction. Activating it moves chassis and module-list context to the most damaged system, reveals the exact durability and Ashmark repair offer, retains focus on the same row, and spends no service action until the player confirms again.

## 2026-08-28 — Route commitment shows the state after departure

The Commit control presents day, fuel, and known pressure as before-and-after values rather than isolated costs. Unscouted routes preserve unknown risk and pressure while still showing the resource balances the crew can calculate. Meridian Pass uses a distinct `Final Commit` label and states that failure ends the run with no retreat before the player confirms the chapter's final encounter.

## 2026-08-28 — Debrief advice follows actual victory thresholds

Result copy now treats final-contact defeat and seven remaining hull as the decisive thresholds implemented by the simulation. Contract status is recorded as run context rather than incorrectly presented as a victory requirement. Scarred runs distinguish hull-shortfall and surviving-contact causes; contact-only results name the remaining threat and its authored counter, while hull-shortfall results state exactly how many more hull points the next run needs.

## 2026-08-28 — Run records name system condition

The result card records the final doctrine and names every damaged or unavailable installed system with current durability and the first dependency reason. Aggregate ready, strained, and offline counts remain for scanning, but replay diagnosis no longer requires the tester to reconstruct specific system failures from the chassis after the run has ended.

## 2026-08-28 — Replay confirms before replacing Continue

Play Again from the result screen uses the application confirmation layer before resetting the stage. With autosave enabled, the dialog states that Continue will immediately switch to the fresh Ashgate checkpoint; with autosave disabled, it explains that the completed checkpoint remains until a later save. Cancelling restores the intact result and focus, while saved local feedback files remain independent from campaign state.

## 2026-08-28 — Blocked departure names the broken movement chain

When no engine can move the fortress, selected-route guidance now reuses the exact movement diagnosis shown at failure: the installed engine, its durability when destroyed, or its first missing dependency such as an adjacent Coal Cell. The map remains inspectable while blocked, but the Commit control and route summary point back to a concrete chassis correction instead of the generic instruction to restore an engine.

## 2026-08-28 — The title counts the finale inside the chapter

The Ashgate overview states that the chapter contains five encounters total, with recovery after the third encounter and the finale at encounter five. This removes the earlier suggestion that five encounters were followed by a separate sixth final battle and gives first-time players an accurate picture of the playable run before they start.

## 2026-08-28 — Completed title checkpoints become replay choices

A completed checkpoint changes the title's fresh-run actions to Play Again and Quick Replay. Starting either path uses result-aware confirmation copy, names the saved outcome, and defaults to Keep Result. Active checkpoints retain New Game and Keep Save language, so the shell distinguishes replaying a finished run from abandoning an unfinished one.

## 2026-08-28 — Restart warnings reflect actual recovery

Restart confirmation inspects the local checkpoint before describing what survives. With a compatible save it names the saved day and location, or completed result, and explains when the restarted run can replace it. Without a usable checkpoint it explicitly warns that there is nothing to return to, avoiding false reassurance on a player's first unsaved attempt.

## 2026-08-28 — Skipping does not complete the briefing

The first-run briefing distinguishes temporary dismissal from completion. Skip and B/Esc now close it for the current run without writing the completed marker, while advancing through all four cards still suppresses it on later guided starts. This prevents an accidental cancel input from permanently hiding onboarding and keeps the existing Settings reset limited to genuinely completed briefings.

## 2026-08-28 — Control hints describe the current screen

The title footer describes directional navigation, confirmation, and closing title panels. It no longer borrows the in-stage claim that B/Esc pauses the game, which was inaccurate while no march was running. Pause and briefing overlays retain their own contextual cancel hints.

## 2026-08-28 — Guide-launched confirmations return to the guide

Quick Start can be launched from either the title action stack or the Field Guide. When an existing checkpoint requires confirmation, cancelling now restores focus to the visible guide action if that panel is still open; title-launched cancellations still return to the title's Quick Start action. This prevents keyboard and controller focus from landing behind the active overlay.

## 2026-08-28 — Quick Start preserves checkpoint semantics, not files

The Field Guide now states that Quick Start changes only whether the introductory briefing opens. Simulation, seed, route graph, and checkpoint rules remain identical. It no longer claims that Quick Start cannot change the save file, since a fresh run can legitimately replace Continue after its first automatic or manual checkpoint.

## 2026-08-28 — Field Guide launch language follows save state

The Field Guide's Ashgate action mirrors the title state: Quick Start when no checkpoint exists, Start New Ashgate Run while an active march is saved, and Quick Replay after a completed result. Confirmation behavior is unchanged, but the button now communicates whether it resumes nothing, branches away from active progress, or begins another attempt.

## 2026-08-28 — Feedback starts with a first-save receipt

An untouched playtest form now says to save a local copy when ready. The previous empty state incorrectly said the tester could “save again” before any feedback file existed. Saved and reopened forms still retain their filename and explicit Save Again action.

## 2026-08-28 — Results save before returning to title

The completed-run action is explicitly labelled Save Result & Return and writes the result to the local Continue slot before emitting the title transition. This protects a finished run when automatic checkpoints are disabled. If the write fails, the result remains open with a visible error instead of silently leaving; the pause menu remains the deliberate route for exiting without saving.

## 2026-08-28 — Replay warnings inspect the actual Continue slot

Play Again confirmation distinguishes a result already saved under Continue, an older checkpoint that does not contain the result, and no usable checkpoint. It also states whether automatic checkpoints will replace the slot immediately or manual saving will leave it intact. The dialog no longer assumes that finishing a run automatically persisted it when autosave was disabled or a write failed.

## 2026-08-28 — Terminal failure remains visible in the run rail

When Meridian Pass ends in March Failed, the Final stage uses a red failed marker while Result remains the current step. Decisive and scarred crossings still show Final as completed. The persistent run-flow summary therefore no longer contradicts the failure debrief by awarding a green completion check to the terminal battle.

## 2026-08-28 — Recovery budgets use one shared grammatical status

Morrowline guidance and completed-service receipts derive “0 service actions remain,” “1 service action remains,” and “2 service actions remain” from one helper. The campaign route preview also keeps the recovery budget visible until a road is selected, rather than immediately reverting to generic map-selection copy at the settlement.

## 2026-08-28 — Retreat recovery remains the current order

After a non-final forced retreat, the command desk tells the player to review the exact losses and patched movement chain before refitting or choosing another road. A retreat to Morrowline also retains the remaining service budget in that instruction. Selecting a new route still advances guidance to the normal route-ready state, so the recovery explanation persists only until the player deliberately moves on.

## 2026-08-28 — Shared instructions stay input-neutral and natural

Removing a module now asks the player to choose an empty chassis cell rather than assuming a mouse click. Route intel and after-action reports also render real singular and plural day and step counts instead of exposing placeholder forms such as `day(s)` and `step(s)`. Tooltips, keyboard focus, and visible receipts therefore use the same natural language across input methods.

## 2026-08-28 — A fresh run explains its first checkpoint

Before the player commits any decision, the pause menu now states that there is no decision checkpoint yet and names both ways forward: commit a choice for the automatic checkpoint or use Save March immediately. This preserves the deliberate committed-decision autosave boundary without leaving a new player to interpret a bare unsaved warning.

## 2026-08-28 — The pause shortcut reflects nested controls

The persistent Pause action no longer advertises B or Escape while those inputs belong to chassis inspection or an open route review. Its visible state and tooltip explain which nested interaction will close first; once that interaction ends, the normal pause shortcut returns. The button itself remains an immediate pointer-accessible route to Pause in every state.

## 2026-08-28 — Battle headings distinguish approach from contact

The combat panel uses Contact Approaching until an undefeated enemy has actually reached the fortress, then changes to Active Contact. This aligns the encounter heading with arrival countdowns, timeline warnings, target forecasts, and damage timing instead of declaring contact several steps early.

## 2026-08-28 — Route cancellation is visible without hover

Selecting a route now keeps `B/Esc cancels selection` in both the route-review receipt and the state-derived current order, including when departure is blocked. Controller and keyboard players can therefore discover the reversible preview boundary from visible text instead of relying on the Pause button tooltip.

## 2026-08-28 — Every terminal outcome opens a debrief

The result frame and current order use March Debrief and Debrief rather than the success-coded Run Complete heading. Decisive, scarred, and failed outcomes still state their specific classification and cause inside that neutral frame, so a terminal loss is reviewed rather than accidentally congratulated.

## 2026-08-28 — Recovery copy retains the live service budget

The persistent Morrowline recovery receipt now derives its action count from the current settlement state. After a service or any later interface refresh, it says zero, one, or two actions remain instead of reverting to the original “up to two” allowance.

## 2026-08-28 — Route review supersedes the previous encounter

An after-action receipt remains above the fold while the player is deciding what to do next, including after a forced retreat. Once a new route is deliberately selected, the visible receipt switches to that route’s review and cancellation instructions; cancelling the preview restores the prior after-action. This keeps history available without letting it mask the current irreversible decision.

## 2026-08-28 — Authored events own the blocking instruction

When a road event prevents departure, the above-fold receipt now names that event and asks for a response instead of continuing to headline the encounter that has already ended. The exact event consequence still replaces it after the choice, preserving the decision-to-result chain without letting historical combat copy mask the current blocker.

## 2026-08-28 — Manual saves remain explicit when autosave is off

The pause status now evaluates whether the live run matches the local save before warning about disabled autosave. A matching manual checkpoint is acknowledged as saved while still noting that future decisions will not checkpoint automatically; only changed or never-saved state asks the player to use Save March.

## 2026-08-28 — The title overview matches the first playable gate

The first chapter step is Prepare at Ashgate: inspect connected systems, then answer the convoy contract. This keeps chassis preparation in the promise while matching the actual contract-first focus handoff, rather than presenting inspection as a mandatory gate the stage does not enforce.

## 2026-08-28 — Test instructions mirror the live input model

Internal release and playtest instructions describe choosing chassis cells and event responses rather than assuming a pointer click. They also name the live CURRENT ORDER guidance instead of the retired NEXT label, so facilitators do not teach controls or terminology the build no longer presents.

## 2026-08-28 — Empty-save copy explains the first autosave

The title now says that autosave begins after the first committed decision. This replaces internal-sounding “progress checkpoints” shorthand and matches the fresh-run pause explanation without implying that merely opening Ashgate has already created a checkpoint.

## 2026-08-28 — Continue identifies the loaded checkpoint cleanly

Pausing immediately after Continue now says that the current decision matches the loaded checkpoint. If that restored state later diverges without another checkpoint, the same branch reports unsaved changes since loading instead of producing the awkward “Current decision saved · Loaded save” construction.

## 2026-08-28 — Manual save receipts hide serialization internals

Saving from Pause now leaves “March saved locally” in the stage receipt instead of exposing the prototype label and schema version. Schema metadata remains in the file and validation path where it is useful; the player sees only where the march was saved and what Continue will do.

## 2026-08-28 — Incompatible saves use recovery language

The title no longer exposes expected and discovered schema numbers when a checkpoint cannot be loaded. It identifies an incompatible save format and offers the existing remove-or-new-run recovery path, while the underlying validator continues to enforce the exact version boundary.

## 2026-08-28 — Save recovery covers every unusable checkpoint

The recovery action now says Remove Unusable Save, and its confirmation explains that the checkpoint cannot be loaded by this build. The same language truthfully covers malformed, incomplete, and version-incompatible files instead of incorrectly calling every case unreadable.
