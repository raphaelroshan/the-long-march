#!/usr/bin/env python3
"""Launch an exported desktop build headlessly and reject startup errors."""
from __future__ import annotations

import argparse
import os
import stat
import subprocess
import tempfile
import zipfile
from pathlib import Path


def macos_executable(archive: Path, destination: Path) -> Path:
    with zipfile.ZipFile(archive) as bundle:
        bundle.extractall(destination)
    candidates = sorted(destination.glob("*.app/Contents/MacOS/*"))
    if not candidates:
        raise ValueError("macOS archive contains no app executable")
    executable = candidates[0]
    executable.chmod(executable.stat().st_mode | stat.S_IXUSR)
    return executable


def smoke_error(returncode: int, output: str) -> str:
    if returncode != 0:
        return f"packaged build exited with {returncode}"
    if "SCRIPT ERROR:" in output or "ERROR:" in output:
        return "packaged build reported a runtime error"
    return ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", required=True, choices=("windows", "macos", "linux"))
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=45)
    args = parser.parse_args()
    package = args.package.resolve()
    if not package.is_file() or package.stat().st_size == 0:
        print(f"ERROR: packaged build is missing or empty: {package}")
        return 1
    try:
        with tempfile.TemporaryDirectory(prefix="long-march-smoke-") as directory:
            smoke_root = Path(directory)
            executable = macos_executable(package, smoke_root) if args.platform == "macos" else package
            if args.platform == "linux":
                executable.chmod(executable.stat().st_mode | stat.S_IXUSR)
            environment = os.environ.copy()
            environment["LONG_MARCH_PACKAGED_SMOKE"] = "1"
            result = subprocess.run(
                [str(executable), "--headless", "--quit-after", "3"],
                cwd=smoke_root,
                env=environment,
                capture_output=True,
                text=True,
                timeout=args.timeout,
                check=False,
            )
    except (OSError, ValueError, zipfile.BadZipFile, subprocess.TimeoutExpired) as exc:
        print(f"ERROR: packaged smoke failed: {exc}")
        return 1
    output = "\n".join(part for part in (result.stdout, result.stderr) if part)
    error = smoke_error(result.returncode, output)
    if error:
        print(output)
        print(f"ERROR: {error}")
        return 1
    print(f"packaged {args.platform} smoke: PASS ({package.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
