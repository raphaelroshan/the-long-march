# The Long March — Latest Visual Review

**Build:** `0.3.0-alpha.298`

**Source baseline:** `0.3.0-alpha.298` presentation-clarity candidate in PR #67

**Engine:** Godot 4.4.1

**Capture:** Targeted deterministic journey evidence at 1600×900, plus 1280×720 with 110% text, high contrast, reduced motion, and alternate controller guidance.

## Verification

The full repository verification suite passed, including version consistency, content, release manifest, fortress state, campaign, playtest journal, interface audio, visual contrast, silhouette, road contact, events, recovery, controller, settlement, shell, tutorial, complete-flow, replayable-mastery, responsive, performance, and Flooded Veyru UI suites. The visual evidence was captured through the same deterministic player-facing journey used by the complete-flow test.

## Evidence

- [1600×900 presentation-clarity set](visual_evidence/v0.3.0-alpha.298-presentation-clarity-1600x900/)
- [1280×720 accessibility set](visual_evidence/v0.3.0-alpha.298-presentation-clarity-1280x720/)
- [Road Raider and Siege Beast target-response frames](visual_evidence/v0.3.0-alpha.298-presentation-clarity-1600x900/)

## Findings

The title remains the strongest authored screen and now has a correctly labelled current-build capture. Its background, hierarchy, scope statement, and First Watch call to action establish a coherent identity that the in-game views can build toward.

Ashgate now reads more clearly as a place rather than a diagram. Station canopies, lamps, workers, cargo, service icons, and a selected-station link frame the same central fortress without changing navigation. Route review explicitly states `inspect → select → commit`, preserving the reversible decision boundary.

Travel has distinct departure, moving-landmark, and contact-on-horizon compositions instead of relying on label changes over one static frame. Contact enlarges the fortress and threat, reserves a hostile approach lane, and connects an arrived threat to its named target with a dashed intent path, arrow, and target pulse. Roadside events now use an opaque framed tableau with a visible relationship between the halted fortress and the event subject.

The Debrief promotes the decisive causal chain immediately below the result and frames damaged/offline systems around the returning fortress. This improves first-glance comprehension while preserving the detailed evidence and replay experiment in the right dock. The 1280×720 accessibility profile retains every required action and all three layout regions.

This is still code-native alpha art. Threat silhouettes, settlement inhabitants, environmental motion, and fortress materials are more readable but not final production assets. Route and contact docks remain deliberately dense enough to require uncoached comprehension testing. Automated bounds and semantic checks establish reachability and causality; they do not prove pacing, emotional impact, or player understanding.

## Next roadmap sequence

1. Run consented, uncoached sessions with the `v0.3.0-alpha.298` presentation candidate after CI packaging succeeds.
2. Record whether players can explain the selected road, the current threat and counter, the recovery trade-off, and the final causal chain without opening debug records or receiving coaching.
3. Rank repeated comprehension, pacing, comfort, and balance failures by severity and frequency.
4. Fix the highest-severity observed failure in one bounded change with the same deterministic and responsive gates.
5. Defer another region, progression layer, or broad content expansion until the current journey's human evidence supports it.

The automated L1–L11 roadmap is complete. Human testing is now the evidence source for further game-quality changes, not a claim that the private alpha is commercially finished.
