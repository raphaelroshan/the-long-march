# Structured Outcome Facts Report

**Build:** `0.3.0-alpha.330`

## Purpose

The causal feedback prompt records what a tester believes happened. Reviewers also need a compact, authoritative account of the run that does not require reopening a save or reconstructing the final machine from raw events.

## Exported facts

The local feedback bundle now includes an `outcome_facts` block containing:

- whether the export represents a terminal result;
- the stable result and encounter-outcome IDs;
- final hull condition;
- the exact result explanation and replay guidance shown in the Debrief;
- every installed system's ID, display name, durability, maximum durability, operating state, dependency reasons, and exterior status;
- every undefeated threat's ID, display name, remaining health, maximum health, and target.

These are copies of authoritative state and visible presentation facts. They do not change simulation or save data.

## Review presentation

Per-session and cohort Markdown reports show the result explanation, replay guidance, affected systems, and surviving threats beside the tester's causal answer. Fully healthy ready systems remain in the JSON for auditability but are omitted from the concise Markdown list.

Older exports remain readable and state that structured outcome facts were not recorded.

## Interpretation boundary

The tools do not grade agreement, classify understanding, or decide which cause mattered most. A human observer compares the tester's wording with the recorded facts and the uncoached session notes.

## Verification

- Prototype-flow coverage verifies the terminal explanation, complete system list, and surviving-threat list in an actual saved feedback bundle.
- Python summary tests cover affected-system formatting, surviving threats, human-language result text, and older-export fallback.
- The full repository suite preserves deterministic simulation and the offline data boundary.
