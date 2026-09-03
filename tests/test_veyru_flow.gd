extends SceneTree

var game: Control
var failures: Array[String] = []
var capture_dir := ""
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
		if control.has_theme_font_size_override("normal_font_size"):
			control.add_theme_font_size_override("normal_font_size", roundi(float(control.get_theme_font_size("normal_font_size")) * 1.1))
	for child in node.get_children():
		_apply_large_text(child)


func _expect_visible_inside(surface: Control, controls: Array, label: String) -> void:
	if not responsive_profile:
		return
	var surface_rect := surface.get_global_rect()
	for control in controls:
		if control == null or not control.is_visible_in_tree():
			_expect(false, "%s should keep every required control visible" % label)
			continue
		_expect(surface_rect.encloses(control.get_global_rect()), "%s should keep %s inside %dx%d" % [label, control.name, viewport_size.x, viewport_size.y])

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
	_expect(game.journey_transition.promise_label.text.contains("sealed medicines") and game.journey_transition.phase_label.text.contains("COSTS APPLIED") and game.journey_transition.presentation_beat() == ("contact_ahead" if responsive_profile else "departed"), "the Veyru departure order should carry its medicine promise, committed phase, and motion preference")
	_expect_visible_inside(game.journey_transition, [game.journey_transition.day_label, game.journey_transition.march_canvas, game.journey_transition.continue_button], "Veyru departure")
	if node_id == "pump_gallery":
		game.journey_transition._process(0.4)
		_expect(String(game.journey_transition.march_canvas.route_visual_signature().get("destination_id", "")) == "pump_gallery", "the first Veyru road should retain its Pump Gallery destination")
		if not responsive_profile:
			_expect(game.journey_transition.march_canvas.beat_visual_signature() == "GALLERY WHEEL PASSING", "the animated Veyru road should carry its pump machinery into the travel beat")
		await _capture("03_pump_gallery_travel")
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
	var width_text := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height_text := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width_text.is_valid_int() and height_text.is_valid_int():
		viewport_size = Vector2i(int(width_text), int(height_text))
	responsive_profile = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	root.size = viewport_size
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
	if responsive_profile:
		game.set_high_contrast(true)
		game.set_reduced_motion(true)
		game.set_controller_layout("east_confirm")
		_apply_large_text(game)
		await _settle_ui()

	_expect(game.state.campaign_region_id == "flooded_veyru" and game.state.current_location == "lantern_quay", "the Veyru UI flow should begin at Lantern Quay")
	_expect(game.settlement_hub.context_label.text.contains("LANTERN QUAY FLOOD MARKET") and game.settlement_hub.bazaar_canvas.presentation_signature().contains("FLOOD DOCK"), "Lantern Quay's starting bazaar should identify its raised flood-market setting")
	_expect(game.settlement_hub.place_identity_label.text.contains("FLOODLINE MARKET") and game.settlement_hub.pressure_label.text.contains("RISING WATER") and game.settlement_hub.route_meaning_label.text.contains("Pump Gallery") and game.settlement_hub.route_meaning_label.text.contains("Sunken Tramworks"), "Lantern Quay should state its place, active water pressure, and the meaning of both opening roads")
	_expect(game.settlement_hub.bazaar_canvas.route_signature() == "PUMP GALLERY · SUNKEN TRAMWORKS", "Lantern Quay's center stage should carry a visible two-road departure sign")
	_expect(game.settlement_hub.attendant_label.text == "ATTENDANT · MEDICINE COURIER" and game.settlement_hub.attendant_portrait.presentation_signature() == "LANTERN_QUAY · ASSIGNMENT_BOARD · MEDICINE COURIER", "Lantern Quay's initial assignment should have a place-specific human representative")
	_expect_visible_inside(game.settlement_hub, [game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, game.settlement_hub.station_buttons["departure_gate"]], "Lantern Quay")
	await _capture("02_lantern_quay")
	game.settlement_hub.station_buttons["signal_broker"].pressed.emit()
	await process_frame
	_expect(game.settlement_hub.attendant_label.text == "ATTENDANT · LANTERN READER" and game.settlement_hub.attendant_portrait.presentation_signature().contains("SIGNAL_BROKER"), "the Veyru signal stall should replace the courier with its own attendant and prop")
	_expect(game.settlement_hub.detail_body.text.contains("water levels") and game.settlement_hub.detail_body.text.contains("archive signals"), "Lantern Quay's signal service should reflect its local route problem")
	await _capture("02b_lantern_signal")
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
	var carrier_marker: Label = game.campaign_map.marker_labels.get("dry_archive") as Label
	var carrier_destination: Button = game.campaign_map.button_for("dry_archive") as Button
	_expect(carrier_marker != null and carrier_destination != null and not carrier_marker.get_global_rect().intersects(carrier_destination.get_global_rect()) and game.campaign_map.get_global_rect().encloses(carrier_marker.get_global_rect()), "the medicine assignment badge should remain beside the Dry Archive node without obscuring its destination label")
	_expect_visible_inside(game.journey_planner, [game.journey_planner.map_host, opening_focus, game.campaign_commit_button], "Veyru route planner")

	await _press_route("pump_gallery")
	_expect(game.state.phase == "battle" and game.combat_panel.visible and _combat_names_include("Flood Surge") and not _combat_names_include("Climber"), "Pump Gallery should show Flood Surge alone in the combat UI")
	_expect_visible_inside(game.road_contact, [game.road_contact.contact_canvas, game.advance_encounter_button, game.road_contact.intervention_buttons[0]], "Veyru contact")
	await _finish_battle()
	_expect(game.state.campaign_event_pending == "drain_pumps" and game.campaign_event_title.text == "THE GALLERY STILL TURNS", "Pump Gallery should hand off to the authored drain decision")
	_expect(game.roadside_event.body_label.text.contains("scoop wheels") and game.roadside_event.story_label.text.contains("ONE DAY AGAINST TWO WATER") and game.roadside_event.choice_buttons[0].text.contains("Rising water") and game.roadside_event.tableau.presentation_signature() == "OLD DRAIN · ONE DAY OR TWO WATER", "the Pump Gallery should tie its exact delay-versus-water choice to the working drain machinery")
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
	_expect(game.recovery_panel.visible and camp_focus in [game.recovery_panel.repair_button, game.recovery_panel.refuel_button, game.recovery_panel.hull_button, game.recovery_panel.refit_button, game.recovery_panel.routes_button] and camp_focus.is_visible_in_tree(), "arrival at Evacuation Camp should focus a visible recovery, refit, or road-review action")
	_expect(game.recovery_panel.local_stake_label.text.contains("medicine carrier") and game.recovery_panel.route_outlook_label.text.contains("Archive Causeway") and game.recovery_panel.route_outlook_label.text.contains("Drowned Registry") and game.recovery_panel.route_outlook_label.text.contains("Pilgrim Gantry"), "Evacuation Camp recovery should carry the medicine stake into three distinct outbound road meanings")
	_expect_visible_inside(game.recovery_panel, [game.recovery_panel.recovery_canvas, game.recovery_panel.routes_button, camp_focus], "Evacuation Camp recovery")
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
	_expect(game.roadside_event.body_label.text.contains("district frequency") and game.roadside_event.story_label.text.contains("PUBLIC HEADINGS OR CARRIER COVER") and game.roadside_event.tableau.presentation_signature() == "ROOF RELAY · PUBLIC HEADINGS OR CARRIER COVER", "the archive commitment should connect its public signal to the medicine carrier's physical exposure")
	game._show_onboarding(true)
	await process_frame
	_expect(game.onboarding_step == 6 and game.onboarding_title_label.text == "Choose what the archive says", "the archive commitment should reopen Field Briefing at its authored finale topic")
	game._finish_onboarding(true)
	await _settle_ui()
	_expect(game.campaign_event_buttons[0].text.contains("Climbers join") and game.campaign_event_buttons[1].text.contains("Carrier damage -1"), "the archive commitment UI should state both mechanical consequences before selection")
	var decision_focus := game.get_viewport().gui_get_focus_owner()
	_expect(decision_focus in game.roadside_event.choice_buttons, "the final commitment should focus its roadside choice set")
	_expect(game.get_global_rect().encloses(game.roadside_event.choice_buttons[1].get_global_rect()), "the final commitment should keep both roadside choices visible")
	_expect_visible_inside(game.roadside_event, [game.roadside_event.tableau, game.roadside_event.choice_buttons[0], game.roadside_event.choice_buttons[1]], "Veyru final commitment")
	await _press_event("seal_archive")
	_expect(game.state.campaign_available_nodes() == ["dry_archive"] and game.campaign_map.status_for("dry_archive") == "available", "resolving the archive commitment should open the final node")

	await _press_route("dry_archive")
	_expect(game.state.phase == "final_battle" and _combat_names_include("Civic Guardian"), "the final Veyru route should enter the shared final-battle UI with the Civic Guardian")
	await _finish_battle()
	_expect(game.state.phase == "results" and game.state.final_result == "archive_kept", "the UI-driven Veyru route should reach Archive Kept")
	_expect(game.debrief_panel.visible and game.debrief_panel.headline_label.text == "DECISIVE" and game.debrief_panel.outcome_label.text.contains("ARCHIVE KEPT") and game.debrief_panel.commitments_label.text.contains("Parts Crate") and game.debrief_panel.commitments_label.text.contains("Pump Gallery — drained the lower roads") and game._result_record_text().contains("Rising water:") and game._result_record_text().contains("Dry Archive — sealed the signal"), "the Veyru debrief should name its result, water, carrier, pump decision, and final commitment")
	_expect_visible_inside(game.debrief_panel, [game.debrief_panel.fortress_canvas, game.debrief_panel.inspect_button, game.debrief_panel.notes_button], "Veyru Debrief")

	if failures.is_empty():
		if responsive_profile:
			print("PASS: The Long March responsive Veyru profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March Flooded Veyru UI flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
