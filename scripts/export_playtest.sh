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
engine_version="$("$engine" --version | head -n 1)"
echo "Using ${engine_version}"

case "$platform" in
	windows)
		rm -f build/the-long-march-windows.exe
		;;
	macos)
		rm -f build/the-long-march-macos.zip
		;;
	all)
		rm -f build/the-long-march-windows.exe build/the-long-march-macos.zip
		;;
	*)
		echo "Usage: scripts/export_playtest.sh [windows|macos|all]" >&2
		exit 2
		;;
esac

"$engine" --headless --path . --import

export_playtest() {
	local preset="$1"
	local output="$2"
	if ! "$engine" --headless --path . --export-release "$preset" "$output"; then
		rm -f "$output"
		echo "Export failed for ${preset}. Install export templates matching ${engine_version}, then retry." >&2
		exit 3
	fi
	if [ ! -s "$output" ]; then
		echo "Export reported success but did not create ${output}." >&2
		exit 3
	fi
	local bytes
	bytes="$(wc -c < "$output" | tr -d ' ')"
	echo "Created ${output} (${bytes} bytes)"
}

case "$platform" in
	windows)
		export_playtest "Windows Desktop" "build/the-long-march-windows.exe"
		;;
	macos)
		export_playtest "macOS Playtest" "build/the-long-march-macos.zip"
		;;
	all)
		export_playtest "Windows Desktop" "build/the-long-march-windows.exe"
		export_playtest "macOS Playtest" "build/the-long-march-macos.zip"
		;;
	*)
		echo "Usage: scripts/export_playtest.sh [windows|macos|all]" >&2
		exit 2
		;;
esac
