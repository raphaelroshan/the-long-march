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
	linux)
		rm -f build/the-long-march-linux.x86_64
		;;
	all)
		rm -f build/the-long-march-windows.exe build/the-long-march-macos.zip build/the-long-march-linux.x86_64
		;;
	*)
		echo "Usage: scripts/export_playtest.sh [windows|macos|linux|all]" >&2
		exit 2
		;;
esac

if [[ "${LONG_MARCH_SKIP_IMPORT:-0}" == "1" ]]; then
	echo "Using the project import cache prepared by the caller."
else
	"$engine" --headless --path . --import
fi

export_playtest() {
	local preset="$1"
	local output="$2"
	local export_status=0
	"$engine" --headless --path . --export-release "$preset" "$output" || export_status=$?
	if [ ! -s "$output" ]; then
		rm -f "$output"
		echo "Export failed for ${preset}. Install export templates matching ${engine_version}, then retry." >&2
		exit 3
	fi
	local bytes
	bytes="$(wc -c < "$output" | tr -d ' ')"
	if [ "$export_status" -ne 0 ]; then
		echo "WARNING: ${preset} returned status ${export_status} after creating ${output}; the mandatory packaged launch smoke must validate it." >&2
	fi
	echo "Created ${output} (${bytes} bytes)"
}

case "$platform" in
	windows)
		export_playtest "Windows Desktop" "build/the-long-march-windows.exe"
		;;
	macos)
		export_playtest "macOS Playtest" "build/the-long-march-macos.zip"
		;;
	linux)
		export_playtest "Linux Playtest" "build/the-long-march-linux.x86_64"
		;;
	all)
		export_playtest "Windows Desktop" "build/the-long-march-windows.exe"
		export_playtest "macOS Playtest" "build/the-long-march-macos.zip"
		export_playtest "Linux Playtest" "build/the-long-march-linux.x86_64"
		;;
	*)
		echo "Usage: scripts/export_playtest.sh [windows|macos|linux|all]" >&2
		exit 2
		;;
esac
