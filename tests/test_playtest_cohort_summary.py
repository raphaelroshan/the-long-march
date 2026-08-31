#!/usr/bin/env python3
from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from summarize_playtest_cohort import build_cohort_report


def _payload(build: str, run_code: str, inspected: bool, replay_score: int) -> dict:
    events = [
        {"timestamp_unix": 1000, "event": "run_started", "properties": {}},
        {"timestamp_unix": 1060, "event": "encounter_step", "properties": {"leg": 1, "step": 1}},
        {"timestamp_unix": 1070, "event": "contact_target_locked", "properties": {"leg": 1, "step": 1, "enemy": "road_raiders", "target": "coal_cell"}},
        {"timestamp_unix": 1120, "event": "intervention_used", "properties": {"leg": 1, "step": 1, "intervention": "seal_compartment"}},
        {"timestamp_unix": 1420, "event": "run_completed", "properties": {}},
    ]
    if inspected:
        events.insert(3, {"timestamp_unix": 1080, "event": "contact_target_inspected", "properties": {"leg": 1, "step": 1, "target": "coal_cell"}})
    return {
        "schema_version": 1,
        "build_version": build,
        "answers": {
            "clear_or_satisfying": "The target warning connected to the hit.",
            "confusing_or_frustrating": "I did not understand the first route cost.",
            "causal_replay": "The engine failed.\nI would repair it before Meridian.",
            "replay_score": replay_score,
        },
        "final_state": {
            "run_code": run_code,
            "campaign_region": "ashgate_lowlands",
            "result": "scarred_march",
            "outcome_facts": {
                "terminal": True,
                "result_id": "scarred_march",
                "result_summary": "SCARRED MARCH · Hull ended below the decisive threshold.",
                "replay_guidance": "NEXT RUN · Preserve hull before Meridian.",
                "systems": [
                    {"id": "steam_lance_engine", "name": "Steam Lance Engine", "durability": 2, "max_durability": 4, "operating_state": "strained", "dependency_reasons": ["fuel link damaged"]},
                ],
                "surviving_threats": [{"id": "siege_beast", "name": "Siege Beast", "hp": 2, "max_hp": 7}],
            },
        },
        "session_metrics": {
            "encounter_steps": 1,
            "contact_targets_locked": 1,
            "contact_target_inspections": 1 if inspected else 0,
            "emergency_orders_used": 1,
        },
        "session": {"started_at_unix": 1000, "events": events},
    }


def main() -> int:
    first = _payload("0.3.0-alpha.327", "ASH-1107", True, 4)
    second = _payload("0.3.0-alpha.326", "VEY-2204", False, 2)
    report = build_cohort_report([first, second])
    assert "INCOMPLETE (2/5 exports)" in report
    assert "MIXED BUILDS" in report
    assert "Sessions with a target lock but no recorded inspection: 1" in report
    assert "Sessions with at least one emergency order: 2" in report
    assert "Mean replay score: 3.0/5" in report
    assert "not proof of unique participants" in report
    assert "do not establish comprehension" in report
    assert "Input filenames are omitted" in report
    assert "Duplicate run identity: none detected" in report
    assert "## Tester-written evidence" in report
    assert "> The target warning connected to the hit." in report
    assert "> I did not understand the first route cost." in report
    assert "> The engine failed.\n> I would repair it before Meridian." in report
    assert "not scored, classified, corrected" in report
    assert "**Recorded game outcome**" in report
    assert "Game result explanation: SCARRED MARCH · Hull ended below the decisive threshold." in report
    assert "Affected systems: Steam Lance Engine 2/4 · Strained · fuel link damaged" in report
    assert "Surviving threats: Siege Beast 2/7" in report

    complete_report = build_cohort_report([copy.deepcopy(first) for _ in range(5)])
    assert "READY FOR HUMAN SYNTHESIS (5/5 exports)" in complete_report
    assert "one build (`0.3.0-alpha.327`)" in complete_report
    assert "passed quality gate" in complete_report
    assert "Duplicate run identity: `ASH-1107`" in complete_report

    mismatched = copy.deepcopy(first)
    mismatched["session_metrics"]["contact_target_inspections"] = 8
    mismatch_report = build_cohort_report([mismatched])
    assert "disagrees with the raw event trail: 1" in mismatch_report

    legacy = copy.deepcopy(first)
    legacy["answers"].pop("causal_replay")
    legacy["final_state"].pop("outcome_facts")
    legacy_report = build_cohort_report([legacy])
    assert "**Perceived cause and next-run change**\n\n> Not recorded." in legacy_report
    assert "Structured outcome facts: not recorded in this export." in legacy_report

    try:
        build_cohort_report([])
    except ValueError as exc:
        assert "at least one feedback export" in str(exc)
    else:
        raise AssertionError("an empty cohort should be rejected")

    print("PASS: The Long March playtest cohort summary")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
