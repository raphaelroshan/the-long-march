#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.summarize_playtest_feedback import build_session_sheet, load_feedback


def main() -> int:
    payload = {
        "schema_version": 1,
        "build_version": "0.3.0-alpha.test",
        "answers": {
            "clear_or_satisfying": "The target lock explained the hit.",
            "confusing_or_frustrating": "I missed the first route warning.",
            "replay_score": 4,
        },
        "final_state": {
            "run_code": "ASH-1107",
            "campaign_region": "ashgate_lowlands",
            "result": "scarred_march",
            "campaign_path": ["ashgate_depot", "rill_crossing", "morrowline_camp", "meridian_pass"],
            "hull": 6,
            "fuel": 2,
            "campaign_pressure": 7,
        },
        "session": {
            "started_at_unix": 1000,
            "events": [
                {"timestamp_unix": 1000, "event": "run_started", "properties": {}},
                {"timestamp_unix": 1060, "event": "module_moved", "properties": {"module": "field_workshop"}},
                {"timestamp_unix": 1180, "event": "campaign_node_started", "properties": {"node": "rill_crossing", "doctrine": "protect_cargo"}},
                {"timestamp_unix": 1240, "event": "intervention_used", "properties": {"intervention": "seal_compartment", "target": "coal_cell"}},
                {"timestamp_unix": 1360, "event": "settlement_service", "properties": {"service": "refuel"}},
                {"timestamp_unix": 1420, "event": "campaign_event_resolved", "properties": {"event": "mara_workbench_choice", "choice": "rebuild_weakest"}},
            ],
        },
    }
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "feedback.json"
        path.write_text(json.dumps(payload), encoding="utf-8")
        loaded = load_feedback(path)
        sheet = build_session_sheet(loaded, path.name)
        assert "Build: `0.3.0-alpha.test`" in sheet
        assert "Run: `ASH-1107`" in sheet
        assert "Recorded duration: 7 minutes" in sheet
        assert "First recorded player action: Module Moved" in sheet
        assert "Rill Crossing / Protect Cargo" in sheet
        assert "Seal Compartment / Coal Cell" in sheet
        assert "Recovery services: Refuel" in sheet
        assert "Mara Workbench Choice / Rebuild Weakest" in sheet
        assert "Replay score: 4/5" in sheet
        assert "Consent confirmed" in sheet and "The game does not upload them" in sheet
        invalid_path = Path(directory) / "invalid.json"
        invalid_path.write_text("{}", encoding="utf-8")
        try:
            load_feedback(invalid_path)
        except ValueError as exc:
            assert "missing build_version" in str(exc)
        else:
            raise AssertionError("invalid feedback should be rejected")
    print("PASS: The Long March playtest summary")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
