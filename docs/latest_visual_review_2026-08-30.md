# The Long March — Latest Visual Review

**Build:** `0.3.0-alpha.297`

**Source baseline:** `origin/main` after `0.3.0-alpha.297`; documentation-only review changes do not alter the packaged game

**Engine:** Godot 4.4.1

**Capture:** Complete deterministic player-facing journey at 1600×900, plus 1280×720 with 110% text, high contrast, reduced motion, and alternate controller guidance.

## Verification

The full repository verification suite passed, including version consistency, content, release manifest, fortress state, campaign, playtest journal, interface audio, visual contrast, silhouette, road contact, events, recovery, controller, settlement, shell, tutorial, complete-flow, replayable-mastery, responsive, performance, and Flooded Veyru UI suites. Both capture runs completed from a clean title through First Watch, live Ashgate, five encounters, Morrowline recovery, Meridian Pass, and terminal Debrief without debug actions.

## Evidence

- [Title](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_01_title.png)
- [First Watch introduction](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_02_first_action.png)
- [Follow-up](visual_evidence/v0.3.0-alpha.297-review-2026-08-30/long_03_followup.png)
- [Complete 1600×900 journey](visual_evidence/v0.3.0-alpha.297-complete-review-1600x900/)
- [Complete responsive 1280×720 journey](visual_evidence/v0.3.0-alpha.297-complete-review-1280x720/)

## Findings

The title has a coherent visual identity, clearly exposes First Watch and the two journey chapters, and provides readable control hints. The First Watch introduction is clear, with a convincing moving-fortress silhouette and a strong moving-settlement premise.

The former complete-handoff evidence gap is closed. Ashgate keeps values left, the fortress central, and the selected bazaar station right. Route review separates reversible selection from Commit. Travel, contact, arrival, roadside consequence, recovery, final arrival, and Debrief remain distinct. The 1280×720 accessibility profile retains every required action and focus target.

The remaining uncertainty is human rather than structural. Route and contact docks are information-dense, and the Debrief uses scrollable evidence areas. Automated bounds checks prove reachability, but only uncoached sessions can determine whether players read the right information, understand the causal chain, and choose a concrete replay experiment without prompting.

## Next roadmap sequence

1. Run consented, uncoached sessions with the verified `v0.3.0-alpha.297` cohort.
2. Record whether players can explain the selected road, the current threat and counter, the recovery trade-off, and the final causal chain without opening debug records or receiving coaching.
3. Rank repeated comprehension, pacing, comfort, and balance failures by severity and frequency.
4. Fix the highest-severity observed failure in one bounded change with the same deterministic and responsive gates.
5. Defer another region, progression layer, or broad content expansion until the current journey's human evidence supports it.

The automated L1–L10 roadmap is complete. Human testing is now the evidence source for further game-quality changes, not a claim that the private alpha is commercially finished.
