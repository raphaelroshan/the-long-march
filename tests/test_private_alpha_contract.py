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
    if manifest.get("playtest_ready") is not True:
        errors.append("candidate manifest must remain playtest_ready")
    if manifest.get("release_ready") is not False:
        errors.append("private alpha must not claim public release readiness")
    if manifest.get("release_candidate_platforms") != ["windows", "macos", "linux"]:
        errors.append("candidate platforms must stay explicitly bounded to Windows, macOS, and Linux")
    if manifest.get("save_compatibility") != {"minimum": 4, "current": 16}:
        errors.append("candidate manifest must declare the tested save compatibility window")

    verify = (root / "scripts/verify.sh").read_text(encoding="utf-8")
    for marker in (
        "verify_offline_boundary.py",
        "test_performance_budget.gd",
        "test_interface_audio.gd",
        "test_controller_layout.gd",
        "LONG_MARCH_RESPONSIVE_PROFILE=1",
        "test_complete_journey_handoff.gd",
        "test_prepare_playtest_session.py",
        "test_finalize_playtest_session.py",
        "test_playtest_packet_cohort.py",
        "test_smoke_playtest_evidence.py",
        "test_release_publication_contract.py",
        "test_release_notes.py",
        "test_readme_contract.py",
        "test_report_output.py",
    ):
        require(verify, marker, "verification gate", errors)

    workflows = "\n".join(
        (root / path).read_text(encoding="utf-8")
        for path in (".github/workflows/ci.yml", ".github/workflows/release.yml")
    )
    require(workflows, "version: 4.4.1", "pinned Godot toolchain", errors)
    require(workflows, "tools/smoke_playtest.py", "packaged smoke", errors)
    require(workflows, "--engine-version", "engine provenance", errors)
    require(workflows, "tools/verify_release_manifest.py", "manifest verification", errors)
    require(workflows, "session_summarizer=tools/summarize_playtest_feedback.py", "session summarizer in exact cohort", errors)
    require(workflows, "session_preparer=tools/prepare_playtest_session.py", "session preflight in exact cohort", errors)
    require(workflows, "session_finalizer=tools/finalize_playtest_session.py", "session finalizer in exact cohort", errors)
    require(workflows, "report_output=tools/report_output.py", "safe report writer in exact cohort", errors)
    require(workflows, "cohort_summarizer=tools/summarize_playtest_cohort.py", "cohort summarizer in exact cohort", errors)
    require(workflows, "packet_cohort_summarizer=tools/summarize_playtest_packets.py", "packet cohort summarizer in exact cohort", errors)
    require(workflows, "evidence_workflow_smoke=tools/smoke_playtest_evidence.py", "evidence workflow smoke in exact cohort", errors)
    require(workflows, "early_access_candidate=docs/early_access_candidate.md", "candidate scope in exact cohort", errors)
    require(workflows, "early_access_known_limitations=docs/early_access_known_limitations.md", "known limitations in exact cohort", errors)
    require(workflows, "early_access_test_matrix=docs/early_access_test_matrix.md", "candidate test matrix in exact cohort", errors)
    require(workflows, "name: Verify downloaded release candidate", "downloaded PR cohort gate", errors)
    require(workflows, "needs: package", "downloaded PR cohort dependency", errors)
    require(workflows, "tools/smoke_playtest_evidence.py staging/candidate/", "downloaded PR cohort evidence smoke", errors)
    require(workflows, "name: Package Linux release candidate", "native Linux package gate", errors)
    require(workflows, "name: Verify downloaded Linux candidate", "downloaded Linux cohort gate", errors)
    require(workflows, "tools/smoke_playtest_evidence.py staging/linux-candidate/", "downloaded Linux cohort evidence smoke", errors)
    if workflows.count("session_preparer=tools/prepare_playtest_session.py") != 3:
        errors.append("Windows CI, Linux CI, and tagged release manifests must checksum the session preflight")
    if workflows.count("tools/prepare_playtest_session.py") < 6:
        errors.append("Windows CI, Linux CI, and tagged release artifacts must upload the session preflight")
    if workflows.count("session_finalizer=tools/finalize_playtest_session.py") != 3:
        errors.append("Windows CI, Linux CI, and tagged release manifests must checksum the session finalizer")
    if workflows.count("tools/finalize_playtest_session.py") < 6:
        errors.append("Windows CI, Linux CI, and tagged release artifacts must upload the session finalizer")
    if workflows.count("packet_cohort_summarizer=tools/summarize_playtest_packets.py") != 3:
        errors.append("Windows CI, Linux CI, and tagged release manifests must checksum the packet cohort summarizer")
    if workflows.count("tools/summarize_playtest_packets.py") < 6:
        errors.append("Windows CI, Linux CI, and tagged release artifacts must upload the packet cohort summarizer")
    if workflows.count("report_output=tools/report_output.py") != 3:
        errors.append("Windows CI, Linux CI, and tagged release manifests must checksum the safe report writer")
    if workflows.count("tools/report_output.py") < 6:
        errors.append("Windows CI, Linux CI, and tagged release artifacts must upload the safe report writer")
    if workflows.count("evidence_workflow_smoke=tools/smoke_playtest_evidence.py") != 3:
        errors.append("Windows CI, Linux CI, and tagged release manifests must checksum the evidence workflow smoke")
    if workflows.count("tools/smoke_playtest_evidence.py") < 6:
        errors.append("Windows CI, Linux CI, and tagged release artifacts must upload and exercise the evidence workflow smoke")

    release_doc = (root / "docs/internal_test_release.md").read_text(encoding="utf-8")
    for statement in (
        "does not implement the planned five-region campaign",
        "final music remains excluded",
        "private-alpha candidate",
        "rollback",
    ):
        require(release_doc.lower(), statement.lower(), "honest release boundary", errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March private-alpha contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
