extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []
var checkpoint_count := 0


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _checkpoint(state: RefCounted, label: String) -> RefCounted:
	var payload: Dictionary = state.serialize()
	var restored := LongMarchState.new(0)
	var result: Dictionary = restored.load_serialized(payload)
	if not bool(result.get("ok", false)):
		print("ANCHOR CHECKPOINT REJECTED · %s · %s" % [label, String(result.get("reason", "unknown reason"))])
	_expect(bool(result.get("ok", false)), "%s should restore from its exact checkpoint" % label)
	if bool(result.get("ok", false)):
		var restored_payload: Dictionary = restored.serialize()
		if restored_payload != payload:
			for key in payload:
				if restored_payload.get(key) != payload.get(key):
					print("ANCHOR CHECKPOINT DIFF · %s · %s · before=%s · after=%s" % [label, key, payload.get(key), restored_payload.get(key)])
		_expect(restored_payload == payload, "%s should preserve every serialized anchor value" % label)
	checkpoint_count += 1
	return restored if bool(result.get("ok", false)) else state


func _install_ashgate_loadout(state: RefCounted, include_wall_lamp: bool = false) -> void:
	_expect(bool(state.place_module("steam_lance_engine", Vector2i(0, 0)).get("ok", false)), "Ashgate engine should install")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "Ashgate fuel should install beside the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "Ashgate generator should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(4, 0)).get("ok", false)), "Ashgate crew quarters should install")
	_expect(bool(state.place_module("ammunition_lift", Vector2i(2, 1)).get("ok", false)), "Ashgate ammunition lift should install")
	_expect(bool(state.place_module("signal_coil", Vector2i(5, 1)).get("ok", false)), "Ashgate signal coil should install")
	_expect(bool(state.place_module("repeater_gun", Vector2i(3, 2), true).get("ok", false)), "Ashgate repeater should install")
	state.seed_starter_inventory()
	if include_wall_lamp:
		_expect(bool(state.deploy_stored_module("wall_lamp", Vector2i(5, 2)).get("ok", false)), "alternate Ashgate plan should install its exterior signal counter")


func _install_veyru_loadout(state: RefCounted) -> void:
	_expect(bool(state.place_module("steam_lance_engine", Vector2i(0, 0)).get("ok", false)), "Veyru engine should install")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "Veyru fuel should install beside the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "Veyru generator should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(2, 1)).get("ok", false)), "Veyru crew quarters should install")
	_expect(bool(state.place_module("field_workshop", Vector2i(2, 2)).get("ok", false)), "Veyru workshop should install beside crew")
	_expect(bool(state.place_module("water_condenser", Vector2i(2, 3)).get("ok", false)), "Veyru condenser should install beside the workshop")
	_expect(bool(state.place_module("parts_crate", Vector2i(4, 2)).get("ok", false)), "Veyru cargo should install beside the workshop")
	state.seed_starter_inventory()


func _resolve_pending_event(state: RefCounted, choice_id: String, label: String) -> RefCounted:
	_expect(not state.campaign_event_pending.is_empty(), "%s should expose its authored decision" % label)
	if state.campaign_event_pending.is_empty():
		return state
	state = _checkpoint(state, "%s event pending" % label)
	var result: Dictionary = state.resolve_campaign_event(choice_id)
	_expect(bool(result.get("ok", false)), "%s should accept %s" % [label, choice_id])
	return _checkpoint(state, "%s event resolved" % label)


func _resolve_contact(state: RefCounted, node_id: String, doctrine: String, intervention: String) -> RefCounted:
	var origin := String(state.current_location)
	var begun: Dictionary = state.begin_campaign_route(node_id, doctrine)
	_expect(bool(begun.get("ok", false)), "%s should be reachable from %s · %s · available %s · pressure %s/%d · fuel %d · engine %s" % [node_id, origin, String(begun.get("reason", "unknown reason")), state.campaign_available_nodes(), state.campaign_pressure_band(), state.campaign_pressure, state.fuel, state._has_engine()])
	if not bool(begun.get("ok", false)):
		return state
	_expect(state.current_location == origin and state.campaign_target_node == node_id and state.encounter_active, "%s commitment should retain the origin until contact resolves" % node_id)
	state = _checkpoint(state, "%s committed contact" % node_id)
	if state.pre_contact_occurrence_active():
		var interruption: Dictionary = state.resolve_campaign_event("carry_lift_load")
		_expect(bool(interruption.get("ok", false)), "%s pre-contact interruption should resolve through its public command" % node_id)
		state = _checkpoint(state, "%s pre-contact decision" % node_id)
	var opening: Dictionary = state.advance_encounter(1.0)
	_expect(bool(opening.get("ok", false)), "%s first contact step should advance" % node_id)
	if state.encounter_active and not state.encounter_intervention_used:
		var order: Dictionary = state.use_encounter_intervention(intervention)
		_expect(bool(order.get("ok", false)), "%s should accept the %s emergency order" % [node_id, intervention])
	var result: Dictionary = state.advance_encounter(6.0)
	_expect(bool(result.get("resolved", false)) and not state.encounter_active, "%s should resolve through normal encounter commands" % node_id)
	return _checkpoint(state, "%s resolved contact" % node_id)


func _run_ashgate_reliable_plan() -> void:
	var state := LongMarchState.new(1107)
	_install_ashgate_loadout(state)
	_expect(bool(state.start_campaign().get("ok", false)), "reliable Ashgate plan should start")
	_expect(bool(state.choose_mastery_experiment("ashgate_signal_discipline").get("ok", false)), "reliable Ashgate plan should select Signal Discipline")
	_expect(bool(state.choose_guard_contract(true).get("ok", false)), "reliable Ashgate plan should accept the convoy")
	state = _checkpoint(state, "Ashgate reliable settlement")
	state = _resolve_contact(state, "rill_crossing", "protect_cargo", "shift_power")
	state = _resolve_contact(state, "broken_relay", "protect_crew", "shift_power")
	state = _resolve_pending_event(state, "restore_relay", "Broken Relay")
	_expect(bool(state.recruit_iven_pell().get("ok", false)), "reliable Ashgate plan should recruit Iven through the public command")
	state = _checkpoint(state, "Ashgate reliable specialist")
	state = _resolve_contact(state, "morrowline_camp", "protect_cargo", "shift_power")
	_expect(state.phase == "settlement" and state.guard_contract_status == "completed", "reliable Ashgate plan should reach Morrowline with its promise kept")
	_expect(bool(state.settlement_refuel().get("ok", false)), "reliable Ashgate plan should spend one visible recovery action on fuel")
	state = _checkpoint(state, "Ashgate reliable recovery")
	state = _resolve_contact(state, "signal_causeway", "protect_crew", "shift_power")
	state = _resolve_contact(state, "meridian_pass", "protect_crew", "shift_power")
	_expect(state.phase == "results" and state.run_complete and state.campaign_encounters_completed == 5, "reliable Ashgate plan should reach a five-contact terminal result")
	_expect(state.final_result in ["decisive_march", "scarred_march"], "reliable Ashgate plan should survive without a debug shortcut")


func _run_ashgate_exposed_plan() -> void:
	var state := LongMarchState.new(1107)
	_install_ashgate_loadout(state, true)
	_expect(bool(state.start_campaign().get("ok", false)), "exposed Ashgate plan should start")
	_expect(bool(state.choose_mastery_experiment("ashgate_signal_discipline").get("ok", false)), "exposed Ashgate plan should select Signal Discipline")
	_expect(bool(state.choose_guard_contract(false).get("ok", false)), "exposed Ashgate plan should decline the convoy")
	state = _checkpoint(state, "Ashgate exposed settlement")
	state = _resolve_contact(state, "soot_orchard", "run_hot", "shift_power")
	state = _resolve_pending_event(state, "take_fuel", "Soot Orchard")
	state = _resolve_contact(state, "red_wheel_toll_bridge", "protect_cargo", "shift_power")
	state = _resolve_pending_event(state, "pay_toll", "Red Wheel")
	state = _resolve_contact(state, "morrowline_camp", "protect_cargo", "shift_power")
	state = _resolve_pending_event(state, "decline_mara", "Morrowline specialist")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 1, "exposed Ashgate plan should reach its one-action shortage")
	_expect(bool(state.settlement_repair("wall_lamp").get("ok", false)), "exposed Ashgate plan should spend its only recovery action on the signal counter")
	state = _checkpoint(state, "Ashgate exposed recovery")
	state = _resolve_contact(state, "signal_causeway", "protect_crew", "shift_power")
	state = _resolve_contact(state, "meridian_pass", "protect_crew", "shift_power")
	_expect(state.phase == "results" and state.run_complete and state.campaign_encounters_completed == 5, "exposed Ashgate plan should reach a five-contact terminal result")
	_expect(state.final_result in ["decisive_march", "scarred_march"], "exposed Ashgate plan should remain viable without Iven or the convoy")


func _run_veyru_reliable_plan() -> void:
	var state := LongMarchState.new(2204)
	_install_veyru_loadout(state)
	_expect(bool(state.start_flooded_veyru().get("ok", false)), "reliable Veyru plan should start")
	_expect(bool(state.choose_veyru_medicine_contract(true).get("ok", false)), "reliable Veyru plan should accept the medicine carrier")
	state = _checkpoint(state, "Veyru reliable settlement")
	state = _resolve_contact(state, "pump_gallery", "protect_cargo", "vent_heat")
	state = _resolve_pending_event(state, "drain_gallery", "Pump Gallery")
	state = _resolve_contact(state, "veyru_evacuation_camp", "protect_cargo", "vent_heat")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 2, "reliable Veyru plan should reach two-action carrier recovery")
	_expect(state.hull_condition == 10 and state.modules.all(func(instance: Dictionary) -> bool: return int(instance.get("durability", 0)) == int(state.module_definition(String(instance.get("id", ""))).get("durability", 0))), "reliable Veyru plan should be able to preserve both recovery actions because its systems remain whole")
	state = _checkpoint(state, "Veyru reliable recovery")
	state = _resolve_contact(state, "archive_causeway", "protect_cargo", "vent_heat")
	state = _resolve_contact(state, "dry_archive_gate", "protect_cargo", "vent_heat")
	state = _resolve_pending_event(state, "seal_archive", "Dry Archive Gate")
	state = _resolve_contact(state, "dry_archive", "protect_cargo", "vent_heat")
	_expect(state.phase == "results" and state.run_complete and state.campaign_encounters_completed == 5, "reliable Veyru plan should reach a five-contact terminal result")
	_expect(state.final_result == "archive_kept", "reliable Veyru plan should deliver its operational carrier")


func _run_veyru_salvage_plan() -> void:
	var state := LongMarchState.new(2204)
	_install_veyru_loadout(state)
	_expect(bool(state.start_flooded_veyru().get("ok", false)), "salvage Veyru plan should start")
	_expect(bool(state.choose_veyru_medicine_contract(false).get("ok", false)), "salvage Veyru plan should preserve cargo space")
	state = _checkpoint(state, "Veyru salvage settlement")
	state = _resolve_contact(state, "sunken_tramworks", "protect_crew", "vent_heat")
	state = _resolve_contact(state, "veyru_evacuation_camp", "protect_crew", "vent_heat")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 1, "salvage Veyru plan should reach its one-action recovery")
	var recovery: Dictionary = state.settlement_repair_hull()
	_expect(bool(recovery.get("ok", false)), "salvage Veyru plan should use its single service action on mass-sensitive hull damage")
	_expect(bool(state.remove_module_at(Vector2i(0, 0)).get("ok", false)), "salvage Veyru plan should store its heavy Steam Lance at recovery")
	_expect(bool(state.remove_module_at(Vector2i(4, 2)).get("ok", false)), "salvage Veyru plan should trade its spare Parts Crate for engine protection")
	_expect(bool(state.deploy_stored_module("ash_runner_engine", Vector2i(0, 0), true).get("ok", false)), "salvage Veyru plan should install a lighter Ash Runner without breaking its fuel connection")
	_expect(bool(state.deploy_stored_module("side_armor_skirt", Vector2i(1, 1)).get("ok", false)), "salvage Veyru plan should brace its fuel connection for the archive approach")
	state = _checkpoint(state, "Veyru salvage recovery")
	_expect(state.total_mass() == 14 and state.hull_condition >= 8, "salvage Veyru plan should spend its mass allowance on a protected, mobile refit")
	state = _resolve_contact(state, "archive_causeway", "protect_crew", "vent_heat")
	state = _resolve_contact(state, "dry_archive_gate", "protect_crew", "vent_heat")
	state = _resolve_pending_event(state, "seal_archive", "Dry Archive Gate")
	state = _resolve_contact(state, "dry_archive", "protect_crew", "vent_heat")
	_expect(state.phase == "results" and state.run_complete and state.campaign_encounters_completed == 5, "salvage Veyru plan should reach a five-contact terminal result · phase %s · location %s · contacts %d · result %s · hull %d · fuel %d" % [state.phase, state.current_location, state.campaign_encounters_completed, state.final_result, state.hull_condition, state.fuel])
	_expect(state.final_result == "archive_scarred" and state.veyru_contract_status == "declined", "salvage Veyru plan should survive with its distinct no-carrier result")
	_expect(String(state.campaign_decisions.get("drain_pumps", "")).is_empty() and String(state.campaign_decisions.get("archive_broadcast", "")) == "seal_archive", "salvage Veyru result should retain its alternate tram route and sealed-archive commitment")


func _init() -> void:
	_run_ashgate_reliable_plan()
	_run_ashgate_exposed_plan()
	_run_veyru_reliable_plan()
	_run_veyru_salvage_plan()
	_expect(checkpoint_count >= 30, "anchor acceptance should round-trip at least thirty authored boundaries")
	if failures.is_empty():
		print("PASS: The Long March Early Access anchor runs (%d checkpoints)" % checkpoint_count)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
