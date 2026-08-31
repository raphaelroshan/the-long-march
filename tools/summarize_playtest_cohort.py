#!/usr/bin/env python3
"""Combine local feedback exports into a human-owned private-alpha review sheet."""
from __future__ import annotations

import argparse
from collections import Counter
from collections.abc import Sequence
from pathlib import Path
from statistics import mean
from typing import Any

from summarize_playtest_feedback import contact_metrics, load_feedback


def _cell(value: Any) -> str:
    rendered = str(value).strip().replace("_", " ").title()
    return rendered.replace("|", "\\|") if rendered else "—"


def _duration_minutes(payload: dict[str, Any]) -> int:
    session = payload.get("session", {})
    events = session.get("events", []) if isinstance(session, dict) else []
    timestamps: list[int] = []
    for entry in events:
        if not isinstance(entry, dict):
            continue
        try:
            timestamp = int(entry.get("timestamp_unix", 0))
        except (TypeError, ValueError):
            continue
        if timestamp > 0:
            timestamps.append(timestamp)
    return max(0, round((max(timestamps) - min(timestamps)) / 60)) if timestamps else 0


def _quoted_answer(answers: dict[str, Any], key: str) -> list[str]:
    text = str(answers.get(key, "")).strip().replace("\r\n", "\n").replace("\r", "\n")
    if not text:
        return ["> Not recorded."]
    return [f"> {line}" if line else ">" for line in text.split("\n")]


def build_cohort_report(
    payloads: Sequence[dict[str, Any]],
    required_sessions: int = 5,
) -> str:
    if not payloads:
        raise ValueError("at least one feedback export is required")
    if required_sessions < 1:
        raise ValueError("required_sessions must be at least 1")

    builds = sorted({str(payload.get("build_version", "unknown")) for payload in payloads})
    gate_state = "READY FOR HUMAN SYNTHESIS" if len(payloads) >= required_sessions else "INCOMPLETE"
    rows: list[str] = []
    total_metrics = {
        "encounter_steps": 0,
        "contact_targets_locked": 0,
        "contact_target_inspections": 0,
        "emergency_orders_used": 0,
    }
    replay_scores: list[int] = []
    no_inspection_sessions = 0
    order_sessions = 0
    mismatch_sessions = 0
    run_codes: list[str] = []
    written_evidence: list[str] = []

    for index, payload in enumerate(payloads, start=1):
        final_state = payload.get("final_state", {})
        answers = payload.get("answers", {})
        session = payload.get("session", {})
        events = session.get("events", []) if isinstance(session, dict) else []
        metrics, metrics_status = contact_metrics(payload, events)
        for key in total_metrics:
            total_metrics[key] += metrics[key]
        if metrics["contact_targets_locked"] > 0 and metrics["contact_target_inspections"] == 0:
            no_inspection_sessions += 1
        if metrics["emergency_orders_used"] > 0:
            order_sessions += 1
        if metrics_status == "mismatch":
            mismatch_sessions += 1
        try:
            replay_score = int(answers.get("replay_score", 0)) if isinstance(answers, dict) else 0
        except (TypeError, ValueError):
            replay_score = 0
        if 1 <= replay_score <= 5:
            replay_scores.append(replay_score)
        run_code = str(final_state.get("run_code", "unknown")) if isinstance(final_state, dict) else "unknown"
        if run_code != "unknown":
            run_codes.append(run_code)
        normalized_answers = answers if isinstance(answers, dict) else {}
        written_evidence.extend(
            [
                f"### Session {index}",
                "",
                "**Clear or satisfying**",
                "",
                *_quoted_answer(normalized_answers, "clear_or_satisfying"),
                "",
                "**Confusing or frustrating**",
                "",
                *_quoted_answer(normalized_answers, "confusing_or_frustrating"),
                "",
                "**Perceived cause and next-run change**",
                "",
                *_quoted_answer(normalized_answers, "causal_replay"),
                "",
            ]
        )
        rows.append(
            "| %d | `%s` | `%s` | %s | %s | %dm | %s | %d / %d / %d / %d | %s |"
            % (
                index,
                str(payload.get("build_version", "unknown")),
                run_code,
                _cell(final_state.get("campaign_region", "unknown")) if isinstance(final_state, dict) else "Unknown",
                _cell(final_state.get("result", "incomplete")) if isinstance(final_state, dict) else "Incomplete",
                _duration_minutes(payload),
                f"{replay_score}/5" if 1 <= replay_score <= 5 else "—",
                metrics["encounter_steps"],
                metrics["contact_targets_locked"],
                metrics["contact_target_inspections"],
                metrics["emergency_orders_used"],
                metrics_status,
            )
        )

    average_replay = f"{mean(replay_scores):.1f}/5" if replay_scores else "not recorded"
    duplicate_run_codes = sorted(code for code, count in Counter(run_codes).items() if count > 1)
    mixed_build_note = (
        "- Build consistency: MIXED BUILDS — separate results by build before attributing a repeated issue."
        if len(builds) > 1
        else f"- Build consistency: one build (`{builds[0]}`)."
    )
    human_rows = [
        f"| {index} | [ ] | [ ] | __________ | __________ | __________ |"
        for index in range(1, max(required_sessions, len(payloads)) + 1)
    ]
    lines = [
        "# The Long March — Private Alpha Cohort Review",
        "",
        "## Gate status",
        "",
        f"- Export collection: {gate_state} ({len(payloads)}/{required_sessions} exports).",
        "- This count is not proof of unique participants, consent, an uncoached run, or a passed quality gate. Confirm each row below.",
        "- Duplicate run identity: %s — confirm these are separate sessions before counting them." % ", ".join(f"`{code}`" for code in duplicate_run_codes) if duplicate_run_codes else "- Duplicate run identity: none detected in the exported run codes.",
        mixed_build_note,
        "- Input filenames are omitted from the report so aliases or machine-specific paths are not copied into the cohort summary.",
        "",
        "## Automatic session evidence",
        "",
        "| Session | Build | Run | Chapter | Result | Recorded | Replay | Steps / locks / inspections / orders | Metric check |",
        "|---:|---|---|---|---|---:|---:|---|---|",
        *rows,
        "",
        "## Cohort navigation totals",
        "",
        f"- Encounter steps: {total_metrics['encounter_steps']}",
        f"- Contact target locks: {total_metrics['contact_targets_locked']}",
        f"- Contact target inspections: {total_metrics['contact_target_inspections']}",
        f"- Emergency orders used: {total_metrics['emergency_orders_used']}",
        f"- Sessions with a target lock but no recorded inspection: {no_inspection_sessions}",
        f"- Sessions with at least one emergency order: {order_sessions}",
        f"- Sessions whose aggregate metric block disagrees with the raw event trail: {mismatch_sessions}",
        f"- Mean replay score: {average_replay}",
        "",
        "These totals describe recorded navigation only. They do not establish comprehension, preference, emotion, or causality.",
        "",
        "## Tester-written evidence",
        "",
        "Responses are shown in session order with line breaks preserved. They are not scored, classified, corrected, or treated as observer findings.",
        "",
        *written_evidence,
        "## Validate the human sessions",
        "",
        "| Session | Consent + unique tester | Uncoached | First comprehension failure | Severity | Direct quote or observation |",
        "|---:|---|---|---|---|---|",
        *human_rows,
        "",
        "## Repeated-failure synthesis",
        "",
        "Do not promote a preference from one tester into the roadmap. Group repeated observable failures, then rank blocked progress above irreversible mistakes, misunderstood consequences, slow discovery, and cosmetic preference.",
        "",
        "| Priority | Repeated failure | Sessions affected | Severity | Evidence | Smallest proposed fix | Rejected alternative |",
        "|---:|---|---:|---|---|---|---|",
        "| 1 | __________ | ___ | __________ | __________ | __________ | __________ |",
        "| 2 | __________ | ___ | __________ | __________ | __________ | __________ |",
        "| 3 | __________ | ___ | __________ | __________ | __________ | __________ |",
        "",
        "## Decision gate",
        "",
        "- [ ] At least five consented, unique, uncoached sessions are confirmed.",
        "- [ ] The three highest repeated failures are backed by observation or direct quotes.",
        "- [ ] Each proposed fix is smaller than adding a new region or progression layer.",
        "- [ ] Selected fixes and rejected alternatives are recorded in `docs/decision_log.md`.",
        "- [ ] Affected journeys and the full verification suite are rerun after changes.",
        "",
        "## Privacy boundary",
        "",
        "This report is generated locally. Remove names, machine identifiers, and unrelated personal information before voluntarily sharing it. Do not commit source exports or completed observer notes without explicit participant consent.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("feedback", type=Path, nargs="+", help="Local feedback JSON exports")
    parser.add_argument("--output", type=Path, help="Optional Markdown destination; stdout is used otherwise")
    parser.add_argument("--required-sessions", type=int, default=5, help="Human review target (default: 5)")
    args = parser.parse_args()
    try:
        payloads = [load_feedback(path) for path in args.feedback]
        report = build_cohort_report(payloads, args.required_sessions)
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 1
    if args.output:
        args.output.write_text(report, encoding="utf-8")
        print(f"playtest cohort review: {args.output}")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
