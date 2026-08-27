# The Long March — Functional Playtest Guide

## What this build is testing

This playtest is about one question: can a player understand how a fortress layout causes a journey outcome? It is not a content-volume test. A useful session is one complete attempt from Ashgate Depot to Meridian Pass, including retreat or failure.

The build opens with a five-part Marchmaster briefing. **How to play** reopens it at any time. The green **NEXT** line on the Marchmaster's Desk gives one contextual instruction for the current phase without prescribing a winning layout.

## Suggested session

1. Complete one run with the prepared layout and the Long Road.
2. On a second attempt, move at least one dependency and try a different route or doctrine.
3. During battle, stop after each step and explain aloud why an enemy chose its target.
4. At Morrowline, decide whether repairing, refueling, or changing the layout is more valuable.
5. At the result screen, inspect the surviving systems and open **Playtest feedback**.

Do not coach testers toward the intended answer. Record where they hesitate, what they expect a control to do, and whether the battle report changes their next decision.

## Feedback bundle

The prototype keeps a small playtest journal on the local machine. It records game events such as route choice, encounter steps, interventions, settlement services, and the final result. It does not record names, typed text outside the feedback form, machine identifiers, or network information.

Nothing is uploaded automatically. **Save feedback bundle** creates a JSON file containing the tester's two written answers, replay score, final state, and local event journal. The confirmation message shows the exact path. The tester chooses whether to share that file.

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
- Could they predict an enemy target before contact?
- Did the single intervention feel consequential and correctly timed?
- At Morrowline, did recovery create a real trade-off?
- Did the final result explain enough for them to want to change the next build?

The next implementation slice should be chosen from repeated playtest evidence, not from the longest feature list.
