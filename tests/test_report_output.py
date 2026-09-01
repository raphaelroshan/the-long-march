#!/usr/bin/env python3
from __future__ import annotations

import tempfile
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.report_output import write_new_report


def main() -> int:
    repository = Path(__file__).resolve().parents[1]
    for relative in (
        "tools/summarize_playtest_feedback.py",
        "tools/summarize_playtest_cohort.py",
        "tools/summarize_playtest_packets.py",
    ):
        source = (repository / relative).read_text(encoding="utf-8")
        assert "write_new_report" in source, f"{relative} must use create-only report output"
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        destination = root / "nested" / "session-01-automatic.md"
        created = write_new_report(destination, "first evidence\n", "session summary")
        assert created == destination.resolve()
        assert destination.read_text(encoding="utf-8") == "first evidence\n"
        try:
            write_new_report(destination, "replacement\n", "session summary")
        except ValueError as exc:
            assert "will not be overwritten" in str(exc)
        else:
            raise AssertionError("generated evidence must not overwrite an existing report")
        assert destination.read_text(encoding="utf-8") == "first evidence\n"
    print("PASS: The Long March create-only report output")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
