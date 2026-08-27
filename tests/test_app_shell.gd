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

	app.start_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Start Game should open the playable Ashgate stage")
	_expect(app.game_view.state.phase == "refit", "a new stage should begin at the Ashgate refit")
	_expect(app.game_view.campaign_map.visible, "the opening stage should expose the playable campaign map")

	app._show_pause()
	await process_frame
	_expect(app.pause_view.visible, "the in-stage menu should pause the march")
	_expect(app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "pausing should block stage input")
	_expect(app.resume_button.has_focus(), "Resume should receive keyboard or controller focus")
	app.resume_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_INHERIT, "Resume should restore the stage")

	app.game_view.state.money = 42
	app.game_view.save_button.pressed.emit()
	await process_frame
	app._show_pause()
	app.title_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.menu_view.visible and app.game_view == null, "Return to Title should close the stage and restore the menu")
	_expect(not app.continue_button.disabled, "saving a stage should enable Continue on the title menu")

	app.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null and app.game_view.state.money == 42, "Continue should restore the locally saved stage")

	_remove_local_test_files()
	if failures.is_empty():
		print("PASS: The Long March application shell")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
