# Causal Feedback Prompt Report

**Build:** `0.3.0-alpha.328`

## Purpose

General satisfaction and frustration notes do not reveal whether the terminal Debrief taught the intended cause-and-effect model. The local notes form now asks the tester to state what caused the result and one concrete change they would make on the next march.

## Interaction

- Completed runs ask: `What caused this result, and what would you change next run?`
- Paused runs ask for the tester's current plan and the alternative they would try if the run ended there.
- The three written prompts live in a contained scrolling question area; privacy, replay score, and local-save actions remain fixed and visible at 1280×720.
- Keyboard and controller focus follows clear feedback → confusing feedback → causal replay → replay score → actions.

## Evidence boundary

The answer is stored only in the explicitly saved local JSON and rendered in the generated session sheet. It records what the tester says; it does not grade correctness or infer understanding from navigation.

## Verification

- Journal tests verify the new answer survives export.
- The complete prototype flow verifies the result wording, navigation order, save receipt, and exported answer.
- The full journey capture verifies the modal remains contained at 1280×720.
- Visual evidence: [`14_playtest_notes.png`](visual_evidence/v0.3.0-alpha.328-causal-feedback/14_playtest_notes.png).
