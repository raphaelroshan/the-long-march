extends SceneTree

var game: Control
var failures: Array[String] = []
var viewport_size := Vector2i(1600, 900)
var responsive := false
var capture_dir := ""


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle() -> void:
	for _frame in range(4):
		await process_frame


func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "LM-I4 capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "LM-I4 capture should be written: " + name)


func _apply_large_text(node: Node) -> void:
	if node is Control:
		var control := node as Control
		if control.theme != null:
			control.theme.default_font_size = roundi(float(control.theme.default_font_size) * 1.1)
		if control.has_theme_font_size_override("font_size"):
			control.add_theme_font_size_override("font_size", roundi(float(control.get_theme_font_size("font_size")) * 1.1))
	for child in node.get_children():
		_apply_large_text(child)


func _place(module_id: String, position: Vector2i, exterior: bool = false) -> void:
	var result: Dictionary = game.state.place_module(module_id, position, exterior)
	_expect(bool(result.get("ok", false)), "%s should install for the LM-I4 UI fixture: %s" % [module_id, String(result.get("reason", "unknown"))])


func _set_loadout(kind: String) -> void:
	game.state.modules.clear()
	game.state.stored_modules.clear()
	_place("ash_runner_engine", Vector2i(0, 0))
	_place("coal_cell", Vector2i(0, 2))
	_place("generator_core", Vector2i(1, 0))
	if kind in ["command", "medical"]:
		_place("crew_quarters", Vector2i(3, 0))
		_place("command_deck" if kind == "command" else "infirmary", Vector2i(2, 1))
		_place("signal_coil", Vector2i(4, 1))
		_place("wall_lamp", Vector2i(5, 1), true)
	else:
		_place("shell_cannon", Vector2i(2, 2), true)
		_place("salvage_crane", Vector2i(5, 0), true)
		_place("signal_coil", Vector2i(4, 2))
		_place("wall_lamp", Vector2i(5, 2), true)
	game.state.seed_starter_inventory()
	game.state._recalculate()
	game._refresh_ui()
	await _settle()


func _new_game(kind: String) -> void:
	if game != null:
		game.queue_free()
		await _settle()
	game = load("res://scenes/Main.tscn").instantiate()
	game.starting_region_id = "white_salt_expanse"
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle()
	if responsive:
		game.set_high_contrast(true)
		game.set_reduced_motion(true)
		game.set_controller_layout("east_confirm")
		_apply_large_text(game)
		await _settle()
	await _set_loadout(kind)


func _open_routes_after_assignment(accept: bool) -> void:
	game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
	await _settle()
	var choice: Button = game.settlement_hub.primary_action_button if accept else game.settlement_hub.secondary_action_button
	choice.pressed.emit()
	await _settle()
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await _settle()
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible, "answering the Saltglass assignment should open the route planner")


func _enter_route(node_id: String, selected_capture: String = "", contact_capture: String = "") -> void:
	var route_button := game.campaign_map.button_for(node_id) as Button
	_expect(route_button != null and route_button.visible and not route_button.disabled, "LM-I4 route should be available: " + node_id)
	if route_button == null or route_button.disabled:
		return
	route_button.pressed.emit()
	await _settle()
	await _capture(selected_capture)
	game.campaign_commit_button.pressed.emit()
	await _settle()
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	_expect(game.road_contact.visible and game.state.encounter_active, "%s should enter contact" % node_id)
	await _capture(contact_capture)


func _finish_contact(arrival_capture: String = "") -> void:
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		game.road_contact.intervention_buttons[0].pressed.emit()
		await process_frame
	for _step in range(7):
		if not game.state.encounter_active:
			await _settle()
			_expect(game.journey_arrival.visible, "resolved LM-I4 contact should stop at the arrival receipt")
			await _capture(arrival_capture)
			game.journey_arrival.continue_button.pressed.emit()
			await _settle()
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "LM-I4 contact should resolve within the shared timeline")


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "LM-I4 event choice should be available: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle()


func _combat_names_include(fragment: String) -> bool:
	for label in game.combat_panel.enemy_names:
		if label.visible and label.text.contains(fragment.to_upper()):
			return true
	return false


func _run_command_view() -> void:
	await _new_game("command")
	game.settlement_hub.station_buttons["hiring_post"].pressed.emit()
	await _settle()
	_expect(game.settlement_hub.primary_action_button.text.contains("SELA") and not game.settlement_hub.primary_action_button.disabled and game.settlement_hub.secondary_action_button.disabled, "Saltglass should expose Sela only when the Command Deck dependency is Ready")
	_expect(game.settlement_hub.detail_body.text.contains("one day") and game.settlement_hub.detail_body.text.contains("+4% risk"), "Sela's offer should name both sides of the route trade")
	await _capture("00_sela_offer")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.state.specialist_id == "sela_vonn" and game.settlement_hub.detail_status.text == "ASSIGNED", "assigning Sela should remain visible at the Hiring Post")
	await _capture("01_sela_assigned")
	await _open_routes_after_assignment(false)
	await _enter_route("quiet_caravan")
	await _finish_contact()
	await _enter_route("windbreak")
	await _finish_contact()
	game.recovery_panel.routes_button.pressed.emit()
	await _settle()
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	await _settle()
	await _enter_route("salt_mine", "02_command_mine_dossier", "03_command_combined_contact")
	_expect(game.journey_planner.specialist_name_label.text.contains("SELA VONN"), "the command journey should retain Sela in its player-facing route status")
	_expect(_combat_names_include("Signal Hunter") and _combat_names_include("Salt Storm"), "Salt Mine should show the combined threat pair")


func _run_medical_view() -> void:
	await _new_game("medical")
	game.settlement_hub.station_buttons["hiring_post"].pressed.emit()
	await _settle()
	_expect(game.settlement_hub.primary_action_button.disabled and not game.settlement_hub.secondary_action_button.disabled, "Saltglass should expose Nera only when the Field Infirmary dependency is Ready")
	_expect(game.settlement_hub.detail_body.text.contains("crew and refuge hits by one"), "Nera's offer should name the exact protected targets and mitigation")
	await _capture("04_nera_offer")
	game.settlement_hub.secondary_action_button.pressed.emit()
	await _settle()
	_expect(game.state.specialist_id == "nera_quill" and game.settlement_hub.detail_status.text == "ASSIGNED", "assigning Nera should remain visible at the Hiring Post")
	await _capture("05_nera_assigned")


func _run_crane_view() -> void:
	await _new_game("crane")
	await _open_routes_after_assignment(true)
	await _enter_route("buried_observatory")
	await _finish_contact()
	await _choose_event("broadcast_beacons")
	await _enter_route("windbreak")
	await _finish_contact()
	var crane_index: int = game.state._module_index_by_id("salvage_crane")
	if crane_index >= 0 and int(game.state.modules[crane_index].get("durability", 0)) < int(game.state.module_definition("salvage_crane").get("durability", 3)):
		var repaired: Dictionary = game.state.settlement_repair("salvage_crane")
		_expect(bool(repaired.get("ok", false)), "the UI fixture should restore the crane before Empty Mile")
		game._refresh_ui()
		await _settle()
	game.recovery_panel.routes_button.pressed.emit()
	await _settle()
	await _enter_route("empty_mile", "06_crane_empty_mile_dossier", "07_bridgebreaker_contact")
	_expect(_combat_names_include("Bridgebreaker") and game.road_contact.counter_readiness_label.text.to_upper().contains("SALVAGE CRANE"), "Empty Mile contact should name the demolition threat and crane counter")
	await _finish_contact("08_crane_recovery_receipt")
	_expect(game.state.log.any(func(line: String) -> bool: return line.contains("Empty Mile recovery") and line.contains("8 Ashmarks")), "the undamaged UI plan should record the crane's fallback fittings sale")
	_expect(game.journey_arrival.report_label.text.contains("Empty Mile recovery") and game.journey_arrival.report_label.text.contains("8 Ashmarks"), "the arrival receipt should expose the crane's cash recovery consequence")


func _run() -> void:
	var width := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width.is_valid_int() and height.is_valid_int():
		viewport_size = Vector2i(int(width), int(height))
	responsive = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	root.size = viewport_size
	await _run_command_view()
	await _run_medical_view()
	await _run_crane_view()
	if responsive and game != null:
		_expect(game.get_global_rect().encloses(game.journey_arrival.get_global_rect()), "LM-I4 arrival receipt should remain contained at %dx%d" % [viewport_size.x, viewport_size.y])
	if failures.is_empty():
		print("PASS: The Long March LM-I4 breadth UI flow%s" % (" %dx%d" % [viewport_size.x, viewport_size.y] if responsive else ""))
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
