extends SceneTree

var game: Control
var failures: Array[String] = []
var return_to_title_requested: bool = false

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _mark_return_to_title_requested() -> void:
	return_to_title_requested = true

func _module_picker_index(module_id: String) -> int:
	for index in range(game.module_option.item_count):
		if String(game.module_option.get_item_metadata(index)) == module_id:
			return index
	return -1

func _init() -> void:
	call_deferred("_run")

func _press_campaign_node(node_id: String) -> void:
	for button in game.campaign_node_buttons:
		if button.visible and String(button.get_meta("node_id", "")) == node_id:
			_expect(not button.disabled, "campaign node button should be enabled: " + node_id)
			if button.disabled:
				return
			button.pressed.emit()
			await process_frame
			_expect(game.selected_campaign_node_id == node_id and game.state.phase in ["refit", "map", "settlement"], "selecting a map node should wait for explicit route confirmation: " + node_id)
			_expect(game.guidance_label.text.begins_with("ROUTE READY"), "selecting a route should update the current objective before commitment")
			_expect(not game.campaign_map.commit_button.disabled, "selected route should enable the commit control: " + node_id)
			_expect(game.campaign_map.commit_button.has_focus(), "route selection should move keyboard or controller focus to confirmation")
			_expect(game.right_scroll.get_global_rect().encloses(game.guidance_label.get_global_rect()), "route confirmation should keep its current objective visible when both fit")
			game.campaign_map.commit_button.pressed.emit()
			await process_frame
			return
	_expect(false, "campaign node button should be available: " + node_id)

func _press_campaign_event(choice_id: String) -> void:
	for button in game.campaign_event_buttons:
		if button.visible and String(button.get_meta("choice_id", "")) == choice_id:
			button.pressed.emit()
			await process_frame
			return
	_expect(false, "campaign event choice should be available: " + choice_id)

func _advance_until_phase(expected_phase: String) -> void:
	if game.state.encounter_active:
		game.advance_encounter_button.pressed.emit()
		await process_frame
		if game.state.encounter_active and not game.state.encounter_intervention_used:
			game.intervention_buttons[0].pressed.emit()
			await process_frame
	for _step in range(8):
		if game.state.phase == expected_phase:
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame

func _run() -> void:
	var save_path := ProjectSettings.globalize_path("user://the_long_march_prototype.save")
	var onboarding_path := ProjectSettings.globalize_path("user://the_long_march_onboarding_v1.complete")
	var journal_path := ProjectSettings.globalize_path("user://the_long_march_playtest_journal.json")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	game.return_to_title_requested.connect(_mark_return_to_title_requested)
	root.add_child(game)
	await process_frame
	await process_frame
	_expect(game.onboarding_overlay.visible, "a first run should open the Marchmaster briefing")
	_expect(game.ONBOARDING_STEPS.size() == 4 and game.onboarding_step_panels.size() == 4, "the guided briefing should use four concise, visible stages")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_skip_button, "the first briefing step should route left around its disabled Previous action")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_next) == game.onboarding_skip_button and game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_top) == game.onboarding_next_button, "the briefing should trap Tab and vertical focus inside its actions")
	_expect(game.onboarding_progress_label.text.contains("D-pad") and game.onboarding_progress_label.text.contains("A / Enter"), "the briefing should name controller and keyboard navigation together")
	_expect(game.onboarding_action_label.text.begins_with("FIRST ACTION"), "each briefing page should name a concrete player action")
	_expect(game.guidance_label.text.begins_with("CURRENT ORDER") and game.guidance_label.text.contains("convoy"), "the opening objective should identify the contract decision")
	_expect(game.how_to_play_button.text == "OPEN FIELD BRIEFING", "the live-stage help action should use the same player-facing name as the pause menu")
	for _step in range(game.ONBOARDING_STEPS.size()):
		if _step == 1:
			_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_back_button, "later briefing steps should restore Previous to controller navigation")
			_expect(game.onboarding_skip_button.get_node_or_null(game.onboarding_skip_button.focus_next) == game.onboarding_back_button, "later briefing steps should restore Previous to the modal Tab cycle")
		if _step == game.ONBOARDING_STEPS.size() - 1:
			_expect(game.onboarding_next_button.text == "ENTER ASHGATE", "the final briefing action should clearly enter the playable stage")
		game.onboarding_next_button.pressed.emit()
		await process_frame
	_expect(not game.onboarding_overlay.visible and FileAccess.file_exists(onboarding_path), "completing onboarding should dismiss it and persist the choice")
	_expect(game.state.phase == "refit", "prototype should begin in Ashgate refit")
	_expect(game.current_run_flow_step == 0 and game.run_flow_labels[0].text.contains("PREP"), "the stage tracker should begin at fortress preparation")
	_expect(game.metric_labels.size() == 7 and game.metric_labels["fuel"].text == "6", "the HUD should expose the seven core operating resources")
	_expect(game.doctrine_detail_label.text.contains("Raiders") and game.doctrine_detail_label.text.contains("−1 damage"), "the default doctrine should explain its real targeting and mitigation effects")
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	await process_frame
	_expect(game.doctrine_detail_label.text.contains("+2 heat") and game.doctrine_detail_label.text.contains("incoming damage"), "Run Hot should disclose both its offensive benefit and thermal risk")
	game.doctrine_option.select(0)
	game.doctrine_option.item_selected.emit(0)
	await process_frame
	var generator_index := _module_picker_index("generator_core")
	game.module_option.select(generator_index)
	game.module_option.item_selected.emit(generator_index)
	await process_frame
	_expect(game.selected_module_cell == Vector2i(2, 0) and game.module_option.get_item_text(generator_index).contains("ON CHASSIS"), "the module picker should navigate directly to installed systems")
	var cannon_index := _module_picker_index("shell_cannon")
	game.module_option.select(cannon_index)
	game.module_option.item_selected.emit(cannon_index)
	await process_frame
	_expect(game.selected_module_cell.x < 0 and game.module_option.get_item_text(cannon_index).contains("STORED"), "the module picker should distinguish stored modules ready for placement")
	var stored_cannon: Dictionary = {}
	for index in range(game.state.stored_modules.size()):
		if String(game.state.stored_modules[index].get("id", "")) == "shell_cannon":
			stored_cannon = game.state.stored_modules[index]
			game.state.stored_modules.remove_at(index)
			break
	game._refresh_ui()
	_expect(game.module_option.is_item_disabled(cannon_index) and game.module_option.get_item_text(cannon_index).contains("LOST"), "a permanently unavailable module should be disabled and marked lost")
	game.state.stored_modules.append(stored_cannon)
	var engine_index := _module_picker_index("steam_lance_engine")
	game.module_option.select(engine_index)
	game.module_option.item_selected.emit(engine_index)
	await process_frame
	_expect(game.campaign_map.visible and game.campaign_node_buttons.size() == 9, "the campaign should render the full authored node graph")
	_expect(game.campaign_map.status_for("ashgate_depot") == "current", "the map should mark Ashgate as the current node")
	_expect(game.campaign_map.status_for("rill_crossing") == "blocked" and game.campaign_map.status_for("soot_orchard") == "blocked", "the opening roads should visibly wait for the contract decision")
	game.contract_accept_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(game.state.guard_contract_status == "accepted", "the guard contract should be selectable through the UI")
	_expect(game.guidance_label.text.contains("Select one cyan route"), "the objective should advance immediately after the contract is answered")
	_expect(game.current_run_flow_step == 1 and game.run_flow_labels[0].text.begins_with("✓"), "answering the contract should advance the tracker to the Lowlands roads")
	_expect(game.campaign_map.status_for("rill_crossing") == "available" and not game.campaign_map.button_for("rill_crossing").disabled, "answering the contract should activate the opening map nodes")
	_expect(game.campaign_map.button_for("rill_crossing").has_focus(), "resolving the contract should hand controller focus to the first route")
	_expect(game.right_scroll.get_global_rect().encloses(game.campaign_map.button_for("rill_crossing").get_global_rect()), "route focus should scroll the selected action fully into view")
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	_expect(game.doctrine_detail_label.text.begins_with("OVERHEAT WARNING") and game.campaign_map.commit_button.text.contains("HEAT 7/6"), "an overheating doctrine should expose predicted heat in the route commitment")
	game.doctrine_option.select(0)
	game.doctrine_option.item_selected.emit(0)
	game.selected_campaign_node_id = ""
	game._refresh_ui()
	var available_fuel: int = game.state.fuel
	game.state.fuel = 0
	game._refresh_ui()
	_expect(not game.campaign_map.button_for("rill_crossing").disabled, "a blocked fortress should still be able to inspect an available route")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	_expect(game.campaign_map.commit_button.disabled and game.campaign_map.commit_button.text.contains("NEED 1 FUEL"), "route commitment should explain an exact fuel shortfall")
	_expect(game.guidance_label.text.begins_with("DEPARTURE BLOCKED"), "the current order should explain why the selected route cannot begin")
	game.state.fuel = available_fuel
	game.selected_campaign_node_id = ""
	game._refresh_ui()
	game.campaign_map.button_for("rill_crossing").grab_focus()
	await process_frame
	_expect(game.campaign_map.detail_label.text.contains("Known route"), "keyboard or controller focus should expose the same route detail as mouse hover")
	await _press_campaign_node("rill_crossing")
	await process_frame
	_expect(game.state.phase == "battle", "the first map choice should begin a road encounter")
	_expect(game.advance_encounter_button.has_focus(), "committing a route should hand controller focus to the encounter timeline")
	_expect(game.right_scroll.get_global_rect().encloses(game.advance_encounter_button.get_global_rect()), "battle focus should scroll encounter advancement into view")
	_expect(game.combat_panel.visible and game.combat_panel.step_panels.size() == 6, "battle state should expose the six-step encounter timeline")
	_expect(game.combat_panel.enemy_panels[0].visible and game.combat_panel.enemy_names[0].text == "ROAD RAIDER", "battle state should expose a readable enemy card")
	_expect(game.combat_panel.step_labels[0].text == "NEXT · 1" and game.advance_encounter_button.text.contains("STEP 1 OF 6"), "combat controls should identify the exact next timeline step")
	_expect(game.combat_panel.enemy_states[0].text.contains("2 STEPS OUT") and game.guidance_label.text.contains("2 steps out"), "approaching enemies should use a live countdown before contact")
	game.advance_encounter_button.pressed.emit()
	await process_frame
	_expect(game.combat_panel.enemy_states[0].text.contains("1 STEP OUT") and game.advance_encounter_button.text.contains("STEP 2 OF 6"), "the arrival countdown and advance action should update after each step")
	await _advance_until_phase("map")
	_expect(int(game.campaign_progress_bar.value) == 1, "the region progress bar should advance after a secured encounter")
	_expect(game.campaign_map.status_for("rill_crossing") == "current" and game.campaign_map.status_for("ashgate_depot") == "secured", "the map should retain the secured route and move the current marker")
	await _press_campaign_node("broken_relay")
	await _advance_until_phase("map")
	_expect(game.state.campaign_event_pending == "lost_signal", "the Broken Relay should surface its authored decision")
	_expect(game.campaign_map.status_for("morrowline_camp") == "blocked", "the map should show that a local decision blocks the next road")
	_expect(game.campaign_event_buttons[0].disabled and game.campaign_event_buttons[0].text.contains("REQUIRES AN OPERATIONAL SIGNAL SYSTEM"), "locked event choices should state their missing capability without requiring hover")
	await _press_campaign_event("move_silent")
	_expect(game.event_label.text.contains("pressure falls by 1") and game.event_label.text.contains("risk falls by 3%"), "event resolution should immediately explain its mechanical consequences")
	_expect(game.encounter_label.text.begins_with("DECISION CONSEQUENCE") and game.encounter_label.text.contains("risk falls by 3%"), "the event consequence should appear above the fold immediately after selection")
	_expect(game.recruit_iven_button.visible and game.recruit_iven_button.disabled and game.recruit_iven_button.text.contains("RELAY IS RESTORED"), "unavailable specialist recruitment should state its unmet requirement without hover")
	_expect(game.campaign_map.status_for("morrowline_camp") == "available", "resolving the relay decision should activate Morrowline")
	await _press_campaign_node("morrowline_camp")
	await _advance_until_phase("settlement")
	await process_frame
	_expect(game.state.phase == "settlement" and game.state.campaign_encounters_completed == 3, "the third encounter should open Morrowline services")
	_expect(game.current_run_flow_step == 2 and game.run_flow_labels[2].text.contains("RECOVER"), "reaching Morrowline should advance the tracker to recovery")
	_expect(game.state.guard_contract_status == "completed", "the protected convoy should complete the guard contract")
	_expect(game.settlement_title.text.contains("2 ACTIONS LEFT"), "the settlement should expose its limited service budget")
	_expect(game.settlement_repair_button.disabled and game.settlement_repair_button.text.contains("FULL DURABILITY"), "a fully repaired selected module should not present a dead-end repair action")
	_expect(game.settlement_refuel_button.has_focus(), "settlement focus should skip unavailable services and land on the first viable action")
	var saved_pressure: int = game.state.campaign_pressure
	game.state.campaign_pressure = 5
	game._refresh_ui()
	_expect(game.campaign_map.status_for("signal_causeway") == "closed" and game.campaign_map.status_for("lower_ash_road") == "available", "the visual map should show Break closing only the optional causeway")
	game.state.campaign_pressure = saved_pressure
	game._refresh_ui()
	var saved_money: int = game.state.money
	game.save_button.pressed.emit()
	await process_frame
	_expect(not game.load_button.disabled, "saving should immediately enable the visible load control")
	game.state.money = 1
	game.load_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "settlement" and game.state.money == saved_money, "JSON save/load should restore settlement state")
	game.settlement_refuel_button.pressed.emit()
	await process_frame
	_expect(game.state.settlement_actions_remaining == 1, "settlement service should consume one action")
	_expect(game.settlement_title.text.contains("1 ACTION LEFT"), "the service budget should update immediately after use")
	_expect(game.encounter_label.text.begins_with("SERVICE COMPLETE") and game.encounter_label.text.contains("+2 fuel") and game.encounter_label.text.contains("1 service action"), "settlement services should report cost, effect, and remaining budget above the fold")
	await _press_campaign_node("lower_ash_road")
	_expect(game.current_run_flow_step == 3 and game.run_flow_labels[3].text.contains("FINAL"), "leaving Morrowline should advance the tracker to the final approach")
	await _advance_until_phase("map")
	_expect(game.state.campaign_encounters_completed == 4, "the lower-hull route should become the fourth encounter")
	await _press_campaign_node("meridian_pass")
	_expect(game.state.phase == "final_battle", "the fifth map node should begin the final battle")
	await _advance_until_phase("results")
	_expect(game.state.phase == "results" and game.state.run_complete and game.state.campaign_encounters_completed == 5, "the five-encounter campaign should produce a completed run")
	_expect(game.current_run_flow_step == 4 and game.run_flow_labels[4].text.contains("RESULT"), "the completed run should finish the stage tracker")
	_expect(game.results_group.visible and game.play_again_button.visible and game.results_title_button.visible, "results should expose replay and return-to-title actions")
	_expect(game.results_summary_label.text.begins_with("SCARRED MARCH") and game.results_summary_label.text.contains("7 required"), "the result should explain the missed decisive threshold")
	_expect(game.results_replay_label.text.begins_with("NEXT RUN"), "the result should offer a concrete replay goal")
	_expect(game.feedback_button.has_focus(), "the completed run should hand controller focus to playtest feedback")
	_expect(game.feedback_button.get_node_or_null(game.feedback_button.focus_neighbor_bottom) == game.play_again_button and game.play_again_button.get_node_or_null(game.play_again_button.focus_neighbor_right) == game.results_title_button, "the result actions should follow their visible controller layout")
	_expect(game.results_title_button.get_node_or_null(game.results_title_button.focus_next) == game.feedback_button and game.feedback_button.get_node_or_null(game.feedback_button.focus_previous) == game.results_title_button, "the result actions should form a closed Tab cycle")
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_overlay.visible, "the final screen should provide an accessible feedback form")
	_expect(game.feedback_close_button.text == "BACK TO RESULTS" and game.feedback_save_button.text == "SAVE NOTES LOCALLY", "the feedback form should expose clear local-only actions")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_neighbor_left) == game.feedback_close_button, "the feedback actions should have explicit horizontal controller navigation")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_next) == game.feedback_clear_text and game.feedback_clear_text.get_node_or_null(game.feedback_clear_text.focus_previous) == game.feedback_save_button, "the feedback form should trap Tab navigation across fields and actions")
	game.feedback_clear_text.text = "The route consequences were clear."
	game.feedback_confusing_text.text = "The final repair tradeoff needs another run."
	game.feedback_score_option.select(3)
	game.feedback_save_button.pressed.emit()
	await process_frame
	_expect(not game.last_feedback_path.is_empty() and FileAccess.file_exists(game.last_feedback_path), "saving feedback should create a local bundle")
	_expect(game.feedback_status_label.text.begins_with("SAVED LOCALLY") and game.feedback_status_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))) and game.feedback_save_button.text == "SAVE AGAIN" and game.feedback_save_button.has_focus(), "saved feedback should provide a clear versioned receipt and repeat action")
	game._hide_feedback()
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_status_label.text.begins_with("LAST SAVED LOCALLY") and game.feedback_save_button.text == "SAVE AGAIN", "reopening feedback should preserve the previous local-save receipt")
	game._hide_feedback()
	_expect(FileAccess.file_exists(journal_path), "the UI flow should leave a local-only playtest journal")
	game.results_title_button.pressed.emit()
	await process_frame
	_expect(return_to_title_requested, "the completed stage should be able to request the application title")
	game.play_again_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "refit" and game.current_run_flow_step == 0 and game.contract_accept_button.has_focus(), "Play Again should create a fresh focused Ashgate stage")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if not game.last_feedback_path.is_empty() and FileAccess.file_exists(game.last_feedback_path):
		DirAccess.remove_absolute(game.last_feedback_path)
	if failures.is_empty():
		print("PASS: The Long March complete prototype flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
