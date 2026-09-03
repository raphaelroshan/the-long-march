---
name: long-march-playtest-triage
description: Triage The Long March's verified private-alpha session packets into repeated, evidence-backed comprehension issues and narrow repository tasks. Use only when real observer notes and matching local feedback exports exist; do not fabricate sessions, infer understanding from telemetry, or use it for ordinary automated test failures.
---

# Long March Playtest Triage

Turn human observation into the next smallest development decision without laundering telemetry into claims about players.

## Require valid inputs

Read `docs/private_alpha_session_sheet.md`, `docs/early_access_test_matrix.md`, and the current milestone in `docs/agent_handoff_roadmap.md`.

Proceed only when each session has:

- explicit consent recorded by the human observer;
- a unique participant and session number;
- uncoached conditions confirmed by the observer;
- an observer sheet and matching local feedback export;
- a packet that passes `python3 tools/finalize_playtest_session.py verify <packet>`;
- artifact and build identities matching the retained cohort.

If these conditions are absent, stop and name the missing evidence. Never generate or complete observer statements on the user's behalf.

## Separate evidence types

- **Observed:** actions, hesitation, wrong predictions, direct quotes, requests for help, visible discomfort.
- **Self-reported:** the tester's written cause, next-run change, and comfort response.
- **Recorded state:** routes, targets, inspections, interventions, services, events, outcome, and timestamps.
- **Inference:** any interpretation connecting those facts. Label it and keep it out of the evidence column.

Read [evidence and severity](references/evidence-and-severity.md) before aggregating sessions.

## Triage the cohort

1. Verify every packet; reject duplicate session numbers or repeated feedback exports.
2. Build one row per observed issue with session, phase, exact behavior or quote, expected decision, consequence, and evidence type.
3. Group only meaningfully equivalent failures. Similar words at different decision boundaries are not automatically the same issue.
4. Prioritize repeated failures across at least two independent sessions. A single blocked-progress or safety issue may still be urgent, but label it as a single-session finding.
5. Rank by blocked progress, wrong irreversible choice, misunderstood consequence, slow discovery, then cosmetic preference.
6. For each priority, propose one narrow reproduction and one smallest credible fix. Do not add explanatory text by default; consider hierarchy, timing, focus, labels, and affordance first.
7. Record accepted and rejected options in `docs/decision_log.md` only after the owner selects a response.

## Output contract

Return:

- packet/cohort identity and verification status;
- findings ordered by severity and recurrence;
- evidence separated into observed, self-reported, and recorded facts;
- a narrow issue proposal with acceptance test for each selected finding;
- contradictions and unanswered questions;
- a clear statement of what cannot be concluded.

Do not declare the human gate complete unless all required sessions exist and the owner has approved disposition of every high-severity issue.
