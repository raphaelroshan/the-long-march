extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_module_capability_metadata()
	_test_placement_and_shape()
	_test_rotation_reposition_and_removal()
	_test_exterior_mount_rules()
	_test_dependency_graph()
	_test_water_condenser_foundation()
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
	_test_mastery_experiments()
	_test_morrowline_parts_shortage()
	_test_campaign_events_and_closure()
	_test_water_condenser_route_unlock()
	_test_water_condenser_threat_and_recovery()
	_test_cinder_quarry_route_branch()
	_test_mara_flint_event_chain()
	_test_bounded_occurrence_scheduler()
	_test_flooded_veyru_region_state()
	_test_flooded_veyru_threats_and_contract()
	_test_veyru_public_archive_signal()
	_test_authored_intel_purchase()
	_test_complete_flooded_veyru_campaign()
	_test_complete_five_encounter_campaign()
	_test_alternate_five_encounter_campaign()
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
	var engine_before_card: Dictionary = engine_state.serialize()
	var engine_card := engine_state.module_dependency_card(engine_state.module_at(Vector2i(0, 0)))
	_expect(String(engine_card.get("direct_dependency", "")).contains("adjacent Coal Cell") and String(engine_card.get("next_failure", "")).contains("stops movement") and String(engine_card.get("legal_counter", "")).contains("reposition or repair"), "the engine dependency card should name its direct fuel link, downstream movement failure, and one legal counter")
	_expect(engine_state.serialize() == engine_before_card, "reading a dependency card must not mutate authoritative fortress state")
	engine_state.reposition_module_at(Vector2i(0, 1), Vector2i(4, 3), false)
	_expect(engine_state.dependency_status_at(Vector2i(0, 0)).state == "offline", "moving fuel away should immediately break the engine connection")
	var comparison_state := LongMarchState.new(1107)
	comparison_state.start_campaign()
	comparison_state.choose_guard_contract(false)
	var comparison_before: Dictionary = comparison_state.serialize()
	var route_comparison := comparison_state.campaign_route_comparison()
	_expect(route_comparison.size() == 2 and route_comparison[0].has("days") and route_comparison[0].has("fuel") and route_comparison[0].has("risk_band") and route_comparison[0].has("pressure_gain") and route_comparison[0].has("next_stops"), "route comparison should expose the required planning facts for every available road")
	_expect(comparison_state.serialize() == comparison_before, "reading the route comparison must not mutate authoritative campaign state")

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

func _test_water_condenser_foundation() -> void:
	var state := LongMarchState.new(1107)
	var placed := state.place_module("water_condenser", Vector2i(4, 1))
	_expect(placed.ok, "Water Condenser should fit as a two-cell interior sustain module")
	_expect(Vector2i(5, 1) in state.occupied_cells(state.modules[0]), "unrotated Water Condenser should occupy two horizontal cells")
	var rotated := state.reposition_module_at(Vector2i(4, 1), Vector2i(5, 1), true)
	_expect(rotated.ok and Vector2i(5, 2) in state.occupied_cells(state.modules[0]), "Water Condenser should rotate into a vertical footprint")
	state.reposition_module_at(Vector2i(5, 1), Vector2i(4, 1), false)
	_expect(state.dependency_status_at(Vector2i(4, 1)).state == "strained", "a powered Water Condenser without workshop access should be strained")
	state.place_module("generator_core", Vector2i(0, 0))
	state.place_module("field_workshop", Vector2i(2, 1))
	state.place_module("crew_quarters", Vector2i(2, 0))
	_expect(state.dependency_status_at(Vector2i(4, 1)).state == "ready", "an adjacent operational Field Workshop should ready the Water Condenser")
	var before_card: Dictionary = state.serialize()
	var card := state.module_dependency_card(state.module_at(Vector2i(4, 1)))
	_expect(String(card.get("direct_dependency", "")).contains("Field Workshop") and String(card.get("next_failure", "")).contains("Dry Cistern Cut") and String(card.get("legal_counter", "")).contains("Field Workshop"), "Water Condenser dependency card should explain maintenance, route loss, and recovery")
	_expect(state.serialize() == before_card, "reading the Water Condenser dependency card must not mutate fortress state")
	state.seed_starter_inventory()
	_expect(state.stored_module_count("water_condenser") == 0, "starter inventory should not duplicate an installed Water Condenser")
	var stored_state := LongMarchState.new(1107)
	stored_state.seed_starter_inventory()
	_expect(stored_state.stored_module_count("water_condenser") == 1, "starter inventory should include one Water Condenser")
	for stored in stored_state.stored_modules:
		if String(stored.get("id", "")) == "water_condenser":
			stored["durability"] = 2
			stored["rotated"] = true
	var restored := LongMarchState.new(0)
	var load_result := restored.load_serialized(stored_state.serialize())
	_expect(bool(load_result.get("ok", false)), "a checkpoint containing the Water Condenser should load")
	var restored_condenser: Dictionary = {}
	for stored in restored.stored_modules:
		if String(stored.get("id", "")) == "water_condenser":
			restored_condenser = stored
			break
	_expect(int(restored_condenser.get("durability", 0)) == 2 and bool(restored_condenser.get("rotated", false)), "Water Condenser identity, damage, and rotation should survive save/load")

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
	_expect(state.current_location == "rill_crossing", "safe road should place the fortress at Rill Crossing during the legacy encounter")
	_expect(state.encounter_enemies.size() == 2, "safe road should create two Road Raider contacts")
	_expect(String(started.get("forecast", {}).get("target_class", "")).contains("cargo"), "safe road forecast should identify cargo pressure")
	var first_step := state.advance_encounter(1.0)
	_expect(not bool(first_step.get("resolved", false)), "the first encounter step should leave time to intervene")
	var defense_preview: Dictionary = Dictionary(state.encounter_summary().get("enemies", [])[0]).get("defense", {})
	_expect(int(defense_preview.get("damage", 0)) > 0 and "Shell Cannon" in defense_preview.get("sources", []), "the encounter summary should expose exact automatic defense output using authored source names")
	var shift_preview := state.encounter_shift_power_preview()
	var shifted_attacks: Array = shift_preview.get("affected_attacks", [])
	_expect(int(shift_preview.get("heat_after", -1)) == int(shift_preview.get("heat_before", -1)) + 1 and not shifted_attacks.is_empty(), "Shift Power should preview its exact heat increase and affected attacks")
	var intervention := state.use_encounter_intervention("shift_power")
	_expect(bool(intervention.get("ok", false)) and intervention.priority == "weapons" and int(intervention.heat_change) == 1 and String(intervention.effect).contains("weapon output +1"), "the Marchmaster should receive the exact power and heat result from an intervention")
	_expect(intervention.get("affected_attacks", []) == shifted_attacks and String(intervention.effect).contains("attacks"), "the committed power shift should preserve its pre-commit attack forecast")
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
	var vent_preview := hot_state.encounter_vent_heat_preview()
	_expect(int(vent_preview.get("heat_before", -1)) == heat_before and int(vent_preview.get("heat_after", -1)) == maxi(0, heat_before - 3) and int(vent_preview.get("heat_removed", -1)) == mini(3, heat_before), "Vent Heat should preview the exact current heat reduction")
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
	var seal_preview := sealed_target.encounter_seal_preview("coal_cell")
	var previewed_retargets: Array = seal_preview.get("retargets", [])
	_expect(bool(seal_preview.get("valid", false)) and previewed_retargets.size() == 1 and String(previewed_retargets[0].get("target", "")) != "coal_cell", "Seal preview should disclose the active threat's replacement target")
	_expect(not bool(sealed_target.modules[sealed_target._module_index_by_id("coal_cell")].get("sealed", false)) and String(sealed_target.encounter_enemies[0].get("target", "")) == "coal_cell", "Seal preview must not mutate the module or live enemy target")
	var sealed := sealed_target.use_encounter_intervention("seal_compartment", "coal_cell")
	var redirected_target := String(sealed_target.encounter_enemies[0].get("target", ""))
	var retargets: Array = sealed.get("retargets", [])
	_expect(bool(sealed.get("ok", false)) and redirected_target != "coal_cell" and not redirected_target.is_empty(), "sealing an active target should redirect the threat immediately")
	_expect(retargets.size() == 1 and String(retargets[0].get("target", "")) == redirected_target and String(sealed.get("effect", "")).contains("redirected"), "the emergency-order receipt should name the immediate retarget")
	_expect(String(previewed_retargets[0].get("target", "")) == redirected_target, "the committed Seal result should match its pre-commit redirect forecast")
	var redirected_preview := sealed_target.encounter_enemy_impact_preview(sealed_target.encounter_enemies[0])
	_expect(String(redirected_preview.get("target", "")) == redirected_target, "the impact forecast should update to the replacement target without requiring another combat step")
	_expect(sealed_target.encounter_report.filter(func(line: String) -> bool: return line.contains("redirects to")).size() == 1, "the lasting combat report should preserve why the enemy target changed")

	var destroyed_target := LongMarchState.new(1107)
	destroyed_target.place_module("coal_cell", Vector2i(0, 0))
	destroyed_target.modules[0]["durability"] = 0
	var command_points_before := destroyed_target.command_points
	_expect(not bool(destroyed_target.intervene("seal_compartment", "coal_cell").get("ok", false)) and destroyed_target.command_points == command_points_before, "destroyed systems should reject Seal without spending a command point")

	var exposed_target := LongMarchState.new(1107)
	_install_encounter_loadout(exposed_target)
	exposed_target.begin_journey("safe_road", "run_hot")
	exposed_target.encounter_enemies[0]["arrived"] = true
	exposed_target.encounter_enemies[0]["target"] = "shell_cannon"
	var exposure_preview := exposed_target.encounter_vent_heat_preview()
	var affected_hits: Array = exposure_preview.get("affected_hits", [])
	_expect(affected_hits.size() == 1 and String(affected_hits[0].get("target", "")) == "shell_cannon" and int(affected_hits[0].get("damage_after", 0)) == int(affected_hits[0].get("damage_before", 0)) + 1, "Vent Heat should identify the active exterior hit and its exact damage increase")
	var vented := exposed_target.use_encounter_intervention("vent_heat")
	_expect(String(vented.get("effect", "")).contains("Shell Cannon") and String(vented.get("effect", "")).contains("exposed"), "the Vent Heat receipt should preserve the forecast exterior consequence")

	var sacrificed_target := LongMarchState.new(1107)
	_install_encounter_loadout(sacrificed_target)
	sacrificed_target.begin_journey("safe_road", "run_hot")
	sacrificed_target.encounter_enemies[0]["arrived"] = true
	sacrificed_target.encounter_enemies[0]["target"] = "coal_cell"
	var cut_preview := sacrificed_target.encounter_cut_loose_preview()
	var previewed_cut_retargets: Array = cut_preview.get("retargets", [])
	_expect(bool(cut_preview.get("valid", false)) and String(cut_preview.get("target_module", "")) == "coal_cell" and previewed_cut_retargets.size() == 1, "cargo-sacrifice preview should name the deterministic module and affected threat")
	_expect(sacrificed_target.module_count("coal_cell") == 1 and String(sacrificed_target.encounter_enemies[0].get("target", "")) == "coal_cell", "cargo-sacrifice preview must not mutate the fortress or live target")
	var cut_loose := sacrificed_target.use_encounter_intervention("cut_loose_cargo")
	var cut_retargets: Array = cut_loose.get("retargets", [])
	var cut_target := String(sacrificed_target.encounter_enemies[0].get("target", ""))
	_expect(bool(cut_loose.get("ok", false)) and String(cut_loose.get("removed_module", "")) == "coal_cell" and cut_target != "coal_cell", "cutting loose an active cargo target should redirect its threat immediately")
	_expect(cut_retargets.size() == 1 and String(cut_retargets[0].get("target", "")) == cut_target and String(cut_loose.get("effect", "")).contains("redirected"), "the cargo-sacrifice receipt should name the replacement target")
	_expect(String(previewed_cut_retargets[0].get("target", "")) == cut_target, "the committed cargo sacrifice should match its pre-commit redirect forecast")
	_expect(String(sacrificed_target.encounter_enemy_impact_preview(sacrificed_target.encounter_enemies[0]).get("target", "")) == cut_target, "cargo sacrifice should replace its stale impact forecast before another combat step")

	var armored := LongMarchState.new(1107)
	armored.place_module("generator_core", Vector2i(0, 0))
	armored.place_module("crew_quarters", Vector2i(2, 1))
	armored.place_module("front_armor_plate", Vector2i(2, 2))
	var crew_before := int(armored.module_at(Vector2i(2, 1)).durability)
	var armor_before := int(armored.module_at(Vector2i(2, 2)).durability)
	var impact_preview := armored.encounter_enemy_impact_preview({"id": "siege_beast", "arrived": true, "defeated": false, "target": "crew_quarters", "damage_bonus": 0})
	_expect(int(impact_preview.get("damage", -1)) == 2 and int(impact_preview.get("armor_absorbed", -1)) == 1 and int(impact_preview.get("remaining_durability", -1)) == crew_before - 2, "the impact preview should include armor mitigation and match the target durability consequence")
	_expect(String(impact_preview.get("armor_id", "")) == "front_armor_plate" and int(impact_preview.get("armor_current_durability", -1)) == armor_before and int(impact_preview.get("armor_remaining_durability", -1)) == armor_before - 1, "the impact preview should identify the absorbing plate and its resulting durability")
	var armored_defense := armored.encounter_defense_preview({"id": "siege_beast", "arrived": true, "defeated": false, "target": "crew_quarters", "damage_bonus": 0})
	_expect(int(armored_defense.get("impact_buffer", 0)) == 1 and String(armored_defense.get("buffer_source", "")) == "Front Armor Plate", "the defense preview should expose exact impact mitigation and its authored source")
	var direct_armor_defense := armored.encounter_defense_preview({"id": "siege_beast", "arrived": true, "defeated": false, "target": "front_armor_plate", "damage_bonus": 0})
	_expect(int(direct_armor_defense.get("impact_buffer", 0)) == 1 and String(direct_armor_defense.get("buffer_source", "")) == "Front Armor Plate", "a Siege Beast striking the front plate should expose the plate's direct one-damage brace")
	armored._encounter_apply_enemy_damage("siege_beast", "crew_quarters")
	_expect(int(armored.module_at(Vector2i(2, 1)).durability) == crew_before - 2, "adjacent armor should reduce Siege Beast damage by one")
	_expect(int(armored.module_at(Vector2i(2, 2)).durability) == armor_before - 1, "protecting armor should absorb one durability")

	var causal := LongMarchState.new(1107)
	causal.place_module("steam_lance_engine", Vector2i(0, 0))
	causal.place_module("coal_cell", Vector2i(0, 1))
	causal.encounter_target_doctrine = "run_hot"
	var causal_before_preview: Dictionary = causal.serialize()
	var causal_preview := causal.encounter_enemy_impact_preview({"id": "road_raiders", "arrived": true, "defeated": false, "target": "coal_cell", "damage_bonus": 1})
	var predicted_changes: Array = causal_preview.get("dependency_changes", [])
	_expect(String(causal_preview.get("target_reason", "")).contains("valuable cargo") and String(causal_preview.get("target_reason", "")).contains("damaged condition"), "the impact preview should explain the same factors used by deterministic target selection")
	_expect(causal.serialize() == causal_before_preview, "target rationale and impact previews must not mutate encounter state")
	_expect(predicted_changes.size() == 1 and String(predicted_changes[0].get("module_id", "")) == "steam_lance_engine" and String(predicted_changes[0].get("to", "")) == "offline", "a disabling fuel hit should preview the downstream engine failure")
	_expect(causal._encounter_source_names(["repeater_gun", "iven_pell"]) == ["Repeater Gun", "Iven Pell"] and causal._encounter_target_name("coal_cell") == "Coal Cell", "combat reports should translate internal source and target IDs into authored names")
	_expect(causal.dependency_status_at(Vector2i(0, 0)).state == "ready" and int(causal.module_at(Vector2i(0, 1)).durability) == 2, "dependency impact previews must not mutate live fortress state")
	causal._encounter_apply_enemy_damage("road_raiders", "coal_cell", 1)
	_expect(causal.dependency_status_at(Vector2i(0, 0)).state == "offline", "destroyed fuel should disable its adjacent engine")
	_expect(causal.encounter_report.filter(func(line: String) -> bool: return line.contains("Dependency change") and line.contains("Steam Lance Engine")).size() > 0, "combat report should explain downstream dependency failure")

func _test_settlement_and_final_march() -> void:
	var hull_service := LongMarchState.new(1107)
	hull_service.phase = "settlement"
	hull_service.current_location = "morrowline_camp"
	hull_service.settlement_actions_remaining = 1
	hull_service.hull_condition = 9
	hull_service.money = 10
	var hull_result := hull_service.settlement_repair_hull()
	_expect(bool(hull_result.get("ok", false)) and int(hull_result.get("hull_added", 0)) == 1 and hull_service.hull_condition == 10, "hull service should report the actual one-point repair when the fortress is nearly full")
	_expect(String(hull_service.settlement_report[-1]).contains("restored 1 hull"), "the settlement record should preserve the exact hull repair delivered")

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
	var invalid_result_save := state.serialize()
	invalid_result_save["phase"] = "results"
	invalid_result_save["final_result"] = "unknown_result"
	var invalid_result_load := LongMarchState.new(0).load_serialized(invalid_result_save)
	_expect(not bool(invalid_result_load.get("ok", false)) and String(invalid_result_load.get("reason", "")).contains("recognized outcome"), "result saves with an unknown terminal outcome should be rejected safely")
	var incomplete_result_save := state.serialize()
	incomplete_result_save["phase"] = "results"
	incomplete_result_save["final_result"] = "scarred_march"
	var incomplete_result_load := LongMarchState.new(0).load_serialized(incomplete_result_save)
	_expect(not bool(incomplete_result_load.get("ok", false)) and String(incomplete_result_load.get("reason", "")).contains("completion state"), "result saves without completed run flags should be rejected safely")
	var active_completed_save := state.serialize()
	active_completed_save["run_complete"] = true
	active_completed_save["journey_complete"] = true
	active_completed_save["final_result"] = "decisive_march"
	var active_completed_load := LongMarchState.new(0).load_serialized(active_completed_save)
	_expect(not bool(active_completed_load.get("ok", false)) and String(active_completed_load.get("reason", "")).contains("active campaign phase"), "active-phase saves should reject contradictory completion state")
	var unknown_phase_save := state.serialize()
	unknown_phase_save["phase"] = "lost_between_roads"
	var unknown_phase_load := LongMarchState.new(0).load_serialized(unknown_phase_save)
	_expect(not bool(unknown_phase_load.get("ok", false)) and String(unknown_phase_load.get("reason", "")).contains("unknown campaign phase"), "unknown campaign phases should be rejected before state mutation")
	var unknown_event_save := state.serialize()
	unknown_event_save["campaign_event_pending"] = "invented_meeting"
	var unknown_event_load := LongMarchState.new(0).load_serialized(unknown_event_save)
	_expect(not bool(unknown_event_load.get("ok", false)) and String(unknown_event_load.get("reason", "")).contains("unknown active campaign event"), "unknown active campaign events should be rejected safely")
	var unknown_specialist_save := state.serialize()
	unknown_specialist_save["specialist_id"] = "miracle_mechanic"
	var unknown_specialist_load := LongMarchState.new(0).load_serialized(unknown_specialist_save)
	_expect(not bool(unknown_specialist_load.get("ok", false)) and String(unknown_specialist_load.get("reason", "")).contains("unknown specialist"), "unknown specialist IDs should be rejected safely")
	var version_four_save := state.serialize()
	version_four_save["save_version"] = 4
	version_four_save.erase("mara_repaired_module_id")
	var version_four_restore := LongMarchState.new(0)
	_expect(bool(version_four_restore.load_serialized(version_four_save).get("ok", false)) and version_four_restore.mara_repaired_module_id.is_empty(), "version-four checkpoints should migrate with no Mara repair target")
	var missing_mara_target_save := state.serialize()
	missing_mara_target_save["specialist_id"] = "mara_flint"
	missing_mara_target_save["campaign_decisions"] = {"mara_meeting": "recruit_mara", "mara_workbench_choice": "rebuild_weakest"}
	var missing_mara_target_load := LongMarchState.new(0).load_serialized(missing_mara_target_save)
	_expect(not bool(missing_mara_target_load.get("ok", false)) and String(missing_mara_target_load.get("reason", "")).contains("missing its system target"), "Mara repair checkpoints should reject a missing repaired-system reference")
	var inactive_battle_save := state.serialize()
	inactive_battle_save["phase"] = "battle"
	var inactive_battle_load := LongMarchState.new(0).load_serialized(inactive_battle_save)
	_expect(not bool(inactive_battle_load.get("ok", false)) and String(inactive_battle_load.get("reason", "")).contains("encounter state"), "battle checkpoints should require an active encounter")
	var active_refit_save := state.serialize()
	active_refit_save["encounter_active"] = true
	var active_refit_load := LongMarchState.new(0).load_serialized(active_refit_save)
	_expect(not bool(active_refit_load.get("ok", false)) and String(active_refit_load.get("reason", "")).contains("encounter state"), "planning checkpoints should reject a stray active encounter")
	var invalid_decision_save := state.serialize()
	invalid_decision_save["campaign_decisions"] = {"lost_signal": "sell_the_relay"}
	var invalid_decision_load := LongMarchState.new(0).load_serialized(invalid_decision_save)
	_expect(not bool(invalid_decision_load.get("ok", false)) and String(invalid_decision_load.get("reason", "")).contains("unknown choice"), "saved campaign history should reject an unknown authored choice")
	var malformed_decision_save := state.serialize()
	malformed_decision_save["campaign_decisions"] = ["move_silent"]
	var malformed_decision_load := LongMarchState.new(0).load_serialized(malformed_decision_save)
	_expect(not bool(malformed_decision_load.get("ok", false)) and String(malformed_decision_load.get("reason", "")).contains("malformed"), "saved campaign history should reject a non-dictionary decision record")
	var unknown_module_save := state.serialize()
	unknown_module_save["modules"][0]["id"] = "miracle_engine"
	var unknown_module_load := LongMarchState.new(0).load_serialized(unknown_module_save)
	_expect(not bool(unknown_module_load.get("ok", false)) and String(unknown_module_load.get("reason", "")).contains("unknown system"), "saved chassis layouts should reject unknown module IDs")
	var overlapping_module_save := state.serialize()
	overlapping_module_save["modules"].append(overlapping_module_save["modules"][0].duplicate(true))
	var overlapping_module_load := LongMarchState.new(0).load_serialized(overlapping_module_save)
	_expect(not bool(overlapping_module_load.get("ok", false)) and String(overlapping_module_load.get("reason", "")).contains("overlapping systems"), "saved chassis layouts should reject overlapping installed modules")
	var out_of_bounds_module_save := state.serialize()
	out_of_bounds_module_save["modules"][0]["position"] = [LongMarchState.GRID_WIDTH, 0]
	var out_of_bounds_module_load := LongMarchState.new(0).load_serialized(out_of_bounds_module_save)
	_expect(not bool(out_of_bounds_module_load.get("ok", false)) and String(out_of_bounds_module_load.get("reason", "")).contains("outside the chassis"), "saved chassis layouts should reject out-of-bounds systems")
	var unknown_enemy_save := state.serialize()
	unknown_enemy_save["encounter_enemies"] = [{"id": "developer_dragon", "hp": 1, "max_hp": 1, "slot": 0}]
	var unknown_enemy_load := LongMarchState.new(0).load_serialized(unknown_enemy_save)
	_expect(not bool(unknown_enemy_load.get("ok", false)) and String(unknown_enemy_load.get("reason", "")).contains("unknown threat"), "saved encounters should reject unknown threat IDs")
	var missing_target_save := state.serialize()
	missing_target_save["encounter_enemies"] = [{"id": "road_raiders", "hp": 2, "max_hp": 5, "slot": 0, "target": "miracle_engine", "defeated": false}]
	var missing_target_load := LongMarchState.new(0).load_serialized(missing_target_save)
	_expect(not bool(missing_target_load.get("ok", false)) and String(missing_target_load.get("reason", "")).contains("missing system"), "saved encounters should reject targets absent from the restored chassis")
	var invalid_progress_save := state.serialize()
	invalid_progress_save["encounter_step"] = 9
	var invalid_progress_load := LongMarchState.new(0).load_serialized(invalid_progress_save)
	_expect(not bool(invalid_progress_load.get("ok", false)) and String(invalid_progress_load.get("reason", "")).contains("invalid encounter progress"), "saved encounters should reject steps beyond the six-step timeline")
	var unknown_location_save := state.serialize()
	unknown_location_save["current_location"] = "the_road_beyond_the_map"
	var unknown_location_load := LongMarchState.new(0).load_serialized(unknown_location_save)
	_expect(not bool(unknown_location_load.get("ok", false)) and String(unknown_location_load.get("reason", "")).contains("unknown journey location"), "saved journeys should reject locations outside the authored map")
	var malformed_path_save := state.serialize()
	malformed_path_save["campaign_path"] = "ashgate_depot"
	var malformed_path_load := LongMarchState.new(0).load_serialized(malformed_path_save)
	_expect(not bool(malformed_path_load.get("ok", false)) and String(malformed_path_load.get("reason", "")).contains("path record is malformed"), "saved campaigns should reject a non-array path record")
	var impossible_path_save := state.serialize()
	impossible_path_save["campaign_active"] = true
	impossible_path_save["campaign_path"] = ["ashgate_depot", "signal_causeway"]
	impossible_path_save["campaign_last_safe_node"] = "signal_causeway"
	var impossible_path_load := LongMarchState.new(0).load_serialized(impossible_path_save)
	_expect(not bool(impossible_path_load.get("ok", false)) and String(impossible_path_load.get("reason", "")).contains("impossible route"), "saved campaigns should reject paths that jump between disconnected nodes")
	var mismatched_safe_node_save := state.serialize()
	mismatched_safe_node_save["campaign_active"] = true
	mismatched_safe_node_save["campaign_path"] = ["ashgate_depot", "rill_crossing"]
	mismatched_safe_node_save["campaign_last_safe_node"] = "ashgate_depot"
	var mismatched_safe_node_load := LongMarchState.new(0).load_serialized(mismatched_safe_node_save)
	_expect(not bool(mismatched_safe_node_load.get("ok", false)) and String(mismatched_safe_node_load.get("reason", "")).contains("secured path"), "saved campaigns should keep the recovery node aligned with the secured path")

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
	var origin_id := state.current_location
	var begun := state.begin_campaign_route(node_id, doctrine)
	if not bool(begun.get("ok", false)):
		return begun
	_expect(state.current_location == origin_id and state.campaign_target_node == node_id, "campaign departure should retain the last secured location until its road contact resolves")
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
	_expect(String(preview.visibility) == "unscouted" and preview.get("threats", []).is_empty() and preview.get("counter_hints", []).is_empty() and preview.get("ready_counter_names", []).is_empty(), "a strained signal should leave an unscouted branch's exact threats, counters, and counter readiness hidden")
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
	_expect(String(state.iven_recruitment_status().get("reason", "")).contains("specialist is already assigned") and not String(state.iven_recruitment_status().get("reason", "")).contains("prototype"), "filled specialist capacity should use in-world language")
	var preview := state.campaign_node_preview("signal_causeway")
	_expect(String(preview.visibility) == "known" and not preview.get("threats", []).is_empty() and not preview.get("counter_hints", []).is_empty(), "Iven should reveal exact immediate-node threats and actionable counters")
	var restored := LongMarchState.new(0)
	restored.load_serialized(state.serialize())
	_expect(restored.specialist_id == "iven_pell" and restored.guard_contract_status == "accepted", "save/load should preserve the specialist and contract")
	_expect(String(restored.campaign_decisions.get("lost_signal", "")) == "restore_relay", "save/load should preserve the exact authored route decision")
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
	_expect(state.settlement_actions_remaining == 1 and state.encounter_report.filter(func(line: String) -> bool: return line.contains("Parts shortage") and line.contains("1 service action")).size() == 1, "declining the convoy should create one explicit Morrowline parts shortage and reduce recovery to one action")
	_expect(state.campaign_event_pending == "mara_meeting" and bool(state.resolve_campaign_event("decline_mara").get("ok", false)), "a free specialist berth should surface Mara's offer at Morrowline and allow a clean decline")

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
	_expect(state.campaign_available_nodes() == ["lower_ash_road", "cinder_quarry"], "closure pressure must leave both the Lower Ash and Cinder Quarry recovery routes available")
	state.specialist_id = "iven_pell"
	_expect(not state.campaign_node_closed("signal_causeway"), "Iven should keep the Signal Causeway readable at Break pressure")
	_expect(state.campaign_available_nodes() == ["lower_ash_road", "signal_causeway", "cinder_quarry"], "reliable forecasting should restore Signal Causeway while preserving both recovery routes")

func _install_mara_loadout(state: LongMarchState, include_refuge: bool = true) -> void:
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("field_workshop", Vector2i(2, 1))
	state.place_module("crew_quarters", Vector2i(2, 2))
	state.place_module("parts_crate", Vector2i(4, 1))
	if include_refuge:
		state.place_module("refugee_bunk", Vector2i(4, 2))
	state.seed_starter_inventory()

func _test_morrowline_parts_shortage() -> void:
	var declined := LongMarchState.new(1107)
	_install_campaign_signal_loadout(declined)
	declined.start_campaign()
	var decision := declined.choose_guard_contract(false)
	_expect(bool(decision.get("ok", false)) and String(decision.get("message", "")).contains("1 service action instead of 2"), "declining the convoy should disclose the later Morrowline shortage before the fortress departs")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(declined.serialize()).get("ok", false)) and restored.guard_contract_status == "declined", "the declined convoy promise should survive save/load before its consequence resolves")
	for arrival_state in [declined, restored]:
		arrival_state.campaign_path.clear()
		arrival_state.campaign_path.append_array(["ashgate_depot", "rill_crossing", "broken_relay"])
		arrival_state.campaign_last_safe_node = "broken_relay"
		arrival_state.current_location = "broken_relay"
		arrival_state.journey_node = "broken_relay"
		arrival_state.campaign_encounters_completed = 2
		arrival_state.campaign_target_node = "morrowline_camp"
		arrival_state.current_location = "morrowline_camp"
		arrival_state.journey_node = "morrowline_camp"
		arrival_state._finish_campaign_encounter(true)
	_expect(declined.settlement_actions_remaining == 1 and restored.settlement_actions_remaining == 1, "the absent parts convoy should deterministically reduce Morrowline to one service action")
	_expect(declined.encounter_report == restored.encounter_report and declined.serialize() == restored.serialize(), "the shortage consequence should resolve identically before and after save/load")
	_expect(bool(declined.settlement_refuel().get("ok", false)) and declined.settlement_actions_remaining == 0, "the shortage path should still allow one chosen recovery service")
	_expect(not bool(declined.settlement_repair_hull().get("ok", false)), "a second Morrowline service should be blocked after the shortage action is spent")

func _test_mastery_experiments() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	var resources_before := {"day": state.day, "fuel": state.fuel, "money": state.money, "trust": state.settlement_trust}
	var selected := state.choose_mastery_experiment("ashgate_quarry_adaptation")
	_expect(bool(selected.get("ok", false)) and state.mastery_experiment_id == "ashgate_quarry_adaptation", "Ashgate should accept the bounded Quarry Adaptation field order")
	_expect(String(state.mastery_experiment_details().get("status", "")) == "ACTIVE" and not bool(state.mastery_experiment_details().get("proven", true)), "a newly selected field order should be active without claiming completion")
	_expect(resources_before == {"day": state.day, "fuel": state.fuel, "money": state.money, "trust": state.settlement_trust}, "selecting a field order should grant no currency, stat, or progression reward")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(state.serialize()).get("ok", false)) and restored.mastery_experiment_id == state.mastery_experiment_id and restored.mastery_experiment_details() == state.mastery_experiment_details(), "the optional mastery order should survive save/load without changing its evaluation")
	var invalid_payload := state.serialize()
	invalid_payload["mastery_experiment_id"] = "unknown_experiment"
	_expect(not bool(LongMarchState.new(0).load_serialized(invalid_payload).get("ok", false)), "unknown mastery IDs should be rejected during save validation")
	_expect(not bool(state.choose_mastery_experiment("unknown_experiment").get("ok", false)), "unknown field orders should be rejected")
	state.current_location = "rill_crossing"
	state.phase = "map"
	state.campaign_encounters_completed = 1
	_expect(not bool(state.choose_mastery_experiment("ashgate_signal_discipline").get("ok", false)), "a field order should not be changed after the first road begins")

func _arrive_at_morrowline_for_mara(state: LongMarchState) -> void:
	state.start_campaign()
	state.choose_guard_contract(false)
	state.campaign_path = ["ashgate_depot", "rill_crossing", "broken_relay"]
	state.campaign_last_safe_node = "broken_relay"
	state.current_location = "broken_relay"
	state.journey_node = "broken_relay"
	state.campaign_encounters_completed = 2
	state.campaign_target_node = "morrowline_camp"
	state.current_location = "morrowline_camp"
	state.journey_node = "morrowline_camp"
	state._finish_campaign_encounter(true)

func _test_mara_flint_event_chain() -> void:
	var unqualified := LongMarchState.new(1107)
	unqualified.campaign_active = true
	unqualified.current_location = "morrowline_camp"
	unqualified.journey_node = "morrowline_camp"
	unqualified.phase = "settlement"
	unqualified.campaign_event_pending = "mara_meeting"
	var locked_offer := unqualified.campaign_event_details()
	_expect(not bool(locked_offer.choices[0].enabled) and String(locked_offer.choices[0].reason).contains("Field Workshop"), "Mara's offer should name the missing operational workshop requirement")
	_expect(bool(unqualified.resolve_campaign_event("decline_mara").get("ok", false)) and unqualified.specialist_id.is_empty() and unqualified.campaign_event_pending.is_empty(), "declining Mara should keep the specialist berth open and end her chain")

	var repair_state := LongMarchState.new(1107)
	_install_mara_loadout(repair_state)
	repair_state.modules[repair_state._module_index_by_id("steam_lance_engine")]["durability"] = 2
	_arrive_at_morrowline_for_mara(repair_state)
	_expect(repair_state.campaign_event_pending == "mara_meeting", "Mara's meeting should trigger after the third encounter at Morrowline")
	var meeting_restore := LongMarchState.new(0)
	_expect(bool(meeting_restore.load_serialized(repair_state.serialize()).get("ok", false)) and meeting_restore.campaign_event_pending == "mara_meeting", "an active Mara meeting should survive save/load")
	var recruited := repair_state.resolve_campaign_event("recruit_mara")
	_expect(bool(recruited.get("ok", false)) and repair_state.specialist_id == "mara_flint" and repair_state.campaign_event_pending == "mara_workbench_choice", "accepting Mara should fill the specialist berth and advance to the forge-core choice")
	var workbench_restore := LongMarchState.new(0)
	_expect(bool(workbench_restore.load_serialized(repair_state.serialize()).get("ok", false)) and workbench_restore.campaign_event_pending == "mara_workbench_choice" and workbench_restore.specialist_id == "mara_flint", "the active Mara workbench choice should survive save/load")
	var workbench := repair_state.campaign_event_details()
	_expect(String(workbench.choices[0].label).contains("Steam Lance Engine") and String(workbench.choices[0].effect).contains("Day +1") and String(workbench.choices[1].effect).contains("damage -1"), "the forge-core event should preview its exact repair target, delay, and refuge alternative")
	var day_before := repair_state.day
	var pressure_before := repair_state.campaign_pressure
	var rebuilt := repair_state.resolve_campaign_event("rebuild_weakest")
	_expect(bool(rebuilt.get("ok", false)) and int(repair_state.module_at(Vector2i(0, 0)).durability) == 4 and repair_state.day == day_before + 1 and repair_state.campaign_pressure == pressure_before + 1, "Mara should rebuild the deterministic weakest system for a visible day and pressure cost")
	_expect(repair_state.mara_repaired_module_id == "steam_lance_engine" and not bool(repair_state.resolve_campaign_event("brace_refuge").get("ok", false)), "resolving the one-core choice should record its target and make the alternative unavailable")
	_expect(repair_state._workshop_repair_amount() == 3, "Mara plus connected parts should raise field repair from two durability to three")
	repair_state.modules[repair_state._module_index_by_id("crew_quarters")]["durability"] = 1
	var service_preview := repair_state.settlement_repair_preview("crew_quarters")
	_expect(int(service_preview.restored) == 3 and int(service_preview.cost) == 8 and int(service_preview.mara_bonus) == 1, "Mara's settlement preview should add one free durability without increasing the two-point price")
	var service_result := repair_state.settlement_repair("crew_quarters")
	_expect(bool(service_result.get("ok", false)) and int(repair_state.module_at(Vector2i(2, 2)).durability) == 4 and String(service_result.get("message", "")).contains("Mara Flint"), "Morrowline service should apply and explain Mara's extra repair point")
	repair_state.campaign_target_node = "lower_ash_road"
	repair_state.current_location = "lower_ash_road"
	repair_state.journey_node = "lower_ash_road"
	repair_state._finish_campaign_encounter(true)
	_expect(repair_state.campaign_event_pending == "mara_followup", "Mara's later callback should block departure after the fourth road")
	var followup_restore := LongMarchState.new(0)
	_expect(bool(followup_restore.load_serialized(repair_state.serialize()).get("ok", false)) and followup_restore.campaign_event_pending == "mara_followup" and followup_restore.mara_repaired_module_id == "steam_lance_engine", "the active Mara callback and repaired system should survive save/load")
	var callback_pressure := repair_state.campaign_pressure
	var callback := repair_state.resolve_campaign_event(String(repair_state.mara_followup_preview().get("choice_id", "")))
	_expect(bool(callback.get("ok", false)) and repair_state.campaign_pressure == maxi(0, callback_pressure - 1) and String(callback.get("message", "")).contains("repair held"), "an operational repaired system should pay off in the later callback by recovering one pressure")
	_expect(repair_state.mara_debrief_line().contains("Steam Lance Engine") and repair_state.mara_debrief_line().contains("recovered 1 pressure"), "Mara's repair debrief should preserve the chosen system and later consequence")

	var refuge_state := LongMarchState.new(1107)
	_install_mara_loadout(refuge_state)
	_arrive_at_morrowline_for_mara(refuge_state)
	refuge_state.resolve_campaign_event("recruit_mara")
	var braced := refuge_state.resolve_campaign_event("brace_refuge")
	_expect(bool(braced.get("ok", false)) and refuge_state.mara_refuge_bracing_active(), "the forge core should be spendable on persistent Refugee Bunk bracing")
	refuge_state.encounter_target_doctrine = "run_hot"
	var bunk_preview := refuge_state.encounter_enemy_impact_preview({"id": "road_raiders", "arrived": true, "defeated": false, "target": "refugee_bunk", "damage_bonus": 0})
	_expect(int(bunk_preview.get("damage", -1)) == 0 and String(bunk_preview.get("mara_effect", "")) == "refuge_bracing", "Mara's bracing should reduce each Refugee Bunk hit by one and expose that mitigation in the preview")
	refuge_state.campaign_target_node = "signal_causeway"
	refuge_state.current_location = "signal_causeway"
	refuge_state.journey_node = "signal_causeway"
	refuge_state._finish_campaign_encounter(true)
	var trust_before := refuge_state.settlement_trust
	var shelter_before := refuge_state.shelter_tendency
	var refuge_callback := refuge_state.resolve_campaign_event(String(refuge_state.mara_followup_preview().get("choice_id", "")))
	_expect(bool(refuge_callback.get("ok", false)) and refuge_state.settlement_trust == trust_before + 1 and refuge_state.shelter_tendency == shelter_before + 1, "an operational braced bunk should earn the promised trust and Shelter callback")
	_expect(refuge_state.mara_debrief_line().contains("Refugee Bunk") and refuge_state.mara_debrief_line().contains("1 trust"), "Mara's refuge debrief should preserve the physical commitment and earned trust")
	var failed_refuge := LongMarchState.new(1107)
	_install_mara_loadout(failed_refuge)
	_arrive_at_morrowline_for_mara(failed_refuge)
	failed_refuge.resolve_campaign_event("recruit_mara")
	failed_refuge.resolve_campaign_event("brace_refuge")
	failed_refuge.modules[failed_refuge._module_index_by_id("refugee_bunk")]["durability"] = 0
	failed_refuge.campaign_target_node = "dry_cistern_cut"
	failed_refuge.current_location = "dry_cistern_cut"
	failed_refuge.journey_node = "dry_cistern_cut"
	failed_refuge._finish_campaign_encounter(true)
	var failed_followup := failed_refuge.mara_followup_preview()
	var failed_trust := failed_refuge.settlement_trust
	_expect(String(failed_followup.get("choice_id", "")) == "record_refuge_failed" and String(failed_followup.get("effect", "")).contains("not operational"), "the later callback should preview failure when the braced bunk did not remain operational")
	_expect(bool(failed_refuge.resolve_campaign_event("record_refuge_failed").get("ok", false)) and failed_refuge.settlement_trust == failed_trust and failed_refuge.mara_debrief_line().contains("not operational"), "a failed refuge commitment should grant no hidden trust and remain explicit in the debrief")

	var first := LongMarchState.new(1107)
	var second := LongMarchState.new(1107)
	for replay_state in [first, second]:
		_install_mara_loadout(replay_state)
		replay_state.modules[replay_state._module_index_by_id("steam_lance_engine")]["durability"] = 2
		_arrive_at_morrowline_for_mara(replay_state)
		replay_state.resolve_campaign_event("recruit_mara")
		replay_state.resolve_campaign_event("rebuild_weakest")
		replay_state.campaign_target_node = "lower_ash_road"
		replay_state.current_location = "lower_ash_road"
		replay_state.journey_node = "lower_ash_road"
		replay_state._finish_campaign_encounter(true)
		replay_state.resolve_campaign_event(String(replay_state.mara_followup_preview().get("choice_id", "")))
	_expect(first.serialize() == second.serialize(), "Mara's complete event chain should replay deterministically from the same state and choices")

func _install_occurrence_loadout(state: LongMarchState) -> void:
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("field_workshop", Vector2i(2, 1))
	state.place_module("crew_quarters", Vector2i(2, 2))
	state.place_module("parts_crate", Vector2i(4, 1))
	state.place_module("refugee_bunk", Vector2i(4, 2))
	state.modules[state._module_index_by_id("steam_lance_engine")]["durability"] = 2
	state.start_campaign()
	state.choose_guard_contract(false)
	state.campaign_encounters_completed = 1
	state.current_location = "rill_crossing"
	state.journey_node = "rill_crossing"
	state.phase = "map"

func _activate_occurrence(state: LongMarchState, event_id: String, phase_id: String) -> void:
	state.campaign_event_pending = event_id
	state.occurrence_active_phase = phase_id
	state.occurrence_phase_history.append(phase_id)

func _test_bounded_occurrence_scheduler() -> void:
	var first := LongMarchState.new(1107)
	var second := LongMarchState.new(1107)
	for state in [first, second]:
		_install_occurrence_loadout(state)
		var candidates: Array[String] = state.occurrence_candidates("road_arrival", "rill_crossing")
		_expect(candidates == ["boiler_heartbeat", "the_last_dry_room", "the_miller_with_a_broken_wheel"], "occurrence eligibility should filter the library by live systems before selection")
		var scheduled: Dictionary = state.try_schedule_occurrence("road_arrival", "rill_crossing", "road_arrival_1_rill_crossing")
		_expect(String(scheduled.get("event_id", "")) == "boiler_heartbeat", "the named occurrence stream should select the same authored incident for the fixed fixture")
		var details: Dictionary = state.campaign_event_details()
		var enabled_counter := false
		for choice in details.get("choices", []):
			enabled_counter = enabled_counter or bool(choice.get("enabled", false))
		_expect(enabled_counter and String(details.get("title", "")).contains("Heartbeat"), "every scheduled occurrence should expose at least one enabled counter in the existing event card")
	_expect(first.campaign_event_pending == second.campaign_event_pending and first.occurrence_stream_cursor == second.occurrence_stream_cursor and first.occurrence_phase_history == second.occurrence_phase_history, "identical seeds and eligible state should produce identical occurrence selection state")
	var active_restore := LongMarchState.new(0)
	_expect(bool(active_restore.load_serialized(first.serialize()).get("ok", false)) and active_restore.campaign_event_pending == "boiler_heartbeat" and active_restore.occurrence_active_phase == "road_arrival_1_rill_crossing" and active_restore.occurrence_stream_cursor == 1, "an active occurrence and its named-stream cursor should survive save/load")
	var cursor_before := first.occurrence_stream_cursor
	var pressure_before := first.campaign_pressure
	var resolved := first.resolve_campaign_event("inspect_boiler")
	_expect(bool(resolved.get("ok", false)) and first.day == 2 and first.campaign_pressure == pressure_before + 1 and int(first.modules[first._module_index_by_id("steam_lance_engine")].durability) == 3, "the boiler inspection should repair the named engine for its visible time and pressure cost")
	_expect(first.occurrence_history.size() == 1 and first.occurrence_active_phase.is_empty() and String(first.occurrence_history[0].choice_id) == "inspect_boiler", "resolving an occurrence should append one typed audit record and clear active state")
	var repeated_phase := first.try_schedule_occurrence("road_arrival", "rill_crossing", "road_arrival_1_rill_crossing")
	_expect(String(repeated_phase.get("event_id", "")).is_empty() and first.occurrence_stream_cursor == cursor_before, "an evaluated phase should not reroll after resolution or reload")
	_expect(not bool(first.occurrence_eligibility("boiler_heartbeat", "road_arrival", "lower_ash_road").eligible), "a repeatable occurrence should respect its encounter cooldown")
	first.campaign_encounters_completed = 4
	_expect(bool(first.occurrence_eligibility("boiler_heartbeat", "road_arrival", "lower_ash_road").eligible), "a repeatable occurrence should become eligible again after its cooldown")

	var dry_room := LongMarchState.new(1107)
	_install_occurrence_loadout(dry_room)
	_activate_occurrence(dry_room, "the_last_dry_room", "manual_dry_room")
	var parts_before := int(dry_room.modules[dry_room._module_index_by_id("parts_crate")].durability)
	var dry_room_details := dry_room.campaign_event_details()
	_expect(String(dry_room_details.choices[0].effect).contains("Parts Crate %d→%d" % [parts_before, parts_before - 1]) and String(dry_room_details.choices[1].effect).contains("Steam Lance Engine 2→3"), "the dry-room choice should preview exact physical damage and repair before commitment")
	_expect(bool(dry_room.resolve_campaign_event("shelter_in_dry_room").get("ok", false)) and dry_room.settlement_trust == 2 and dry_room.shelter_tendency == 1 and int(dry_room.modules[dry_room._module_index_by_id("parts_crate")].durability) == parts_before - 1, "the dry-room shelter choice should exchange physical repair stock for trust and refuge capacity")
	_expect(dry_room.occurrence_debrief_lines()[0].contains("families sheltered; repair stock exposed"), "the dry-room terminal record should translate the internal choice ID into its remembered consequence")
	_expect(not bool(dry_room.occurrence_eligibility("the_last_dry_room", "road_arrival", "lower_ash_road").eligible), "a one-shot occurrence should not repeat after resolution")

	var lift := LongMarchState.new(1107)
	lift.place_module("steam_lance_engine", Vector2i(0, 0))
	lift.place_module("coal_cell", Vector2i(0, 1))
	lift.place_module("generator_core", Vector2i(2, 0))
	lift.place_module("ammunition_lift", Vector2i(2, 1))
	lift.place_module("repeater_gun", Vector2i(3, 2), true)
	lift.start_campaign()
	lift.choose_guard_contract(false)
	lift.campaign_encounters_completed = 1
	_activate_occurrence(lift, "lift_chain_sings", "manual_lift")
	var lift_before := int(lift.modules[lift._module_index_by_id("ammunition_lift")].durability)
	_expect(bool(lift.resolve_campaign_event("carry_lift_load").get("ok", false)) and int(lift.modules[lift._module_index_by_id("ammunition_lift")].durability) == lift_before - 1, "the lift incident should make dependency strain explicit and recoverable")

	var miller := LongMarchState.new(1107)
	_install_occurrence_loadout(miller)
	_activate_occurrence(miller, "the_miller_with_a_broken_wheel", "manual_miller")
	var workshop_before := int(miller.modules[miller._module_index_by_id("field_workshop")].durability)
	_expect(bool(miller.resolve_campaign_event("lend_workshop_bench").get("ok", false)) and miller.fuel == 7 and miller.settlement_trust == 1 and int(miller.modules[miller._module_index_by_id("field_workshop")].durability) == workshop_before - 1, "the optional meeting should trade workshop condition and time for fuel and trust without creating a recruit state")

	var seen_results: Dictionary = {}
	for world_seed in range(1, 33):
		var seeded := LongMarchState.new(world_seed)
		_install_occurrence_loadout(seeded)
		var seeded_result := seeded.try_schedule_occurrence("road_arrival", "rill_crossing", "seed_audit")
		var event_id := String(seeded_result.get("event_id", ""))
		seen_results[event_id] = true
		if not event_id.is_empty():
			var has_counter := false
			for choice in seeded.campaign_event_details().get("choices", []):
				has_counter = has_counter or bool(choice.get("enabled", false))
			_expect(has_counter, "every tested seed that selects an occurrence should preserve one visible legal counter")
	_expect(seen_results.size() >= 3 and seen_results.has(""), "the named stream should produce multiple authored results and intentional quiet phases across tested seeds")

	var bounded := LongMarchState.new(1107)
	for index in range(LongMarchState.OCCURRENCE_HISTORY_LIMIT + 3):
		bounded.occurrence_active_phase = "history_%d" % index
		bounded._record_occurrence_resolution("lift_chain_sings", "carry_lift_load")
	_expect(bounded.occurrence_history.size() == LongMarchState.OCCURRENCE_HISTORY_LIMIT and String(bounded.occurrence_history[0].phase_id) == "history_3", "occurrence history should discard its oldest records instead of growing without bound")
	var malformed_history := first.serialize()
	malformed_history["occurrence_history"] = []
	for index in range(LongMarchState.OCCURRENCE_HISTORY_LIMIT + 1):
		malformed_history["occurrence_history"].append({"event_id": "lift_chain_sings", "choice_id": "carry_lift_load", "phase_id": "bad_%d" % index})
	_expect(not bool(LongMarchState.new(0).load_serialized(malformed_history).get("ok", false)), "unbounded occurrence history should be rejected before mutating restored state")
	var version_five := first.serialize()
	version_five["save_version"] = 5
	for key in ["occurrence_stream", "occurrence_stream_cursor", "occurrence_active_phase", "occurrence_phase_history", "occurrence_history", "occurrence_cooldowns"]:
		version_five.erase(key)
	var migrated := LongMarchState.new(0)
	_expect(bool(migrated.load_serialized(version_five).get("ok", false)) and migrated.occurrence_history.is_empty() and migrated.occurrence_stream_cursor == 0, "version-five checkpoints should migrate with an empty occurrence scheduler")
	_expect(first.occurrence_debrief_lines()[0].contains("Boiler's Second Heartbeat") and first.occurrence_debrief_lines()[0].contains("Inspect Boiler"), "resolved occurrences should produce a concise causal debrief record")

func _test_flooded_veyru_region_state() -> void:
	var state := LongMarchState.new(2204)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 2))
	state.place_module("field_workshop", Vector2i(2, 1))
	state.place_module("refugee_bunk", Vector2i(4, 1))
	state.start_flooded_veyru()
	_expect(state.campaign_region_id == "flooded_veyru" and state.current_location == "lantern_quay" and state.campaign_path == ["lantern_quay"], "a Veyru chapter should initialize independently at Lantern Quay")
	_expect(state.campaign_region_name() == "Flooded Veyru" and state.campaign_pressure_name() == "Rising water" and state.campaign_pressure_band() == "low_water", "Veyru should expose its regional identity and low-water pressure band")
	_expect(state.campaign_available_nodes() == ["pump_gallery", "sunken_tramworks"] and not state.campaign_edges()["veyru_evacuation_camp"].has("pilgrim_gantry"), "low water should expose both opening routes while keeping the emergency gantry out of the normal graph")
	var contract_status := state.veyru_medicine_contract_status()
	_expect(bool(contract_status.get("available", false)) and String(contract_status.get("carrier_id", "")) == "refugee_bunk", "the medicine contract should reserve the operational Refugee Bunk before falling back to parts storage")
	var accepted := state.choose_veyru_medicine_contract(true)
	_expect(bool(accepted.get("ok", false)) and state.veyru_contract_status == "accepted" and state.veyru_medicine_carrier_id == "refugee_bunk" and state.veyru_contract_carrier_operational(), "accepting the Veyru contract should preserve its exact physical carrier")
	state.current_location = "veyru_evacuation_camp"
	state.journey_node = "veyru_evacuation_camp"
	state.campaign_path.append("pump_gallery")
	state.campaign_path.append("veyru_evacuation_camp")
	state.campaign_last_safe_node = "veyru_evacuation_camp"
	state.phase = "settlement"
	state.campaign_pressure = 5
	_expect(state.campaign_pressure_band() == "breach" and state.campaign_node_closed("drowned_registry"), "Breach water should close the low Drowned Registry branch")
	_expect(state.campaign_available_nodes() == ["archive_causeway", "pilgrim_gantry"] and state.campaign_edges()["veyru_evacuation_camp"].has("pilgrim_gantry"), "Breach water must add Pilgrim Gantry while preserving another forward route")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(state.serialize()).get("ok", false)) and restored.campaign_region_id == "flooded_veyru" and restored.campaign_pressure == 5 and restored.veyru_medicine_carrier_id == "refugee_bunk" and restored.campaign_available_nodes() == ["archive_causeway", "pilgrim_gantry"], "Veyru region, water pressure, graph state, and contract carrier should survive save/load")
	var bad_region := state.serialize()
	bad_region["campaign_region_id"] = "endless_ocean"
	_expect(not bool(LongMarchState.new(0).load_serialized(bad_region).get("ok", false)), "unknown campaign regions should be rejected before restore")
	var bad_carrier := state.serialize()
	bad_carrier["veyru_medicine_carrier_id"] = "shell_cannon"
	_expect(not bool(LongMarchState.new(0).load_serialized(bad_carrier).get("ok", false)), "the medicine contract should reject a carrier outside its authored cargo options")
	var missing_carrier := state.serialize()
	for index in range(missing_carrier["modules"].size() - 1, -1, -1):
		if String(missing_carrier["modules"][index].get("id", "")) == "refugee_bunk":
			missing_carrier["modules"].remove_at(index)
	_expect(not bool(LongMarchState.new(0).load_serialized(missing_carrier).get("ok", false)), "an accepted medicine contract should reject a checkpoint whose reserved carrier has been removed")
	var legacy := state.serialize()
	legacy["save_version"] = 6
	legacy.erase("campaign_region_id")
	legacy.erase("veyru_contract_status")
	legacy.erase("veyru_medicine_carrier_id")
	legacy["campaign_path"] = ["ashgate_depot"]
	legacy["campaign_last_safe_node"] = "ashgate_depot"
	legacy["current_location"] = "ashgate_depot"
	legacy["journey_node"] = "ashgate_depot"
	var legacy_restore := LongMarchState.new(0)
	_expect(bool(legacy_restore.load_serialized(legacy).get("ok", false)) and legacy_restore.campaign_region_id == "ashgate_lowlands" and legacy_restore.veyru_contract_status == "unoffered", "version-six checkpoints should migrate into the Ashgate region with no Veyru contract")
	var declined := LongMarchState.new(2204)
	declined.start_flooded_veyru()
	_expect(bool(declined.choose_veyru_medicine_contract(false).get("ok", false)) and declined.veyru_contract_status == "declined" and declined.mobility_tendency == 1 and declined.veyru_medicine_carrier_id.is_empty(), "declining the Veyru contract should preserve capacity and record the mobility tradeoff")

func _install_veyru_loadout(state: LongMarchState) -> void:
	_expect(bool(state.place_module("steam_lance_engine", Vector2i(0, 0)).get("ok", false)), "Veyru engine should install")
	_expect(bool(state.place_module("coal_cell", Vector2i(0, 1)).get("ok", false)), "Veyru fuel should install beside the engine")
	_expect(bool(state.place_module("generator_core", Vector2i(2, 0)).get("ok", false)), "Veyru generator should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(2, 1)).get("ok", false)), "Veyru crew quarters should install")
	_expect(bool(state.place_module("field_workshop", Vector2i(2, 2)).get("ok", false)), "Veyru workshop should install beside crew")
	_expect(bool(state.place_module("water_condenser", Vector2i(2, 3)).get("ok", false)), "Veyru condenser should install beside the workshop")
	_expect(bool(state.place_module("parts_crate", Vector2i(4, 2)).get("ok", false)), "Veyru medicine carrier should install beside the workshop")
	state.seed_starter_inventory()

func _veyru_battle(state: LongMarchState, node_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	var begun := state.begin_campaign_route(node_id, doctrine)
	if not bool(begun.get("ok", false)):
		return begun
	state.use_encounter_intervention("vent_heat")
	return state.advance_encounter(6.0)

func _test_flooded_veyru_threats_and_contract() -> void:
	var exposed := LongMarchState.new(2204)
	exposed.place_module("refugee_bunk", Vector2i(3, 2))
	exposed.campaign_region_id = "flooded_veyru"
	exposed.campaign_pressure = 3
	exposed.encounter_target_doctrine = "protect_crew"
	var exposed_profile := exposed._encounter_damage_profile("flood_surge", "refugee_bunk")
	_expect(int(exposed_profile.get("damage", 0)) == 2 and String(exposed_profile.get("threat_effect", "")) == "flood_pressure", "Flood Surge should add visible damage at Flooding water against an exposed carrier")

	var condensed := LongMarchState.new(2204)
	_install_water_condenser_loadout(condensed)
	condensed.place_module("parts_crate", Vector2i(4, 2))
	condensed.campaign_region_id = "flooded_veyru"
	condensed.campaign_pressure = 3
	condensed.encounter_target_doctrine = "protect_crew"
	var condensed_profile := condensed._encounter_damage_profile("flood_surge", "parts_crate")
	_expect(int(condensed_profile.get("damage", 0)) == 1 and String(condensed_profile.get("water_effect", "")) == "condenser_buffer", "a Ready Water Condenser should remove one Flood Surge damage without erasing the pressure rule")

	var armored := LongMarchState.new(2204)
	armored.place_module("parts_crate", Vector2i(4, 2))
	armored.place_module("side_armor_skirt", Vector2i(5, 2))
	armored.campaign_region_id = "flooded_veyru"
	armored.campaign_pressure = 3
	armored.encounter_target_doctrine = "protect_crew"
	var armored_profile := armored._encounter_damage_profile("flood_surge", "parts_crate")
	_expect(int(armored_profile.get("armor_absorbed", 0)) == 1 and int(armored_profile.get("damage", 0)) == 1, "a Side Armor Skirt should intercept Flood Surge before the rising-water pressure is applied")

	var teaching := LongMarchState.new(2204)
	_install_veyru_loadout(teaching)
	teaching.start_flooded_veyru()
	_expect(bool(teaching.choose_veyru_medicine_contract(true).get("ok", false)) and teaching.veyru_medicine_carrier_id == "parts_crate", "the Veyru fixture should reserve its exact cargo-capable Parts Crate")
	var carrier := teaching.module_at(Vector2i(4, 2))
	var rationale := teaching.encounter_target_rationale("flood_surge", carrier)
	_expect(String(rationale.get("reason", "")).contains("lower-deck exposure") and String(rationale.get("reason", "")).contains("sealed medicine carrier"), "Flood Surge should explain both the carrier obligation and lower-deck exposure")
	var opening := teaching.begin_campaign_route("pump_gallery", "protect_crew")
	_expect(bool(opening.get("ok", false)) and teaching.encounter_enemies.size() == 1 and String(teaching.encounter_enemies[0].get("id", "")) == "flood_surge", "Pump Gallery should teach Flood Surge without hiding another contact in the composition")
	var active_restore := LongMarchState.new(0)
	_expect(bool(active_restore.load_serialized(teaching.serialize()).get("ok", false)) and active_restore.encounter_active and String(active_restore.encounter_enemies[0].get("id", "")) == "flood_surge", "an active Veyru teaching encounter should survive save/load")
	var cut_loose := teaching.use_encounter_intervention("cut_loose_cargo")
	_expect(bool(cut_loose.get("ok", false)) and String(cut_loose.get("removed_module", "")) == "parts_crate" and teaching.veyru_contract_status == "failed" and teaching.encounter_active, "losing the reserved medicine carrier should fail the contract without ending the run")
	var failed_restore := LongMarchState.new(0)
	_expect(bool(failed_restore.load_serialized(teaching.serialize()).get("ok", false)) and failed_restore.veyru_contract_status == "failed" and failed_restore.veyru_medicine_carrier_id == "parts_crate", "a failed medicine contract should preserve its named carrier even when that carrier was cut loose")

	var sunken := LongMarchState.new(2204)
	_install_veyru_loadout(sunken)
	sunken.start_flooded_veyru()
	sunken.choose_veyru_medicine_contract(true)
	var route_choice_restore := LongMarchState.new(0)
	_expect(bool(route_choice_restore.load_serialized(sunken.serialize()).get("ok", false)) and route_choice_restore.campaign_available_nodes() == ["pump_gallery", "sunken_tramworks"], "the answered Veyru contract and opening route choice should survive save/load")
	var sunken_result := _veyru_battle(sunken, "sunken_tramworks", "protect_crew")
	_expect(bool(sunken_result.get("resolved", false)) and sunken.phase == "map" and sunken.hull_condition == 9 and sunken.campaign_path.has("sunken_tramworks"), "the prepared layout should survive Sunken Tramworks while paying its visible heavy-build hull cost")

	var combination := LongMarchState.new(2204)
	_install_veyru_loadout(combination)
	combination.start_flooded_veyru()
	combination.choose_veyru_medicine_contract(false)
	combination.current_location = "veyru_evacuation_camp"
	combination.journey_node = "veyru_evacuation_camp"
	combination.phase = "settlement"
	combination.campaign_path = ["lantern_quay", "pump_gallery", "veyru_evacuation_camp"]
	combination.campaign_last_safe_node = "veyru_evacuation_camp"
	combination.campaign_pressure = 2
	var registry := combination.begin_campaign_route("drowned_registry", "protect_crew")
	_expect(bool(registry.get("ok", false)) and combination.encounter_enemies.size() == 2 and String(combination.encounter_enemies[0].get("id", "")) == "flood_surge" and String(combination.encounter_enemies[1].get("id", "")) == "climbers", "Drowned Registry should expose the authored Flood Surge and Climbers combination")

	var replay_a := LongMarchState.new(2204)
	var replay_b := LongMarchState.new(2204)
	for replay_state in [replay_a, replay_b]:
		_install_veyru_loadout(replay_state)
		replay_state.start_flooded_veyru()
		replay_state.choose_veyru_medicine_contract(true)
		_veyru_battle(replay_state, "pump_gallery", "protect_cargo")
	_expect(replay_a.encounter_report == replay_b.encounter_report and replay_a.modules == replay_b.modules and replay_a.hull_condition == replay_b.hull_condition and replay_a.campaign_pressure == replay_b.campaign_pressure, "the Veyru teaching route should replay deterministically from the same seed, layout, contract, doctrine, and order")

func _test_veyru_public_archive_signal() -> void:
	var state := LongMarchState.new(2204)
	state.start_flooded_veyru()
	var before := state.campaign_node_preview("drowned_registry")
	_expect(String(before.get("visibility", "")) == "unscouted" and String(before.get("regional_development", "")).is_empty(), "Drowned Registry should begin unscouted without a prior regional development")
	var applied := state.set_regional_developments(["veyru_public_archive_signal"])
	var after := state.campaign_node_preview("drowned_registry")
	_expect(bool(applied.get("ok", false)) and String(after.get("visibility", "")) == "known" and String(after.get("regional_development", "")) == "Public Archive Signal", "Public Archive Signal should reveal the Registry's exact contacts without requiring a live signal module")
	_expect(after.get("threats", []) == ["Flood Surge", "Climber"] and not Array(after.get("risk_factors", [])).has("forecasting -8pt"), "the development should reveal information without granting the live forecasting risk discount")
	_expect(float(after.get("risk", 0.0)) == float(before.get("risk", 0.0)) and int(after.get("pressure_gain", 0)) == int(before.get("pressure_gain", 0)) and int(after.get("fuel", 0)) == int(before.get("fuel", 0)) and int(after.get("days", 0)) == int(before.get("days", 0)), "the information development should not alter Registry risk, pressure, fuel, or time")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(state.serialize()).get("ok", false)) and restored.has_regional_development("veyru_public_archive_signal"), "active regional developments should survive the run save envelope")
	var legacy_payload := state.serialize()
	legacy_payload["save_version"] = 7
	legacy_payload.erase("regional_developments")
	var legacy_restore := LongMarchState.new(0)
	_expect(bool(legacy_restore.load_serialized(legacy_payload).get("ok", false)) and legacy_restore.regional_developments.is_empty(), "schema-7 saves should migrate with no invented regional development")
	var invalid_payload := state.serialize()
	invalid_payload["regional_developments"] = ["perfect_forecast"]
	_expect(not bool(LongMarchState.new(0).load_serialized(invalid_payload).get("ok", false)), "unknown regional developments should be rejected before mutating restored state")
	state.phase = "results"
	state.final_result = "archive_scarred"
	state.run_complete = true
	state.journey_complete = true
	state.campaign_decisions["archive_broadcast"] = "broadcast_archive"
	_expect(state.earned_regional_development() == "veyru_public_archive_signal", "surviving after the public archive broadcast should earn its named regional development")
	state.campaign_decisions["archive_broadcast"] = "seal_archive"
	_expect(state.earned_regional_development().is_empty(), "sealing the archive should not silently earn the public signal development")

func _test_authored_intel_purchase() -> void:
	var state := LongMarchState.new(1107)
	state.start_campaign()
	var before := state.campaign_node_preview("soot_orchard")
	var money_before := state.money
	_expect(String(before.get("visibility", "")) == "forecast" and Array(before.get("threats", [])).is_empty(), "Soot Orchard should begin with uncertain exact contacts when the fortress has no live forecast")
	var purchase := state.purchase_intel("ashgate_orchard_weather_report")
	var after := state.campaign_node_preview("soot_orchard")
	_expect(bool(purchase.get("ok", false)) and state.money == money_before - 8 and state.acquired_intel_ids == ["ashgate_orchard_weather_report"], "the Ashgate report should atomically spend its exact price and enter the route ledger")
	_expect(String(after.get("visibility", "")) == "known" and after.get("threats", []) == ["Storm Front"] and not Array(after.get("counter_hints", [])).is_empty(), "the purchased report should reveal the authored Orchard contact and counter guidance")
	_expect(String(after.get("intel_source", "")) == "Ashgate Signal Reader" and String(after.get("intel_confidence", "")) == "reliable", "purchased route intelligence should retain its source and confidence")
	var comparison_source := ""
	for route in state.campaign_route_comparison():
		if String(route.get("id", "")) == "soot_orchard":
			comparison_source = "%s · %s" % [String(route.get("intel_source", "")), String(route.get("intel_confidence", ""))]
	_expect(comparison_source == "Ashgate Signal Reader · reliable", "the route comparison should preserve purchased intel attribution")
	_expect(float(after.get("risk", 0.0)) == float(before.get("risk", 0.0)) and int(after.get("encounter_pressure", 0)) == int(before.get("encounter_pressure", 0)) and int(after.get("fuel", 0)) == int(before.get("fuel", 0)) and int(after.get("days", 0)) == int(before.get("days", 0)), "purchased information should not grant the live forecasting risk or difficulty discount")
	var duplicate_money := state.money
	_expect(not bool(state.purchase_intel("ashgate_orchard_weather_report").get("ok", false)) and state.money == duplicate_money, "a duplicate report purchase should fail without charging twice")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(state.serialize()).get("ok", false)) and restored.acquired_intel_ids == ["ashgate_orchard_weather_report"] and String(restored.campaign_node_preview("soot_orchard").get("intel_source", "")) == "Ashgate Signal Reader", "purchased intel and its route effect should survive save/load")
	var legacy_payload := state.serialize()
	legacy_payload["save_version"] = 8
	legacy_payload.erase("acquired_intel_ids")
	var legacy_restore := LongMarchState.new(0)
	_expect(bool(legacy_restore.load_serialized(legacy_payload).get("ok", false)) and legacy_restore.acquired_intel_ids.is_empty(), "schema-8 saves should migrate without inventing a purchase")
	var invalid_payload := state.serialize()
	invalid_payload["acquired_intel_ids"] = ["invented_report"]
	_expect(not bool(LongMarchState.new(0).load_serialized(invalid_payload).get("ok", false)), "unknown acquired intel records should be rejected before state restoration")
	var duplicate_payload := state.serialize()
	duplicate_payload["acquired_intel_ids"] = ["ashgate_orchard_weather_report", "ashgate_orchard_weather_report"]
	_expect(not bool(LongMarchState.new(0).load_serialized(duplicate_payload).get("ok", false)), "duplicate acquired intel records should be rejected")
	var poor_state := LongMarchState.new(1107)
	poor_state.start_campaign()
	poor_state.money = 7
	_expect(not bool(poor_state.purchase_intel("ashgate_orchard_weather_report").get("ok", false)) and poor_state.money == 7 and poor_state.acquired_intel_ids.is_empty(), "an unaffordable report should leave money and the route ledger unchanged")

func _test_complete_flooded_veyru_campaign() -> void:
	var state := LongMarchState.new(2204)
	_install_veyru_loadout(state)
	state.start_flooded_veyru()
	_expect(bool(state.choose_veyru_medicine_contract(true).get("ok", false)), "the complete Veyru route should accept the medicine contract")
	var first := _veyru_battle(state, "pump_gallery", "protect_cargo")
	_expect(bool(first.get("resolved", false)) and state.campaign_event_pending == "drain_pumps", "the first Veyru encounter should secure Pump Gallery and expose its water decision")
	_expect(bool(state.resolve_campaign_event("drain_gallery").get("ok", false)) and state.campaign_pressure == 0, "draining Pump Gallery should trade one day for two water pressure")
	var second := _veyru_battle(state, "veyru_evacuation_camp", "protect_cargo")
	_expect(bool(second.get("resolved", false)) and state.phase == "settlement" and state.settlement_actions_remaining == 2 and state.campaign_last_safe_node == "veyru_evacuation_camp", "an operational medicine carrier should earn two camp actions and establish Veyru's recovery anchor")
	var camp_restore := LongMarchState.new(0)
	_expect(bool(camp_restore.load_serialized(state.serialize()).get("ok", false)) and camp_restore.phase == "settlement" and camp_restore.campaign_last_safe_node == "veyru_evacuation_camp", "Evacuation Camp recovery state should survive save/load")
	state.hull_condition = 8
	_expect(bool(state.settlement_repair_hull().get("ok", false)) and state.hull_condition == 10 and state.settlement_actions_remaining == 1, "Evacuation Camp should provide the authored two-hull service for one action")
	state.fuel = 1
	_expect(bool(state.settlement_refuel().get("ok", false)) and state.fuel == 2 and state.settlement_actions_remaining == 0, "Evacuation Camp should provide one free emergency fuel below two fuel")
	state.fuel = 5
	var third := _veyru_battle(state, "archive_causeway", "protect_cargo")
	_expect(bool(third.get("resolved", false)) and state.phase == "map", "Archive Causeway should resolve as the third Veyru encounter")
	var fourth := _veyru_battle(state, "dry_archive_gate", "protect_cargo")
	_expect(bool(fourth.get("resolved", false)) and state.campaign_event_pending == "archive_broadcast", "Dry Archive Gate should block departure on the archive commitment")
	var choice_restore := LongMarchState.new(0)
	_expect(bool(choice_restore.load_serialized(state.serialize()).get("ok", false)) and choice_restore.campaign_event_pending == "archive_broadcast", "the final archive commitment should survive save/load")
	var broadcast_state := LongMarchState.new(0)
	broadcast_state.load_serialized(state.serialize())
	_expect(bool(broadcast_state.resolve_campaign_event("broadcast_archive").get("ok", false)), "broadcasting the archive should resolve the final commitment")
	var broadcast_departure := broadcast_state.begin_campaign_route("dry_archive", "protect_cargo")
	_expect(bool(broadcast_departure.get("ok", false)) and broadcast_state.encounter_enemies.size() == 2 and String(broadcast_state.encounter_enemies[1].get("id", "")) == "climbers", "broadcasting should add Climbers to the Civic Guardian final contact")

	var pressure_before_seal := state.campaign_pressure
	_expect(bool(state.resolve_campaign_event("seal_archive").get("ok", false)) and state.campaign_pressure == maxi(0, pressure_before_seal - 1), "sealing the archive should lower rising water before the final approach")
	var final_preview := state.campaign_node_preview("dry_archive")
	_expect(String(final_preview.get("visibility", "")) == "forecast" and Array(final_preview.get("threats", [])).is_empty(), "the sealed archive approach should keep exact final targeting at forecast confidence")
	var fifth := _veyru_battle(state, "dry_archive", "protect_cargo")
	_expect(bool(fifth.get("resolved", false)) and state.phase == "results" and state.run_complete and state.campaign_encounters_completed == 5, "the fifth Veyru encounter should end the isolated chapter")
	_expect(state.final_result == "archive_kept" and state.veyru_contract_status == "completed" and state.settlement_trust == 2, "an operational medicine carrier and sound hull should produce Archive Kept and complete the delivery")
	var result_restore := LongMarchState.new(0)
	_expect(bool(result_restore.load_serialized(state.serialize()).get("ok", false)) and result_restore.final_result == "archive_kept" and result_restore.veyru_contract_status == "completed", "the Veyru result and completed medicine contract should survive save/load")

	var retreat := LongMarchState.new(2204)
	_install_veyru_loadout(retreat)
	retreat.start_flooded_veyru()
	retreat.choose_veyru_medicine_contract(false)
	retreat.campaign_path = ["lantern_quay", "pump_gallery", "veyru_evacuation_camp", "archive_causeway"]
	retreat.campaign_last_safe_node = "veyru_evacuation_camp"
	retreat.current_location = "dry_archive_gate"
	retreat.journey_node = "dry_archive_gate"
	retreat.campaign_target_node = "dry_archive_gate"
	retreat.phase = "battle"
	retreat.encounter_active = true
	var recovered := retreat._finish_campaign_encounter(false)
	_expect(bool(recovered.get("resolved", false)) and retreat.current_location == "veyru_evacuation_camp" and retreat.phase == "settlement" and retreat.campaign_retreats == 1 and retreat.campaign_edges()["veyru_evacuation_camp"].has("pilgrim_gantry"), "a non-final Veyru failure should retreat to Evacuation Camp and permanently expose Pilgrim Gantry")
func _test_water_condenser_route_unlock() -> void:
	var locked_state := LongMarchState.new(1107)
	locked_state.start_campaign()
	locked_state.choose_guard_contract(false)
	locked_state.current_location = "morrowline_camp"
	locked_state.phase = "settlement"
	_expect(locked_state.campaign_available_nodes() == ["lower_ash_road", "signal_causeway", "cinder_quarry"], "Dry Cistern Cut should stay unavailable without a Ready Water Condenser while Cinder Quarry remains open")
	_expect(String(locked_state.campaign_node_lock_reason("dry_cistern_cut")).contains("Ready Water Condenser"), "the locked dry road should name its system requirement")
	var blocked_departure := locked_state.begin_campaign_route("dry_cistern_cut")
	_expect(not bool(blocked_departure.get("ok", false)) and String(blocked_departure.get("reason", "")).contains("Field Workshop"), "attempting the locked dry road should return its actionable maintenance requirement")

	var ready_state := LongMarchState.new(1107)
	ready_state.place_module("steam_lance_engine", Vector2i(0, 0))
	ready_state.place_module("coal_cell", Vector2i(0, 1))
	ready_state.place_module("generator_core", Vector2i(2, 0))
	ready_state.place_module("crew_quarters", Vector2i(2, 2))
	ready_state.place_module("field_workshop", Vector2i(2, 1))
	ready_state.place_module("water_condenser", Vector2i(4, 1))
	ready_state.start_campaign()
	ready_state.choose_guard_contract(false)
	ready_state.current_location = "morrowline_camp"
	ready_state.phase = "settlement"
	_expect(ready_state.total_mass() == 13 and ready_state.total_heat() == LongMarchState.BASE_HEAT_LIMIT, "the cool condenser fixture should remain within both chassis mass and heat limits by giving up weapon coverage")
	_expect(ready_state.campaign_available_nodes() == ["lower_ash_road", "dry_cistern_cut", "signal_causeway", "cinder_quarry"], "a Ready Water Condenser should add Dry Cistern Cut alongside the three baseline Morrowline roads")
	var preview := ready_state.campaign_node_preview("dry_cistern_cut")
	_expect(int(preview.get("fuel", 0)) == 1 and int(preview.get("fuel_discount", 0)) == 1, "the Ready Water Condenser should reduce Dry Cistern Cut from two fuel to one")
	var comparison := ready_state.campaign_route_comparison()
	_expect(comparison.size() == 4 and String(comparison[1].get("id", "")) == "dry_cistern_cut" and int(comparison[1].get("fuel", 0)) == 1 and int(comparison[1].get("fuel_discount", 0)) == 1, "route comparison should include the unlocked dry road and its explicit condenser fuel discount")
	var fuel_before := ready_state.fuel
	var departure := ready_state.begin_campaign_route("dry_cistern_cut", "protect_crew")
	_expect(bool(departure.get("ok", false)) and ready_state.fuel == fuel_before - 1, "committing to Dry Cistern Cut should charge the discounted fuel cost")
	_expect(ready_state.encounter_enemies.size() == 1 and String(ready_state.encounter_enemies[0].get("id", "")) == "storm_front", "Dry Cistern Cut should begin its authored Storm Front encounter")

func _install_water_condenser_loadout(state: LongMarchState) -> void:
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 2))
	state.place_module("field_workshop", Vector2i(2, 1))
	state.place_module("water_condenser", Vector2i(4, 1))

func _test_water_condenser_threat_and_recovery() -> void:
	var vulnerable := LongMarchState.new(1107)
	_install_water_condenser_loadout(vulnerable)
	vulnerable.journey_route = "dry_cistern_cut"
	var condenser := vulnerable.module_at(Vector2i(4, 1))
	var rationale := vulnerable.encounter_target_rationale("storm_front", condenser)
	_expect(vulnerable._encounter_choose_target("storm_front") == "water_condenser" and String(rationale.get("reason", "")).contains("dry-road sustain role"), "Storm Front should select and explain the condenser's dry-road sustain vulnerability")
	var impact := vulnerable.encounter_enemy_impact_preview({"id": "storm_front", "arrived": true, "defeated": false, "target": "water_condenser", "damage_bonus": 0})
	_expect(int(impact.get("damage", 0)) == 2 and String(impact.get("threat_effect", "")) == "sustain_exposure", "an exposed sustain system should preview one additional Storm Front damage")
	vulnerable._encounter_apply_enemy_damage("storm_front", "water_condenser")
	_expect(int(vulnerable.module_at(Vector2i(4, 1)).get("durability", 0)) == 1 and vulnerable.encounter_report[-2].contains("Dry-system exposure"), "the Storm Front report should explain the condenser's extra damage before recording the hit")
	_expect(bool(vulnerable.repair_module("water_condenser", 1).get("ok", false)) and int(vulnerable.module_at(Vector2i(4, 1)).get("durability", 0)) == 2, "an operational Field Workshop should repair a damaged Water Condenser")
	vulnerable.phase = "settlement"
	vulnerable.current_location = "morrowline_camp"
	vulnerable.settlement_actions_remaining = 1
	vulnerable.money = 8
	var settlement_repair := vulnerable.settlement_repair("water_condenser")
	_expect(bool(settlement_repair.get("ok", false)) and int(vulnerable.module_at(Vector2i(4, 1)).get("durability", 0)) == 3, "Morrowline service should fully restore the damaged Water Condenser")

	var armored := LongMarchState.new(1107)
	armored.place_module("ash_runner_engine", Vector2i(0, 0))
	armored.place_module("coal_cell", Vector2i(1, 0))
	armored.place_module("generator_core", Vector2i(2, 0))
	armored.place_module("crew_quarters", Vector2i(2, 2))
	armored.place_module("field_workshop", Vector2i(2, 1))
	armored.place_module("water_condenser", Vector2i(4, 1))
	armored.place_module("side_armor_skirt", Vector2i(5, 2))
	_expect(armored.total_mass() == LongMarchState.BASE_MASS_LIMIT and armored.total_heat() > LongMarchState.BASE_HEAT_LIMIT and armored.dependency_status_at(Vector2i(4, 1)).state == "ready", "the heavy condenser fixture should be legal and protected while visibly paying the maximum-mass and overheat costs")
	var armored_preview := armored.encounter_enemy_impact_preview({"id": "storm_front", "arrived": true, "defeated": false, "target": "water_condenser", "damage_bonus": 0})
	_expect(int(armored_preview.get("damage", 0)) == 1 and int(armored_preview.get("armor_absorbed", 0)) == 1, "adjacent armor should absorb one point of the condenser's Storm Front hit")

	var sealed := LongMarchState.new(1107)
	_install_water_condenser_loadout(sealed)
	sealed.journey_node = "dry_cistern_cut"
	sealed.journey_route = "dry_cistern_cut"
	sealed._configure_encounter(["storm_front"], "Dry Cistern Cut", "A dry weather line closes over the cisterns.")
	sealed.encounter_enemies[0]["arrived"] = true
	sealed.encounter_enemies[0]["target"] = "water_condenser"
	var seal_result := sealed.use_encounter_intervention("seal_compartment", "water_condenser")
	_expect(bool(seal_result.get("ok", false)) and String(sealed.encounter_enemies[0].get("target", "")) != "water_condenser", "Seal Compartment should immediately redirect a Storm Front away from the Water Condenser")
	_expect(sealed.dependency_status_at(Vector2i(4, 1)).state == "offline" and String(seal_result.get("effect", "")).contains("protected from targeting"), "sealing the condenser should expose its temporary offline trade-off")
	sealed._clear_temporary_seals()
	_expect(sealed.dependency_status_at(Vector2i(4, 1)).state == "ready", "the condenser should return to Ready after the encounter seal clears")

	var first := LongMarchState.new(1107)
	var second := LongMarchState.new(1107)
	for replay_state in [first, second]:
		_install_water_condenser_loadout(replay_state)
		replay_state.start_campaign()
		replay_state.choose_guard_contract(false)
		replay_state.current_location = "morrowline_camp"
		replay_state.phase = "settlement"
		replay_state.begin_campaign_route("dry_cistern_cut", "protect_crew")
		replay_state.advance_encounter(6.0)
	_expect(first.encounter_report == second.encounter_report and first.modules == second.modules and first.hull_condition == second.hull_condition, "the Water Condenser teaching encounter should replay deterministically from the same seed, layout, and doctrine")

func _prepare_cinder_quarry_state() -> LongMarchState:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	state.choose_guard_contract(false)
	state.choose_mastery_experiment("ashgate_quarry_adaptation")
	state.current_location = "morrowline_camp"
	state.journey_node = "morrowline_camp"
	state.campaign_last_safe_node = "morrowline_camp"
	state.campaign_path = ["ashgate_depot", "rill_crossing", "broken_relay", "morrowline_camp"]
	state.campaign_encounters_completed = 3
	state.campaign_event_pending = ""
	state.phase = "settlement"
	return state

func _test_cinder_quarry_route_branch() -> void:
	var repair_state := _prepare_cinder_quarry_state()
	repair_state._change_module_durability("crew_quarters", -1)
	var repair_result := repair_state._apply_cinder_quarry_recovery()
	_expect(String(repair_result.get("kind", "")) == "repair" and String(repair_result.get("module_id", "")) == "crew_quarters" and int(repair_result.get("amount", 0)) == 1 and repair_state.operational("crew_quarters"), "Cinder Quarry plate crews should restore up to 2 durability to the deterministic weakest damaged system")
	var sale_state := _prepare_cinder_quarry_state()
	var money_before := sale_state.money
	var sale_result := sale_state._apply_cinder_quarry_recovery()
	_expect(String(sale_result.get("kind", "")) == "ashmarks" and sale_state.money == money_before + 8, "Cinder Quarry should sell unused plate for 8 Ashmarks when no system needs repair")

	var first := _prepare_cinder_quarry_state()
	first._change_module_durability("crew_quarters", -1)
	var preview := first.campaign_node_preview("cinder_quarry", "run_hot")
	_expect(bool(preview.get("ok", false)) and int(preview.get("days", 0)) == 1 and int(preview.get("fuel", 0)) == 2 and int(preview.get("pressure_gain", 0)) == 1 and String(preview.get("risk_band", "")) == "high", "Cinder Quarry should disclose its fast, fuel-heavy, high-risk route cost")
	_expect(String(preview.get("route_effect", "")).contains("weakest damaged system") and String(preview.get("threat_hint", "")).contains("raiders above"), "Cinder Quarry should disclose its field-repair payoff and two-direction threat forecast")
	var departure := first.begin_campaign_route("cinder_quarry", "run_hot")
	_expect(bool(departure.get("ok", false)) and first.encounter_enemies.size() == 2 and String(first.encounter_enemies[0].get("id", "")) == "road_raiders" and String(first.encounter_enemies[1].get("id", "")) == "burrowers", "Cinder Quarry should combine the existing cargo and lower-hull threat families in stable order")
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(first.serialize()).get("ok", false)) and restored.campaign_target_node == "cinder_quarry" and restored.encounter_enemies == first.encounter_enemies, "an active Cinder Quarry route should preserve its node and encounter composition across save/load")
	for replay_state in [first, restored]:
		replay_state.advance_encounter(1.0)
		replay_state.use_encounter_intervention("shift_power")
		replay_state.advance_encounter(6.0)
	_expect(first.encounter_report == restored.encounter_report and first.modules == restored.modules and first.hull_condition == restored.hull_condition, "Cinder Quarry should replay deterministically from the same saved contact")
	_expect(first.phase == "map" and first.current_location == "cinder_quarry" and first.campaign_available_nodes() == ["meridian_pass"], "securing Cinder Quarry should preserve the five-encounter path and expose Meridian Pass")
	_expect(bool(first.mastery_experiment_details().get("proven", false)) and String(first.mastery_experiment_details().get("status", "")) == "PROVEN", "Run Hot should prove Quarry Adaptation when Cinder Quarry is secured")
	_expect(first.encounter_report.filter(func(line: String) -> bool: return line.contains("Cinder Quarry recovery:")).size() == 1, "Cinder Quarry victory should record exactly one field-recovery consequence")

	var armored := LongMarchState.new(1107)
	armored.place_module("steam_lance_engine", Vector2i(0, 0))
	armored.place_module("coal_cell", Vector2i(0, 1))
	armored.place_module("side_armor_skirt", Vector2i(1, 1))
	armored.place_module("generator_core", Vector2i(2, 0))
	armored.place_module("ammunition_lift", Vector2i(2, 1))
	armored.place_module("repeater_gun", Vector2i(3, 2), true)
	armored.place_module("crew_quarters", Vector2i(4, 0))
	armored.seed_starter_inventory()
	armored.start_campaign()
	armored.choose_guard_contract(false)
	armored.choose_mastery_experiment("ashgate_quarry_adaptation")
	armored.current_location = "morrowline_camp"
	armored.journey_node = "morrowline_camp"
	armored.campaign_last_safe_node = "morrowline_camp"
	armored.campaign_path = ["ashgate_depot", "rill_crossing", "broken_relay", "morrowline_camp"]
	armored.campaign_encounters_completed = 3
	armored.phase = "settlement"
	_expect(bool(armored.begin_campaign_route("cinder_quarry", "protect_cargo").get("ok", false)), "an armored cargo-protection plan should be able to commit to Cinder Quarry")
	armored.advance_encounter(1.0)
	armored.use_encounter_intervention("shift_power")
	armored.advance_encounter(6.0)
	_expect(armored.phase == "map" and armored.current_location == "cinder_quarry" and armored.encounter_report.filter(func(line: String) -> bool: return line.contains("Side Armor Skirt absorbs")).size() > 0, "lower-hull armor should provide a second viable Cinder Quarry plan without Run Hot")
	_expect(bool(armored.mastery_experiment_details().get("proven", false)), "Protect Cargo and lower-hull armor should prove the same Quarry Adaptation order through a second solution")

func _test_complete_five_encounter_campaign() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	state.start_campaign()
	state.choose_mastery_experiment("ashgate_signal_discipline")
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
	_expect(bool(state.mastery_experiment_details().get("proven", false)), "Iven's forecast should prove Signal Discipline through the specialist solution")
	var fifth := _campaign_battle(state, "meridian_pass")
	_expect(bool(fifth.get("resolved", false)) and state.phase == "results", "the fifth campaign encounter should resolve at Meridian Pass")
	_expect(state.campaign_encounters_completed == 5 and state.run_complete, "the alpha chapter should complete exactly five encounters")
	_expect(state.final_result in ["decisive_march", "scarred_march"], "a surviving five-encounter campaign should produce a final result")

func _test_alternate_five_encounter_campaign() -> void:
	var state := LongMarchState.new(1107)
	_install_campaign_signal_loadout(state)
	_expect(bool(state.deploy_stored_module("wall_lamp", Vector2i(5, 2)).get("ok", false)), "the alternate complete route should prepare an exterior signal counter")
	state.start_campaign()
	state.choose_mastery_experiment("ashgate_signal_discipline")
	state.choose_guard_contract(false)
	var first := _campaign_battle(state, "soot_orchard", "protect_crew")
	_expect(bool(first.get("resolved", false)) and state.phase == "map", "the Soot Orchard opening should survive as part of a complete route")
	_expect(bool(state.resolve_campaign_event("take_fuel").get("ok", false)), "the alternate route should convert the orchard into fuel")
	var second := _campaign_battle(state, "red_wheel_toll_bridge", "protect_cargo")
	_expect(bool(second.get("resolved", false)) and state.phase == "map", "the Red Wheel branch should survive as part of a complete route")
	_expect(bool(state.resolve_campaign_event("pay_toll").get("ok", false)), "the alternate route should be able to reduce pressure at the toll")
	_expect(String(state.campaign_decisions.get("salvage_choice", "")) == "take_fuel" and String(state.campaign_decisions.get("toll_decision", "")) == "pay_toll", "the alternate route should retain both authored decisions for its eventual debrief")
	var third := _campaign_battle(state, "morrowline_camp", "protect_cargo")
	_expect(bool(third.get("resolved", false)) and state.phase == "settlement", "the alternate first half should reach Morrowline recovery")
	_expect(state.settlement_actions_remaining == 1, "the alternate declined-contract route should reach Morrowline with one scarce recovery action")
	_expect(bool(state.resolve_campaign_event("decline_mara").get("ok", false)), "the alternate route should be able to decline Mara and preserve its existing recovery plan")
	_expect(bool(state.settlement_repair("wall_lamp").get("ok", false)), "the alternate route should restore its storm counter at Morrowline")
	_expect(not bool(state.settlement_refuel().get("ok", false)), "the convoy shortage should force the alternate route to choose repair instead of also refueling")
	var fourth := _campaign_battle(state, "signal_causeway", "protect_crew")
	_expect(bool(fourth.get("resolved", false)) and state.phase == "map", "ready signal equipment should keep the alternate route viable through Signal Causeway")
	_expect(bool(state.mastery_experiment_details().get("proven", false)), "an operational Wall Lamp should prove Signal Discipline without recruiting Iven")
	var fifth := _campaign_battle(state, "meridian_pass", "protect_crew")
	_expect(bool(fifth.get("resolved", false)) and state.phase == "results" and state.run_complete, "the alternate five-encounter route should reach a terminal debrief")
	_expect(state.campaign_encounters_completed == 5 and state.final_result in ["decisive_march", "scarred_march"], "the alternate route should complete all five encounters without relying on the relay branch or Iven")

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
