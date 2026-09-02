extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []
var checkpoints := 0


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _place(state: LongMarchState, module_id: String, position: Vector2i, exterior: bool = false) -> void:
	var result := state.place_module(module_id, position, exterior)
	_expect(bool(result.get("ok", false)), "%s should install at %s: %s" % [module_id, position, String(result.get("reason", "unknown"))])


func _install_staffed_plan(state: LongMarchState, facility_id: String) -> void:
	_expect(bool(state.choose_chassis_template("salt_skimmer").get("ok", false)), "staffed plan should select the Salt Skimmer")
	_place(state, "ash_runner_engine", Vector2i(0, 0))
	_place(state, "coal_cell", Vector2i(0, 2))
	_place(state, "generator_core", Vector2i(1, 0))
	_place(state, "crew_quarters", Vector2i(3, 0))
	_place(state, facility_id, Vector2i(2, 1))
	_place(state, "signal_coil", Vector2i(4, 1))
	_place(state, "wall_lamp", Vector2i(5, 1), true)
	state.seed_starter_inventory()
	_expect(state.total_mass() == 12 and state.total_power_draw() == 4, "%s plan should leave one mass free but consume the complete four-power bus" % facility_id)
	_expect(state.operational(facility_id) and state.operational("signal_coil"), "%s and its forecast line should be Ready" % facility_id)


func _install_crane_plan(state: LongMarchState) -> void:
	_expect(bool(state.choose_chassis_template("salt_skimmer").get("ok", false)), "crane plan should select the Salt Skimmer")
	_place(state, "ash_runner_engine", Vector2i(0, 0))
	_place(state, "coal_cell", Vector2i(0, 2))
	_place(state, "generator_core", Vector2i(1, 0))
	_place(state, "shell_cannon", Vector2i(2, 2), true)
	_place(state, "salvage_crane", Vector2i(5, 0), true)
	_place(state, "signal_coil", Vector2i(4, 2))
	_place(state, "wall_lamp", Vector2i(5, 2), true)
	state.seed_starter_inventory()
	_expect(state.total_mass() == 13 and state.operational("salvage_crane"), "crane plan should fill the mass budget with a Ready recovery mount")
	_expect(state.chassis_exterior_limit() == 3, "crane plan should consume the Salt Skimmer's three-mount advantage")


func _checkpoint(state: LongMarchState, label: String) -> LongMarchState:
	var payload := state.serialize()
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(payload)
	_expect(bool(result.get("ok", false)), "%s should load from an exact checkpoint" % label)
	if bool(result.get("ok", false)):
		_expect(restored.serialize() == payload, "%s should preserve every serialized field" % label)
	checkpoints += 1
	return restored if bool(result.get("ok", false)) else state


func _resolve_event(state: LongMarchState, choice_id: String, label: String) -> LongMarchState:
	_expect(not state.campaign_event_pending.is_empty(), "%s should expose a decision" % label)
	var result := state.resolve_campaign_event(choice_id)
	_expect(bool(result.get("ok", false)), "%s should accept %s" % [label, choice_id])
	return _checkpoint(state, label)


func _contact(state: LongMarchState, node_id: String, doctrine: String = "protect_cargo", intervention: String = "shift_power", intervention_target: String = "") -> LongMarchState:
	var begun := state.begin_campaign_route(node_id, doctrine)
	_expect(bool(begun.get("ok", false)), "%s should begin: %s" % [node_id, String(begun.get("reason", "unknown"))])
	if not bool(begun.get("ok", false)):
		return state
	state = _checkpoint(state, node_id + " committed")
	if state.encounter_active and not state.encounter_intervention_used:
		var order := state.use_encounter_intervention(intervention, intervention_target)
		_expect(bool(order.get("ok", false)), "%s should accept %s" % [node_id, intervention])
	var result := state.advance_encounter(6.0)
	_expect(bool(result.get("resolved", false)) and not state.encounter_active, "%s should resolve through the normal timeline" % node_id)
	_expect(state.current_location == node_id or state.run_complete, "%s should arrive instead of retreating to %s · outcome %s · hull %d" % [node_id, state.current_location, state.encounter_outcome, state.hull_condition])
	return _checkpoint(state, node_id + " resolved")


func _run_staffed_plan(facility_id: String, specialist_id: String, seed_value: int) -> Dictionary:
	var state := LongMarchState.new(seed_value)
	_install_staffed_plan(state, facility_id)
	state.start_white_salt_expanse()
	var baseline := state.campaign_node_preview("buried_observatory", "run_hot")
	var assigned := state.assign_specialist(specialist_id)
	_expect(bool(assigned.get("ok", false)), "%s should join through a Ready %s" % [specialist_id, facility_id])
	if specialist_id == "sela_vonn":
		var accelerated := state.campaign_node_preview("buried_observatory", "run_hot")
		_expect(int(accelerated.get("days", 0)) == int(baseline.get("days", 0)) - 1, "Sela should save one day on the two-day Run Hot road")
		_expect(is_equal_approx(float(accelerated.get("risk", 0.0)), float(baseline.get("risk", 0.0)) + 0.04), "Sela should disclose the four-point risk cost")
	else:
		state.encounter_target_doctrine = "protect_cargo"
		var before := state._encounter_damage_profile("signal_hunters", "crew_quarters")
		state.specialist_id = ""
		var without_nera := state._encounter_damage_profile("signal_hunters", "crew_quarters")
		state.specialist_id = specialist_id
		_expect(int(before.get("damage", -1)) == maxi(0, int(without_nera.get("damage", 0)) - 1) and before.get("specialist_effect") == "nera_triage", "Nera should reduce an eligible Signal Hunter crew hit by exactly one")
	_expect(bool(state.choose_salt_beacon_contract(false).get("ok", false)), "staffed plan should decline the beacon escort to preserve an independent outcome")
	state = _checkpoint(state, specialist_id + " at Saltglass")
	state = _contact(state, "quiet_caravan", "run_hot" if specialist_id == "sela_vonn" else "protect_cargo")
	state = _contact(state, "windbreak", "protect_cargo", "vent_heat")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 1, "the staffed independent plan should expose one constrained Windbreak recovery action")
	state = _checkpoint(state, specialist_id + " Windbreak recovery")
	var mine_preview := state.campaign_node_preview("salt_mine", "run_hot" if specialist_id == "sela_vonn" else "protect_crew")
	_expect("Signal Hunter" in mine_preview.get("threats", []) and "Salt Storm" in mine_preview.get("threats", []), "Salt Mine should disclose the combined storm and hunter question")
	_expect("%s" % ("Command Deck" if specialist_id == "sela_vonn" else "Field Infirmary") in mine_preview.get("ready_counter_names", []), "%s plan should name its new facility in the route counters" % specialist_id)
	state = _contact(state, "salt_mine", "run_hot" if specialist_id == "sela_vonn" else "protect_crew")
	state = _contact(state, "rival_approach", "protect_cargo", "seal_compartment", "ash_runner_engine")
	state = _resolve_event(state, "race_rival", "rival terms")
	state = _contact(state, "salt_citadel", "protect_crew", "seal_compartment", "ash_runner_engine")
	_expect(state.run_complete and state.final_result == "expanse_crossed", "%s plan should complete its independent five-contact journey" % specialist_id)
	return state.serialize()


func _run_crane_plan(seed_value: int) -> Dictionary:
	var state := LongMarchState.new(seed_value)
	_install_crane_plan(state)
	state.start_white_salt_expanse()
	_expect(bool(state.choose_salt_beacon_contract(true).get("ok", false)), "crane plan should accept the beacon escort through its exposed signal line")
	state = _checkpoint(state, "crane at Saltglass")
	state = _contact(state, "buried_observatory", "protect_cargo", "seal_compartment", "shell_cannon")
	state = _resolve_event(state, "broadcast_beacons", "crane observatory signal")
	state = _contact(state, "windbreak", "protect_cargo", "seal_compartment", "shell_cannon")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 2, "the signaled crane plan should earn two Windbreak service actions")
	for module_id in ["salvage_crane", "wall_lamp"]:
		var module_index := state._module_index_by_id(module_id)
		var maximum := int(state.module_definition(module_id).get("durability", 1))
		if module_index >= 0 and int(state.modules[module_index].get("durability", 0)) < maximum and state.settlement_actions_remaining > 0:
			var module_repair := state.settlement_repair(module_id)
			_expect(bool(module_repair.get("ok", false)), "Windbreak should restore %s before the Empty Mile" % module_id)
	_expect(state.operational("salvage_crane"), "the recovered crane should be Ready before its signature road")
	var preview := state.campaign_node_preview("empty_mile", "protect_cargo")
	_expect("Bridgebreaker" in preview.get("threats", []) and "Salvage Crane" in " ".join(preview.get("counter_hints", [])) and state.operational("salvage_crane") and String(preview.get("route_effect", "")).to_lower().contains("recovers 1 durability"), "Empty Mile should disclose the Ready crane counter and post-contact recovery")
	var recovery_target := state._weakest_damaged_module_id()
	if recovery_target.is_empty():
		var generator_index := state._module_index_by_id("generator_core")
		state.modules[generator_index]["durability"] = 1
		state._recalculate()
		recovery_target = "generator_core"
	var recovery_index := state._module_index_by_id(recovery_target)
	var durability_before := int(state.modules[recovery_index].get("durability", 0))
	var money_before := state.money
	state = _checkpoint(state, "crane damaged before Empty Mile")
	state = _contact(state, "empty_mile", "protect_cargo", "shift_power")
	recovery_index = state._module_index_by_id(recovery_target)
	_expect(int(state.modules[recovery_index].get("durability", 0)) == durability_before + 1, "the Salvage Crane should restore the weakest damaged system after a cleared Empty Mile")
	_expect(state.money == money_before + 18, "a needed crane repair should keep the ordinary route reward without also granting the fallback fittings sale")
	_expect(state.log.any(func(line: String) -> bool: return line.contains("Empty Mile recovery") and line.contains(String(state.module_definition(recovery_target).get("name", recovery_target)))), "the crane repair should remain visible in the causal log")
	state = _contact(state, "rival_approach", "protect_cargo", "seal_compartment", "ash_runner_engine")
	state = _resolve_event(state, "escort_compact", "rival terms")
	state = _contact(state, "salt_citadel", "protect_cargo", "seal_compartment", "ash_runner_engine")
	_expect(state.run_complete and state.final_result in ["expanse_allied", "expanse_crossed"], "crane plan should complete its signaled five-contact journey")
	return state.serialize()


func _run() -> void:
	var command_first := _run_staffed_plan("command_deck", "sela_vonn", 7411)
	var command_replay := _run_staffed_plan("command_deck", "sela_vonn", 7411)
	_expect(command_first == command_replay, "the command-feint journey should replay exactly from the same seed and commands")
	var medical_first := _run_staffed_plan("infirmary", "nera_quill", 7412)
	var medical_replay := _run_staffed_plan("infirmary", "nera_quill", 7412)
	_expect(medical_first == medical_replay, "the medical-watch journey should replay exactly from the same seed and commands")
	var crane_first := _run_crane_plan(7413)
	var crane_replay := _run_crane_plan(7413)
	_expect(crane_first == crane_replay, "the demolition-recovery journey should replay exactly from the same seed and commands")
	_expect(checkpoints >= 48, "LM-I4 should cross at least forty-eight exact save/load boundaries")
	if failures.is_empty():
		print("PASS: The Long March LM-I4 breadth gate (%d checkpoints)" % checkpoints)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
