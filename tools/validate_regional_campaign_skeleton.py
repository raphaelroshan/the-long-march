#!/usr/bin/env python3
"""Validate the bounded four-region GPT56 campaign skeleton."""
import json
from pathlib import Path


def keyed(items):
    return {item.get("id"): item for item in items if isinstance(item, dict)}


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    data = json.loads((root / "content/regional_campaign_skeleton.json").read_text(encoding="utf-8"))
    candidate = json.loads((root / "content/early_access_candidate.json").read_text(encoding="utf-8"))
    manifest = json.loads((root / "content/content_manifest.json").read_text(encoding="utf-8"))
    region_files = {
        "flooded_veyru": "flooded_veyru.json",
        "cinder_spine": "cinder_spine.json",
        "white_salt_expanse": "white_salt_expanse.json",
    }
    errors: list[str] = []
    totals = data.get("totals", {})
    expected = {
        "encounters": 20,
        "chassis": 3,
        "modules": 20,
        "specialists": 6,
        "threat_pressure_families": 10,
        "threat_ids": 15,
        "routes": 16,
        "settlements": 8,
        "events": 21,
        "regional_developments": 5,
        "composable_endings": 60,
    }
    if totals != expected:
        errors.append(f"campaign totals must match the bounded Early Access skeleton: {totals}")
    scope = candidate.get("scope", {})
    for key in ("modules", "specialists", "regional_developments"):
        if totals.get(key) != scope.get(key):
            errors.append(f"campaign {key} must match candidate scope")
    if totals.get("threat_ids") != scope.get("threat_families"):
        errors.append("campaign threat IDs must match the existing candidate roster")
    pressure_families = keyed(data.get("threat_pressure_families", []))
    flattened = [threat for family in pressure_families.values() for threat in family.get("threats", [])]
    if len(pressure_families) != totals.get("threat_pressure_families") or len(flattened) != len(set(flattened)) or len(flattened) != totals.get("threat_ids"):
        errors.append("ten pressure families must partition all fifteen threat IDs exactly once")
    regions = keyed(data.get("regions", []))
    if set(regions) != {"ashgate_lowlands", "flooded_veyru", "cinder_spine", "white_salt_expanse"}:
        errors.append("campaign skeleton must contain the four playable regions")
    promises: set[str] = set()
    hazards: set[str] = set()
    settlement_ids = {item.get("id") for item in manifest.get("settlements", [])}
    ashgate_nodes = set(manifest.get("implemented_journey_slice", {}).get("nodes", [])) | {"cinder_quarry"}
    all_nodes: dict[str, dict] = {
        node.get("id"): node
        for node in manifest.get("routes", [])
        if isinstance(node, dict)
    }
    region_nodes: dict[str, dict[str, dict]] = {"ashgate_lowlands": all_nodes}
    for region_id, filename in region_files.items():
        region_data = json.loads((root / "content" / filename).read_text(encoding="utf-8"))
        region_nodes[region_id] = keyed(region_data.get("nodes", []))
        settlement_ids.update(region_nodes[region_id])
    for region_id, region in regions.items():
        for field in ("operational_promise", "settlement_tradeoff", "route_hazard", "threat_lesson", "recovery_implication", "failure_forward_development"):
            if not str(region.get(field, "")).strip():
                errors.append(f"{region_id} is missing {field}")
        promises.add(region.get("operational_promise"))
        hazards.add(region.get("route_hazard"))
        if len(region.get("settlements", [])) != 2 or not set(region.get("settlements", [])).issubset(settlement_ids):
            errors.append(f"{region_id} needs two known settlements")
        if len(region.get("route_families", [])) != 4 or len(set(region.get("route_families", []))) != 4:
            errors.append(f"{region_id} needs four distinct route families")
        if len(region.get("viable_loadouts", [])) < 2:
            errors.append(f"{region_id} needs two viable loadout proofs")
        nodes = region_nodes.get(region_id, {})
        for contact_key, threat_count in (("teaching_contact", 1), ("combined_contact", 2)):
            contact = region.get(contact_key, {})
            node_id = contact.get("node")
            if region_id == "ashgate_lowlands" and node_id not in ashgate_nodes:
                errors.append(f"Ashgate {contact_key} references an unknown node")
            elif region_id != "ashgate_lowlands" and node_id not in nodes:
                errors.append(f"{region_id} {contact_key} references an unknown node")
            authored_threats = contact.get("threats", [])
            if len(authored_threats) != threat_count or any(threat not in flattened for threat in authored_threats):
                errors.append(f"{region_id} {contact_key} needs {threat_count} known threat IDs")
            if region_id != "ashgate_lowlands" and set(nodes.get(node_id, {}).get("encounter", [])) != set(authored_threats):
                errors.append(f"{region_id} {contact_key} must match its authored node encounter")
    if len(promises) != 4 or len(hazards) != 4:
        errors.append("every region needs a unique operational promise and route hazard")
    if sum(len(region.get("settlements", [])) for region in regions.values()) != totals.get("settlements"):
        errors.append("regional settlement total is inconsistent")
    if sum(len(region.get("route_families", [])) for region in regions.values()) != totals.get("routes"):
        errors.append("regional route-family total is inconsistent")
    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1
    print("Regional campaign skeleton: PASS (4 regions, 20 contacts, 16 route families, 10 pressure families, 8 viable plans)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
