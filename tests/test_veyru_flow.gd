extends SceneTree

var game: Control
var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle_ui() -> void:
	for _frame in range(4):
		await process_frame


func _init() -> void:
	call_deferred("_run")


func _press_route(node_id: String) -> void:
	var button: Button = game.campaign_map.button_for(node_id)
	_expect(button != null and not button.disabled, "Veyru route should be selectable: " + node_id)
	if button == null or button.disabled:
		return
	button.pressed.emit()
	await process_frame
	_expect(game.selected_campaign_node_id == node_id and game.campaign_commit_button.has_focus(), "Veyru route selection should wait at the shared Commit boundary: " + node_id)
	game.campaign_commit_button.pressed.emit()
	await process_frame
	_expect(game.journey_transition.visible and game.journey_transition.detail_label.text.contains("resolve the contact before"), "committing a Veyru route should preserve its in-between road presentation")
	game.journey_transition.continue_button.pressed.emit()
	await process_frame


func _press_event(choice_id: String) -> void:
	for button in game.campaign_event_buttons:
		if button.visible and String(button.get_meta("choice_id", "")) == choice_id:
			button.pressed.emit()
			await process_frame
			return
	_expect(false, "Veyru event choice should be visible: " + choice_id)


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
			_expect(game.journey_arrival.visible and game.journey_arrival.continue_button.has_focus(), "a resolved Veyru road should stop at its arrival receipt")
			game.journey_arrival.continue_button.pressed.emit()
			await process_frame
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "Veyru battle should resolve within the shared six-step timeline")


func _run() -> void:
	for relative_path in ["user://the_long_march_prototype.save", "user://the_long_march_prototype.backup.save", "user://the_long_march_onboarding_v1.complete", "user://the_long_march_playtest_journal.json"]:
		var path := ProjectSettings.globalize_path(relative_path)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	game.starting_region_id = "flooded_veyru"
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await process_frame
	await process_frame

	_expect(game.state.campaign_region_id == "flooded_veyru" and game.state.current_location == "lantern_quay", "the Veyru UI flow should begin at Lantern Quay")
	_expect(game.settlement_hub.visible and game.settlement_hub.station_buttons["assignment_board"].has_focus() and game.settlement_hub.detail_body.text.contains("Parts Crate"), "the opening bazaar should focus and name the medicine carrier")
	game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
	await process_frame
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.veyru_contract_status == "accepted" and game.campaign_path_label.text.contains("Carrier: Parts Crate"), "accepting through the UI should persist the exact medicine carrier")
	_expect(game.settlement_hub.station_buttons["departure_gate"].has_focus(), "answering the Veyru contract should focus the departure gate")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	var opening_focus := game.get_viewport().gui_get_focus_owner()
	_expect(opening_focus in game.campaign_node_buttons and game.journey_planner.map_host.get_global_rect().encloses(opening_focus.get_global_rect()), "opening the Veyru route table should focus a visible opening road")

	await _press_route("pump_gallery")
	_expect(game.state.phase == "battle" and game.combat_panel.visible and _combat_names_include("Flood Surge") and not _combat_names_include("Climber"), "Pump Gallery should show Flood Surge alone in the combat UI")
	await _finish_battle()
	_expect(game.state.campaign_event_pending == "drain_pumps" and game.campaign_event_title.text == "THE GALLERY STILL TURNS", "Pump Gallery should hand off to the authored drain decision")
	var pump_briefing_state: Dictionary = game.state.serialize()
	game._show_onboarding(true)
	await process_frame
	_expect(game.onboarding_step == 5 and game.onboarding_title_label.text == "Read the rising water", "a Veyru road decision should reopen Field Briefing at its water-and-route topic")
	game._finish_onboarding(true)
	await _settle_ui()
	_expect(game.state.serialize() == pump_briefing_state, "contextual Veyru route guidance should preserve the active decision")
	await _press_event("drain_gallery")

	await _press_route("veyru_evacuation_camp")
	await _finish_battle()
	_expect(game.state.phase == "settlement" and game.settlement_title.text.contains("EVACUATION CAMP SERVICES") and game.settlement_title.text.contains("2 ACTIONS LEFT"), "the protected medicine carrier should grant two visible Evacuation Camp actions")
	var camp_focus := game.get_viewport().gui_get_focus_owner()
	_expect(camp_focus in [game.settlement_repair_button, game.settlement_refuel_button, game.settlement_hull_button, game.settlement_routes_button] and game.right_scroll.get_global_rect().encloses(camp_focus.get_global_rect()), "arrival at Evacuation Camp should focus a visible recovery or road-review action")
	game.state.fuel = 1
	game._refresh_ui()
	_expect(not game.settlement_refuel_button.disabled and game.settlement_refuel_button.text.contains("+1 EMERGENCY FUEL") and game.settlement_refuel_button.text.contains("FREE"), "Evacuation Camp should expose its free low-fuel safeguard")
	game.settlement_refuel_button.pressed.emit()
	await process_frame
	_expect(game.state.fuel == 2 and game.event_label.text.contains("+1 fuel loaded for 0 Ashmarks"), "using emergency fuel should report the exact no-cost transaction")
	game.state.fuel = 5
	game._refresh_ui()

	game.settlement_routes_button.pressed.emit()
	await _settle_ui()
	await _press_route("archive_causeway")
	await _finish_battle()
	await _press_route("dry_archive_gate")
	await _finish_battle()
	_expect(game.state.campaign_event_pending == "archive_broadcast" and game.campaign_event_title.text == "WHAT THE ARCHIVE BROADCASTS", "the fourth encounter should present the final archive commitment in the shared event card")
	game._show_onboarding(true)
	await process_frame
	_expect(game.onboarding_step == 6 and game.onboarding_title_label.text == "Choose what the archive says", "the archive commitment should reopen Field Briefing at its authored finale topic")
	game._finish_onboarding(true)
	await _settle_ui()
	_expect(game.campaign_event_buttons[0].text.contains("Climbers join") and game.campaign_event_buttons[1].text.contains("Carrier damage -1"), "the archive commitment UI should state both mechanical consequences before selection")
	var decision_focus := game.get_viewport().gui_get_focus_owner()
	_expect(decision_focus in game.campaign_event_buttons and game.right_scroll.get_global_rect().encloses(game.campaign_event_buttons[1].get_global_rect()), "the final commitment should focus its event card with both choices visible")
	await _press_event("seal_archive")
	_expect(game.state.campaign_available_nodes() == ["dry_archive"] and game.campaign_map.status_for("dry_archive") == "available", "resolving the archive commitment should open the final node")

	await _press_route("dry_archive")
	_expect(game.state.phase == "final_battle" and _combat_names_include("Civic Guardian"), "the final Veyru route should enter the shared final-battle UI with the Civic Guardian")
	await _finish_battle()
	_expect(game.state.phase == "results" and game.state.final_result == "archive_kept", "the UI-driven Veyru route should reach Archive Kept")
	_expect(game.results_summary_label.text.contains("ARCHIVE KEPT") and game.results_record_label.text.contains("Rising water:") and game.results_record_label.text.contains("Carrier: Parts Crate") and game.results_record_label.text.contains("Dry Archive — sealed the signal"), "the Veyru debrief should name its result, water, carrier, and final commitment")

	if failures.is_empty():
		print("PASS: The Long March Flooded Veyru UI flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
