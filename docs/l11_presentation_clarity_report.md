# L11 — Presentation Clarity Pass

**Build:** `0.3.0-alpha.298`

## Purpose

Close the concrete presentation weaknesses found in the alpha.297 visual review without changing simulation state, route costs, encounter timing, save data, or player commands.

## Implemented

- Strengthened the shared fortress silhouette with a grounded shadow, tapered hull profile, structural bracing, mode-specific stance cues, service lights, travel dust, and visible damaged-system activity.
- Split travel into visibly distinct departure-gate, passing-landmark, and contact-on-horizon tableaux while retaining reduced-motion skipping.
- Enlarged contact subjects and added a hostile approach lane, target pulse, arrowed intent path, and a compact threat/target/damage/counter presentation summary.
- Added bazaar activity, station canopies and service icons, and a visual link between the selected station and the fortress.
- Reframed roadside choices as an opaque, bordered decision tableau connected to the halted fortress.
- Added an immediate causal banner and damage frame to Debrief so the decisive failure or success is visible before reading the detailed record.
- Added a route-planning state cue that distinguishes inspection, reversible selection, and commitment.

## Boundaries

All changes are presentation-only. `LongMarchState`, save schema, deterministic streams, encounter commands, and authored outcomes are unchanged. The pass does not claim final character art, threat animation, environment art, audio, or human-validated comprehension.

## Verification

- Full `scripts/verify.sh`: PASS with Godot 4.4.1.
- Complete Ashgate journey: PASS.
- Cinder Quarry, declined-convoy, replayable-mastery, 1280×720 responsive, 1600×900 responsive, and Flooded Veyru profiles: PASS.
- New assertions cover fortress mode treatments, route decision state, travel visual beats, named contact handoff, contact readability summary, settlement service link, roadside decision framing, and the debrief causal banner.
- Captures: [`1600×900`](visual_evidence/v0.3.0-alpha.298-presentation-clarity-1600x900/) and [`1280×720 accessibility profile`](visual_evidence/v0.3.0-alpha.298-presentation-clarity-1280x720/).

## Remaining validation

Use uncoached private-alpha sessions to determine whether players notice the target path before advancing, distinguish route selection from commitment, understand why a march ended, and experience travel as movement rather than delay. Further changes should respond to repeated observations rather than add more interface copy.
