# The Long March — Private Alpha Session Sheet

Use this sheet for the first five uncoached sessions. The observer may explain the session purpose and controls printed on screen, but must not recommend a layout, route, intervention, recovery service, or event choice.

## Before each session

1. Select one retained artifact cohort and read its `artifacts/release_manifest.json`.
2. Run `python tools/verify_release_manifest.py artifacts/release_manifest.json`. Do not use a cohort with a missing file or digest mismatch.
3. Use **Settings → Reset Playtest Data** unless the session explicitly tests Continue.
4. Record the exact **Playtest Build** label, `cohort.id`, platform, manifest workflow commit, device, display scale, input method, and tester alias.
5. Ask for consent before taking notes, screenshots, recordings, or collecting the local JSON export.
6. Choose one primary path: First Watch, Ashgate Lowlands, or Flooded Veyru.
7. Do not tell the tester what the interface is intended to mean. Ask what they expect before they act.

## Evidence to collect

Record observable behavior and direct quotes for:

- time and action taken first;
- invalid placement attempts and the dependency the tester expected;
- route-cost and threat prediction before Commit;
- target and damage prediction before advancing a contact;
- understanding of the one-intervention limit;
- recovery choice and rejected alternative;
- event cost recalled after leaving the event;
- outcome explanation from the terminal Debrief;
- one concrete replay change.

The game already records committed routes, interventions, services, event choices, final state, build version, and a replay score in a local-only feedback export. It does not record cursor movement, hesitation, incorrect predictions, spoken explanations, or emotion. Those require an observer note and must never be inferred from completion alone.

## Generate a session sheet from an export

After the tester chooses **Record Playtest Notes → Save Notes Locally**, copy the report path and run:

```bash
python3 tools/summarize_playtest_feedback.py /absolute/path/to/the_long_march_feedback_....json --output session-01.md
```

The generated Markdown combines the local event trail with blank observation fields. It does not modify the source export or send data anywhere.

## Required capture matrix

Capture only with tester consent.

| Moment | Viewport | Text | Contrast | What must be readable |
|---|---:|---:|---|---|
| Title choice | 1280×720 | 100% | Standard | recommended start and selected chapter promise |
| First chassis commitment | 1280×720 | 100% | Standard | physical placement and dependency consequence |
| Route preview | 1280×720 | 110% | Standard | cost, forecast confidence, obligation, Commit/Cancel |
| Contact | 1280×720 | 100% | High | target lock, attack cue, damage, dependency consequence |
| Recovery before service | 1280×720 | 110% | Standard | finite actions and all before/after previews |
| Recovery after service | 1280×720 | 110% | Standard | exact transaction receipt and remaining action |
| Authored event | 1280×720 | 100% | Standard | physical conflict and both practical costs |
| Event callback or record | 1280×720 | 100% | Standard | earlier promise and later held/failed result |
| Terminal Debrief | 1280×720 | 110% | High | causal outcome and one concrete replay experiment |

## Five-session review gate

Do not prioritize fixes from a single preference. After five sessions, group observations by repeated failure:

1. Count how many testers hit each comprehension failure without coaching.
2. Rank by severity: blocked progress, wrong irreversible choice, misunderstood consequence, slow discovery, cosmetic preference.
3. Fix the three highest repeated issues before adding another region.
4. Write the evidence, selected fix, and rejected alternatives into `docs/decision_log.md`.
5. Rerun the affected journey plus the full verification suite.

Keep exported reports and completed sheets outside Git unless every participant explicitly agreed to repository storage and all personal information has been removed.

The exported JSON includes a `session_metrics` block with counts for encounter steps, contact targets locked, deliberate target inspections, and emergency orders used. Treat these as navigation evidence, not intent: compare the event order and observer notes before concluding that a player understood or ignored a target.
