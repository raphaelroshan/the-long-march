extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_module_capability_metadata()
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
	_test_campaign_graph_and_visibility()
	_test_campaign_contract_and_specialist()
	_test_campaign_events_and_closure()
	_test_complete_five_encounter_campaign()
	_test_campaign_recoverable_failure()
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

func _test_module_capability_metadata() -> void:
	for module_id in LongMarchState.MODULE_DEFS:
		var definition: Dictionary = LongMarchState.MODULE_DEFS[module_id]
		_expect(not String(definition.get("capability", "")).is_empty(), "every playable module should explain its implemented capability: " + String(module_id))

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
	_expect(cut.ok and cut.removed_module == "parts_crate" and state.module_count("parts_crate") == 0, "cut loose cargo should name and remove the deterministic sacrifice")

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
	_expect(bool(intervention.get("ok", false)) and intervention.priority == "weapons" and int(intervention.heat_change) == 1 and String(intervention.effect).contains("weapon output +1"), "the Marchmaster should receive the exact power and heat result from an intervention")
	_expect(state.encounter_report[-1].contains("Weapon priority") and state.encounter_report[-1].contains("heat +1"), "the lasting encounter report should preserve an emergency order's causal result")
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
	_expect(bool(vent.get("ok", false)) and hot_state.heat < heat_before and int(vent.heat_removed) == heat_before - hot_state.heat, "Vent Heat should report the exact heat removed during an encounter")
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

	var sealed_target := LongMarchState.new(1107)
	_install_encounter_loadout(sealed_target)
	sealed_target.begin_journey("safe_road", "run_hot")
	sealed_target.encounter_enemies[0]["arrived"] = true
	sealed_target.encounter_enemies[0]["target"] = "coal_cell"
	var sealed := sealed_target.use_encounter_intervention("seal_compartment", "coal_cell")
	var redirected_target := String(sealed_target.encounter_enemies[0].get("target", ""))
	var retargets: Array = sealed.get("retargets", [])
	_expect(bool(sealed.get("ok", false)) and redirected_target != "coal_cell" and not redirected_target.is_empty(), "sealing an active target should redirect the threat immediately")
	_expect(retargets.size() == 1 and String(retargets[0].get("target", "")) == redirected_target and String(sealed.get("effect", "")).contains("redirected"), "the emergency-order receipt should name the immediate retarget")
	var redirected_preview := sealed_target.encounter_enemy_impact_preview(sealed_target.encounter_enemies[0])
	_expect(String(redirected_preview.get("target", "")) == redirected_target, "the impact forecast should update to the replacement target without requiring another combat step")
	_expect(sealed_target.encounter_report.filter(func(line: String) -> bool: return line.contains("redirects to")).size() == 1, "the lasting combat report should preserve why the enemy target changed")

	var armored := LongMarchState.new(1107)
	armored.place_module("generator_core", Vector2i(0, 0))
	armored.place_module("crew_quarters", Vector2i(2, 1))
	armored.place_module("front_armor_plate", Vector2i(2, 2))
	var crew_before := int(armored.module_at(Vector2i(2, 1)).durability)
	var armor_before := int(armored.module_at(Vector2i(2, 2)).durability)
	var impact_preview := armored.encounter_enemy_impact_preview({"id": "siege_beast", "arrived": true, "defeated": false, "target": "crew_quarters", "damage_bonus": 0})
	_expect(int(impact_preview.get("damage", -1)) == 2 and int(impact_preview.get("armor_absorbed", -1)) == 1 and int(impact_preview.get("remaining_durability", -1)) == crew_before - 2, "the impact preview should include armor mitigation and match the target durability consequence")
	_expect(String(impact_preview.get("armor_id", "")) == "front_armor_plate" and int(impact_preview.get("armor_current_durability", -1)) == armor_before and int(impact_preview.get("armor_remaining_durability", -1)) == armor_before - 1, "the impact preview should identify the absorbing plate and its resulting durability")
	armored._encounter_apply_enemy_damage("siege_beast", "crew_quarters")
	_expect(int(armored.module_at(Vector2i(2, 1)).durability) == crew_before - 2, "adjacent armor should reduce Siege Beast damage by one")
	_expect(int(armored.module_at(Vector2i(2, 2)).durability) == armor_before - 1, "protecting armor should absorb one durability")

	var causal := LongMarchState.new(1107)
	causal.place_module("steam_lance_engine", Vector2i(0, 0))
	causal.place_module("coal_cell", Vector2i(0, 1))
	causal.encounter_target_doctrine = "run_hot"
	var causal_preview := causal.encounter_enemy_impact_preview({"id": "road_raiders", "arrived": true, "defeated": false, "target": "coal_cell", "damage_bonus": 1})
	var predicted_changes: Array = causal_preview.get("dependency_changes", [])
	_expect(predicted_changes.size() == 1 and String(predicted_changes[0].get("module_id", "")) == "steam_lance_engine" and String(predicted_changes[0].get("to", "")) == "offline", "a disabling fuel hit should preview the downstream engine failure")
	_expect(causal.dependency_status_at(Vector2i(0, 0)).state == "ready" and int(causal.module_at(Vector2i(0, 1)).durability) == 2, "dependency impact previews must not mutate live fortress state")
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

func _install_campaign_signal_loadout(state: LongMarchState) -> void:
	_expect(bool(state.place_module("steam_lance_engine", Vector2i(0, 0)).get("ok", false)), "campaign engine should install")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "campaign fuel should install beside the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "campaign generator should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(4, 0)).get("ok", false)), "campaign crew quarters should install")
	_expect(bool(state.place_module("ammunition_lift", Vector2i(2, 1)).get("ok", false)), "campaign ammunition lift should install")
	_expect(bool(state.place_module("signal_coil", Vector2i(5, 1)).get("ok", false)), "campaign signal coil should install")
	_expect(bool(state.place_module("repeater_gun", Vector2i(3, 2), true).get("ok", false)), "campaign repeater should install")
	state.seed_starter_inventory()

func _campaign_battle(state: LongMarchState, node_id: String, doctrine: String = "protect_crew") -> Dictionary:
	var begun := state.begin_campaign_route(node_id, doctrine)
	if not bool(begun.get("ok", false)):
		return begun
	state.advance_encounter(1.0)
	state.use_encounter_intervention("shift_power")
	return state.advance_encounter(6.0)

func _test_campaign_graph_and_visibility() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	_expect(state.guard_contract_status == "offered", "Ashgate should present the first guard contract")
	_expect(state.campaign_available_nodes() == ["rill_crossing", "soot_orchard"], "the authored map should begin with two forward nodes")
	var preview := state.campaign_node_preview("red_wheel_toll_bridge", "protect_cargo")
	_expect(String(preview.visibility) == "unscouted" and preview.get("threats", []).is_empty(), "a strained signal should leave an unscouted branch's exact threats hidden")
	_expect("baseline 36%" not in preview.get("risk_factors", []) and "heavy fortress +5pt, +1 fuel" not in preview.get("risk_factors", []), "an unscouted route should not leak its baseline risk and should only expose modifiers that actually apply")
	state.choose_guard_contract(false)
	var first := _campaign_battle(state, "rill_crossing")
	_expect(bool(first.get("resolved", false)) and state.phase == "map", "securing Rill Crossing should return to the campaign map")
	_expect(state.campaign_encounters_completed == 1 and state.campaign_path.has("rill_crossing"), "the campaign should count and record secured nodes")
	_expect(state.campaign_available_nodes() == ["broken_relay", "red_wheel_toll_bridge"], "Rill Crossing should branch toward the relay or toll bridge")

func _test_campaign_contract_and_specialist() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	var contract_result := state.choose_guard_contract(true)
	_expect(bool(contract_result.get("ok", false)), "the Morrowline guard contract should be accepted at Ashgate")
	_expect(String(contract_result.get("message", "")).contains("each enemy") and String(contract_result.get("message", "")).contains("30 Ashmarks") and String(contract_result.get("message", "")).contains("2 trust"), "accepting the contract should return a complete consequence receipt")
	_campaign_battle(state, "rill_crossing", "protect_cargo")
	_campaign_battle(state, "broken_relay")
	_expect(state.campaign_event_pending == "lost_signal", "the Broken Relay should require an authored local decision")
	_expect(bool(state.resolve_campaign_event("restore_relay").get("ok", false)), "an operational signal should restore the relay")
	_expect(bool(state.recruit_iven_pell().get("ok", false)), "Iven Pell should join a fortress with crew quarters after the relay is restored")
	var preview := state.campaign_node_preview("signal_causeway")
	_expect(String(preview.visibility) == "known" and not preview.get("threats", []).is_empty(), "Iven should reveal exact immediate-node threats")
	var restored := LongMarchState.new(0)
	restored.load_serialized(state.serialize())
	_expect(restored.specialist_id == "iven_pell" and restored.guard_contract_status == "accepted", "save/load should preserve the specialist and contract")
	_expect(restored.campaign_path == state.campaign_path and restored.campaign_pressure == state.campaign_pressure, "save/load should preserve the campaign map state")

func _test_campaign_events_and_closure() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	_expect(bool(state.deploy_stored_module("wall_lamp", Vector2i(5, 2)).get("ok", false)), "the alternate branch loadout should connect an exterior signal lamp")
	state.start_campaign()
	state.choose_guard_contract(false)
	var orchard_result := _campaign_battle(state, "soot_orchard")
	_expect(bool(orchard_result.get("resolved", false)) and state.campaign_event_pending == "salvage_choice", "the Soot Orchard branch should be viable and open its local decision")
	var orchard := state.campaign_event_details()
	_expect(not bool(orchard.choices[1].enabled), "rescuing orchard workers should require an operational refuge module")
	_expect(String(orchard.choices[0].effect) == "Fuel +2 · Trust -1" and String(orchard.choices[1].effect).contains("Pressure +1"), "orchard choices should expose their complete resource trade-offs before selection")
	var fuel_before := state.fuel
	_expect(bool(state.resolve_campaign_event("take_fuel").get("ok", false)) and state.fuel == fuel_before + 2, "the orchard fuel choice should grant two fuel")

	var toll_result := _campaign_battle(state, "red_wheel_toll_bridge", "protect_cargo")
	_expect(bool(toll_result.get("resolved", false)) and state.campaign_event_pending == "toll_decision", "the Red Wheel branch should be viable and open its toll decision")
	var pressure_before := state.campaign_pressure
	var money_before := state.money
	var toll := state.campaign_event_details()
	_expect(String(toll.choices[0].effect).contains("Ashmarks -10") and String(toll.choices[1].effect).contains("Ashmarks +8"), "toll choices should expose both economic outcomes before selection")
	_expect(bool(state.resolve_campaign_event("break_blockade").get("ok", false)), "the fortress should be able to break the Red Wheel toll post")
	_expect(state.money == money_before + 8 and state.campaign_pressure == pressure_before + 1, "breaking the toll should recover coin and increase closure pressure")
	var morrowline_result := _campaign_battle(state, "morrowline_camp")
	_expect(bool(morrowline_result.get("resolved", false)) and state.phase == "settlement", "the Soot Orchard and Red Wheel path should reach Morrowline after three encounters")

	var refuge_state := LongMarchState.new(1107)
	refuge_state.place_module("refugee_bunk", Vector2i(0, 0))
	refuge_state.start_campaign()
	refuge_state.choose_guard_contract(false)
	refuge_state.campaign_event_pending = "salvage_choice"
	var rescue_day := refuge_state.day
	_expect(bool(refuge_state.campaign_event_details().choices[1].enabled), "an operational refuge module should enable the orchard rescue")
	_expect(bool(refuge_state.resolve_campaign_event("rescue_workers").get("ok", false)), "the orchard workers should be rescuable when refuge space is operational")
	_expect(refuge_state.workers_rescued and refuge_state.day == rescue_day + 1 and refuge_state.settlement_trust == 2, "worker rescue should persist and cost a day while raising trust")

	var toll_state := LongMarchState.new(1107)
	toll_state.start_campaign()
	toll_state.choose_guard_contract(false)
	toll_state.campaign_event_pending = "toll_decision"
	toll_state.money = 14
	toll_state.campaign_pressure = 4
	_expect(bool(toll_state.resolve_campaign_event("pay_toll").get("ok", false)), "the Red Wheel toll should accept payment when the fortress can afford it")
	_expect(toll_state.money == 4 and toll_state.campaign_pressure == 3, "paying the toll should cost 10 Ashmarks and reduce closure pressure")

	state.current_location = "morrowline_camp"
	state.phase = "settlement"
	state.campaign_pressure = 5
	_expect(state.campaign_node_closed("signal_causeway"), "Signal Causeway should close at Break pressure without reliable forecasting")
	_expect(state.campaign_available_nodes() == ["lower_ash_road"], "closure pressure must leave the Lower Ash Road recovery route available")
	state.specialist_id = "iven_pell"
	_expect(not state.campaign_node_closed("signal_causeway"), "Iven should keep the Signal Causeway readable at Break pressure")
	_expect(state.campaign_available_nodes() == ["lower_ash_road", "signal_causeway"], "reliable forecasting should restore both Morrowline departures")

func _test_complete_five_encounter_campaign() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	state.choose_guard_contract(true)
	_campaign_battle(state, "rill_crossing", "protect_cargo")
	_campaign_battle(state, "broken_relay")
	state.resolve_campaign_event("restore_relay")
	state.recruit_iven_pell()
	_campaign_battle(state, "morrowline_camp", "protect_cargo")
	_expect(state.phase == "settlement" and state.guard_contract_status == "completed", "surviving the third encounter should complete the guard contract at Morrowline")
	state.settlement_refuel()
	state.remove_module_at(Vector2i(3, 2))
	state.remove_module_at(Vector2i(5, 1))
	_expect(bool(state.deploy_stored_module("shell_cannon", Vector2i(3, 2), false).get("ok", false)), "Morrowline refit should replace the repeater and signal coil with a shell cannon")
	var fourth := _campaign_battle(state, "signal_causeway")
	_expect(bool(fourth.get("resolved", false)) and state.phase == "map", "Iven and the refitted fortress should secure the Signal Causeway")
	var fifth := _campaign_battle(state, "meridian_pass")
	_expect(bool(fifth.get("resolved", false)) and state.phase == "results", "the fifth campaign encounter should resolve at Meridian Pass")
	_expect(state.campaign_encounters_completed == 5 and state.run_complete, "the alpha chapter should complete exactly five encounters")
	_expect(state.final_result in ["decisive_march", "scarred_march"], "a surviving five-encounter campaign should produce a final result")

func _test_campaign_recoverable_failure() -> void:
	var state := LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.start_campaign()
	state.choose_guard_contract(false)
	state.money = 4
	state.begin_campaign_route("rill_crossing", "protect_crew")
	var retreat := state.advance_encounter(6.0)
	_expect(state.phase == "refit" and state.current_location == "ashgate_depot", "an early route failure should retreat to Ashgate instead of ending the run")
	_expect(state.campaign_retreats == 1 and state.campaign_pressure >= 2, "retreat should be recorded and advance closure pressure")
	_expect(state.operational("steam_lance_engine") and state.fuel >= 2 and state.hull_condition >= 3, "the road crew should restore a viable limping recovery state")
	var receipt: Dictionary = retreat.get("retreat", {})
	_expect(int(receipt.get("day_added", 0)) == 1 and int(receipt.get("pressure_added", 0)) == 2, "the retreat receipt should report its exact time and closure-pressure penalties")
	_expect(int(receipt.get("ashmarks_lost", -1)) == 4 and state.money == 0, "the retreat receipt should report a partial charge when fewer than 10 Ashmarks remain")
	_expect(int(receipt.get("hull_after", 0)) == state.hull_condition and int(receipt.get("fuel_after", 0)) == state.fuel, "the retreat receipt should match the recovered hull and fuel state")
	_expect(not Array(receipt.get("system_repairs", [])).is_empty(), "the retreat receipt should name the disabled mobility system restored by the road crew")
	var report: Array = retreat.get("report", [])
	var final_line := String(report.back()) if not report.is_empty() else ""
	_expect(final_line.contains("Ashmarks -%d" % int(receipt.get("ashmarks_lost", -1))) and final_line.contains("hull %d→%d" % [int(receipt.get("hull_before", -1)), int(receipt.get("hull_after", -1))]), "the visible retreat report should be generated from the structured receipt")
