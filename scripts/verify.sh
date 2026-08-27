#!/usr/bin/env bash
set -euo pipefail

if command -v godot >/dev/null 2>&1; then
  godot --headless --path . --script res://tests/test_fortress_state.gd
elif command -v godot4 >/dev/null 2>&1; then
  godot4 --headless --path . --script res://tests/test_fortress_state.gd
else
  echo "Godot 4.x is required for headless verification but was not found." >&2
  exit 2
fi
