#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


def require(text: str, needle: str, label: str, errors: list[str]) -> None:
    if needle not in text:
        errors.append(f"missing {label}: {needle}")


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    errors: list[str] = []
    manifest = json.loads((root / "tools/ci_manifest.json").read_text(encoding="utf-8"))
    candidate = json.loads((root / "content/early_access_candidate.json").read_text(encoding="utf-8"))
    expected_packets = [f"LM-GPT56-{index}" for index in range(0, 6)]
    campaign = manifest.get("campaign_contract", {})
    if campaign.get("regions") != 4:
        errors.append("candidate campaign contract must declare four regions")
    if campaign.get("session_minutes") != {"minimum": 30, "maximum": 90}:
        errors.append("candidate campaign contract must declare a 30–90 minute target")
    if campaign.get("timing_evidence") != "authored_target_not_human_observation":
        errors.append("candidate must not present authored pacing as human evidence")
    if campaign.get("completed_packets") != expected_packets:
        errors.append("candidate campaign contract must list all six completed GPT56 packets")
    if candidate.get("session_contract", {}).get("target_minutes") != campaign.get("session_minutes"):
        errors.append("content and package duration contracts must match")
    if manifest.get("release_candidate_platforms") != ["windows", "macos", "linux"]:
        errors.append("candidate platforms must remain Windows, macOS, and Linux")
    if manifest.get("release_ready") is not False:
        errors.append("GPT56 completion must not imply owner approval or public readiness")

    reports = [root / f"docs/lm_gpt56_{index}_{name}.md" for index, name in (
        (0, "rendered_frame_gate_report"),
        (1, "full_journey_report"),
        (2, "fortress_identity_report"),
        (3, "regional_campaign_report"),
        (4, "people_promises_report"),
        (5, "early_access_package_report"),
    )]
    for report in reports:
        if not report.exists() or len(report.read_text(encoding="utf-8").strip()) < 500:
            errors.append(f"missing substantive GPT56 report: {report.name}")

    verify = (root / "scripts/verify.sh").read_text(encoding="utf-8")
    for marker in (
        "validate_fortress_presentation.py",
        "validate_regional_campaign_skeleton.py",
        "validate_people_promises.py",
        "test_fortress_presentation_registry.gd",
        "test_regional_campaign_skeleton.gd",
        "test_people_promises.gd",
        "test_rendered_frame_capture.gd",
        "LONG_MARCH_GPT56_1_PROFILE=1",
        "test_gpt56_package_contract.py",
        "test_early_access_hardening.gd",
        "test_controller_layout.gd",
        "LONG_MARCH_RESPONSIVE_PROFILE=1",
        "test_performance_budget.gd",
        "verify_offline_boundary.py",
        "test_release_manifest.py",
    ):
        require(verify, marker, "GPT56 verification gate", errors)

    workflows = "\n".join((root / path).read_text(encoding="utf-8") for path in (".github/workflows/ci.yml", ".github/workflows/release.yml"))
    for marker in (
        "name: Package release candidate",
        "name: Package Linux release candidate",
        "name: Verify downloaded release candidate",
        "name: Verify downloaded Linux candidate",
        "name: macOS",
        "campaign_contract=content/early_access_candidate.json",
        "gpt56_execution=docs/lm_gpt56_5_early_access_package_report.md",
        "tools/verify_release_manifest.py",
    ):
        require(workflows, marker, "package workflow contract", errors)
    if workflows.count("campaign_contract=content/early_access_candidate.json") != 3:
        errors.append("all three manifest-producing package paths must checksum the campaign contract")
    if workflows.count("gpt56_execution=docs/lm_gpt56_5_early_access_package_report.md") != 3:
        errors.append("all three manifest-producing package paths must checksum the GPT56 execution report")

    docs = "\n".join((root / path).read_text(encoding="utf-8").lower() for path in (
        "docs/early_access_candidate.md",
        "docs/early_access_known_limitations.md",
        "docs/early_access_test_matrix.md",
        "docs/internal_test_release.md",
    ))
    for phrase in ("30–90 minute", "offline", "save", "controller", "reduced motion", "rollback", "known limitations", "human"):
        require(docs, phrase, "truthful candidate boundary", errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March LM-GPT56-5 Early Access package contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
