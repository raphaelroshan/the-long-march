#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
from pathlib import Path


EXPECTED_COUNTS = {
    "static": 28,
    "core": 15,
    "presentation": 17,
    "journey": 12,
    "regional": 11,
}


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    verifier_path = root / "scripts" / "verify.sh"
    source = verifier_path.read_text(encoding="utf-8")
    listed = subprocess.run(
        ["bash", str(verifier_path), "--list"],
        cwd=root,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    errors: list[str] = []

    if listed != list(EXPECTED_COUNTS):
        errors.append(f"unexpected group list: {listed}")

    for group, expected_count in EXPECTED_COUNTS.items():
        match = re.search(
            rf"run_group_{group}\(\) \{{(?P<body>.*?)^\}}",
            source,
            flags=re.MULTILINE | re.DOTALL,
        )
        if match is None:
            errors.append(f"missing group function: {group}")
            continue
        steps = re.findall(rf"^\s*run_step {group} ([a-z0-9_]+) ", match.group("body"), re.MULTILINE)
        if len(steps) != expected_count:
            errors.append(f"{group} has {len(steps)} direct steps; expected {expected_count}")
        if len(steps) != len(set(steps)):
            errors.append(f"{group} contains duplicate step identifiers")

    godot_scripts = re.findall(r"--script (res://tests/[a-z0-9_]+\.gd)", source)
    if len(godot_scripts) != 55:
        errors.append(f"verifier has {len(godot_scripts)} Godot invocations; expected 55")

    for marker in ("VERIFY_TIMING", "VERIFY_GROUP_RESULT", "VERIFY_RESULT"):
        if marker not in source:
            errors.append(f"missing machine-readable result marker: {marker}")

    workflow = (root / ".github" / "workflows" / "ci.yml").read_text(encoding="utf-8")
    for group in EXPECTED_COUNTS:
        if f"group: {group}" not in workflow:
            errors.append(f"CI matrix is missing verification group: {group}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March bounded verification groups")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
