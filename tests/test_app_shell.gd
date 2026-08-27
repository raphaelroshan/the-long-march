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
	_expect(app.guide_button.text == "FIELD GUIDE" and app.save_status_label.text.contains("checkpoints"), "the title should use player-facing guide and autosave language")
	var invalid_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_save.store_string("{not valid save data")
	invalid_save.close()
	app._refresh_title_state()
	_expect(app.continue_button.disabled and app.continue_button.text.contains("UNAVAILABLE"), "invalid save data should never enable Continue")
	_expect(app.save_status_label.text.contains("Invalid data"), "the title screen should explain why a save is unavailable")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	app._refresh_title_state()
	app.settings_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and app.display_mode_button.has_focus(), "Settings should open without starting a run")
	_expect(app.settings_context_label.text.begins_with("TITLE MENU") and app.settings_close_button.text == "BACK TO TITLE", "title Settings should identify and return to the title menu")
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
	app.game_view.contract_decline_button.grab_focus()
	app._show_pause()
	app.resume_button.pressed.emit()
	await process_frame
	_expect(app.game_view.contract_decline_button.has_focus(), "resuming should restore the stage control that had focus")
	app.game_view.contract_decline_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "confirming the first campaign decision should create an automatic checkpoint")
	_expect(app.last_checkpoint_reason == "contract_answered", "the application should report the latest automatic checkpoint reason")
	_expect(app.checkpoint_toast.visible and app.checkpoint_toast_label.text.contains("CONTRACT ANSWERED"), "a successful automatic checkpoint should produce a brief non-blocking notice")
	app._show_pause()
	_expect(not app.checkpoint_toast.visible, "opening the pause menu should dismiss transient checkpoint notices")
	_expect(app.title_button.text == "RETURN TO TITLE" and app.pause_save_status_label.text.begins_with("Current decision saved"), "the pause menu should recognize a current automatic checkpoint")
	_expect(app.pause_summary_label.text.contains("FUEL 6") and app.pause_summary_label.text.contains("HULL 10/10") and app.pause_summary_label.text.contains("HEAT 5/6"), "the pause menu should preserve the critical fortress resource snapshot")
	app.game_view.state.money += 1
	app._refresh_pause_summary()
	_expect(app.title_button.text == "EXIT UNSAVED" and app.pause_save_status_label.text.begins_with("Unsaved changes"), "the pause menu should reveal progress made after the last checkpoint")
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
	app.reset_briefing_button.pressed.emit()
	await process_frame
	_expect(app.reset_briefing_button.disabled and app.settings_close_button.has_focus(), "resetting the briefing should move focus to an enabled return action")
	app.settings_close_button.pressed.emit()
	await process_frame
	_expect(app.pause_view.visible and app.pause_settings_button.has_focus(), "closing in-run Settings should return to the pause menu")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible, "restart should require confirmation before discarding progress")
	_expect(app.confirmation_cancel_button.get_node_or_null(app.confirmation_cancel_button.focus_neighbor_right) == app.confirmation_confirm_button, "confirmation actions should have explicit horizontal controller navigation")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	app.pause_save_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "Save March should create the local save from the pause menu")
	_expect(app.pause_save_status_label.text.begins_with("Saved."), "the pause menu should confirm a successful save")
	_expect(app.title_button.text == "RETURN TO TITLE", "saving should make the safe return action explicit")
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
	_expect(app.start_button.text.begins_with("NEW GAME") and app.quick_start_button.text.begins_with("NEW QUICK RUN"), "existing progress should make both fresh-start actions explicit")
	_expect(app.continue_button.has_focus(), "a valid save should make Continue the default title action")
	_expect(app.continue_button.text.contains("DAY 1") and app.continue_button.text.contains("ASHGATE DEPOT"), "Continue should identify the saved day and location before loading")
	_expect(app.save_status_label.text.contains("Refit") and app.save_status_label.text.contains("0/5"), "the title should identify the saved phase and encounter progress")

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

	_remove_local_test_files()
	if failures.is_empty():
		print("PASS: The Long March application shell")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
