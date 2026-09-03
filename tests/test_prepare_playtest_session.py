#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest
from tools.prepare_playtest_session import prepare_session


def main() -> int:
    with tempfile.TemporaryDirectory() as directory:
        base = Path(directory)
        cohort = base / "cohort"
        sessions = base / "sessions"
        for folder in (cohort / "tools", cohort / "build", cohort / "docs", cohort / "artifacts"):
            folder.mkdir(parents=True, exist_ok=True)
        (cohort / "tools/ci_manifest.json").write_text(
            json.dumps(
                {
                    "slug": "the-long-march",
                    "display_name": "The Long March",
                    "prototype_version": "0.3.0-alpha.test",
                    "save_compatibility": {"minimum": 4, "current": 16},
                    "campaign_contract": {"regions": 4, "session_minutes": {"minimum": 30, "maximum": 90}, "timing_evidence": "authored_target_not_human_observation", "completed_packets": [f"LM-GPT56-{index}" for index in range(0, 6)]},
                    "playtest_ready": True,
                    "release_ready": False,
                    "primary_repo": "example/the-long-march",
                }
            ),
            encoding="utf-8",
        )
        (cohort / "build/game.exe").write_bytes(b"verified playtest")
        (cohort / "docs/private_alpha_session_sheet.md").write_text(
            "# The Long March — Private Alpha Session Sheet\n\n## Observe without coaching\n\n- First action: __________\n",
            encoding="utf-8",
        )
        manifest = build_manifest(
            cohort,
            cohort / "tools/ci_manifest.json",
            [
                ("desktop_package", "build/game.exe"),
                ("session_sheet", "docs/private_alpha_session_sheet.md"),
            ],
            "workflow-sha",
            "head-sha-1234567890",
            "refs/tags/v0.3.0-alpha.test",
            "https://example.invalid/runs/12",
            "windows",
            "4.4.1.stable.official",
            ["deterministic_tests", "windows_packaged_smoke"],
        )
        manifest_path = cohort / "artifacts/release_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

        output = sessions / "session-01-observer.md"
        created = prepare_session(manifest_path, output, 1)
        assert created == output.resolve()
        sheet = output.read_text(encoding="utf-8")
        assert sheet.startswith("# The Long March — Private Alpha Session 01")
        assert "Build: `0.3.0-alpha.test`" in sheet
        assert "Cohort: `0.3.0-alpha.test@head-sha-123`" in sheet
        assert "Platform: `windows`" in sheet
        assert "Source commit: `head-sha-1234567890`" in sheet
        desktop_digest = next(entry["sha256"] for entry in manifest["files"] if entry["role"] == "desktop_package")
        assert desktop_digest in sheet
        assert "Consent confirmed" in sheet and "Session is uncoached" in sheet
        assert "## Observe without coaching" in sheet
        assert sheet.count("# The Long March") == 1
        assert "## Before each session" not in sheet

        try:
            prepare_session(manifest_path, output, 1)
        except ValueError as exc:
            assert "will not be overwritten" in str(exc)
        else:
            raise AssertionError("existing observer notes must not be overwritten")

        try:
            prepare_session(manifest_path, cohort / "session-02.md", 2)
        except ValueError as exc:
            assert "outside the verified cohort" in str(exc)
        else:
            raise AssertionError("session output inside the retained cohort must be rejected")

        try:
            prepare_session(manifest_path, sessions / "session-00-observer.md", 0)
        except ValueError as exc:
            assert "session number" in str(exc)
        else:
            raise AssertionError("session zero must be rejected")

        (cohort / "build/game.exe").write_bytes(b"altered build")
        try:
            prepare_session(manifest_path, sessions / "session-02-observer.md", 2)
        except ValueError as exc:
            assert "cohort verification failed" in str(exc) and "mismatch" in str(exc)
        else:
            raise AssertionError("an altered cohort must not create an observer sheet")

    print("PASS: The Long March private-alpha session preflight")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
