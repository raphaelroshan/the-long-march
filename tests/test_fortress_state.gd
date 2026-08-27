extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_placement_and_shape()
	_test_mass_and_power()
	_test_travel_and_deterministic_threat()
	_test_intervention_and_recovery()
	_test_save_round_trip()
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
