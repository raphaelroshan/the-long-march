extends SceneTree

const LOCAL_PATHS := [
	"user://the_long_march_prototype.save",
	"user://the_long_march_prototype.backup.save",
	"user://the_long_march_tutorial.save",
	"user://the_long_march_tutorial.backup.save",
	"user://the_long_march_tutorial.complete",
	"user://the_long_march_onboarding_v1.complete",
	"user://the_long_march_settings.cfg",
	"user://the_long_march_progress.json",
	"user://the_long_march_playtest_journal.json",
]

var failures: Array[String] = []
var app: Control
var game: Control
var capture_dir := ""
var responsive_profile := false
var cinder_quarry_profile := false
var declined_convoy_profile := false
var mastery_profile := false
var capture_filter: Array[String] = []
var viewport_size := Vector2i(1600, 900)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _remove_local_state() -> void:
	for path in LOCAL_PATHS:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute):
			DirAccess.remove_absolute(absolute)


func _configure_environment_profile() -> void:
	var width_text := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height_text := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width_text.is_valid_int() and height_text.is_valid_int():
		viewport_size = Vector2i(int(width_text), int(height_text))
	responsive_profile = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	if not responsive_profile:
		return
	var config := ConfigFile.new()
	config.set_value("accessibility", "text_scale_percent", 110)
	config.set_value("accessibility", "high_contrast", true)
	config.set_value("accessibility", "reduced_motion", true)
	config.set_value("input", "controller_layout", "east_confirm")
	config.set_value("audio", "interface_percent", 0)
	var save_result := config.save(ProjectSettings.globalize_path("user://the_long_march_settings.cfg"))
	_expect(save_result == OK, "the responsive profile should create deterministic local preferences")


func _settle(frames: int = 3) -> void:
	for _frame in range(frames):
		await process_frame


func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	if not capture_filter.is_empty() and name not in capture_filter:
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "capture requires a rendering display: " + name)
		return
	var result := image.save_png(capture_dir.path_join(name + ".png"))
	_expect(result == OK, "capture should be written: " + name)


func _rect_encloses(outer: Rect2, inner: Rect2) -> bool:
	return inner.position.x >= outer.position.x - 1.0 and inner.position.y >= outer.position.y - 1.0 and inner.end.x <= outer.end.x + 1.0 and inner.end.y <= outer.end.y + 1.0


func _expect_three_column_contract(surface: Control, left: Control, center: Control, right: Control, label: String) -> void:
	if not responsive_profile:
		return
	var surface_rect := surface.get_global_rect()
	var left_rect := left.get_global_rect()
	var center_rect := center.get_global_rect()
	var right_rect := right.get_global_rect()
	_expect(left.is_visible_in_tree() and center.is_visible_in_tree() and right.is_visible_in_tree(), label + " should keep all three presentation regions visible")
	_expect(_rect_encloses(surface_rect, left_rect) and _rect_encloses(surface_rect, center_rect) and _rect_encloses(surface_rect, right_rect), "%s should keep status, fortress/map, and required action inside the viewport · surface %s · left %s · center %s · right %s" % [label, surface_rect, left_rect, center_rect, right_rect])
	_expect(left_rect.get_center().x < center_rect.get_center().x and center_rect.get_center().x < right_rect.get_center().x, label + " should preserve left status, center subject, and right action hierarchy")


func _launch_app() -> void:
	app = load("res://scenes/App.tscn").instantiate()
	root.add_child(app)
	await _settle()
	game = app.game_view


func _relaunch_and_continue(expected_surface: String) -> void:
	app.queue_free()
	await _settle()
	await _launch_app()
	_expect(app.continue_button.visible and not app.continue_button.disabled, "a saved handoff should expose Continue on relaunch")
	app.continue_button.pressed.emit()
	await _settle(5)
	game = app.game_view
	_expect(game != null and not game.tutorial_mode, "Continue should reopen the live Ashgate march")
	match expected_surface:
		"departure":
			_expect(game.journey_transition.visible and game.journey_transition.continue_button.has_focus(), "Continue should restore the pending departure and its action focus")
			_expect(game.last_journey_receipt.begins_with("ROUTE COMMITTED"), "departure resume should preserve the last committed journey receipt")
		"arrival":
			_expect(game.journey_arrival.visible and game.journey_arrival.continue_button.has_focus(), "Continue should restore the pending arrival and its action focus")
			_expect(game.last_journey_receipt.begins_with("ROAD"), "arrival resume should preserve the resolved-road receipt")
		_:
			_expect(false, "unknown relaunch surface: " + expected_surface)


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "event choice should be available through the visible tableau: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle()


func _commit_route(node_id: String) -> void:
	var button := game.campaign_map.button_for(node_id) as Button
	_expect(button != null and button.visible and not button.disabled, "route should be available through the visible map: " + node_id)
	if button == null or button.disabled:
		return
	button.pressed.emit()
	await _settle()
	_expect(game.selected_campaign_node_id == node_id and game.campaign_commit_button.has_focus(), "route inspection should move focus to explicit commitment: " + node_id)
	game.campaign_commit_button.pressed.emit()
	await _settle()
	_expect(game.journey_transition.visible and game.journey_transition.continue_button.has_focus(), "route commitment should open a focused departure handoff: " + node_id)


func _enter_contact() -> void:
	_expect(game.journey_transition.visible, "contact entry should begin at the travel handoff")
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	_expect(game.road_contact.visible and game.road_contact.advance_button.has_focus(), "travel should hand focus to the visible road contact")


func _resolve_contact(expected_phase: String) -> void:
	if game.state.encounter_active:
		game.road_contact.advance_button.pressed.emit()
		await _settle()
	if game.state.encounter_active and not game.state.encounter_intervention_used:
		var shift_button := game.road_contact.intervention_buttons[0] as Button
		if shift_button.visible and not shift_button.disabled:
			shift_button.pressed.emit()
			await _settle()
	for _step in range(10):
		if not game.state.encounter_active:
			break
		game.road_contact.advance_button.pressed.emit()
		await _settle()
	_expect(not game.state.encounter_active and game.state.phase == expected_phase, "visible contact steps should resolve into " + expected_phase)
	_expect(game.journey_arrival.visible and game.journey_arrival.continue_button.has_focus(), "a resolved contact should stop at a focused arrival receipt")


func _acknowledge_arrival() -> void:
	game.journey_arrival.continue_button.pressed.emit()
	await _settle()
	_expect(not game.journey_arrival.visible, "acknowledging arrival should expose the next player-facing order")


func _complete_first_watch() -> void:
	app.tutorial_button.pressed.emit()
	await _settle()
	_expect(app.tutorial_intro.visible and app.tutorial_intro.next_button.has_focus(), "Learn to Command should open the focused prologue")
	if responsive_profile:
		var intro_rect: Rect2 = app.tutorial_intro.get_global_rect()
		_expect(_rect_encloses(intro_rect, app.tutorial_intro.next_button.get_global_rect()) and _rect_encloses(intro_rect, app.tutorial_intro.skip_button.get_global_rect()), "the large-text tutorial prologue should keep both actions inside the compact viewport")
	await _capture("01_first_watch_prologue")
	app.tutorial_intro.next_button.pressed.emit()
	app.tutorial_intro.next_button.pressed.emit()
	await _settle()
	app.tutorial_intro.next_button.pressed.emit()
	await _settle(5)
	game = app.game_view
	_expect(game != null and game.tutorial_mode and game.tutorial_director.lesson_id == "place_engine", "the prologue should enter the interactive muster yard")
	game._on_grid_cell_pressed(Vector2i(0, 0))
	await _settle()
	game._on_grid_cell_pressed(Vector2i(5, 0))
	await _settle()
	game._on_grid_cell_pressed(Vector2i(0, 0))
	game._on_grid_cell_pressed(Vector2i(5, 0))
	await _settle()
	_expect(game.tutorial_director.lesson_id == "plan_road", "visible chassis actions should complete the placement and dependency lessons")
	game.travel_button.pressed.emit()
	await _settle()
	_expect(game.journey_transition.visible and game.tutorial_director.lesson_id == "travel", "the tutorial road should enter the shared departure presentation")
	_expect(game.journey_transition.route_label.text.begins_with("ASHGATE MUSTER YARD → MUSTER ROAD") and game.journey_transition.destination_label.text == "MUSTER ROAD" and game.journey_transition.promise_label.text.begins_with("TRAINING ORDER"), "the tutorial departure should preserve its own place and purpose")
	_expect(game.journey_transition.presentation_beat() == ("contact_ahead" if responsive_profile else "departed"), "the tutorial march should skip directly under reduced motion and otherwise begin at departure")
	_expect_three_column_contract(game.journey_transition, game.journey_transition.day_label, game.journey_transition.march_canvas, game.journey_transition.continue_button, "First Watch departure")
	await _capture("02_first_watch_departure")
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	game.road_contact.advance_button.pressed.emit()
	await _settle()
	game.road_contact.advance_button.pressed.emit()
	await _settle()
	game.road_contact.advance_button.pressed.emit()
	await _settle()
	var tutorial_order := game.road_contact.intervention_buttons[0] as Button
	_expect(not tutorial_order.disabled, "the tutorial should expose a legal emergency order")
	tutorial_order.pressed.emit()
	await _settle()
	var damaged: Dictionary = game._most_damaged_installed_module()
	_expect(not damaged.is_empty(), "the tutorial contact should leave one damaged system to inspect")
	if not damaged.is_empty():
		game._on_grid_cell_pressed(Vector2i(damaged.get("position", Vector2i.ZERO)))
		await _settle()
	for _step in range(10):
		if not game.state.encounter_active:
			break
		game.road_contact.advance_button.pressed.emit()
		await _settle()
	_expect(game.journey_arrival.visible and game.tutorial_director.lesson_id == "repair", "First Watch should reach its recovery siding through normal contact steps")
	_expect(game.journey_arrival.destination_label.text == "MUSTER ROAD RECOVERY SIDING" and game.journey_arrival.continue_button.text == "ENTER RECOVERY SIDING", "First Watch arrival should name the training recovery handoff")
	_expect(game.journey_arrival.report_label.text.contains("Muster Yard records the drill") and not game.journey_arrival.report_label.text.contains("Morrowline"), "First Watch arrival should use a training receipt instead of a live campaign payout")
	_expect(game.journey_arrival.beat_label.text.contains("CONSEQUENCES APPLIED") and game.journey_arrival.next_label.text.contains("restore the affected system"), "First Watch arrival should separate the consequence receipt from its next order")
	_expect_three_column_contract(game.journey_arrival, game.journey_arrival.receipt_labels["hull"], game.journey_arrival.arrival_canvas, game.journey_arrival.continue_button, "First Watch arrival")
	await _capture("03_first_watch_arrival")
	game.journey_arrival.continue_button.pressed.emit()
	await _settle()
	_expect(game.settlement_title.text.begins_with("MUSTER YARD SERVICES"), "the recovery lesson should remain visibly anchored to the Muster Yard")
	damaged = game._most_damaged_installed_module()
	if not damaged.is_empty():
		game._on_grid_cell_pressed(Vector2i(damaged.get("position", Vector2i.ZERO)))
		await _settle()
		game.settlement_repair_button.pressed.emit()
		await _settle()
	_expect(game.tutorial_completion_view.visible and game.tutorial_completion_view.begin_button.has_focus(), "repair should complete First Watch and focus the campaign handoff")
	await _capture("04_first_watch_complete")
	game.tutorial_completion_view.begin_button.pressed.emit()
	await _settle(5)
	game = app.game_view
	_expect(game != null and not game.tutorial_mode and game.state.campaign_active, "First Watch certification should enter a fresh Ashgate campaign")


func _run_ashgate_journey() -> void:
	_expect(game.settlement_hub.visible and game.settlement_hub.station_buttons["assignment_board"].has_focus(), "Ashgate handoff should begin at the required assignment")
	_expect(game.get_global_rect().encloses(game.settlement_hub.primary_action_button.get_global_rect()), "the first Ashgate action should be visible at 1600x900")
	_expect(not app.checkpoint_toast.get_global_rect().intersects(game.settlement_hub.location_label.get_global_rect()), "the compact save notice should not obscure the current location heading")
	_expect_three_column_contract(game.settlement_hub, game.settlement_hub.value_labels["hull"], game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, "Ashgate bazaar")
	await _capture("05_ashgate_handoff")
	if mastery_profile:
		game.settlement_hub.station_buttons["signal_broker"].pressed.emit()
		await _settle()
		_expect(game.settlement_hub.detail_title.text == "MARCHMASTER'S DESK" and game.settlement_hub.primary_action_button.text.contains("QUARRY") and game.settlement_hub.secondary_action_button.text.contains("SIGNAL"), "the Marchmaster's Desk should offer two bounded field experiments")
		await _capture("05c_mastery_orders")
		game.settlement_hub.primary_action_button.pressed.emit()
		await _settle()
		_expect(game.state.mastery_experiment_id == "ashgate_quarry_adaptation" and game.settlement_hub.context_label.text.contains("FIELD ORDER: QUARRY ADAPTATION"), "selecting Quarry Adaptation should retain its field order before departure")
		await _capture("05d_quarry_order_selected")
	game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
	await _settle()
	if declined_convoy_profile:
		_expect(game.settlement_hub.detail_body.text.contains("only 1 service action") and game.settlement_hub.secondary_action_button.tooltip_text.contains("only 1 service action"), "the assignment board should disclose the exact Morrowline shortage before decline")
		game.settlement_hub.secondary_action_button.pressed.emit()
	else:
		game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.state.guard_contract_status == ("declined" if declined_convoy_profile else "accepted") and game.settlement_hub.station_buttons["departure_gate"].has_focus(), "answering the assignment should hand focus to departure")
	if declined_convoy_profile:
		_expect(game.settlement_hub.context_label.text.contains("Morrowline will have 1 service action"), "the declined assignment receipt should retain its later service consequence")
		await _capture("05b_declined_convoy_receipt")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await _settle()
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible and game.campaign_map.button_for("rill_crossing").has_focus(), "departure should open route planning at the first available road")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await _settle()
	_expect_three_column_contract(game.journey_planner, game.journey_planner.value_labels["day"], game.journey_planner.map_host, game.campaign_commit_button, "route commitment")
	await _capture("06_route_commitment")
	game.campaign_commit_button.pressed.emit()
	await _settle()
	_expect_three_column_contract(game.journey_transition, game.journey_transition.day_label, game.journey_transition.march_canvas, game.journey_transition.continue_button, "Ashgate departure")
	if responsive_profile:
		_expect(game.journey_transition.high_contrast_enabled and game.journey_transition.reduced_motion and game.journey_transition.presentation_beat() == "contact_ahead" and game.journey_transition.continue_button.text == "ENTER CONTACT" and game.journey_transition.pause_button.text.contains("A"), "the live departure should preserve contrast, skip motion, expose contact, and retain alternate controller guidance")
	await _capture("07_departure")
	if not responsive_profile and not capture_dir.is_empty():
		game.journey_transition._process(0.4)
		await _capture("07b_road_in_motion")
		game.journey_transition._process(0.7)
		await _capture("07c_contact_ahead")
	await _relaunch_and_continue("departure")
	_expect(game.state.campaign_target_node == "rill_crossing" and game.state.encounter_step == 0, "departure resume should preserve the committed road before contact")
	await _enter_contact()
	_expect_three_column_contract(game.road_contact, game.road_contact.value_labels["hull"], game.road_contact.contact_canvas, game.road_contact.advance_button, "road contact")
	await _capture("08_road_contact")
	await _resolve_contact("map")
	await _capture("09_arrival_receipt")
	await _relaunch_and_continue("arrival")
	_expect(game.state.current_location == "rill_crossing" and game.state.campaign_event_pending == "lift_chain_sings", "arrival resume should preserve the secured road and pending occurrence")
	await _acknowledge_arrival()
	_expect_three_column_contract(game.roadside_event, game.roadside_event.value_labels["day"], game.roadside_event.tableau, game.roadside_event.choice_buttons[0], "roadside event")
	await _capture("10_roadside_event")
	await _choose_event("brace_lift_chain")
	_expect(game.journey_planner.visible and game.journey_planner.receipt_label.text.contains("LAST RECEIPT"), "a resolved roadside event should leave its consequence receipt on the reopened route table")
	await _capture("10b_consequence_receipt")

	await _commit_route("broken_relay")
	await _enter_contact()
	await _resolve_contact("map")
	await _acknowledge_arrival()
	await _choose_event("move_silent")

	await _commit_route("morrowline_camp")
	await _enter_contact()
	await _resolve_contact("settlement")
	await _acknowledge_arrival()
	_expect(game.state.campaign_event_pending == "mara_meeting", "Morrowline arrival should surface Mara's operational offer")
	await _choose_event("decline_mara")
	_expect(game.recovery_panel.visible and game.recovery_panel.routes_button.visible, "declining Mara should continue into the normal recovery tableau")
	if declined_convoy_profile:
		_expect(game.state.settlement_actions_remaining == 1 and game.recovery_panel.local_stake_label.text.contains("PARTS SHORTAGE") and game.recovery_panel.local_stake_label.text.contains("only 1 service action"), "Morrowline recovery should expose the declined convoy as a one-action parts shortage")
	else:
		_expect(game.state.settlement_actions_remaining == 2 and game.recovery_panel.local_stake_label.text.contains("promise is kept"), "Morrowline recovery should expose the completed convoy's two-action benefit")
	_expect(game.recovery_panel.route_outlook_label.text.contains("Lower Ash") and game.recovery_panel.route_outlook_label.text.contains("Dry Cistern") and game.recovery_panel.route_outlook_label.text.contains("Signal Causeway") and game.recovery_panel.route_outlook_label.text.contains("Cinder Quarry"), "Morrowline recovery should carry the convoy stake into four distinct outbound road meanings")
	_expect_three_column_contract(game.recovery_panel, game.recovery_panel.value_labels["hull"], game.recovery_panel.recovery_canvas, game.recovery_panel.routes_button, "Morrowline recovery")
	await _capture("11_morrowline_recovery")
	if not game.recovery_panel.refuel_button.disabled:
		game.recovery_panel.refuel_button.pressed.emit()
		await _settle()
	game.recovery_panel.routes_button.pressed.emit()
	await _settle()
	if cinder_quarry_profile or mastery_profile:
		game.doctrine_option.select(2)
		game.doctrine_option.item_selected.emit(2)
		await _settle()
	var quarry_button := game.campaign_map.button_for("cinder_quarry") as Button
	_expect(quarry_button != null and not quarry_button.disabled and game.campaign_map.status_for("cinder_quarry") == "available", "Morrowline should expose Cinder Quarry as a fourth viable road")
	quarry_button.pressed.emit()
	await _settle()
	_expect(game.route_preview_label.text.contains("CINDER QUARRY") and game.route_preview_label.text.contains("2 fuel") and game.route_preview_label.text.contains("weakest damaged system") and game.campaign_map.detail_for("cinder_quarry").contains("weakest damaged system"), "the Cinder Quarry preview should visibly disclose its exact cost and guaranteed field-recovery consequence")
	await _capture("11b_cinder_quarry_route")

	if cinder_quarry_profile or mastery_profile:
		await _commit_route("cinder_quarry")
		await _enter_contact()
		await _capture("11c_cinder_quarry_contact")
		await _resolve_contact("map")
		_expect(game.journey_arrival.report_label.text.contains("Cinder Quarry recovery:"), "Cinder Quarry arrival should expose its guaranteed field-recovery consequence")
		await _capture("11d_cinder_quarry_recovery")
		await _acknowledge_arrival()
	else:
		await _commit_route("lower_ash_road")
		await _enter_contact()
		await _resolve_contact("map")
		await _acknowledge_arrival()
	_expect(game.state.campaign_encounters_completed == 4 and game.campaign_map.button_for("meridian_pass").visible, "the fourth road should expose the final commitment")

	await _commit_route("meridian_pass")
	await _enter_contact()
	await _resolve_contact("results")
	await _capture("12_final_arrival")
	await _acknowledge_arrival()
	_expect(game.state.run_complete and game.state.campaign_encounters_completed == 5, "the player-facing journey should complete all five encounters")
	_expect(game.debrief_panel.visible and game.debrief_panel.inspect_button.has_focus(), "the final arrival should hand focus to the terminal Debrief")
	if mastery_profile:
		_expect(game.state.mastery_experiment_details().get("status") == "PROVEN" and game.debrief_panel.commitments_label.text.contains("Quarry Adaptation · PROVEN") and game.debrief_panel.experiment_label.text.contains("PROVEN · QUARRY ADAPTATION"), "the Debrief should evaluate the selected field order without granting progression")
	_expect(game.get_global_rect().encloses(game.debrief_panel.inspect_button.get_global_rect()), "the first Debrief action should remain visible at 1600x900")
	_expect_three_column_contract(game.debrief_panel, game.debrief_panel.timeline_labels[0], game.debrief_panel.fortress_canvas, game.debrief_panel.inspect_button, "terminal Debrief")
	await _capture("13_debrief")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove_local_state()
	_configure_environment_profile()
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	cinder_quarry_profile = OS.get_environment("LONG_MARCH_CINDER_QUARRY_PROFILE") == "1"
	declined_convoy_profile = OS.get_environment("LONG_MARCH_DECLINED_CONVOY_PROFILE") == "1"
	mastery_profile = OS.get_environment("LONG_MARCH_MASTERY_PROFILE") == "1"
	var capture_filter_text := OS.get_environment("LONG_MARCH_CAPTURE_FILTER")
	if not capture_filter_text.is_empty():
		for capture_name in capture_filter_text.split(",", false):
			capture_filter.append(String(capture_name).strip_edges())
	root.size = viewport_size
	await _launch_app()
	_expect(app.tutorial_button.has_focus(), "a clean save should focus Learn to Command")
	if responsive_profile:
		_expect(app.text_scale_percent == 110 and app.high_contrast_enabled and app.reduced_motion and app.controller_layout_id == "east_confirm", "the compact journey should load the complete accessibility and alternate-controller profile")
		_expect(_rect_encloses(app.get_global_rect(), app.tutorial_button.get_global_rect()) and _rect_encloses(app.get_global_rect(), app.settings_button.get_global_rect()), "the compact large-text title should keep primary and utility actions visible")
	await _capture("00_title")
	await _complete_first_watch()
	await _run_ashgate_journey()
	app.queue_free()
	await _settle()
	_remove_local_state()
	if failures.is_empty():
		if cinder_quarry_profile:
			print("PASS: The Long March Cinder Quarry route profile")
		if declined_convoy_profile:
			print("PASS: The Long March declined convoy consequence profile")
		if mastery_profile:
			print("PASS: The Long March replayable mastery profile")
		if responsive_profile:
			print("PASS: The Long March responsive journey profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March complete journey handoff")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
