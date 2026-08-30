# L2 Responsive Fortress Presentation Report

**Build:** `0.3.0-alpha.289`

**Viewports:** 1280×720 and 1600×900

**Profile:** 110% text, high contrast, reduced motion, east-button confirm

## Result

PASS. The complete clean-save First Watch-to-Debrief journey preserves its primary three-region presentation and action focus at both supported viewport sizes under the combined accessibility and alternate-controller profile.

## Contract

The full app-shell journey now asserts, where applicable:

- the left status or receipt control is visible and inside the active stage;
- the center fortress, route map, contact, event, recovery, or Debrief subject is visible and inside the active stage;
- the right required action is visible and inside the active stage;
- the three subjects retain left-to-right hierarchy;
- title, tutorial, route, contact, event, recovery, and Debrief focus remains on a legal player-facing action;
- high contrast, reduced motion, and alternate controller guidance reach the live journey views;
- the same deterministic five-contact result is reached under both viewport profiles.

## Defects corrected

At 1280×720 with 110% text, **Morrowline Convoy Guard** previously expanded the selected-station dock three pixels beyond the stage. Bazaar station titles now wrap within the fixed dock instead of changing the stage width.

Checkpoint notices previously covered part of the current location or route heading. The notice now occupies a shallow top lane above those labels while retaining separation from the persistent Pause action.

## Evidence

Representative captures are stored in:

- [`visual_evidence/v0.3.0-alpha.289-l2-responsive-1280x720/`](visual_evidence/v0.3.0-alpha.289-l2-responsive-1280x720/)
- [`visual_evidence/v0.3.0-alpha.289-l2-responsive-1600x900/`](visual_evidence/v0.3.0-alpha.289-l2-responsive-1600x900/)

Each set includes the title, First Watch departure, Ashgate handoff, route commitment, road contact, Morrowline recovery, and terminal Debrief.

## Interpretation

This is a deterministic implementation and visual-layout gate. It proves that required information and actions remain available under the supported matrix; it does not claim general accessibility certification or human comprehension. The next implementation gate is L3 Journey Rhythm.
