#!/usr/bin/env python3
"""Validate the bounded, non-public LM-EA-6 candidate contract."""
import json
import re
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    data = json.loads((root / "content/early_access_candidate.json").read_text(encoding="utf-8"))
    manifest = json.loads((root / "tools/ci_manifest.json").read_text(encoding="utf-8"))
    state_source = (root / "src/core/fortress_state.gd").read_text(encoding="utf-8")
    errors = []
    scope = data.get("scope", {})
    floors = {
        "regions": 4,
        "chassis_templates": 3,
        "modules": 18,
        "specialists": 6,
        "threat_families": 10,
        "authored_decisions_and_meetings": 20,
        "regional_developments": 4,
        "composable_ending_combinations": 6,
    }
    for key, minimum in floors.items():
        if int(scope.get(key, 0)) < minimum:
            errors.append(f"{key} must meet the Early Access floor of {minimum}")
    if {item.get("id") for item in data.get("chassis_contracts", [])} != {"road_keep", "salt_skimmer", "ridge_crawler"}:
        errors.append("all three chassis need stable candidate contracts")
    if len({item.get("id") for item in data.get("specialist_contracts", [])}) != 6:
        errors.append("all six specialists need stable candidate contracts")
    compatibility = data.get("compatibility", {})
    if data.get("version") != manifest.get("prototype_version"):
        errors.append("candidate content version must match the package manifest")
    if data.get("status") != "candidate_not_public_release" or manifest.get("release_ready") is not False:
        errors.append("candidate must not claim owner approval or public-release readiness")
    if compatibility.get("candidate_platforms") != ["windows", "macos", "linux"] or compatibility.get("offline_runtime") is not True:
        errors.append("candidate platform and offline boundaries must remain explicit")
    current_match = re.search(r"^const SAVE_VERSION := (\d+)$", state_source, re.MULTILINE)
    minimum_match = re.search(r"^const MIN_SUPPORTED_SAVE_VERSION := (\d+)$", state_source, re.MULTILINE)
    authoritative_window = {
        "minimum": int(minimum_match.group(1)) if minimum_match else -1,
        "current": int(current_match.group(1)) if current_match else -1,
    }
    if compatibility.get("save_versions") != authoritative_window:
        errors.append("save compatibility window must match the authoritative state")
    if manifest.get("save_compatibility") != authoritative_window:
        errors.append("package manifest save compatibility must match the authoritative state")
    required_docs = [
        root / "docs/early_access_candidate.md",
        root / "docs/early_access_known_limitations.md",
        root / "docs/early_access_test_matrix.md",
    ]
    for path in required_docs:
        if not path.exists() or len(path.read_text(encoding="utf-8").strip()) < 200:
            errors.append(f"missing substantive release document: {path.name}")
    verify = (root / "scripts/verify.sh").read_text(encoding="utf-8")
    for gate in ("test_early_access_hardening.gd", "test_interface_audio.gd", "test_performance_budget.gd", "test_release_manifest.py"):
        if gate not in verify:
            errors.append(f"verification does not run {gate}")
    if errors:
        print(f"Early Access candidate: BLOCK ({len(errors)} errors)")
        for error in errors:
            print("ERROR:", error)
        return 1
    print("Early Access candidate: PASS (scope floors and release boundaries declared)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
