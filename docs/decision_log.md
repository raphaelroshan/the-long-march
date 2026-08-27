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

## 2026-08-27 — Playtest guidance teaches causality, not a winning recipe

The first-run briefing explains dependencies, route commitments, encounter reading, intervention limits, and recovery. A short phase-specific NEXT line remains visible after onboarding, but it does not prescribe a layout or route. Testers can reopen the briefing at any time, and completion is remembered locally.

The briefing is four short stages rather than five prose-heavy pages. Each stage pairs one concept with a concrete next action and a visible Command → Chassis → Route → Survive progress rail. The final action says Enter Ashgate and hands focus directly to the live contract, preserving teaching without delaying the first decision.

The persistent desk instruction is derived from the exact campaign state rather than only the broad phase. It advances from the Ashgate contract to route selection, route commitment, encounter action, recovery, and results, so completed work is never presented as the player's next task. The left-side idle message uses “No encounter underway” to avoid confusing an unanswered contract with combat contact.

## 2026-08-27 — Feedback collection is local and explicit

The prototype records a small local journal of gameplay decisions and outcomes. It contains no account, machine identifier, analytics SDK, or network upload. A tester may add two written answers and a replay score, then explicitly save a JSON bundle and decide whether to share it. This gives early playtests enough causal context without building production telemetry before consent and retention policies exist.

The result screen explains its classification before asking for feedback. A Scarred March names each missed decisive threshold—hull, surviving final contacts, or contract failure—while failure identifies hull loss or loss of operational movement. A short next-run prompt turns the result into a testable strategy without claiming there is one correct build.

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

## 2026-08-27 — Non-final defeat retreats to a viable state

A failed regional encounter returns the fortress to its last secured node with explicit time, money, and pressure penalties. A road crew restores only enough hull, fuel, engine, and fuel-module durability to make another decision possible. Meridian Pass remains a hard endpoint because it is presented as the chapter's final commitment; earlier failures remain recoverable and retain their consequences.

Morrowline's service controls expose the remaining action budget in the heading and disable choices that cannot succeed because the selected module or hull is already whole, funds are insufficient, or no actions remain. Module repair names the selected system, restored durability, and exact cost. Focus skips unavailable services so arrival never lands on a dead-end action.

## 2026-08-27 — The campaign map is an interactive graph

The alpha presents the entire regional route graph instead of reducing each choice to a list. Node labels and borders distinguish current, secured, available, decision-blocked, closed, and future states; color is supporting information rather than the only signal. Route details update on both pointer hover and keyboard/controller focus, and only immediately reachable nodes accept input.

Route selection and departure are separate actions. Selecting a node highlights the road and preserves the current state while the player reviews time, fuel, risk, pressure, visibility, and doctrine. A dedicated commit control begins travel, preventing accidental departures and making controller navigation predictable.

## 2026-08-27 — Combat presents causes before spectacle

The alpha battle view uses enemy cards, arrival timing, target labels, counters, a six-step timeline, and the latest causal report lines. Targeted modules receive a visible chassis outline and every module shows durability. Emergency orders state both their benefit and cost. Animation and effects should reinforce this information later rather than replace it.

Combat timing is expressed relative to the present state. Approaching enemy cards count down the steps until arrival, the timeline distinguishes Done from Next, the primary button names the exact step it will resolve, and the desk order mentions either the nearest arrival or the systems currently under threat. This avoids asking the player to inspect a target that does not exist yet.

## 2026-08-27 — The application shell starts outside the simulation

The packaged build opens on a title menu instead of constructing a run immediately. Start Game creates a fresh Ashgate stage, Continue restores the explicit local save, and Escape opens a pause layer with resume, restart, and return-to-title actions. The shell owns these lifecycle transitions while `Main.tscn` remains the playable stage and `LongMarchState` remains presentation-independent. This keeps menu state from leaking into deterministic campaign state and leaves the stage independently testable.

Save, load, and reset controls remain callable by the test harness but are hidden from the live stage because the application shell now owns those operations. The pause menu groups safe continuation, persistence, reference, settings, and destructive session actions; it can reopen the field briefing without abandoning or mutating the current run.

The title menu separates a guided first run from a briefing-free Quick Start. Quick Start suppresses onboarding only for that stage and does not write the onboarding marker, alter the deterministic seed, or touch the save. A field-guide overlay states the intended five-part test flow so repeated playtests can reach the actual decisions quickly without introducing simulation-only debug shortcuts.

The title presents that material as a chapter and field guide rather than as internal test tooling. Its no-save line follows the autosave preference: automatic checkpoints are explained when enabled, while manual saving through pause is named when disabled. This keeps the first screen truthful without exposing implementation vocabulary.

The pause menu is a session boundary rather than a decorative overlay. It reports the current day, location, phase, and secured encounters; supports Save and Save & Return; and asks for confirmation before restart or return without saving. The safe cancellation action receives focus by default. This makes repeated tests faster while keeping accidental loss visible and reversible through the existing local save.

## 2026-08-27 — The stage shows the whole run without hiding the next decision

The Marchmaster's Desk carries a persistent five-milestone tracker: Prep, Roads, Recover, Final, and Result. Completed, current, and upcoming milestones use both symbols and color. The tracker is explanatory rather than a second simulation state; its current position derives from the deterministic campaign state and is verified across a complete run.

Mandatory local decisions appear immediately below the current objective. In particular, the opening Ashgate contract sits above doctrine and refit controls so a new tester can act without scrolling. Optional configuration remains available after the blocking choice rather than visually competing with it.

## 2026-08-27 — Focus follows the decision flow

Menu and stage transitions explicitly hand keyboard/controller focus to the next meaningful action: the opening contract, the first available route, route confirmation, encounter advancement, or final feedback. Pause records the previously focused stage control and restores it on resume. A fallback focus resolver activates whenever a refresh hides or disables the current owner, preventing focus from remaining trapped on an invisible control.

Focus handoff also scrolls the Marchmaster's Desk until the target control is fully visible. Logical focus alone was insufficient because the route map and later encounter actions can sit below the 720p fold. Automated flow coverage now checks both focus ownership and viewport containment after the contract and first route commitment.

## 2026-08-27 — Continue is offered only for a readable compatible save

The application shell inspects local save JSON, schema version, and required campaign fields before enabling Continue. Missing, malformed, incomplete, or version-incompatible files receive a concise title-screen explanation. The stage load operation also returns success explicitly; an unexpected load failure returns to the title instead of leaving the player in a fresh state that could be mistaken for the saved run.

After the lightweight file checks, Continue validates the complete payload through `LongMarchState.load_serialized`. The title summary includes day, location, phase, and encounter progress, so a returning tester knows which decision will be restored before opening the stage.

## 2026-08-27 — Playtest preferences remain local and outside campaign state

The title screen exposes fullscreen mode, persisted reduced transition motion, briefing reset, and confirmed local-save clearing. These preferences live in a separate local configuration file and never enter deterministic campaign serialization. Destructive save clearing reuses the safe confirmation layer, while briefing reset affects only whether the guided introduction appears on the next run.

Settings are also reachable from the paused stage. Opening them temporarily replaces the pause panel while leaving the stage disabled; closing them returns focus to the pause menu and preserves the stage control that will be restored on resume. A tester therefore does not need to abandon the current run to change display or motion preferences.

## 2026-08-27 — Results close the application loop

The results phase places Record Playtest Notes, Play Again, and Return to Title immediately below the current objective. Replay constructs a clean deterministic Ashgate state and restores focus to the opening contract. Return to Title is emitted as a stage lifecycle request handled by the application shell, keeping the playable scene independently testable while avoiding a dead end after the final encounter.

The exact application version appears on both the title and pause screens. A tester can therefore include the build identifier in a screenshot or written report even when the stage is paused, without depending on filenames or external release notes.

The title menu changes its primary action based on verified local state. Start Game is highlighted and focused when no compatible save exists; Continue becomes highlighted and focused after a manual or automatic save. This shortens the common resume path without making a corrupt save actionable.

Starting a Guided or Quick run while a valid save exists now requires confirmation when autosave is enabled. The copy states that the old save remains intact until the new run reaches its first checkpoint. The safe cancellation action is labelled Keep Save and receives focus by default.

## 2026-08-27 — Autosaves follow confirmed state changes

The application writes a silent local checkpoint after meaningful committed actions: refit changes, contract answers, route departures, authored event choices, specialist recruitment, encounter advancement, emergency interventions, and successful settlement services. Merely selecting a module or previewing a route does not save. The stage emits checkpoint intent while the application shell owns file persistence, preserving the separation between simulation and lifecycle policy. The pause summary names the latest checkpoint so testers can tell what Continue will restore.

Automatic checkpoints default to enabled but can be disabled as a persisted local preference. When disabled, checkpoint signals are ignored and the pause screen explicitly directs the tester to Save March. Manual save behavior remains available regardless of the autosave preference.

Successful automatic checkpoints display a short corner notice naming the committed action. The notice does not take focus, pause play, or replace the event log, and respects reduced-motion settings by omitting its fade animation.
