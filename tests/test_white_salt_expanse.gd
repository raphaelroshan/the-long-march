extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []
var checkpoints := 0


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _checkpoint(state: LongMarchState, label: String) -> LongMarchState:
	var payload := state.serialize()
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(payload)
	_expect(bool(result.get("ok", false)), label + " should restore: " + String(result.get("reason", "")))
	if bool(result.get("ok", false)):
		_expect(restored.serialize() == payload, label + " should round-trip exactly")
	checkpoints += 1
	return restored if bool(result.get("ok", false)) else state


func _install_skimmer(state: LongMarchState) -> void:
	_expect(bool(state.choose_chassis_template("salt_skimmer").get("ok", false)), "Salt Skimmer should be selectable before installation")
	_expect(bool(state.place_module("ash_runner_engine", Vector2i(0, 0), false, true).get("ok", false)), "Skimmer engine should fit")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "Skimmer fuel should fit")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "Skimmer generator should fit")
	_expect(bool(state.place_module("signal_coil", Vector2i(5, 1)).get("ok", false)), "Skimmer signal should fit")
	_expect(bool(state.place_module("ammunition_lift", Vector2i(4, 0)).get("ok", false)), "Skimmer ammunition should fit")
	_expect(bool(state.place_module("shell_cannon", Vector2i(3, 2), true).get("ok", false)), "Skimmer cannon should fit")
	_expect(bool(state.place_module("wall_lamp", Vector2i(5, 2), true).get("ok", false)), "Skimmer beacon lamp should expose the Signal Coil")
	state.seed_starter_inventory()
	_expect(state.total_mass() == 13 and state.chassis_mass_limit() == 13 and state.chassis_exterior_limit() == 3, "Salt Skimmer should trade two lower corners and one mass for a third exterior mount")
	_expect(not bool(state.validate_module_placement("parts_crate", Vector2i(0, 3)).get("ok", false)), "cut-away rear corner should reject placement")


func _contact(state: LongMarchState, node_id: String, doctrine: String = "protect_cargo") -> LongMarchState:
	var begun := state.begin_campaign_route(node_id, doctrine)
	_expect(bool(begun.get("ok", false)), node_id + " should begin: " + String(begun.get("reason", "")))
	if not bool(begun.get("ok", false)):
		return state
	state = _checkpoint(state, node_id + " committed")
	state.advance_encounter(1.0)
	if state.encounter_active:
		state.use_encounter_intervention("shift_power")
	var result := state.advance_encounter(6.0)
	_expect(bool(result.get("resolved", false)) and not state.encounter_active, node_id + " should resolve")
	if state.current_location != node_id:
		print("SALT CONTACT FAILED · %s · location=%s · phase=%s · hull=%d · result=%s · report=%s" % [node_id, state.current_location, state.phase, state.hull_condition, state.final_result, state.encounter_report])
	return _checkpoint(state, node_id + " resolved")


func _event(state: LongMarchState, choice_id: String, label: String) -> LongMarchState:
	_expect(not state.campaign_event_pending.is_empty(), label + " should be pending")
	state = _checkpoint(state, label + " pending")
	var result := state.resolve_campaign_event(choice_id)
	_expect(bool(result.get("ok", false)), label + " should resolve: " + String(result.get("reason", "")))
	return _checkpoint(state, label + " resolved")


func _run_plan(accept_contract: bool, public_beacons: bool) -> void:
	var state := LongMarchState.new(4406)
	_install_skimmer(state)
	state.start_white_salt_expanse()
	_expect(state.can_refit(), "Saltglass Haven should expose its promised starting workbench")
	_expect(bool(state.choose_salt_beacon_contract(accept_contract).get("ok", false)), "Saltglass contract should resolve")
	state = _checkpoint(state, "Saltglass Haven")
	state = _contact(state, "buried_observatory" if public_beacons else "quiet_caravan")
	if public_beacons:
		state = _event(state, "broadcast_beacons", "observatory signal")
	state = _contact(state, "windbreak")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == (2 if accept_contract else 1) and state.can_refit(), "Windbreak should expose contract-shaped recovery capacity and its promised refit window")
	state = _checkpoint(state, "Windbreak recovery")
	state = _contact(state, "beacon_road" if public_beacons else "empty_mile", "run_hot" if not public_beacons else "protect_cargo")
	state = _contact(state, "rival_approach")
	state = _event(state, "escort_compact" if accept_contract else "race_rival", "rival terms")
	state = _contact(state, "salt_citadel", "protect_cargo")
	var expected := "expanse_allied" if accept_contract else "expanse_crossed"
	_expect(state.phase == "results" and state.campaign_encounters_completed == 5 and state.final_result == expected, "Salt plan should reach its distinct final result")
	if public_beacons:
		_expect(state.earned_regional_development() == "salt_public_beacons", "public surviving plan should earn Public Salt Beacons")


func _run() -> void:
	_run_plan(true, true)
	_run_plan(false, false)
	_expect(checkpoints >= 24, "Salt acceptance should cross at least twenty-four exact checkpoints")
	if failures.is_empty():
		print("PASS: The Long March White Salt Expanse (%d checkpoints)" % checkpoints)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
