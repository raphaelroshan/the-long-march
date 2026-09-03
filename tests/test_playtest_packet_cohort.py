#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest
from tools.finalize_playtest_session import create_packet
from tools.prepare_playtest_session import prepare_session
from tools.summarize_playtest_packets import build_packet_cohort_report, load_packet_cohort


def feedback_payload(run_code: str) -> dict[str, object]:
    return {
        "schema_version": 2,
        "build_version": "0.3.0-alpha.test",
        "answers": {
            "clear_or_satisfying": f"Target lock was clear in {run_code}.",
            "confusing_or_frustrating": "The first route warning was easy to miss.",
            "causal_replay": "I would protect the engine before the pass.",
            "replay_score": 4,
        },
        "final_state": {
            "run_code": run_code,
            "campaign_region": "ashgate_lowlands",
            "result": "scarred_march",
            "campaign_path": ["ashgate_depot", "soot_orchard"],
            "hull": 6,
            "fuel": 2,
            "campaign_pressure": 7,
        },
        "session_metrics": {
            "encounter_steps": 0,
            "contact_targets_locked": 0,
            "contact_target_inspections": 0,
            "emergency_orders_used": 0,
            "journey_commitments": 1,
            "road_events_reached": 1,
            "road_events_resolved": 1,
            "road_arrivals_completed": 1,
        },
        "session": {
            "started_at_unix": 1000,
            "events": [
                {"timestamp_unix": 1000, "event": "campaign_node_started", "properties": {"node": "soot_orchard"}},
                {"timestamp_unix": 1010, "event": "road_event_reached", "properties": {"event": "salvage_choice"}},
                {"timestamp_unix": 1020, "event": "road_event_resolved", "properties": {"event": "salvage_choice"}},
                {"timestamp_unix": 1030, "event": "road_arrival_completed", "properties": {"destination": "soot_orchard"}},
            ],
        },
    }


def main() -> int:
    with tempfile.TemporaryDirectory() as directory:
        base = Path(directory)
        cohort = base / "cohort"
        sessions = base / "sessions"
        for folder in (cohort / "tools", cohort / "build", cohort / "docs", cohort / "artifacts"):
            folder.mkdir(parents=True, exist_ok=True)
        (cohort / "tools/ci_manifest.json").write_text(
            json.dumps(
                {
                    "slug": "the-long-march",
                    "display_name": "The Long March",
                    "prototype_version": "0.3.0-alpha.test",
                    "save_compatibility": {"minimum": 4, "current": 16},
                    "campaign_contract": {"regions": 4, "session_minutes": {"minimum": 30, "maximum": 90}, "timing_evidence": "authored_target_not_human_observation", "completed_packets": [f"LM-GPT56-{index}" for index in range(0, 6)]},
                    "playtest_ready": True,
                    "release_ready": False,
                    "primary_repo": "example/the-long-march",
                }
            ),
            encoding="utf-8",
        )
        (cohort / "build/game.exe").write_bytes(b"verified playtest")
        (cohort / "docs/private_alpha_session_sheet.md").write_text(
            "# The Long March — Private Alpha Session Sheet\n\n## Evidence to collect\n\n- First action: __________\n",
            encoding="utf-8",
        )
        manifest = build_manifest(
            cohort,
            cohort / "tools/ci_manifest.json",
            [("desktop_package", "build/game.exe"), ("session_sheet", "docs/private_alpha_session_sheet.md")],
            "workflow-sha",
            "head-sha-1234567890",
            "refs/tags/v0.3.0-alpha.test",
            "https://example.invalid/runs/12",
            "windows",
            "4.4.1.stable.official",
            ["deterministic_tests"],
        )
        manifest_path = cohort / "artifacts/release_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

        packets: list[Path] = []
        for session_number, run_code in ((1, "PACKET-01"), (3, "PACKET-03")):
            observer = sessions / f"session-{session_number:02d}-observer.md"
            prepare_session(manifest_path, observer, session_number)
            with observer.open("a", encoding="utf-8") as output:
                output.write(f"\nPrivate observer phrase {session_number} must not be summarized.\n")
            feedback = sessions / f"session-{session_number:02d}-feedback.json"
            feedback.write_text(json.dumps(feedback_payload(run_code)), encoding="utf-8")
            packet = sessions / f"session-{session_number:02d}-packet"
            create_packet(manifest_path, observer, feedback, packet)
            packets.append(packet)

        records = load_packet_cohort(list(reversed(packets)))
        assert [record["session_number"] for record in records] == [1, 3]
        report = build_packet_cohort_report(records)
        assert "INCOMPLETE (2/5 verified packets)" in report
        assert "one cohort (`0.3.0-alpha.test@head-sha-123`)" in report
        assert "| 01 | `0.3.0-alpha.test`" in report
        assert "| 03 | `0.3.0-alpha.test`" in report
        assert "### Session 01" in report and "### Session 03" in report
        assert "Target lock was clear in PACKET-03" in report
        assert "Private observer phrase" not in report
        assert "Observer prose is neither copied nor summarized" in report
        assert "does not prove consent" in report
        assert "| pending 1 | [ ] | [ ]" in report

        try:
            load_packet_cohort([packets[0], packets[0]])
        except ValueError as exc:
            assert "numbers must be unique" in str(exc)
        else:
            raise AssertionError("the same numbered packet must not be counted twice")

        observer_two = sessions / "session-02-observer.md"
        prepare_session(manifest_path, observer_two, 2)
        duplicate_feedback_packet = sessions / "session-02-duplicate-feedback-packet"
        create_packet(
            manifest_path,
            observer_two,
            sessions / "session-01-feedback.json",
            duplicate_feedback_packet,
        )
        try:
            load_packet_cohort([packets[0], duplicate_feedback_packet])
        except ValueError as exc:
            assert "same feedback export" in str(exc)
        else:
            raise AssertionError("one feedback export must not count as two sessions")

        (packets[1] / "observer.md").write_text("tampered\n", encoding="utf-8")
        try:
            load_packet_cohort([packets[1]])
        except ValueError as exc:
            assert "invalid session packet" in str(exc) and "mismatch" in str(exc)
        else:
            raise AssertionError("a changed packet must be rejected before cohort synthesis")

    print("PASS: The Long March verified packet cohort review")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
