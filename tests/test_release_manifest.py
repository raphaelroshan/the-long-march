#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.create_release_manifest import build_manifest


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
			["windows_export", "deterministic_tests", "deterministic_tests"],
		)
		assert manifest["schema_version"] == 1
		assert manifest["product"]["version"] == "0.3.0-alpha.test"
		assert manifest["source"]["workflow_commit"] == "merge-sha"
		assert manifest["source"]["head_commit"] == "head-sha"
		assert manifest["verification"] == ["deterministic_tests", "windows_export"]
		assert [entry["role"] for entry in manifest["files"]] == ["observer_brief", "windows_executable"]
		game_entry = manifest["files"][1]
		assert game_entry["bytes"] == len(b"deterministic build")
		assert game_entry["sha256"] == hashlib.sha256(b"deterministic build").hexdigest()

		try:
			build_manifest(
				root,
				root / "tools/ci_manifest.json",
				[("one", "build/game.exe"), ("two", "build/game.exe")],
				"sha",
				"",
				"ref",
				"url",
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
