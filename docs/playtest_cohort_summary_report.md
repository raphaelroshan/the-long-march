# Playtest Cohort Summary Report

**Build:** `0.3.0-alpha.327`

## Purpose

The private-alpha gate requires five consented, uncoached human sessions. A pile of JSON exports is not itself evidence that this requirement was met. This slice supplies a local synthesis tool that organizes automatic evidence and leaves the claims that require observation visibly incomplete.

## Cohort report

`tools/summarize_playtest_cohort.py` accepts one or more local feedback exports and generates:

- collection status against the five-session target;
- one row per argument, preserving the operator's session order without copying filenames;
- mixed-build and duplicate-run warnings;
- event-derived contact totals and metric-integrity status;
- a blank validation matrix for consent, unique testers, uncoached conditions, failure severity, and direct evidence;
- a blank three-priority synthesis table for repeated failures and smallest fixes.

Five exports are labeled `READY FOR HUMAN SYNTHESIS`, never as a passed gate.

## Release integration

Both the per-session and cohort summarizers are now included in Windows and macOS cohort artifacts and listed in their checksummed release manifests. An observer can therefore verify the cohort and generate reviews without unpacking the source snapshot or installing project dependencies.

## Verification

- Tests cover incomplete and five-export cohorts, mixed builds, duplicate run identities, missing inspections, replay-score averages, aggregate mismatches, and empty-input rejection.
- The private-alpha contract requires both summarizers in CI and tagged release cohorts.
- Full repository verification retains the offline-runtime boundary.
