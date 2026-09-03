# The Long March — visual evidence review

**Reviewed build:** `0.3.0-alpha.364` plus the pending route-badge correction

**Review date:** 2026-09-04

**Evidence:** validated 1280×720 and 1600×900 LM-GPT56 journey cohorts

## Evidence-backed finding

**Concern — assignment badge obscures destination identity.** In `06_route_commitment.png` at both supported sizes, the `ACCEPTED` badge sits across the upper-right of the Morrowline Camp node and competes with its title. The assignment state is visible, but the marker weakens the map's required non-color status grammar at the exact destination it is meant to clarify.

The correction places assignment markers beside their destination when chart space permits, falls back to the opposite side, and uses an above-node fallback only in a constrained standalone map. A geometry assertion requires the real journey planner to keep the marker inside the chart without intersecting its destination node.

The post-change geometry passes the Ashgate and Veyru journey-flow assertions at 1280×720. A fresh local rendered-frame capture was attempted but did not complete under this Mac's headless renderer, so this review does not claim a post-change screenshot; the next configured CI or release evidence cohort should visually confirm the corrected placement.

## Other observed states

The reviewed title, Ashgate handoff, route commitment, travel interruption, contact, arrival, Morrowline recovery, and Debrief retain one visible phase, a stable left rail, a center-stage fortress or map, and one right-hand decision dock. The fortress remains recognizable across the sequence. Required actions remain visible in the committed 1280×720 cohort.

These observations establish rendering and layout properties only. They do not establish that players understand the route graph, recognize the fortress as inhabited, follow battle causality, enjoy the pacing, or want to replay.

## Boundary reached

No additional objective blocker is visible in the validated cohort. The active roadmap now requires a consented, uncoached LM-H1 session on one retained checksummed candidate. Further hierarchy, pacing, tutorial, prose, or game-feel changes should respond to observed behavior rather than another speculative review pass.
