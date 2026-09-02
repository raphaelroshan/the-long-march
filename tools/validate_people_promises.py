#!/usr/bin/env python3
"""Validate the compact specialist, promise, and obligation campaign layer."""
import json
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    data = json.loads((root / "content/people_promises.json").read_text(encoding="utf-8"))
    candidate = json.loads((root / "content/early_access_candidate.json").read_text(encoding="utf-8"))
    memory = json.loads((root / "content/campaign_memory.json").read_text(encoding="utf-8"))
    errors: list[str] = []
    specialists = {item.get("id"): item for item in data.get("specialists", [])}
    expected_specialists = {item.get("id") for item in candidate.get("specialist_contracts", [])}
    if set(specialists) != expected_specialists or len(specialists) != 6:
        errors.append("people layer must cover all six candidate specialists exactly once")
    for specialist_id, specialist in specialists.items():
        for field in ("capability", "limitation", "conflict_or_promise", "visible_consequence"):
            if not str(specialist.get(field, "")).strip():
                errors.append(f"{specialist_id} is missing {field}")
    obligations = {item.get("status"): item for item in data.get("obligations", [])}
    memory_states = {item.get("status"): item for item in memory.get("obligation_memory", {}).get("states", [])}
    if set(obligations) != {"completed", "declined", "failed"}:
        errors.append("people layer needs completed, declined, and failed obligation outcomes")
    for status, obligation in obligations.items():
        source = memory_states.get(status, {})
        if obligation.get("memory") != source.get("id") or obligation.get("ending_network") != source.get("ending_network") or not obligation.get("later_change"):
            errors.append(f"{status} obligation must match campaign memory and name its later change")
    if set(data.get("active_event_checkpoints", [])) != {"mara_berth_choice", "mara_workbench_choice", "mara_followup"}:
        errors.append("Mara's complete active-event chain must remain checkpointed")
    if {item.get("id") for item in data.get("replay_comparisons", [])} != {"iven_or_mara", "guard_outcome"}:
        errors.append("people layer needs specialist and obligation replay comparisons")
    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1
    print("People and promises: PASS (6 specialists, 3 obligation outcomes, 3 active-event checkpoints, 2 replay comparisons)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
