#!/usr/bin/env python3
"""Verify one retained cohort and create a non-destructive observer session sheet."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

try:
    from .verify_release_manifest import sha256, verify_manifest
except ImportError:
    from verify_release_manifest import sha256, verify_manifest


def _entry_for_role(manifest: dict[str, Any], role: str) -> dict[str, Any]:
    matches = [
        entry
        for entry in manifest.get("files", [])
        if isinstance(entry, dict) and entry.get("role") == role
    ]
    if len(matches) != 1:
        raise ValueError(f"manifest must contain exactly one {role} file")
    return matches[0]


def load_verified_cohort(manifest_path: Path) -> tuple[dict[str, Any], Path]:
    manifest_path = manifest_path.resolve()
    root = manifest_path.parent.parent
    try:
        payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"cannot read release manifest: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError("release manifest root must be an object")
    errors = verify_manifest(payload, root)
    if errors:
        raise ValueError("cohort verification failed:\n- " + "\n- ".join(errors))
    return payload, root


def build_session_document(
    manifest: dict[str, Any],
    cohort_root: Path,
    manifest_path: Path,
    session_number: int,
) -> str:
    if session_number < 1:
        raise ValueError("session number must be at least 1")
    product = manifest["product"]
    cohort = manifest["cohort"]
    source = manifest["source"]
    toolchain = manifest["toolchain"]
    package = _entry_for_role(manifest, "desktop_package")
    template = _entry_for_role(manifest, "session_sheet")
    template_path = (cohort_root / str(template["path"])).resolve()
    template_text = template_path.read_text(encoding="utf-8")
    template_lines = template_text.splitlines()
    evidence_heading = "## Evidence to collect"
    if evidence_heading in template_lines:
        template_lines = template_lines[template_lines.index(evidence_heading):]
    elif template_lines and template_lines[0].startswith("# "):
        template_lines = template_lines[1:]
    verification = ", ".join(f"`{item}`" for item in manifest.get("verification", []))
    lines = [
        f"# The Long March — Private Alpha Session {session_number:02d}",
        "",
        "## Verified cohort identity",
        "",
        "This sheet was generated only after every checksummed cohort file passed verification. Keep the extracted cohort unchanged and store this observer sheet outside it.",
        "",
        f"- Build: `{product.get('version', 'unknown')}`",
        f"- Cohort: `{cohort.get('id', 'unknown')}`",
        f"- Platform: `{cohort.get('platform', 'unknown')}`",
        f"- Source commit: `{source.get('head_commit', 'unknown')}`",
        f"- Workflow commit: `{source.get('workflow_commit', 'unknown')}`",
        f"- Workflow: {source.get('workflow_run_url', 'not recorded')}",
        f"- Godot: `{toolchain.get('godot', 'unknown')}`",
        f"- Desktop package: `{package.get('path', 'unknown')}`",
        f"- Desktop SHA-256: `{package.get('sha256', 'unknown')}`",
        f"- Manifest SHA-256: `{sha256(manifest_path.resolve())}`",
        f"- Verified gates: {verification or 'not recorded'}",
        "",
        "## Session ownership",
        "",
        "- Tester alias: __________",
        "- Observer: __________",
        "- Date / device / input / display: __________",
        "- [ ] Consent confirmed before notes, screenshots, recording, or report collection.",
        "- [ ] Session is uncoached beyond the controls and instructions visible in the build.",
        "- [ ] This tester and run are unique within the intended cohort review.",
        "",
        "---",
        "",
        *template_lines,
    ]
    return "\n".join(lines).rstrip() + "\n"


def prepare_session(manifest_path: Path, output_path: Path, session_number: int) -> Path:
    if session_number < 1:
        raise ValueError("session number must be at least 1")
    manifest, cohort_root = load_verified_cohort(manifest_path)
    destination = output_path.resolve()
    try:
        destination.relative_to(cohort_root.resolve())
    except ValueError:
        pass
    else:
        raise ValueError("observer output must be outside the verified cohort directory")
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        with destination.open("x", encoding="utf-8") as output:
            output.write(build_session_document(manifest, cohort_root, manifest_path, session_number))
    except FileExistsError as exc:
        raise ValueError(f"observer output already exists and will not be overwritten: {destination}") from exc
    return destination


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="Path to artifacts/release_manifest.json")
    parser.add_argument("--session", type=int, required=True, help="Positive session number")
    parser.add_argument("--output", type=Path, required=True, help="New Markdown observer sheet outside the cohort")
    args = parser.parse_args()
    try:
        output = prepare_session(args.manifest, args.output, args.session)
    except (OSError, KeyError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    print(f"verified private-alpha session sheet: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
