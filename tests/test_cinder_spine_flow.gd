extends SceneTree

var game: Control
var failures: Array[String] = []
var responsive_profile := false
var viewport_size := Vector2i(1600, 900)
var capture_dir := ""
var capture_filter: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle_ui() -> void:
	for _frame in range(4):
		await process_frame


func _capture(name: String) -> void:
	if capture_dir.is_empty() or (not capture_filter.is_empty() and name not in capture_filter):
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "Cinder capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "Cinder capture should be written: " + name)


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
	if not responsive_profile:
		return
	var surface_rect := surface.get_global_rect()
	for control in controls:
		_expect(control != null and control.is_visible_in_tree() and surface_rect.encloses(control.get_global_rect()), "%s should keep its required controls inside %dx%d" % [label, viewport_size.x, viewport_size.y])


func _select_module(module_id: String) -> void:
	for index in range(game.module_option.item_count):
		if String(game.module_option.get_item_metadata(index)) == module_id:
			game.module_option.select(index)
			game.module_option.item_selected.emit(index)
			await _settle_ui()
			return
	_expect(false, "stored Cinder module should be selectable: " + module_id)


func _combat_names_include(fragment: String) -> bool:
	for label in game.combat_panel.enemy_names:
		if label.visible and label.text.contains(fragment.to_upper()):
			return true
	return false


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "Cinder event choice should be available: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle_ui()


func _enter_route(node_id: String) -> void:
	var route_button := game.campaign_map.button_for(node_id) as Button
	_expect(route_button != null and route_button.visible and not route_button.disabled, "Cinder route should be available: " + node_id)
	if route_button == null or route_button.disabled:
		return
	route_button.pressed.emit()
	await _settle_ui()
	game.campaign_commit_button.pressed.emit()
	await _settle_ui()
	_expect(game.journey_transition.visible and game.journey_transition.continue_button.has_focus(), "committing %s should open its travel handoff" % node_id)
	game.journey_transition.continue_button.pressed.emit()
	await _settle_ui()
	if game.roadside_event.visible and game.state.pre_contact_occurrence_active():
		for choice_button in game.roadside_event.choice_buttons:
			if choice_button.visible and not choice_button.disabled:
				await _choose_event(String(choice_button.get_meta("choice_id", "")))
				break
	_expect(game.road_contact.visible and game.state.encounter_active, "%s should enter a staged contact" % node_id)


func _finish_battle(arrival_capture: String = "", intervention_index: int = 2) -> void:
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		game.road_contact.intervention_buttons[intervention_index].pressed.emit()
		await process_frame
	for _step in range(7):
		if not game.state.encounter_active:
			await _settle_ui()
			_expect(game.journey_arrival.visible, "a resolved Cinder road should stop at its arrival receipt")
			await _capture(arrival_capture)
			game.journey_arrival.continue_button.pressed.emit()
			await _settle_ui()
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "Cinder battle should resolve within the shared six-step timeline")


func _run() -> void:
	var width_text := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height_text := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width_text.is_valid_int() and height_text.is_valid_int():
		viewport_size = Vector2i(int(width_text), int(height_text))
	responsive_profile = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	var capture_filter_text := OS.get_environment("LONG_MARCH_CAPTURE_FILTER")
	if not capture_filter_text.is_empty():
		for capture_name in capture_filter_text.split(",", false):
			capture_filter.append(String(capture_name).strip_edges())
	root.size = viewport_size
	game = load("res://scenes/Main.tscn").instantiate()
	game.starting_region_id = "cinder_spine"
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle_ui()
	if responsive_profile:
		game.set_high_contrast(true)
		game.set_reduced_motion(true)
		game.set_controller_layout("east_confirm")
		_apply_large_text(game)
		await _settle_ui()

	_expect(game.state.campaign_region_id == "cinder_spine" and game.state.current_location == "blackkiln" and game.state.chassis_template_id == "ridge_crawler", "the Cinder UI flow should begin at Blackkiln on the heavy Ridge Crawler")
	_expect(game.settlement_hub.context_label.text.contains("BLACKKILN FORGE BAZAAR"), "Blackkiln should identify its forge bazaar")
	_expect(game.settlement_hub.place_identity_label.text.contains("VOLCANIC FORGE MARKET") and game.settlement_hub.pressure_label.text.contains("FIRELINE"), "Blackkiln should state its volcanic identity and active fireline")
	_expect(game.settlement_hub.bazaar_canvas.presentation_signature().contains("FORGE STACKS") and game.settlement_hub.bazaar_canvas.route_signature() == "CHARCOAL MONASTERY · RED CUT", "Blackkiln should render a distinct forge skyline and both opening roads")
	_expect(game.settlement_hub.attendant_label.text == "ATTENDANT · GUILD COURIER", "Blackkiln's opening obligation should have a local guild courier")
	_expect_visible_inside(game.settlement_hub, [game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, game.settlement_hub.station_buttons["departure_gate"]], "Blackkiln")
	await _capture("00_blackkiln")

	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.cinder_contract_status == "accepted" and game.campaign_path_label.text.contains("Dynamo contract: Accepted"), "accepting through the UI should bind the dynamo obligation")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	_expect(game.settlement_hub.detail_body.text.contains("Charcoal Monastery") and game.settlement_hub.detail_body.text.contains("Red Cut"), "the gate should explain both opening Cinder routes")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	var route_button: Button = game.campaign_map.button_for("charcoal_monastery")
	_expect(route_button != null and not route_button.disabled, "Charcoal Monastery should be selectable")
	if route_button != null and not route_button.disabled:
		route_button.pressed.emit()
		await process_frame
		game.campaign_commit_button.pressed.emit()
		await process_frame
		_expect(game.journey_transition.visible and game.journey_transition.promise_label.text.contains("dynamo pattern"), "Cinder travel should carry the guild promise into the in-between scene")
		_expect(String(game.journey_transition.march_canvas.route_visual_signature().get("marker", "")) == "CHARCOAL BELLS", "the monastery road should use its authored travel landmark")
		_expect_visible_inside(game.journey_transition, [game.journey_transition.march_canvas, game.journey_transition.continue_button], "Cinder departure")
		await _capture("01_charcoal_departure")
		game.journey_transition.continue_button.pressed.emit()
		await process_frame
		_expect(game.state.phase == "battle" and _combat_names_include("Ember Drake"), "the monastery road should enter contact with an Ember Drake")
		var presented_enemies: Array = game.road_contact.current_view.get("enemies", [])
		_expect(not presented_enemies.is_empty() and String(presented_enemies[0].get("id", "")) == "ember_drakes" and game.road_contact.threat_detail.text.to_upper().contains("WALL LAMP"), "the Cinder contact should present its authoritative ember approach and counters")
		_expect_visible_inside(game.road_contact, [game.road_contact.contact_canvas, game.advance_encounter_button, game.road_contact.intervention_buttons[0]], "Cinder contact")
		await _capture("02_ember_contact")
		await _finish_battle("03_charcoal_arrival")
		_expect(game.state.campaign_event_pending == "charcoal_vow", "Charcoal Monastery should hand off to its authored vow")
		var vow_button: Button = game.roadside_event.button_for("bank_coals")
		_expect(vow_button != null and vow_button.visible, "the Cinder vow should expose an explicit bank-coals choice")
		await _capture("04_charcoal_vow")
		await _choose_event("bank_coals")

	await _enter_route("old_lift_station")
	await _finish_battle("05_old_lift_arrival")
	_expect(game.recovery_panel.visible and game.state.current_location == "old_lift_station" and game.state.settlement_actions_remaining == 2, "the delivered dynamo should open two-action Old Lift recovery")
	_expect(game.recovery_panel.local_stake_label.text.contains("dynamo") and game.recovery_panel.route_outlook_label.text.contains("Slag Tunnel") and game.recovery_panel.route_outlook_label.text.contains("Ash Chapel"), "Old Lift recovery should connect the delivered promise to all three upper roads")
	_expect(game.recovery_panel.recovery_canvas.presentation_signature().contains("CHAIN HOISTS") and game.recovery_panel.recovery_canvas.route_signature() == "SLOPE · SLAG TUNNEL · ASH CHAPEL", "Old Lift recovery should use its own forge-and-hoist visual identity")
	_expect_visible_inside(game.recovery_panel, [game.recovery_panel.recovery_canvas, game.recovery_panel.refuel_button, game.recovery_panel.routes_button], "Old Lift recovery")
	await _capture("06_old_lift_recovery")
	game.recovery_panel.refit_button.pressed.emit()
	await _settle_ui()
	_expect(game.main_columns.visible and game.settlement_hub_return_button.visible and game.settlement_hub_return_button.text.contains("OLD LIFT STATION RECOVERY") and game.focus_chassis_button.has_focus(), "Old Lift recovery should expose a player-facing chassis workbench with a clear return path and without spending a service action")
	game._on_grid_cell_pressed(Vector2i(2, 1))
	await _settle_ui()
	game.remove_button.pressed.emit()
	await _settle_ui()
	game._on_grid_cell_pressed(Vector2i(5, 1))
	await _settle_ui()
	game.remove_button.pressed.emit()
	await _settle_ui()
	await _select_module("shell_cannon")
	game._on_grid_cell_pressed(Vector2i(3, 2))
	await _settle_ui()
	_expect(game.state.operational("shell_cannon") and game.state.total_mass() == 12 and game.state.settlement_actions_remaining == 2, "the field refit should mount the Warden counter without consuming either recovery action")
	await _capture("06b_old_lift_refit")
	game.settlement_hub_return_button.pressed.emit()
	await _settle_ui()
	_expect(game.recovery_panel.visible and game.recovery_panel.refit_button.is_visible_in_tree() and game.recovery_panel.get_viewport().gui_get_focus_owner() != null, "returning from the workbench should restore Old Lift recovery and controller focus")
	if not game.recovery_panel.refuel_button.disabled:
		game.recovery_panel.refuel_button.pressed.emit()
		await _settle_ui()
	if not game.recovery_panel.hull_button.disabled:
		game.recovery_panel.hull_button.pressed.emit()
		await _settle_ui()
	game.recovery_panel.routes_button.pressed.emit()
	await _settle_ui()
	_expect(game.journey_planner.visible and game.campaign_map.button_for("long_slope").visible and game.campaign_map.button_for("slag_tunnel").visible, "Old Lift should reopen a map with distinct grade and tunnel choices")
	await _capture("07_upper_routes")

	await _enter_route("long_slope")
	await _finish_battle("08_long_slope_arrival", 0)
	await _enter_route("lift_engine_house")
	await _finish_battle("09_lift_engine_arrival", 0)
	_expect(game.roadside_event.visible and game.state.campaign_event_pending == "lift_engine_choice", "Lift Engine House should halt at its power-or-bypass decision")
	await _capture("10_lift_engine_choice")
	await _choose_event("power_lift")
	_expect(game.roadside_event.visible and game.state.campaign_event_pending == "commune_design", "powering the lift should expose the communal-design commitment")
	await _capture("11_commune_design")
	await _choose_event("share_lift_plan")
	_expect(game.journey_planner.visible and game.campaign_map.button_for("switchback_commune").visible, "the shared lift plan should reopen the final route")

	await _enter_route("switchback_commune")
	_expect(_combat_names_include("Elevator Warden"), "the final Cinder contact should stage its distinct Elevator Warden")
	await _capture("12_warden_contact")
	await _finish_battle("13_switchback_arrival", 0)
	_expect(game.state.run_complete and game.state.campaign_encounters_completed == 5 and game.debrief_panel.visible, "the Cinder UI journey should complete five contacts and open Debrief · phase %s · location %s · result %s · contacts %d" % [game.state.phase, game.state.current_location, game.state.final_result, game.state.campaign_encounters_completed])
	_expect(game.results_record_label.text.contains("COMMUNAL LIFT PLAN") and game.debrief_panel.commitments_label.text.contains("Ending facets") and game.debrief_panel.consequence_label.text.contains("Generator Core remained operational") and game.debrief_panel.consequence_label.text.contains("dynamo reached Switchback Commune"), "the Cinder Debrief should retain its regional development, composed ending, and causal outcome")
	await _capture("14_cinder_debrief")

	if failures.is_empty():
		if responsive_profile:
			print("PASS: The Long March responsive Cinder profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March Cinder Spine UI flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
