#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    readme = (root / "README.md").read_text(encoding="utf-8")
    required = {
        "playable release link": "https://github.com/raphaelroshan/the-long-march/releases",
        "private-alpha boundary": "not a public launch or storefront-ready release",
        "Windows download": "**Windows:**",
        "macOS download": "**macOS:**",
        "release checksums": "SHA256SUMS.txt",
        "cohort preflight": "tools/prepare_playtest_session.py",
        "session packet finalizer": "tools/finalize_playtest_session.py",
        "current loop": "settlement bazaar",
        "Ashgate chapter": "**Ashgate Lowlands**",
        "Veyru chapter": "**Flooded Veyru**",
        "local privacy": "no analytics upload",
        "source verification": "bash scripts/verify.sh",
        "scope boundary": "## Scope boundary",
        "roadmap": "docs/agent_handoff_roadmap.md",
    }
    forbidden = {
        "obsolete prototype heading": "## Current prototype",
        "obsolete lightweight prototype claim": "A lightweight UI prototype",
        "human evidence described as optional": "Human testing is optional validation",
    }
    errors = [f"missing {label}: {marker}" for label, marker in required.items() if marker not in readme]
    errors.extend(f"found {label}: {marker}" for label, marker in forbidden.items() if marker in readme)
    referenced_files = (
        "docs/visual_evidence/v0.3.0-alpha.338-orchard-road-event/01_orchard_before_arrival.png",
        "docs/agent_handoff_roadmap.md",
        "design/journey_presentation_vertical_slice.md",
        "design/fortress_visual_modes.md",
        "design/gameplay_framework.md",
        "docs/private_alpha_session_sheet.md",
        "docs/visual_evidence_gallery.md",
        "docs/latest_test_report_2026-08-31.md",
    )
    for relative in referenced_files:
        if relative not in readme:
            errors.append(f"README is missing repository link: {relative}")
        elif not (root / relative).is_file():
            errors.append(f"README repository link is broken: {relative}")
    bullet_count = sum(1 for line in readme.splitlines() if line.startswith("- "))
    if len(readme.splitlines()) > 140:
        errors.append("README should remain a concise landing page (maximum 140 lines)")
    if bullet_count > 35:
        errors.append("README has regressed into a feature inventory (maximum 35 bullets)")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March player-first README contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
