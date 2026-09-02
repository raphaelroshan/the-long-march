#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest
from tools.smoke_playtest_evidence import smoke_evidence_workflow


def main() -> int:
    with tempfile.TemporaryDirectory() as directory:
        base = Path(directory)
        cohort = base / "cohort"
        for folder in (cohort / "tools", cohort / "build", cohort / "docs", cohort / "artifacts"):
            folder.mkdir(parents=True, exist_ok=True)
        (cohort / "tools/ci_manifest.json").write_text(
            json.dumps(
                {
                    "slug": "the-long-march",
                    "display_name": "The Long March",
                    "prototype_version": "0.3.0-alpha.test",
                    "save_compatibility": {"minimum": 4, "current": 16},
                    "playtest_ready": True,
                    "release_ready": False,
                    "primary_repo": "example/the-long-march",
                }
            ),
            encoding="utf-8",
        )
        (cohort / "build/game.exe").write_bytes(b"verified playtest")
        (cohort / "docs/private_alpha_session_sheet.md").write_text(
            "# Session Sheet\n\n## Evidence to collect\n\n- First action: __________\n",
            encoding="utf-8",
        )
        manifest = build_manifest(
            cohort,
            cohort / "tools/ci_manifest.json",
            [("desktop_package", "build/game.exe"), ("session_sheet", "docs/private_alpha_session_sheet.md")],
            "workflow-sha",
            "head-sha-1234567890",
            "refs/tags/v0.3.0-alpha.test",
            "https://example.invalid/runs/12",
            "windows",
            "4.4.1.stable.official",
            ["deterministic_tests"],
        )
        manifest_path = cohort / "artifacts/release_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

        output = base / "evidence-smoke"
        review = smoke_evidence_workflow(manifest_path, output)
        assert review == (output / "cohort-review.md").resolve()
        assert "INCOMPLETE (1/5 verified packets)" in review.read_text(encoding="utf-8")
        packet = json.loads((output / "packet/packet_manifest.json").read_text(encoding="utf-8"))
        assert packet["artifact"]["product_version"] == "0.3.0-alpha.test"
        assert packet["artifact"]["platform"] == "windows"
        assert packet["session"]["run_code"] == "EVIDENCE-SMOKE-WINDOWS"
        assert packet["claims"]["artifact_identity_verified"] is True
        assert packet["claims"]["consent_verified"] is False
        assert packet["claims"]["unique_tester_verified"] is False
        assert packet["claims"]["uncoached_session_verified"] is False
        assert packet["claims"]["comprehension_verified"] is False

        try:
            smoke_evidence_workflow(manifest_path, output)
        except ValueError as exc:
            assert "will not be overwritten" in str(exc)
        else:
            raise AssertionError("evidence smoke output must be create-only")

        try:
            smoke_evidence_workflow(manifest_path, cohort / "smoke")
        except ValueError as exc:
            assert "outside the verified cohort" in str(exc)
        else:
            raise AssertionError("evidence smoke output must not alter its cohort")

    print("PASS: The Long March packaged playtest-evidence workflow smoke")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
