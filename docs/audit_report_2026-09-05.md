# The Long March — audit report

**Build:** `0.3.0-alpha.364`

**Baseline commit:** `73fc3d7`

**Engine:** Godot 4.4.1

**Viewports:** 1600×900 and responsive 1280×720

**Evidence:** `docs/visual_evidence/v0.3.0-alpha.364-gpt56-1c-1600x900/` and `docs/visual_evidence/v0.3.0-alpha.364-gpt56-1c-1280x720/`

## Automated result

The 900-second monolithic-wrapper timeout is resolved as a verification-orchestration problem, not a gameplay assertion failure. The wrapper now preserves all prior 26 Python invocations and 55 Godot invocations, adds one group-contract test, and exposes five independently runnable groups with per-step, per-group, and final machine-readable timing.

On the pinned Godot 4.4.1 local run, static completed in 5 seconds, core in 41 seconds, presentation in 52 seconds, journey in 134 seconds, and regional in 76 seconds. Journey is the slowest group. The slowest individual fixtures were 11-second complete-journey variants, led by the Cinder Quarry profile in the final summary; no fixture approached the external 900-second bound. GitHub Actions now runs the five groups as bounded Linux jobs and repeats all four Godot groups on Windows. Timing is machine-specific diagnostic evidence, not a player-facing performance or pacing claim.

## Visual result

The fresh Godot-controlled proof starts from a clean save, completes First Watch, performs a live chassis refit, commits and travels roads, resolves the pre-contact interruption and road contacts, changes specialists, uses recovery, reaches Meridian Pass, and ends in Debrief after five secured contacts. Both manifests record the four required save/resume checkpoints and terminal `results` state at encounter step five.

The complete standard set contains 24 validated rendered states at 1600×900. The representative accessibility set contains 22 at 1280×720 with 110% text, high contrast, reduced motion, and alternate controller confirmation. The refit, contact, recovery, and Debrief frames were visually inspected for bounds and readable action hierarchy. The compact contact remains deliberately dense; whether an uncoached player understands it is an LM-H1 observation question.

## Next task

**LM-GPT56-1C is complete.** The sole next packet is **LM-H1**: run one consented, uncoached observation cohort against one exact checksummed candidate and convert the first repeated finding into a narrow issue. Repository automation does not establish comprehension, comfort, pacing, or replay appetite.
