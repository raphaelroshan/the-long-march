#!/usr/bin/env python3
"""Validate the isolated Flooded Veyru chapter contract."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


EXPECTED_NODES = {
    "lantern_quay",
    "pump_gallery",
    "sunken_tramworks",
    "veyru_evacuation_camp",
    "archive_causeway",
    "drowned_registry",
    "pilgrim_gantry",
    "dry_archive_gate",
    "dry_archive",
}
EXPECTED_DECISIONS = {"drain_pumps", "registry_salvage", "archive_broadcast"}
EXPECTED_RESULTS = {"archive_kept", "archive_scarred", "veyru_lost"}
EXPECTED_DEVELOPMENTS = {"veyru_public_archive_signal"}


def load(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read Flooded Veyru data: {exc}") from exc
    if not isinstance(data, dict):
        raise SystemExit("ERROR: Flooded Veyru root must be an object")
    return data


def item_ids(items: Any, label: str, errors: list[str]) -> set[str]:
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


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    args = parser.parse_args()
    data = load(Path(args.data))
    errors: list[str] = []

    region = data.get("region", {})
    if not isinstance(region, dict) or region.get("id") != "flooded_veyru":
        errors.append("region.id must be flooded_veyru")
        region = {}
    if region.get("start_node") != "lantern_quay" or region.get("final_node") != "dry_archive":
        errors.append("region must run from lantern_quay to dry_archive")
    if region.get("encounter_count") != 5:
        errors.append("region.encounter_count must be 5")

    nodes = data.get("nodes", [])
    node_ids = item_ids(nodes, "nodes", errors)
    if node_ids != EXPECTED_NODES:
        errors.append("nodes must match the nine authored Veyru locations")
    node_by_id = {item["id"]: item for item in nodes if isinstance(item, dict) and item.get("id")}
    for node_id, node in node_by_id.items():
        for next_id in node.get("next", []):
            if next_id not in node_ids:
                errors.append(f"node {node_id} references unknown next node {next_id}")
    paths: list[list[str]] = []

    def walk(node_id: str, path: list[str]) -> None:
        if node_id in path:
            errors.append(f"route graph contains a cycle at {node_id}")
            return
        next_path = [*path, node_id]
        if node_id == "dry_archive":
            paths.append(next_path)
            return
        for next_id in node_by_id.get(node_id, {}).get("next", []):
            walk(str(next_id), next_path)

    if "lantern_quay" in node_by_id:
        walk("lantern_quay", [])
    if not paths or any(len(path) != 6 for path in paths):
        errors.append("every authored route must contain the start plus exactly five encounter nodes")
    if node_by_id.get("drowned_registry", {}).get("encounter") != ["flood_surge", "climbers"]:
        errors.append("Drowned Registry must contain the Flood Surge and Climbers combination")
    if node_by_id.get("dry_archive_gate", {}).get("decision") != "archive_broadcast":
        errors.append("Dry Archive Gate must require the archive_broadcast commitment")

    pressure = region.get("pressure", {}) if isinstance(region, dict) else {}
    if pressure.get("guaranteed_recovery_node") != "pilgrim_gantry":
        errors.append("Pilgrim Gantry must be the guaranteed recovery node")
    if "drowned_registry" not in pressure.get("breach_closes", []) or "pilgrim_gantry" not in pressure.get("breach_opens", []):
        errors.append("Breach must close Drowned Registry and open Pilgrim Gantry")

    contract = data.get("contract", {})
    if contract.get("id") != "veyru_medicine_delivery" or contract.get("failure_ends_run") is not False:
        errors.append("medicine delivery must be non-terminal on failure")
    if contract.get("carrier_priority") != ["refugee_bunk", "parts_crate"]:
        errors.append("medicine carrier priority must be Refugee Bunk then Parts Crate")
    if contract.get("reward") != {"ashmarks": 28, "trust": 2}:
        errors.append("medicine delivery reward must be 28 Ashmarks and 2 trust")

    if item_ids(data.get("decisions"), "decisions", errors) != EXPECTED_DECISIONS:
        errors.append("Veyru decisions do not match the runtime contract")
    if item_ids(data.get("results"), "results", errors) != EXPECTED_RESULTS:
        errors.append("Veyru results do not match the runtime contract")
    threat_ids = item_ids(data.get("regional_threats"), "regional_threats", errors)
    if threat_ids != {"flood_surge", "civic_guardian"}:
        errors.append("regional threats must contain Flood Surge and Civic Guardian")
    for threat in data.get("regional_threats", []):
        if isinstance(threat, dict) and len(threat.get("counters", [])) < 2:
            errors.append(f"regional threat {threat.get('id')} needs at least two counters")

    development_ids = item_ids(data.get("regional_developments"), "regional_developments", errors)
    if development_ids != EXPECTED_DEVELOPMENTS:
        errors.append("regional developments must contain the public archive signal")
    developments = {item["id"]: item for item in data.get("regional_developments", []) if isinstance(item, dict) and item.get("id")}
    public_signal = developments.get("veyru_public_archive_signal", {})
    if public_signal.get("trigger") != {"decision": "broadcast_archive", "results": ["archive_kept", "archive_scarred"]}:
        errors.append("Public Archive Signal must require a surviving public broadcast result")
    if public_signal.get("future_effect") != {"node": "drowned_registry", "visibility": "known", "risk_discount": 0}:
        errors.append("Public Archive Signal must reveal Drowned Registry without granting a risk discount")

    loadout = data.get("prepared_loadout", {})
    module_ids = [entry.get("id") for entry in loadout.get("modules", []) if isinstance(entry, dict)]
    for required in ["steam_lance_engine", "coal_cell", "generator_core", "field_workshop", "water_condenser", "parts_crate"]:
        if required not in module_ids:
            errors.append(f"prepared loadout is missing {required}")
    if loadout.get("mass_limit") != 14 or loadout.get("heat_limit") != 6:
        errors.append("prepared loadout must declare the alpha mass and heat limits")

    if errors:
        print(f"Flooded Veyru content: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"Flooded Veyru content: PASS ({len(node_ids)} nodes, {len(paths)} valid routes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
