#!/usr/bin/env python3
"""Validate the isolated Cinder Spine chapter contract."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


EXPECTED_NODES = {
    "blackkiln", "charcoal_monastery", "red_cut", "old_lift_station",
    "long_slope", "slag_tunnel", "ash_chapel_bypass", "lift_engine_house",
    "switchback_commune",
}
EXPECTED_DECISIONS = {"charcoal_vow", "lift_engine_choice", "commune_design"}
EXPECTED_RESULTS = {"spine_powered", "spine_bypassed", "cinder_lost"}


def load(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read Cinder Spine data: {exc}") from exc
    if not isinstance(data, dict):
        raise SystemExit("ERROR: Cinder Spine root must be an object")
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
    if not isinstance(region, dict) or region.get("id") != "cinder_spine":
        errors.append("region.id must be cinder_spine")
        region = {}
    if region.get("start_node") != "blackkiln" or region.get("final_node") != "switchback_commune":
        errors.append("region must run from blackkiln to switchback_commune")
    if region.get("encounter_count") != 5:
        errors.append("region.encounter_count must be 5")
    if data.get("chassis") != {"id": "ridge_crawler", "grid": [6, 4], "cut_away_cells": [[0, 3], [1, 3]], "mass_limit": 15, "exterior_mounts": 2}:
        errors.append("Cinder must declare the heavy Ridge Crawler and its paired rear cut-away")

    nodes = data.get("nodes", [])
    node_ids = item_ids(nodes, "nodes", errors)
    if node_ids != EXPECTED_NODES:
        errors.append("nodes must match the nine authored Cinder locations")
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
        if node_id == "switchback_commune":
            paths.append(next_path)
            return
        for next_id in node_by_id.get(node_id, {}).get("next", []):
            walk(str(next_id), next_path)

    if "blackkiln" in node_by_id:
        walk("blackkiln", [])
    if not paths or any(len(path) != 6 for path in paths):
        errors.append("every authored route must contain the start plus exactly five encounter nodes")
    if not node_by_id.get("red_cut", {}).get("mass_sensitive") or not node_by_id.get("long_slope", {}).get("mass_sensitive"):
        errors.append("Red Cut and Long Slope must make chassis mass mechanically legible")
    if node_by_id.get("lift_engine_house", {}).get("decision") != "lift_engine_choice":
        errors.append("Lift Engine House must require the lift_engine_choice commitment")

    pressure = region.get("pressure", {}) if isinstance(region, dict) else {}
    if pressure.get("guaranteed_recovery_node") != "ash_chapel_bypass":
        errors.append("Ash Chapel Bypass must be the guaranteed failure-forward route")
    if "slag_tunnel" not in pressure.get("inferno_closes", []) or "ash_chapel_bypass" not in pressure.get("inferno_opens", []):
        errors.append("Inferno must close Slag Tunnel and open Ash Chapel Bypass")

    contract = data.get("contract", {})
    if contract.get("id") != "cinder_guild_dynamo" or contract.get("failure_ends_run") is not False:
        errors.append("dynamo delivery must be non-terminal on failure")
    if contract.get("required_module") != "generator_core" or contract.get("route_heat") != 1:
        errors.append("dynamo delivery must require the Generator Core and add one heat per road")
    if contract.get("reward") != {"ashmarks": 30, "trust": 2}:
        errors.append("dynamo delivery reward must be 30 Ashmarks and 2 trust")

    if item_ids(data.get("decisions"), "decisions", errors) != EXPECTED_DECISIONS:
        errors.append("Cinder decisions do not match the runtime contract")
    if item_ids(data.get("results"), "results", errors) != EXPECTED_RESULTS:
        errors.append("Cinder results do not match the runtime contract")
    threat_ids = item_ids(data.get("regional_threats"), "regional_threats", errors)
    if threat_ids != {"ember_drakes", "lift_saboteurs", "elevator_warden"}:
        errors.append("regional threats must contain Ember Drakes, Lift Saboteurs, and Elevator Warden")
    for threat in data.get("regional_threats", []):
        if isinstance(threat, dict) and len(threat.get("counters", [])) < 2:
            errors.append(f"regional threat {threat.get('id')} needs at least two counters")

    development_ids = item_ids(data.get("regional_developments"), "regional_developments", errors)
    if development_ids != {"cinder_communal_lift_plan"}:
        errors.append("regional developments must contain the Communal Lift Plan")
    developments = {item["id"]: item for item in data.get("regional_developments", []) if isinstance(item, dict) and item.get("id")}
    communal_plan = developments.get("cinder_communal_lift_plan", {})
    if communal_plan.get("trigger") != {"decision": "share_lift_plan", "results": ["spine_powered", "spine_bypassed"]}:
        errors.append("Communal Lift Plan must require a surviving shared-design result")
    if communal_plan.get("future_effect") != {"node": "slag_tunnel", "visibility": "known", "risk_discount": 0}:
        errors.append("Communal Lift Plan must reveal Slag Tunnel without granting a risk discount")

    if errors:
        print(f"Cinder Spine content: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"Cinder Spine content: PASS ({len(node_ids)} nodes, {len(paths)} valid routes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
