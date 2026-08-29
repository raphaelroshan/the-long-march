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

## 2026-08-28 — Session options recognize a completed march

Opening the pause layer from results now presents Final Report and Debrief Options, explains that the march has ended, offers Save Result, and returns to the debrief. The same overlay retains March Paused and Save March during an active run, so shared controls no longer describe a finished campaign as merely waiting on the road.

## 2026-08-28 — Debrief save status describes the result slot

Completed-run options now distinguish an unsaved result, a result already stored under Continue, and an older checkpoint still occupying that slot. Saving from this overlay confirms that Continue will reopen the debrief. Terminal state no longer asks the player to commit another campaign choice or use the active-run Save March label.

## 2026-08-28 — Debrief replay uses one lifecycle path

The session-options Restart action becomes Play Again after a completed run and opens the same result-aware confirmation as the main debrief action. Cancelling returns to the options overlay with focus intact; confirming closes that overlay and creates the same fresh Ashgate replay checkpoint. Active-run Restart retains its existing behavior.

## 2026-08-28 — Title recovery explanations wrap safely

The title’s save-status region now word-wraps inside its action card. Longer malformed, incomplete, or incompatible-checkpoint explanations remain readable alongside the recovery action instead of depending on a single line wide enough for the shortest no-save message.

## 2026-08-28 — Passed branches are marked bypassed

The route map now derives whether an unvisited node is still reachable from the fortress’s current position. Unchosen branches behind the march are labelled Bypassed with a muted treatment and an explicit cannot-revisit explanation, while genuinely upcoming nodes remain Future and failed roads that are still connected remain available for another attempt.

## 2026-08-28 — After-action guidance names selectable routes

Securing a road now asks the player to choose the next available route rather than the next visible node. The map deliberately keeps future and bypassed locations visible for context, so the receipt now points to the same availability concept and cyan treatment used by the actual controls.

## 2026-08-28 — Final-road stakes remain above the fold

Selecting Meridian Pass promotes its terminal rule into both the route-review receipt and current order: failure ends the run and there is no retreat. The detailed map preview and commit control retain the same warning, but the player no longer needs the right-hand scroll position to understand the consequence of the final commitment.

## 2026-08-28 — Result checkpoints require a recognized outcome

Deserialization rejects a results-phase checkpoint unless its outcome is Decisive March, Scarred March, or March Failed. The title therefore routes malformed terminal saves through normal unusable-save recovery instead of presenting them as an active Continue slot, while the defensive in-stage fallback calls the state an Unclassified Debrief rather than a successful completion.

## 2026-08-28 — Completion state must agree with the saved phase

A results checkpoint is valid only when both the run and journey are marked complete, while active campaign phases reject terminal flags or outcomes. This keeps recovery strict at the state boundary and prevents a contradictory save from appearing to be either a resumable march or a trustworthy debrief.

## 2026-08-28 — Critical consequences stay beside Advance

When the next combat step will collapse the hull, disable a system, trigger a dependency cascade, or break protecting armor, the command desk now repeats that forecast directly beneath Advance. The detailed contact card and current-order text remain available, but the irreversible action no longer depends on the player connecting information across opposite sides of the screen.

## 2026-08-28 — Saved phases retain a valid next action

Deserialization now accepts only the six implemented campaign phases and requires encounter activity to agree with battle versus planning states. Unknown phases, inactive battle saves, and stray encounters in refit or map checkpoints are rejected before state mutation, allowing the title's normal recovery action to replace them instead of opening a stage with no trustworthy next command.

## 2026-08-28 — Route intel remains beside commitment

Selecting a road now places its known contacts, forecast hazard, or unscouted broad warning directly above the Commit action. This preserves the information boundary for uncertain roads while keeping the most important threat context visible after keyboard or controller focus scrolls past the regional map.

## 2026-08-28 — Exact scouting includes preparation advice

Known routes now reveal each contact's authored counter alongside its name, both in map detail and beside Commit. Forecast and unscouted routes keep those counters hidden. Signal readiness and Iven Pell therefore convert uncertainty into an actionable refit decision rather than merely replacing a generic hazard with a proper noun.

## 2026-08-28 — Departure discloses unused recovery

Selecting a road from Morrowline now adds the live unused service budget beside Commit and states that departure ends access to it. The warning disappears after all services are spent and uses natural singular or plural wording, preserving the choice to leave early without silently discarding a scarce recovery opportunity.

## 2026-08-28 — Hull threats mark the whole chassis

Module-directed attacks retain their red target outline, while a hull-directed contact now outlines the entire chassis grid and adds a `HULL TARGETED` text marker. The treatment clears as soon as targeting returns to a system, ensuring both color and wording communicate that no individual compartment can absorb the forecasted hull hit.

## 2026-08-28 — CI and local exports share one checked path

Runnable Windows and macOS packaging now goes through `scripts/export_playtest.sh` in both developer and GitHub Actions environments. The script reports its engine version, deletes stale target files before export, verifies a non-empty artifact, and gives a specific matching-template error, preventing an old executable from being mistaken for the current build after a failed export.

## 2026-08-28 — Release metadata creates its own destination

The tagged release workflow now creates the artifact directory immediately before writing its manifest. Export setup no longer owns that unrelated side effect, so refactoring or replacing the build script cannot leave an otherwise successful desktop package without its provenance metadata.

## 2026-08-28 — Blockade pressure predicts its consequence

The campaign desk now explains the Watch-to-Closing and Closing-to-Break thresholds before they are crossed. At Break it reports whether Signal Causeway is closed or being held open by forecasting, and it names both ways to reopen a closure. Color severity supports the text rather than carrying the rule alone.

## 2026-08-28 — Route commitment restates doctrine

The compact context beside Commit now names the selected doctrine and its central offensive and defensive tradeoff. Run Hot becomes a danger-colored summary when its predicted heat exceeds the limit. Route selection therefore confirms the road, available intelligence, and standing combat order in one final decision area.

## 2026-08-28 — Debriefs account for unused recovery

The run record now states whether Morrowline's service actions were fully spent or left unused. When a Scarred March or hull failure follows unused recovery, the replay goal points to that exact missed opportunity instead of generically recommending that a future run reserve a service action.

## 2026-08-28 — The alternate first half is proven finishable

Deterministic coverage now completes a second full campaign through Soot Orchard, Red Wheel Toll Bridge, Morrowline, Signal Causeway, and Meridian Pass without the Broken Relay or Iven Pell. This guards the alpha's route-choice promise against balance changes that leave an alternate branch technically selectable but unable to finish.

## 2026-08-28 — Debriefs retain authored route decisions

Resolved Soot Orchard, Broken Relay, and Red Wheel choices are now stored explicitly in campaign state and survive save/load. The run record names the decisions actually made on the travelled path, while older compatible checkpoints derive the choices that can be known safely and mark an unrecorded toll decision honestly.

## 2026-08-28 — Feedback bundles preserve campaign context

The local-only feedback export now includes the secured campaign path, exact authored route decisions, and unused Morrowline recovery actions in its final-state summary. A tester's comments can therefore be interpreted against the choices and missed resources that produced them without collecting identity, device, or network data.

## 2026-08-28 — Route teaching matches the live decision

The first-run briefing and persistent Field Guide now explain that known routes reveal both contacts and counters, and that closure pressure enters Closing at 3 and Break at 5. Their action text asks the player to compare those facts with the current chassis before Commit, matching the information and vocabulary on the live command desk.

## 2026-08-28 — Known-route intel checks the current chassis

Threat definitions now carry explicit counter-module IDs in addition to player-facing advice. Known route previews use those IDs to name which counters are operational in the current build, or state that no listed module counter is ready. Forecast and unscouted routes do not expose this derived information, preserving the value of signal readiness and Iven Pell.

## 2026-08-28 — Saved decision history is validated

Campaign deserialization now checks every persisted event and choice against the authored Soot Orchard, Broken Relay, and Red Wheel option sets. Malformed containers and unknown choices are rejected before state mutation, so a damaged checkpoint cannot manufacture a plausible but false debrief history.

## 2026-08-28 — Saved routes must exist on the authored map

Campaign deserialization now validates journey locations, destinations, route IDs, target nodes, and every secured path step before changing live state. Active campaigns must begin at Ashgate, follow real map edges, and keep their recovery node aligned with the last secured stop, preventing damaged checkpoints from loading into dead ends or inventing impossible travel history.

## 2026-08-28 — Route previews have a visible reversible exit

Selecting a campaign road now reveals a dedicated Cancel Route Preview action directly beneath Commit. It clears the selection, restores focus to the inspected map node, and confirms that no fuel, time, or blockade pressure was spent, giving mouse players the same explicit escape already available through B or Escape.

## 2026-08-28 — The title states the player's control boundary

The first screen now names the four decisions the player owns—chassis, route, doctrine, and one emergency order—and states that battles resolve step by step. This communicates the preparation-driven auto-battle contract before Start without adding another tutorial panel or implying that combat is directly piloted.

## 2026-08-28 — Combat reports use authored names

Encounter attack sources and newly assigned targets are translated through the module and specialist catalogs before entering the causal report. The command desk, saved encounter history, and feedback bundles now say `Repeater Gun`, `Coal Cell`, and `Iven Pell` instead of leaking identifiers such as `repeater_gun` or `coal_cell`.

## 2026-08-28 — Runtime receipts stay inside the fiction

Continue now reports that the march was restored from a local checkpoint, and filled specialist capacity says another specialist is already assigned to the fortress. Dormant diagnostic controls use the same vocabulary. Player-facing runtime text no longer calls the active campaign or its crew slots a prototype.

## 2026-08-28 — Pre-contact order timing is explicit

Before any hostile target is assigned, the encounter-order panel now states that an unused order survives Advance unless the encounter ends, while directing attention to the Contact Next forecast. Players can deliberately wait for a target instead of spending Seal or Cut Loose early because they fear the order will expire on the next step.

## 2026-08-28 — Saved chassis layouts are validated before use

Checkpoint loading now validates every installed and stored system against the authored module catalog before mutating live state. Installed layouts must also respect chassis bounds, overlap, mount, durability, and mass limits. Corrupt layouts are routed to title-screen recovery instead of rendering an impossible fortress or failing later during combat.

## 2026-08-28 — Saved encounters cannot invent threats or targets

Checkpoint loading now validates encounter entries, unique slots, health and defeated state, target references, and the six-step progress range before restoring combat. Active battles must contain at least one authored threat, preventing a damaged save from opening an empty encounter or targeting a system that is not present on the restored chassis.

## 2026-08-28 — Continue previews the waiting decision

The title's checkpoint summary now derives a compact next action from the validated save: answer the contract, choose a road, resolve a named local event, continue a specific battle step, use recovery, or review the debrief. It shares the existing resource line instead of increasing the menu card height, so returning players gain orientation without crowding the 1280×720 layout.

## 2026-08-28 — Recommended repairs disclose their two-stage action

When the currently inspected system is healthy, Morrowline's repair action now labels the damaged recommendation as a free review and states that a second press confirms repair. The existing safety step remains intact, but players no longer have to infer from a tooltip whether the first press consumes Ashmarks or one of the two service actions.

## 2026-08-28 — Recovery services preview their complete transaction

Each available Morrowline purchase now shows the relevant fuel, hull, or module durability before and after service alongside the shared action budget before and after use. Affordability and exhaustion locks remain additional lines, keeping the decision's benefit, Ashmark price, and opportunity cost visible on the same control before confirmation.

## 2026-08-28 — Operational damage remains visible

The chassis inspector and module description now distinguish a damaged-but-operational system from a fully healthy one. Dependency readiness still describes whether the module can function, while the adjacent durability fraction explains why repair may remain worthwhile; damaged ready systems use the warning color rather than the healthy green state.

## 2026-08-28 — Recovery actions lead the Morrowline desk

At Morrowline, the limited service actions now move ahead of optional doctrine and chassis controls in the command-desk reading order. Programmatic focus also invokes the existing contextual scroll behavior, so keyboard and controller handoffs keep their focused decision visible instead of relying on incidental container scrolling.

## 2026-08-28 — Recovery has an explicit route handoff

Campaign recovery now ends with a Review Next Roads action that moves focus to the first available map route without choosing or committing it. The control states how many service actions remain available, and the resulting message confirms that the handoff spends no service action, fuel, time, or Ashmarks; the existing route preview and explicit commit remain authoritative.

## 2026-08-28 — Focus handoffs must also move the viewport

Command-desk focus scrolling now coalesces rapid focus changes and reapplies the latest target across the next two UI frames, after layout has settled. The previous nested coroutine reached the target control logically but never applied its scroll, allowing controller focus to sit far below the visible panel. A geometry regression now requires the recovery-to-route handoff to place the entire focused node inside the right-hand viewport.

## 2026-08-28 — Dependency explanations are authoritative read models

The selected installed module now exposes one compact dependency card: direct inputs, current operating state, the next practical failure if its most relevant link is lost, and one legal counter. The card is derived by `LongMarchState` without mutating the fortress; presentation only formats the returned fields. This rejects UI-owned dependency rules and a larger encyclopedia panel, keeping the explanation attached to the physical chassis decision.

## 2026-08-28 — Available roads are compared before selection

When two forward roads are available, the command desk now presents their days, current fuel cost, known or unknown risk, pressure gain, threat clue, next stops, and whether a settlement follows. The comparison is an authoritative non-mutating read model and disappears during final route confirmation, preserving the existing preview-and-commit boundary instead of turning comparison into automatic choice.

## 2026-08-28 — Target explanations share the targeting score

Combat cards now state why an arrived threat chose its current target before showing the predicted hit. The explanation is produced by the same authoritative scoring profile used to select the target, including route tags, exposed or lower-hull placement, doctrine protection, and damaged condition. This avoids a separate UI heuristic that could disagree with simulation behavior.

## 2026-08-28 — The title names the build's real boundary

The title now identifies Ashgate Lowlands as the current complete test journey, names Ashgate Depot as its starting point, and states that later regions are not included. Existing encounter, recovery, finale, and duration expectations remain prominent. This replaces the ambiguous “Chapter One” framing without adding a defensive disclaimer screen or diminishing the playable chapter.

## 2026-08-28 — Guided onboarding teaches one dependency at a time

The Marchmaster briefing now separates engine fuel, weapon ammunition, workshop staffing and parts, signal visibility, route pressure, and contact response into focused steps. The contract remains first and each page names one concrete inspection or decision. This accepts a slightly longer optional briefing in exchange for avoiding the previous compressed chassis page, where several unrelated dependencies competed for attention.

## 2026-08-28 — Route comparison states confidence and risk bands

Each available-road summary now pairs its numeric risk with the same low, guarded, or high planning band and explicitly labels information as known, forecast, or unscouted. The comparison updates when doctrine changes and still hides exact risk for unscouted roads. This keeps uncertainty meaningful while removing the need to cross-reference map-node shorthand.

## 2026-08-28 — Water Condenser is a maintained sustain system

The first post-alpha module is a rotatable two-cell interior system with two heat, one power draw, and three durability. Shared power keeps the hardware operational, while an adjacent operational Field Workshop is the soft maintenance dependency that moves it from Strained to Ready. Only Ready state may unlock and discount the Dry Cistern Cut, so layout, workshop staffing, power, damage, and sealing can all remove the benefit through the existing dependency model. The module uses a stable `water_condenser` ID and the existing finite inventory and save schema rather than adding a separate resource or persistence path.

## 2026-08-28 — Gated roads remain visible on the campaign map

Dry Cistern Cut is a one-day Storm Front road from Morrowline to Meridian Pass. Its authored cost is two fuel; a Ready Water Condenser both unlocks it and reduces that cost to one. The comparison and route intel name the condenser discount separately from risk modifiers. Without the required system, the node remains visible with a distinct `SYSTEM REQUIRED` state and names shared power plus adjacent operational workshop maintenance. This keeps build-gated content legible and aspirational instead of silently removing it from comparison or presenting an unusable Commit action.

## 2026-08-28 — Storms pressure the system that enabled the shortcut

Storm Front targeting now includes sustain systems and strongly prefers the Water Condenser that enabled Dry Cistern Cut. A sustain hit deals one additional damage, making an unprotected condenser deteriorate faster than a basic workshop patch can restore it. Adjacent armor absorbs one point, while Seal Compartment removes the condenser from targeting at the explicit cost of taking it offline until the encounter ends. The target rationale, impact preview, and causal report all use the same rule, and both field repair and Morrowline service can restore the resulting damage.

## 2026-08-28 — Mara Flint enters through a recovery decision

Mara appears at Morrowline only while the current specialist berth is free. Recruiting her requires an operational Field Workshop and Crew Quarters, then immediately presents one scarce forge core: rebuild the weakest installed system for one day and one blockade pressure, or brace the Refugee Bunk against one damage per hit. Mara adds one durability to operational workshop repairs and to paid Morrowline module service without increasing the service price. After the fourth encounter, a blocking callback evaluates the actual committed system and grants only the visible consequence that survived. The chain reuses validated event decisions, adds one stable repaired-module reference, and does not introduce affinity, dialogue, or faction-reputation state.

## 2026-08-28 — Road occurrences are bounded authored state

The Ashgate campaign now evaluates otherwise-empty arrival phases through the named `ashgate_operational_occurrences_v1` stream. Hard eligibility checks use the live chassis before a sorted candidate set can select one authored event or an intentional quiet result. Milestone events retain priority, no phase rolls twice, repeatable incidents use encounter cooldowns, one-shot meetings consult durable decisions, and both phase and result histories are capped at eight records. Active phase, cursor, cooldowns, and history are validated in save schema 6. This rejects procedural prose, unbounded graphs, reroll-on-load behavior, and UI-owned event rules while allowing repeat runs to respond to the fortress the player actually built.

## 2026-08-28 — Regional maps share one configurable view

The campaign map now owns named layout data for Ashgate Lowlands and Flooded Veyru rather than assuming every chapter uses Ashgate's ten node IDs. Region configuration rebuilds the same buttons, status colors, route lines, focus behavior, and commit surface from a bounded authored layout. The simulation will still own reachability and route rules; this presentation change only makes a second isolated chapter possible without duplicating the map widget or creating a second game flow.

## 2026-08-28 — Veyru is an isolated region in the existing save envelope

Flooded Veyru begins at Lantern Quay through the same authoritative fortress state rather than a second campaign controller. A stable region ID selects its authored graph and gives the shared pressure value Veyru's Low Water, Flooding, and Breach bands. At Breach, Drowned Registry closes while Pilgrim Gantry joins the graph as a guaranteed recovery route. The medicine contract records the exact installed Refugee Bunk or Parts Crate carrying its sealed cases, and save schema 7 validates the region, path, contract, and carrier before restore. Older schema-6 saves migrate to Ashgate with no Veyru obligation.

## 2026-08-28 — Veyru reuses combat while changing what survival means

Flooded Veyru now completes through the shared six-step encounter engine rather than a regional combat fork. Flood Surge applies explicit lower-deck and medicine-carrier targeting, gains damage at Flooding water or maximum chassis mass, and exposes Water Condenser, Side Armor Skirt, workshop recovery, and Seal Compartment as distinct counters. Pilgrim Gantry reduces flood impact without erasing it. The Civic Guardian tests the reserved carrier at the archive, while the gate commitment either adds Climbers through a public broadcast or reduces carrier damage through a sealed approach.

Veyru recovery is anchored only at Lantern Quay and Evacuation Camp. Securing an ordinary road no longer turns every node into a retreat point; save validation instead accepts the latest reached regional anchor within the authored path. Evacuation Camp grants one service action, or two while an accepted medicine carrier remains operational, and provides one free emergency fuel below two. Carrier destruction or Cut Loose Cargo fails the contract but never ends the chapter. A surviving fifth encounter produces Archive Kept only with an operational delivered carrier and at least six hull; all other mobile arrivals produce Archive Scarred, while final mobility or hull failure produces Veyru Lost.

## 2026-08-28 — Chapter selection is explicit at the title

The title now presents Ashgate and Flooded Veyru as separate new-run actions while Continue remains tied to one validated local checkpoint. Ashgate retains the guided briefing; Veyru opens directly at Lantern Quay because the current briefing is authored around Ashgate-specific systems and route names. The playable stage receives a stable starting region before it enters the scene tree, builds the matching legal chassis, and then uses the same save, pause, map, event, combat, recovery, and debrief surfaces. Restart and replay preserve the active region, including after loading a Veyru checkpoint.

The Veyru prepared layout sits exactly at the fourteen-mass limit and six-heat limit with a Ready Water Condenser, crew-connected workshop, and Parts Crate medicine carrier. It deliberately has no installed weapon: Pump Gallery teaches that draining, armor, repair, sealing, and condenser preparation are real answers to a hazard rather than making every encounter another damage race. Flood Surge base endurance is four so a maintained condenser resolves the teaching contact before its pressure can exhaust the prepared carrier, while unprepared builds still face six approach steps and escalating water damage.

## 2026-08-28 — Veyru content has a machine-checked chapter contract

Flooded Veyru now has a dedicated authored content file referenced by the main manifest. Its validator fixes the region endpoints, five-encounter route length, pressure closures and guaranteed recovery, medicine-carrier rules, prepared loadout, regional threats, decisions, and result IDs. The runtime remains authoritative for simulation, while CI now rejects drift between the implemented chapter and its reviewable content contract before Godot tests run.

## 2026-08-28 — Region-rebuilt map controls retain accessible handoffs

Campaign map controls rebuilt for a different regional layout now receive the same focus-triggered command-desk scrolling as the initial Ashgate buttons. Settlement focus also includes Review Next Roads after enabled services, so a fully supplied Evacuation Camp does not jump directly into the map or leave controller focus below the viewport. The Veyru UI regression drives the complete five-encounter route through real buttons and requires the opening route, recovery handoff, final archive choice, and debrief to remain visible and actionable at 1280×720.

## 2026-08-28 — Session actions preserve chapter identity

Continue now names Ashgate or Veyru on the action, summary, and tooltip. Pause summaries, restart confirmations, and replay confirmations derive their chapter and starting settlement from the active run, preventing a Veyru player from being told that a destructive action will restart Ashgate. When a checkpoint exists, the title hides the redundant Ashgate Skip Briefing button and keeps that path in the Field Guide; Continue, one guided Ashgate start, Veyru, utilities, and the complete checkpoint summary therefore remain visible together at 1280×720.

## 2026-08-28 — Help follows the active region

The title Field Guide now explains the shared loop through both implemented chapters instead of presenting Ashgate as the only road. Reopening the in-run briefing derives seven labels and lessons from the active region: Ashgate retains its engine, ammunition, signal, blockade, and Morrowline teaching, while Veyru teaches the condenser, named medicine carrier, water thresholds, Pilgrim Gantry guarantee, and archive commitment. Veyru still starts directly at its contract; the tailored briefing is available on demand and never marks the Ashgate first-run lesson complete.

## 2026-08-28 — Public information creates information, not power

Surviving Flooded Veyru after broadcasting the Dry Archive establishes `veyru_public_archive_signal` in a small local progression record. Later Veyru runs copy that stable ID into their save-safe simulation state and reveal Drowned Registry's Flood Surge and Climber composition as Known. The development does not reduce route risk, pressure, damage, fuel, or time, preserving the value of live signal equipment and avoiding a permanent-stat treadmill. The earning debrief, title overview, active run status, route comparison, and map detail all name the prior decision that changed the later option.

## 2026-08-28 — The first campaign shell connects results, not resources

The March Charter stores each playable region's best terminal result separately from the single Continue checkpoint. A debrief can now March On directly to the other chapter through a confirmation that explains what persists and when Continue changes. This creates a readable two-chapter itinerary and a replay reason without carrying fuel, damage, modules, or money between isolated deterministic chapters, and without presenting the planned five-region campaign as finished.

## 2026-08-28 — Window close respects the save boundary

The shell disables automatic acceptance of operating-system close requests. A safe title or an exactly checkpointed stage exits immediately; unsaved live state opens a chapter- and location-specific Save & Quit confirmation. Cancelling restores the previous live or paused focus context, repeated close requests cannot bypass the modal, and a failed write leaves the application open. The existing Continue format remains the only run save.

## 2026-08-28 — Persistent data resets stay separate

Title Settings exposes March Charter reset independently from Continue clearing and briefing reset. Its confirmation explicitly names regional results and Public Archive Signal as the deleted data, and names Continue, settings, and briefing progress as preserved. The action is disabled during a live run because that stage holds a deterministic regional-development snapshot; reset therefore cannot make active state disagree with its profile mid-journey.

## 2026-08-28 — Continue keeps one validated predecessor

Before a valid primary checkpoint is overwritten, the stage preserves and validates its complete previous serialized state as a local recovery backup. The title never loads that file silently: when the primary is missing or invalid it disables Continue, names the recoverable chapter/day/location, and requires an explicit Restore Backup confirmation. Invalid primary bytes cannot replace a valid predecessor, and Clear Local Save removes both files while preserving the March Charter and other local data categories.

## 2026-08-28 — Playtest notes are available at the decision

The existing local-only feedback form is reachable from Pause as well as the final debrief. A paused handoff names the active region, day, location, and phase, preserves unfinished text for the current stage, and returns to the suspended pause menu without mutating campaign state or losing the pre-pause focus target. This was chosen over background telemetry or automatic uploads because early tests need authentic explanation in the tester's own words and an explicit sharing boundary.

## 2026-08-28 — Large text preserves the decision canvas

Settings offers a bounded 100%/110% text-size preference rather than scaling the whole viewport. Whole-canvas scaling made the fixed chassis and command desk exceed the 1280×720 logical width; enlarging inherited and explicit font sizes keeps that decision surface intact. At 110%, the title removes one redundant small control-summary line and its decorative right spacer, while the visible input guide remains. Settings scrolls its preference rows independently so context, status, and return controls stay fixed and controller focus never lands below the viewport.

## 2026-08-28 — Clean playtests preserve deliberate exports

Title Settings can return all managed runtime state to a genuine first-launch baseline in one confirmed action. Continue and backup, March Charter state, briefing completion, preferences, and the current journal are removed together and their in-memory counterparts are rebuilt immediately. Exported feedback files are excluded because they are deliberate tester-owned artifacts, not hidden runtime state. The reset is unavailable during a live run, while narrower category resets remain for targeted testing.

## 2026-08-28 — Exported feedback has an input-neutral handoff

A successful local feedback export exposes Copy Report Path as a visible action in the modal rather than hiding the complete location in a pointer tooltip. The action copies only the path and never uploads or opens the file. It joins the controller focus row only while the report exists; a moved or deleted report removes the stale action and returns focus to Save Again. This keeps consent explicit while making the intended handoff practical for every supported input method.

## 2026-08-28 — Interface audio reinforces rather than carries state

The shell generates four short local cues for focus, activation, warning dialogs, and checkpoint receipts, then applies them to both existing menus and buttons created inside a stage. Settings uses a bounded Muted/40%/70%/100% control instead of presenting an unsupported final mixer. Muting never removes text, focus styling, confirmation copy, or save receipts. Runtime-generated PCM keeps the checkpoint offline and license-free while the final music, ambience, combat sound, and platform mix remain separate human-reviewed work.

## 2026-08-28 — High contrast preserves authored meaning

Settings can darken image-backed surfaces, brighten reviewed text colors, and strengthen button, route-map, and combat outlines across the running shell. The transformer records the latest authored base color rather than repeatedly lightening its own output, so dynamic warning changes remain reversible and switching back restores the standard palette. Route visibility, risk, pressure, dependency state, combat contact, and run progress continue to name themselves through text and symbols; color remains reinforcement rather than authority. This is a bounded playtest aid, not a substitute for a measured accessibility audit.

## 2026-08-28 — Controller convention changes bindings and copy together

Settings can swap the south/east face buttons assigned to `ui_accept` and `ui_cancel` while preserving Enter, Escape, navigation, and pointer input. The shell applies the mapping before initial focus and passes the preference into each stage before it enters the tree. Title, Pause, briefing, route, and chassis hints derive from the same layout identifier, preventing instructions from drifting away from runtime behavior. The preference deliberately stops short of a complete binding editor, which would require conflict handling, device-specific glyphs, and an inaccessible-binding recovery path.

## 2026-08-28 — Build and storage support stays inside the consent boundary

Settings exposes one read-only panel that identifies the exact build/platform, states the no-account/no-telemetry/no-automatic-upload boundary, reports managed local-file presence, counts exported feedback, and shows the absolute Godot data folder. Its only side effect is copying that folder path; it never opens a browser, reads report contents into the UI, or sends data. The panel preserves title versus paused context and returns focus to Settings without resuming the stage, making support handoff practical without weakening the local-only playtest contract.

## 2026-08-28 — Title focus explains the action it will take

The existing right-hand title card now follows Guided Ashgate, Quick Ashgate, Flooded Veyru, Continue, and damaged-save recovery focus instead of describing both chapters generically. Each new journey names its obligation, pressure, recovery point, and finale; Continue uses validated save metadata to name the waiting decision and fortress condition. Pointer hover may inspect another action, but mouse exit restores the keyboard/controller-focused card. Launch remains a single activation and existing replacement confirmations remain authoritative, so preview does not become a hidden selection step.

## 2026-08-28 — Reorientation uses an inspectable March Record

Pause now exposes a read-only March Record assembled from the authoritative live state. Its first viewport prioritizes the stable chapter-and-seed run code and current order, followed by path, pressure, commitments, authored decisions, occurrences, resources, and named system damage. Copy is an explicit clipboard-only action; Back or cancel restores the suspended Pause menu and exact entry focus. The same run code enters debrief and feedback summaries so screenshots, notes, and exported reports refer to one deterministic run without claiming that the seed replaces the command history.

## 2026-08-28 — Current Order can return focus but cannot act

The Run Flow heading carries a compact phase-aware jump that delegates to the same `focus_current_action()` resolver used after transitions. Its label names the destination class, while activation only focuses and scrolls to the existing authoritative control. Contract, route, event, battle, recovery, and debrief choices therefore retain their original confirmation and state-change paths. The adjacent route cancel copy is shortened at 110% text so the reversible pointer action remains visible beside Commit.

## 2026-08-28 — Reference help opens where the player is working

Reopening Field Briefing now selects the topic implied by the live contract, road, battle, recovery, Mara, or archive state instead of returning to Command unconditionally. The seven-item rail is made of real input controls, so a player can inspect any other topic directly; only visited topics receive a completion mark. First-run guidance still starts at the authored opening and focuses Next. This keeps reference help fast without introducing a second tutorial state machine, changing briefing persistence, or mutating the deterministic run.

## 2026-08-28 — Pause separates continuity from reorientation

The primary Pause row now distinguishes Resume Here, which restores the exact valid pre-pause control, from a phase-labelled Go to action, which delegates to the authoritative current-order resolver. Cancel remains Resume Here. Sharing one row preserves the 1280×720 layout and makes the choice explicit without adding another overlay. The resolver now prioritizes phase and pending-decision state before testing visible controls, so stale presentation cannot redirect a debrief or battle order. Neither path activates a control or changes serialized state.

## 2026-08-28 — Settings exposes its hierarchy while scrolling

Settings now groups its existing controls under Display & Readability, Controls & Feedback, and Runs & Local Data. Compact headings make pointer scanning easier, while the fixed context line follows keyboard/controller focus so the category remains visible after scrolling. Opening Settings resets to the first heading, and Build & Local Data returns to its original section. Headings remain non-interactive, avoiding extra focus stops or a second settings state model; preferences, defaults, storage, and confirmation behavior are unchanged.

## 2026-08-28 — The shared guide launches either proven chapter

The title Field Guide now offers direct Ashgate and Flooded Veyru starts beside Back to Title. Both delegate to the existing chapter launch and Continue-replacement confirmation paths; cancelling restores the exact guide action. Replay wording derives from each region's March Charter record rather than treating any completed Continue file as proof that both chapters were completed. This closes the mismatch between a two-chapter guide and an Ashgate-only footer without introducing another chapter selector or save slot.

## 2026-08-28 — Returning to title leaves a persistence receipt

Before releasing a live stage, the shell now compares its complete serialized state with the validated Continue checkpoint and creates one temporary title receipt. Saved decisions name their chapter, day, and location; saved results name the retained debrief; unsaved exits distinguish an older retained checkpoint from no checkpoint. The receipt temporarily replaces the longer generic save summary so the 1280×720 title remains intact at 110% text, while Continue focus still exposes full checkpoint details. It clears on the next launch and never enters saves, preferences, the journal, or the March Charter. This was chosen over a notification history or second save model because the ambiguity exists only at the immediate stage-to-title boundary.

## 2026-08-28 — Chassis selection is inspection until the grid owns focus

The preparation screen still selects one installed module so its dependency card is immediately useful, but the passive chassis now names that state as Overview, Inspected System, and Inspect. Edit Chassis or a direct pointer click changes the same panel into explicit edit mode with a stronger selection outline, active cursor, placement language, and mapped confirm/cancel instructions. Stored modules continue to expose global placement blockers before entry. This preserves fast mouse editing and controller parity while removing the false impression that the opening engine is already being moved. The stage refresh also type-checks non-button focus before route-button membership tests, preventing chassis focus from emitting an engine error.

## 2026-08-28 — Checkpoint feedback owns a safe header slot

The non-modal checkpoint toast now uses compact `Saved · reason` copy in a 250-pixel header slot capped at x=330 and positioned with a twelve-pixel gap before the live Pause control. The cap reserves space for the widest contextual Pause label before that label expands, preventing an existing toast from being covered during Route Review. This keeps save feedback, the title, and session control simultaneously legible at 1280×720 with 110% text. The toast still carries no focus, dismisses when Pause opens, and changes no autosave timing, state, or audio behavior.

## 2026-08-28 — Chassis guidance follows the available phase action

The passive chassis heading now points to Edit Chassis only where refit is actually available, to battle inspection during contact, and to final-chassis review during debrief. Results expose a dedicated Inspect Final Chassis action in the debrief action sequence; controller or keyboard selection remains in review, while cancel returns to that visible action. This closes the previous pointer-only debrief path and removes refit language from locked phases without changing placement, damage, targeting, results, or serialized state.

## 2026-08-28 — Debrief navigation follows its teaching order

A newly opened debrief now resets inherited battle scrolling and focuses Inspect Final Chassis before feedback. The action moved directly below March Debrief so both remain visible together even when the authored result record is long at 110% text. Entering review advances the current-order and Pause return targets to feedback through transient UI state; loading the result offers review first again. This aligns guidance, focus, and layout without making inspection mandatory or adding presentation state to saves.

## 2026-08-28 — Chassis detail copy obeys its fixed column

Locked-phase chassis help now uses compact labelled instructions sized for the existing 320-pixel detail column, with a two-line drawing bound as a fallback. Battle names the selected module as a Battle System and points to targeting; results use Final System and review language; road states name the refit lock and next road-stop opportunity. This preserves the dense inspector layout while removing visibly truncated instructions and generic headings, without changing any simulation or input behavior.

## 2026-08-28 — Session controls stay above stage scrolling

The stage title and contextual Pause action now sit in a fixed left-column header, while metrics, route evidence, combat, chassis, and reports scroll beneath them. Chassis focus can still reveal the complete inspector at 110% text without moving Pause out of pointer reach. Results also hide the decorative journey banner because the completed path, result, and machine are the relevant evidence. Shortcut priority and simulation state are unchanged.

## 2026-08-28 — Pointer Pause does not become the resume target

The persistent Pause button is pointer-active but focus-neutral. Keyboard and controller users already open Pause through Escape or the configured cancel button, so adding the visible button to their focus loop would duplicate the same command. More importantly, a pointer click no longer replaces the active stage control before the overlay records it; Resume Here restores that exact context, while Go to Order retains its separate authoritative destination.

## 2026-08-28 — Build identity names the artifact once

Title and Pause now share a `Playtest Build · v<version>` convention. The title retains the two-playable-region scope, while the Pause footer stays compact. This removes the previous `ALPHA · v...alpha...` repetition and gives screenshots one recognizable artifact label without changing the raw version used by saves, feedback exports, manifests, or compatibility checks.

## 2026-08-28 — Focus scrolling begins at a meaningful section boundary

Campaign-node focus now prefers the regional map heading as its scroll anchor, while route confirmation prefers the selected-road summary. The focused action still wins when all context cannot fit, but ordinary 1280×720 route handoffs no longer begin on a clipped fragment of the preceding doctrine explanation. This keeps automatic focus movement legible without making headings sticky or changing route state.

## 2026-08-28 — Lower desk actions need trailing focus room

The Marchmaster's Desk now ends with a small non-interactive margin. This gives automatic scrolling enough range to place lower controls cleanly without leaving a sliver of the prior section at the viewport edge. Emergency-order focus therefore preserves the complete Current Order and Encounter Order context, while ordinary battle entry still begins at the desk header and run tracker.

## 2026-08-28 — Checkpoint receipts name the resumable state

Encounter checkpoint reasons now distinguish an intermediate Battle Step from a Road Secured, Recovery Reached, or Run Ended transition. The save still occurs at the same successful advance boundary with the same serialized state and backup behavior; only the receipt and later pause summary use the more accurate player-facing reason. Run Ended remains neutral across decisive, scarred, and failed debriefs.

## 2026-08-28 — Event consequences hand off to the next order

A completed authored event now appends one Next line derived from the live Current Order guidance. The left evidence column therefore keeps the consequence and immediate route or recovery instruction together even when automatic focus scrolls the desk to lower controls. Chained events retain their existing Decision Continues treatment until the final choice resolves.

## 2026-08-29 — Journey spectacle follows an explicit simulation boundary

The next presentation slice will first replace the settlement's long control stack with a labelled bazaar whose Quartermaster, Signal Broker, Hiring Post, Assignment Board, Workshop, and Departure Gate each open one task panel. Departure leads to reversible Plan Journey choices and one atomic Commit, then to a saveable `travel` phase before contact or arrival. Potential assignment destinations use hollow grey markers; accepted assignments use filled, labelled color markers, while route focus exposes sourced news and travel cost without selecting the node. The fortress remains at the origin until at least one in-between road beat and all mandatory events or contacts resolve. A side-on moving-fortress scene, scenery, threat actors, and scenario tableaux consume structured events produced by the deterministic core; animation frames, tween progress, particles, and camera motion never decide offers, route costs, schedules, targets, damage, or outcomes. This supports safe Continue behavior, skip/reduced-motion parity, and exact causal playback without building a second combat engine. The first proof is limited to Ashgate's bazaar, Rill Crossing, and The Soot Orchard before the visual grammar expands to every settlement, threat, and region.

## 2026-08-29 — The fortress anchors every playable mode

The next layout keeps operational values in a stable left rail, reserves the center stage for the fortress or regional map, and uses a right dock for one selected station, module, route, threat, event, or consequence. The same fortress actor and module-anchor mapping persist across idle, travel, and contact states so visual spectacle remains tied to the real chassis. Map inspection, route selection, and Commit stay separate, and moving encounters preserve the side-on road rather than switching to an unrelated battle board. This was chosen over adding more panels to the existing two-column scroll because the fortress must remain the game's spatial subject while details change around it.
## 2026-08-29 — Separate settlement, road, and arrival state visually before expanding content

The first presentation pass uses a reusable `SettlementHubView` at Ashgate Depot and Lantern Quay. It keeps hull, fuel, power, heat, mass, Ashmarks, and trust in a stable left rail; the fortress and bazaar landmarks occupy the center; one selected station owns the right detail dock. The workshop and route table are mutually focused workspaces with an explicit return to the bazaar. Stations without implemented inventory or personnel say so directly rather than presenting placeholder transactions.

Route commitment now opens a mandatory `JourneyTransitionView` before combat controls. The view repeats the exact day, fuel, pressure, and heat result of the commitment, animates the same code-native walking-fortress silhouette against moving scenery, supports reduced motion and high contrast, and states that arrival is still pending. Campaign simulation also keeps `current_location` at the last secured node until the encounter resolves successfully; `campaign_target_node` remains the committed destination while on the road. This makes the no-teleport rule authoritative rather than purely cosmetic.

Plan Journey now owns a full-frame three-part composition: readiness values on the left, the existing deterministic node graph enlarged and centered, and a scrollable road dossier with fixed Commit/Cancel actions on the right. Route detail remains verbose when inspected, while the selected-route heading and Commit label become compact to keep the final action on-screen at 1280×720.

This checkpoint deliberately reuses the established deterministic combat engine and route graph. Threat-to-module approach staging, roadside scenario tableau, and arrival presentation remain separate slices so their UI can be tested without weakening save, focus, and campaign correctness.

## 2026-08-29 — Contact and arrival are presentation gates, not new simulations

Road encounters now use a full-frame `RoadContactView` while the existing encounter state remains the only authority for arrival timing, targets, damage, counters, interventions, and dependency cascades. The left rail keeps Hull, Power, Heat, Fuel, Pressure, Step, and Doctrine stable; the side-on fortress and current approach lanes occupy the center; one dossier owns the nearest threat and all player actions. The target marker is derived from the same module ID shown in the chassis inspector, and Inspect Chassis temporarily reveals that grid without enabling refit. A resolved encounter opens `JourneyArrivalView`, which reports already-applied Hull, Ashmark, Pressure, and system-state consequences before exposing the next map, bazaar, event, retreat stop, or debrief. These views add no simulation state; the save payload carries only their departure receipt and pending-arrival presentation snapshot so Continue cannot skip the visible handoff. This was chosen over a separate cinematic combat state machine because playback must never diverge from deterministic encounter results or create a second source of truth.
