#!/usr/bin/env python3
"""Verify every file in a downloaded playtest cohort against its manifest."""
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


def verify_manifest(manifest: dict[str, Any], root: Path) -> list[str]:
	errors: list[str] = []
	root = root.resolve()
	if manifest.get("schema_version") != 1:
		errors.append(f"unsupported schema_version: {manifest.get('schema_version')!r}")
	product = manifest.get("product")
	if not isinstance(product, dict) or not str(product.get("version", "")).strip():
		errors.append("manifest is missing product.version")
	files = manifest.get("files")
	if not isinstance(files, list) or not files:
		errors.append("manifest files must be a non-empty array")
		return errors
	seen_paths: set[str] = set()
	for index, entry in enumerate(files):
		if not isinstance(entry, dict):
			errors.append(f"files[{index}] must be an object")
			continue
		relative = str(entry.get("path", "")).strip()
		if not relative:
			errors.append(f"files[{index}] is missing path")
			continue
		candidate = (root / relative).resolve()
		try:
			candidate.relative_to(root)
		except ValueError:
			errors.append(f"file escapes cohort root: {relative}")
			continue
		if relative in seen_paths:
			errors.append(f"file is listed more than once: {relative}")
			continue
		seen_paths.add(relative)
		if not candidate.is_file():
			errors.append(f"missing file: {relative}")
			continue
		expected_bytes = entry.get("bytes")
		actual_bytes = candidate.stat().st_size
		if not isinstance(expected_bytes, int) or actual_bytes != expected_bytes:
			errors.append(f"size mismatch: {relative} ({actual_bytes} != {expected_bytes})")
		expected_hash = str(entry.get("sha256", "")).lower()
		actual_hash = sha256(candidate)
		if actual_hash != expected_hash:
			errors.append(f"SHA-256 mismatch: {relative}")
	return errors


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("manifest", type=Path, help="Path to artifacts/release_manifest.json")
	parser.add_argument("--root", type=Path, help="Downloaded artifact root; inferred from the manifest path by default")
	args = parser.parse_args()
	manifest_path = args.manifest.resolve()
	root = args.root.resolve() if args.root else manifest_path.parent.parent
	try:
		manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
	except (OSError, json.JSONDecodeError) as exc:
		print(f"ERROR: cannot read release manifest: {exc}")
		return 1
	if not isinstance(manifest, dict):
		print("ERROR: release manifest root must be an object")
		return 1
	errors = verify_manifest(manifest, root)
	if errors:
		for error in errors:
			print(f"ERROR: {error}")
		return 1
	product = manifest["product"]
	cohort = manifest.get("cohort", {})
	cohort_id = cohort.get("id", product["version"]) if isinstance(cohort, dict) else product["version"]
	platform = cohort.get("platform", "unspecified") if isinstance(cohort, dict) else "unspecified"
	print(f"PASS: {cohort_id} ({platform}), {len(manifest['files'])} files verified")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
