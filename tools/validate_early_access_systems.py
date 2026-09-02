#!/usr/bin/env python3
"""Validate the LM-EA-4 dependency-expansion content contract."""
import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    args = parser.parse_args()
    data = json.loads(Path(args.data).read_text(encoding="utf-8"))
    errors = []
    families = {item.get("id"): item for item in data.get("module_families", [])}
    specialists = {item.get("id"): item for item in data.get("specialists", [])}
    threats = {item.get("id"): item for item in data.get("threat_families", [])}
    if data.get("slice") != "lm_ea_4" or set(families) != {"medical", "command"}:
        errors.append("LM-EA-4 must define the medical and command module families")
    if families.get("medical", {}).get("module") != "infirmary" or families.get("command", {}).get("module") != "command_deck":
        errors.append("each new family must map to its runtime module")
    if {key: value.get("requires") for key, value in specialists.items()} != {"sela_vonn": "command_deck", "nera_quill": "infirmary"}:
        errors.append("specialists must require their staffed facility")
    if set(threats) != {"signal_hunters", "bridgebreakers"}:
        errors.append("both dependency-focused threat families are required")
    if not {"command_deck", "repeater_gun"}.issubset(set(threats.get("signal_hunters", {}).get("counters", []))):
        errors.append("Signal Hunters need command and weapon counterplay")
    if "salvage_crane" not in threats.get("bridgebreakers", {}).get("counters", []):
        errors.append("Bridgebreakers must give the recovery family a counter role")
    if data.get("support_module", {}).get("id") != "salvage_crane":
        errors.append("the support module must be the Salvage Crane")
    if errors:
        print(f"Early Access systems: BLOCK ({len(errors)} errors)")
        for error in errors:
            print("ERROR:", error)
        return 1
    print("Early Access systems: PASS (2 families, 2 specialists, 2 threats)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
