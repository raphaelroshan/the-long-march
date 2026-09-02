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
		_expect(false, "LM-I5 capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "LM-I5 capture should be written: " + name)


func _apply_large_text(node: Node) -> void:
	if node is Control:
		var control := node as Control
		if control.theme != null:
			control.theme.default_font_size = roundi(float(control.theme.default_font_size) * 1.1)
		if control.has_theme_font_size_override("font_size"):
			control.add_theme_font_size_override("font_size", roundi(float(control.get_theme_font_size("font_size")) * 1.1))
	for child in node.get_children():
		_apply_large_text(child)


func _new_game(prior_status: String) -> void:
	if game != null:
		game.queue_free()
		await _settle()
	game = load("res://scenes/Main.tscn").instantiate()
	game.starting_region_id = "flooded_veyru"
	game.starting_obligation_records = {"ashgate_lowlands": prior_status}
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle()
	if responsive:
		game.set_high_contrast(true)
		game.set_reduced_motion(true)
		game.set_controller_layout("east_confirm")
		_apply_large_text(game)
		await _settle()
	_expect(game.state.prior_obligation_status("ashgate_lowlands") == prior_status, "Veyru should receive the %s Ashgate obligation" % prior_status)
	_expect(game.campaign_path_label.text.contains("Prior obligation"), "the active Veyru status should name inherited obligation history")


func _open_routes() -> void:
	game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
	await _settle()
	game.settlement_hub.secondary_action_button.pressed.emit()
	await _settle()
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await _settle()
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible, "declining the current medicine contract should still open Veyru's route planner")


func _select_route(node_id: String, capture_name: String) -> void:
	var button := game.campaign_map.button_for(node_id) as Button
	_expect(button != null and button.visible and not button.disabled, "memory route should be selectable: " + node_id)
	if button == null or button.disabled:
		return
	button.pressed.emit()
	await _settle()
	await _capture(capture_name)


func _commit_selected() -> void:
	game.campaign_commit_button.pressed.emit()
	await _settle()
	game.journey_transition.continue_button.pressed.emit()
	await _settle()


func _finish_contact() -> void:
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		game.road_contact.intervention_buttons[2].pressed.emit()
		await process_frame
	for _step in range(7):
		if not game.state.encounter_active:
			await _settle()
			_expect(game.journey_arrival.visible, "memory route should stop at its arrival receipt")
			game.journey_arrival.continue_button.pressed.emit()
			await _settle()
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "memory route should resolve within six steps")


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "memory flow choice should be available: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle()


func _completed_service_flow() -> void:
	await _new_game("completed")
	await _open_routes()
	game.state.current_location = "pump_gallery"
	game.state.journey_node = "pump_gallery"
	game.state.campaign_path.clear()
	game.state.campaign_path.append("lantern_quay")
	game.state.campaign_path.append("pump_gallery")
	game.state.campaign_encounters_completed = 1
	game.state.phase = "map"
	game.selected_campaign_node_id = ""
	game.journey_planner_active = true
	game._refresh_ui()
	await _settle()
	await _select_route("veyru_evacuation_camp", "00_completed_camp_dossier")
	_expect(game.route_preview_label.text.contains("Morrowline's delivered parts") and game.route_preview_label.text.contains("1 recovery action"), "the camp dossier should explain the completed-contract service effect before commitment")
	game.state.current_location = "veyru_evacuation_camp"
	game.state.journey_node = "veyru_evacuation_camp"
	game.state.campaign_path.append("veyru_evacuation_camp")
	game.state.campaign_encounters_completed = 2
	game.state.phase = "settlement"
	game.state.settlement_actions_remaining = 2
	game.selected_campaign_node_id = ""
	game.journey_planner_active = false
	game._refresh_ui()
	await _settle()
	_expect(game.state.settlement_actions_remaining == 2 and game.settlement_title.text.contains("2 ACTIONS LEFT"), "completed Ashgate service support should add one action to the declined-carrier camp")
	_expect(game.campaign_path_label.text.contains("Morrowline supply line"), "the recovery screen should retain the source of its extra service")
	await _capture("01_completed_camp_service")


func _declined_route_flow() -> void:
	await _new_game("declined")
	await _open_routes()
	await _select_route("sunken_tramworks", "02_declined_tram_chart")
	_expect(game.route_preview_label.text.contains("unbound convoy's chart") and game.route_preview_label.text.contains("pressure by 1"), "the declined-contract route dossier should explain its Free Carters pressure effect")
	_expect(int(game.state.campaign_node_preview("sunken_tramworks").get("pressure_gain", -1)) == 0 and game.campaign_commit_button.text.contains("P 0→0"), "the inherited chart should reduce Sunken Tramworks pressure to zero at commit")


func _failed_route_flow() -> void:
	await _new_game("failed")
	await _open_routes()
	await _select_route("pump_gallery", "03_failed_pump_warning")
	_expect(game.route_preview_label.text.contains("Survivors") and game.route_preview_label.text.contains("risk by 6 points"), "the failed-contract dossier should turn the loss into an attributed warning")
	_expect("prior obligation -6pt" in game.state.campaign_node_preview("pump_gallery").get("risk_factors", []), "the risk breakdown should quantify the inherited warning")


func _run() -> void:
	var width := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width.is_valid_int() and height.is_valid_int():
		viewport_size = Vector2i(int(width), int(height))
	responsive = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	root.size = viewport_size
	await _completed_service_flow()
	await _declined_route_flow()
	await _failed_route_flow()
	if responsive:
		_expect(game.get_global_rect().encloses(game.campaign_commit_button.get_global_rect()), "LM-I5 route commitment should remain inside %dx%d" % [viewport_size.x, viewport_size.y])
	if failures.is_empty():
		print("PASS: The Long March LM-I5 memory UI flow%s" % (" %dx%d" % [viewport_size.x, viewport_size.y] if responsive else ""))
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
