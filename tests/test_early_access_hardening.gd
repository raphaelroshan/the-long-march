extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const SettlementPresenter = preload("res://src/presentation/settlement_presenter.gd")

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _cinder_state(seed_value: int, workshop: bool = false) -> LongMarchState:
	var state := LongMarchState.new(seed_value)
	state.choose_chassis_template("ridge_crawler")
	state.place_module("ash_runner_engine", Vector2i(0, 0), false, true)
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 1))
	if workshop:
		state.place_module("field_workshop", Vector2i(2, 2))
	state.start_cinder_spine()
	return state


func _test_scope_and_chassis() -> void:
	_expect(LongMarchState.VALID_CAMPAIGN_REGIONS.size() == 4, "candidate should contain four playable region contracts")
	_expect(LongMarchState.VALID_CHASSIS_TEMPLATES.size() == 3 and LongMarchState.MODULE_DEFS.size() == 20, "candidate should meet chassis and module breadth floors")
	_expect(LongMarchState.VALID_SPECIALIST_IDS.size() - 1 >= 6 and LongMarchState.THREATS.size() >= 10, "candidate should meet specialist and threat breadth floors")
	_expect(LongMarchState.CAMPAIGN_DECISION_OPTIONS.size() >= 20 and LongMarchState.VALID_REGIONAL_DEVELOPMENTS.size() >= 4, "candidate should meet event and regional-memory breadth floors")
	var chassis := LongMarchState.new(6601)
	_expect(bool(chassis.choose_chassis_template("ridge_crawler").get("ok", false)), "Ridge Crawler should be a selectable stable chassis")
	_expect(chassis.chassis_mass_limit() == 15 and chassis.chassis_exterior_limit() == 2, "Ridge Crawler should trade a heavier frame for standard exterior capacity")
	_expect(not chassis.chassis_cell_available(Vector2i(0, 3)) and not chassis.chassis_cell_available(Vector2i(1, 3)) and chassis.chassis_cell_available(Vector2i(5, 3)), "Ridge Crawler should expose its paired rear cut-away")
	var payload := chassis.serialize()
	var restored := LongMarchState.new(0)
	_expect(bool(restored.load_serialized(payload).get("ok", false)) and restored.chassis_template_id == "ridge_crawler", "Ridge Crawler should survive save/load")
	var tampered := payload.duplicate(true)
	tampered["modules"] = [{"id": "parts_crate", "position": [0, 3], "exterior": false, "rotated": false, "durability": 2, "sealed": false}]
	_expect(not bool(LongMarchState.new(0).load_serialized(tampered).get("ok", true)), "save validation should reject a module inside the Ridge Crawler cut-away")
	var compatibility_source := LongMarchState.new(6602)
	compatibility_source.set_prior_obligations({"ashgate_lowlands": "completed"})
	var current_save := compatibility_source.serialize()
	for supported_version in range(LongMarchState.MIN_SUPPORTED_SAVE_VERSION, LongMarchState.SAVE_VERSION + 1):
		var supported_save := current_save.duplicate(true)
		supported_save["save_version"] = supported_version
		if supported_version < 16:
			supported_save.erase("prior_obligations")
		var migrated := LongMarchState.new(0)
		_expect(bool(migrated.load_serialized(supported_save).get("ok", false)), "declared save schema %d should remain loadable" % supported_version)
		_expect(migrated.prior_obligations.is_empty() if supported_version < 16 else migrated.prior_obligation_status("ashgate_lowlands") == "completed", "schema %d should preserve only history available in that format" % supported_version)
	var future_save := current_save.duplicate(true)
	future_save["save_version"] = LongMarchState.SAVE_VERSION + 1
	_expect(not bool(LongMarchState.new(0).load_serialized(future_save).get("ok", true)), "future save versions should remain blocked")


func _test_specialists() -> void:
	var orla := _cinder_state(6603)
	var baseline := orla.campaign_node_preview("charcoal_monastery")
	var hub := SettlementPresenter.build(orla, orla.summary(), {})
	var hiring: Dictionary = Dictionary(hub.get("stations", {})).get("hiring_post", {})
	_expect(bool(Dictionary(hiring.get("primary", {})).get("enabled", false)) and not bool(Dictionary(hiring.get("secondary", {})).get("enabled", true)), "Blackkiln should offer Orla while honestly locking Tomas without a Ready Workshop")
	_expect(bool(orla.assign_specialist("orla_nine").get("ok", false)), "Orla Nine should join a fortress with a Ready engine")
	var tuned := orla.campaign_node_preview("charcoal_monastery")
	_expect(int(tuned.get("fuel", 0)) == maxi(1, int(baseline.get("fuel", 0)) - 1) and int(tuned.get("predicted_heat", 0)) == int(baseline.get("predicted_heat", 0)) + 1, "Orla's long-road fuel saving should disclose its heat cost")
	var orla_restored := LongMarchState.new(0)
	_expect(bool(orla_restored.load_serialized(orla.serialize()).get("ok", false)) and orla_restored.specialist_id == "orla_nine", "Orla's assignment and engine dependency should survive save/load")
	var tomas := _cinder_state(6604, true)
	var before := tomas._encounter_damage_profile("lift_saboteurs", "generator_core")
	_expect(bool(tomas.assign_specialist("tomas_reed").get("ok", false)), "Tomas Reed should join through a Ready Field Workshop")
	var after := tomas._encounter_damage_profile("lift_saboteurs", "generator_core")
	_expect(int(after.get("damage", -1)) == maxi(0, int(before.get("damage", 0)) - 1), "Tomas should reduce Lift Saboteur damage by exactly one")
	var tomas_restored := LongMarchState.new(0)
	_expect(bool(tomas_restored.load_serialized(tomas.serialize()).get("ok", false)) and tomas_restored.specialist_id == "tomas_reed", "Tomas and his workshop dependency should survive save/load")


func _test_three_choice_accessibility() -> void:
	root.size = Vector2i(1280, 720)
	var state := _cinder_state(6605)
	state.set_regional_developments(["cinder_refuge_chain"])
	state.campaign_event_pending = "charcoal_vow"
	var event_view = load("res://scenes/journey/RoadsideEvent.tscn").instantiate()
	root.add_child(event_view)
	event_view.visible = true
	event_view.set_high_contrast(true)
	event_view.set_controller_cancel_label("B")
	event_view.configure({"region_id": "cinder_spine", "title": state.campaign_event_details().title, "body": state.campaign_event_details().body, "choices": state.campaign_event_details().choices})
	await process_frame
	event_view.focus_default()
	await process_frame
	var third: Button = event_view.button_for("call_refuge_chain")
	_expect(third != null and third.visible and not third.disabled and third.text.contains("Fireline -2"), "the regional-memory option should remain visible and explicit at 1280x720")
	_expect(event_view.get_global_rect().encloses(third.get_global_rect()), "the third choice should remain inside the accessible event panel")
	_expect(root.gui_get_focus_owner() == event_view.choice_buttons[0] and event_view.pause_button.text.contains("B"), "controller focus and cancel labels should remain available in high contrast")
	event_view.queue_free()
	await process_frame


func _run() -> void:
	_test_scope_and_chassis()
	_test_specialists()
	await _test_three_choice_accessibility()
	if failures.is_empty():
		print("PASS: The Long March Early Access hardening")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
