extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")

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


func _install_beacon_skimmer(state: LongMarchState) -> void:
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
	_expect(String(state.dependency_status(state.module_at(Vector2i(5, 1))).get("state", "")) == "ready", "the Skimmer signal line should be Ready through its exterior Wall Lamp")


func _install_armored_skimmer(state: LongMarchState) -> void:
	_expect(bool(state.choose_chassis_template("salt_skimmer").get("ok", false)), "the armored plan should retain the alternate Salt Skimmer chassis")
	_expect(bool(state.place_module("ash_runner_engine", Vector2i(0, 0), false, true).get("ok", false)), "armored Skimmer engine should fit")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "armored Skimmer fuel should fit beside its engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "armored Skimmer generator should fit")
	_expect(bool(state.place_module("side_armor_skirt", Vector2i(2, 1)).get("ok", false)), "armored Skimmer lower-hull protection should fit around its cut-away")
	_expect(bool(state.place_module("shell_cannon", Vector2i(3, 2), true).get("ok", false)), "armored Skimmer cannon should fit without an ammunition lift")
	_expect(bool(state.place_module("signal_coil", Vector2i(5, 1)).get("ok", false)), "armored Skimmer signal should fit")
	_expect(bool(state.place_module("wall_lamp", Vector2i(5, 2), true).get("ok", false)), "armored Skimmer beacon lamp should expose the Signal Coil")
	state.seed_starter_inventory()
	_expect(state.total_mass() == 13 and state.chassis_mass_limit() == 13, "the armored Skimmer should exactly fill its lower mass ceiling")
	_expect(String(state.dependency_status(state.module_at(Vector2i(3, 2))).get("state", "")) == "strained", "the armored Skimmer should accept emergency ammunition in exchange for lower-hull protection")
	_expect(String(state.dependency_status(state.module_at(Vector2i(5, 1))).get("state", "")) == "ready" and state.operational("side_armor_skirt"), "the armored Skimmer should preserve a Ready beacon line and lower-hull brace")


func _test_chassis_tradeoff() -> void:
	var skimmer := LongMarchState.new(4410)
	var road_keep := LongMarchState.new(4410)
	_expect(bool(skimmer.choose_chassis_template("salt_skimmer").get("ok", false)), "Salt Skimmer comparison should initialize")
	_expect(skimmer.chassis_exterior_limit() == 3 and skimmer.chassis_mass_limit() == 13 and not skimmer.chassis_cell_available(Vector2i(0, 3)) and not skimmer.chassis_cell_available(Vector2i(5, 3)), "Salt Skimmer should expose three mounts by giving up one mass and both lower corners")
	_expect(road_keep.chassis_exterior_limit() == 2 and road_keep.chassis_mass_limit() == 14 and road_keep.chassis_cell_available(Vector2i(0, 3)) and road_keep.chassis_cell_available(Vector2i(5, 3)), "Road Keep should retain one more mass and both lower corners but only two exterior mounts")


func _contact(state: LongMarchState, node_id: String, doctrine: String = "protect_cargo", intervention_id: String = "shift_power", intervention_target: String = "") -> LongMarchState:
	var begun := state.begin_campaign_route(node_id, doctrine)
	_expect(bool(begun.get("ok", false)), node_id + " should begin: " + String(begun.get("reason", "")))
	if not bool(begun.get("ok", false)):
		return state
	state = _checkpoint(state, node_id + " committed")
	state.advance_encounter(1.0)
	if state.encounter_active:
		state.use_encounter_intervention(intervention_id, intervention_target)
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


func _route_view(state: LongMarchState, node_id: String) -> Dictionary:
	if node_id not in state.campaign_available_nodes():
		return {}
	return state.campaign_node_preview(node_id, "protect_cargo")


func _run_plan(loadout_id: String, accept_contract: bool, public_beacons: bool) -> Dictionary:
	var state := LongMarchState.new(4406)
	if loadout_id == "beacon_skimmer":
		_install_beacon_skimmer(state)
	else:
		_install_armored_skimmer(state)
	state.start_white_salt_expanse()
	_expect(state.can_refit(), "Saltglass Haven should expose its promised starting workbench")
	_expect(bool(state.choose_salt_beacon_contract(accept_contract).get("ok", false)), "Saltglass contract should resolve")
	state = _checkpoint(state, "Saltglass Haven")
	state = _contact(state, "buried_observatory" if public_beacons else "quiet_caravan", "protect_cargo", "shift_power" if public_beacons else "vent_heat")
	if public_beacons:
		state = _event(state, "broadcast_beacons", "observatory signal")
	state = _contact(state, "windbreak")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == (2 if accept_contract else 1) and state.can_refit(), "Windbreak should expose contract-shaped recovery capacity and its promised refit window")
	state = _checkpoint(state, "Windbreak recovery")
	var selected_upper_route := "beacon_road" if public_beacons else "empty_mile"
	var upper_preview := _route_view(state, selected_upper_route)
	_expect(not upper_preview.is_empty(), "the selected White Salt upper road should appear in the comparison")
	if loadout_id == "beacon_skimmer":
		_expect("forecasting -8pt" in upper_preview.get("risk_factors", []), "the Beacon Skimmer should reduce Beacon Road risk through its Ready signal line")
		_expect("Signal Coil" in upper_preview.get("ready_counter_names", []), "the Beacon Skimmer should name Signal Coil as a Ready salt-storm counter")
	else:
		_expect("Side Armor Skirt" in upper_preview.get("ready_counter_names", []) and "Shell Cannon" in upper_preview.get("ready_counter_names", []), "the armored Skimmer should make Empty Mile a visibly countered Bridgebreaker line")
	var previous_save := state.serialize()
	previous_save["save_version"] = LongMarchState.SAVE_VERSION - 1
	var migrated := LongMarchState.new(0)
	_expect(bool(migrated.load_serialized(previous_save).get("ok", false)) and migrated.chassis_template_id == state.chassis_template_id and migrated.current_location == "windbreak" and migrated.modules == state.modules, "the %s Windbreak checkpoint should migrate from the previous save version without changing its chassis or loadout" % loadout_id)
	state = _contact(state, selected_upper_route, "protect_cargo", "shift_power" if public_beacons else "vent_heat")
	state = _contact(state, "rival_approach", "protect_cargo", "shift_power")
	state = _event(state, "escort_compact" if accept_contract else "race_rival", "rival terms")
	state = _contact(state, "salt_citadel", "protect_cargo", "shift_power" if public_beacons else "seal_compartment", "ash_runner_engine" if not public_beacons else "")
	var expected := "expanse_allied" if accept_contract else "expanse_crossed"
	_expect(state.phase == "results" and state.campaign_encounters_completed == 5 and state.final_result == expected, "Salt plan should reach its distinct final result")
	if public_beacons:
		_expect(state.earned_regional_development() == "salt_public_beacons", "public surviving plan should earn Public Salt Beacons")
	else:
		_expect(state.operational("ash_runner_engine") and state.modules.all(func(module: Dictionary) -> bool: return not bool(module.get("sealed", false))), "the defensive plan should restore its temporarily sealed engine before evaluating final mobility")
	var debrief := DebriefPresenter.build(state, {}, {
		"contract_status": state.salt_contract_status,
		"decision_record": " → ".join(state.campaign_decisions.values()),
		"result_summary": "EXPANSE ALLIED" if state.final_result == "expanse_allied" else "EXPANSE CROSSED",
		"causal_chain": "beacon chain" if state.final_result == "expanse_allied" else "independent crossing",
		"system_condition": "",
		"replay_text": "Compare the other White Salt loadout.",
		"starting_region_results": {}
	})
	return {
		"loadout": loadout_id,
		"chassis": state.chassis_template_id,
		"path": state.campaign_path.duplicate(),
		"result": state.final_result,
		"ending": String(state.composable_ending().get("title", "")),
		"debrief_headline": String(debrief.get("headline", "")),
		"debrief_outcome": String(debrief.get("outcome_label", "")),
		"debrief_commitments": String(debrief.get("commitments", "")),
		"hull": state.hull_condition,
		"fuel": state.fuel
	}


func _run() -> void:
	_test_chassis_tradeoff()
	var allied := _run_plan("beacon_skimmer", true, true)
	var crossed := _run_plan("armored_skimmer", false, false)
	_expect(allied.get("chassis") == "salt_skimmer" and crossed.get("chassis") == "salt_skimmer", "both viable White Salt plans should preserve the alternate chassis through the final checkpoint")
	_expect(allied.get("path") != crossed.get("path") and allied.get("result") == "expanse_allied" and crossed.get("result") == "expanse_crossed", "the two viable loadouts should produce different upper roads and terminal outcomes")
	_expect(allied.get("ending") != crossed.get("ending"), "the Beacon and Armored Skimmer plans should compose different Debrief ending facets")
	_expect(allied.get("debrief_headline") == "DECISIVE" and crossed.get("debrief_headline") == "SCARRED" and String(allied.get("debrief_outcome", "")).contains("EXPANSE ALLIED") and String(crossed.get("debrief_outcome", "")).contains("EXPANSE CROSSED"), "the two viable loadouts should reach visibly different Debrief outcomes")
	_expect(String(allied.get("debrief_commitments", "")).contains("broadcast_beacons") and String(crossed.get("debrief_commitments", "")).contains("race_rival"), "each Debrief should preserve the decisions that produced its result")
	_expect(checkpoints >= 30, "Salt acceptance should cross at least thirty exact checkpoints across two complete loadout plans")
	if failures.is_empty():
		print("PASS: The Long March White Salt Expanse (%d checkpoints)" % checkpoints)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
