extends SceneTree

const SAVE_PATH := "user://the_long_march_prototype.save"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const JOURNAL_PATH := "user://the_long_march_playtest_journal.json"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"

var app: Control
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_local_test_files() -> void:
	for path in [SAVE_PATH, ONBOARDING_PATH, JOURNAL_PATH, SETTINGS_PATH]:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove_local_test_files()
	app = load("res://scenes/App.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	_expect(app.menu_view.visible, "the application should open on the title menu")
	_expect(app.game_view == null, "the playable stage should not begin behind the title menu")
	_expect(app.title_build_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))), "the title should expose the exact build version for playtest reports")
	_expect(app.start_button.has_focus(), "Start Game should receive initial keyboard or controller focus")
	_expect(app.start_button.get_node_or_null(app.start_button.focus_neighbor_bottom) == app.quick_start_button, "title navigation should move down from Guided Start to Quick Start")
	_expect(app.continue_button.get_node_or_null(app.continue_button.focus_neighbor_bottom) == app.settings_button, "title navigation should move from Continue to the central utility action")
	_expect(app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_left) == app.guide_button and app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_right) != null, "title navigation should traverse the utility row explicitly")
	_expect(app.continue_button.disabled, "Continue should explain that no local save exists")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_neighbor_bottom) == app.settings_button and app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_top) == app.quick_start_button, "no-save navigation should route around disabled Continue")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_next) == app.guide_button and app.quit_button.get_node_or_null(app.quit_button.focus_next) == app.start_button, "no-save Tab navigation should skip Continue and wrap through visible title actions")
	_expect(app.guide_button.text == "FIELD GUIDE" and app.save_status_label.text.contains("checkpoints"), "the title should use player-facing guide and autosave language")
	var completed_briefing := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
	completed_briefing.store_string("completed for title test")
	completed_briefing.close()
	app._refresh_title_state()
	_expect(not app.quick_start_button.visible and app.start_button.text == "START GAME · ASHGATE DEPOT", "a completed briefing should collapse the two equivalent fresh-start actions into one clear Start Game action")
	_expect(app.start_button.get_node_or_null(app.start_button.focus_neighbor_bottom) == app.settings_button and app.start_button.get_node_or_null(app.start_button.focus_next) == app.guide_button, "completed-briefing navigation should skip the hidden Quick Start action")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ONBOARDING_PATH))
	app._refresh_title_state()
	_expect(app.quick_start_button.visible and app.start_button.text.contains("GUIDED FIRST RUN"), "removing the briefing marker should restore the explicit guided and quick-start choices")
	var invalid_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_save.store_string("{not valid save data")
	invalid_save.close()
	app._refresh_title_state()
	_expect(app.continue_button.disabled and app.continue_button.text.contains("UNAVAILABLE"), "invalid save data should never enable Continue")
	_expect(app.save_status_label.text.contains("Invalid data"), "the title screen should explain why a save is unavailable")
	_expect(app.save_recovery_button.visible and app.quick_start_button.get_node_or_null(app.quick_start_button.focus_neighbor_bottom) == app.save_recovery_button, "an invalid save should expose a direct recovery action in the title flow")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_next) == app.save_recovery_button and app.save_recovery_button.get_node_or_null(app.save_recovery_button.focus_next) == app.guide_button, "invalid-save Tab navigation should include the recovery action")
	app._continue_game()
	await process_frame
	_expect(app.save_recovery_button.has_focus(), "a failed Continue attempt should focus the newly available recovery action")
	app.save_recovery_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_confirm_button.text == "REMOVE SAVE" and app.confirmation_cancel_button.text == "KEEP FILE", "invalid-save removal should require a specific confirmation")
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and not app.save_recovery_button.visible and app.start_button.has_focus(), "confirmed recovery should remove the invalid save and restore the primary start action")
	app.settings_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and app.display_mode_button.has_focus(), "Settings should open without starting a run")
	_expect(app.settings_context_label.text.begins_with("TITLE MENU") and app.settings_close_button.text == "BACK TO TITLE", "title Settings should identify and return to the title menu")
	_expect(_tree_contains_text(app.settings_view, "Switch between a window") and _tree_contains_text(app.settings_view, "Save after committed decisions"), "Settings should expose consequences without requiring mouse-only tooltips")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.settings_close_button and app.settings_close_button.get_node_or_null(app.settings_close_button.focus_neighbor_top) == app.autosave_button, "Settings navigation should skip unavailable one-shot actions")
	_expect(app.settings_close_button.get_node_or_null(app.settings_close_button.focus_neighbor_bottom) == app.display_mode_button and app.display_mode_button.get_node_or_null(app.display_mode_button.focus_neighbor_top) == app.settings_close_button, "Settings navigation should form an explicit controller loop")
	app.display_mode_button.pressed.emit()
	await process_frame
	var display_config := ConfigFile.new()
	display_config.load(SETTINGS_PATH)
	_expect(app.fullscreen_enabled and bool(display_config.get_value("display", "fullscreen", false)), "fullscreen should persist as a local preference")
	app.display_mode_button.pressed.emit()
	await process_frame
	app.motion_button.pressed.emit()
	await process_frame
	_expect(app.reduced_motion and FileAccess.file_exists(ProjectSettings.globalize_path(SETTINGS_PATH)), "reduced motion should persist as a local preference")
	app.autosave_button.pressed.emit()
	await process_frame
	_expect(not app.autosave_enabled and app.autosave_button.text.contains("OFF"), "automatic checkpoints should be optional and visibly disabled")
	app.autosave_button.pressed.emit()
	await process_frame
	_expect(app.autosave_enabled and app.autosave_button.text.contains("ON"), "automatic checkpoints should be restorable before a playtest")
	app.settings_close_button.pressed.emit()
	await process_frame
	_expect(not app.settings_view.visible and app.settings_button.has_focus(), "closing Settings should restore title-menu focus")

	app.guide_button.pressed.emit()
	await process_frame
	_expect(app.guide_view.visible, "Field Guide should open without starting a run")
	_expect(app.guide_quick_start_button.has_focus(), "the field guide should focus its Quick Start action")
	_expect(app.guide_quick_start_button.get_node_or_null(app.guide_quick_start_button.focus_neighbor_left) == app.guide_close_button, "the field guide should have explicit horizontal controller navigation")
	_expect(app.guide_quick_start_button.get_node_or_null(app.guide_quick_start_button.focus_neighbor_top) == app.guide_quick_start_button and app.guide_quick_start_button.get_node_or_null(app.guide_quick_start_button.focus_next) == app.guide_close_button, "the field guide should trap directional and Tab focus inside its actions")
	_expect(_tree_contains_text(app.guide_view, "Known roads name the threat") and _tree_contains_text(app.guide_view, "only one emergency order"), "the field guide should explain visibility and intervention rules, not only list screens")
	app.guide_close_button.pressed.emit()
	await process_frame
	_expect(not app.guide_view.visible and app.guide_button.has_focus(), "closing the field guide should restore title-menu focus")

	app.quick_start_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Quick Start should open the playable Ashgate stage")
	_expect(not app.game_view.onboarding_overlay.visible, "Quick Start should skip the briefing for repeated flow tests")
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(ONBOARDING_PATH)), "Quick Start should not permanently mark the briefing complete")
	_expect(app.game_view.contract_accept_button.has_focus(), "Quick Start should focus the first required Ashgate decision")
	_expect(app.game_view.pause_button.visible and app.game_view.pause_button.text.contains("ESC / B"), "the live stage should expose a visible mouse and controller pause action")
	app.game_view.contract_decline_button.grab_focus()
	app.game_view.pause_button.pressed.emit()
	await process_frame
	_expect(app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "the visible stage pause action should open and suspend the march")
	app.resume_button.pressed.emit()
	await process_frame
	_expect(app.game_view.contract_decline_button.has_focus(), "resuming should restore the stage control that had focus")
	app.game_view.contract_decline_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "confirming the first campaign decision should create an automatic checkpoint")
	_expect(app.last_checkpoint_reason == "contract_answered", "the application should report the latest automatic checkpoint reason")
	_expect(app.checkpoint_toast.visible and app.checkpoint_toast_label.text.contains("CONTRACT DECISION"), "a successful automatic checkpoint should produce a brief player-facing notice")
	_expect(not app.checkpoint_toast.get_global_rect().intersects(app.game_view.pause_button.get_global_rect()), "checkpoint notices should not cover the persistent stage pause control")
	app._show_pause()
	_expect(not app.checkpoint_toast.visible, "opening the pause menu should dismiss transient checkpoint notices")
	_expect(app.title_button.text == "RETURN TO TITLE" and app.pause_save_status_label.text.begins_with("Current decision saved"), "the pause menu should recognize a current automatic checkpoint")
	_expect(app.restart_button.has_theme_stylebox_override("normal") and not app.title_button.has_theme_stylebox_override("normal"), "pause should distinguish destructive restart from a safely checkpointed title return")
	_expect(app.pause_summary_label.text.contains("FUEL 6") and app.pause_summary_label.text.contains("HULL 10/10") and app.pause_summary_label.text.contains("HEAT 5/6"), "the pause menu should preserve the critical fortress resource snapshot")
	app.game_view.state.money += 1
	app._refresh_pause_summary()
	_expect(app.title_button.text == "EXIT UNSAVED" and app.pause_save_status_label.text.begins_with("Unsaved changes"), "the pause menu should reveal progress made after the last checkpoint")
	_expect(app.title_button.has_theme_stylebox_override("normal"), "an unsaved title exit should receive the destructive warning treatment")
	app.title_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible, "returning without saving should require confirmation")
	_expect(app.confirmation_cancel_button.has_focus(), "the safe confirmation choice should receive focus")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(not app.confirmation_view.visible and app.pause_view.visible, "cancelling should return to the pause menu")
	app.title_button.pressed.emit()
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	await process_frame

	app.start_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_confirm_button.text == "START NEW", "starting over with an autosave should explain when the previous save will be replaced")
	_expect(app.confirmation_cancel_button.text == "KEEP SAVE", "the safe new-run confirmation action should preserve the existing save")
	_expect(app.confirmation_body_label.text.contains("Day 1 at Ashgate Depot"), "the new-run warning should identify the checkpoint being preserved")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	app.start_button.pressed.emit()
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Start Game should open the playable Ashgate stage")
	_expect(app.game_view.state.phase == "refit", "a new stage should begin at the Ashgate refit")
	_expect(app.game_view.campaign_map.visible, "the opening stage should expose the playable campaign map")
	_expect(app.game_view.onboarding_overlay.visible, "the guided Start Game path should open the Marchmaster briefing")
	_expect(app.game_view.onboarding_next_button.has_focus(), "the guided path should focus the briefing's next action")
	_expect(not app.game_view.save_button.visible and not app.game_view.load_button.visible, "pause-owned persistence controls should not be duplicated in the live stage")

	app.game_view._finish_onboarding(false)
	await process_frame
	app._show_pause()
	await process_frame
	_expect(app.pause_view.visible, "the in-stage menu should pause the march")
	_expect(app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "pausing should block stage input")
	_expect(app.resume_button.has_focus(), "Resume should receive keyboard or controller focus")
	_expect(app.resume_button.get_node_or_null(app.resume_button.focus_neighbor_bottom) == app.pause_save_button and app.pause_save_button.get_node_or_null(app.pause_save_button.focus_neighbor_right) == app.save_return_button, "the pause menu should have explicit directional navigation")
	_expect(app.title_button.get_node_or_null(app.title_button.focus_next) == app.resume_button and app.resume_button.get_node_or_null(app.resume_button.focus_previous) == app.title_button, "the pause menu should trap Tab navigation inside its visible actions")
	_expect(app.pause_summary_label.text.contains("Ashgate Depot") and app.pause_summary_label.text.contains("0/5"), "the pause menu should summarize the current run")
	_expect(app.pause_build_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))), "the pause menu should preserve the tested build identifier")
	app.pause_briefing_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_INHERIT and app.game_view.onboarding_overlay.visible, "the pause menu should reopen the field briefing without leaving the run")
	_expect(app.game_view.onboarding_skip_button.text == "CLOSE BRIEFING" and app.game_view.onboarding_progress_label.text.contains("Esc closes"), "a reopened briefing should use reference-mode close language")
	app.game_view.onboarding_step = app.game_view.ONBOARDING_STEPS.size() - 1
	app.game_view._refresh_onboarding()
	_expect(app.game_view.onboarding_next_button.text == "RETURN TO MARCH", "the final reopened briefing step should return to the active march")
	app.game_view._finish_onboarding(true)
	await process_frame
	app._show_pause()
	await process_frame
	app.pause_settings_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and not app.pause_view.visible, "Settings should open directly from a paused run")
	_expect(app.settings_context_label.text.begins_with("PAUSED MARCH") and app.settings_close_button.text == "BACK TO PAUSE", "in-run Settings should identify and return to the paused march")
	_expect(not app.reset_briefing_button.disabled, "a completed briefing should expose its one-shot reset action")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.reset_briefing_button and app.reset_briefing_button.get_node_or_null(app.reset_briefing_button.focus_neighbor_bottom) == app.clear_save_button, "Settings navigation should include available one-shot actions in order")
	app.reset_briefing_button.pressed.emit()
	await process_frame
	_expect(app.reset_briefing_button.disabled and app.settings_close_button.has_focus(), "resetting the briefing should move focus to an enabled return action")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.clear_save_button and app.clear_save_button.get_node_or_null(app.clear_save_button.focus_neighbor_top) == app.autosave_button, "Settings navigation should reroute immediately after a one-shot action becomes unavailable")
	var cancel_input := InputEventJoypadButton.new()
	cancel_input.button_index = JOY_BUTTON_B
	cancel_input.pressed = true
	app._unhandled_input(cancel_input)
	await process_frame
	_expect(not app.settings_view.visible and app.pause_view.visible and app.pause_settings_button.has_focus(), "cancelling in-run Settings should close it and return to the pause menu")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible, "restart should require confirmation before discarding progress")
	_expect(app.confirmation_cancel_button.get_node_or_null(app.confirmation_cancel_button.focus_neighbor_right) == app.confirmation_confirm_button, "confirmation actions should have explicit horizontal controller navigation")
	_expect(app.confirmation_cancel_button.get_node_or_null(app.confirmation_cancel_button.focus_neighbor_top) == app.confirmation_cancel_button and app.confirmation_confirm_button.get_node_or_null(app.confirmation_confirm_button.focus_next) == app.confirmation_cancel_button, "confirmation dialogs should trap directional and Tab focus")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	app.pause_save_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "Save March should create the local save from the pause menu")
	_expect(app.pause_save_status_label.text.begins_with("Saved."), "the pause menu should confirm a successful save")
	_expect(app.title_button.text == "RETURN TO TITLE", "saving should make the safe return action explicit")
	_expect(not app.title_button.has_theme_stylebox_override("normal"), "saving should remove the destructive warning treatment from Return to Title")
	app.title_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.menu_view.visible and not app.confirmation_view.visible, "a fully saved run should return to title without a redundant warning")
	app.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null, "Continue should restore the run after a safe return")
	app._show_pause()
	app.resume_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_INHERIT, "Resume should restore the stage")

	app.game_view.state.money = 42
	app._show_pause()
	app.save_return_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.menu_view.visible and app.game_view == null, "Save & Return should close the stage and restore the menu")
	_expect(not app.continue_button.disabled, "Save & Return should enable Continue on the title menu")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_neighbor_bottom) == app.continue_button and app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_top) == app.continue_button, "save-aware navigation should restore Continue to the title loop")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_next) == app.continue_button and app.continue_button.get_node_or_null(app.continue_button.focus_next) == app.guide_button, "save-aware Tab navigation should include Continue in the title loop")
	_expect(app.start_button.text.begins_with("NEW GAME") and app.quick_start_button.text.begins_with("NEW QUICK RUN"), "existing progress should make both fresh-start actions explicit")
	_expect(app.continue_button.has_focus(), "a valid save should make Continue the default title action")
	_expect(app.continue_button.text.contains("DAY 1") and app.continue_button.text.contains("ASHGATE DEPOT"), "Continue should identify the saved day and location before loading")
	_expect(app.save_status_label.text.contains("Watch") and app.save_status_label.text.contains("Refit") and app.save_status_label.text.contains("0/5"), "the title should identify checkpoint condition, phase, and encounter progress")
	_expect(app.save_status_label.text.contains("Saved just now"), "the title should show how recently the local checkpoint was written")
	_expect(app.save_status_label.text.contains("Fuel 6") and app.save_status_label.text.contains("Hull 10/10") and app.save_status_label.text.contains("Heat 5/6"), "the title should summarize the saved fortress condition")
	_expect(app.continue_button.tooltip_text.contains(String(ProjectSettings.get_setting("application/config/version"))), "Continue should expose the build that created the checkpoint")
	var saved_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	_expect(saved_payload is Dictionary and String(saved_payload.get("build_version", "")) == String(ProjectSettings.get_setting("application/config/version")), "campaign saves should record their exact application build")
	_expect(saved_payload is Dictionary and int(saved_payload.get("saved_at_unix", 0)) > 0, "campaign saves should record when the checkpoint was created")
	saved_payload["build_version"] = "0.2.0-test"
	var older_build_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	older_build_save.store_string(JSON.stringify(saved_payload))
	older_build_save.close()
	app._refresh_title_state()
	_expect(app.save_status_label.text.contains("Compatible checkpoint from 0.2.0-test"), "a compatible save from another build should identify that build without requiring a tooltip")
	app.settings_button.pressed.emit()
	await process_frame
	app.autosave_button.pressed.emit()
	app.settings_close_button.pressed.emit()
	await process_frame
	app.quick_start_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_body_label.text.contains("save manually or enable autosave"), "a fresh run should protect existing progress even while autosave is off")
	app.confirmation_cancel_button.pressed.emit()
	app.settings_button.pressed.emit()
	await process_frame
	app.autosave_button.pressed.emit()
	app.settings_close_button.pressed.emit()
	await process_frame

	app.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null and app.game_view.state.money == 42, "Continue should restore the locally saved stage")
	if app.game_view != null:
		_expect(not app.game_view.onboarding_overlay.visible, "Continue should return directly to the saved decision state")
		app._show_pause()
		app.save_return_button.pressed.emit()
		await process_frame
		await process_frame
		app.settings_button.pressed.emit()
		await process_frame
		_expect(not app.clear_save_button.disabled, "Settings should offer clearing an existing local save")
		app.clear_save_button.pressed.emit()
		await process_frame
		_expect(app.confirmation_view.visible and app.confirmation_confirm_button.text == "CLEAR SAVE", "clearing a save should require explicit confirmation")
		app.confirmation_confirm_button.pressed.emit()
		await process_frame
		_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and app.continue_button.disabled, "confirmed save clearing should remove Continue progress")
		_expect(app.clear_save_button.disabled and app.settings_close_button.has_focus(), "clearing the save should move focus away from the newly disabled action")
		_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.settings_close_button and app.settings_close_button.get_node_or_null(app.settings_close_button.focus_neighbor_top) == app.autosave_button, "Settings navigation should collapse cleanly after the last one-shot action is consumed")

	_remove_local_test_files()
	if failures.is_empty():
		print("PASS: The Long March application shell")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _tree_contains_text(node: Node, fragment: String) -> bool:
	if node is Label and String(node.text).contains(fragment):
		return true
	for child in node.get_children():
		if _tree_contains_text(child, fragment):
			return true
	return false
