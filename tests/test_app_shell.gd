extends SceneTree

const SAVE_PATH := "user://the_long_march_prototype.save"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const JOURNAL_PATH := "user://the_long_march_playtest_journal.json"

var app: Control
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_local_test_files() -> void:
	for path in [SAVE_PATH, ONBOARDING_PATH, JOURNAL_PATH]:
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
	_expect(app.start_button.has_focus(), "Start Game should receive initial keyboard or controller focus")
	_expect(app.continue_button.disabled, "Continue should explain that no local save exists")

	app.guide_button.pressed.emit()
	await process_frame
	_expect(app.guide_view.visible, "View Test Flow should open the field guide without starting a run")
	_expect(app.guide_quick_start_button.has_focus(), "the field guide should focus its Quick Start action")
	app.guide_close_button.pressed.emit()
	await process_frame
	_expect(not app.guide_view.visible and app.guide_button.has_focus(), "closing the field guide should restore title-menu focus")

	app.quick_start_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Quick Start should open the playable Ashgate stage")
	_expect(not app.game_view.onboarding_overlay.visible, "Quick Start should skip the briefing for repeated flow tests")
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(ONBOARDING_PATH)), "Quick Start should not permanently mark the briefing complete")
	app._show_pause()
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
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Start Game should open the playable Ashgate stage")
	_expect(app.game_view.state.phase == "refit", "a new stage should begin at the Ashgate refit")
	_expect(app.game_view.campaign_map.visible, "the opening stage should expose the playable campaign map")
	_expect(app.game_view.onboarding_overlay.visible, "the guided Start Game path should open the Marchmaster briefing")

	app._show_pause()
	await process_frame
	_expect(app.pause_view.visible, "the in-stage menu should pause the march")
	_expect(app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "pausing should block stage input")
	_expect(app.resume_button.has_focus(), "Resume should receive keyboard or controller focus")
	_expect(app.pause_summary_label.text.contains("Ashgate Depot") and app.pause_summary_label.text.contains("0/5"), "the pause menu should summarize the current run")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible, "restart should require confirmation before discarding progress")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	app.pause_save_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "Save March should create the local save from the pause menu")
	_expect(app.pause_save_status_label.text.begins_with("Saved."), "the pause menu should confirm a successful save")
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

	app.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null and app.game_view.state.money == 42, "Continue should restore the locally saved stage")
	_expect(not app.game_view.onboarding_overlay.visible, "Continue should return directly to the saved decision state")

	_remove_local_test_files()
	if failures.is_empty():
		print("PASS: The Long March application shell")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
