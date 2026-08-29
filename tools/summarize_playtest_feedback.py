#!/usr/bin/env python3
"""Turn one local feedback export into a human-reviewable session sheet."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PLAYER_ACTIONS = {
    "guard_contract_answered",
    "medicine_contract_answered",
    "module_installed",
    "module_moved",
    "module_rotated",
    "module_stored",
    "campaign_node_started",
    "route_started",
    "campaign_event_resolved",
    "intervention_used",
    "settlement_service",
}


def load_feedback(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read feedback JSON: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError("feedback root must be an object")
    for key in ("build_version", "answers", "final_state", "session"):
        if key not in payload:
            raise ValueError(f"feedback is missing {key}")
    if not isinstance(payload["answers"], dict) or not isinstance(payload["final_state"], dict):
        raise ValueError("feedback answers and final_state must be objects")
    session = payload["session"]
    if not isinstance(session, dict) or not isinstance(session.get("events", []), list):
        raise ValueError("feedback session.events must be an array")
    return payload


def _event_rows(events: list[Any], event_id: str) -> list[dict[str, Any]]:
    return [entry for entry in events if isinstance(entry, dict) and entry.get("event") == event_id]


def _property_list(events: list[Any], event_id: str, fields: tuple[str, ...]) -> str:
    rows: list[str] = []
    for entry in _event_rows(events, event_id):
        properties = entry.get("properties", {})
        if not isinstance(properties, dict):
            continue
        values = [str(properties.get(field, "")).strip().replace("_", " ").title() for field in fields]
        rendered = " / ".join(value for value in values if value)
        if rendered:
            rows.append(rendered)
    return ", ".join(rows) if rows else "not recorded"


def build_session_sheet(payload: dict[str, Any], source_name: str = "feedback.json") -> str:
    answers: dict[str, Any] = payload["answers"]
    final_state: dict[str, Any] = payload["final_state"]
    session: dict[str, Any] = payload["session"]
    events: list[Any] = session.get("events", [])
    timestamps = [int(entry.get("timestamp_unix", 0)) for entry in events if isinstance(entry, dict) and int(entry.get("timestamp_unix", 0)) > 0]
    elapsed_minutes = max(0, round((max(timestamps) - min(timestamps)) / 60)) if timestamps else 0
    first_action = "not recorded"
    for entry in events:
        if isinstance(entry, dict) and str(entry.get("event", "")) in PLAYER_ACTIONS:
            first_action = str(entry.get("event", "")).replace("_", " ").title()
            break
    region = str(final_state.get("campaign_region", "unknown")).replace("_", " ").title()
    result = str(final_state.get("result", "incomplete")).replace("_", " ").title()
    path = final_state.get("campaign_path", [])
    path_text = " → ".join(str(node).replace("_", " ").title() for node in path) if isinstance(path, list) and path else "not completed"
    lines = [
        "# The Long March — Private Alpha Session",
        "",
        "## Session identity",
        "",
        f"- Source: `{source_name}`",
        f"- Build: `{payload.get('build_version', 'unknown')}`",
        f"- Run: `{final_state.get('run_code', 'unknown')}`",
        f"- Chapter: {region}",
        f"- Result: {result}",
        f"- Recorded duration: {elapsed_minutes} minutes",
        "- Tester alias: __________",
        "- Observer: __________",
        "- Date / device / input: __________",
        "- Consent confirmed for local notes and optional report sharing: [ ]",
        "",
        "## Automatic evidence",
        "",
        f"- First recorded player action: {first_action}",
        f"- Route: {path_text}",
        f"- Route commitments: {_property_list(events, 'campaign_node_started', ('node', 'doctrine'))}",
        f"- Interventions: {_property_list(events, 'intervention_used', ('intervention', 'target'))}",
        f"- Recovery services: {_property_list(events, 'settlement_service', ('service', 'module'))}",
        f"- Event choices: {_property_list(events, 'campaign_event_resolved', ('event', 'choice'))}",
        f"- Final hull / fuel / pressure: {final_state.get('hull', '?')} / {final_state.get('fuel', '?')} / {final_state.get('campaign_pressure', '?')}",
        f"- Replay score: {answers.get('replay_score', '?')}/5",
        "",
        "## Observe without coaching",
        "",
        "| Moment | Record what happened, not an interpretation |",
        "|---|---|",
        "| First action | What did the tester try first, and how long did it take? |",
        "| Placement | Count invalid attempts. What dependency did they expect? |",
        "| Route choice | Ask what they predict will cost fuel/time and what might attack. |",
        "| Contact | Before Advance, ask which system will be targeted and why. |",
        "| Intervention | Record whether they noticed the one-order limit and expected consequence. |",
        "| Recovery | Ask why they chose repair, fuel, hull, or no service. |",
        "| Authored event | After leaving it, ask what was traded and what may matter later. |",
        "| Debrief | Ask what caused the outcome without opening the detailed chassis. |",
        "| Replay | Ask for one concrete change to layout, route, doctrine, or promise. |",
        "",
        "## Tester words",
        "",
        f"- Clear or satisfying: {answers.get('clear_or_satisfying', '') or '__________'}",
        f"- Confusing or frustrating: {answers.get('confusing_or_frustrating', '') or '__________'}",
        "- Most memorable place, person, or machine state: __________",
        "- Predicted outcome versus actual outcome: __________",
        "- One change for the next march: __________",
        "",
        "## Observer synthesis",
        "",
        "- First comprehension failure: __________",
        "- Highest-severity friction: __________",
        "- Evidence seen in at least one other session: __________",
        "- Recommended fix or follow-up experiment: __________",
        "- Do not infer emotion from completion; quote the tester where possible.",
        "",
        "## Capture checklist",
        "",
        "Capture only with tester consent. Use 1280×720 and record Standard/High Contrast plus 100%/110% text where specified.",
        "",
        "- [ ] Title choice (100% Standard)",
        "- [ ] First chassis commitment (100% Standard)",
        "- [ ] Route preview before Commit (110% Standard)",
        "- [ ] Contact target lock or consequence (100% High Contrast)",
        "- [ ] Recovery before service (110% Standard)",
        "- [ ] Recovery receipt after service (110% Standard)",
        "- [ ] Authored event before choice (100% Standard)",
        "- [ ] Later callback or terminal record (100% Standard)",
        "- [ ] Terminal Debrief (110% High Contrast)",
        "",
        "## Privacy boundary",
        "",
        "The source export and this sheet remain local. The game does not upload them. Remove names, machine identifiers, or unrelated personal information before voluntarily sharing either file.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("feedback", type=Path, help="Local feedback JSON exported by the game")
    parser.add_argument("--output", type=Path, help="Optional Markdown destination; stdout is used otherwise")
    args = parser.parse_args()
    try:
        payload = load_feedback(args.feedback)
        sheet = build_session_sheet(payload, args.feedback.name)
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 1
    if args.output:
        args.output.write_text(sheet, encoding="utf-8")
        print(f"playtest session sheet: {args.output}")
    else:
        print(sheet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
