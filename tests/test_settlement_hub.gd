extends SceneTree

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle_ui(frames: int = 4) -> void:
	for _frame in range(frames):
		await process_frame

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/Main.tscn").instantiate()
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle_ui()

	var hub = game.settlement_hub
	_expect(hub.visible and not game.main_columns.visible, "the opening settlement should use the bazaar hub instead of the dense operations desk")
	_expect(hub.station_buttons.size() == 6 and hub.station_buttons.has("workshop") and hub.station_buttons.has("departure_gate"), "the bazaar should expose six stable station landmarks")
	_expect(hub.value_labels["hull"].text == "10/10" and hub.value_labels["fuel"].text == "6" and hub.value_labels["money"].text == "80", "the left rail should expose the critical fortress values")
	_expect(hub.station_buttons["assignment_board"].has_focus(), "the unresolved opening assignment should receive default focus")
	var canvas_rect: Rect2 = hub.bazaar_canvas.get_global_rect()
	_expect(hub.value_labels["hull"].global_position.x < canvas_rect.position.x and hub.detail_title.global_position.x > canvas_rect.end.x, "the 1280x720 hub should keep values left, the fortress stage centered, and details right")
	_expect(game.get_global_rect().encloses(hub.pause_button.get_global_rect()) and game.get_global_rect().encloses(hub.primary_action_button.get_global_rect()), "the persistent pause and station action should remain on screen at 1280x720")

	var state_before_browse: Dictionary = game.state.serialize()
	hub.station_buttons["workshop"].pressed.emit()
	await process_frame
	_expect(hub.selected_station_id == "workshop" and hub.primary_action_button.text == "ENTER WORKSHOP", "selecting a bazaar station should open its named detail action")
	_expect(game.state.serialize() == state_before_browse, "browsing bazaar stations should not mutate deterministic run state")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(not hub.visible and game.main_columns.visible and game.settlement_hub_return_button.visible and game.focus_chassis_button.has_focus(), "entering the workshop should reveal the detailed chassis view and a clear return path")
	game.settlement_hub_return_button.pressed.emit()
	await _settle_ui()
	_expect(hub.visible and hub.station_buttons["assignment_board"].has_focus(), "returning from detailed work should restore the bazaar's current required station")

	hub.station_buttons["assignment_board"].pressed.emit()
	await process_frame
	_expect(hub.primary_action_button.text == "ACCEPT ASSIGNMENT" and hub.secondary_action_button.text.begins_with("DECLINE"), "the assignment board should disclose both commitment choices before activation")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.guard_contract_status == "accepted" and hub.visible, "accepting through the bazaar should use the existing campaign contract state")
	_expect(hub.station_buttons["departure_gate"].has_focus() and hub.station_buttons["departure_gate"].text.contains("PLAN JOURNEY"), "answering the assignment should hand focus to the now-open departure gate")

	hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	_expect(hub.primary_action_button.text == "PLAN JOURNEY" and not hub.primary_action_button.disabled, "the departure station should require an explicit plan action")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(not hub.visible and not game.main_columns.visible and game.journey_planner.visible and game.campaign_map.visible, "planning a journey should open the dedicated regional map without moving the fortress")
	_expect(game.state.current_location == "ashgate_depot" and game.state.phase == "refit" and game.selected_campaign_node_id.is_empty(), "opening the map should not spend fuel, time, or commit a destination")
	_expect(game.journey_planner.return_button.visible, "route planning should retain a visible return to the settlement bazaar")
	var planner_map_rect: Rect2 = game.campaign_map.get_global_rect()
	_expect(game.journey_planner.value_labels["fuel"].global_position.x < planner_map_rect.position.x and game.route_preview_label.global_position.x > planner_map_rect.end.x, "the route planner should keep readiness left, the map centered, and the road dossier right")

	game.set_high_contrast(true)
	await _settle_ui(2)
	game.journey_planner.return_button.pressed.emit()
	await _settle_ui(2)
	_expect(hub.high_contrast_enabled and hub.bazaar_canvas.high_contrast_enabled, "the settlement presentation should inherit the stage's high-contrast setting")

	hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	hub.primary_action_button.pressed.emit()
	await _settle_ui(2)
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await _settle_ui(2)
	game.campaign_commit_button.pressed.emit()
	await _settle_ui()
	var journey = game.journey_transition
	_expect(game.state.phase == "battle" and game.state.current_location == "ashgate_depot" and game.state.campaign_target_node == "rill_crossing" and journey.visible and not game.main_columns.visible, "committing a route should keep the fortress at its last secured location and stop at a mandatory road presentation")
	_expect(journey.route_label.text.contains("ASHGATE DEPOT") and journey.route_label.text.contains("RILL CROSSING") and journey.detail_label.text.contains("resolve the contact before"), "the road view should preserve origin, destination, and the unresolved-arrival rule")
	_expect(journey.day_label.text.contains("+1") and journey.fuel_label.text.contains("−1") and journey.pressure_label.text.contains("+1"), "the road view should show the committed time, fuel, and pressure receipt")
	var march_rect: Rect2 = journey.march_canvas.get_global_rect()
	_expect(journey.day_label.global_position.x < march_rect.position.x and journey.destination_label.global_position.x > march_rect.end.x, "the road view should retain the left-values, centered-fortress, right-details hierarchy")
	_expect(journey.continue_button.has_focus() and journey.continue_button.text == "CONTINUE TO CONTACT", "the road view should require an explicit continuation into the contact")
	journey.continue_button.pressed.emit()
	await _settle_ui()
	_expect(not journey.visible and game.main_columns.visible and game.combat_panel.visible and game.advance_encounter_button.has_focus(), "continuing from the road should reveal the encounter without resolving a combat step")

	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March settlement hub")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
