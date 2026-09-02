extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _staffed_state() -> LongMarchState:
	var state := LongMarchState.new(9404)
	state.place_module("ash_runner_engine", Vector2i(0, 0), false, true)
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 1))
	state.place_module("field_workshop", Vector2i(2, 2))
	state.start_cinder_spine()
	return state


func _debrief_has_consequence(state: LongMarchState) -> bool:
	var view := DebriefPresenter.build(state, {}, {"contract_status": "declined", "result_summary": "Test result", "causal_chain": "Test cause", "system_condition": ""})
	return String(view.get("commitments", "")).contains("Specialist consequence · " + state.specialist_name())


func _init() -> void:
	var file := FileAccess.open("res://content/people_promises.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text()) if file != null else null
	_expect(data is Dictionary and Array(data.get("specialists", [])).size() == 6, "people and promises content should load all specialists")
	for specialist_id in ["iven_pell", "mara_flint", "sela_vonn", "nera_quill", "orla_nine", "tomas_reed"]:
		var state := _staffed_state()
		state.specialist_id = specialist_id
		_expect(not state.specialist_campaign_summary().is_empty() and _debrief_has_consequence(state), "%s should expose an explicit mechanical consequence in Debrief" % specialist_id)

	var mara := _staffed_state()
	mara.specialist_id = "mara_flint"
	_expect(mara.mara_repair_bonus() == 1, "Mara should improve recovery while the staffed workshop is Ready")
	mara._change_module_durability("field_workshop", -3)
	_expect(mara.mara_repair_bonus() == 0 and mara.specialist_campaign_summary().contains("inactive"), "Mara's benefit and summary should respond when the workshop dependency fails")

	var orla := _staffed_state()
	_expect(bool(orla.assign_specialist("orla_nine").get("ok", false)), "Orla should join through the public assignment command")
	var long_road := orla.campaign_node_preview("long_slope")
	var baseline := _staffed_state().campaign_node_preview("long_slope")
	_expect(int(long_road.get("fuel", 0)) == int(baseline.get("fuel", 0)) - 1 and int(long_road.get("predicted_heat", 0)) == int(baseline.get("predicted_heat", 0)) + 1, "Orla's replay choice should visibly trade fuel for heat")

	var obligation_titles: Array[String] = []
	for status in ["completed", "declined", "failed"]:
		var state := _staffed_state()
		state.start_flooded_veyru()
		state.set_prior_obligations({"ashgate_lowlands": status})
		state.phase = "results"
		state.final_result = "archive_scarred"
		state.run_complete = true
		state.journey_complete = true
		state.mobility_tendency = 0
		state.shelter_tendency = 0
		state.knowledge_tendency = 0
		state.industry_tendency = 0
		obligation_titles.append(String(state.composable_ending().get("title", "")))
	_expect(obligation_titles.size() == 3 and obligation_titles[0] != obligation_titles[1] and obligation_titles[1] != obligation_titles[2] and obligation_titles[0] != obligation_titles[2], "completed, declined, and failed promises should remain distinct replay histories")
	if failures.is_empty():
		print("PASS: The Long March LM-GPT56-4 people and promises")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
