extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")

var failures: Array[String] = []
var checkpoints := 0


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _veyru_state(seed_value: int) -> LongMarchState:
	var state := LongMarchState.new(seed_value)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 1))
	state.place_module("field_workshop", Vector2i(2, 2))
	state.place_module("water_condenser", Vector2i(2, 3))
	state.seed_starter_inventory()
	state.start_flooded_veyru()
	return state


func _checkpoint(state: LongMarchState, label: String) -> LongMarchState:
	var payload := state.serialize()
	var restored := LongMarchState.new(0)
	var loaded := restored.load_serialized(payload)
	_expect(bool(loaded.get("ok", false)) and restored.serialize() == payload, "%s should preserve its obligation-aware checkpoint exactly" % label)
	checkpoints += 1
	return restored if bool(loaded.get("ok", false)) else state


func _contact(state: LongMarchState, node_id: String) -> LongMarchState:
	var begun := state.begin_campaign_route(node_id, "protect_cargo")
	_expect(bool(begun.get("ok", false)), "%s should begin under the inherited obligation: %s" % [node_id, String(begun.get("reason", "unknown"))])
	if not bool(begun.get("ok", false)):
		return state
	state = _checkpoint(state, node_id + " committed")
	if state.encounter_active and not state.encounter_intervention_used:
		state.use_encounter_intervention("vent_heat")
	var result := state.advance_encounter(6.0)
	_expect(bool(result.get("resolved", false)) and (state.current_location == node_id or state.run_complete), "%s should resolve without losing its causal route" % node_id)
	return _checkpoint(state, node_id + " resolved")


func _test_completed_obligation_journey() -> void:
	var state := _veyru_state(8511)
	_expect(bool(state.set_prior_obligations({"ashgate_lowlands": "completed"}).get("ok", false)), "completed Ashgate obligation should enter the Veyru run")
	var camp_preview := state.campaign_node_preview("veyru_evacuation_camp")
	_expect(String(camp_preview.get("route_effect", "")).contains("add 1 recovery action") and Dictionary(camp_preview.get("obligation_effect", {})).get("id") == "morrowline_supply_line", "the Veyru route dossier should disclose the Morrowline service consequence")
	_expect(bool(state.choose_veyru_medicine_contract(false).get("ok", false)), "the completed-obligation fixture should decline the current medicine contract so service capacity isolates prior history")
	state = _contact(state, "pump_gallery")
	state.campaign_event_pending = "drain_pumps"
	_expect(bool(state.resolve_campaign_event("drain_gallery").get("ok", false)), "Pump Gallery should resolve its drainage decision")
	state = _contact(state, "veyru_evacuation_camp")
	_expect(state.phase == "settlement" and state.settlement_actions_remaining == 2, "completed Morrowline guard should raise a declined-carrier Evacuation Camp from one to two service actions")
	_expect(state.log.any(func(line: String) -> bool: return line.contains("Morrowline's delivered parts")), "the added service action should remain in the causal road log")
	state = _contact(state, "archive_causeway")
	state = _contact(state, "dry_archive_gate")
	_expect(bool(state.resolve_campaign_event("seal_archive").get("ok", false)), "the inherited-history journey should resolve the archive commitment")
	state = _contact(state, "dry_archive")
	_expect(state.run_complete and state.final_result in ["archive_kept", "archive_scarred"], "the completed-obligation fixture should reach a terminal Veyru result")
	var debrief := DebriefPresenter.build(state, {}, {"contract_status": state.veyru_contract_status, "result_summary": "Veyru crossed.", "causal_chain": "Morrowline parts expanded recovery.", "system_condition": "", "starting_region_results": {"ashgate_lowlands": "scarred_march"}})
	_expect(String(debrief.get("commitments", "")).contains("Prior obligation") and String(debrief.get("commitments", "")).contains("Evacuation Camp service +1"), "the terminal Debrief should preserve the completed obligation's downstream effect")


func _test_declined_and_failed_routes() -> void:
	var baseline := _veyru_state(8512)
	var baseline_tram := baseline.campaign_node_preview("sunken_tramworks")
	var declined := _veyru_state(8512)
	declined.set_prior_obligations({"ashgate_lowlands": "declined"})
	var declined_tram := declined.campaign_node_preview("sunken_tramworks")
	_expect(int(declined_tram.get("pressure_gain", -1)) == int(baseline_tram.get("pressure_gain", 0)) - 1 and String(declined_tram.get("route_effect", "")).contains("unbound convoy"), "declining the guard should expose a lower-pressure Sunken Tramworks line")
	declined.choose_veyru_medicine_contract(false)
	var begun := declined.begin_campaign_route("sunken_tramworks")
	_expect(bool(begun.get("ok", false)) and declined.campaign_pressure == 0, "the Free Carters chart should apply its exact pressure reduction at commitment")

	var failed := _veyru_state(8513)
	var baseline_pump := failed.campaign_node_preview("pump_gallery")
	failed.set_prior_obligations({"ashgate_lowlands": "failed"})
	var warned_pump := failed.campaign_node_preview("pump_gallery")
	_expect(is_equal_approx(float(warned_pump.get("risk", 0.0)), float(baseline_pump.get("risk", 0.0)) - 0.06), "a failed guard should become a six-point survivor warning instead of dead progression")
	_expect(String(warned_pump.get("route_effect", "")).contains("Survivors") and "prior obligation -6pt" in warned_pump.get("risk_factors", []), "the failed-obligation risk reduction should be attributed in the route dossier")


func _test_migration_and_endings() -> void:
	var state := _veyru_state(8514)
	state.set_prior_obligations({"ashgate_lowlands": "declined"})
	var current := state.serialize()
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(current).get("ok", false)) and restored.prior_obligation_status("ashgate_lowlands") == "declined" and restored.serialize() == current, "current checkpoints should preserve prior obligations exactly")
	var previous := current.duplicate(true)
	previous["save_version"] = LongMarchState.SAVE_VERSION - 1
	previous.erase("prior_obligations")
	var migrated := LongMarchState.new(0)
	_expect(bool(migrated.load_serialized(previous).get("ok", false)) and migrated.prior_obligations.is_empty(), "version-15 checkpoints should migrate without inventing obligation history")
	var malformed := current.duplicate(true)
	malformed["prior_obligations"] = {"ashgate_lowlands": "accepted"}
	_expect(not bool(LongMarchState.new(0).load_serialized(malformed).get("ok", true)), "checkpoint validation should reject transient prior obligation states")

	var ending_titles: Array[String] = []
	for status in ["completed", "declined", "failed"]:
		var ending_state := _veyru_state(8520)
		ending_state.set_prior_obligations({"ashgate_lowlands": status})
		ending_state.phase = "results"
		ending_state.final_result = "archive_scarred"
		ending_state.run_complete = true
		ending_state.journey_complete = true
		ending_state.veyru_contract_status = "declined"
		ending_state.mobility_tendency = 0
		ending_state.shelter_tendency = 0
		ending_state.knowledge_tendency = 0
		ending_state.industry_tendency = 0
		var ending := ending_state.composable_ending()
		var title := String(ending.get("title", ""))
		if title not in ending_titles:
			ending_titles.append(title)
		_expect(String(ending.get("causes", [])[-1]).contains(status), "%s ending should cite its prior Ashgate obligation" % status)
	_expect(ending_titles.size() == 3, "completed, declined, and failed obligations should compose three distinct ending titles")


func _run() -> void:
	_test_completed_obligation_journey()
	_test_declined_and_failed_routes()
	_test_migration_and_endings()
	_expect(checkpoints >= 10, "LM-I5 should cross at least ten exact obligation-aware checkpoints")
	if failures.is_empty():
		print("PASS: The Long March LM-I5 memory gate (%d checkpoints)" % checkpoints)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
