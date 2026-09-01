# The Long March — Private Alpha Session Sheet

Use this sheet for the first five uncoached sessions. The observer may explain the session purpose and controls printed on screen, but must not recommend a layout, route, intervention, recovery service, or event choice.

## Before each session

1. Select one retained artifact cohort and keep its extracted directory unchanged.
2. Run `python tools/prepare_playtest_session.py artifacts/release_manifest.json --session 1 --output ../long-march-session-01.md`, changing the session number and output for each tester. Do not use a cohort if verification fails.
3. Use the generated sheet, which already records the exact build, cohort ID, platform, source and workflow commits, Godot version, executable digest, manifest digest, and verification gates.
4. Use **Settings → Reset Playtest Data** unless the session explicitly tests Continue.
5. Record the device, display scale, input method, tester alias, and observer, then ask for consent before taking notes, screenshots, recordings, or collecting the local JSON export.
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

The game already records committed routes, interventions, services, event choices, final state, build version, a replay score, the tester's written account of the result cause and next-run change, structured outcome facts for installed systems and surviving threats, and the ordered commitment → road scenario → resolution → arrival trail in a local-only feedback export. It does not record cursor movement, hesitation, incorrect predictions, spoken explanations, or emotion. Those require an observer note and must never be inferred from completion alone.

## Generate a session sheet from an export

After the tester chooses **Record Playtest Notes → Save Notes Locally**, copy the report path and run:

```bash
python3 tools/summarize_playtest_feedback.py /absolute/path/to/the_long_march_feedback_....json --output session-01-automatic.md
```

The generated Markdown combines the local event trail with blank observation fields. Its contact section lists event-derived counts and the ordered target-lock, inspection, and emergency-order trail. Its journey section lists route commitments, road scenarios reached and resolved, and completed arrivals in chronological order. It warns if exported aggregate counts disagree with the raw events and derives counts for older exports that predate either metric block. It does not modify the source export, send data anywhere, infer comprehension from interaction counts, or replace an existing output file. Keep the automatic summary separate from the hand-written observer sheet.

When the observer sheet is complete, bind it to the matching export in a new local packet:

```bash
python3 tools/finalize_playtest_session.py create artifacts/release_manifest.json --observer /path/session-01-observer.md --feedback /path/the_long_march_feedback_....json --output /path/session-01-packet
python3 tools/finalize_playtest_session.py verify /path/session-01-packet
```

Creation reverifies the retained cohort, requires the observer's embedded build and artifact digests to match it, requires the feedback build to match, then copies both inputs byte-for-byte alongside the automatic summary and a checksummed packet manifest. It never alters either source and refuses an existing packet directory. Packet validity proves artifact identity and later tamper detection only; consent, participant uniqueness, uncoached conditions, comprehension, and severity remain human confirmations.

After collecting the intended five exports, generate a cohort review in the same argument order used for the session numbers:

```bash
python3 tools/summarize_playtest_cohort.py /path/session-01.json /path/session-02.json /path/session-03.json /path/session-04.json /path/session-05.json --output cohort-review.md
```

The cohort tool reports whether five exports are present, but deliberately does not call the human gate passed. It places each tester's three written answers beside the exported game-result explanation, system condition, and surviving-threat facts without scoring agreement. It also refuses to replace an existing cohort review. Confirm consent, unique participants, uncoached conditions, and repeated observed failures in the generated review before changing the roadmap.

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
| Road scenario before arrival | 1280×720 | 100% | Standard | origin, destination, arrival-pending state, and both choices |
| Arrival after scenario | 1280×720 | 100% | Standard | secured destination, applied road decision, and next action |
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

The exported JSON includes a `session_metrics` block with counts for encounter steps, contact targets locked, deliberate target inspections, emergency orders used, route commitments, road scenarios reached and resolved, and completed arrivals. Treat these as navigation evidence, not intent: compare both chronological trails and observer notes before concluding that a player understood a target or transition. A scenario reached without a later arrival may be confusion, an intentional stop, a crash, or the agreed session boundary.
