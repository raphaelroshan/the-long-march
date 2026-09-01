#!/usr/bin/env python3
"""Render the stable tester-facing preamble for a tagged private-alpha release."""
from __future__ import annotations

import argparse
from pathlib import Path


def render_notes(tag: str, workflow_url: str) -> str:
    if not tag.startswith("v") or len(tag) < 2:
        raise ValueError("release tag must start with v")
    if not workflow_url.startswith(("https://", "http://")):
        raise ValueError("workflow URL must be absolute")
    windows = f"The-Long-March-{tag}-Windows.exe"
    macos = f"The-Long-March-{tag}-macOS.zip"
    windows_cohort = f"The-Long-March-{tag}-Windows-Cohort.zip"
    macos_cohort = f"The-Long-March-{tag}-macOS-Cohort.zip"
    return "\n".join(
        [
            "Private-alpha playtest build — not a public release or storefront-ready product.",
            "",
            "## Choose a download",
            "",
            f"- Windows standalone: `{windows}`",
            f"- macOS standalone: `{macos}`",
            f"- Windows observer cohort: `{windows_cohort}`",
            f"- macOS observer cohort: `{macos_cohort}`",
            "",
            "Standalone builds are the quickest way to play. Observer cohorts also contain the exact manifest, source snapshot, playtest guide, session template, local summary tools, and session preflight.",
            "",
            "## Run a verified session",
            "",
            "From an extracted cohort:",
            "",
            "```bash",
            "python tools/prepare_playtest_session.py artifacts/release_manifest.json --session 1 --output ../long-march-session-01.md",
            "```",
            "",
            "Use `SHA256SUMS.txt` to verify the downloaded release assets. The cohort's own manifest verifies every file inside it.",
            "",
            f"Build and verification evidence: [GitHub Actions workflow]({workflow_url})",
            "",
            "---",
            "",
        ]
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--workflow-url", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        notes = render_notes(args.tag, args.workflow_url)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(notes, encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    print(f"release notes preamble: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
