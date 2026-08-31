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
            "causal_replay": "The engine failed; I would protect it before Meridian.",
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
            "outcome_facts": {
                "terminal": True,
                "result_id": "scarred_march",
                "result_summary": "SCARRED MARCH · The fortress crossed with a disabled engine.",
                "replay_guidance": "NEXT RUN · Repair the Steam Lance Engine before Meridian.",
                "systems": [
                    {"id": "steam_lance_engine", "name": "Steam Lance Engine", "durability": 0, "max_durability": 4, "operating_state": "offline", "dependency_reasons": ["destroyed"]},
                    {"id": "coal_cell", "name": "Coal Cell", "durability": 3, "max_durability": 3, "operating_state": "ready", "dependency_reasons": []},
                ],
                "surviving_threats": [{"id": "siege_beast", "name": "Siege Beast", "hp": 2, "max_hp": 7}],
            },
        },
        "session_metrics": {
            "encounter_steps": 1,
            "contact_targets_locked": 1,
            "contact_target_inspections": 1,
            "emergency_orders_used": 1,
        },
        "session": {
            "started_at_unix": 1000,
            "events": [
                {"timestamp_unix": 1000, "event": "run_started", "properties": {}},
                {"timestamp_unix": 1060, "event": "module_moved", "properties": {"module": "field_workshop"}},
                {"timestamp_unix": 1180, "event": "campaign_node_started", "properties": {"node": "rill_crossing", "doctrine": "protect_cargo"}},
                {"timestamp_unix": 1200, "event": "encounter_step", "properties": {"leg": 1, "step": 2}},
                {"timestamp_unix": 1210, "event": "contact_target_locked", "properties": {"leg": 1, "step": 2, "enemy": "road_raiders", "target": "coal_cell"}},
                {"timestamp_unix": 1220, "event": "contact_target_inspected", "properties": {"leg": 1, "step": 2, "enemy": "road_raiders", "target": "coal_cell"}},
                {"timestamp_unix": 1240, "event": "intervention_used", "properties": {"intervention": "seal_compartment", "target": "coal_cell", "leg": 1, "step": 2}},
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
        assert "Game result explanation: SCARRED MARCH · The fortress crossed with a disabled engine." in sheet
        assert "Affected systems: Steam Lance Engine 0/4 · Offline · destroyed" in sheet
        assert "Surviving threats: Siege Beast 2/7" in sheet
        assert "the sheet does not grade agreement" in sheet
        assert "Result cause and next-run change: The engine failed; I would protect it before Meridian." in sheet
        assert "Contact navigation: steps 1 / target locks 1 / target inspections 1 / emergency orders 1" in sheet
        assert "Metric check: exported counts match the event trail." in sheet
        assert "Target locked: Road Raiders → Coal Cell" in sheet
        assert "Target inspected: Coal Cell" in sheet
        assert "Emergency order: Seal Compartment → Coal Cell" in sheet
        assert "They do not establish what the tester understood." in sheet
        assert "Consent confirmed" in sheet and "The game does not upload them" in sheet

        payload["session_metrics"]["contact_target_inspections"] = 9
        mismatch_sheet = build_session_sheet(payload, path.name)
        assert "exported counts differ from the event trail" in mismatch_sheet
        del payload["session_metrics"]
        older_sheet = build_session_sheet(payload, path.name)
        assert "older export has no complete metric block" in older_sheet
        del payload["final_state"]["outcome_facts"]
        oldest_sheet = build_session_sheet(payload, path.name)
        assert "Structured outcome facts: not recorded in this export." in oldest_sheet
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
