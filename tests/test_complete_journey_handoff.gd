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
const RenderCapture = preload("res://tests/support/rendered_frame_capture.gd")

var failures: Array[String] = []
var app: Control
var game: Control
var capture_dir := ""
var responsive_profile := false
var cinder_quarry_profile := false
var declined_convoy_profile := false
var mastery_profile := false
var iven_profile := false
var investment_profile := false
var gpt56_journey_profile := false
var pre_contact_resume_tested := false
var capture_filter: Array[String] = []
var viewport_size := Vector2i(1600, 900)
var capture_records: Array[Dictionary] = []
var resume_records: Array[Dictionary] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _expect_semantic_cue(cue_id: String, message: String) -> void:
	if app.interface_audio.volume_percent > 0:
		_expect(app.interface_audio.last_semantic_cue_kind == cue_id, message)


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
	var result: Dictionary = await RenderCapture.capture(self, capture_dir.path_join(name + ".png"), viewport_size)
	_expect(bool(result.get("ok", false)), "capture should contain a ready rendered frame for %s: %s" % [name, result.get("reason", "unknown error")])
	if bool(result.get("ok", false)):
		capture_records.append(result)


func _write_capture_manifest() -> void:
	if capture_dir.is_empty() or capture_records.is_empty():
		return
	var terminal_state := _evidence_state()
	var manifest := {
		"schema_version": 2,
		"game": "The Long March",
		"build": String(ProjectSettings.get_setting("application/config/version", "unknown")),
		"engine": Engine.get_version_info().get("string", "unknown"),
		"viewport": {"width": viewport_size.x, "height": viewport_size.y},
		"capture_method": "godot_viewport_after_rendered_frame_gate",
		"quality_result": "validated_rendered_frames",
		"journey_contract": {
			"profile_id": "LM-GPT56-1B" if gpt56_journey_profile else "complete_journey_handoff",
			"journey_id": "ashgate_lowlands_alpha",
			"fresh_save_started": true,
			"normal_player_actions": true,
			"captured_state_count": capture_records.size(),
			"terminal_complete": bool(terminal_state.get("run_complete", false)),
		},
		"resume_checkpoints": resume_records,
		"terminal_state": terminal_state,
		"states": capture_records,
	}
	var file := FileAccess.open(capture_dir.path_join("capture-manifest.json"), FileAccess.WRITE)
	_expect(file != null, "capture evidence manifest should be writable")
	if file != null:
		file.store_string(JSON.stringify(manifest, "  ") + "\n")
		file.close()


func _evidence_state() -> Dictionary:
	if game == null or game.state == null:
		return {}
	return {
		"phase": String(game.state.phase),
		"current_location": String(game.state.current_location),
		"target_node": String(game.state.campaign_target_node),
		"pending_event": String(game.state.campaign_event_pending),
		"encounter_step": int(game.state.encounter_step),
		"encounters_completed": int(game.state.campaign_encounters_completed),
		"specialist_id": String(game.state.specialist_id),
		"run_complete": bool(game.state.run_complete),
	}


func _record_resume_checkpoint(checkpoint_id: String) -> void:
	var record := _evidence_state()
	record["checkpoint_id"] = checkpoint_id
	resume_records.append(record)


func _expect_completion_evidence_contract() -> void:
	if not gpt56_journey_profile:
		return
	var resumed_ids: Array[String] = []
	for record in resume_records:
		resumed_ids.append(String(record.get("checkpoint_id", "")))
	for checkpoint_id in ["departure", "pre_contact_interruption", "arrival", "roadside_event"]:
		_expect(checkpoint_id in resumed_ids, "LM-GPT56-1B should preserve the save/resume checkpoint: " + checkpoint_id)
	var terminal_state := _evidence_state()
	_expect(bool(terminal_state.get("run_complete", false)), "LM-GPT56-1B evidence should end at a completed run")
	_expect(int(terminal_state.get("encounters_completed", 0)) == 5, "LM-GPT56-1B evidence should secure all five contacts")
	_expect(terminal_state.get("phase") == "results" and terminal_state.get("current_location") == "meridian_pass", "LM-GPT56-1B evidence should end at the Meridian Pass Debrief")


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
			_expect(String(game.journey_arrival.current_view.get("destination_id", "")) == "rill_crossing" and String(game.journey_arrival.arrival_canvas.arrival_visual_signature().get("motif", "")) == "crossing", "arrival resume should preserve the exact destination tableau")
		"roadside_event":
			_expect(game.roadside_event.visible and game.roadside_event.choice_buttons[0].has_focus(), "Continue should restore the unresolved authored decision and its first action")
		_:
			_expect(false, "unknown relaunch surface: " + expected_surface)
	_record_resume_checkpoint(expected_surface)


func _choose_event(choice_id: String) -> void:
	var button := game.roadside_event.button_for(choice_id) as Button
	_expect(button != null and button.visible and not button.disabled, "event choice should be available through the visible tableau: " + choice_id)
	if button != null and button.visible and not button.disabled:
		button.pressed.emit()
		await _settle()
		_expect_semantic_cue("event", "a resolved roadside choice should use the temporary event cue instead of a generic click")


func _choose_first_available_event() -> void:
	for button in game.roadside_event.choice_buttons:
		if button.visible and not button.disabled:
			var choice_id := String(button.get_meta("choice_id", ""))
			await _choose_event(choice_id)
			return
	_expect(false, "the visible roadside event should expose at least one legal response")


func _select_module(module_id: String) -> void:
	for index in range(game.module_option.item_count):
		if String(game.module_option.get_item_metadata(index)) == module_id:
			game.module_option.select(index)
			game.module_option.item_selected.emit(index)
			await _settle()
			return
	_expect(false, "stored or installed module should be selectable: " + module_id)


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
	_expect_semantic_cue("route_commit", "a successful route commitment should use its distinct temporary confirmation cue")


func _enter_contact() -> void:
	_expect(game.journey_transition.visible, "contact entry should begin at the travel handoff")
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	var interruption_seen := false
	if game.roadside_event.visible:
		interruption_seen = true
		_expect(game.state.pre_contact_occurrence_active() and not game.road_contact.visible and game.state.current_location == "ashgate_depot" and game.state.encounter_step == 0, "the authored road interruption should hold the fortress at its origin before exposing contact")
		_expect(game.roadside_event.context_label.text == "ROAD INTERRUPTION · CONTACT WAITING" and game.roadside_event.location_label.text.contains("ASHGATE DEPOT → RILL CROSSING"), "the interruption tableau should name both ends of the road and the waiting contact")
		_expect(game.roadside_event.guidance_label.text.contains("cannot be bypassed"), "the interruption should explain that its committed contact remains mandatory")
		await _capture("07d_pre_contact_interruption")
		if not pre_contact_resume_tested:
			pre_contact_resume_tested = true
			_expect(game.save_run(true), "the visible pre-contact interruption should save successfully")
			_expect(game.load_saved_run(), "the pre-contact interruption checkpoint should load successfully")
			await _settle()
			_expect(game.journey_transition.visible and game.state.pre_contact_occurrence_active(), "loading an unresolved interruption should restore the road handoff before the decision")
			game.journey_transition.continue_button.pressed.emit()
			await _settle()
			_expect(game.roadside_event.visible and game.roadside_event.choice_buttons[0].has_focus(), "continuing a restored road should return to the unresolved interruption without entering contact")
			_record_resume_checkpoint("pre_contact_interruption")
		await _choose_event("brace_lift_chain")
	_expect(game.road_contact.visible and game.road_contact.advance_button.has_focus(), "travel should hand focus to the visible road contact")
	_expect_semantic_cue("event" if interruption_seen else "contact_entry", "the road handoff should use the semantic cue for the surface it actually enters")


func _resolve_contact(expected_phase: String) -> void:
	if game.state.encounter_active:
		var first_step_cue: String = game.contact_audio_cue_for_step(game.state.encounter_step + 1, game.state.encounter_enemies)
		game.road_contact.advance_button.pressed.emit()
		await _settle()
		if not first_step_cue.is_empty() and game.state.encounter_active:
			_expect_semantic_cue(first_step_cue, "the first readable contact step should announce the approaching threat family")
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
	_expect(not game.state.encounter_active and game.state.phase == expected_phase, "visible contact steps should resolve into %s, got %s at %s with %s pending" % [expected_phase, game.state.phase, game.state.current_location, game.state.campaign_event_pending])
	_expect(game.journey_arrival.visible and game.journey_arrival.continue_button.has_focus(), "a resolved contact should stop at a focused arrival receipt")
	_expect(not String(game.journey_arrival.current_view.get("destination_id", "")).is_empty() and not String(game.journey_arrival.arrival_canvas.arrival_visual_signature().get("marker", "")).is_empty(), "arrival should preserve a stable destination identity for the center-stage tableau")
	_expect_semantic_cue("debrief" if expected_phase == "results" else "arrival", "the resolved road should announce arrival or Debrief with its semantic cue")


func _acknowledge_arrival() -> void:
	game.journey_arrival.continue_button.pressed.emit()
	await _settle()
	_expect(not game.journey_arrival.visible, "acknowledging arrival should expose the next player-facing order")
	_expect_semantic_cue("arrival_handoff", "acknowledging arrival should use the distinct location-handoff cue")


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
	_expect(game.journey_arrival.recovery_priority_label.text.contains("REPAIR PRIORITY") and game.journey_arrival.recovery_priority_label.text.contains("WHY IT MATTERS"), "First Watch arrival should carry the exact damage consequence into the recovery handoff")
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
	var uses_iven := iven_profile or investment_profile
	_expect(game.settlement_hub.visible and game.settlement_hub.station_buttons["assignment_board"].has_focus(), "Ashgate handoff should begin at the required assignment")
	_expect(game.get_global_rect().encloses(game.settlement_hub.primary_action_button.get_global_rect()), "the first Ashgate action should be visible at 1600x900")
	_expect(not app.checkpoint_toast.get_global_rect().intersects(game.settlement_hub.location_label.get_global_rect()), "the compact save notice should not obscure the current location heading")
	_expect_three_column_contract(game.settlement_hub, game.settlement_hub.value_labels["hull"], game.settlement_hub.bazaar_canvas, game.settlement_hub.primary_action_button, "Ashgate bazaar")
	await _capture("05_ashgate_handoff")
	if investment_profile:
		game.settlement_hub.station_buttons["workshop"].pressed.emit()
		await _settle()
		game.settlement_hub.primary_action_button.pressed.emit()
		await _settle()
		_expect(game.main_columns.visible and game.state.can_refit(), "the investment profile should enter Ashgate's workshop before departure")
		if responsive_profile:
			_expect(not game.journey_banner.visible and not game.run_flow_tracker.visible and game.left_scroll.get_global_rect().encloses(game.fortress_panel.get_global_rect()), "the compact investment workshop should make the complete chassis the dominant above-fold decision")
			_expect(game.right_scroll.get_global_rect().encloses(game.settlement_hub_return_button.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.focus_chassis_button.get_global_rect()), "the compact investment workshop should keep its exit and primary refit action visible together")
		game._on_grid_cell_pressed(Vector2i(0, 0))
		await _settle()
		game.remove_button.pressed.emit()
		await _settle()
		game._on_grid_cell_pressed(Vector2i(0, 1))
		await _settle()
		game.remove_button.pressed.emit()
		await _settle()
		await _select_module("ash_runner_engine")
		game._on_grid_cell_pressed(Vector2i(0, 0))
		await _settle()
		await _select_module("coal_cell")
		game._on_grid_cell_pressed(Vector2i(1, 1))
		await _settle()
		await _select_module("wall_lamp")
		game._on_grid_cell_pressed(Vector2i(5, 2))
		await _settle()
		_expect(game.state.operational("ash_runner_engine") and game.state.operational("field_workshop") and game.state.operational("wall_lamp") and game.state.total_mass() <= game.state.BASE_MASS_LIMIT, "the investment refit should preserve movement and repair while adding signal capacity within the chassis limit")
		await _capture("05a_live_refit")
		game.settlement_hub_return_button.pressed.emit()
		await _settle()
		_expect(game.settlement_hub.visible and game.settlement_hub.station_buttons["assignment_board"].has_focus(), "returning from the investment refit should restore the required Ashgate assignment")
	elif iven_profile:
		game.settlement_hub.station_buttons["workshop"].pressed.emit()
		await _settle()
		game.settlement_hub.primary_action_button.pressed.emit()
		await _settle()
		_expect(game.main_columns.visible and game.state.can_refit(), "the Iven profile should enter Ashgate's workshop before departure")
		game._on_grid_cell_pressed(Vector2i(3, 1))
		await _settle()
		_expect(game.selected_module_id == "field_workshop" and not game.remove_button.disabled, "the Iven profile should select the installed workshop it will trade for signal capacity")
		game.remove_button.pressed.emit()
		await _settle()
		await _select_module("wall_lamp")
		game._on_grid_cell_pressed(Vector2i(5, 2))
		await _settle()
		_expect(game.state.operational("wall_lamp") and game.state.total_mass() <= game.state.BASE_MASS_LIMIT, "the Iven profile should install an operational Wall Lamp within the normal mass and exterior-mount limits")
		game.settlement_hub_return_button.pressed.emit()
		await _settle()
		_expect(game.settlement_hub.visible and game.settlement_hub.station_buttons["assignment_board"].has_focus(), "returning from the signal refit should restore the required Ashgate assignment")
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
	if mastery_profile:
		game.settlement_hub.station_buttons["assignment_board"].pressed.emit()
		await _settle()
		_expect(game.settlement_hub.detail_title.text == "MARCHMASTER'S ORDERS" and game.settlement_hub.primary_action_button.text.contains("QUARRY") and game.settlement_hub.secondary_action_button.text.contains("SIGNAL"), "the resolved Marchmaster's Orders desk should offer two bounded field experiments")
		await _capture("05c_mastery_orders")
		game.settlement_hub.primary_action_button.pressed.emit()
		await _settle()
		_expect(game.state.mastery_experiment_id == "ashgate_quarry_adaptation" and game.settlement_hub.context_label.text.contains("FIELD ORDER: QUARRY ADAPTATION"), "selecting Quarry Adaptation should retain its field order before departure")
		await _capture("05d_quarry_order_selected")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await _settle()
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible and game.campaign_map.button_for("rill_crossing").has_focus(), "departure should open route planning at the first available road")
	var assignment_marker: Label = game.campaign_map.marker_labels.get("morrowline_camp") as Label
	var assignment_destination: Button = game.campaign_map.button_for("morrowline_camp") as Button
	if declined_convoy_profile:
		_expect(assignment_marker != null and not assignment_marker.visible, "declining the convoy assignment should leave no accepted marker on Morrowline")
	else:
		_expect(assignment_marker != null and assignment_marker.visible and assignment_destination != null and not assignment_marker.get_global_rect().intersects(assignment_destination.get_global_rect()) and game.campaign_map.get_global_rect().encloses(assignment_marker.get_global_rect()), "the accepted assignment badge should remain beside its destination without covering the node label or leaving the route chart")
	_expect(game.journey_planner.detail_heading.text == "ROAD DOSSIER" and game.journey_planner.route_stage_label.text.contains("NO COST"), "opening the route map should frame focus as reversible browsing rather than a selected commitment")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await _settle()
	_expect(game.journey_planner.detail_heading.text == "SELECTED ROAD", "selecting a node should promote the dossier to an explicit selected-road state")
	_expect_three_column_contract(game.journey_planner, game.journey_planner.value_labels["day"], game.journey_planner.map_host, game.campaign_commit_button, "route commitment")
	await _capture("06_route_commitment")
	game.campaign_commit_button.pressed.emit()
	await _settle()
	_expect_three_column_contract(game.journey_transition, game.journey_transition.day_label, game.journey_transition.march_canvas, game.journey_transition.continue_button, "Ashgate departure")
	if responsive_profile:
		_expect(game.journey_transition.high_contrast_enabled and game.journey_transition.reduced_motion and game.journey_transition.presentation_beat() == "contact_ahead" and game.journey_transition.continue_button.text == "REVIEW INTERRUPTION" and game.journey_transition.pause_button.text.contains("A"), "the live departure should preserve contrast, skip motion, expose the mandatory interruption, and retain alternate controller guidance")
		_expect(not game.journey_transition.march_canvas.temporary_travel_vfx_active() and float(game.journey_transition.march_canvas.motion_signature().get("speed_scale", 1.0)) == 0.0, "reduced motion should land on the static contact brace without temporary march effects")
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
	if responsive_profile and app.checkpoint_toast.visible:
		var contact_toast_rect: Rect2 = app.checkpoint_toast.get_global_rect()
		var phase_badge_rect: Rect2 = game.road_contact.battle_phase_label.get_global_rect()
		var phase_text_end: float = game.road_contact.phase_label.get_global_rect().position.x + game.road_contact.phase_label.get_minimum_size().x
		_expect(contact_toast_rect.end.x <= phase_badge_rect.position.x - app.CHECKPOINT_TOAST_GAP, "the compact save notice should stay left of the contact phase badge")
		_expect(contact_toast_rect.position.x >= phase_text_end + app.CHECKPOINT_TOAST_GAP, "the compact save notice should not cover the contact breadcrumb · toast %.1f · text end %.1f" % [contact_toast_rect.position.x, phase_text_end])
	if responsive_profile:
		for intervention_button in game.road_contact.intervention_buttons:
			_expect(game.road_contact.get_global_rect().encloses(intervention_button.get_global_rect()), "the compact contact dock should keep every emergency order visible without scrolling")
	await _capture("08_road_contact")
	await _resolve_contact("map")
	if responsive_profile and app.checkpoint_toast.visible:
		var arrival_toast_rect: Rect2 = app.checkpoint_toast.get_global_rect()
		var arrival_text_end: float = game.journey_arrival.route_label.get_global_rect().position.x + game.journey_arrival.route_label.get_minimum_size().x
		_expect(arrival_toast_rect.position.x >= arrival_text_end + app.CHECKPOINT_TOAST_GAP, "the compact save notice should not cover the arrival breadcrumb · toast %.1f · text end %.1f" % [arrival_toast_rect.position.x, arrival_text_end])
	await _capture("09_arrival_receipt")
	await _relaunch_and_continue("arrival")
	_expect(game.state.current_location == "rill_crossing" and not game.state.pre_contact_occurrence_active(), "arrival resume should preserve the secured road after its pre-contact interruption was resolved")
	await _acknowledge_arrival()
	if game.roadside_event.visible:
		_expect_three_column_contract(game.roadside_event, game.roadside_event.value_labels["day"], game.roadside_event.tableau, game.roadside_event.choice_buttons[0], "roadside event")
		await _capture("10_roadside_event")
		await _choose_first_available_event()
		_expect(game.journey_planner.visible and game.journey_planner.receipt_label.text.contains("LAST RECEIPT"), "a resolved roadside event should leave its consequence receipt on the reopened route table")
		await _capture("10b_consequence_receipt")
	else:
		_expect(game.journey_planner.visible, "a secured Rill road may proceed directly when no post-arrival occurrence is eligible")

	await _commit_route("broken_relay")
	await _enter_contact()
	await _resolve_contact("map")
	await _acknowledge_arrival()
	await _choose_event("restore_relay" if uses_iven else "move_silent")
	if uses_iven:
		_expect(game.journey_planner.visible and game.recruit_iven_button.is_visible_in_tree() and not game.recruit_iven_button.disabled, "restoring the relay should expose Iven's legal recruitment action inside the active planner")
		game.recruit_iven_button.pressed.emit()
		await _settle()
		_expect(game.state.specialist_id == "iven_pell" and game.journey_planner.specialist_portrait.presentation_signature() == "IVEN_PELL · SIGNAL OFFICER · ASSIGNED", "recruiting Iven should persist the assigned signal officer in route planning")
		_expect(game.journey_planner.receipt_label.text.contains("12 Ashmarks spent") and game.journey_planner.specialist_effect_label.text.contains("EXACT IMMEDIATE CONTACTS"), "the recruited-Iven planner should retain his cost and active forecasting effect")

	await _commit_route("morrowline_camp")
	await _enter_contact()
	await _resolve_contact("settlement")
	await _acknowledge_arrival()
	if uses_iven:
		_expect(game.state.campaign_event_pending == "mara_berth_choice" and game.roadside_event.visible, "an occupied specialist berth should surface the Iven-versus-Mara crossroads")
		await _capture("11_specialist_crossroads")
		if investment_profile:
			_expect(game.save_run(true), "the unresolved specialist crossroads should save successfully")
			await _relaunch_and_continue("roadside_event")
			_expect(game.state.campaign_event_pending == "mara_berth_choice" and game.state.specialist_id == "iven_pell", "the restored crossroads should preserve Iven and the unresolved berth")
			await _choose_event("replace_iven_with_mara")
			_expect(game.state.specialist_id == "mara_flint" and game.state.campaign_event_pending == "mara_workbench_choice", "the investment vertical should visibly trade Iven's forecast for Mara's recovery chain")
			await _capture("11b_forge_core_dilemma")
			await _choose_first_available_event()
			_expect(game.recovery_panel.visible and game.state.specialist_id == "mara_flint" and game.state.campaign_decisions.has("mara_workbench_choice"), "the forge-core decision should persist into Morrowline recovery")
		else:
			await _choose_event("keep_iven")
			_expect(game.recovery_panel.visible and game.state.specialist_id == "iven_pell", "keeping Iven should continue into recovery with signal certainty assigned")
	else:
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
	var recovery_actions_before: int = int(game.state.settlement_actions_remaining)
	var recovery_sacrifice_made := false
	for recovery_button in [game.recovery_panel.repair_button, game.recovery_panel.refuel_button, game.recovery_panel.hull_button]:
		if recovery_button.visible and not recovery_button.disabled:
			recovery_button.pressed.emit()
			await _settle()
			recovery_sacrifice_made = true
			break
	_expect(recovery_sacrifice_made and game.state.settlement_actions_remaining == recovery_actions_before - 1, "the complete journey should spend exactly one finite Morrowline service opportunity before choosing the next road")
	if recovery_sacrifice_made:
		_expect(not game.last_recovery_receipt.is_empty() and game.recovery_panel.receipt_label.text.contains("LAST RECEIPT"), "the recovery sacrifice should leave a visible material receipt")
		_expect_semantic_cue("service", "a completed recovery action should use the distinct material service cue")
	game.recovery_panel.routes_button.pressed.emit()
	await _settle()
	if iven_profile:
		_expect(game.journey_planner.specialist_name_label.text == "IVEN PELL" and game.journey_planner.specialist_effect_label.text.begins_with("ACTIVE"), "Iven should remain visibly assigned after Morrowline recovery")
	if investment_profile:
		_expect(game.journey_planner.specialist_name_label.text == "MARA FLINT" and game.journey_planner.specialist_effect_label.text.begins_with("ACTIVE"), "Mara should remain visibly assigned after the berth exchange and recovery dilemma")
	if cinder_quarry_profile or mastery_profile or investment_profile:
		game.doctrine_option.select(2)
		game.doctrine_option.item_selected.emit(2)
		await _settle()
	var quarry_button := game.campaign_map.button_for("cinder_quarry") as Button
	_expect(quarry_button != null and not quarry_button.disabled and game.campaign_map.status_for("cinder_quarry") == "available", "Morrowline should expose Cinder Quarry as a fourth viable road")
	quarry_button.pressed.emit()
	await _settle()
	_expect(game.route_preview_label.text.contains("CINDER QUARRY") and game.route_preview_label.text.contains("2 fuel") and game.route_preview_label.text.contains("weakest damaged system") and game.campaign_map.detail_for("cinder_quarry").contains("weakest damaged system"), "the Cinder Quarry preview should visibly disclose its exact cost and guaranteed field-recovery consequence")
	await _capture("11b_cinder_quarry_route")

	if cinder_quarry_profile or mastery_profile or investment_profile:
		await _commit_route("cinder_quarry")
		await _enter_contact()
		await _capture("11c_cinder_quarry_contact")
		await _resolve_contact("map")
		_expect(game.journey_arrival.report_label.text.contains("Cinder Quarry recovery:"), "Cinder Quarry arrival should expose its guaranteed field-recovery consequence")
		await _capture("11d_cinder_quarry_recovery")
		await _acknowledge_arrival()
	elif iven_profile:
		await _commit_route("signal_causeway")
		await _enter_contact()
		await _resolve_contact("map")
		await _acknowledge_arrival()
	else:
		await _commit_route("lower_ash_road")
		await _enter_contact()
		await _resolve_contact("map")
		await _acknowledge_arrival()
	if investment_profile:
		_expect(game.roadside_event.visible and game.state.campaign_event_pending == "mara_followup", "the fourth road should call back the forge-core commitment")
		await _capture("11e_forge_core_callback")
		await _choose_first_available_event()
	_expect(game.state.campaign_encounters_completed == 4 and game.campaign_map.button_for("meridian_pass").visible, "the fourth road should expose the final commitment")

	await _commit_route("meridian_pass")
	await _enter_contact()
	await _resolve_contact("results")
	_expect(String(game.journey_arrival.arrival_canvas.arrival_visual_signature().get("motif", "")) == "finale" and String(game.journey_arrival.current_view.get("destination_id", "")) == "meridian_pass", "the final Ashgate arrival should use the Meridian Pass threshold composition")
	await _capture("12_final_arrival")
	await _acknowledge_arrival()
	_expect(game.state.run_complete and game.state.campaign_encounters_completed == 5, "the player-facing journey should complete all five encounters")
	_expect(game.debrief_panel.visible and game.debrief_panel.inspect_button.has_focus(), "the final arrival should hand focus to the terminal Debrief")
	if iven_profile:
		_expect(game.debrief_panel.commitments_label.text.contains("Carried · Iven Pell") and game.debrief_panel.commitments_label.text.contains("Specialist crossroads") and game.debrief_panel.commitments_label.text.contains("exact forecasts retained"), "the terminal Debrief should retain Iven and explain the specialist tradeoff that carried him forward")
	if investment_profile:
		_expect(game.debrief_panel.commitments_label.text.contains("Carried · Mara Flint") and game.debrief_panel.commitments_label.text.contains("Iven → Mara") and game.debrief_panel.commitments_label.text.contains("forecast traded for repair") and game.debrief_panel.commitments_label.text.contains("Forge-core promise") and game.debrief_panel.commitments_label.text.contains("fourth road"), "the investment Debrief should connect the Iven-Mara exchange to the forge-core consequence")
	if mastery_profile:
		_expect(game.state.mastery_experiment_details().get("status") == "PROVEN" and game.debrief_panel.commitments_label.text.contains("Quarry Adaptation · PROVEN") and game.debrief_panel.experiment_label.text.contains("PROVEN · QUARRY ADAPTATION"), "the Debrief should evaluate the selected field order without granting progression")
	_expect(game.get_global_rect().encloses(game.debrief_panel.inspect_button.get_global_rect()), "the first Debrief action should remain visible at 1600x900")
	_expect_three_column_contract(game.debrief_panel, game.debrief_panel.timeline_labels[0], game.debrief_panel.fortress_canvas, game.debrief_panel.inspect_button, "terminal Debrief")
	await _capture("13_debrief")
	game.debrief_panel.notes_button.pressed.emit()
	await _settle()
	var feedback_panel := game.feedback_overlay.find_child("FeedbackPanel", true, false) as PanelContainer
	_expect(game.feedback_overlay.visible and feedback_panel != null and _rect_encloses(game.feedback_overlay.get_global_rect(), feedback_panel.get_global_rect()), "the playtest notes modal should remain inside the viewport after adding the causal replay prompt")
	_expect(game.feedback_causal_text != null and game.feedback_causal_text.visible and game.feedback_causal_label.text.contains("what would you change next run"), "the terminal feedback form should ask for the perceived cause and one concrete replay change")
	game.feedback_causal_text.grab_focus()
	await _settle()
	_expect(game.feedback_questions_scroll.get_global_rect().encloses(game.feedback_causal_text.get_global_rect()), "the causal replay field should scroll fully into view for keyboard and controller users")
	await _capture("14_playtest_notes")
	game._hide_feedback()


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove_local_state()
	_configure_environment_profile()
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	cinder_quarry_profile = OS.get_environment("LONG_MARCH_CINDER_QUARRY_PROFILE") == "1"
	declined_convoy_profile = OS.get_environment("LONG_MARCH_DECLINED_CONVOY_PROFILE") == "1"
	mastery_profile = OS.get_environment("LONG_MARCH_MASTERY_PROFILE") == "1"
	iven_profile = OS.get_environment("LONG_MARCH_IVEN_PROFILE") == "1"
	gpt56_journey_profile = OS.get_environment("LONG_MARCH_GPT56_1_PROFILE") == "1"
	investment_profile = OS.get_environment("LONG_MARCH_INVESTMENT_PROFILE") == "1" or gpt56_journey_profile
	var capture_filter_text := OS.get_environment("LONG_MARCH_CAPTURE_FILTER")
	if not capture_filter_text.is_empty():
		for capture_name in capture_filter_text.split(",", false):
			capture_filter.append(String(capture_name).strip_edges())
	root.size = viewport_size
	await _launch_app()
	_expect(app.tutorial_button.has_focus(), "a clean save should focus Learn to Command")
	if gpt56_journey_profile:
		_expect(app.title_preview_eyebrow_label.text.contains("20–30 MINUTES"), "the clean First Watch entry should disclose its expected tutorial duration")
		app.start_button.mouse_entered.emit()
		_expect(app.title_preview_eyebrow_label.text.contains("15–25 MINUTES"), "the Ashgate journey should disclose a duration that composes with First Watch into a 35–55 minute creative run")
		app.start_button.mouse_exited.emit()
	if responsive_profile:
		_expect(app.text_scale_percent == 110 and app.high_contrast_enabled and app.reduced_motion and app.controller_layout_id == "east_confirm", "the compact journey should load the complete accessibility and alternate-controller profile")
		_expect(_rect_encloses(app.get_global_rect(), app.tutorial_button.get_global_rect()) and _rect_encloses(app.get_global_rect(), app.settings_button.get_global_rect()), "the compact large-text title should keep primary and utility actions visible")
	await _capture("00_title")
	await _complete_first_watch()
	await _run_ashgate_journey()
	_expect_completion_evidence_contract()
	_write_capture_manifest()
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
		if iven_profile:
			print("PASS: The Long March Iven specialist profile")
		if investment_profile:
			print("PASS: The Long March investment evaluation vertical")
		if gpt56_journey_profile:
			print("PASS: The Long March LM-GPT56-1 full creative journey")
			print("PASS: The Long March LM-GPT56-1B completion evidence contract")
		if responsive_profile:
			print("PASS: The Long March responsive journey profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March complete journey handoff")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
