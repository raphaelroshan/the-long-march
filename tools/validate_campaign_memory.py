#!/usr/bin/env python3
"""Validate LM-EA-5 events, replay goals, regional memory, and ending facets."""
import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    args = parser.parse_args()
    data = json.loads(Path(args.data).read_text(encoding="utf-8"))
    errors = []
    events = {item.get("id"): item for item in data.get("events", [])}
    memories = {item.get("id"): item for item in data.get("regional_memory", [])}
    goals = {item.get("id"): item for item in data.get("replay_goals", [])}
    facets = data.get("ending_facets", {})
    if data.get("slice") != "lm_ea_5" or set(events) != {"chapel_refuge", "trench_cistern"}:
        errors.append("LM-EA-5 must author both failure-road meetings")
    if set(memories) != {"cinder_refuge_chain", "salt_shared_cisterns"}:
        errors.append("both new regional memories are required")
    for memory in memories.values():
        if not memory.get("later_option") or not memory.get("later_event"):
            errors.append("regional memory must unlock a named later option in a named event")
    if set(goals) != {"cinder_redundant_lift", "salt_dependency_watch"} or any(item.get("solutions") != 2 or item.get("reward") != "none" for item in goals.values()):
        errors.append("each replay goal must expose two solutions and no power reward")
    if set(facets) != {"survival", "network", "promise"} or any(len(values) < 3 for values in facets.values()):
        errors.append("composable endings need survival, network, and promise axes")
    if errors:
        print(f"Campaign memory: BLOCK ({len(errors)} errors)")
        for error in errors:
            print("ERROR:", error)
        return 1
    combinations = len(facets["survival"]) * len(facets["network"]) * len(facets["promise"])
    print(f"Campaign memory: PASS (2 events, 2 memories, 2 replay goals, {combinations} ending combinations)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
