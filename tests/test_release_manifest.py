#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest
from tools.verify_release_manifest import verify_manifest


def main() -> int:
	with tempfile.TemporaryDirectory() as directory:
		root = Path(directory)
		(root / "tools").mkdir()
		(root / "build").mkdir()
		(root / "docs").mkdir()
		(root / "tools/ci_manifest.json").write_text(
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
		(root / "build/game.exe").write_bytes(b"deterministic build")
		(root / "docs/observer.md").write_text("observe without coaching\n", encoding="utf-8")
		manifest = build_manifest(
			root,
			root / "tools/ci_manifest.json",
			[("observer_brief", "docs/observer.md"), ("windows_executable", "build/game.exe")],
			"merge-sha",
			"head-sha",
			"refs/pull/12/merge",
			"https://example.invalid/runs/12",
			"windows",
			"4.4.1.stable.official",
			["windows_export", "deterministic_tests", "deterministic_tests"],
		)
		assert manifest["schema_version"] == 1
		assert manifest["product"]["version"] == "0.3.0-alpha.test"
		assert manifest["source"]["workflow_commit"] == "merge-sha"
		assert manifest["source"]["head_commit"] == "head-sha"
		assert manifest["cohort"] == {"id": "0.3.0-alpha.test@head-sha", "platform": "windows"}
		assert manifest["toolchain"] == {"godot": "4.4.1.stable.official"}
		assert manifest["compatibility"] == {"save_versions": {"minimum": 4, "current": 16}, "offline_runtime": True}
		assert manifest["campaign"] == {"regions": 4, "session_minutes": {"minimum": 30, "maximum": 90}, "timing_evidence": "authored_target_not_human_observation", "completed_packets": [f"LM-GPT56-{index}" for index in range(0, 6)]}
		assert manifest["verification"] == ["deterministic_tests", "windows_export"]
		assert [entry["role"] for entry in manifest["files"]] == ["observer_brief", "windows_executable"]
		game_entry = manifest["files"][1]
		assert game_entry["bytes"] == len(b"deterministic build")
		assert game_entry["sha256"] == hashlib.sha256(b"deterministic build").hexdigest()
		assert verify_manifest(manifest, root) == []
		linux_manifest = build_manifest(
			root,
			root / "tools/ci_manifest.json",
			[("linux_executable", "build/game.exe")],
			"merge-sha",
			"head-sha",
			"refs/pull/12/merge",
			"https://example.invalid/runs/12",
			"linux",
			"4.4.1.stable.official",
			["linux_export", "linux_packaged_smoke"],
		)
		assert linux_manifest["cohort"]["platform"] == "linux"
		assert verify_manifest(linux_manifest, root) == []
		missing_toolchain = json.loads(json.dumps(manifest))
		missing_toolchain.pop("toolchain")
		assert any("Godot toolchain" in error for error in verify_manifest(missing_toolchain, root))
		missing_compatibility = json.loads(json.dumps(manifest))
		missing_compatibility.pop("compatibility")
		assert any("compatibility data" in error for error in verify_manifest(missing_compatibility, root))
		invalid_window = json.loads(json.dumps(manifest))
		invalid_window["compatibility"]["save_versions"] = {"minimum": 16, "current": 4}
		assert any("save compatibility window" in error for error in verify_manifest(invalid_window, root))
		invalid_campaign = json.loads(json.dumps(manifest))
		invalid_campaign["campaign"]["session_minutes"] = {"minimum": 10, "maximum": 180}
		assert any("30–90 minute" in error for error in verify_manifest(invalid_campaign, root))
		unobserved_boundary = json.loads(json.dumps(manifest))
		unobserved_boundary["campaign"]["timing_evidence"] = "human_observed"
		assert any("human observation" in error for error in verify_manifest(unobserved_boundary, root))
		(root / "build/game.exe").write_bytes(b"changed build")
		verification_errors = verify_manifest(manifest, root)
		assert any("size mismatch" in error for error in verification_errors)
		assert any("SHA-256 mismatch" in error for error in verification_errors)
		(root / "build/game.exe").write_bytes(b"deterministic build")

		try:
			build_manifest(
				root,
				root / "tools/ci_manifest.json",
				[("one", "build/game.exe"), ("two", "build/game.exe")],
				"sha",
				"",
				"ref",
				"url",
				"windows",
				"4.4.1",
				[],
			)
		except ValueError as exc:
			assert "more than once" in str(exc)
		else:
			raise AssertionError("duplicate artifact paths should be rejected")

		try:
			build_manifest(
				root,
				root / "tools/ci_manifest.json",
				[("escape", "../outside")],
				"sha",
				"",
				"ref",
				"url",
				"windows",
				"4.4.1",
				[],
			)
		except ValueError as exc:
			assert "escapes repository root" in str(exc)
		else:
			raise AssertionError("paths outside the repository should be rejected")

	print("PASS: The Long March release manifest")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
