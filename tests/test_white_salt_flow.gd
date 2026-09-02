extends SceneTree

var game: Control
var failures: Array[String] = []
var viewport_size := Vector2i(1600, 900)
var responsive := false
var capture_dir := ""
var capture_filter: Array[String] = []


func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)


func _settle() -> void:
	for _frame in range(4):
		await process_frame


func _capture(name: String) -> void:
	if capture_dir.is_empty() or (not capture_filter.is_empty() and name not in capture_filter):
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "White Salt capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "White Salt capture should be written: " + name)


func _apply_large_text(node: Node) -> void:
	if node is Control:
		var control := node as Control
		if control.theme != null:
			control.theme.default_font_size = roundi(float(control.theme.default_font_size) * 1.1)
		if control.has_theme_font_size_override("font_size"):
			control.add_theme_font_size_override("font_size", roundi(float(control.get_theme_font_size("font_size")) * 1.1))
	for child in node.get_children():
		_apply_large_text(child)


func _expect_visible_inside(surface: Control, controls: Array, label: String) -> void:
	if not responsive:
		return
	var surface_rect := surface.get_global_rect()
	for control in controls:
		_expect(control != null and control.is_visible_in_tree() and surface_rect.encloses(control.get_global_rect()), "%s should keep its required controls inside %dx%d" % [label, viewport_size.x, viewport_size.y])


func _combat_names_include(fragment: String) -> bool:
	for label in game.combat_panel.enemy_names:
		if label.visible and label.text.contains(fragment.to_upper()):
			return true
	return false


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "White Salt event choice should be available: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle()


func _enter_route(node_id: String, departure_capture: String = "", preview_capture: String = "") -> void:
	var route_button := game.campaign_map.button_for(node_id) as Button
	_expect(route_button != null and route_button.visible and not route_button.disabled, "White Salt route should be available: " + node_id)
	if route_button == null or route_button.disabled:
		return
	route_button.pressed.emit()
	await _settle()
	await _capture(preview_capture)
	game.campaign_commit_button.pressed.emit()
	await _settle()
	_expect(game.journey_transition.visible and game.journey_transition.continue_button.has_focus(), "committing %s should open its travel handoff" % node_id)
	await _capture(departure_capture)
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	_expect(game.road_contact.visible and game.state.encounter_active, "%s should enter a staged contact" % node_id)


func _finish_battle(arrival_capture: String = "", intervention_index: int = 0) -> void:
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		game.road_contact.intervention_buttons[intervention_index].pressed.emit()
		await process_frame
	for _step in range(7):
		if not game.state.encounter_active:
			await _settle()
			_expect(game.journey_arrival.visible, "a resolved White Salt road should stop at its arrival receipt")
			await _capture(arrival_capture)
			game.journey_arrival.continue_button.pressed.emit()
			await _settle()
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "White Salt battle should resolve within the shared six-step timeline")


func _run() -> void:
	var width := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width.is_valid_int() and height.is_valid_int():
		viewport_size = Vector2i(int(width), int(height))
	responsive = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	var capture_filter_text := OS.get_environment("LONG_MARCH_CAPTURE_FILTER")
	if not capture_filter_text.is_empty():
		for capture_name in capture_filter_text.split(",", false):
			capture_filter.append(String(capture_name).strip_edges())
	root.size = viewport_size
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

	_expect(game.state.current_location == "saltglass_haven" and game.state.chassis_template_id == "salt_skimmer", "White Salt should launch at Saltglass Haven with the Salt Skimmer")
	_expect(game.state.chassis_mass_limit() == 13 and game.state.chassis_exterior_limit() == 3 and not game.state.chassis_cell_available(Vector2i(0, 3)), "the alternate chassis should expose its physical constraints")
	_expect(game.settlement_hub.context_label.text.contains("SALTGLASS SIGNAL MARKET") and game.settlement_hub.bazaar_canvas.presentation_signature().contains("MIRROR BEACONS"), "Saltglass should have a distinct signal-market identity")
	_expect_visible_inside(game.settlement_hub, [game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, game.settlement_hub.station_buttons["departure_gate"]], "Saltglass Haven")
	await _capture("00_saltglass_haven")

	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.state.salt_contract_status == "accepted" and game.campaign_path_label.text.contains("Beacon escort: Accepted"), "the beacon escort should be accepted through the shared assignment station")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await _settle()
	_expect(game.settlement_hub.detail_body.text.contains("Buried Observatory") and game.settlement_hub.detail_body.text.contains("Quiet Caravan"), "the gate should explain both opening White Salt roads")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()

	await _enter_route("buried_observatory", "01_observatory_departure")
	_expect(_combat_names_include("Salt Storm") and game.road_contact.threat_detail.text.to_upper().contains("WATER CONDENSER"), "the observatory road should stage its salt storm and authored counters")
	_expect_visible_inside(game.road_contact, [game.road_contact.contact_canvas, game.advance_encounter_button, game.road_contact.intervention_buttons[0]], "White Salt contact")
	await _capture("02_salt_storm_contact")
	await _finish_battle("03_observatory_arrival")
	_expect(game.roadside_event.visible and game.state.campaign_event_pending == "observatory_signal", "Buried Observatory should halt at its public-or-private signal decision")
	await _capture("04_public_beacons")
	await _choose_event("broadcast_beacons")

	await _enter_route("windbreak")
	await _finish_battle("05_windbreak_arrival")
	_expect(game.recovery_panel.visible and game.state.current_location == "windbreak" and game.state.settlement_actions_remaining == 2, "the guided Compact should open two-action Windbreak recovery")
	_expect(game.recovery_panel.local_stake_label.text.contains("beacon caravan") and game.recovery_panel.route_outlook_label.text.contains("Salt Mine") and game.recovery_panel.route_outlook_label.text.contains("Empty Mile") and game.recovery_panel.route_outlook_label.text.contains("Beacon Road"), "Windbreak recovery should connect the escort stake to its distinct upper roads")
	_expect(game.recovery_panel.recovery_canvas.presentation_signature().contains("MIRROR POSTS") and game.recovery_panel.recovery_canvas.route_signature() == "MINE · EMPTY MILE · BEACON · LEE", "Windbreak should use its own stone, mirror, and water visual identity")
	_expect_visible_inside(game.recovery_panel, [game.recovery_panel.recovery_canvas, game.recovery_panel.refit_button, game.recovery_panel.routes_button], "Windbreak recovery")
	await _capture("06_windbreak_recovery")
	game.recovery_panel.refit_button.pressed.emit()
	await _settle()
	_expect(game.main_columns.visible and game.settlement_hub_return_button.visible and game.settlement_hub_return_button.text.contains("THE WINDBREAK RECOVERY") and game.state.can_refit(), "Windbreak should expose the Salt Skimmer workbench with a clear return path")
	await _capture("06b_skimmer_workbench")
	game.settlement_hub_return_button.pressed.emit()
	await _settle()
	game.recovery_panel.routes_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible and game.campaign_map.button_for("salt_mine").visible and game.campaign_map.button_for("empty_mile").visible and game.campaign_map.button_for("beacon_road").visible, "Windbreak should reopen the full upper-road comparison")
	_expect(game.campaign_comparison_label.text.contains("SALT MINE") and game.campaign_comparison_label.text.contains("EMPTY MILE") and game.campaign_comparison_label.text.contains("BEACON ROAD"), "the upper map should compare the three ordinary roads before commitment")
	await _capture("07_upper_routes")

	await _enter_route("beacon_road", "07c_beacon_departure", "07b_beacon_selected")
	_expect(game.journey_transition.promise_label.text.contains("Compact") and String(game.journey_transition.march_canvas.route_visual_signature().get("marker", "")) == "MIRROR BEACONS", "Beacon Road departure should preserve the escort promise and public-beacon landmark")
	await _finish_battle("08_beacon_arrival")
	await _enter_route("rival_approach")
	await _finish_battle("09_rival_arrival")
	_expect(game.roadside_event.visible and game.state.campaign_event_pending == "rival_terms", "Rival Approach should halt at its alliance-or-race decision")
	await _capture("10_rival_terms")
	await _choose_event("escort_compact")
	await _enter_route("salt_citadel")
	_expect(_combat_names_include("Rival Fortress"), "the final White Salt contact should stage the rival fortress")
	await _capture("11_rival_fortress")
	await _finish_battle("12_citadel_arrival")
	_expect(game.state.run_complete and game.state.campaign_encounters_completed == 5 and game.state.final_result == "expanse_allied" and game.debrief_panel.visible, "the White Salt UI journey should complete five contacts and open its allied Debrief")
	_expect(game.results_record_label.text.contains("PUBLIC SALT BEACONS") and game.debrief_panel.commitments_label.text.contains("Ending facets") and game.debrief_panel.consequence_label.text.contains("signal chain remained operational") and game.debrief_panel.consequence_label.text.contains("Salt Citadel opened"), "the White Salt Debrief should retain its regional development, composed ending, and causal outcome")
	await _capture("13_salt_debrief")

	if failures.is_empty():
		if responsive:
			print("PASS: The Long March responsive White Salt profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March White Salt UI flow")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _init() -> void:
	call_deferred("_run")
