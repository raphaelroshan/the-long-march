# Debrief First-Action Sequence

## Player problem

The debrief told players to inspect surviving systems before recording notes, but its initial focus and current-order jump went directly to feedback. Because the command desk retained its battle scroll position, the first result frame could also open without the debrief heading visible. The interface was teaching one sequence while navigating another.

## Interaction contract

- Entering results resets both stage columns to their debrief starting positions.
- The initial controller/keyboard focus and current-order jump target **Inspect Final Chassis**.
- The inspection action sits immediately below **March Debrief**, ahead of the potentially long result record, so its heading and first action remain visible together at 1280×720 with 110% text.
- Entering chassis review marks only a transient presentation milestone; it does not alter the run, save, result, or March Charter.
- After review begins, current-order guidance and Pause's **Go to…** action advance to feedback.
- Reloading or newly opening a result offers chassis review first again, because the transient viewing milestone is intentionally not serialized.

## Why this order

The fortress is the explanation for the result. Showing its surviving dependencies before asking for free-form feedback helps testers connect the debrief's outcome to the machine they built. Feedback remains optional and one action away after review begins.

## Scope

This adds no mandatory modal, completion gate, analytics event, or save field. Pointer users can still choose any visible debrief action directly.

## Visual evidence

- `/tmp/long_march_alpha259_debrief_arrival_110.png`
- `/tmp/long_march_alpha259_debrief_review_110.png`
