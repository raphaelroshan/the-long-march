extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_placement_and_shape()
	_test_mass_and_power()
	_test_travel_and_deterministic_threat()
	_test_intervention_and_recovery()
	_test_save_round_trip()
	_test_city_journey_and_battle()
	_test_exposed_route_and_enemy_behavior()
	_test_encounter_save_round_trip()
	if failures.is_empty():
		print("PASS: The Long March fortress-state tests")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _test_placement_and_shape() -> void:
	var state := LongMarchState.new(1107)
	var engine := state.place_module("steam_lance_engine", Vector2i(0, 0))
	_expect(engine.ok, "engine should fit at the origin")
	var overlap := state.place_module("generator_core", Vector2i(1, 0))
	_expect(not overlap.ok, "overlapping modules should be rejected")
	var outside := state.place_module("front_armor_plate", Vector2i(5, 3))
	_expect(not outside.ok, "a two-cell module should not fit beyond the grid")

func _test_mass_and_power() -> void:
	var state := LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(4, 0))
	_expect(state.total_mass() == 8, "mass should sum installed module definitions")
	_expect(state.total_power_output() == 6, "base and generator power should be available")
	_expect(state.total_power_draw() == 1, "crew quarters should draw one power")
	_expect(state.summary().power_stable, "the starter layout should have stable power")

func _test_travel_and_deterministic_threat() -> void:
	var first := LongMarchState.new(42)
	var second := LongMarchState.new(42)
	first.place_module("steam_lance_engine", Vector2i(0, 0))
	second.place_module("steam_lance_engine", Vector2i(0, 0))
	var first_travel := first.travel("safe_road")
	var second_travel := second.travel("safe_road")
	_expect(first_travel.ok and second_travel.ok, "a working engine should allow safe-road travel")
	_expect(first_travel.threat == second_travel.threat, "fixed seeds should produce the same threat forecast")
	_expect(first.day == 3 and first.fuel == 4, "travel should consume route days and fuel")

func _test_intervention_and_recovery() -> void:
	var state := LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("field_workshop", Vector2i(4, 0))
	state.place_module("parts_crate", Vector2i(0, 2))
	var threat := state.resolve_threat("burrowers")
	_expect(threat.ok, "a known threat should resolve")
	var vent := state.intervene("vent_heat")
	_expect(vent.ok, "vent heat should work with command points")
	var repaired := state.repair_module("steam_lance_engine", 1)
	_expect(repaired.ok, "a workshop should repair an installed module")
	var cut := state.intervene("cut_loose_cargo")
	_expect(cut.ok, "cut loose cargo should preserve a recovery option")

func _install_encounter_loadout(state: LongMarchState, include_signal: bool = false) -> void:
	_expect(bool(state.place_module("steam_lance_engine", Vector2i(0, 0)).get("ok", false)), "journey loadout engine should install")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "journey loadout generator should install")
	_expect(bool(state.place_module("shell_cannon", Vector2i(4, 0), true).get("ok", false)), "journey loadout cannon should install")
	_expect(bool(state.place_module("field_workshop", Vector2i(0, 1)).get("ok", false)), "journey loadout workshop should install")
	if include_signal:
		_expect(bool(state.place_module("signal_coil", Vector2i(2, 1)).get("ok", false)), "journey loadout signal should install")

func _test_city_journey_and_battle() -> void:
	var state := LongMarchState.new(1107)
	_install_encounter_loadout(state)
	var started := state.begin_journey("safe_road", "protect_cargo")
	_expect(bool(started.get("ok", false)), "safe road should begin the Ashgate-to-Morrowline journey")
	_expect(state.current_location == "rill_crossing", "safe road should place the fortress at Rill Crossing during the encounter")
	_expect(state.encounter_enemies.size() == 2, "safe road should create two Road Raider contacts")
	_expect(String(started.get("forecast", {}).get("target_class", "")).contains("cargo"), "safe road forecast should identify cargo pressure")
	var first_step := state.advance_encounter(1.0)
	_expect(not bool(first_step.get("resolved", false)), "the first encounter step should leave time to intervene")
	var intervention := state.use_encounter_intervention("shift_power")
	_expect(bool(intervention.get("ok", false)), "the Marchmaster should be able to shift power once during the encounter")
	_expect(not bool(state.use_encounter_intervention("vent_heat").get("ok", false)), "the journey encounter should allow only one intervention")
	var result := state.advance_encounter(5.0)
	_expect(bool(result.get("resolved", false)), "the safe road encounter should resolve within six steps")
	_expect(state.journey_complete, "a survived encounter should complete the first journey")
	_expect(state.current_location == "morrowline_camp", "a survived encounter should arrive at Morrowline Camp")
	_expect(String(state.encounter_outcome) in ["protected_arrival", "damaged_arrival"], "a living fortress should have an explicit arrival outcome")
	_expect(state.encounter_report.filter(func(line: String) -> bool: return line.contains("Shell Cannon")).size() > 0, "the encounter report should name the Shell Cannon behavior")

func _test_exposed_route_and_enemy_behavior() -> void:
	var state := LongMarchState.new(1107)
	_install_encounter_loadout(state, true)
	var started := state.begin_journey("exposed_shortcut", "protect_cargo")
	_expect(bool(started.get("ok", false)), "the exposed shortcut should begin a journey encounter")
	_expect(state.journey_node == "morrowline_camp", "the shortcut should skip Rill Crossing")
	var forecast := state.encounter_forecast()
	_expect(forecast.get("threat_ids", []).has("climbers"), "the exposed shortcut should forecast a Climber")
	state.advance_encounter(6.0)
	_expect(state.encounter_report.filter(func(line: String) -> bool: return line.contains("Climber")).size() > 0, "the mixed encounter report should describe Climber behavior")
	_expect(not state.encounter_active, "the exposed shortcut encounter should resolve")

func _test_encounter_save_round_trip() -> void:
	var state := LongMarchState.new(77)
	_install_encounter_loadout(state, true)
	state.begin_journey("safe_road", "protect_cargo")
	state.advance_encounter(1.0)
	var restored := LongMarchState.new(0)
	restored.load_serialized(state.serialize())
	_expect(restored.journey_node == state.journey_node, "save should preserve the current journey node")
	_expect(restored.encounter_active == state.encounter_active, "save should preserve an active encounter")
	_expect(restored.encounter_step == state.encounter_step, "save should preserve encounter step")
	_expect(restored.encounter_enemies == state.encounter_enemies, "save should preserve encounter enemy state")
	_expect(restored.encounter_report == state.encounter_report, "save should preserve the causal encounter report")

func _test_save_round_trip() -> void:
	var state := LongMarchState.new(42)
	state.money = 55
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.day = 4
	var restored := LongMarchState.new(0)
	restored.load_serialized(state.serialize())
	_expect(restored.seed == 42, "save should preserve the seed")
	_expect(restored.money == 55, "save should preserve money")
	_expect(restored.day == 4, "save should preserve the day")
	_expect(restored.modules.size() == 1, "save should preserve module instances")
