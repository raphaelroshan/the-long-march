#!/usr/bin/env python3
"""Validate the LM-I4 module, specialist, and threat breadth contract."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


EXPANDED_MODULES = {"infirmary", "command_deck", "salvage_crane"}
EXPANDED_SPECIALISTS = {"sela_vonn", "nera_quill"}
EXPANDED_THREATS = {"signal_hunters", "bridgebreakers"}
EXPECTED_PROOFS = {"command_feint", "medical_watch", "demolition_recovery"}


def load(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"ERROR: cannot read {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit(f"ERROR: {path} must contain an object")
    return value


def keyed(items: Any, label: str, errors: list[str]) -> dict[str, dict[str, Any]]:
    if not isinstance(items, list):
        errors.append(f"{label} must be an array")
        return {}
    result: dict[str, dict[str, Any]] = {}
    for index, item in enumerate(items):
        if not isinstance(item, dict) or not isinstance(item.get("id"), str) or not item["id"]:
            errors.append(f"{label}[{index}] requires a non-empty id")
            continue
        if item["id"] in result:
            errors.append(f"duplicate {label} id: {item['id']}")
        result[item["id"]] = item
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    parser.add_argument("--framework", default="content/gameplay_framework.json")
    parser.add_argument("--candidate", default="content/early_access_candidate.json")
    args = parser.parse_args()

    data_path = Path(args.data)
    data = load(data_path)
    framework = load(Path(args.framework))
    candidate = load(Path(args.candidate))
    errors: list[str] = []

    families = keyed(data.get("module_families"), "module_families", errors)
    specialists = keyed(data.get("specialists"), "specialists", errors)
    threats = keyed(data.get("threat_families"), "threat_families", errors)
    proofs = keyed(data.get("complete_journey_proofs"), "complete_journey_proofs", errors)

    if data.get("slice") != "lm_ea_4" or set(families) != {"medical", "command"}:
        errors.append("LM-EA-4 must define the medical and command module families")
    family_modules = {str(item.get("module", "")) for item in families.values()}
    support = data.get("support_module", {})
    expansion_modules = family_modules | {str(support.get("id", ""))}
    if expansion_modules != EXPANDED_MODULES:
        errors.append("expanded module IDs must be infirmary, command_deck, and salvage_crane")
    for item in [*families.values(), support]:
        if not all(str(item.get(field, "")).strip() for field in ("dependency", "decision", "weakness", "repair_consequence")):
            errors.append(f"module contract {item.get('id', 'unknown')} must name dependency, decision, weakness, and repair consequence")

    required_facilities = {key: value.get("requires") for key, value in specialists.items()}
    if required_facilities != {"sela_vonn": "command_deck", "nera_quill": "infirmary"}:
        errors.append("expanded specialists must require their staffed facility")
    if any(not str(item.get("effect", "")).strip() for item in specialists.values()):
        errors.append("each expanded specialist must state a mechanical effect")

    if set(threats) != EXPANDED_THREATS:
        errors.append("both dependency-focused threat families are required")
    signal = threats.get("signal_hunters", {})
    if not {"signal", "command", "crew", "exterior"}.issubset(set(signal.get("targets", []))):
        errors.append("Signal Hunters must threaten both machine signals and their operating crew")
    if not {"command_deck", "repeater_gun", "infirmary", "nera_quill"}.issubset(set(signal.get("counters", []))):
        errors.append("Signal Hunters need offensive, command, and medical counterplay")
    bridge = threats.get("bridgebreakers", {})
    if not {"shell_cannon", "side_armor_skirt", "salvage_crane"}.issubset(set(bridge.get("counters", []))):
        errors.append("Bridgebreakers need weapon, armor, and recovery counterplay")

    if set(proofs) != EXPECTED_PROOFS:
        errors.append("LM-I4 must define command, medical, and demolition complete-journey proofs")
    covered_modules: set[str] = set()
    covered_specialists: set[str] = set()
    covered_threats: set[str] = set()
    sacrifices: set[str] = set()
    for proof in proofs.values():
        if proof.get("region") != "white_salt_expanse":
            errors.append(f"proof {proof.get('id')} must run through White Salt")
        covered_modules.update(str(item) for item in proof.get("modules", []))
        specialist = str(proof.get("specialist", ""))
        if specialist:
            covered_specialists.add(specialist)
        covered_threats.update(str(item) for item in proof.get("threats", []))
        sacrifice = str(proof.get("gives_up", "")).strip()
        if not sacrifice:
            errors.append(f"proof {proof.get('id')} must name what its build gives up")
        sacrifices.add(sacrifice)
    if not EXPANDED_MODULES.issubset(covered_modules):
        errors.append("complete journeys must cover all expanded modules")
    if covered_specialists != EXPANDED_SPECIALISTS:
        errors.append("complete journeys must cover both expanded specialists")
    if covered_threats != EXPANDED_THREATS | {"salt_storm"}:
        errors.append("complete journeys must cover the expanded threats in isolated and combined contacts")
    if len(sacrifices) != len(proofs):
        errors.append("each complete journey must carry a distinct sacrifice")

    base_modules = set(keyed(framework.get("modules"), "framework.modules", errors))
    candidate_scope = candidate.get("scope", {})
    if len(base_modules | expansion_modules) != int(candidate_scope.get("modules", -1)):
        errors.append("base plus expanded module IDs must equal the candidate module count")
    candidate_specialists = keyed(candidate.get("specialist_contracts"), "candidate.specialist_contracts", errors)
    if len(candidate_specialists) != int(candidate_scope.get("specialists", -1)) or not EXPANDED_SPECIALISTS.issubset(candidate_specialists):
        errors.append("candidate specialist contracts must include the expanded specialists and match scope")

    content_root = data_path.parent
    all_threats = keyed(framework.get("threats"), "framework.threats", errors)
    for filename in ("flooded_veyru.json", "cinder_spine.json", "white_salt_expanse.json"):
        region = load(content_root / filename)
        for threat_id, threat in keyed(region.get("regional_threats"), f"{filename}.regional_threats", errors).items():
            all_threats[threat_id] = threat
    expected_threat_count = int(candidate_scope.get("threat_families", -1))
    if len(all_threats) != expected_threat_count:
        errors.append(f"regional threat roster has {len(all_threats)} unique IDs; candidate claims {expected_threat_count}")
    for threat_id, threat in all_threats.items():
        if len(set(threat.get("counters", []))) < 2:
            errors.append(f"threat {threat_id} requires at least two authored counters")

    if errors:
        print(f"Early Access systems: BLOCK ({len(errors)} errors)")
        for error in errors:
            print("ERROR:", error)
        return 1
    print(f"Early Access systems: PASS ({len(base_modules | expansion_modules)} modules, {len(candidate_specialists)} specialists, {len(all_threats)} threats, {len(proofs)} complete journey proofs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
