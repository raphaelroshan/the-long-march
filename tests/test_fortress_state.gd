extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_placement_and_shape()
	_test_rotation_reposition_and_removal()
	_test_exterior_mount_rules()
	_test_dependency_graph()
	_test_mass_and_power()
	_test_travel_and_deterministic_threat()
	_test_intervention_and_recovery()
	_test_save_round_trip()
	_test_city_journey_and_battle()
	_test_exposed_route_and_enemy_behavior()
	_test_route_doctrine_and_heat_tradeoffs()
	_test_spatial_targeting_and_causality()
	_test_settlement_and_final_march()
	_test_salvage_counter_build()
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

func _test_rotation_reposition_and_removal() -> void:
	var state := LongMarchState.new(1107)
	var placed := state.place_module("ammunition_lift", Vector2i(0, 0))
	_expect(placed.ok, "ammunition lift should place vertically")
	_expect(Vector2i(0, 1) in state.occupied_cells(state.modules[0]), "unrotated lift should occupy two vertical cells")
	var rotated := state.reposition_module_at(Vector2i(0, 0), Vector2i(1, 0), true)
	_expect(rotated.ok, "installed modules should rotate and move atomically")
	_expect(Vector2i(2, 0) in state.occupied_cells(state.modules[0]), "rotated lift should occupy two horizontal cells")
	var restored := LongMarchState.new(0)
	var load_result := restored.load_serialized(state.serialize())
	_expect(bool(load_result.get("ok", false)), "current save schema should load")
	_expect(bool(restored.modules[0].get("rotated", false)), "save data should preserve module orientation")
	_expect(Vector2i(2, 0) in restored.occupied_cells(restored.modules[0]), "restored rotation should preserve occupied cells")
	var invalid := state.reposition_module_at(Vector2i(1, 0), Vector2i(5, 3), true)
	_expect(not invalid.ok, "invalid reposition should be rejected")
	_expect(Vector2i(2, 0) in state.occupied_cells(state.modules[0]), "failed reposition should preserve the old footprint")
	state.modules[0]["durability"] = 1
	var removed := state.remove_module_at(Vector2i(2, 0))
	_expect(removed.ok and state.modules.is_empty() and state.stored_module_count("ammunition_lift") == 1, "removal should return the whole module to storage")
	var redeployed := state.deploy_stored_module("ammunition_lift", Vector2i(0, 0), false)
	_expect(redeployed.ok and int(state.modules[0].durability) == 1, "redeploying a stored module should preserve its condition")

func _test_exterior_mount_rules() -> void:
	var state := LongMarchState.new(1107)
	_expect(not state.place_module("shell_cannon", Vector2i(0, 0)).ok, "exterior modules should require an exterior mount")
	_expect(state.place_module("shell_cannon", Vector2i(0, 0), true).ok, "shell cannon should use the first exterior mount")
	_expect(state.place_module("repeater_gun", Vector2i(2, 0), true).ok, "repeater gun should use the second exterior mount")
	_expect(not state.place_module("wall_lamp", Vector2i(3, 0), true).ok, "a third exterior module should exceed mount capacity")

func _test_dependency_graph() -> void:
	var engine_state := LongMarchState.new(1107)
	engine_state.place_module("steam_lance_engine", Vector2i(0, 0))
	_expect(engine_state.dependency_status_at(Vector2i(0, 0)).state == "offline", "engine without adjacent fuel should be offline")
	engine_state.place_module("coal_cell", Vector2i(0, 1))
	_expect(engine_state.dependency_status_at(Vector2i(0, 0)).state == "ready", "adjacent Coal Cell should enable the engine")
	engine_state.reposition_module_at(Vector2i(0, 1), Vector2i(4, 3), false)
	_expect(engine_state.dependency_status_at(Vector2i(0, 0)).state == "offline", "moving fuel away should immediately break the engine connection")

	var weapon_state := LongMarchState.new(1107)
	weapon_state.place_module("generator_core", Vector2i(3, 0))
	weapon_state.place_module("shell_cannon", Vector2i(0, 1), true)
	_expect(weapon_state.dependency_status_at(Vector2i(0, 1)).state == "strained", "weapon without adjacent ammunition should use emergency rounds")
	weapon_state.place_module("ammunition_lift", Vector2i(2, 1))
	_expect(weapon_state.dependency_status_at(Vector2i(0, 1)).state == "ready", "adjacent Ammunition Lift should enable full weapon output")

	var workshop_state := LongMarchState.new(1107)
	workshop_state.place_module("generator_core", Vector2i(0, 0))
	workshop_state.place_module("field_workshop", Vector2i(2, 1))
	_expect(workshop_state.dependency_status_at(Vector2i(2, 1)).state == "offline", "workshop without adjacent crew should be offline")
	workshop_state.place_module("crew_quarters", Vector2i(2, 0))
	_expect(workshop_state.dependency_status_at(Vector2i(2, 1)).state == "strained", "crew-connected workshop without parts should provide limited repairs")
	workshop_state.place_module("parts_crate", Vector2i(4, 1))
	_expect(workshop_state.dependency_status_at(Vector2i(2, 1)).state == "ready", "adjacent parts should provide full workshop repairs")

	var signal_state := LongMarchState.new(1107)
	signal_state.place_module("generator_core", Vector2i(0, 0))
	signal_state.place_module("signal_coil", Vector2i(2, 1))
	_expect(signal_state.dependency_status_at(Vector2i(2, 1)).state == "strained", "interior signal without exterior visibility should have a broad forecast")
	signal_state.place_module("wall_lamp", Vector2i(2, 2), true)
	_expect(signal_state.dependency_status_at(Vector2i(2, 1)).state == "ready", "adjacent exterior signal should provide visibility")

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
	first.place_module("coal_cell", Vector2i(0, 1))
	second.place_module("coal_cell", Vector2i(0, 1))
	var first_travel := first.travel("safe_road")
	var second_travel := second.travel("safe_road")
	_expect(first_travel.ok and second_travel.ok, "a working engine should allow safe-road travel")
	_expect(first_travel.threat == second_travel.threat, "fixed seeds should produce the same threat forecast")
	_expect(first.day == 3 and first.fuel == 4, "travel should consume route days and fuel")

func _test_intervention_and_recovery() -> void:
	var state := LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(4, 0))
	state.place_module("field_workshop", Vector2i(4, 1))
	state.place_module("parts_crate", Vector2i(3, 1))
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
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "journey loadout fuel should install beside the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "journey loadout generator should install")
	_expect(bool(state.place_module("ammunition_lift", Vector2i(2, 1)).get("ok", false)), "journey loadout ammunition lift should install")
	_expect(bool(state.place_module("shell_cannon", Vector2i(3, 2), true).get("ok", false)), "journey loadout cannon should install beside ammunition")
	if include_signal:
		_expect(bool(state.place_module("signal_coil", Vector2i(5, 0)).get("ok", false)), "journey loadout signal should install")

func _test_city_journey_and_battle() -> void:
	var state := LongMarchState.new(1107)
	_install_encounter_loadout(state)
	_expect(state.can_refit(), "the fortress should be refittable at Ashgate before departure")
	var started := state.begin_journey("safe_road", "protect_cargo")
	_expect(bool(started.get("ok", false)), "safe road should begin the Ashgate-to-Morrowline journey")
	_expect(not state.can_refit(), "refit should lock after departure")
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
	_expect(not state.journey_complete and state.phase == "settlement", "a survived first encounter should open Morrowline recovery rather than end the run")
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

func _test_route_doctrine_and_heat_tradeoffs() -> void:
	var preview_state := LongMarchState.new(1107)
	_install_encounter_loadout(preview_state, true)
	var safe_preview := preview_state.route_preview("safe_road", "protect_cargo")
	var exposed_preview := preview_state.route_preview("exposed_shortcut", "protect_cargo")
	var hot_preview := preview_state.route_preview("exposed_shortcut", "run_hot")
	_expect(int(safe_preview.fuel) == 3, "a near-capacity fortress should pay one additional fuel")
	_expect(float(exposed_preview.risk) > float(safe_preview.risk), "the exposed route should visibly carry more risk")
	_expect(int(hot_preview.predicted_heat) == int(exposed_preview.predicted_heat) + 2, "Run Hot should add two predicted heat")
	_expect(int(hot_preview.pressure) > int(exposed_preview.pressure), "overheated travel should increase encounter pressure")

	var cargo_state := LongMarchState.new(1107)
	var hot_state := LongMarchState.new(1107)
	_install_encounter_loadout(cargo_state)
	_install_encounter_loadout(hot_state)
	cargo_state.begin_journey("exposed_shortcut", "protect_cargo")
	hot_state.begin_journey("exposed_shortcut", "run_hot")
	cargo_state.advance_encounter(1.0)
	hot_state.advance_encounter(1.0)
	_expect(int(hot_state.encounter_enemies[1].damage_taken) > int(cargo_state.encounter_enemies[1].damage_taken), "Run Hot should increase damage against a Climber")
	var heat_before := hot_state.heat
	var vent := hot_state.use_encounter_intervention("vent_heat")
	_expect(bool(vent.get("ok", false)) and hot_state.heat < heat_before, "Vent Heat should reduce current heat during an encounter")
	_expect(hot_state.vent_exposure, "Vent Heat should create a temporary exterior exposure tradeoff")
	hot_state.advance_encounter(6.0)
	_expect(not hot_state.vent_exposure, "Vent Heat exposure should clear when the encounter ends")

func _test_spatial_targeting_and_causality() -> void:
	var targeting := LongMarchState.new(1107)
	targeting.place_module("generator_core", Vector2i(0, 0))
	targeting.place_module("parts_crate", Vector2i(0, 2))
	targeting.place_module("shell_cannon", Vector2i(2, 2), true)
	targeting.encounter_target_doctrine = "run_hot"
	_expect(targeting._encounter_choose_target("road_raiders") == "parts_crate", "raiders should prioritize exposed cargo value")
	targeting.encounter_target_doctrine = "protect_cargo"
	_expect(targeting._encounter_choose_target("road_raiders") == "shell_cannon", "Protect Cargo should redirect raiders toward an exterior weapon")

	var armored := LongMarchState.new(1107)
	armored.place_module("generator_core", Vector2i(0, 0))
	armored.place_module("crew_quarters", Vector2i(2, 1))
	armored.place_module("front_armor_plate", Vector2i(2, 2))
	var crew_before := int(armored.module_at(Vector2i(2, 1)).durability)
	var armor_before := int(armored.module_at(Vector2i(2, 2)).durability)
	armored._encounter_apply_enemy_damage("siege_beast", "crew_quarters")
	_expect(int(armored.module_at(Vector2i(2, 1)).durability) == crew_before - 2, "adjacent armor should reduce Siege Beast damage by one")
	_expect(int(armored.module_at(Vector2i(2, 2)).durability) == armor_before - 1, "protecting armor should absorb one durability")

	var causal := LongMarchState.new(1107)
	causal.place_module("steam_lance_engine", Vector2i(0, 0))
	causal.place_module("coal_cell", Vector2i(0, 1))
	causal.encounter_target_doctrine = "run_hot"
	causal._encounter_apply_enemy_damage("road_raiders", "coal_cell", 1)
	_expect(causal.dependency_status_at(Vector2i(0, 0)).state == "offline", "destroyed fuel should disable its adjacent engine")
	_expect(causal.encounter_report.filter(func(line: String) -> bool: return line.contains("Dependency change") and line.contains("Steam Lance Engine")).size() > 0, "combat report should explain downstream dependency failure")

func _test_settlement_and_final_march() -> void:
	var state := LongMarchState.new(1107)
	_install_encounter_loadout(state)
	state.begin_journey("safe_road", "protect_cargo")
	state.advance_encounter(6.0)
	_expect(state.phase == "settlement" and state.current_location == "morrowline_camp", "first arrival should enter the Morrowline settlement phase")
	_expect(state.settlement_actions_remaining == 2 and state.can_refit(), "Morrowline should provide two recovery actions and allow refitting")
	for index in range(state.modules.size()):
		if String(state.modules[index].get("id", "")) == "shell_cannon":
			state.modules[index]["durability"] = 1
	var repaired := state.settlement_repair("shell_cannon")
	_expect(bool(repaired.get("ok", false)) and int(state.module_at(Vector2i(3, 2)).durability) == 3, "Morrowline should repair a selected damaged module")
	var fuel_before := state.fuel
	var refueled := state.settlement_refuel()
	_expect(bool(refueled.get("ok", false)) and state.fuel == fuel_before + 2, "Morrowline should sell two fuel")
	_expect(not bool(state.settlement_refuel().get("ok", false)), "a third settlement service should be blocked after two actions")
	var final_departure := state.begin_final_journey("protect_crew")
	_expect(bool(final_departure.get("ok", false)) and state.phase == "final_battle", "recovered fortress should depart for Meridian Pass")
	state.advance_encounter(6.0)
	_expect(state.phase == "results" and state.run_complete and state.journey_complete, "final battle should end in a run result")
	_expect(state.final_result in ["decisive_march", "scarred_march"], "a surviving fortress should complete the March")

func _test_salvage_counter_build() -> void:
	var state := LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(1, 1))
	state.place_module("side_armor_skirt", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("ammunition_lift", Vector2i(2, 1))
	state.place_module("shell_cannon", Vector2i(3, 2), true)
	var started := state.begin_journey("salvage_detour", "protect_crew")
	_expect(bool(started.get("ok", false)), "an anti-Burrower layout should enter the salvage detour")
	state.advance_encounter(1.0)
	state.use_encounter_intervention("shift_power")
	state.advance_encounter(6.0)
	_expect(state.phase == "settlement", "lower-hull armor, connected cannon, and Shift Power should provide a viable salvage-detour counter")
	_expect(int(state.module_at(Vector2i(0, 0)).durability) > 0, "the protected engine should survive the Burrower")

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
	state.seed_starter_inventory()
	state.stored_modules[0]["durability"] = 1
	var damaged_stored_id := String(state.stored_modules[0].get("id", ""))
	state.day = 4
	state.pending_route_reward = 23
	var restored := LongMarchState.new(0)
	restored.load_serialized(state.serialize())
	_expect(restored.seed == 42, "save should preserve the seed")
	_expect(restored.money == 55, "save should preserve money")
	_expect(restored.day == 4, "save should preserve the day")
	_expect(restored.modules.size() == 1, "save should preserve module instances")
	_expect(restored.pending_route_reward == 23, "save should preserve rewards that are pending successful arrival")
	_expect(restored.stored_modules.size() == state.stored_modules.size(), "save should preserve the starter inventory")
	_expect(String(restored.stored_modules[0].get("id", "")) == damaged_stored_id and int(restored.stored_modules[0].get("durability", 0)) == 1, "save should preserve stored module identity and damage")
	var future_save := state.serialize()
	future_save["save_version"] = LongMarchState.SAVE_VERSION + 1
	_expect(not bool(LongMarchState.new(0).load_serialized(future_save).get("ok", false)), "future save versions should be rejected safely")
