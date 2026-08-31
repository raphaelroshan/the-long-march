extends SceneTree

var game: Control
var failures: Array[String] = []
var capture_dir := ""


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle_ui() -> void:
	for _frame in range(4):
		await process_frame

func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "Veyru capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "Veyru capture should be written: " + name)


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
	_expect(game.journey_transition.promise_label.text.contains("sealed medicines") and game.journey_transition.phase_label.text.contains("COSTS APPLIED") and game.journey_transition.presentation_beat() == "departed" and game.journey_transition.next_label.text.contains("Skip the march beat"), "the Veyru departure order should carry its medicine promise, committed phase, and skippable march handoff")
	game.journey_transition.continue_button.pressed.emit()
	await process_frame


func _press_event(choice_id: String) -> void:
	var button: Button = game.roadside_event.button_for(choice_id)
	if button != null and button.visible:
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
			_expect(String(game.journey_arrival.arrival_canvas.arrival_visual_signature().get("destination_id", "")) == String(game.journey_arrival.current_view.get("destination_id", "")) and not String(game.journey_arrival.arrival_canvas.arrival_visual_signature().get("motif", "")).is_empty(), "Veyru arrival should render the authoritative destination with a named regional motif")
			await _capture("arrival_%s" % String(game.journey_arrival.current_view.get("destination_id", "unknown")))
			game.journey_arrival.continue_button.pressed.emit()
			await process_frame
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame
	_expect(false, "Veyru battle should resolve within the shared six-step timeline")


func _run() -> void:
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
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
	_expect(game.settlement_hub.context_label.text.contains("LANTERN QUAY FLOOD MARKET") and game.settlement_hub.bazaar_canvas.presentation_signature().contains("FLOOD DOCK"), "Lantern Quay's starting bazaar should identify its raised flood-market setting")
	_expect(game.settlement_hub.place_identity_label.text.contains("FLOODLINE MARKET") and game.settlement_hub.pressure_label.text.contains("RISING WATER") and game.settlement_hub.route_meaning_label.text.contains("Pump Gallery") and game.settlement_hub.route_meaning_label.text.contains("Sunken Tramworks"), "Lantern Quay should state its place, active water pressure, and the meaning of both opening roads")
	_expect(game.settlement_hub.bazaar_canvas.route_signature() == "PUMP GALLERY · SUNKEN TRAMWORKS", "Lantern Quay's center stage should carry a visible two-road departure sign")
	await _capture("02_lantern_quay")
	game.settlement_hub.station_buttons["signal_broker"].pressed.emit()
	await process_frame
	_expect(game.settlement_hub.detail_body.text.contains("water levels") and game.settlement_hub.detail_body.text.contains("archive signals"), "Lantern Quay's signal service should reflect its local route problem")
	game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
	await process_frame
	_expect(game.settlement_hub.visible and game.settlement_hub.primary_action_button.has_focus() and game.settlement_hub.detail_body.text.contains("Parts Crate"), "the opening bazaar should expose and name the medicine carrier after inspecting another local service")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.veyru_contract_status == "accepted" and game.campaign_path_label.text.contains("Carrier: Parts Crate"), "accepting through the UI should persist the exact medicine carrier")
	_expect(game.settlement_hub.station_buttons["departure_gate"].has_focus(), "answering the Veyru contract should focus the departure gate")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	_expect(game.settlement_hub.detail_body.text.contains("Pump Gallery") and game.settlement_hub.detail_body.text.contains("Sunken Tramworks"), "Lantern Quay's departure gate should explain the managed-water road and submerged cut before route planning")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle_ui()
	var opening_focus := game.get_viewport().gui_get_focus_owner()
	_expect(opening_focus in game.campaign_node_buttons and game.journey_planner.map_host.get_global_rect().encloses(opening_focus.get_global_rect()), "opening the Veyru route table should focus a visible opening road")
	_expect(game.campaign_map.assignment_marker_for("dry_archive") == "accepted" and game.campaign_map.marker_labels["dry_archive"].text == "ACCEPTED", "the Veyru route map should carry the medicine obligation onto the Dry Archive destination")

	await _press_route("pump_gallery")
	_expect(game.state.phase == "battle" and game.combat_panel.visible and _combat_names_include("Flood Surge") and not _combat_names_include("Climber"), "Pump Gallery should show Flood Surge alone in the combat UI")
	await _finish_battle()
	_expect(game.state.campaign_event_pending == "drain_pumps" and game.campaign_event_title.text == "THE GALLERY STILL TURNS", "Pump Gallery should hand off to the authored drain decision")
	_expect(game.roadside_event.story_label.text.contains("ONE DAY AGAINST TWO WATER") and game.roadside_event.tableau.presentation_signature() == "OLD DRAIN · ONE DAY OR TWO WATER", "the Pump Gallery should frame its delay as a visible choice against the flood clock")
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
	_expect(game.recovery_panel.visible and camp_focus in [game.recovery_panel.repair_button, game.recovery_panel.refuel_button, game.recovery_panel.hull_button, game.recovery_panel.routes_button] and camp_focus.is_visible_in_tree(), "arrival at Evacuation Camp should focus a visible recovery or road-review action")
	_expect(game.recovery_panel.local_stake_label.text.contains("medicine carrier") and game.recovery_panel.route_outlook_label.text.contains("Archive Causeway") and game.recovery_panel.route_outlook_label.text.contains("Drowned Registry") and game.recovery_panel.route_outlook_label.text.contains("Pilgrim Gantry"), "Evacuation Camp recovery should carry the medicine stake into three distinct outbound road meanings")
	game.state.fuel = 1
	game._refresh_ui()
	_expect(not game.recovery_panel.refuel_button.disabled and game.recovery_panel.refuel_button.text.contains("+1 EMERGENCY FUEL") and game.recovery_panel.refuel_button.text.contains("FREE"), "Evacuation Camp should expose its free low-fuel safeguard")
	game.recovery_panel.refuel_button.pressed.emit()
	await process_frame
	_expect(game.state.fuel == 2 and game.event_label.text.contains("+1 fuel loaded for 0 Ashmarks"), "using emergency fuel should report the exact no-cost transaction")
	_expect(game.recovery_panel.receipt_label.text.contains("+1 fuel loaded for 0 Ashmarks"), "the Evacuation Camp receipt should keep the emergency safeguard legible")
	game.state.fuel = 5
	game._refresh_ui()

	game.recovery_panel.routes_button.pressed.emit()
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
	_expect(decision_focus in game.roadside_event.choice_buttons, "the final commitment should focus its roadside choice set")
	_expect(game.get_global_rect().encloses(game.roadside_event.choice_buttons[1].get_global_rect()), "the final commitment should keep both roadside choices visible")
	await _press_event("seal_archive")
	_expect(game.state.campaign_available_nodes() == ["dry_archive"] and game.campaign_map.status_for("dry_archive") == "available", "resolving the archive commitment should open the final node")

	await _press_route("dry_archive")
	_expect(game.state.phase == "final_battle" and _combat_names_include("Civic Guardian"), "the final Veyru route should enter the shared final-battle UI with the Civic Guardian")
	await _finish_battle()
	_expect(game.state.phase == "results" and game.state.final_result == "archive_kept", "the UI-driven Veyru route should reach Archive Kept")
	_expect(game.debrief_panel.visible and game.debrief_panel.headline_label.text == "DECISIVE" and game.debrief_panel.outcome_label.text.contains("ARCHIVE KEPT") and game.debrief_panel.commitments_label.text.contains("Parts Crate") and game.debrief_panel.commitments_label.text.contains("Pump Gallery — drained the lower roads") and game._result_record_text().contains("Rising water:") and game._result_record_text().contains("Dry Archive — sealed the signal"), "the Veyru debrief should name its result, water, carrier, pump decision, and final commitment")

	if failures.is_empty():
		print("PASS: The Long March Flooded Veyru UI flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
