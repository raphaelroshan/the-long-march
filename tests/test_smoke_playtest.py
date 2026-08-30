#!/usr/bin/env python3
from __future__ import annotations

import sys
import tempfile
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools.smoke_playtest import macos_executable, smoke_error


def main() -> int:
    assert smoke_error(0, "Godot started") == ""
    assert smoke_error(3, "") == "packaged build exited with 3"
    assert smoke_error(0, "SCRIPT ERROR: broken startup") == "packaged build reported a runtime error"
    assert smoke_error(0, "ERROR: resource failed") == "packaged build reported a runtime error"

    with tempfile.TemporaryDirectory() as directory:
        temp = Path(directory)
        archive = temp / "game.zip"
        with zipfile.ZipFile(archive, "w") as bundle:
            bundle.writestr("The Long March.app/Contents/MacOS/The Long March", "binary")
        extracted = macos_executable(archive, temp / "unpacked")
        assert extracted.name == "The Long March" and extracted.is_file()

        invalid = temp / "invalid.zip"
        with zipfile.ZipFile(invalid, "w") as bundle:
            bundle.writestr("readme.txt", "no app")
        try:
            macos_executable(invalid, temp / "invalid")
        except ValueError as exc:
            assert "no app executable" in str(exc)
        else:
            raise AssertionError("a macOS archive without an app executable should fail")

    print("PASS: The Long March packaged smoke verifier")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
