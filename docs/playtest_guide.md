# The Long March — Functional Playtest Guide

For the five-session private-alpha protocol, capture matrix, and local export summarizer, use [`private_alpha_session_sheet.md`](private_alpha_session_sheet.md).

## What this build is testing

This playtest is about two connected questions: can a player understand how a fortress layout causes a battle outcome, and can they use incomplete map information to plan five encounters? It is not a content-volume test. A useful session is one complete attempt from Ashgate Depot to Meridian Pass, including contract, route decisions, Morrowline recovery, retreat, or failure.

The build opens with a seven-step Marchmaster briefing that introduces one core dependency or journey decision at a time. **Open Field Briefing** reopens it at the topic matching the current contract, route, battle, recovery, or finale decision. Every topic in its rail is directly selectable with pointer, keyboard, or controller, so testers can compare guidance without paging from the start. The green current-order line on the Marchmaster's Desk follows the active decision without prescribing a winning layout.

If the active control moves out of view while inspecting the desk, use the compact **Go to…** action beside Run Flow. It moves focus and scrolls to the contract, route, commit, event, battle step, recovery service, or feedback action named by the current phase; it never activates that choice for the player.

The playable stage now opens in a settlement bazaar. Move among the six named stations and confirm that only the selected station's explanation and actions occupy the right dock. The **Assignment Board** owns the opening obligation, **Workshop** opens the chassis tools, and **Departure Gate** opens route planning only after the assignment is answered. Returning to the bazaar must not change the run.

Inside the workshop, the chassis opens as a passive overview. Its cyan outline identifies the system described by the inspector; it does not mean the module is being moved. **Edit Chassis** deliberately switches to the gold cursor, movement instructions, and placement language. Pointer users may click the grid directly to enter the same editing context.

Pause preserves two different intentions. **Resume Here** and the cancel shortcut return to the exact control the tester left. The adjacent phase-labelled **Go to…** action returns to the required decision instead. Ask testers which they expect before activation; both paths must leave the run unchanged.

Before starting, move focus or the pointer across the title's chapter actions. The right-hand journey card should explain the selected obligation, regional pressure, recovery point, and finale. Continue should instead name the exact saved next decision and fortress condition. Ask whether the tester can choose a chapter without relying on tooltips or prior knowledge.

The title **Field Guide** can launch either prepared chapter directly after explaining their shared rules. If Continue exists, both guide actions use the same explicit replacement warning as their title equivalents; cancelling must return to the chapter action the tester chose.

After returning from a live stage, the title briefly prioritizes a return receipt over the generic save summary. It should name the exact saved checkpoint or debrief, or state that unsaved chapter changes were discarded and whether Continue still points to an older decision. Starting or continuing a chapter clears the receipt.

## Suggested session

1. At Ashgate, explore the bazaar without coaching. Ask whether the player can find the assignment, workshop, and departure gate and whether unavailable services are described honestly.
2. Accept or decline the guard contract, enter Plan Journey, compare Rill Crossing and The Soot Orchard, and ask what each visibility label promises.
3. Commit the route and stop at the moving-fortress road screen. Ask whether the exact resource receipt and pending arrival are clear before continuing to contact.
4. During battle, stop after each step and explain aloud why an enemy chose its target. Compare the card's exact next-hit damage with the applied result. With keyboard or controller, use **Inspect Chassis** and confirm that active targets are reached without a mouse.
5. Resolve the local event or seeded road occurrence and ask whether its cost and consequence were clear before choosing. Across repeat runs, note whether quiet phases and event phases both feel intentional.
6. At Morrowline, inspect Mara Flint's workshop and crew requirements. If she joins, compare rebuilding the named weakest system against bracing the Refugee Bunk; ask whether the immediate benefit and later obligation are both clear.
7. Decide whether repairing, refueling, changing the layout, or preserving money is more valuable. If Mara is aboard, confirm her extra repair point is visible before paying. Compare all available roads, including Dry Cistern Cut when a maintained Water Condenser unlocks it.
8. Complete the fourth encounter and resolve Mara's **What Held** callback if active. Ask whether the result clearly follows from the earlier physical commitment.
9. Complete Meridian Pass. On a second attempt, change at least one dependency and take the other branch or deliberately test a recoverable retreat.
10. At the result screen, verify that the debrief card itself retains the secured path, pressure, contract, specialist, resolved road occurrences, Mara's consequence when applicable, and surviving systems, then choose **Record Playtest Notes**.
11. Choose **March On**, read the destination and save explanation, cancel once, then confirm. Verify the other chapter starts normally and the title March Charter later retains the best result from each region.
12. Make one unsaved change and close the window. Verify the game pauses for **Save & Quit**, that **Keep Playing** restores the exact context, and that saving before close can be resumed from Continue after relaunch.

Do not coach testers toward the intended answer. Record where they hesitate, what they expect a control to do, and whether the battle report changes their next decision. A tester may pause and choose **Record Playtest Notes** at any decision; closing the form returns to the still-suspended pause menu with the run unchanged.

Use **March Record** when resuming a checkpoint or asking a tester to explain the run so far. Its first screen names the next order and deterministic run ID; the scrollable remainder records path, pressure, commitments, occurrences, and damaged systems. **Copy March Record** copies only that text to the local clipboard and does not save, upload, or alter the march.

## Feedback bundle

The prototype keeps a small playtest journal on the local machine. It records game events such as route choice, encounter steps, interventions, settlement services, and the final result. It does not record names, typed text outside the feedback form, machine identifiers, or network information.

Nothing is uploaded automatically. **Save Notes Locally** creates a JSON file containing the exact build version, the tester's three written answers—including their perceived cause and next-run change—replay score, final state, and local event journal. The receipt shows the filename and enables **Copy Report Path** for mouse, keyboard, or controller use. Copying places only the local path on the clipboard; the tester still chooses whether and where to share that file.

Before handing the build to a new tester, use **Settings → Reset Playtest Data** from the title. Confirm that the guided first-run title returns. Previously exported feedback reports remain in the user-data folder and must be managed separately by the test owner.

Settings also includes **Interface Audio** at Muted, 40%, 70%, or 100%. These short cues reinforce focus, activation, warnings, and saved checkpoints, but never replace visible state. Ask the tester whether the default 70% feels useful or tiring; test Muted once to confirm the complete run remains understandable without sound.

Automatic saves also produce a short `Saved · <reason>` receipt in the stage header. At 110% text it should remain between the title and the widest contextual Pause label, including Route Review, without covering either control or entering the command-desk scroll area. Opening Pause dismisses the receipt immediately.

The title and contextual **Pause** action remain fixed above the left evidence scroll. Enter chassis editing or inspection at 110% text and confirm the complete grid can scroll into view without moving Pause off-screen. The journey illustration remains during preparation but retires on the debrief so result evidence and the final chassis receive the available space.

When opening Pause with the pointer, **Resume Here** should restore the exact contract, route, battle, or debrief control that was active before the click. The Pause button is deliberately excluded from keyboard/controller focus because those inputs already use Escape or the configured cancel button; **Go to…** remains the separate path to the required current order.

Chassis language follows the current phase. During battle, **Inspect Chassis** enters read-only target review and returns to the encounter orders. A new debrief resets its view and focuses **Inspect Final Chassis** before feedback; selecting a system stays in review, and cancel returns to the debrief action. After review begins, the current-order and Pause shortcuts advance to feedback. Neither inspection path permits placement outside a refit stop.

Inside the inspector, **Battle System**, **Final System**, and **Refit Locked** distinguish targeting, debrief review, and road-state inspection. At 110% text, verify that these labels and their complete helper sentences fit the right-hand detail column; no instruction should end mid-word or disappear beneath the panel edge.

**Visual Contrast** switches between the authored Standard palette and a darker, brighter-outlined High mode. Test it on the title, one route decision, and one contact card. Ask whether focus and secondary copy become easier to find without flattening the difference between safe, warning, danger, and unknown states; every state should remain understandable from its words and symbols alone.

**Controller Confirm** can use A or B. The paired face button becomes Cancel, while Enter and Escape never change. After switching, check the title legend, Pause shortcut, briefing, route review, and chassis instructions; report any place whose hint disagrees with the button that actually acts.

**Build & Local Data** identifies the running artifact and every managed local-data category without opening the filesystem. Use **Copy Data Folder Path** when collecting a save or exported report from a tester. The panel is informational: its copy action moves only the folder path to the clipboard, and its Back/cancel action returns to Settings without resuming a paused run.

The title and Pause footer both label the exact version as **Playtest Build**. Include that full identifier in screenshots or issue reports; it is the same authoritative application version written into saves and exported feedback.

When a decision advances to route planning, the Marchmaster's Desk should scroll from a clean regional-map heading. Selecting a road should then keep its summary, map, Commit, and Cancel together rather than exposing a clipped fragment of the previous section.

During battle, moving focus into an emergency order should keep the complete Current Order and Encounter Order context visible. The top of the desk should never begin on clipped remnants of the run tracker.

Autosave receipts name the state that Continue now preserves. **Battle Step** means the encounter is still active; **Road Secured**, **Recovery Reached**, and **Run Ended** mark resolved transitions.

Completed event receipts pair the exact consequence with one **Next** instruction. Check that this line agrees with the visible route choices or live recovery budget and never suggests that the next action was already taken.

Settings uses three visible sections: **Display & Readability**, **Controls & Feedback**, and **Runs & Local Data**. The fixed breadcrumb follows focused controls even when their section heading scrolls away. Watch whether testers can predict where a preference or reset belongs before reading every row.

## Building locally

Install Godot 4.4.1 with export templates, then run:

```bash
bash scripts/verify.sh
bash scripts/export_playtest.sh windows
bash scripts/export_playtest.sh macos
```

Generated builds are written to `build/` and are intentionally ignored by Git. Tagged releases also build Windows and macOS playtest artifacts in GitHub Actions.

For comparative sessions, prefer a retained CI or tagged-release artifact over a local rebuild. From the extracted artifact root, run `python tools/verify_release_manifest.py artifacts/release_manifest.json` and keep all five sessions on the same `cohort.id`. Windows and macOS exports from the same source share that ID while retaining platform-specific hashes. The bundled observer brief, session sheet, verifier, and scope/limitations document are all hashed so the build or testing instructions cannot drift unnoticed during a cohort.

## Questions for the first five testers

- Could they identify why a module was ready, strained, or offline?
- Did route risk, pressure, fuel, and heat lead to a deliberate route choice?
- Did known, forecast, and unscouted information feel distinct and trustworthy?
- Did closure pressure create urgency without making the route feel arbitrary?
- Could they predict an enemy target before contact?
- Did the single intervention feel consequential and correctly timed?
- Were the contract, event choices, and the mutually exclusive value of Iven and Mara understandable before committing resources?
- Did Mara's repair-versus-refuge choice feel like one scarce physical commitment rather than a dialogue answer?
- Did each road occurrence feel connected to the installed fortress, and was at least one legal response obvious before committing?
- At Morrowline, did recovery create a real trade-off?
- After retreat, did the player understand both the penalty and how to continue?
- Did the final result explain enough for them to want to change the next build?

The next implementation slice should be chosen from repeated playtest evidence, not from the longest feature list.
