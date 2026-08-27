#!/usr/bin/env bash
set -euo pipefail

if command -v godot >/dev/null 2>&1; then
	godot --headless --path . --import
	godot --headless --path . --script res://tests/test_fortress_state.gd
	godot --headless --path . --script res://tests/test_playtest_journal.gd
	godot --headless --path . --script res://tests/test_app_shell.gd
	godot --headless --path . --script res://tests/test_prototype_flow.gd
elif command -v godot4 >/dev/null 2>&1; then
	godot4 --headless --path . --import
	godot4 --headless --path . --script res://tests/test_fortress_state.gd
	godot4 --headless --path . --script res://tests/test_playtest_journal.gd
	godot4 --headless --path . --script res://tests/test_app_shell.gd
	godot4 --headless --path . --script res://tests/test_prototype_flow.gd
else
  echo "Godot 4.x is required for headless verification but was not found." >&2
  exit 2
fi
