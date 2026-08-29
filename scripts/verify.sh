#!/usr/bin/env bash
set -euo pipefail

if command -v godot >/dev/null 2>&1; then
	GODOT_BIN="godot"
elif command -v godot4 >/dev/null 2>&1; then
	GODOT_BIN="godot4"
else
  echo "Godot 4.x is required for headless verification but was not found." >&2
  exit 2
fi

run_checked() {
	local expected="$1"
	shift
	local output_file
	output_file="$(mktemp)"
	set +e
	"$@" 2>&1 | tee "$output_file"
	local command_status=${PIPESTATUS[0]}
	set -e
	if [[ $command_status -ne 0 ]] || grep -Eq 'SCRIPT ERROR:|(^| )ERROR:' "$output_file"; then
		rm -f "$output_file"
		return 1
	fi
	if [[ -n "$expected" ]] && ! grep -Fq "$expected" "$output_file"; then
		echo "Expected test marker was not produced: $expected" >&2
		rm -f "$output_file"
		return 1
	fi
	rm -f "$output_file"
}

python3 tools/validate_versions.py --repo .
python3 tools/validate_flooded_veyru.py --data content/flooded_veyru.json
run_checked "" "$GODOT_BIN" --headless --path . --import
run_checked "PASS: The Long March fortress-state tests" "$GODOT_BIN" --headless --path . --script res://tests/test_fortress_state.gd
run_checked "PASS: The Long March local playtest journal" "$GODOT_BIN" --headless --path . --script res://tests/test_playtest_journal.gd
run_checked "PASS: The Long March campaign progress" "$GODOT_BIN" --headless --path . --script res://tests/test_campaign_progress.gd
run_checked "PASS: The Long March interface audio" "$GODOT_BIN" --headless --path . --script res://tests/test_interface_audio.gd
run_checked "PASS: The Long March visual contrast" "$GODOT_BIN" --headless --path . --script res://tests/test_visual_contrast.gd
run_checked "PASS: The Long March fortress silhouette" "$GODOT_BIN" --headless --path . --script res://tests/test_fortress_silhouette.gd
run_checked "PASS: The Long March controller layout" "$GODOT_BIN" --headless --path . --script res://tests/test_controller_layout.gd
run_checked "PASS: The Long March settlement hub" "$GODOT_BIN" --headless --path . --script res://tests/test_settlement_hub.gd
run_checked "PASS: The Long March application shell" "$GODOT_BIN" --headless --path . --script res://tests/test_app_shell.gd
run_checked "PASS: The Long March guided tutorial" "$GODOT_BIN" --headless --path . --script res://tests/test_guided_tutorial.gd
run_checked "PASS: The Long March complete prototype flow" "$GODOT_BIN" --headless --path . --script res://tests/test_prototype_flow.gd
run_checked "PASS: The Long March Flooded Veyru UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_veyru_flow.gd
