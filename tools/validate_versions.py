#!/usr/bin/env python3
"""Verify that player-facing and packaged build versions stay synchronized."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def quoted_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{re.escape(key)}=\"([^\"]+)\"$", text, re.MULTILINE)
    return match.group(1) if match else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=".")
    args = parser.parse_args()
    root = Path(args.repo).resolve()
    errors: list[str] = []

    project_text = (root / "project.godot").read_text(encoding="utf-8")
    project_version = quoted_value(project_text, "config/version")
    match = re.fullmatch(r"(\d+\.\d+\.\d+)-alpha\.(\d+)", project_version or "")
    if match is None:
        errors.append(f"project.godot config/version is not an alpha build: {project_version!r}")
        numeric_version = ""
    else:
        numeric_version = f"{match.group(1)}.{match.group(2)}"

    manifest = json.loads((root / "tools/ci_manifest.json").read_text(encoding="utf-8"))
    if manifest.get("prototype_version") != project_version:
        errors.append(
            "tools/ci_manifest.json prototype_version does not match project.godot "
            f"({manifest.get('prototype_version')!r} != {project_version!r})"
        )

    export_text = (root / "export_presets.cfg").read_text(encoding="utf-8")
    for key in ("application/file_version", "application/product_version", "application/version"):
        values = re.findall(rf"^{re.escape(key)}=\"([^\"]+)\"$", export_text, re.MULTILINE)
        if not values:
            errors.append(f"export_presets.cfg is missing {key}")
        for value in values:
            if value != numeric_version:
                errors.append(f"export_presets.cfg {key} is {value!r}; expected {numeric_version!r}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"build version consistency: PASS ({project_version})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
