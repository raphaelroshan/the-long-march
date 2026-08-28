# The Long March — Functional Playtest Guide

## What this build is testing

This playtest is about two connected questions: can a player understand how a fortress layout causes a battle outcome, and can they use incomplete map information to plan five encounters? It is not a content-volume test. A useful session is one complete attempt from Ashgate Depot to Meridian Pass, including contract, route decisions, Morrowline recovery, retreat, or failure.

The build opens with a seven-step Marchmaster briefing that introduces one core dependency or journey decision at a time. **Open Field Briefing** reopens it at any time. The green current-order line on the Marchmaster's Desk follows the active decision—contract, route preview, battle, recovery, or result—without prescribing a winning layout.

## Suggested session

1. At Ashgate, compare Rill Crossing and The Soot Orchard before choosing; ask what the player believes each visibility label promises.
2. Accept or decline the guard contract without coaching, then complete one route through Broken Relay or Red Wheel Toll Bridge.
3. During battle, stop after each step and explain aloud why an enemy chose its target. Compare the card's exact next-hit damage with the applied result. With keyboard or controller, use **Inspect Chassis** and confirm that active targets are reached without a mouse.
4. Resolve the local event or seeded road occurrence and ask whether its cost and consequence were clear before choosing. Across repeat runs, note whether quiet phases and event phases both feel intentional.
5. At Morrowline, inspect Mara Flint's workshop and crew requirements. If she joins, compare rebuilding the named weakest system against bracing the Refugee Bunk; ask whether the immediate benefit and later obligation are both clear.
6. Decide whether repairing, refueling, changing the layout, or preserving money is more valuable. If Mara is aboard, confirm her extra repair point is visible before paying. Compare all available roads, including Dry Cistern Cut when a maintained Water Condenser unlocks it.
7. Complete the fourth encounter and resolve Mara's **What Held** callback if active. Ask whether the result clearly follows from the earlier physical commitment.
8. Complete Meridian Pass. On a second attempt, change at least one dependency and take the other branch or deliberately test a recoverable retreat.
9. At the result screen, verify that the debrief card itself retains the secured path, pressure, contract, specialist, resolved road occurrences, Mara's consequence when applicable, and surviving systems, then choose **Record Playtest Notes**.
10. Choose **March On**, read the destination and save explanation, cancel once, then confirm. Verify the other chapter starts normally and the title March Charter later retains the best result from each region.
11. Make one unsaved change and close the window. Verify the game pauses for **Save & Quit**, that **Keep Playing** restores the exact context, and that saving before close can be resumed from Continue after relaunch.

Do not coach testers toward the intended answer. Record where they hesitate, what they expect a control to do, and whether the battle report changes their next decision. A tester may pause and choose **Record Playtest Notes** at any decision; closing the form returns to the still-suspended pause menu with the run unchanged.

## Feedback bundle

The prototype keeps a small playtest journal on the local machine. It records game events such as route choice, encounter steps, interventions, settlement services, and the final result. It does not record names, typed text outside the feedback form, machine identifiers, or network information.

Nothing is uploaded automatically. **Save Notes Locally** creates a JSON file containing the exact build version, the tester's two written answers, replay score, final state, and local event journal. The receipt shows the filename; hovering it reveals the full local path. The tester chooses whether to share that file.

Before handing the build to a new tester, use **Settings → Reset Playtest Data** from the title. Confirm that the guided first-run title returns. Previously exported feedback reports remain in the user-data folder and must be managed separately by the test owner.

## Building locally

Install Godot 4.4.1 with export templates, then run:

```bash
bash scripts/verify.sh
bash scripts/export_playtest.sh windows
bash scripts/export_playtest.sh macos
```

Generated builds are written to `build/` and are intentionally ignored by Git. Tagged releases also build Windows and macOS playtest artifacts in GitHub Actions.

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
