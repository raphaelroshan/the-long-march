#!/usr/bin/env python3
"""Validate the White Salt Expanse region and alternate-chassis contract."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


EXPECTED_NODES = {
    "saltglass_haven", "buried_observatory", "quiet_caravan", "windbreak",
    "salt_mine", "empty_mile", "beacon_road", "lee_trench",
    "rival_approach", "salt_citadel",
}
EXPECTED_DECISIONS = {"observatory_signal", "rival_terms", "trench_cistern"}
EXPECTED_RESULTS = {"expanse_allied", "expanse_crossed", "salt_lost"}
EXPECTED_DEVELOPMENTS = {"salt_public_beacons", "salt_shared_cisterns"}
EXPECTED_THREATS = {"salt_storm", "rival_scouts", "rival_fortress", "signal_hunters", "bridgebreakers"}


def load(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read White Salt data: {exc}") from exc
    if not isinstance(data, dict):
        raise SystemExit("ERROR: White Salt root must be an object")
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
    if not isinstance(region, dict) or region.get("id") != "white_salt_expanse":
        errors.append("region.id must be white_salt_expanse")
        region = {}
    if region.get("start_node") != "saltglass_haven" or region.get("final_node") != "salt_citadel" or region.get("encounter_count") != 5:
        errors.append("region must define the five-contact Saltglass-to-Citadel journey")

    nodes = data.get("nodes", [])
    node_ids = item_ids(nodes, "nodes", errors)
    if node_ids != EXPECTED_NODES:
        errors.append("nodes must match the ten authored White Salt locations")
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
        if node_id == "salt_citadel":
            paths.append(next_path)
            return
        for next_id in node_by_id.get(node_id, {}).get("next", []):
            walk(str(next_id), next_path)

    if "saltglass_haven" in node_by_id:
        walk("saltglass_haven", [])
    if len(paths) != 8 or any(len(path) != 6 for path in paths):
        errors.append("White Salt must expose eight acyclic routes with the start plus five encounters")
    if node_by_id.get("rival_approach", {}).get("decision") != "rival_terms":
        errors.append("Rival Approach must require the rival_terms commitment")
    if node_by_id.get("lee_trench", {}).get("decision") != "trench_cistern":
        errors.append("Lee Trench must require the trench_cistern recovery decision")

    pressure = region.get("pressure", {}) if isinstance(region, dict) else {}
    if pressure.get("guaranteed_recovery_node") != "lee_trench":
        errors.append("Lee Trench must be the guaranteed failure-forward route")
    if "empty_mile" not in pressure.get("whiteout_closes", []) or "lee_trench" not in pressure.get("whiteout_opens", []):
        errors.append("Whiteout must close Empty Mile and open Lee Trench")

    chassis = data.get("chassis", {})
    expected_chassis = {"id": "salt_skimmer", "grid": [6, 4], "cut_away_cells": [[0, 3], [5, 3]], "mass_limit": 13, "exterior_mounts": 3}
    if chassis != expected_chassis:
        errors.append("Salt Skimmer must retain a 6x4 frame, cut two corners, cap mass at 13, and allow three exterior mounts")
    comparison = data.get("chassis_comparison", {})
    if comparison.get("road_keep") != {"mass_limit": 14, "exterior_mounts": 2, "cut_away_cells": []} or comparison.get("salt_skimmer") != {"mass_limit": 13, "exterior_mounts": 3, "cut_away_cells": [[0, 3], [5, 3]]}:
        errors.append("chassis comparison must state the exact Road Keep versus Salt Skimmer geometry trade")

    loadouts = {item.get("id"): item for item in data.get("prepared_loadouts", []) if isinstance(item, dict)}
    if set(loadouts) != {"beacon_skimmer", "armored_skimmer"}:
        errors.append("White Salt must define the beacon and armored seeded loadouts")
    else:
        beacon_modules = set(loadouts["beacon_skimmer"].get("modules", []))
        armored_modules = set(loadouts["armored_skimmer"].get("modules", []))
        if loadouts["beacon_skimmer"].get("mass") != 13 or loadouts["beacon_skimmer"].get("route_priority") != "beacon_road" or "ammunition_lift" not in beacon_modules:
            errors.append("Beacon Skimmer must spend its mass on full ammunition and prefer Beacon Road")
        if loadouts["armored_skimmer"].get("mass") != 13 or loadouts["armored_skimmer"].get("route_priority") != "empty_mile" or "side_armor_skirt" not in armored_modules:
            errors.append("Armored Skimmer must spend its mass on lower-hull protection and prefer Empty Mile")
        if beacon_modules - armored_modules != {"ammunition_lift"} or armored_modules - beacon_modules != {"side_armor_skirt"}:
            errors.append("the seeded loadouts must isolate the ammunition-versus-armor decision")

    contract = data.get("contract", {})
    if contract.get("id") != "compact_beacon_escort" or contract.get("required_tag") != "forecast" or contract.get("failure_ends_run") is not False:
        errors.append("beacon escort must require forecast and remain non-terminal on failure")
    if contract.get("reward") != {"ashmarks": 26, "trust": 2}:
        errors.append("beacon escort reward must be 26 Ashmarks and 2 trust")

    if item_ids(data.get("decisions"), "decisions", errors) != EXPECTED_DECISIONS:
        errors.append("White Salt decisions do not match the runtime contract")
    if item_ids(data.get("results"), "results", errors) != EXPECTED_RESULTS:
        errors.append("White Salt results do not match the runtime contract")
    threat_ids = item_ids(data.get("regional_threats"), "regional_threats", errors)
    if threat_ids != EXPECTED_THREATS:
        errors.append("White Salt threat set is incomplete")
    for threat in data.get("regional_threats", []):
        if isinstance(threat, dict) and len(threat.get("counters", [])) < 2:
            errors.append(f"regional threat {threat.get('id')} needs at least two counters")

    if item_ids(data.get("regional_developments"), "regional_developments", errors) != EXPECTED_DEVELOPMENTS:
        errors.append("regional developments must contain Public Salt Beacons and Shared Cisterns")
    developments = {item["id"]: item for item in data.get("regional_developments", []) if isinstance(item, dict) and item.get("id")}
    public_beacons = developments.get("salt_public_beacons", {})
    if public_beacons.get("trigger") != {"decision": "broadcast_beacons", "results": ["expanse_allied", "expanse_crossed"]}:
        errors.append("Public Salt Beacons must require a surviving public-broadcast result")
    if public_beacons.get("future_effect") != {"node": "salt_mine", "visibility": "known", "risk_discount": 0}:
        errors.append("Public Salt Beacons must reveal Salt Mine without granting a risk discount")
    shared_cisterns = developments.get("salt_shared_cisterns", {})
    if shared_cisterns.get("trigger") != {"decision": "share_trench_water", "results": ["expanse_allied", "expanse_crossed"]}:
        errors.append("Shared Cisterns must require a surviving public-water result")
    if shared_cisterns.get("future_effect") != {"event": "observatory_signal", "choice": "call_cistern_network"}:
        errors.append("Shared Cisterns must unlock the observatory cistern-network choice")

    if errors:
        print(f"White Salt content: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"White Salt content: PASS ({len(node_ids)} nodes, {len(paths)} valid routes, {len(loadouts)} viable loadouts)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
