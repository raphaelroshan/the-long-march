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
	if not bool(result.get("ok", false)):
		print("CINDER CHECKPOINT REJECTED · %s · %s" % [label, String(result.get("reason", "unknown"))])
	_expect(bool(result.get("ok", false)), label + " should restore")
	if bool(result.get("ok", false)):
		_expect(restored.serialize() == payload, label + " should round-trip exactly")
	checkpoints += 1
	return restored if bool(result.get("ok", false)) else state


func _install_loadout(state: LongMarchState) -> void:
	_expect(bool(state.place_module("ash_runner_engine", Vector2i(0, 0), false, true).get("ok", false)), "Ash Runner should install horizontally")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "Coal Cell should connect to the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "Generator Core should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(2, 1)).get("ok", false)), "Crew Quarters should install")
	_expect(bool(state.place_module("ammunition_lift", Vector2i(4, 0)).get("ok", false)), "Ammunition Lift should install")
	_expect(bool(state.place_module("repeater_gun", Vector2i(5, 1), true).get("ok", false)), "Repeater Gun should connect to the ammunition lift")
	_expect(bool(state.place_module("wall_lamp", Vector2i(5, 2), true).get("ok", false)), "Wall Lamp should cover ember approaches")
	state.seed_starter_inventory()


func _contact(state: LongMarchState, node_id: String, doctrine: String = "protect_crew", intervention: String = "vent_heat") -> LongMarchState:
	var begun := state.begin_campaign_route(node_id, doctrine)
	_expect(bool(begun.get("ok", false)), "%s should begin: %s" % [node_id, String(begun.get("reason", ""))])
	if not bool(begun.get("ok", false)):
		return state
	state = _checkpoint(state, node_id + " committed")
	var first := state.advance_encounter(1.0)
	_expect(bool(first.get("ok", false)), node_id + " should advance")
	if state.encounter_active:
		_expect(bool(state.use_encounter_intervention(intervention).get("ok", false)), "%s should accept %s" % [node_id, intervention])
	var result := state.advance_encounter(6.0)
	_expect(bool(result.get("resolved", false)) and not state.encounter_active, node_id + " should resolve")
	if state.current_location != node_id:
		print("CINDER CONTACT FAILED · %s · location=%s · phase=%s · result=%s · modules=%s · report=%s" % [node_id, state.current_location, state.phase, state.final_result, state.modules, state.encounter_report])
	return _checkpoint(state, node_id + " resolved")


func _event(state: LongMarchState, choice_id: String, label: String) -> LongMarchState:
	_expect(not state.campaign_event_pending.is_empty(), label + " should be pending")
	state = _checkpoint(state, label + " pending")
	var result := state.resolve_campaign_event(choice_id)
	if not bool(result.get("ok", false)):
		print("CINDER EVENT REJECTED · %s · %s · preview=%s · modules=%s" % [label, String(result.get("reason", "unknown")), state.campaign_event_details(), state.modules])
	_expect(bool(result.get("ok", false)), "%s should accept %s" % [label, choice_id])
	return _checkpoint(state, label + " resolved")


func _fit_upper_grade(state: LongMarchState) -> void:
	_expect(bool(state.remove_module_at(Vector2i(2, 1)).get("ok", false)), "camp refit should store Crew Quarters")
	_expect(bool(state.remove_module_at(Vector2i(5, 1)).get("ok", false)), "camp refit should trade the Repeater Gun for a heavier Warden counter")
	_expect(bool(state.deploy_stored_module("shell_cannon", Vector2i(3, 2)).get("ok", false)), "camp refit should mount a Shell Cannon beside the Ammunition Lift")
	_expect(state.total_mass() == 12 and state.operational("shell_cannon"), "Cinder refit should stay below the grade penalty while retaining two distinct threat counters")


func _run_powered_plan() -> void:
	var state := LongMarchState.new(3305)
	_install_loadout(state)
	_expect(bool(state.start_cinder_spine().get("ok", false)), "powered plan should start")
	_expect(bool(state.choose_cinder_forge_contract(true).get("ok", false)), "powered plan should accept the dynamo")
	state = _checkpoint(state, "powered Blackkiln")
	state = _contact(state, "charcoal_monastery")
	state = _event(state, "bank_coals", "charcoal vow")
	state = _contact(state, "old_lift_station")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 2, "delivered dynamo should earn two Lift Station actions")
	_expect(bool(state.settlement_refuel().get("ok", false)), "powered plan should buy the fuel needed for the upper grade")
	_fit_upper_grade(state)
	state = _checkpoint(state, "powered Lift Station refit")
	state = _contact(state, "long_slope", "protect_cargo", "shift_power")
	state = _contact(state, "lift_engine_house", "protect_cargo", "shift_power")
	state = _event(state, "power_lift", "lift engine")
	state = _event(state, "share_lift_plan", "commune design")
	state = _contact(state, "switchback_commune", "protect_crew", "shift_power")
	_expect(state.phase == "results" and state.campaign_encounters_completed == 5 and state.final_result == "spine_powered", "powered plan should complete the Cinder Spine · phase %s · contacts %d · result %s · contract %s · generator %s" % [state.phase, state.campaign_encounters_completed, state.final_result, state.cinder_contract_status, state.operational("generator_core")])
	_expect(state.earned_regional_development() == "cinder_communal_lift_plan", "shared powered plan should earn the communal lift development")


func _run_bypass_plan() -> void:
	var state := LongMarchState.new(3305)
	_install_loadout(state)
	_expect(bool(state.start_cinder_spine().get("ok", false)), "bypass plan should start")
	_expect(bool(state.choose_cinder_forge_contract(false).get("ok", false)), "bypass plan should decline the dynamo")
	state = _checkpoint(state, "bypass Blackkiln")
	state = _contact(state, "red_cut")
	state = _contact(state, "old_lift_station")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 1, "declined dynamo should leave one Lift Station action")
	_expect(bool(state.settlement_refuel().get("ok", false)), "bypass plan should spend its only service action on fuel")
	_fit_upper_grade(state)
	state = _checkpoint(state, "bypass Lift Station refit")
	state = _contact(state, "long_slope", "protect_cargo", "shift_power")
	state = _contact(state, "lift_engine_house", "protect_cargo", "shift_power")
	state = _event(state, "cut_switchback", "lift bypass")
	state = _event(state, "keep_guild_pattern", "guild design")
	state = _contact(state, "switchback_commune", "protect_crew", "shift_power")
	_expect(state.phase == "results" and state.campaign_encounters_completed == 5 and state.final_result == "spine_bypassed", "bypass plan should complete through a distinct road and lift choice")
	_expect(state.mobility_tendency == 1 and state.industry_tendency == 1, "bypass result should retain its mobility and Guild commitments")


func _test_failure_forward_route() -> void:
	var state := LongMarchState.new(3305)
	_install_loadout(state)
	state.start_cinder_spine()
	state.choose_cinder_forge_contract(false)
	state.current_location = "old_lift_station"
	state.journey_node = "old_lift_station"
	state.campaign_path = ["blackkiln", "red_cut", "old_lift_station"]
	state.campaign_last_safe_node = "old_lift_station"
	state.phase = "settlement"
	state.campaign_pressure = 5
	state.campaign_retreats = 1
	_expect(state.campaign_node_closed("slag_tunnel"), "inferno should close Slag Tunnel")
	_expect(state.campaign_available_nodes().has("ash_chapel_bypass") and state.campaign_available_nodes().has("long_slope"), "inferno should open a guaranteed bypass without deleting every road")


func _init() -> void:
	_run_powered_plan()
	_run_bypass_plan()
	_test_failure_forward_route()
	_expect(checkpoints >= 30, "Cinder acceptance should cross at least thirty exact checkpoints")
	if failures.is_empty():
		print("PASS: The Long March Cinder Spine chapter (%d checkpoints)" % checkpoints)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
