# Phase-Aware Chassis Review

## Player problem

The chassis stays visible throughout preparation, travel, battle, and debrief, but its passive heading previously always said it was read-only until **Edit Chassis**. That action exists only at a refit stop. Battle already had an explicit inspection path, while the final debrief left keyboard and controller players without any way to review the fortress that produced the result.

## Interaction contract

- Preparation keeps **Chassis Overview** passive and uses **Edit Chassis** to enter placement mode.
- Battle overview points to **Inspect Chassis**, whose purpose is choosing or reviewing a Seal Compartment target.
- The debrief exposes **Inspect Final Chassis** directly after the run summary.
- Active debrief inspection uses **Chassis Review**, never edit or encounter-order language.
- Selecting a surviving system updates the final inspection context and remains in chassis review so adjacent systems can be compared.
- Cancel returns to the visible inspection action for the current phase: battle inspection during contact, final-chassis inspection during debrief, and Edit Chassis during refit.
- Pointer, keyboard, and controller share the same selection path and do not mutate module placement outside refit.

## Presentation

Passive headings name the action that is actually available in the current phase. Tooltips use the same phase-specific destination and return language. The result action sits directly below the debrief heading so reviewing the machine remains part of understanding the outcome rather than appearing to be another replay action.

At 1280×720 with 110% text, focusing the result action keeps it and the debrief heading visible. Entering chassis review scrolls the left pane to the full inspector while preserving the debrief action's right-pane position.

## Scope

This changes no placement, damage, targeting, result, save, or simulation rule. It adds no post-run repair and does not turn the debrief into a second refit phase.

## Visual evidence

- `/tmp/long_march_audit_battle_passive_alpha258_110.png`
- `/tmp/long_march_audit_battle_active_alpha258_110.png`
- `/tmp/long_march_audit_results_passive_alpha258_110.png`
- `/tmp/long_march_audit_results_active_alpha258_110.png`
