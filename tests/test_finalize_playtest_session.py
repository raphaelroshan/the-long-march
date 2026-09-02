#!/usr/bin/env python3
from __future__ import annotations

import copy
import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest
from tools.finalize_playtest_session import create_packet, verify_packet
from tools.prepare_playtest_session import prepare_session
from tools.verify_release_manifest import sha256


def feedback_payload(build: str) -> dict[str, object]:
    return {
        "schema_version": 2,
        "build_version": build,
        "answers": {
            "clear_or_satisfying": "The target lock explained the impact.",
            "confusing_or_frustrating": "The first route warning was easy to miss.",
            "causal_replay": "I would protect the engine before the pass.",
            "replay_score": 4,
        },
        "final_state": {
            "run_code": "PACKET-01",
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
                {"timestamp_unix": 1020, "event": "road_event_resolved", "properties": {"event": "salvage_choice", "choice": "take_fuel"}},
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
            [
                ("desktop_package", "build/game.exe"),
                ("session_sheet", "docs/private_alpha_session_sheet.md"),
            ],
            "workflow-sha",
            "head-sha-1234567890",
            "refs/tags/v0.3.0-alpha.test",
            "https://example.invalid/runs/12",
            "windows",
            "4.4.1.stable.official",
            ["deterministic_tests", "windows_packaged_smoke"],
        )
        manifest_path = cohort / "artifacts/release_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

        observer = sessions / "session-01-observer.md"
        prepare_session(manifest_path, observer, 1)
        feedback = sessions / "session-01-feedback.json"
        feedback.write_text(json.dumps(feedback_payload("0.3.0-alpha.test")), encoding="utf-8")
        observer_digest = sha256(observer)
        feedback_digest = sha256(feedback)

        packet = sessions / "session-01-packet"
        created = create_packet(manifest_path, observer, feedback, packet)
        assert created == packet.resolve()
        assert sha256(observer) == observer_digest
        assert sha256(feedback) == feedback_digest
        assert verify_packet(packet) == []
        packet_manifest = json.loads((packet / "packet_manifest.json").read_text(encoding="utf-8"))
        assert packet_manifest["artifact"]["product_version"] == "0.3.0-alpha.test"
        assert packet_manifest["artifact"]["cohort_id"] == "0.3.0-alpha.test@head-sha-123"
        assert packet_manifest["session"] == {"number": 1, "run_code": "PACKET-01"}
        assert packet_manifest["claims"]["artifact_identity_verified"] is True
        assert packet_manifest["claims"]["comprehension_verified"] is False
        assert (packet / "release_manifest.json").read_bytes() == manifest_path.read_bytes()
        assert (packet / "observer.md").read_bytes() == observer.read_bytes()
        assert (packet / "feedback.json").read_bytes() == feedback.read_bytes()
        assert "Journey continuity" in (packet / "automatic.md").read_text(encoding="utf-8")
        assert "does not prove consent" in (packet / "README.md").read_text(encoding="utf-8")

        try:
            create_packet(manifest_path, observer, feedback, packet)
        except ValueError as exc:
            assert "will not be overwritten" in str(exc)
        else:
            raise AssertionError("an existing packet must not be overwritten")
        assert sha256(observer) == observer_digest and sha256(feedback) == feedback_digest

        wrong_build = sessions / "wrong-build.json"
        wrong_build.write_text(json.dumps(feedback_payload("0.3.0-alpha.other")), encoding="utf-8")
        try:
            create_packet(manifest_path, observer, wrong_build, sessions / "wrong-build-packet")
        except ValueError as exc:
            assert "feedback build does not match" in str(exc)
        else:
            raise AssertionError("a feedback export from another build must be rejected")
        assert not (sessions / "wrong-build-packet").exists()

        altered_observer = sessions / "altered-observer.md"
        altered_observer.write_text(
            observer.read_text(encoding="utf-8").replace("Platform: `windows`", "Platform: `macos`"),
            encoding="utf-8",
        )
        try:
            create_packet(manifest_path, altered_observer, feedback, sessions / "altered-observer-packet")
        except ValueError as exc:
            assert "do not match this verified cohort" in str(exc)
        else:
            raise AssertionError("observer notes from another cohort must be rejected")

        tampered = copy.deepcopy(packet_manifest)
        tampered["claims"]["comprehension_verified"] = True
        (packet / "packet_manifest.json").write_text(json.dumps(tampered), encoding="utf-8")
        assert any("human-owned false claim" in error for error in verify_packet(packet))
        (packet / "packet_manifest.json").write_text(json.dumps(packet_manifest), encoding="utf-8")
        (packet / "observer.md").write_text("changed notes\n", encoding="utf-8")
        packet_errors = verify_packet(packet)
        assert any("size mismatch" in error for error in packet_errors)
        assert any("SHA-256 mismatch" in error for error in packet_errors)

        try:
            create_packet(manifest_path, observer, feedback, cohort / "packet")
        except ValueError as exc:
            assert "outside the verified cohort" in str(exc)
        else:
            raise AssertionError("a packet inside the retained cohort must be rejected")

    print("PASS: The Long March provenance-checked playtest session packet")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
