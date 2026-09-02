extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const CampaignProgress = preload("res://src/support/campaign_progress.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")
const TEST_PATH := "user://the_long_march_memory_test.json"

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _engine_state(seed_value: int) -> LongMarchState:
	var state := LongMarchState.new(seed_value)
	state.place_module("ash_runner_engine", Vector2i(0, 0), false, true)
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 1))
	return state


func _test_cinder_memory() -> void:
	var state := _engine_state(5501)
	state.start_cinder_spine()
	_expect(state._campaign_event_for_node("ash_chapel_bypass") == "chapel_refuge", "Ash Chapel should route into its authored meeting")
	state.campaign_event_pending = "chapel_refuge"
	var choice := state.resolve_campaign_event("light_refuge_markers")
	_expect(bool(choice.get("ok", false)) and state.shelter_tendency == 1 and state.settlement_trust == 2, "lighting the Ash Chapel should create an immediate shelter consequence")
	state.phase = "results"
	state.final_result = "spine_bypassed"
	state.run_complete = true
	state.journey_complete = true
	_expect(state.earned_regional_developments().has("cinder_refuge_chain"), "a surviving chapel choice should earn the Cinder Refuge Chain")
	var replay := _engine_state(5502)
	replay.start_cinder_spine()
	replay.set_regional_developments(["cinder_refuge_chain"])
	replay.campaign_event_pending = "charcoal_vow"
	var details := replay.campaign_event_details()
	var choice_ids: Array[String] = []
	for item in details.get("choices", []):
		choice_ids.append(String(item.get("id", "")))
	_expect("call_refuge_chain" in choice_ids, "Cinder memory should unlock a visible later event option")
	replay.campaign_pressure = 4
	_expect(bool(replay.resolve_campaign_event("call_refuge_chain").get("ok", false)) and replay.campaign_pressure == 2, "the refuge chain option should have its authored pressure effect")


func _test_salt_memory_and_persistence() -> void:
	var state := _engine_state(5503)
	state.start_white_salt_expanse()
	_expect(state._campaign_event_for_node("lee_trench") == "trench_cistern", "Lee Trench should route into its authored meeting")
	state.fuel = 4
	state.campaign_event_pending = "trench_cistern"
	_expect(bool(state.resolve_campaign_event("share_trench_water").get("ok", false)) and state.fuel == 3, "sharing Lee Trench water should spend one fuel and record the public choice")
	state.phase = "results"
	state.final_result = "expanse_crossed"
	state.run_complete = true
	state.journey_complete = true
	state.campaign_decisions["observatory_signal"] = "broadcast_beacons"
	_expect(state.earned_regional_developments() == ["salt_public_beacons", "salt_shared_cisterns"], "one surviving run should preserve both independently earned Salt developments")
	var progress := CampaignProgress.new(TEST_PATH)
	progress.clear_progress()
	for development_id in state.earned_regional_developments():
		_expect(bool(progress.unlock(development_id).get("ok", false)), "earned memory should persist through the campaign ledger")
	var restored_progress := CampaignProgress.new(TEST_PATH)
	_expect(bool(restored_progress.load_progress().get("ok", false)) and restored_progress.has_development("salt_shared_cisterns"), "shared cistern memory should survive a profile reload")
	var replay := _engine_state(5504)
	replay.start_white_salt_expanse()
	replay.set_regional_developments(restored_progress.developments)
	replay.campaign_event_pending = "observatory_signal"
	var choice_ids: Array[String] = []
	for item in replay.campaign_event_details().get("choices", []):
		choice_ids.append(String(item.get("id", "")))
	_expect("call_cistern_network" in choice_ids, "Salt memory should unlock a visible later event option")
	progress.clear_progress()


func _test_replay_goals_and_endings() -> void:
	var cinder := _engine_state(5505)
	cinder.start_cinder_spine()
	_expect(bool(cinder.choose_mastery_experiment("cinder_redundant_lift").get("ok", false)), "Cinder should expose its chapter-specific replay order")
	cinder.campaign_decisions["lift_engine_choice"] = "power_lift"
	_expect(bool(cinder.mastery_experiment_details().get("proven", false)), "the powered lift solution should prove Redundant Lift")
	var salt := _engine_state(5506)
	salt.place_module("salvage_crane", Vector2i(5, 0), true)
	salt.start_white_salt_expanse()
	_expect(bool(salt.choose_mastery_experiment("salt_dependency_watch").get("ok", false)), "Salt should expose its chapter-specific replay order")
	_expect(not bool(salt.mastery_experiment_details().get("proven", true)), "a replay order should not claim success before its route proof exists")
	salt.campaign_path.append("empty_mile")
	_expect(bool(salt.mastery_experiment_details().get("proven", false)), "a Ready Salvage Crane on Empty Mile should prove Dependency Watch through its recovery-family solution")
	var ending_state := _engine_state(5507)
	ending_state.start_cinder_spine()
	ending_state.phase = "results"
	ending_state.final_result = "spine_powered"
	ending_state.cinder_contract_status = "completed"
	ending_state.knowledge_tendency = 1
	ending_state.campaign_encounters_completed = 5
	ending_state.run_complete = true
	ending_state.journey_complete = true
	var ending := ending_state.composable_ending()
	_expect(ending.get("survival") == "secure" and ending.get("network") == "open_signal_network" and ending.get("promise") == "promise_kept", "ending facets should compose survival, regional direction, and promise state")
	var debrief := DebriefPresenter.build(ending_state, {}, {"contract_status": "completed", "result_summary": "The lift answers.", "causal_chain": "Generator held", "system_condition": "Stable"})
	_expect(Dictionary(debrief.get("ending", {})).get("title") == ending.get("title") and String(debrief.get("commitments", "")).contains("Ending facets"), "Debrief should expose the composed ending and its causal dimensions")


func _init() -> void:
	_expect(LongMarchState.CAMPAIGN_DECISION_OPTIONS.size() >= 20, "Early Access should expose at least twenty authored event or meeting decisions")
	_test_cinder_memory()
	_test_salt_memory_and_persistence()
	_test_replay_goals_and_endings()
	if failures.is_empty():
		print("PASS: The Long March campaign memory and endings")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
