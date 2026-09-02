extends SceneTree

var game: Control
var failures: Array[String] = []
var responsive_profile := false
var viewport_size := Vector2i(1600, 900)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle_ui() -> void:
	for _frame in range(4):
		await process_frame


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


func _combat_names_include(fragment: String) -> bool:
	for label in game.combat_panel.enemy_names:
		if label.visible and label.text.contains(fragment.to_upper()):
			return true
	return false


func _finish_battle() -> void:
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		game.road_contact.intervention_buttons[2].pressed.emit()
		await process_frame
	for _step in range(7):
		if not game.state.encounter_active:
			await _settle_ui()
			_expect(game.journey_arrival.visible, "a resolved Cinder road should stop at its arrival receipt")
			game.journey_arrival.continue_button.pressed.emit()
			await process_frame
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

	_expect(game.state.campaign_region_id == "cinder_spine" and game.state.current_location == "blackkiln", "the Cinder UI flow should begin at Blackkiln")
	_expect(game.settlement_hub.context_label.text.contains("BLACKKILN FORGE BAZAAR"), "Blackkiln should identify its forge bazaar")
	_expect(game.settlement_hub.place_identity_label.text.contains("VOLCANIC FORGE MARKET") and game.settlement_hub.pressure_label.text.contains("FIRELINE"), "Blackkiln should state its volcanic identity and active fireline")
	_expect(game.settlement_hub.bazaar_canvas.presentation_signature().contains("FORGE STACKS") and game.settlement_hub.bazaar_canvas.route_signature() == "CHARCOAL MONASTERY · RED CUT", "Blackkiln should render a distinct forge skyline and both opening roads")
	_expect(game.settlement_hub.attendant_label.text == "ATTENDANT · GUILD COURIER", "Blackkiln's opening obligation should have a local guild courier")
	_expect_visible_inside(game.settlement_hub, [game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, game.settlement_hub.station_buttons["departure_gate"]], "Blackkiln")

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
		game.journey_transition.continue_button.pressed.emit()
		await process_frame
		_expect(game.state.phase == "battle" and _combat_names_include("Ember Drake"), "the monastery road should enter contact with an Ember Drake")
		var presented_enemies: Array = game.road_contact.current_view.get("enemies", [])
		_expect(not presented_enemies.is_empty() and String(presented_enemies[0].get("id", "")) == "ember_drakes" and game.road_contact.threat_detail.text.to_upper().contains("WALL LAMP"), "the Cinder contact should present its authoritative ember approach and counters")
		_expect_visible_inside(game.road_contact, [game.road_contact.contact_canvas, game.advance_encounter_button, game.road_contact.intervention_buttons[0]], "Cinder contact")
		await _finish_battle()
		_expect(game.state.campaign_event_pending == "charcoal_vow", "Charcoal Monastery should hand off to its authored vow")
		var vow_button: Button = game.roadside_event.button_for("bank_coals")
		_expect(vow_button != null and vow_button.visible, "the Cinder vow should expose an explicit bank-coals choice")

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
