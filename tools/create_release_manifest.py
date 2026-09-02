#!/usr/bin/env python3
"""Create a checksummed manifest for one reproducible playtest cohort."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


def sha256(path: Path) -> str:
	digest = hashlib.sha256()
	with path.open("rb") as source:
		for block in iter(lambda: source.read(1024 * 1024), b""):
			digest.update(block)
	return digest.hexdigest()


def parse_file(value: str) -> tuple[str, str]:
	role, separator, path = value.partition("=")
	if not separator or not role.strip() or not path.strip():
		raise argparse.ArgumentTypeError("files must use ROLE=PATH")
	return role.strip(), path.strip()


def build_manifest(
	root: Path,
	ci_manifest_path: Path,
	files: list[tuple[str, str]],
	commit: str,
	head_commit: str,
	ref: str,
	run_url: str,
	platform: str,
	engine_version: str,
	verification: list[str],
) -> dict[str, Any]:
	root = root.resolve()
	ci_manifest = json.loads(ci_manifest_path.read_text(encoding="utf-8"))
	entries: list[dict[str, Any]] = []
	seen_paths: set[str] = set()
	for role, requested_path in files:
		candidate = (root / requested_path).resolve()
		try:
			relative = candidate.relative_to(root).as_posix()
		except ValueError as exc:
			raise ValueError(f"artifact path escapes repository root: {requested_path}") from exc
		if relative in seen_paths:
			raise ValueError(f"artifact path listed more than once: {relative}")
		if not candidate.is_file():
			raise ValueError(f"artifact file does not exist: {relative}")
		seen_paths.add(relative)
		entries.append(
			{
				"role": role,
				"path": relative,
				"bytes": candidate.stat().st_size,
				"sha256": sha256(candidate),
			}
		)
	entries.sort(key=lambda entry: (entry["role"], entry["path"]))
	version = ci_manifest["prototype_version"]
	save_compatibility = ci_manifest["save_compatibility"]
	resolved_head = head_commit or commit
	return {
		"schema_version": 1,
		"product": {
			"slug": ci_manifest["slug"],
			"display_name": ci_manifest["display_name"],
			"version": version,
			"playtest_ready": bool(ci_manifest.get("playtest_ready", False)),
			"release_ready": bool(ci_manifest.get("release_ready", False)),
		},
		"cohort": {
			"id": f"{version}@{resolved_head[:12]}",
			"platform": platform,
		},
		"source": {
			"repository": ci_manifest["primary_repo"],
			"workflow_commit": commit,
			"head_commit": resolved_head,
			"ref": ref,
			"workflow_run_url": run_url,
		},
		"toolchain": {"godot": engine_version},
		"compatibility": {
			"save_versions": {
				"minimum": int(save_compatibility["minimum"]),
				"current": int(save_compatibility["current"]),
			},
			"offline_runtime": True,
		},
		"verification": sorted(set(verification)),
		"files": entries,
	}


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--root", type=Path, default=Path("."))
	parser.add_argument("--ci-manifest", type=Path, default=Path("tools/ci_manifest.json"))
	parser.add_argument("--output", type=Path, required=True)
	parser.add_argument("--commit", required=True)
	parser.add_argument("--head-commit", default="")
	parser.add_argument("--ref", required=True)
	parser.add_argument("--run-url", required=True)
	parser.add_argument("--platform", required=True, choices=("windows", "macos", "linux"))
	parser.add_argument("--engine-version", required=True)
	parser.add_argument("--file", action="append", type=parse_file, default=[])
	parser.add_argument("--verification", action="append", default=[])
	args = parser.parse_args()
	if not args.file:
		parser.error("at least one --file ROLE=PATH is required")
	root = args.root.resolve()
	ci_manifest_path = args.ci_manifest
	if not ci_manifest_path.is_absolute():
		ci_manifest_path = root / ci_manifest_path
	output = args.output
	if not output.is_absolute():
		output = root / output
	try:
		manifest = build_manifest(
			root,
			ci_manifest_path,
			args.file,
			args.commit,
			args.head_commit,
			args.ref,
			args.run_url,
			args.platform,
			args.engine_version,
			args.verification,
		)
	except (OSError, KeyError, json.JSONDecodeError, ValueError) as exc:
		print(f"ERROR: {exc}")
		return 1
	output.parent.mkdir(parents=True, exist_ok=True)
	output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
	print(f"playtest cohort manifest: {output}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
