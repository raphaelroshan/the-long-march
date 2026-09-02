#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.render_release_notes import render_notes


def main() -> int:
    notes = render_notes("v0.3.0-alpha.test", "https://example.invalid/actions/runs/12")
    assert notes.startswith("Private-alpha playtest build")
    assert "not a public release or storefront-ready product" in notes
    assert "The-Long-March-v0.3.0-alpha.test-Windows.exe" in notes
    assert "The-Long-March-v0.3.0-alpha.test-macOS.zip" in notes
    assert "The-Long-March-v0.3.0-alpha.test-Linux.x86_64" in notes
    assert "The-Long-March-v0.3.0-alpha.test-Windows-Cohort.zip" in notes
    assert "The-Long-March-v0.3.0-alpha.test-macOS-Cohort.zip" in notes
    assert "The-Long-March-v0.3.0-alpha.test-Linux-Cohort.zip" in notes
    assert "prepare_playtest_session.py" in notes
    assert "finalize_playtest_session.py create" in notes
    assert "verified packet cohort review" in notes
    assert "SHA256SUMS.txt" in notes
    assert "https://example.invalid/actions/runs/12" in notes
    assert notes.endswith("---\n")

    for tag, url, message in (
        ("0.3.0-alpha.test", "https://example.invalid/run", "start with v"),
        ("v0.3.0-alpha.test", "relative/run", "absolute"),
    ):
        try:
            render_notes(tag, url)
        except ValueError as exc:
            assert message in str(exc)
        else:
            raise AssertionError("invalid release-note input must be rejected")

    print("PASS: The Long March tester-facing release notes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
