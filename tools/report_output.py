#!/usr/bin/env python3
"""Create human-review reports without replacing an existing file."""
from __future__ import annotations

from pathlib import Path


def write_new_report(path: Path, content: str, label: str = "report") -> Path:
    destination = path.resolve()
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        with destination.open("x", encoding="utf-8") as output:
            output.write(content)
    except FileExistsError as exc:
        raise ValueError(f"{label} already exists and will not be overwritten: {destination}") from exc
    return destination
