#!/usr/bin/env python3
"""Reject network-capable APIs and remote URLs from packaged runtime sources."""
from __future__ import annotations

import argparse
import re
from pathlib import Path


RUNTIME_ROOTS = ("src", "scenes", "content")
NETWORK_PATTERNS = {
    "Godot HTTP client": re.compile(r"\bHTTPClient\b"),
    "Godot HTTP request": re.compile(r"\bHTTPRequest\b"),
    "WebSocket peer": re.compile(r"\bWebSocketPeer\b"),
    "ENet peer": re.compile(r"\bENetMultiplayerPeer\b"),
    "remote URL": re.compile(r"https?://", re.IGNORECASE),
}
TEXT_SUFFIXES = {".gd", ".tscn", ".tres", ".json", ".cfg"}


def runtime_files(root: Path) -> list[Path]:
    files: list[Path] = [root / "project.godot"]
    for relative_root in RUNTIME_ROOTS:
        directory = root / relative_root
        if directory.exists():
            files.extend(path for path in directory.rglob("*") if path.is_file() and path.suffix in TEXT_SUFFIXES)
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".")
    args = parser.parse_args()
    root = Path(args.repo).resolve()
    errors: list[str] = []
    checked = 0
    for path in runtime_files(root):
        if not path.is_file():
            continue
        checked += 1
        text = path.read_text(encoding="utf-8", errors="ignore")
        for label, pattern in NETWORK_PATTERNS.items():
            if pattern.search(text):
                errors.append(f"{label} found in packaged runtime source: {path.relative_to(root)}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"offline runtime boundary: PASS ({checked} files, no network APIs or remote URLs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
