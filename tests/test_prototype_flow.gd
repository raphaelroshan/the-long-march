extends SceneTree

var game: Control
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

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
	root.add_child(game)
	await process_frame
	await process_frame
	_expect(game.onboarding_overlay.visible, "a first run should open the Marchmaster briefing")
	for _step in range(game.ONBOARDING_STEPS.size()):
		game.onboarding_next_button.pressed.emit()
		await process_frame
	_expect(not game.onboarding_overlay.visible and FileAccess.file_exists(onboarding_path), "completing onboarding should dismiss it and persist the choice")
	_expect(game.state.phase == "refit", "prototype should begin in Ashgate refit")
	_expect(game.metric_labels.size() == 7 and game.metric_labels["fuel"].text == "6", "the HUD should expose the seven core operating resources")
	_expect(game.campaign_map.visible and game.campaign_node_buttons.size() == 9, "the campaign should render the full authored node graph")
	_expect(game.campaign_map.status_for("ashgate_depot") == "current", "the map should mark Ashgate as the current node")
	_expect(game.campaign_map.status_for("rill_crossing") == "blocked" and game.campaign_map.status_for("soot_orchard") == "blocked", "the opening roads should visibly wait for the contract decision")
	game.contract_accept_button.pressed.emit()
	await process_frame
	_expect(game.state.guard_contract_status == "accepted", "the guard contract should be selectable through the UI")
	_expect(game.campaign_map.status_for("rill_crossing") == "available" and not game.campaign_map.button_for("rill_crossing").disabled, "answering the contract should activate the opening map nodes")
	game.campaign_map.button_for("rill_crossing").grab_focus()
	await process_frame
	_expect(game.campaign_map.detail_label.text.contains("Known route"), "keyboard or controller focus should expose the same route detail as mouse hover")
	await _press_campaign_node("rill_crossing")
	_expect(game.state.phase == "battle", "the first map choice should begin a road encounter")
	_expect(game.combat_panel.visible and game.combat_panel.step_panels.size() == 6, "battle state should expose the six-step encounter timeline")
	_expect(game.combat_panel.enemy_panels[0].visible and game.combat_panel.enemy_names[0].text == "ROAD RAIDER", "battle state should expose a readable enemy card")
	await _advance_until_phase("map")
	_expect(int(game.campaign_progress_bar.value) == 1, "the region progress bar should advance after a secured encounter")
	_expect(game.campaign_map.status_for("rill_crossing") == "current" and game.campaign_map.status_for("ashgate_depot") == "secured", "the map should retain the secured route and move the current marker")
	await _press_campaign_node("broken_relay")
	await _advance_until_phase("map")
	_expect(game.state.campaign_event_pending == "lost_signal", "the Broken Relay should surface its authored decision")
	_expect(game.campaign_map.status_for("morrowline_camp") == "blocked", "the map should show that a local decision blocks the next road")
	await _press_campaign_event("move_silent")
	_expect(game.campaign_map.status_for("morrowline_camp") == "available", "resolving the relay decision should activate Morrowline")
	await _press_campaign_node("morrowline_camp")
	await _advance_until_phase("settlement")
	_expect(game.state.phase == "settlement" and game.state.campaign_encounters_completed == 3, "the third encounter should open Morrowline services")
	_expect(game.state.guard_contract_status == "completed", "the protected convoy should complete the guard contract")
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
	await _press_campaign_node("lower_ash_road")
	await _advance_until_phase("map")
	_expect(game.state.campaign_encounters_completed == 4, "the lower-hull route should become the fourth encounter")
	await _press_campaign_node("meridian_pass")
	_expect(game.state.phase == "final_battle", "the fifth map node should begin the final battle")
	await _advance_until_phase("results")
	_expect(game.state.phase == "results" and game.state.run_complete and game.state.campaign_encounters_completed == 5, "the five-encounter campaign should produce a completed run")
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_overlay.visible, "the final screen should provide an accessible feedback form")
	game._hide_feedback()
	_expect(FileAccess.file_exists(journal_path), "the UI flow should leave a local-only playtest journal")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if failures.is_empty():
		print("PASS: The Long March complete prototype flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
