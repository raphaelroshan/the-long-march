#!/usr/bin/env python3
"""Build one human-owned cohort review from verified playtest session packets."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

try:
    from .finalize_playtest_session import PACKET_FILES, verify_packet
    from .report_output import write_new_report
    from .summarize_playtest_cohort import build_cohort_report
    from .summarize_playtest_feedback import load_feedback
except ImportError:
    from finalize_playtest_session import PACKET_FILES, verify_packet
    from report_output import write_new_report
    from summarize_playtest_cohort import build_cohort_report
    from summarize_playtest_feedback import load_feedback


def _cell(value: Any) -> str:
    rendered = " ".join(str(value).split()).strip()
    return rendered.replace("|", "\\|") if rendered else "—"


def load_packet(packet_dir: Path) -> dict[str, Any]:
    root = packet_dir.resolve()
    errors = verify_packet(root)
    if errors:
        raise ValueError(f"invalid session packet {root}:\n- " + "\n- ".join(errors))
    try:
        packet = json.loads((root / "packet_manifest.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read verified packet manifest: {exc}") from exc
    session = packet.get("session", {})
    artifact = packet.get("artifact", {})
    entries = packet.get("files", [])
    if not isinstance(session, dict) or not isinstance(artifact, dict) or not isinstance(entries, list):
        raise ValueError("verified packet is missing session, artifact, or file metadata")
    try:
        session_number = int(session["number"])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError("verified packet has an invalid session number") from exc
    files = {
        str(entry.get("role", "")): entry
        for entry in entries
        if isinstance(entry, dict)
    }
    feedback = load_feedback(root / PACKET_FILES["feedback_export"])
    return {
        "root": root,
        "session_number": session_number,
        "run_code": str(session.get("run_code", "unknown")),
        "artifact": artifact,
        "observer_sha256": str(files["observer_notes"]["sha256"]),
        "feedback_sha256": str(files["feedback_export"]["sha256"]),
        "feedback": feedback,
    }


def load_packet_cohort(packet_dirs: list[Path]) -> list[dict[str, Any]]:
    if not packet_dirs:
        raise ValueError("at least one session packet is required")
    records = [load_packet(path) for path in packet_dirs]
    session_numbers = [record["session_number"] for record in records]
    duplicate_sessions = sorted(number for number in set(session_numbers) if session_numbers.count(number) > 1)
    if duplicate_sessions:
        raise ValueError(
            "session packet numbers must be unique within one review: "
            + ", ".join(f"{number:02d}" for number in duplicate_sessions)
        )
    feedback_hashes = [record["feedback_sha256"] for record in records]
    if len(set(feedback_hashes)) != len(feedback_hashes):
        raise ValueError("the same feedback export appears in more than one session packet")
    return sorted(records, key=lambda record: record["session_number"])


def build_packet_cohort_report(records: list[dict[str, Any]], required_sessions: int = 5) -> str:
    if not records:
        raise ValueError("at least one verified session packet is required")
    if required_sessions < 1:
        raise ValueError("required_sessions must be at least 1")
    cohort_ids = sorted({str(record["artifact"].get("cohort_id", "unknown")) for record in records})
    cohort_note = (
        f"- Cohort consistency: one cohort (`{cohort_ids[0]}`)."
        if len(cohort_ids) == 1
        else "- Cohort consistency: MIXED COHORTS — separate findings by cohort before attributing a repeated issue."
    )
    gate_state = "READY FOR HUMAN SYNTHESIS" if len(records) >= required_sessions else "INCOMPLETE"
    rows = []
    for record in records:
        artifact = record["artifact"]
        rows.append(
            "| %02d | `%s` | `%s` | %s | `%s` | `%s` | `%s` |"
            % (
                record["session_number"],
                _cell(artifact.get("product_version", "unknown")),
                _cell(artifact.get("cohort_id", "unknown")),
                _cell(artifact.get("platform", "unknown")),
                _cell(record["run_code"]),
                record["observer_sha256"],
                record["feedback_sha256"],
            )
        )
    labels = [f"{record['session_number']:02d}" for record in records]
    gameplay_report = build_cohort_report(
        [record["feedback"] for record in records],
        required_sessions,
        session_labels=labels,
    )
    gameplay_body = gameplay_report.split("\n", 2)[2] if gameplay_report.startswith("# ") else gameplay_report
    lines = [
        "# The Long March — Verified Packet Cohort Review",
        "",
        "## Packet gate",
        "",
        f"- Packet collection: {gate_state} ({len(records)}/{required_sessions} verified packets).",
        "- Every packet passed its file hashes, release-manifest identity, observer provenance, feedback build, session number, run code, and human-owned claim checks.",
        cohort_note,
        "- Duplicate session numbers and duplicate feedback exports are rejected before a report is created.",
        "- Observer prose is neither copied nor summarized here. Review `observer.md` directly when completing the human-validation rows.",
        "- Packet directory names and machine-specific paths are omitted.",
        "",
        "| Session | Build | Cohort | Platform | Run | Observer SHA-256 | Feedback SHA-256 |",
        "|---:|---|---|---|---|---|---|",
        *rows,
        "",
        "A verified packet establishes evidence pairing and file integrity. It does not prove consent, participant uniqueness, uncoached conditions, comprehension, severity, or a passed quality gate.",
        "",
        "---",
        "",
        gameplay_body,
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packet", type=Path, nargs="+", help="Verified session packet directories")
    parser.add_argument("--output", type=Path, required=True, help="New Markdown cohort-review destination")
    parser.add_argument("--required-sessions", type=int, default=5, help="Human review target (default: 5)")
    args = parser.parse_args()
    try:
        records = load_packet_cohort(args.packet)
        report = build_packet_cohort_report(records, args.required_sessions)
        output = write_new_report(args.output, report, "verified packet cohort review")
    except (OSError, KeyError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    print(f"verified packet cohort review: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
