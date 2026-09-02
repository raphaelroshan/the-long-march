extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const SettlementPresenter = preload("res://src/presentation/settlement_presenter.gd")

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _staffed_state(facility_id: String) -> LongMarchState:
	var state := LongMarchState.new(4404)
	_expect(bool(state.place_module("generator_core", Vector2i(0, 0)).get("ok", false)), "generator should install")
	_expect(bool(state.place_module("crew_quarters", Vector2i(2, 0)).get("ok", false)), "crew quarters should install")
	_expect(bool(state.place_module(facility_id, Vector2i(2, 1)).get("ok", false)), "%s should install" % facility_id)
	return state


func _test_facility_dependencies_and_sela() -> void:
	var isolated := LongMarchState.new(4404)
	isolated.place_module("generator_core", Vector2i(0, 0))
	isolated.place_module("command_deck", Vector2i(2, 1))
	_expect(not isolated.operational("command_deck"), "Command Deck should be offline without adjacent crew")
	var state := _staffed_state("command_deck")
	_expect(state.operational("command_deck"), "Command Deck should become Ready beside crew with stable power")
	state.start_white_salt_expanse()
	var baseline := state.campaign_node_preview("buried_observatory", "run_hot")
	var assigned := state.assign_specialist("sela_vonn")
	var accelerated := state.campaign_node_preview("buried_observatory", "run_hot")
	_expect(bool(assigned.get("ok", false)) and state.specialist_name() == "Sela Vonn", "Sela should join only through a staffed Command Deck")
	var hub := SettlementPresenter.build(state, state.summary(), {})
	var hiring: Dictionary = Dictionary(hub.get("stations", {})).get("hiring_post", {})
	_expect(String(hiring.get("status", "")) == "ASSIGNED" and String(hiring.get("button_status", "")).contains("SELA"), "Saltglass hiring presentation should show the assigned specialist instead of debug state")
	_expect(int(accelerated.get("days", 0)) == int(baseline.get("days", 0)) - 1, "Sela should shorten a multi-day Run Hot route")
	_expect(is_equal_approx(float(accelerated.get("risk", 0.0)), float(baseline.get("risk", 0.0)) + 0.04), "Sela's fast line should disclose its four-point risk cost")
	_expect(int(state._encounter_module_damage("signal_hunters").get("damage", 0)) >= 2, "a Ready Command Deck should actively counter Signal Hunters")
	var duplicate := state.assign_specialist("nera_quill")
	_expect(not bool(duplicate.get("ok", true)), "one fortress cannot silently replace an assigned specialist")
	var payload := state.serialize()
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(payload)
	_expect(bool(result.get("ok", false)) and restored.specialist_id == "sela_vonn" and restored.operational("command_deck"), "Sela and her staffed facility should survive exact save/load")
	_expect(restored.serialize() == payload, "LM-EA-4 specialist state should round-trip exactly")
	var tampered := payload.duplicate(true)
	tampered["specialist_id"] = "invented_specialist"
	_expect(not bool(LongMarchState.new(0).load_serialized(tampered).get("ok", true)), "unknown specialist IDs must be rejected")


func _test_nera_and_bridgebreaker_counterplay() -> void:
	var state := _staffed_state("infirmary")
	state.start_white_salt_expanse()
	var before := state._encounter_damage_profile("signal_hunters", "crew_quarters")
	var assigned := state.assign_specialist("nera_quill")
	var after := state._encounter_damage_profile("signal_hunters", "crew_quarters")
	_expect(bool(assigned.get("ok", false)) and state.operational("infirmary"), "Nera should join through a staffed Field Infirmary")
	_expect(int(after.get("damage", -1)) == maxi(0, int(before.get("damage", 0)) - 1), "Nera should reduce crew damage by exactly one")
	var crane_state := _staffed_state("infirmary")
	_expect(bool(crane_state.place_module("salvage_crane", Vector2i(5, 0), true).get("ok", false)), "Salvage Crane should consume an exterior mount")
	var armor_result := crane_state.place_module("side_armor_skirt", Vector2i(4, 2))
	_expect(bool(armor_result.get("ok", false)), "Side armor should install as a Bridgebreaker target: %s" % String(armor_result.get("reason", "unknown")))
	var response := crane_state._encounter_module_damage("bridgebreakers")
	_expect(int(response.get("damage", 0)) >= 2 and Array(response.get("attackers", [])).has("salvage_crane"), "Salvage Crane should visibly brace a Bridgebreaker approach")
	var target := crane_state.encounter_target_rationale("bridgebreakers", crane_state.modules.back())
	_expect(bool(target.get("eligible", false)), "Bridgebreakers should recognize engine, lower-hull, or armor targets through authored tags")


func _init() -> void:
	_test_facility_dependencies_and_sela()
	_test_nera_and_bridgebreaker_counterplay()
	_expect(LongMarchState.MODULE_DEFS.has("infirmary") and LongMarchState.MODULE_DEFS.has("command_deck") and LongMarchState.MODULE_DEFS.has("salvage_crane"), "all LM-EA-4 modules should use stable runtime IDs")
	_expect(LongMarchState.ENCOUNTER_ENEMIES.has("signal_hunters") and LongMarchState.ENCOUNTER_ENEMIES.has("bridgebreakers"), "all LM-EA-4 threats should use stable runtime IDs")
	if failures.is_empty():
		print("PASS: The Long March Early Access systems")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
