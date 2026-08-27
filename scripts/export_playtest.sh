#!/usr/bin/env bash
set -euo pipefail

platform="${1:-all}"
if command -v godot >/dev/null 2>&1; then
	engine="godot"
elif command -v godot4 >/dev/null 2>&1; then
	engine="godot4"
else
	echo "Godot 4.x is required to export a playtest build." >&2
	exit 2
fi

mkdir -p build
"$engine" --headless --path . --import

case "$platform" in
	windows)
		"$engine" --headless --path . --export-release "Windows Desktop" "build/the-long-march-windows.exe"
		;;
	macos)
		"$engine" --headless --path . --export-release "macOS Playtest" "build/the-long-march-macos.zip"
		;;
	all)
		"$engine" --headless --path . --export-release "Windows Desktop" "build/the-long-march-windows.exe"
		"$engine" --headless --path . --export-release "macOS Playtest" "build/the-long-march-macos.zip"
		;;
	*)
		echo "Usage: scripts/export_playtest.sh [windows|macos|all]" >&2
		exit 2
		;;
esac
