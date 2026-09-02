#!/usr/bin/env python3
"""Validate the White Salt Expanse region and alternate chassis contract."""
import argparse
import json
from pathlib import Path

EXPECTED = {"saltglass_haven", "buried_observatory", "quiet_caravan", "windbreak", "salt_mine", "empty_mile", "beacon_road", "lee_trench", "rival_approach", "salt_citadel"}

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    args = parser.parse_args()
    data = json.loads(Path(args.data).read_text(encoding="utf-8"))
    errors = []
    region = data.get("region", {})
    if region.get("id") != "white_salt_expanse" or region.get("start_node") != "saltglass_haven" or region.get("final_node") != "salt_citadel" or region.get("encounter_count") != 5:
        errors.append("region contract must define the five-contact Saltglass-to-Citadel journey")
    nodes = {node.get("id"): node for node in data.get("nodes", [])}
    if set(nodes) != EXPECTED:
        errors.append("node set does not match the authored White Salt graph")
    pressure = region.get("pressure", {})
    if pressure.get("whiteout_closes") != ["empty_mile"] or pressure.get("whiteout_opens") != ["lee_trench"] or pressure.get("guaranteed_recovery_node") != "lee_trench":
        errors.append("whiteout must close Empty Mile and guarantee Lee Trench")
    chassis = data.get("chassis", {})
    if chassis != {"id": "salt_skimmer", "grid": [6, 4], "cut_away_cells": [[0, 3], [5, 3]], "mass_limit": 13, "exterior_mounts": 3}:
        errors.append("Salt Skimmer must retain a 6x4 frame, cut two corners, cap mass at 13, and allow three exterior mounts")
    threat_ids = {item.get("id") for item in data.get("regional_threats", [])}
    if threat_ids != {"salt_storm", "rival_scouts", "rival_fortress"}:
        errors.append("White Salt threat set is incomplete")
    if {item.get("id") for item in data.get("results", [])} != {"expanse_allied", "expanse_crossed", "salt_lost"}:
        errors.append("White Salt result set is incomplete")
    if errors:
        print(f"White Salt content: BLOCK ({len(errors)} errors)")
        for error in errors:
            print("ERROR:", error)
        return 1
    print(f"White Salt content: PASS ({len(nodes)} nodes, alternate chassis validated)")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
