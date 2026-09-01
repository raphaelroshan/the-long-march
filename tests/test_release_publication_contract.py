#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    workflow = (root / ".github/workflows/release.yml").read_text(encoding="utf-8")
    required = {
        "tag-only publish gate": "if: startsWith(github.ref, 'refs/tags/v')",
        "matrix dependency": "needs: release-candidate",
        "scoped release permission": "contents: write",
        "Windows cohort download": "windows-playtest-${{ github.ref_name }}",
        "macOS cohort download": "macos-playtest-${{ github.ref_name }}",
        "cohort verification": "tools/verify_release_manifest.py",
        "session preflight": "tools/prepare_playtest_session.py",
        "Windows cohort archive": "Windows-Cohort.zip",
        "macOS cohort archive": "macOS-Cohort.zip",
        "asset integrity list": "SHA256SUMS.txt",
        "tester-facing release notes": "tools/render_release_notes.py",
        "generated change list": "--notes \"$notes\" --title",
        "idempotent asset replacement": "gh release upload \"$tag\" release/* --clobber",
        "verified tag publication": "gh release create \"$tag\" release/* --verify-tag --prerelease",
    }
    errors = [f"missing {label}: {marker}" for label, marker in required.items() if marker not in workflow]
    if workflow.count("tools/verify_release_manifest.py staging/") != 2:
        errors.append("publisher must verify both downloaded platform cohorts")
    if workflow.count("tools/prepare_playtest_session.py staging/") != 2:
        errors.append("publisher must exercise preflight against both downloaded platform cohorts")
    publish_section = workflow.split("\n  publish:\n", 1)[-1]
    if "pull_request:" in publish_section:
        errors.append("publish job must not introduce a pull-request release trigger")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March automated prerelease publication contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
