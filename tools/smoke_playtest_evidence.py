#!/usr/bin/env python3
"""Exercise the packaged playtest-evidence workflow with synthetic local data."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path
from typing import Any

try:
    from .finalize_playtest_session import create_packet, verify_packet
    from .prepare_playtest_session import load_verified_cohort, prepare_session
    from .report_output import write_new_report
    from .summarize_playtest_packets import build_packet_cohort_report, load_packet_cohort
except ImportError:
    from finalize_playtest_session import create_packet, verify_packet
    from prepare_playtest_session import load_verified_cohort, prepare_session
    from report_output import write_new_report
    from summarize_playtest_packets import build_packet_cohort_report, load_packet_cohort


def _feedback_payload(build_version: str, platform: str) -> dict[str, Any]:
    run_code = f"EVIDENCE-SMOKE-{platform.upper()}"
    return {
        "schema_version": 2,
        "build_version": build_version,
        "answers": {
            "clear_or_satisfying": "Synthetic release-pipeline smoke response.",
            "confusing_or_frustrating": "Synthetic release-pipeline smoke response.",
            "causal_replay": "Synthetic release-pipeline smoke response.",
            "replay_score": 3,
        },
        "final_state": {
            "run_code": run_code,
            "campaign_region": "release_pipeline_smoke",
            "result": "synthetic_evidence_check",
            "campaign_path": ["release_pipeline_smoke"],
            "hull": 1,
            "fuel": 1,
            "campaign_pressure": 0,
        },
        "session_metrics": {
            "encounter_steps": 0,
            "contact_targets_locked": 0,
            "contact_target_inspections": 0,
            "emergency_orders_used": 0,
            "journey_commitments": 1,
            "road_events_reached": 0,
            "road_events_resolved": 0,
            "road_arrivals_completed": 0,
        },
        "session": {
            "started_at_unix": 1,
            "events": [
                {
                    "timestamp_unix": 1,
                    "event": "campaign_node_started",
                    "properties": {"node": "release_pipeline_smoke"},
                }
            ],
        },
    }


def smoke_evidence_workflow(manifest_path: Path, output_dir: Path) -> Path:
    manifest_path = manifest_path.resolve()
    manifest, cohort_root = load_verified_cohort(manifest_path)
    destination = output_dir.resolve()
    try:
        destination.relative_to(cohort_root.resolve())
    except ValueError:
        pass
    else:
        raise ValueError("evidence smoke output must be outside the verified cohort directory")
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        destination.mkdir()
    except FileExistsError as exc:
        raise ValueError(f"evidence smoke output already exists and will not be overwritten: {destination}") from exc

    try:
        product_version = str(manifest.get("product", {}).get("version", "unknown"))
        platform = str(manifest.get("cohort", {}).get("platform", "unknown"))
        observer = prepare_session(manifest_path, destination / "observer.md", 1)
        feedback = destination / "feedback.json"
        with feedback.open("x", encoding="utf-8") as output:
            json.dump(_feedback_payload(product_version, platform), output, indent=2)
            output.write("\n")

        packet = create_packet(manifest_path, observer, feedback, destination / "packet")
        packet_errors = verify_packet(packet)
        if packet_errors:
            raise ValueError("created packet failed verification:\n- " + "\n- ".join(packet_errors))
        packet_manifest = json.loads((packet / "packet_manifest.json").read_text(encoding="utf-8"))
        claims = packet_manifest.get("claims", {})
        human_claims = (
            "consent_verified",
            "unique_tester_verified",
            "uncoached_session_verified",
            "comprehension_verified",
        )
        if not isinstance(claims, dict) or any(claims.get(claim) is not False for claim in human_claims):
            raise ValueError("synthetic smoke packet must leave every human-owned claim false")

        records = load_packet_cohort([packet])
        report = build_packet_cohort_report(records)
        if "INCOMPLETE (1/5 verified packets)" not in report:
            raise ValueError("synthetic cohort report must remain below the human evidence gate")
        return write_new_report(destination / "cohort-review.md", report, "synthetic cohort review")
    except Exception:
        shutil.rmtree(destination)
        raise


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="Path to artifacts/release_manifest.json")
    parser.add_argument("--output", type=Path, required=True, help="New output directory outside the cohort")
    args = parser.parse_args()
    try:
        review = smoke_evidence_workflow(args.manifest, args.output)
    except (OSError, KeyError, ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}")
        return 1
    print(f"PASS: packaged playtest-evidence workflow: {review}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
