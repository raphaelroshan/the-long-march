#!/usr/bin/env bash
set -euo pipefail

readonly VERIFY_GROUPS="static core presentation journey regional"
SELECTION="${1:-all}"
GODOT_BIN=""
GODOT_IMPORTED=0
SLOWEST_STEP="none"
SLOWEST_SECONDS=0

usage() {
	cat <<'EOF'
Usage: bash scripts/verify.sh [all|static|core|presentation|journey|regional|--list]

Groups:
  static        Content, release, documentation, and packaging contracts
  core          Fortress state, campaign state, persistence, and hardening
  presentation  Audio, visual, presenter, shell, and tutorial contracts
  journey       Complete-journey profiles and the prototype flow
  regional      Flooded Veyru, Cinder Spine, White Salt, and breadth flows
EOF
}

if [[ "$SELECTION" == "--list" ]]; then
	for group in $VERIFY_GROUPS; do
		echo "$group"
	done
	exit 0
fi

case "$SELECTION" in
	all|static|core|presentation|journey|regional) ;;
	-h|--help) usage; exit 0 ;;
	*) echo "Unknown verification selection: $SELECTION" >&2; usage >&2; exit 2 ;;
esac

resolve_godot() {
	if [[ -n "$GODOT_BIN" ]]; then return; fi
	if command -v godot >/dev/null 2>&1; then
		GODOT_BIN="godot"
	elif command -v godot4 >/dev/null 2>&1; then
		GODOT_BIN="godot4"
	else
		echo "Godot 4.x is required for this verification group but was not found." >&2
		exit 2
	fi
}

run_checked() {
	local expected="$1"
	shift
	local output_file command_status
	output_file="$(mktemp)"
	set +e
	"$@" 2>&1 | tee "$output_file"
	command_status=${PIPESTATUS[0]}
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

run_step() {
	local group="$1" step="$2" expected="$3"
	shift 3
	local started elapsed
	started=$(date +%s)
	run_checked "$expected" "$@"
	elapsed=$(($(date +%s) - started))
	echo "VERIFY_TIMING group=$group step=$step seconds=$elapsed"
	if (( elapsed > SLOWEST_SECONDS )); then
		SLOWEST_SECONDS=$elapsed
		SLOWEST_STEP="$group/$step"
	fi
}

ensure_godot_import() {
	local group="$1"
	resolve_godot
	if (( GODOT_IMPORTED == 0 )); then
		run_step "$group" godot_import "" "$GODOT_BIN" --headless --path . --import
		GODOT_IMPORTED=1
	fi
}

run_group_static() {
	run_step static validate_versions "" python3 tools/validate_versions.py --repo .
	run_step static validate_project_skills "" python3 tools/validate_project_skills.py
	run_step static validate_flooded_veyru "" python3 tools/validate_flooded_veyru.py --data content/flooded_veyru.json
	run_step static validate_cinder_spine "" python3 tools/validate_cinder_spine.py --data content/cinder_spine.json
	run_step static validate_white_salt "" python3 tools/validate_white_salt.py --data content/white_salt_expanse.json
	run_step static validate_early_access_systems "" python3 tools/validate_early_access_systems.py --data content/early_access_systems.json
	run_step static validate_campaign_memory "" python3 tools/validate_campaign_memory.py --data content/campaign_memory.json
	run_step static validate_fortress_presentation "" python3 tools/validate_fortress_presentation.py
	run_step static validate_regional_campaign_skeleton "" python3 tools/validate_regional_campaign_skeleton.py
	run_step static validate_people_promises "" python3 tools/validate_people_promises.py
	run_step static validate_early_access_candidate "" python3 tools/validate_early_access_candidate.py
	run_step static verify_offline_boundary "" python3 tools/verify_offline_boundary.py --repo .
	run_step static test_playtest_summary "" python3 tests/test_playtest_summary.py
	run_step static test_playtest_cohort_summary "" python3 tests/test_playtest_cohort_summary.py
	run_step static test_playtest_packet_cohort "" python3 tests/test_playtest_packet_cohort.py
	run_step static test_smoke_playtest_evidence "" python3 tests/test_smoke_playtest_evidence.py
	run_step static test_release_manifest "" python3 tests/test_release_manifest.py
	run_step static test_prepare_playtest_session "" python3 tests/test_prepare_playtest_session.py
	run_step static test_finalize_playtest_session "" python3 tests/test_finalize_playtest_session.py
	run_step static test_release_publication_contract "" python3 tests/test_release_publication_contract.py
	run_step static test_release_notes "" python3 tests/test_release_notes.py
	run_step static test_readme_contract "" python3 tests/test_readme_contract.py
	run_step static test_report_output "" python3 tests/test_report_output.py
	run_step static test_smoke_playtest "" python3 tests/test_smoke_playtest.py
	run_step static test_private_alpha_contract "" python3 tests/test_private_alpha_contract.py
	run_step static test_gpt56_package_contract "" python3 tests/test_gpt56_package_contract.py
	run_step static test_verify_groups "" python3 tests/test_verify_groups.py
}

run_group_core() {
	ensure_godot_import core
	run_step core fortress_state "PASS: The Long March fortress-state tests" "$GODOT_BIN" --headless --path . --script res://tests/test_fortress_state.gd
	run_step core early_access_anchor_runs "PASS: The Long March Early Access anchor runs" "$GODOT_BIN" --headless --path . --script res://tests/test_early_access_anchor_runs.gd
	run_step core playtest_journal "PASS: The Long March local playtest journal" "$GODOT_BIN" --headless --path . --script res://tests/test_playtest_journal.gd
	run_step core campaign_progress "PASS: The Long March campaign progress" "$GODOT_BIN" --headless --path . --script res://tests/test_campaign_progress.gd
	run_step core cinder_spine "PASS: The Long March Cinder Spine chapter" "$GODOT_BIN" --headless --path . --script res://tests/test_cinder_spine.gd
	run_step core white_salt_expanse "PASS: The Long March White Salt Expanse" "$GODOT_BIN" --headless --path . --script res://tests/test_white_salt_expanse.gd
	run_step core early_access_systems "PASS: The Long March Early Access systems" "$GODOT_BIN" --headless --path . --script res://tests/test_early_access_systems.gd
	run_step core breadth_gate "PASS: The Long March LM-I4 breadth gate" "$GODOT_BIN" --headless --path . --script res://tests/test_breadth_gate.gd
	run_step core campaign_memory "PASS: The Long March campaign memory and endings" "$GODOT_BIN" --headless --path . --script res://tests/test_campaign_memory.gd
	run_step core memory_gate "PASS: The Long March LM-I5 memory gate" "$GODOT_BIN" --headless --path . --script res://tests/test_memory_gate.gd
	run_step core memory_flow "PASS: The Long March LM-I5 memory UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_memory_flow.gd
	run_step core memory_flow_1280 "PASS: The Long March LM-I5 memory UI flow 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_memory_flow.gd
	run_step core early_access_hardening "PASS: The Long March Early Access hardening" "$GODOT_BIN" --headless --path . --script res://tests/test_early_access_hardening.gd
	run_step core hardening_flow "PASS: The Long March LM-I6 candidate recovery flow" "$GODOT_BIN" --headless --path . --script res://tests/test_hardening_flow.gd
	run_step core hardening_flow_1280 "PASS: The Long March LM-I6 candidate recovery flow 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_hardening_flow.gd
}

run_group_presentation() {
	ensure_godot_import presentation
	run_step presentation interface_audio "PASS: The Long March interface audio" "$GODOT_BIN" --headless --path . --script res://tests/test_interface_audio.gd
	run_step presentation visual_contrast "PASS: The Long March visual contrast" "$GODOT_BIN" --headless --path . --script res://tests/test_visual_contrast.gd
	run_step presentation fortress_silhouette "PASS: The Long March fortress silhouette" "$GODOT_BIN" --headless --path . --script res://tests/test_fortress_silhouette.gd
	run_step presentation rendered_frame_capture "PASS: The Long March LM-GPT56-0 rendered-frame evidence gate" "$GODOT_BIN" --headless --path . --script res://tests/test_rendered_frame_capture.gd
	run_step presentation fortress_presentation_registry "PASS: The Long March LM-GPT56-2 fortress presentation registry" "$GODOT_BIN" --headless --path . --script res://tests/test_fortress_presentation_registry.gd
	run_step presentation regional_campaign_skeleton "PASS: The Long March LM-GPT56-3 regional campaign skeleton" "$GODOT_BIN" --headless --path . --script res://tests/test_regional_campaign_skeleton.gd
	run_step presentation people_promises "PASS: The Long March LM-GPT56-4 people and promises" "$GODOT_BIN" --headless --path . --script res://tests/test_people_promises.gd
	run_step presentation presentation_builders "PASS: The Long March presentation builders" "$GODOT_BIN" --headless --path . --script res://tests/test_presentation_builders.gd
	run_step presentation performance_budget "PASS: The Long March performance budget" "$GODOT_BIN" --headless --path . --script res://tests/test_performance_budget.gd
	run_step presentation road_contact_presentation "PASS: The Long March road-contact presentation" "$GODOT_BIN" --headless --path . --script res://tests/test_road_contact_presentation.gd
	run_step presentation roadside_event_presentation "PASS: The Long March roadside-event presentation" "$GODOT_BIN" --headless --path . --script res://tests/test_roadside_event_presentation.gd
	run_step presentation soot_orchard_flow "PASS: The Long March Soot Orchard road-event flow" "$GODOT_BIN" --headless --path . --script res://tests/test_soot_orchard_flow.gd
	run_step presentation recovery_panel "PASS: The Long March recovery panel" "$GODOT_BIN" --headless --path . --script res://tests/test_recovery_panel.gd
	run_step presentation controller_layout "PASS: The Long March controller layout" "$GODOT_BIN" --headless --path . --script res://tests/test_controller_layout.gd
	run_step presentation settlement_hub "PASS: The Long March settlement hub" "$GODOT_BIN" --headless --path . --script res://tests/test_settlement_hub.gd
	run_step presentation app_shell "PASS: The Long March application shell" "$GODOT_BIN" --headless --path . --script res://tests/test_app_shell.gd
	run_step presentation guided_tutorial "PASS: The Long March guided tutorial" "$GODOT_BIN" --headless --path . --script res://tests/test_guided_tutorial.gd
}

run_group_journey() {
	ensure_godot_import journey
	run_step journey complete_journey "PASS: The Long March complete journey handoff" "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey cinder_quarry "PASS: The Long March Cinder Quarry route profile" env LONG_MARCH_CINDER_QUARRY_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey declined_convoy "PASS: The Long March declined convoy consequence profile" env LONG_MARCH_DECLINED_CONVOY_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey mastery "PASS: The Long March replayable mastery profile" env LONG_MARCH_MASTERY_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey iven "PASS: The Long March Iven specialist profile" env LONG_MARCH_IVEN_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey investment "PASS: The Long March investment evaluation vertical" env LONG_MARCH_INVESTMENT_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey investment_1280 "PASS: The Long March investment evaluation vertical" env LONG_MARCH_INVESTMENT_PROFILE=1 LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey gpt56_completion "PASS: The Long March LM-GPT56-1B completion evidence contract" env LONG_MARCH_GPT56_1_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey gpt56_1280 "PASS: The Long March LM-GPT56-1 full creative journey" env LONG_MARCH_GPT56_1_PROFILE=1 LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey responsive_1280 "PASS: The Long March responsive journey profile 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey responsive_1600 "PASS: The Long March responsive journey profile 1600x900" env LONG_MARCH_VIEWPORT_WIDTH=1600 LONG_MARCH_VIEWPORT_HEIGHT=900 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_complete_journey_handoff.gd
	run_step journey prototype_flow "PASS: The Long March complete prototype flow" "$GODOT_BIN" --headless --path . --script res://tests/test_prototype_flow.gd
}

run_group_regional() {
	ensure_godot_import regional
	run_step regional veyru_flow "PASS: The Long March Flooded Veyru UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_veyru_flow.gd
	run_step regional veyru_1280 "PASS: The Long March responsive Veyru profile 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_veyru_flow.gd
	run_step regional veyru_1600 "PASS: The Long March responsive Veyru profile 1600x900" env LONG_MARCH_VIEWPORT_WIDTH=1600 LONG_MARCH_VIEWPORT_HEIGHT=900 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_veyru_flow.gd
	run_step regional cinder_flow "PASS: The Long March Cinder Spine UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_cinder_spine_flow.gd
	run_step regional cinder_1280 "PASS: The Long March responsive Cinder profile 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_cinder_spine_flow.gd
	run_step regional cinder_1600 "PASS: The Long March responsive Cinder profile 1600x900" env LONG_MARCH_VIEWPORT_WIDTH=1600 LONG_MARCH_VIEWPORT_HEIGHT=900 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_cinder_spine_flow.gd
	run_step regional white_salt_flow "PASS: The Long March White Salt UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_white_salt_flow.gd
	run_step regional white_salt_1280 "PASS: The Long March responsive White Salt profile 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_white_salt_flow.gd
	run_step regional white_salt_1600 "PASS: The Long March responsive White Salt profile 1600x900" env LONG_MARCH_VIEWPORT_WIDTH=1600 LONG_MARCH_VIEWPORT_HEIGHT=900 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_white_salt_flow.gd
	run_step regional breadth_flow "PASS: The Long March LM-I4 breadth UI flow" "$GODOT_BIN" --headless --path . --script res://tests/test_breadth_flow.gd
	run_step regional breadth_flow_1280 "PASS: The Long March LM-I4 breadth UI flow 1280x720" env LONG_MARCH_VIEWPORT_WIDTH=1280 LONG_MARCH_VIEWPORT_HEIGHT=720 LONG_MARCH_RESPONSIVE_PROFILE=1 "$GODOT_BIN" --headless --path . --script res://tests/test_breadth_flow.gd
}

run_group() {
	local group="$1" started elapsed
	started=$(date +%s)
	"run_group_$group"
	elapsed=$(($(date +%s) - started))
	echo "VERIFY_GROUP_RESULT group=$group status=PASS seconds=$elapsed"
}

started_all=$(date +%s)
if [[ "$SELECTION" == "all" ]]; then
	for group in $VERIFY_GROUPS; do
		run_group "$group"
	done
else
	run_group "$SELECTION"
fi
elapsed_all=$(($(date +%s) - started_all))
echo "VERIFY_RESULT selection=$SELECTION status=PASS seconds=$elapsed_all slowest_step=$SLOWEST_STEP slowest_seconds=$SLOWEST_SECONDS"
