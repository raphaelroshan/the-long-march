# Contact Session Summary Report

**Build:** `0.3.0-alpha.326`

## Purpose

Alpha.325 made contact navigation available in explicitly saved local feedback. This slice makes that evidence practical for a human observer without adding telemetry or asking a reviewer to inspect raw JSON.

## Generated evidence

`tools/summarize_playtest_feedback.py` now adds:

- event-derived counts for encounter steps, target locks, target inspections, and emergency orders;
- a chronological table naming the leg, encounter step, target, enemy, and order where recorded;
- an integrity note when exported aggregate counts disagree with the raw event trail;
- a compatible fallback for older exports without a complete `session_metrics` block.

The source JSON is read-only and the generated Markdown remains local.

## Interpretation boundary

The timeline establishes which game actions were recorded and their order. It does not establish that the tester understood the target, consequence, or emergency-order limit. The observer must compare the trail with direct quotes and predictions captured during the session.

## Verification

- Summary tests cover matching counts, mismatched counts, older exports, chronological target rows, and the privacy wording.
- Repository verification continues to exercise the offline boundary and private-alpha contract.
