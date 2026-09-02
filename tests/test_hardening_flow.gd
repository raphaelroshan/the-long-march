extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SAVE_BACKUP_PATH := "user://the_long_march_prototype.backup.save"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"

var app: Control
var failures: Array[String] = []
var viewport_size := Vector2i(1600, 900)
var responsive := false
var capture_dir := ""


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _settle() -> void:
	for _frame in range(4):
		await process_frame


func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "LM-I6 capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "LM-I6 capture should be written: " + name)


func _clear_test_files() -> void:
	for path in [SAVE_PATH, SAVE_BACKUP_PATH, SETTINGS_PATH]:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_expect(file != null, "LM-I6 fixture should open " + path)
	if file != null:
		file.store_string(text)
		file.close()


func _open_data_info() -> void:
	app.settings_button.pressed.emit()
	await _settle()
	app.data_info_button.pressed.emit()
	await _settle()


func _run() -> void:
	_clear_test_files()
	var width := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width.is_valid_int() and height.is_valid_int():
		viewport_size = Vector2i(int(width), int(height))
	responsive = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	root.size = viewport_size
	if responsive:
		var preferences := ConfigFile.new()
		preferences.set_value("accessibility", "text_scale_percent", 110)
		preferences.set_value("accessibility", "high_contrast", true)
		preferences.set_value("accessibility", "reduced_motion", true)
		preferences.set_value("input", "controller_layout", "east_confirm")
		preferences.save(SETTINGS_PATH)
	app = load("res://scenes/App.tscn").instantiate()
	root.add_child(app)
	await _settle()
	await _open_data_info()
	_expect(app.data_info_summary_label.text.contains("SAVE HEALTH · SCHEMA 16 · READS 4–16"), "clean-install diagnostics should expose the exact save compatibility window")
	_expect(app.data_info_summary_label.text.contains("Campaign Continue: NOT CREATED") and app.data_info_summary_label.text.contains("Campaign backup: NOT CREATED"), "clean-install diagnostics should distinguish absent checkpoints from damaged ones")
	await _capture("00_clean_install_health")
	app.data_info_close_button.pressed.emit()
	await _settle()
	app.settings_close_button.pressed.emit()
	await _settle()

	var state := LongMarchState.new(9106)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.start_campaign()
	var payload := state.serialize()
	payload["build_version"] = String(ProjectSettings.get_setting("application/config/version", "unknown"))
	payload["saved_at_unix"] = int(Time.get_unix_time_from_system())
	var valid_text := JSON.stringify(payload)
	_write(SAVE_BACKUP_PATH, valid_text)
	_write(SAVE_PATH, "{broken primary checkpoint")
	app._refresh_title_state()
	await _settle()
	await _open_data_info()
	_expect(app.data_info_summary_label.text.contains("Campaign Continue: UNUSABLE") and app.data_info_summary_label.text.contains("Campaign backup: VALID · DAY 1"), "diagnostics should expose a corrupt primary and valid predecessor without reading raw files")
	await _capture("01_recoverable_save_health")
	app.data_info_close_button.pressed.emit()
	await _settle()
	app.settings_close_button.pressed.emit()
	await _settle()
	app.save_recovery_button.pressed.emit()
	await _settle()
	_expect(app.confirmation_view.visible and app.confirmation_title_label.text == "Restore the backup?" and app.confirmation_cancel_button.text == "KEEP FILES", "recovery should require explicit confirmation and preserve a cancel path")
	await _capture("02_restore_confirmation")
	app.confirmation_confirm_button.pressed.emit()
	await _settle()
	_expect(FileAccess.get_file_as_string(SAVE_PATH) == valid_text and app.continue_button.visible, "confirmed recovery should restore the exact predecessor and re-enable Continue")
	await _open_data_info()
	_expect(app.data_info_summary_label.text.contains("Campaign Continue: VALID · DAY 1") and app.data_info_summary_label.text.contains("Campaign backup: VALID · DAY 1"), "post-recovery diagnostics should confirm both local checkpoints are valid")
	if responsive:
		_expect(app.get_global_rect().encloses(app.data_info_view.get_global_rect()), "LM-I6 diagnostics should remain inside %dx%d" % [viewport_size.x, viewport_size.y])
	await _capture("03_restored_save_health")
	_clear_test_files()
	if failures.is_empty():
		print("PASS: The Long March LM-I6 candidate recovery flow%s" % (" %dx%d" % [viewport_size.x, viewport_size.y] if responsive else ""))
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _init() -> void:
	call_deferred("_run")
