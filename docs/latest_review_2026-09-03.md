# The Long March — latest review

**Build:** `0.3.0-alpha.363`  
**Main commit:** `6733ea8`  
**Engine:** Godot 4.4.1  
**Viewport:** 1280×720  
**Evidence:** `docs/visual_evidence/v0.3.0-alpha.363-review-2026-09-03/`

## Verification result

The full repository verification suite passed after restoring the repository-owned `tools/validate_versions.py` into the sandbox path expected by the wrapper. The test run passed the creative vertical, complete journey handoff, responsive 1280×720 and 1600×900 profiles, regional flows, breadth, memory, recovery, controller, accessibility, audio, performance, and hardening markers.

## Visual result

The three fresh smoke captures are uniform grey frames. This is an evidence-harness failure, not a verified gameplay rendering failure. The project’s game tests are green, but these images cannot be used to support an investment-facing visual claim.

The prior Long March evidence suggests the opening has a strong moving-fortress identity. The next trustworthy review must replace the desktop ImageGrab timing path with a Godot-controlled viewport capture or a readiness handshake that waits for the first rendered frame. It must then capture First Watch, refit, route selection, contact/event, visible consequence, recovery, arrival, and Debrief from one clean save.

## Roadmap update

The first mandatory task is now **LM-GPT56-0**: repair the screenshot harness and add a deterministic rendered-frame readiness check. Then execute **LM-GPT56-1** for the complete clean-save journey and causal Debrief. Do not treat the grey captures as evidence that the game itself is grey or broken, and do not add another region until the complete journey is visually proven.

## Evidence files

- `01_title.png` — grey frame; capture invalid.
- `02_first_action.png` — grey frame; capture invalid.
- `03_followup.png` — grey frame; capture invalid.
