#!/usr/bin/env python3
"""Validate The Long March's implementation-ready gameplay framework."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def load(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read framework JSON: {exc}") from exc
    if not isinstance(data, dict):
        raise SystemExit("ERROR: framework root must be an object")
    return data


def collect_ids(items: Any, label: str, errors: list[str]) -> set[str]:
    if not isinstance(items, list):
        errors.append(f"{label} must be an array")
        return set()
    result: set[str] = set()
    for index, item in enumerate(items):
        if not isinstance(item, dict) or not isinstance(item.get("id"), str) or not item["id"]:
            errors.append(f"{label}[{index}] requires a non-empty id")
            continue
        if item["id"] in result:
            errors.append(f"duplicate id in {label}: {item['id']}")
        result.add(item["id"])
    return result


def require_fields(item: dict[str, Any], fields: tuple[str, ...], label: str, errors: list[str]) -> None:
    for field in fields:
        if field not in item or item[field] in (None, "", []):
            errors.append(f"{label} missing {field}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    args = parser.parse_args()
    data = load(Path(args.data))
    errors: list[str] = []
    if data.get("game_id") != "the-long-march":
        errors.append("game_id must be the-long-march")

    space_ids = collect_ids(data.get("spaces"), "spaces", errors)
    family_ids = collect_ids(data.get("module_families"), "module_families", errors)
    module_ids = collect_ids(data.get("modules"), "modules", errors)
    connection_ids = collect_ids(data.get("connection_rules"), "connection_rules", errors)
    intervention_ids = collect_ids(data.get("interventions"), "interventions", errors)
    threat_ids = collect_ids(data.get("threats"), "threats", errors)
    progression_ids = collect_ids(data.get("progression_tracks"), "progression_tracks", errors)
    progression_node_ids: set[str] = set()
    for track in data.get("progression_tracks", []):
        if isinstance(track, dict):
            progression_node_ids.update(str(node_id) for node_id in track.get("nodes", []))

    if space_ids != {"chassis_grid", "exterior_mounts", "crew_stations"}:
        errors.append("spaces must include chassis_grid, exterior_mounts, and crew_stations")
    required_families = {"engine", "weapon", "workshop", "crew_room", "armor", "cargo", "signal"}
    if not required_families.issubset(family_ids):
        errors.append("module families are incomplete")
    if len(module_ids) < 16:
        errors.append("vertical slice requires at least 16 modules")
    if len(intervention_ids) != 4:
        errors.append("vertical slice requires exactly four interventions")
    if len(threat_ids) != 5:
        errors.append("vertical slice requires exactly five threat definitions")
    if len(progression_ids) < 3:
        errors.append("at least three progression tracks are required")

    for index, module in enumerate(data.get("modules", [])):
        if not isinstance(module, dict):
            errors.append(f"modules[{index}] must be an object")
            continue
        require_fields(module, ("id", "family", "shape", "mass", "power_draw", "heat", "durability", "tags", "connections"), f"module {module.get('id')}", errors)
        if module.get("family") not in family_ids:
            errors.append(f"module {module.get('id')} references unknown family {module.get('family')}")
        shape = module.get("shape")
        if not isinstance(shape, list) or len(shape) != 2 or any(not isinstance(value, int) or value < 1 for value in shape):
            errors.append(f"module {module.get('id')} must have a positive two-dimensional shape")
        if int(module.get("mass", 0)) < 0 or int(module.get("durability", 0)) <= 0:
            errors.append(f"module {module.get('id')} must have non-negative mass and positive durability")

    for index, threat in enumerate(data.get("threats", [])):
        if not isinstance(threat, dict):
            continue
        require_fields(threat, ("id", "name", "doctrine", "targets", "counters"), f"threat {threat.get('id')}", errors)
        if len(threat.get("counters", [])) < 2:
            errors.append(f"threat {threat.get('id')} needs at least two counter-options")
        for counter in threat.get("counters", []):
            if counter not in module_ids and counter not in intervention_ids and counter not in progression_node_ids and counter != "controlled_sacrifice":
                errors.append(f"threat {threat.get('id')} references unknown counter {counter}")

    for index, intervention in enumerate(data.get("interventions", [])):
        if not isinstance(intervention, dict):
            continue
        require_fields(intervention, ("id", "name", "timing", "cost", "benefit", "risk"), f"intervention {intervention.get('id')}", errors)

    for index, track in enumerate(data.get("progression_tracks", [])):
        if not isinstance(track, dict):
            continue
        require_fields(track, ("id", "nodes", "principle"), f"progression track {track.get('id')}", errors)
        if len(track.get("nodes", [])) < 3:
            errors.append(f"progression track {track.get('id')} needs at least three nodes")

    slice_data = data.get("vertical_slice", {})
    expected = {"chassis_dimensions": [6, 4], "exterior_mounts": 2, "module_count": 16, "enemy_count": 5, "intervention_count": 4, "settlement_count": 2, "route_count": 3, "encounter_count": 5}
    for key, value in expected.items():
        if slice_data.get(key) != value:
            errors.append(f"vertical_slice.{key} must be {value}")
    guardrails = data.get("guardrails", [])
    if len(guardrails) < 6:
        errors.append("at least six gameplay guardrails are required")

    if errors:
        print(f"The Long March gameplay framework: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"The Long March gameplay framework: PASS ({len(module_ids)} modules, {len(threat_ids)} threats, {len(intervention_ids)} interventions, {len(progression_ids)} progression tracks)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
