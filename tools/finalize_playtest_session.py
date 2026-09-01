#!/usr/bin/env python3
"""Create or verify a provenance-checked, non-destructive playtest session packet."""
from __future__ import annotations

import argparse
import json
import re
import shutil
from pathlib import Path
from typing import Any

try:
    from .prepare_playtest_session import load_verified_cohort
    from .report_output import write_new_report
    from .summarize_playtest_feedback import build_session_sheet, load_feedback
    from .verify_release_manifest import sha256
except ImportError:
    from prepare_playtest_session import load_verified_cohort
    from report_output import write_new_report
    from summarize_playtest_feedback import build_session_sheet, load_feedback
    from verify_release_manifest import sha256


PACKET_FILES = {
    "release_manifest": "release_manifest.json",
    "observer_notes": "observer.md",
    "feedback_export": "feedback.json",
    "automatic_summary": "automatic.md",
    "packet_readme": "README.md",
}


def _manifest_file(manifest: dict[str, Any], role: str) -> dict[str, Any]:
    matches = [
        entry
        for entry in manifest.get("files", [])
        if isinstance(entry, dict) and entry.get("role") == role
    ]
    if len(matches) != 1:
        raise ValueError(f"cohort manifest must contain exactly one {role} file")
    return matches[0]


def _observer_session_number(observer_text: str) -> int:
    first_line = observer_text.splitlines()[0] if observer_text.splitlines() else ""
    match = re.fullmatch(r"# The Long March — Private Alpha Session ([0-9]+)", first_line)
    if not match:
        raise ValueError("observer notes do not have a generated private-alpha session heading")
    session_number = int(match.group(1))
    if session_number < 1:
        raise ValueError("observer session number must be at least 1")
    return session_number


def validate_observer_identity(
    observer_text: str,
    manifest: dict[str, Any],
    manifest_path: Path,
) -> int:
    session_number = _observer_session_number(observer_text)
    product = manifest.get("product", {})
    cohort = manifest.get("cohort", {})
    source = manifest.get("source", {})
    package = _manifest_file(manifest, "desktop_package")
    expected_lines = (
        f"- Build: `{product.get('version', 'unknown')}`",
        f"- Cohort: `{cohort.get('id', 'unknown')}`",
        f"- Platform: `{cohort.get('platform', 'unknown')}`",
        f"- Source commit: `{source.get('head_commit', 'unknown')}`",
        f"- Desktop SHA-256: `{package.get('sha256', 'unknown')}`",
        f"- Manifest SHA-256: `{sha256(manifest_path.resolve())}`",
    )
    missing = [line for line in expected_lines if observer_text.count(line) != 1]
    if missing:
        raise ValueError("observer notes do not match this verified cohort: " + "; ".join(missing))
    for ownership_marker in (
        "Consent confirmed before notes, screenshots, recording, or report collection.",
        "Session is uncoached beyond the controls and instructions visible in the build.",
    ):
        if ownership_marker not in observer_text:
            raise ValueError(f"observer notes are missing the session-ownership marker: {ownership_marker}")
    return session_number


def _packet_readme(packet: dict[str, Any]) -> str:
    artifact = packet["artifact"]
    session = packet["session"]
    return "\n".join(
        [
            f"# The Long March — Session {int(session['number']):02d} Evidence Packet",
            "",
            "This local packet binds one observer sheet to one in-game feedback export without modifying either source file.",
            "",
            f"- Build: `{artifact['product_version']}`",
            f"- Cohort: `{artifact['cohort_id']}`",
            f"- Platform: `{artifact['platform']}`",
            f"- Source commit: `{artifact['source_commit']}`",
            f"- Run code: `{session['run_code']}`",
            "",
            "## Contents",
            "",
            "- `observer.md`: exact byte-for-byte copy of the human observer sheet.",
            "- `feedback.json`: exact byte-for-byte copy of the local game export.",
            "- `release_manifest.json`: exact cohort manifest used to validate the session.",
            "- `automatic.md`: generated navigation and outcome summary; it does not grade comprehension.",
            "- `packet_manifest.json`: SHA-256 and byte length for every file above and this README.",
            "",
            "Verify from the retained cohort with:",
            "",
            "```bash",
            "python tools/finalize_playtest_session.py verify /path/to/session-packet",
            "```",
            "",
            "## Human evidence boundary",
            "",
            "A valid packet proves artifact identity and detects later file changes. It does not prove consent, a unique tester, an uncoached session, comprehension, or a passed quality gate. A human reviewer must confirm those facts.",
            "",
            "This packet can contain direct quotes and locally exported answers. Keep it outside Git and shared services unless the participant explicitly consented and personal information has been removed.",
            "",
        ]
    )


def _file_entry(path: Path, role: str) -> dict[str, Any]:
    return {
        "role": role,
        "path": path.name,
        "bytes": path.stat().st_size,
        "sha256": sha256(path),
    }


def create_packet(
    manifest_path: Path,
    observer_path: Path,
    feedback_path: Path,
    output_dir: Path,
) -> Path:
    manifest_path = manifest_path.resolve()
    manifest, cohort_root = load_verified_cohort(manifest_path)
    observer_path = observer_path.resolve()
    feedback_path = feedback_path.resolve()
    if not observer_path.is_file():
        raise ValueError(f"observer notes do not exist: {observer_path}")
    if not feedback_path.is_file():
        raise ValueError(f"feedback export does not exist: {feedback_path}")

    observer_bytes = observer_path.read_bytes()
    try:
        observer_text = observer_bytes.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ValueError("observer notes must be UTF-8 Markdown") from exc
    session_number = validate_observer_identity(observer_text, manifest, manifest_path)
    feedback = load_feedback(feedback_path)
    product_version = str(manifest.get("product", {}).get("version", "unknown"))
    if str(feedback.get("build_version", "")) != product_version:
        raise ValueError(
            "feedback build does not match the verified cohort: "
            f"{feedback.get('build_version', 'missing')} != {product_version}"
        )
    automatic = build_session_sheet(feedback, "feedback.json")

    destination = output_dir.resolve()
    try:
        destination.relative_to(cohort_root.resolve())
    except ValueError:
        pass
    else:
        raise ValueError("session packet output must be outside the verified cohort directory")

    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        destination.mkdir()
    except FileExistsError as exc:
        raise ValueError(f"session packet already exists and will not be overwritten: {destination}") from exc

    try:
        release_manifest_copy = destination / PACKET_FILES["release_manifest"]
        observer_copy = destination / PACKET_FILES["observer_notes"]
        feedback_copy = destination / PACKET_FILES["feedback_export"]
        with release_manifest_copy.open("xb") as output:
            output.write(manifest_path.read_bytes())
        with observer_copy.open("xb") as output:
            output.write(observer_bytes)
        with feedback_path.open("rb") as source, feedback_copy.open("xb") as output:
            shutil.copyfileobj(source, output)
        automatic_path = write_new_report(
            destination / PACKET_FILES["automatic_summary"],
            automatic,
            "automatic playtest summary",
        )
        final_state = feedback.get("final_state", {})
        run_code = str(final_state.get("run_code", "unknown")) if isinstance(final_state, dict) else "unknown"
        packet: dict[str, Any] = {
            "schema_version": 1,
            "artifact": {
                "product_version": product_version,
                "cohort_id": str(manifest.get("cohort", {}).get("id", "unknown")),
                "platform": str(manifest.get("cohort", {}).get("platform", "unknown")),
                "source_commit": str(manifest.get("source", {}).get("head_commit", "unknown")),
                "release_manifest_sha256": sha256(manifest_path),
            },
            "session": {"number": session_number, "run_code": run_code},
            "claims": {
                "artifact_identity_verified": True,
                "consent_verified": False,
                "unique_tester_verified": False,
                "uncoached_session_verified": False,
                "comprehension_verified": False,
            },
            "files": [],
        }
        readme_path = destination / PACKET_FILES["packet_readme"]
        write_new_report(readme_path, _packet_readme(packet), "session packet README")
        packet["files"] = [
            _file_entry(release_manifest_copy, "release_manifest"),
            _file_entry(observer_copy, "observer_notes"),
            _file_entry(feedback_copy, "feedback_export"),
            _file_entry(automatic_path, "automatic_summary"),
            _file_entry(readme_path, "packet_readme"),
        ]
        packet["files"].sort(key=lambda entry: entry["role"])
        manifest_output = destination / "packet_manifest.json"
        with manifest_output.open("x", encoding="utf-8") as output:
            json.dump(packet, output, indent=2)
            output.write("\n")
    except Exception:
        shutil.rmtree(destination)
        raise
    return destination


def verify_packet(packet_dir: Path) -> list[str]:
    root = packet_dir.resolve()
    manifest_path = root / "packet_manifest.json"
    try:
        packet = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read packet manifest: {exc}"]
    errors: list[str] = []
    if not isinstance(packet, dict) or packet.get("schema_version") != 1:
        return ["packet manifest must be a schema-version 1 object"]
    claims = packet.get("claims", {})
    if not isinstance(claims, dict) or claims.get("artifact_identity_verified") is not True:
        errors.append("packet does not record verified artifact identity")
    for claim in ("consent_verified", "unique_tester_verified", "uncoached_session_verified", "comprehension_verified"):
        if not isinstance(claims, dict) or claims.get(claim) is not False:
            errors.append(f"packet must leave {claim} as a human-owned false claim")
    entries = packet.get("files", [])
    if not isinstance(entries, list):
        return errors + ["packet files must be an array"]
    roles = [entry.get("role") for entry in entries if isinstance(entry, dict)]
    if sorted(roles) != sorted(PACKET_FILES):
        errors.append("packet must contain exactly one release manifest, observer, feedback export, automatic summary, and README")
    for entry in entries:
        if not isinstance(entry, dict):
            errors.append("packet file entry must be an object")
            continue
        relative = Path(str(entry.get("path", "")))
        role = str(entry.get("role", ""))
        if role in PACKET_FILES and relative.as_posix() != PACKET_FILES[role]:
            errors.append(f"packet role has an unexpected path: {role} -> {relative}")
        candidate = (root / relative).resolve()
        try:
            candidate.relative_to(root)
        except ValueError:
            errors.append(f"packet file escapes packet root: {relative}")
            continue
        if not candidate.is_file():
            errors.append(f"packet file is missing: {relative}")
            continue
        if candidate.stat().st_size != entry.get("bytes"):
            errors.append(f"packet file size mismatch: {relative}")
        if sha256(candidate) != entry.get("sha256"):
            errors.append(f"packet file SHA-256 mismatch: {relative}")
    release_manifest_path = root / PACKET_FILES["release_manifest"]
    observer_path = root / PACKET_FILES["observer_notes"]
    feedback_path = root / PACKET_FILES["feedback_export"]
    if release_manifest_path.is_file() and observer_path.is_file() and feedback_path.is_file():
        try:
            release_manifest = json.loads(release_manifest_path.read_text(encoding="utf-8"))
            artifact = packet.get("artifact", {})
            if not isinstance(release_manifest, dict) or not isinstance(artifact, dict):
                raise ValueError("packet artifact and release manifest must be objects")
            expected_artifact = {
                "product_version": str(release_manifest.get("product", {}).get("version", "unknown")),
                "cohort_id": str(release_manifest.get("cohort", {}).get("id", "unknown")),
                "platform": str(release_manifest.get("cohort", {}).get("platform", "unknown")),
                "source_commit": str(release_manifest.get("source", {}).get("head_commit", "unknown")),
                "release_manifest_sha256": sha256(release_manifest_path),
            }
            if artifact != expected_artifact:
                errors.append("packet artifact identity does not match its retained release manifest")
            observer_text = observer_path.read_text(encoding="utf-8")
            session_number = validate_observer_identity(observer_text, release_manifest, release_manifest_path)
            session = packet.get("session", {})
            if not isinstance(session, dict) or session.get("number") != session_number:
                errors.append("packet session number does not match its observer notes")
            feedback = load_feedback(feedback_path)
            if str(feedback.get("build_version", "")) != expected_artifact["product_version"]:
                errors.append("packet feedback build does not match its retained release manifest")
            final_state = feedback.get("final_state", {})
            run_code = str(final_state.get("run_code", "unknown")) if isinstance(final_state, dict) else "unknown"
            if not isinstance(session, dict) or session.get("run_code") != run_code:
                errors.append("packet run code does not match its feedback export")
        except (OSError, UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
            errors.append(f"packet provenance validation failed: {exc}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    create = commands.add_parser("create", help="Create a new session packet")
    create.add_argument("manifest", type=Path, help="Verified cohort release manifest")
    create.add_argument("--observer", type=Path, required=True, help="Completed generated observer sheet")
    create.add_argument("--feedback", type=Path, required=True, help="Local feedback JSON export")
    create.add_argument("--output", type=Path, required=True, help="New packet directory outside the cohort")
    verify = commands.add_parser("verify", help="Verify an existing session packet")
    verify.add_argument("packet", type=Path, help="Session packet directory")
    args = parser.parse_args()

    if args.command == "verify":
        errors = verify_packet(args.packet)
        if errors:
            for error in errors:
                print(f"ERROR: {error}")
            return 1
        print(f"PASS: verified playtest session packet: {args.packet.resolve()}")
        return 0

    try:
        output = create_packet(args.manifest, args.observer, args.feedback, args.output)
    except (OSError, KeyError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    print(f"playtest session packet: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
