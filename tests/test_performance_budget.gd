extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _install_loadout(state: LongMarchState) -> void:
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("ammunition_lift", Vector2i(2, 1))
	state.place_module("repeater_gun", Vector2i(3, 2), true)
	state.place_module("crew_quarters", Vector2i(4, 0))
	state.seed_starter_inventory()

func _init() -> void:
	var inspection_state := LongMarchState.new(1107)
	_install_loadout(inspection_state)
	inspection_state.start_campaign()
	inspection_state.choose_guard_contract(false)
	inspection_state.choose_mastery_experiment("ashgate_quarry_adaptation")
	var before := inspection_state.serialize()
	var inspection_started := Time.get_ticks_msec()
	var doctrines := ["protect_cargo", "protect_crew", "run_hot"]
	for index in range(1800):
		inspection_state.summary()
		inspection_state.dependency_summary()
		inspection_state.campaign_route_comparison(doctrines[index % doctrines.size()])
		inspection_state.mastery_experiment_details()
	var inspection_elapsed := Time.get_ticks_msec() - inspection_started
	_expect(inspection_state.serialize() == before, "thirty-minute-equivalent inspection work must remain read-only")
	_expect(inspection_elapsed <= 12000, "1,800 representative decision inspections should stay within the 12-second headless budget; took %d ms" % inspection_elapsed)

	var replay_started := Time.get_ticks_msec()
	var reference_report: Array[String] = []
	for iteration in range(60):
		var replay := LongMarchState.new(1107)
		_install_loadout(replay)
		replay.start_campaign()
		replay.choose_guard_contract(false)
		replay.begin_campaign_route("rill_crossing", "protect_cargo")
		replay.advance_encounter(6.0)
		if iteration == 0:
			reference_report = replay.encounter_report.duplicate()
		else:
			_expect(replay.encounter_report == reference_report, "repeated performance samples must preserve deterministic reports")
	var replay_elapsed := Time.get_ticks_msec() - replay_started
	_expect(replay_elapsed <= 12000, "60 deterministic encounter replays should stay within the 12-second headless budget; took %d ms" % replay_elapsed)

	if failures.is_empty():
		print("PASS: The Long March performance budget (%d ms inspection, %d ms replay)" % [inspection_elapsed, replay_elapsed])
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
