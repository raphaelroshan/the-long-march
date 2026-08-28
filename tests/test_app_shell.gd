extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SAVE_BACKUP_PATH := "user://the_long_march_prototype.backup.save"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const JOURNAL_PATH := "user://the_long_march_playtest_journal.json"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"
const PROGRESS_PATH := "user://the_long_march_progress.json"
const FEEDBACK_PRESERVE_PATH := "user://the_long_march_feedback_reset_test.json"

var app: Control
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_local_test_files() -> void:
	for path in [SAVE_PATH, SAVE_BACKUP_PATH, ONBOARDING_PATH, JOURNAL_PATH, SETTINGS_PATH, PROGRESS_PATH, FEEDBACK_PRESERVE_PATH]:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove_local_test_files()
	root.size = Vector2i(1280, 720)
	var persisted_scale_config := ConfigFile.new()
	persisted_scale_config.set_value("accessibility", "text_scale_percent", 110)
	persisted_scale_config.set_value("accessibility", "high_contrast", true)
	persisted_scale_config.set_value("input", "controller_layout", "east_confirm")
	persisted_scale_config.set_value("audio", "interface_percent", 40)
	persisted_scale_config.save(SETTINGS_PATH)
	var restored_scale_app = load("res://scenes/App.tscn").instantiate()
	root.add_child(restored_scale_app)
	await process_frame
	await process_frame
	_expect(restored_scale_app.text_scale_percent == 110 and restored_scale_app.theme.default_font_size == 18 and not restored_scale_app.title_control_contract_label.visible and not restored_scale_app.title_right_spacer.visible, "a new application shell should restore and apply the persisted large-text layout")
	_expect(restored_scale_app.high_contrast_enabled and restored_scale_app.title_veil.color.a > 0.7 and restored_scale_app.theme.get_stylebox("focus", "Button").border_width_left == 4, "a new application shell should restore the stronger backdrop and focus outline")
	_expect(restored_scale_app.controller_layout_id == "east_confirm" and restored_scale_app.title_input_legend_label.text.contains("B / Enter confirms") and restored_scale_app.title_input_legend_label.text.contains("A / Esc closes"), "a new application shell should restore the alternate controller layout and matching visible legend")
	_expect(restored_scale_app.interface_audio_percent == 40 and restored_scale_app.interface_audio.volume_percent == 40, "a new application shell should restore the local interface-audio level")
	restored_scale_app.queue_free()
	await process_frame
	var invalid_scale_config := ConfigFile.new()
	invalid_scale_config.set_value("accessibility", "text_scale_percent", 175)
	invalid_scale_config.set_value("audio", "interface_percent", 135)
	invalid_scale_config.set_value("input", "controller_layout", "unsupported")
	invalid_scale_config.save(SETTINGS_PATH)
	app = load("res://scenes/App.tscn").instantiate()
	var quit_probe := {"count": 0}
	app.application_quit_requested.connect(func() -> void: quit_probe["count"] = int(quit_probe["count"]) + 1)
	root.add_child(app)
	await process_frame
	await process_frame
	_expect(not auto_accept_quit, "the application should intercept operating-system close requests instead of accepting them before save review")
	_expect(app.menu_view.visible, "the application should open on the title menu")
	_expect(app.game_view == null, "the playable stage should not begin behind the title menu")
	_expect(app.title_build_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))), "the title should expose the exact build version for playtest reports")
	_expect(app.start_button.has_focus(), "Start Game should receive initial keyboard or controller focus")
	_expect(app.start_button.get_node_or_null(app.start_button.focus_neighbor_bottom) == app.quick_start_button, "title navigation should move down from Guided Start to Quick Start")
	_expect(app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_left) == app.guide_button and app.settings_button.get_node_or_null(app.settings_button.focus_neighbor_right) != null, "title navigation should traverse the utility row explicitly")
	_expect(not app.continue_button.visible and app.continue_button.disabled, "Continue should stay out of the action stack when no local save exists")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_neighbor_bottom) == app.veyru_start_button and app.veyru_start_button.get_node_or_null(app.veyru_start_button.focus_neighbor_bottom) == app.settings_button, "no-save navigation should include both playable regions while routing around disabled Continue")
	_expect(app.quick_start_button.get_node_or_null(app.quick_start_button.focus_next) == app.veyru_start_button and app.veyru_start_button.get_node_or_null(app.veyru_start_button.focus_next) == app.guide_button and app.quit_button.get_node_or_null(app.quit_button.focus_next) == app.start_button, "no-save Tab navigation should include Veyru, skip Continue, and wrap through visible title actions")
	_expect(app.guide_button.text == "FIELD GUIDE" and app.save_status_label.text.contains("Autosave begins after your first committed decision"), "the title should explain the first automatic checkpoint in player-facing language")
	_expect(app.guide_quick_start_button.text == "QUICK START ASHGATE", "the no-save Field Guide should offer a direct quick start")
	_expect(_tree_contains_text(app.menu_view, "Choose the obligation") and _tree_contains_text(app.menu_view, "sealed medicines"), "the title overview should frame both chapters through their opening obligation")
	_expect(_tree_contains_text(app.menu_view, "CURRENT BUILD · TWO TEST JOURNEYS") and _tree_contains_text(app.menu_view, "Ashgate") and _tree_contains_text(app.menu_view, "Flooded Veyru"), "the title should state both playable chapters without implying that the wider campaign is implemented")
	_expect(_tree_contains_text(app.menu_view, "YOU CONTROL · CHASSIS · ROUTE · DOCTRINE · ONE EMERGENCY ORDER") and _tree_contains_text(app.menu_view, "BATTLES RESOLVE STEP BY STEP"), "the title should state the boundary between player decisions and automatic battle resolution before starting")
	_expect(_tree_contains_text(app.menu_view, "TWO PLAYABLE CHAPTERS") and _tree_contains_text(app.menu_view, "5 ENCOUNTERS EACH") and _tree_contains_text(app.menu_view, "FINALE AT 5"), "the title should make clear that both playable chapters reach a fifth-encounter finale")
	_expect(app.title_charter_label.text.contains("MARCH CHARTER · 0/2 REGIONS SURVIVED") and app.title_charter_label.text.contains("Choose either chapter"), "a fresh title should present the bounded two-chapter charter without inventing progress")
	_expect(_tree_contains_text(app.menu_view, "D-pad / arrows move") and _tree_contains_text(app.menu_view, "B / Esc closes panels"), "the title should describe its own navigation behavior instead of claiming that cancel pauses the game")
	app._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	_expect(int(quit_probe["count"]) == 1 and not app.confirmation_view.visible, "closing from the title should quit immediately because no live stage state can be lost")
	var completed_briefing := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
	completed_briefing.store_string("completed for title test")
	completed_briefing.close()
	app._refresh_title_state()
	_expect(not app.quick_start_button.visible and app.start_button.text == "START GAME · ASHGATE DEPOT", "a completed briefing should collapse the two equivalent fresh-start actions into one clear Start Game action")
	_expect(app.start_button.get_node_or_null(app.start_button.focus_neighbor_bottom) == app.veyru_start_button and app.start_button.get_node_or_null(app.start_button.focus_next) == app.veyru_start_button, "completed-briefing navigation should skip the hidden Quick Start action while retaining Veyru")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ONBOARDING_PATH))
	app._refresh_title_state()
	_expect(app.quick_start_button.visible and app.start_button.text.contains("GUIDED FIRST RUN"), "removing the briefing marker should restore the explicit guided and quick-start choices")
	var invalid_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_save.store_string("{not valid save data")
	invalid_save.close()
	app._refresh_title_state()
	_expect(not app.continue_button.visible and app.continue_button.disabled, "invalid save data should never expose Continue as an actionable choice")
	_expect(app.save_status_label.text.contains("Invalid data"), "the title screen should explain why a save is unavailable")
	_expect(app.save_recovery_button.visible and app.save_recovery_button.text == "REMOVE UNUSABLE SAVE" and app.veyru_start_button.get_node_or_null(app.veyru_start_button.focus_neighbor_bottom) == app.save_recovery_button, "an invalid save should expose an accurately named recovery action after both new-run choices")
	_expect(not app.quick_start_button.visible and app.start_button.get_node_or_null(app.start_button.focus_next) == app.veyru_start_button and app.veyru_start_button.get_node_or_null(app.veyru_start_button.focus_next) == app.save_recovery_button and app.save_recovery_button.get_node_or_null(app.save_recovery_button.focus_next) == app.guide_button, "invalid-save navigation should collapse redundant Quick Start while retaining both regions and recovery")
	app._continue_game()
	await process_frame
	_expect(app.save_recovery_button.has_focus(), "a failed Continue attempt should focus the newly available recovery action")
	app.save_recovery_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_confirm_button.text == "REMOVE SAVE" and app.confirmation_cancel_button.text == "KEEP FILE" and app.confirmation_body_label.text.contains("cannot be loaded by this build"), "invalid-save removal should require an accurate, specific confirmation")
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and not app.save_recovery_button.visible and app.start_button.has_focus(), "confirmed recovery should remove the invalid save and restore the primary start action")
	var incompatible_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	incompatible_save.store_string(JSON.stringify({"save_version": 999}))
	incompatible_save.close()
	app._refresh_title_state()
	_expect(app.save_status_label.text.contains("incompatible save format") and not app.save_status_label.text.contains("schema") and app.save_status_label.autowrap_mode != TextServer.AUTOWRAP_OFF, "an incompatible checkpoint should use wrapped player-facing recovery language rather than raw schema numbers")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	app._refresh_title_state()
	app.settings_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and app.display_mode_button.has_focus(), "Settings should open without starting a run")
	_expect(app.settings_context_label.text.begins_with("TITLE MENU") and app.settings_close_button.text == "BACK TO TITLE", "title Settings should identify and return to the title menu")
	_expect(_tree_contains_text(app.settings_view, "Switch between a window") and _tree_contains_text(app.settings_view, "Increase interface text") and _tree_contains_text(app.settings_view, "Darken backdrops") and _tree_contains_text(app.settings_view, "Swap the A/B") and _tree_contains_text(app.settings_view, "Cycle restrained focus") and _tree_contains_text(app.settings_view, "Save after committed decisions"), "Settings should expose display, text-size, contrast, controller, audio, and save consequences without requiring mouse-only tooltips")
	_expect(app.text_scale_button.text == "TEXT SIZE · 100%" and app.theme.default_font_size == 16, "Settings should safely normalize an unsupported stored text size to the standard interface size")
	_expect(not app.high_contrast_enabled and app.contrast_button.text == "VISUAL CONTRAST · STANDARD", "Settings should default to the authored standard palette when no contrast preference is stored")
	_expect(app.controller_layout_id == "south_confirm" and app.controller_layout_button.text == "CONTROLLER CONFIRM · A", "Settings should normalize an unsupported controller layout to the default A-confirm mapping")
	_expect(app.interface_audio_percent == 70 and app.interface_audio_button.text == "INTERFACE AUDIO · 70%", "Settings should safely normalize an unsupported stored audio level to the comfortable default")
	_expect(app.display_mode_button.get_node_or_null(app.display_mode_button.focus_neighbor_bottom) == app.text_scale_button and app.text_scale_button.get_node_or_null(app.text_scale_button.focus_neighbor_bottom) == app.contrast_button and app.contrast_button.get_node_or_null(app.contrast_button.focus_neighbor_bottom) == app.controller_layout_button and app.controller_layout_button.get_node_or_null(app.controller_layout_button.focus_neighbor_bottom) == app.motion_button, "controller navigation should place controller layout between visual contrast and motion")
	_expect(app.motion_button.get_node_or_null(app.motion_button.focus_neighbor_bottom) == app.interface_audio_button and app.interface_audio_button.get_node_or_null(app.interface_audio_button.focus_neighbor_bottom) == app.autosave_button, "controller navigation should place interface audio between motion and save behavior")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.data_info_button and app.data_info_button.get_node_or_null(app.data_info_button.focus_neighbor_bottom) == app.reset_playtest_button and app.reset_playtest_button.get_node_or_null(app.reset_playtest_button.focus_neighbor_bottom) == app.settings_close_button, "Settings navigation should retain build information and the available clean-start action while skipping unavailable category resets")
	_expect(app.settings_close_button.get_node_or_null(app.settings_close_button.focus_neighbor_bottom) == app.display_mode_button and app.display_mode_button.get_node_or_null(app.display_mode_button.focus_neighbor_top) == app.settings_close_button, "Settings navigation should form an explicit controller loop")
	_expect(app.data_info_button.text.contains(String(ProjectSettings.get_setting("application/config/version"))), "Settings should expose the exact running build before opening local-data details")
	app.data_info_button.pressed.emit()
	await process_frame
	_expect(app.data_info_view.visible and not app.settings_view.visible and app.data_info_close_button.has_focus(), "Build & Local Data should open as a focused modal above Settings")
	_expect(app.data_info_context_label.text.begins_with("TITLE MENU") and app.data_info_summary_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))) and app.data_info_summary_label.text.contains(OS.get_name()) and app.data_info_summary_label.text.contains("No account login, telemetry SDK, or automatic upload"), "the data panel should identify the build, platform, and offline boundary in visible copy")
	_expect(app.data_info_summary_label.text.contains("Continue: NOT CREATED") and app.data_info_summary_label.text.contains("Preferences: AVAILABLE") and app.data_info_summary_label.text.contains("Exported feedback reports:"), "the data panel should report each local state category without claiming every file exists")
	_expect(app.data_info_path_label.text.contains(ProjectSettings.globalize_path("user://")) and app.data_info_close_button.get_node_or_null(app.data_info_close_button.focus_neighbor_right) == app.data_info_copy_button, "the data panel should expose the exact local folder and a closed controller action pair")
	app.data_info_copy_button.pressed.emit()
	await process_frame
	_expect(app.data_info_status_label.text.begins_with("DATA FOLDER PATH COPIED") and app.data_info_status_label.text.contains("Nothing was opened or sent") and app.data_info_copy_button.has_focus(), "copying the data-folder path should produce a visible local-only receipt")
	var data_cancel := InputEventJoypadButton.new()
	data_cancel.button_index = JOY_BUTTON_B
	data_cancel.pressed = true
	app._unhandled_input(data_cancel)
	await process_frame
	_expect(not app.data_info_view.visible and app.settings_view.visible and app.data_info_button.has_focus(), "controller cancel should return from build information to the same Settings action")
	app.text_scale_button.pressed.emit()
	await process_frame
	await process_frame
	var scale_config := ConfigFile.new()
	scale_config.load(SETTINGS_PATH)
	_expect(app.text_scale_percent == 110 and app.text_scale_button.text == "TEXT SIZE · 110%" and app.theme.default_font_size == 18 and app.title_build_label.get_theme_font_size("font_size") == 14, "the larger text size should apply immediately to inherited and explicit interface text")
	_expect(int(scale_config.get_value("accessibility", "text_scale_percent", 0)) == 110, "text size should persist as a local accessibility preference")
	var scale_scroll_rect: Rect2 = app.settings_scroll.get_global_rect()
	var scale_button_rect: Rect2 = app.text_scale_button.get_global_rect()
	_expect(scale_button_rect.position.y >= scale_scroll_rect.position.y and scale_button_rect.end.y <= scale_scroll_rect.end.y, "changing text size should keep its focused control inside the visible Settings viewport")
	var title_view_rect: Rect2 = app.menu_view.get_global_rect()
	_expect(title_view_rect.encloses(app.start_button.get_global_rect()) and title_view_rect.encloses(app.quit_button.get_global_rect()) and not app.title_control_contract_label.visible and not app.title_right_spacer.visible, "larger text should preserve the complete title action stack while collapsing secondary title spacing at 1280×720")
	app.text_scale_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.text_scale_percent == 100 and app.theme.default_font_size == 16 and app.title_build_label.get_theme_font_size("font_size") == 13 and app.title_control_contract_label.visible and app.title_right_spacer.visible, "text size should return to the complete standard layout without restarting")
	app.contrast_button.pressed.emit()
	await process_frame
	await process_frame
	var contrast_config := ConfigFile.new()
	contrast_config.load(SETTINGS_PATH)
	_expect(app.high_contrast_enabled and bool(contrast_config.get_value("accessibility", "high_contrast", false)) and app.contrast_button.text == "VISUAL CONTRAST · HIGH", "high contrast should apply immediately and persist locally")
	_expect(app.title_veil.color.a > 0.7 and app.theme.get_stylebox("focus", "Button").border_width_left == 4 and app.save_status_label.get_theme_color("font_color") == Color("#e0e7e7"), "high contrast should strengthen the title backdrop, focus outline, and muted save copy together")
	app.contrast_button.pressed.emit()
	await process_frame
	_expect(not app.high_contrast_enabled and app.title_veil.color.a < 0.5 and app.theme.get_stylebox("focus", "Button").border_width_left == 3 and app.save_status_label.get_theme_color("font_color") == Color("#9aa8aa"), "returning to Standard should restore the authored title backdrop, outline, and latest status color")
	app.contrast_button.pressed.emit()
	await process_frame
	_expect(app.high_contrast_enabled, "visual contrast should be re-enabled for the live-stage inheritance test")
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
	app.interface_audio_button.pressed.emit()
	await process_frame
	var audio_config := ConfigFile.new()
	audio_config.load(SETTINGS_PATH)
	_expect(app.interface_audio_percent == 100 and app.interface_audio.volume_percent == 100 and int(audio_config.get_value("audio", "interface_percent", -1)) == 100, "interface-audio changes should apply immediately and persist locally")
	app.interface_audio_button.pressed.emit()
	await process_frame
	_expect(app.interface_audio_percent == 0 and app.interface_audio_button.text.contains("MUTED") and app.settings_status_label.text.contains("Visual focus"), "muting should explicitly preserve the visual interaction contract")
	app.interface_audio_button.pressed.emit()
	await process_frame
	_expect(app.interface_audio_percent == 40 and app.interface_audio.last_cue_kind == "notice", "restoring audible interface feedback should preview the selected level")
	app.interface_audio_button.pressed.emit()
	await process_frame
	_expect(app.interface_audio_percent == 70, "the settings cycle should return to the documented default level")
	app.controller_layout_button.pressed.emit()
	await process_frame
	var controller_config := ConfigFile.new()
	controller_config.load(SETTINGS_PATH)
	_expect(app.controller_layout_id == "east_confirm" and String(controller_config.get_value("input", "controller_layout", "")) == "east_confirm" and app.controller_layout_button.text == "CONTROLLER CONFIRM · B", "the alternate controller layout should apply immediately and persist locally")
	_expect(app.title_input_legend_label.text.contains("B / Enter confirms") and app.title_input_legend_label.text.contains("A / Esc closes"), "changing controller layout should update visible title instructions even while Settings is open")
	var swapped_cancel := InputEventJoypadButton.new()
	swapped_cancel.button_index = JOY_BUTTON_A
	swapped_cancel.pressed = true
	app._unhandled_input(swapped_cancel)
	await process_frame
	_expect(not app.settings_view.visible and app.settings_button.has_focus(), "the remapped cancel button should close Settings and restore title focus")
	app.settings_button.pressed.emit()
	await process_frame
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
	_expect(_tree_contains_text(app.guide_view, "Known roads name contacts and counters") and _tree_contains_text(app.guide_view, "Ashgate reaches Closing at 3 and Break at 5") and _tree_contains_text(app.guide_view, "Veyru reaches Flooding at 3 and Breach at 5") and _tree_contains_text(app.guide_view, "only one emergency order"), "the field guide should explain both regions' visibility, pressure, and intervention rules, not only list screens")
	_expect(_tree_contains_text(app.guide_view, "same simulation, seed, route graph, and checkpoint rules apply"), "the Quick Start note should preserve normal save expectations instead of claiming that the save file cannot change")
	app.guide_close_button.pressed.emit()
	await process_frame
	_expect(not app.guide_view.visible and app.guide_button.has_focus(), "closing the field guide should restore title-menu focus")

	app.veyru_start_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null and app.game_view.state.campaign_region_id == "flooded_veyru" and app.game_view.state.current_location == "lantern_quay", "the title should open Flooded Veyru as a separate chapter at Lantern Quay")
	_expect(app.game_view.high_contrast_enabled and app.game_view.theme.get_stylebox("focus", "Button").border_width_left == 4 and app.game_view.campaign_map.high_contrast_enabled and app.game_view.combat_panel.high_contrast_enabled, "a newly opened playable stage should inherit the persisted contrast mode across controls, map, and combat presentation")
	_expect(app.game_view.controller_layout_id == "east_confirm" and app.game_view.pause_button.text.contains("ESC / A") and app.game_view.focus_chassis_button.tooltip_text.contains("B / Enter") and app.game_view.fortress_panel.controller_cancel_label == "A", "a newly opened playable stage should inherit the remapped face buttons and matching visible instructions")
	var controller_copy_phase: String = app.game_view.state.phase
	app.game_view.state.phase = "results"
	app._refresh_controller_copy()
	_expect(app.pause_hint_label.text == "A / Esc returns to debrief", "changing controller layout should preserve the debrief-specific pause return hint")
	app.game_view.state.phase = controller_copy_phase
	app._refresh_controller_copy()
	var stage_audio_callback := Callable(app.interface_audio, "_on_button_pressed").bind(app.game_view.contract_accept_button)
	_expect(app.game_view.contract_accept_button.pressed.is_connected(stage_audio_callback), "buttons created inside the playable stage should inherit the same interface feedback as title controls")
	_expect(not app.game_view.onboarding_overlay.visible and app.game_view.contract_accept_button.has_focus(), "Veyru should skip the Ashgate briefing and focus its medicine decision")
	app._request_application_close()
	await process_frame
	_expect(app.confirmation_view.visible and app.pending_confirmation == "quit_save" and app.confirmation_title_label.text == "Save before quitting?" and app.confirmation_confirm_button.text == "SAVE & QUIT", "closing a fresh unsaved stage should stop at an explicit local save boundary")
	_expect(app.confirmation_body_label.text.contains("Flooded Veyru at Lantern Quay") and app.confirmation_body_label.text.contains("local Continue slot"), "the close confirmation should name the exact chapter, location, and persistence target")
	app._request_application_close()
	_expect(int(quit_probe["count"]) == 1 and app.confirmation_view.visible and app.pending_confirmation == "quit_save", "a second close request should not bypass or dismiss an open save-before-quit confirmation")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(not app.confirmation_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_INHERIT and app.game_view.contract_accept_button.has_focus(), "cancelling a window close should restore the exact live-stage focus and processing state")
	_expect(app.game_view.contract_title.text == "LANTERN QUAY CONTRACT" and app.game_view.contract_accept_button.text.contains("PARTS CRATE") and app.game_view.campaign_map.button_for("pump_gallery") != null, "the Veyru stage should expose its named carrier and regional map immediately")
	app._show_pause()
	await process_frame
	_expect(app.pause_summary_label.text.begins_with("FLOODED VEYRU · DAY 1 · Lantern Quay") and app.restart_button.tooltip_text.contains("Flooded Veyru"), "Veyru pause context should identify the active chapter before a destructive action")
	app.pause_briefing_button.pressed.emit()
	await process_frame
	_expect(app.game_view.onboarding_overlay.visible and app.game_view.onboarding_title_label.text == "Your job is delivery" and app.game_view.onboarding_body_label.text.contains("Dry Archive") and app.game_view.onboarding_progress_label.text.begins_with("Veyru briefing"), "Veyru's reachable field briefing should open with its own objective and chapter label")
	_expect(app.game_view.onboarding_step_labels[2].text.contains("SUSTAIN") and app.game_view.onboarding_step_labels[4].text.contains("CARRIER") and app.game_view.onboarding_step_labels[5].text.contains("WATER"), "Veyru's briefing rail should teach its actual sustain, carrier, and water decisions")
	app.game_view.onboarding_step = app.game_view.VEYRU_ONBOARDING_STEPS.size() - 1
	app.game_view._refresh_onboarding()
	_expect(app.game_view.onboarding_title_label.text == "Choose what the archive says" and app.game_view.onboarding_body_label.text.contains("broadcasting") and app.game_view.onboarding_next_button.text == "RETURN TO MARCH", "Veyru's final briefing card should explain the archive commitment and return to the current run")
	app.game_view._finish_onboarding(true)
	await process_frame
	app._show_pause()
	await process_frame
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Restart Flooded Veyru?" and app.confirmation_body_label.text.contains("reset to Lantern Quay"), "Veyru restart should name the chapter and its actual starting settlement")
	app.confirmation_cancel_button.pressed.emit()
	app.resume_button.pressed.emit()
	await process_frame
	app.game_view.contract_accept_button.pressed.emit()
	await process_frame
	_expect(app.game_view.state.veyru_contract_status == "accepted" and app.game_view.campaign_path_label.text.contains("Carrier: Parts Crate") and app.game_view.campaign_map.status_for("pump_gallery") == "available", "accepting the medicine contract through the UI should record its carrier and open the Veyru roads")
	app.game_view.state.phase = "results"
	app.game_view.state.run_complete = true
	app.game_view.state.journey_complete = true
	app.game_view.state.final_result = "archive_scarred"
	app.game_view.state.campaign_decisions["archive_broadcast"] = "broadcast_archive"
	app.game_view._refresh_ui()
	_expect(app.game_view.results_record_label.text.contains("PUBLIC ARCHIVE SIGNAL") and app.game_view.results_record_label.text.contains("future Veyru runs reveal Drowned Registry"), "the Veyru debrief should state the regional development and its later route effect")
	app._on_checkpoint_reached("encounter_advanced")
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(PROGRESS_PATH)) and app.campaign_progress.has_development("veyru_public_archive_signal") and app.campaign_progress.result_for_region("flooded_veyru") == "archive_scarred", "surviving after the public broadcast should persist the regional development and Veyru result outside the replaceable Continue slot")
	_expect(app.game_view.march_on_button.text == "MARCH ON · ASHGATE LOWLANDS", "the Veyru debrief should offer the other unfinished chapter as its primary onward path")
	app.game_view.march_on_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_title_label.text == "Continue to Ashgate Lowlands?" and app.confirmation_confirm_button.text == "MARCH ON" and app.confirmation_cancel_button.text == "STAY AT DEBRIEF", "March On should use a chapter-aware, result-preserving confirmation")
	_expect(app.confirmation_body_label.text.contains("result is recorded in the March Charter") and app.confirmation_body_label.text.contains("Continue keeps its current checkpoint"), "March On confirmation should distinguish durable Charter history from the replaceable Continue slot")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(not app.confirmation_view.visible and app.game_view.march_on_button.has_focus() and app.game_view.state.phase == "results", "cancelling March On should restore the intact debrief and onward action")
	app.game_view.play_again_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Replay Flooded Veyru?" and app.confirmation_body_label.text.contains("fresh Flooded Veyru"), "Veyru replay should not describe the replacement run as Ashgate")
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	await process_frame
	var developed_registry: Dictionary = app.game_view.state.campaign_node_preview("drowned_registry")
	_expect(app.game_view.state.campaign_region_id == "flooded_veyru" and app.game_view.state.current_location == "lantern_quay" and app.game_view.state.veyru_contract_status == "offered", "confirming Veyru replay should create another Veyru run at Lantern Quay")
	_expect(app.game_view.state.has_regional_development("veyru_public_archive_signal") and String(developed_registry.get("visibility", "")) == "known" and developed_registry.get("threats", []) == ["Flood Surge", "Climber"], "the replay should apply the earned Public Archive Signal and reveal Drowned Registry's combination contact")
	app.game_view.state.choose_veyru_medicine_contract(false)
	app.game_view.state.current_location = "veyru_evacuation_camp"
	app.game_view.state.journey_node = "veyru_evacuation_camp"
	app.game_view.state.phase = "settlement"
	app.game_view.state.campaign_encounters_completed = 2
	var developed_path: Array[String] = ["lantern_quay", "pump_gallery", "veyru_evacuation_camp"]
	app.game_view.state.campaign_path = developed_path
	app.game_view.state.campaign_last_safe_node = "veyru_evacuation_camp"
	app.game_view._refresh_ui()
	_expect(app.game_view.campaign_map.button_for("drowned_registry").text.contains("KNOWN") and app.game_view.campaign_map.detail_for("drowned_registry").contains("Regional development: Public Archive Signal") and app.game_view.campaign_comparison_label.text.contains("KNOWN · PUBLIC ARCHIVE SIGNAL"), "the later Veyru map should visibly attribute the Registry's exact contact intel to the prior public broadcast")
	_expect(app.game_view.campaign_path_label.text.contains("Public Archive Signal") and app.game_view.campaign_path_label.text.contains("Drowned Registry contacts known"), "the active run status should keep the regional development visible before route selection")
	app._return_to_title()
	await process_frame
	await process_frame
	_expect(app.menu_view.visible and app.game_view == null, "returning from an unsaved Veyru inspection should restore the shared title menu")
	_expect(app.continue_button.text.contains("VEYRU") and app.save_status_label.text.contains("Flooded Veyru") and app.continue_button.tooltip_text.contains("Flooded Veyru"), "a Veyru checkpoint should identify its chapter in the title action, summary, and tooltip")
	_expect(app.title_region_briefing_label.text.contains("PUBLIC ARCHIVE SIGNAL") and app.title_region_briefing_label.text.contains("Drowned Registry contacts are Known") and app.veyru_start_button.tooltip_text.contains("Public Archive Signal is active"), "the title should explain the unlocked regional development before the next Veyru run")
	_expect(app.title_charter_label.text.contains("MARCH CHARTER · 1/2 REGIONS SURVIVED") and app.title_charter_label.text.contains("Veyru Archive Scarred") and app.title_charter_label.text.contains("Next: Ashgate Lowlands"), "the title Charter should retain the best Veyru outcome and direct the player toward the unfinished chapter")
	_expect(not app.quick_start_button.visible, "a returning-player title should collapse the redundant Ashgate quick-start action while the Field Guide retains that path")
	if FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	app._refresh_title_state()

	app.quick_start_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(not app.menu_view.visible and app.game_view != null, "Quick Start should open the playable Ashgate stage")
	_expect(not app.game_view.onboarding_overlay.visible, "Quick Start should skip the briefing for repeated flow tests")
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(ONBOARDING_PATH)), "Quick Start should not permanently mark the briefing complete")
	_expect(app.game_view.contract_accept_button.has_focus(), "Quick Start should focus the first required Ashgate decision")
	_expect(app.game_view.pause_button.visible and app.game_view.pause_button.text.contains("ESC / A"), "the live stage should expose the remapped controller pause action")
	app.game_view.contract_decline_button.grab_focus()
	app.game_view.pause_button.pressed.emit()
	await process_frame
	_expect(app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "the visible stage pause action should open and suspend the march")
	_expect(app.pause_save_status_label.text.contains("No decision checkpoint yet") and app.pause_save_status_label.text.contains("Save March"), "pause should explain how a fresh run receives its first checkpoint instead of only reporting that it is unsaved")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_body_label.text.contains("no usable checkpoint to return to"), "restart should not promise recovery when the current run has never been saved")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
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
	app.title_button.grab_focus()
	app._request_application_close()
	await process_frame
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED and app.title_button.has_focus(), "cancelling window close from Pause should restore the paused context and its exact focused action")
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
	_expect(app.game_view.onboarding_skip_button.text == "SKIP FOR THIS RUN" and app.game_view.onboarding_progress_label.text.contains("A / Esc closes for this run"), "the first-run briefing should describe Skip and the active cancel button as temporary choices")
	app.text_scale_percent = 110
	app._apply_text_scale()
	_expect(app.game_view.theme.default_font_size == 15 and app.game_view.phase_badge.get_theme_font_size("font_size") == 13, "the selected text size should apply to a newly created playable stage and its explicit status text")
	app.text_scale_percent = 100
	app._apply_text_scale()
	app.game_view._finish_onboarding(true)
	await process_frame
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(ONBOARDING_PATH)), "skipping should not permanently mark an unread briefing complete")
	app.game_view._show_onboarding(false)
	await process_frame
	_expect(app.game_view.onboarding_overlay.visible and app.game_view.onboarding_step == 0, "a skipped briefing should remain available from its first card in the current run")

	app.game_view._finish_onboarding(false)
	await process_frame
	var stage_focus_before_pause := app.get_viewport().gui_get_focus_owner()
	app._show_pause()
	await process_frame
	_expect(app.pause_view.visible, "the in-stage menu should pause the march")
	_expect(app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "pausing should block stage input")
	_expect(app.resume_button.has_focus(), "Resume should receive keyboard or controller focus")
	_expect(app.resume_button.get_node_or_null(app.resume_button.focus_neighbor_bottom) == app.pause_save_button and app.pause_save_button.get_node_or_null(app.pause_save_button.focus_neighbor_right) == app.save_return_button, "the pause menu should have explicit directional navigation")
	_expect(app.pause_briefing_button.get_node_or_null(app.pause_briefing_button.focus_neighbor_bottom) == app.pause_notes_button and app.pause_notes_button.get_node_or_null(app.pause_notes_button.focus_neighbor_bottom) == app.restart_button, "pause navigation should include the local playtest-notes action before destructive session controls")
	_expect(app.title_button.get_node_or_null(app.title_button.focus_next) == app.resume_button and app.resume_button.get_node_or_null(app.resume_button.focus_previous) == app.title_button, "the pause menu should trap Tab navigation inside its visible actions")
	_expect(app.pause_summary_label.text.contains("Ashgate Depot") and app.pause_summary_label.text.contains("0/5"), "the pause menu should summarize the current run")
	_expect(app.pause_build_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))), "the pause menu should preserve the tested build identifier")
	var state_before_notes: Dictionary = app.game_view.state.serialize()
	app.pause_notes_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_INHERIT and app.game_view.feedback_overlay.visible, "Playtest Notes should open from Pause without leaving or advancing the run")
	_expect(app.game_view.feedback_close_button.text == "BACK TO PAUSE" and app.game_view.feedback_context_label.text.contains("ASHGATE LOWLANDS · DAY 1 · Ashgate Depot · Refit"), "paused notes should name their exact run context and return destination")
	_expect(app.game_view.feedback_clear_text.has_focus() and app.game_view.feedback_status_label.text.contains("Nothing is sent automatically"), "paused notes should focus the first prompt and retain the local-only privacy statement")
	app.game_view.feedback_confusing_text.text = "I paused at this exact decision."
	var notes_cancel_input := InputEventJoypadButton.new()
	notes_cancel_input.button_index = JOY_BUTTON_A
	notes_cancel_input.pressed = true
	app.game_view._unhandled_input(notes_cancel_input)
	await process_frame
	_expect(not app.game_view.feedback_overlay.visible and app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED and app.pause_notes_button.has_focus(), "controller cancel should return paused notes to the suspended pause menu")
	_expect(app._saved_values_match(state_before_notes, app.game_view.state.serialize()), "opening and closing paused notes should not mutate deterministic campaign state")
	app.pause_notes_button.pressed.emit()
	await process_frame
	_expect(app.game_view.feedback_confusing_text.text == "I paused at this exact decision.", "unsaved note text should survive a pause-menu round trip during the same stage")
	app.game_view.feedback_close_button.pressed.emit()
	await process_frame
	_expect(app.pause_view.visible and app.pause_notes_button.has_focus(), "the visible Back to Pause action should restore the notes entry point")
	app.resume_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.get_viewport().gui_get_focus_owner() == stage_focus_before_pause, "resuming after paused notes should restore the exact stage control focused before Pause")
	app._show_pause()
	await process_frame
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
	_expect(app.reset_charter_button.disabled and app.reset_charter_button.text.contains("RETURN TO TITLE"), "paused Settings should not erase persistent history beneath an active run snapshot")
	_expect(app.reset_playtest_button.disabled and app.reset_playtest_button.text.contains("RETURN TO TITLE"), "paused Settings should not reset local playtest data beneath an active run")
	_expect(not app.reset_briefing_button.disabled, "a completed briefing should expose its one-shot reset action")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.data_info_button and app.data_info_button.get_node_or_null(app.data_info_button.focus_neighbor_bottom) == app.reset_briefing_button and app.reset_briefing_button.get_node_or_null(app.reset_briefing_button.focus_neighbor_bottom) == app.clear_save_button, "Settings navigation should include build information and available one-shot actions in order")
	app.data_info_button.pressed.emit()
	await process_frame
	_expect(app.data_info_view.visible and app.data_info_context_label.text.begins_with("PAUSED MARCH") and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "build information opened during a run should retain paused context and keep the stage suspended")
	var paused_data_cancel := InputEventJoypadButton.new()
	paused_data_cancel.button_index = JOY_BUTTON_A
	paused_data_cancel.pressed = true
	app._unhandled_input(paused_data_cancel)
	await process_frame
	_expect(not app.data_info_view.visible and app.settings_view.visible and app.data_info_button.has_focus() and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "the remapped cancel button should return from build information to paused Settings without resuming play")
	app.text_scale_button.pressed.emit()
	await process_frame
	await process_frame
	app.clear_save_button.grab_focus()
	await process_frame
	var lower_scroll_rect: Rect2 = app.settings_scroll.get_global_rect()
	var lower_button_rect: Rect2 = app.clear_save_button.get_global_rect()
	_expect(app.text_scale_percent == 110 and lower_button_rect.position.y >= lower_scroll_rect.position.y and lower_button_rect.end.y <= lower_scroll_rect.end.y, "large-text controller focus should scroll the lowest available Settings action fully into view")
	app.text_scale_button.pressed.emit()
	await process_frame
	await process_frame
	app.autosave_button.grab_focus()
	app._request_application_close()
	await process_frame
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and not app.pause_view.visible and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED and app.autosave_button.has_focus(), "cancelling window close from paused Settings should preserve both the overlay and disabled stage state")
	app.reset_briefing_button.pressed.emit()
	await process_frame
	_expect(app.reset_briefing_button.disabled and app.settings_close_button.has_focus(), "resetting the briefing should move focus to an enabled return action")
	_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.data_info_button and app.data_info_button.get_node_or_null(app.data_info_button.focus_neighbor_bottom) == app.clear_save_button and app.clear_save_button.get_node_or_null(app.clear_save_button.focus_neighbor_top) == app.data_info_button, "Settings navigation should reroute immediately after a one-shot action becomes unavailable")
	var cancel_input := InputEventJoypadButton.new()
	cancel_input.button_index = JOY_BUTTON_A
	cancel_input.pressed = true
	app._unhandled_input(cancel_input)
	await process_frame
	_expect(not app.settings_view.visible and app.pause_view.visible and app.pause_settings_button.has_focus(), "cancelling in-run Settings should close it and return to the pause menu")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible, "restart should require confirmation before discarding progress")
	_expect(app.confirmation_body_label.text.contains("Day 1 at Ashgate Depot in Ashgate Lowlands checkpoint") and app.confirmation_body_label.text.contains("automatic checkpoint"), "restart should name the protected checkpoint, chapter, and when autosave will replace it")
	_expect(app.confirmation_cancel_button.get_node_or_null(app.confirmation_cancel_button.focus_neighbor_right) == app.confirmation_confirm_button, "confirmation actions should have explicit horizontal controller navigation")
	_expect(app.confirmation_cancel_button.get_node_or_null(app.confirmation_cancel_button.focus_neighbor_top) == app.confirmation_cancel_button and app.confirmation_confirm_button.get_node_or_null(app.confirmation_confirm_button.focus_next) == app.confirmation_cancel_button, "confirmation dialogs should trap directional and Tab focus")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	app.pause_save_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)), "Save March should create the local save from the pause menu")
	_expect(app.pause_save_status_label.text.begins_with("Saved."), "the pause menu should confirm a successful save")
	_expect(app.game_view.event_label.text.contains("March saved locally") and not app.game_view.event_label.text.contains("schema version"), "resuming after a manual save should show a player-facing receipt rather than serialization internals")
	_expect(app.title_button.text == "RETURN TO TITLE", "saving should make the safe return action explicit")
	_expect(not app.title_button.has_theme_stylebox_override("normal"), "saving should remove the destructive warning treatment from Return to Title")
	app.autosave_enabled = false
	app._refresh_pause_summary()
	_expect(app.pause_save_status_label.text.begins_with("Current decision is saved") and app.pause_save_status_label.text.contains("autosave remains off"), "an autosave-disabled pause should still acknowledge a matching manual save")
	app.autosave_enabled = true
	app._refresh_pause_summary()
	app.title_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.menu_view.visible and not app.confirmation_view.visible, "a fully saved run should return to title without a redundant warning")
	app.continue_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null, "Continue should restore the run after a safe return")
	_expect(app.game_view.event_label.text == "March restored from the local checkpoint.", "Continue should confirm restoration in player-facing campaign language")
	app._show_pause()
	_expect(app.pause_save_status_label.text == "Current decision matches the loaded checkpoint.", "pausing immediately after Continue should describe the loaded checkpoint without awkward saved-save wording")
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
	_expect(app.save_status_label.text.contains("Next · Answer convoy contract") and app.save_status_label.text.contains("Fuel 6"), "the active checkpoint summary should identify the exact decision waiting after Continue without losing resource context")
	_expect(app.continue_button.get_index() < app.start_button.get_index() and app.continue_button.get_node_or_null(app.continue_button.focus_neighbor_bottom) == app.start_button, "a valid save should place Continue first visually and route downward into fresh-start actions")
	_expect(app.continue_button.get_node_or_null(app.continue_button.focus_next) == app.start_button and app.start_button.get_node_or_null(app.start_button.focus_next) == app.veyru_start_button and app.veyru_start_button.get_node_or_null(app.veyru_start_button.focus_next) == app.guide_button, "save-aware Tab navigation should follow Continue, guided Ashgate, Veyru, then utility actions")
	_expect(app.start_button.text.begins_with("NEW ASHGATE") and not app.quick_start_button.visible, "existing progress should keep one clear Ashgate start on the title instead of crowding out checkpoint details")
	_expect(app.continue_button.has_focus(), "a valid save should make Continue the default title action")
	_expect(app.continue_button.text.contains("DAY 1") and app.continue_button.text.contains("ASHGATE DEPOT"), "Continue should identify the saved day and location before loading")
	_expect(app.save_status_label.text.contains("Watch") and app.save_status_label.text.contains("Refit") and app.save_status_label.text.contains("0/5"), "the title should identify checkpoint condition, phase, and encounter progress")
	_expect(app.save_status_label.text.contains("Saved just now"), "the title should show how recently the local checkpoint was written")
	_expect(app.save_status_label.text.contains("Fuel 6") and app.save_status_label.text.contains("Hull 10/10") and app.save_status_label.text.contains("Heat 5/6"), "the title should summarize the saved fortress condition")
	_expect(app.continue_button.tooltip_text.contains(String(ProjectSettings.get_setting("application/config/version"))), "Continue should expose the build that created the checkpoint")
	_expect(app.guide_quick_start_button.text == "START NEW ASHGATE RUN", "the Field Guide should identify that Quick Start begins a different run when progress exists")
	app.guide_button.pressed.emit()
	app.guide_quick_start_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.guide_view.visible, "Quick Start from the Field Guide should protect the existing checkpoint")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.guide_view.visible and app.guide_quick_start_button.has_focus(), "cancelling a guide-launched Quick Start should restore focus inside the visible guide")
	app.guide_close_button.pressed.emit()
	await process_frame
	var saved_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	_expect(saved_payload is Dictionary and String(saved_payload.get("build_version", "")) == String(ProjectSettings.get_setting("application/config/version")), "campaign saves should record their exact application build")
	_expect(saved_payload is Dictionary and int(saved_payload.get("saved_at_unix", 0)) > 0, "campaign saves should record when the checkpoint was created")
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_BACKUP_PATH)), "overwriting a valid checkpoint should preserve its predecessor as a local recovery backup")
	var backup_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_BACKUP_PATH))
	_expect(backup_payload is Dictionary and bool(LongMarchState.new(0).load_serialized(backup_payload).get("ok", false)), "the recovery backup should contain a fully validated campaign state")
	var corrupt_primary := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt_primary.store_string("{broken primary checkpoint")
	corrupt_primary.close()
	app._refresh_title_state()
	_expect(app.save_recovery_button.visible and app.save_recovery_button.text.begins_with("RESTORE BACKUP") and app.save_status_label.text.contains("Valid backup available"), "a corrupt primary save should offer its valid backup instead of only deletion")
	app.save_recovery_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Restore the backup?" and app.confirmation_body_label.text.contains("broken file will be discarded") and app.confirmation_cancel_button.text == "KEEP FILES", "backup recovery should require a precise replacement confirmation")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.save_recovery_button.has_focus() and FileAccess.get_file_as_string(SAVE_PATH).begins_with("{broken"), "cancelling backup recovery should preserve both files and restore focus")
	app.save_recovery_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	var restored_backup_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	_expect(restored_backup_payload == backup_payload and app.continue_button.visible and app.continue_button.has_focus(), "confirmed backup recovery should restore the exact validated predecessor and re-enable Continue")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	app._refresh_title_state()
	_expect(app.save_recovery_button.visible and app.save_recovery_button.text.begins_with("RESTORE BACKUP") and not app.continue_button.visible, "a missing primary should also expose the validated backup without silently enabling Continue")
	app.save_recovery_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and app.continue_button.visible, "backup recovery should rebuild a missing primary checkpoint after confirmation")
	var current_after_recovery := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	current_after_recovery.store_string(JSON.stringify(saved_payload))
	current_after_recovery.close()
	var legacy_title_payload: Dictionary = saved_payload.duplicate(true)
	legacy_title_payload["save_version"] = 7
	legacy_title_payload.erase("regional_developments")
	var legacy_title_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	legacy_title_save.store_string(JSON.stringify(legacy_title_payload))
	legacy_title_save.close()
	var legacy_title_info: Dictionary = app._saved_run_info()
	_expect(bool(legacy_title_info.get("valid", false)) and String(legacy_title_info.get("action", "")).contains("ASHGATE"), "the title should continue to load schema-7 checkpoints while migrating an empty development snapshot")
	var current_title_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	current_title_save.store_string(JSON.stringify(saved_payload))
	current_title_save.close()
	var completed_payload: Dictionary = saved_payload.duplicate(true)
	completed_payload["phase"] = "results"
	completed_payload["final_result"] = "scarred_march"
	completed_payload["run_complete"] = true
	completed_payload["journey_complete"] = true
	completed_payload["current_location"] = "meridian_pass"
	completed_payload["campaign_encounters_completed"] = 5
	var completed_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	completed_save.store_string(JSON.stringify(completed_payload))
	completed_save.close()
	var completed_info: Dictionary = app._saved_run_info()
	_expect(String(completed_info.get("action", "")).begins_with("VIEW RESULT · SCARRED MARCH"), "a completed save should be presented as a debrief rather than active gameplay")
	_expect(String(completed_info.get("summary", "")).contains("Completed run · Scarred March · 5/5"), "the title summary should identify a completed run and its outcome")
	_expect(bool(completed_info.get("completed", false)) and String(completed_info.get("result", "")) == "Scarred March", "completed checkpoint metadata should remain available to title actions")
	var invalid_result_payload: Dictionary = completed_payload.duplicate(true)
	invalid_result_payload["final_result"] = "unknown_result"
	var invalid_result_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_result_file.store_string(JSON.stringify(invalid_result_payload))
	invalid_result_file.close()
	var invalid_result_info: Dictionary = app._saved_run_info()
	_expect(not bool(invalid_result_info.get("valid", true)) and String(invalid_result_info.get("summary", "")).contains("recognized outcome"), "the title should reject a result checkpoint whose terminal outcome cannot be interpreted")
	var incomplete_result_payload: Dictionary = completed_payload.duplicate(true)
	incomplete_result_payload["run_complete"] = false
	var incomplete_result_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	incomplete_result_file.store_string(JSON.stringify(incomplete_result_payload))
	incomplete_result_file.close()
	var incomplete_result_info: Dictionary = app._saved_run_info()
	_expect(not bool(incomplete_result_info.get("valid", true)) and String(incomplete_result_info.get("summary", "")).contains("completion state"), "the title should reject a named result that was not recorded as a completed run")
	var unknown_phase_payload: Dictionary = completed_payload.duplicate(true)
	unknown_phase_payload["phase"] = "lost_between_roads"
	unknown_phase_payload["final_result"] = ""
	unknown_phase_payload["run_complete"] = false
	unknown_phase_payload["journey_complete"] = false
	var unknown_phase_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	unknown_phase_file.store_string(JSON.stringify(unknown_phase_payload))
	unknown_phase_file.close()
	var unknown_phase_info: Dictionary = app._saved_run_info()
	_expect(not bool(unknown_phase_info.get("valid", true)) and String(unknown_phase_info.get("summary", "")).contains("unknown campaign phase"), "the title should route unknown campaign phases through unusable-save recovery")
	var invalid_decision_payload: Dictionary = completed_payload.duplicate(true)
	invalid_decision_payload["campaign_decisions"] = {"lost_signal": "sell_the_relay"}
	var invalid_decision_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_decision_file.store_string(JSON.stringify(invalid_decision_payload))
	invalid_decision_file.close()
	var invalid_decision_info: Dictionary = app._saved_run_info()
	_expect(not bool(invalid_decision_info.get("valid", true)) and String(invalid_decision_info.get("summary", "")).contains("unknown choice"), "the title should reject a checkpoint whose authored decision history cannot be trusted")
	var impossible_path_payload: Dictionary = completed_payload.duplicate(true)
	impossible_path_payload["campaign_path"] = ["ashgate_depot", "signal_causeway", "meridian_pass"]
	impossible_path_payload["campaign_last_safe_node"] = "meridian_pass"
	var impossible_path_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	impossible_path_file.store_string(JSON.stringify(impossible_path_payload))
	impossible_path_file.close()
	var impossible_path_info: Dictionary = app._saved_run_info()
	_expect(not bool(impossible_path_info.get("valid", true)) and String(impossible_path_info.get("summary", "")).contains("impossible route"), "the title should reject a checkpoint whose secured route could not occur on the authored map")
	var invalid_chassis_payload: Dictionary = completed_payload.duplicate(true)
	invalid_chassis_payload["modules"][0]["id"] = "miracle_engine"
	var invalid_chassis_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_chassis_file.store_string(JSON.stringify(invalid_chassis_payload))
	invalid_chassis_file.close()
	var invalid_chassis_info: Dictionary = app._saved_run_info()
	_expect(not bool(invalid_chassis_info.get("valid", true)) and String(invalid_chassis_info.get("summary", "")).contains("unknown system"), "the title should reject a checkpoint containing a system that does not exist")
	var invalid_encounter_payload: Dictionary = completed_payload.duplicate(true)
	invalid_encounter_payload["encounter_enemies"] = [{"id": "developer_dragon", "hp": 1, "max_hp": 1, "slot": 0}]
	var invalid_encounter_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	invalid_encounter_file.store_string(JSON.stringify(invalid_encounter_payload))
	invalid_encounter_file.close()
	var invalid_encounter_info: Dictionary = app._saved_run_info()
	_expect(not bool(invalid_encounter_info.get("valid", true)) and String(invalid_encounter_info.get("summary", "")).contains("unknown threat"), "the title should reject a checkpoint containing an unauthored encounter threat")
	completed_save = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	completed_save.store_string(JSON.stringify(completed_payload))
	completed_save.close()
	app._refresh_title_state()
	_expect(app.start_button.text == "PLAY ASHGATE · GUIDED BRIEFING" and app.quick_start_button.text == "REPLAY ASHGATE · SKIP BRIEFING", "a completed checkpoint should offer Ashgate replay actions instead of implying an unfinished new game")
	_expect(app.guide_quick_start_button.text == "QUICK REPLAY ASHGATE", "the Field Guide action should use the same completed-run vocabulary as the title")
	app.start_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Begin another march?" and app.confirmation_confirm_button.text == "PLAY AGAIN", "starting from a completed title checkpoint should use replay confirmation language")
	_expect(app.confirmation_cancel_button.text == "KEEP RESULT" and app.confirmation_body_label.text.contains("Scarred March result"), "replay confirmation should identify the completed result being preserved")
	app.confirmation_cancel_button.pressed.emit()
	var restored_active_save := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	restored_active_save.store_string(JSON.stringify(saved_payload))
	restored_active_save.close()
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
		_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and not FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_BACKUP_PATH)) and not app.continue_button.visible and app.continue_button.disabled, "confirmed save clearing should remove Continue and its recovery backup from the title action stack")
		_expect(app.clear_save_button.disabled and app.settings_close_button.has_focus(), "clearing the save should move focus away from the newly disabled action")
		_expect(app.autosave_button.get_node_or_null(app.autosave_button.focus_neighbor_bottom) == app.data_info_button and app.data_info_button.get_node_or_null(app.data_info_button.focus_neighbor_bottom) == app.reset_charter_button and app.reset_charter_button.get_node_or_null(app.reset_charter_button.focus_neighbor_bottom) == app.reset_playtest_button and app.reset_playtest_button.get_node_or_null(app.reset_playtest_button.focus_neighbor_bottom) == app.settings_close_button, "clearing Continue should leave build information and the independent Charter and clean-start resets in the Settings focus path")

	app._open_stage(false, false)
	await process_frame
	await process_frame
	app.game_view.state.phase = "results"
	app.game_view.state.final_result = "scarred_march"
	app.game_view.state.run_complete = true
	app.game_view.state.journey_complete = true
	app.game_view._refresh_ui()
	app._show_pause()
	await process_frame
	_expect(app.pause_eyebrow_label.text == "FINAL REPORT" and app.pause_title_label.text == "DEBRIEF OPTIONS", "opening session options from results should use completed-run framing")
	_expect(app.pause_detail_label.text.contains("march has ended") and app.resume_button.text == "RETURN TO DEBRIEF" and app.pause_save_button.text == "SAVE RESULT" and app.restart_button.text == "PLAY AGAIN" and app.pause_hint_label.text.contains("returns to debrief"), "the completed-run overlay should describe its actual return, save, and replay actions")
	_expect(app.pause_save_status_label.text.contains("result is not saved yet") and app.pause_save_status_label.text.contains("Save Result"), "an unsaved debrief should name the result-specific persistence action instead of asking for another campaign decision")
	app.restart_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.pause_view.visible and app.confirmation_title_label.text == "Replay Ashgate Lowlands?" and app.confirmation_confirm_button.text == "PLAY AGAIN", "Play Again from debrief options should identify the active chapter in its result-aware confirmation")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(not app.confirmation_view.visible and app.pause_view.visible and app.restart_button.has_focus() and app.game_view.process_mode == Node.PROCESS_MODE_DISABLED, "cancelling a debrief-options replay should return focus to the paused overlay")
	app.resume_button.pressed.emit()
	await process_frame
	_expect(not app.pause_view.visible and app.game_view.state.phase == "results", "returning from debrief options should preserve the completed result")
	app.game_view.play_again_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_title_label.text == "Replay Ashgate Lowlands?" and app.confirmation_confirm_button.text == "PLAY AGAIN" and app.confirmation_cancel_button.text == "KEEP RESULT", "Play Again should require an explicit chapter-aware result-preserving confirmation")
	_expect(app.confirmation_body_label.text.contains("This result is not saved under Continue") and app.confirmation_body_label.text.contains("fresh Ashgate checkpoint immediately"), "replay confirmation should not claim an unsaved result already exists under Continue")
	_expect(app.game_view.state.phase == "results", "opening replay confirmation should preserve the completed run")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(not app.confirmation_view.visible and app.game_view.state.phase == "results" and app.game_view.play_again_button.has_focus(), "cancelling replay should return to the intact result action")
	_expect(app.game_view.save_run(true), "the replay confirmation test should be able to persist the completed result")
	app._show_pause()
	await process_frame
	_expect(app.pause_save_status_label.text == "This result is saved under Continue.", "a saved debrief should identify the completed result available from Continue")
	app.resume_button.pressed.emit()
	await process_frame
	app.game_view.play_again_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_body_label.text.contains("completed result is saved under Continue") and app.confirmation_body_label.text.contains("replace it with a fresh Ashgate checkpoint"), "autosave replay should identify the saved result it will immediately replace")
	app.confirmation_cancel_button.pressed.emit()
	app.autosave_enabled = false
	app.game_view.play_again_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_body_label.text.contains("completed result remains under Continue until you save the fresh Ashgate run"), "manual-save replay should explain that the saved result remains until another explicit save")
	app.confirmation_cancel_button.pressed.emit()
	app.autosave_enabled = true
	app.game_view.play_again_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	var replay_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	_expect(app.last_checkpoint_reason == "new_run_started", "the application shell should identify the replay checkpoint")
	_expect(replay_payload is Dictionary and String(replay_payload.get("phase", "")) == "refit" and String(replay_payload.get("guard_contract_status", "")) == "offered", "Play Again should replace a completed autosave with the fresh Ashgate state immediately")
	app.game_view.state.phase = "results"
	app.game_view.state.final_result = "scarred_march"
	app.game_view.state.run_complete = true
	app.game_view.state.journey_complete = true
	app._on_checkpoint_reached("encounter_advanced")
	app.game_view._refresh_ui()
	_expect(app.campaign_progress.survived_region_count() == 2 and app.campaign_progress.result_for_region("ashgate_lowlands") == "scarred_march", "surviving both chapters should complete the bounded March Charter")
	_expect(app.game_view.march_on_button.text == "REVISIT · FLOODED VEYRU", "after both regions survive, the debrief should frame March On as a deliberate revisit")
	app.game_view.march_on_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view.state.campaign_region_id == "flooded_veyru" and app.game_view.state.current_location == "lantern_quay" and app.game_view.state.has_regional_development("veyru_public_archive_signal"), "confirming March On should open the other chapter and carry durable regional developments into it")
	app.game_view.state.money += 3
	app.autosave_enabled = false
	app._request_application_close()
	await process_frame
	_expect(app.confirmation_view.visible and app.confirmation_body_label.text.contains("unsaved changes"), "window close should protect unsaved stage changes even when automatic checkpoints are disabled")
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	var close_payload = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	_expect(int(quit_probe["count"]) == 2 and close_payload is Dictionary and String(close_payload.get("campaign_region_id", "")) == "flooded_veyru" and int(close_payload.get("money", 0)) == app.game_view.state.money, "Save & Quit should flush the exact live state before requesting application exit")
	app._request_application_close()
	_expect(int(quit_probe["count"]) == 3 and not app.confirmation_view.visible, "a close request should quit immediately once the live stage matches the durable checkpoint")
	app._return_to_title()
	await process_frame
	await process_frame
	app.settings_button.pressed.emit()
	await process_frame
	_expect(not app.reset_charter_button.disabled and app.reset_charter_button.text.contains("AVAILABLE"), "title Settings should expose Charter reset when persistent regional history exists")
	app.reset_charter_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Reset the March Charter?" and app.confirmation_body_label.text.contains("Public Archive Signal") and app.confirmation_body_label.text.contains("Continue, settings, and briefing progress remain unchanged") and app.confirmation_confirm_button.text == "RESET CHARTER" and app.confirmation_cancel_button.text == "KEEP CHARTER", "Charter reset should require a precise confirmation that distinguishes every local data category")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and app.reset_charter_button.has_focus() and FileAccess.file_exists(ProjectSettings.globalize_path(PROGRESS_PATH)), "cancelling Charter reset should preserve the record and return focus to its Settings action")
	app.reset_charter_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(PROGRESS_PATH)) and app.campaign_progress.developments.is_empty() and app.campaign_progress.region_results.is_empty(), "confirmed Charter reset should clear both regional developments and chapter results")
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(SAVE_PATH)) and FileAccess.file_exists(ProjectSettings.globalize_path(SETTINGS_PATH)), "Charter reset should preserve the independent Continue save and settings file")
	_expect(app.reset_charter_button.disabled and app.settings_status_label.text.contains("Continue, settings, and briefing progress were kept") and app.settings_close_button.has_focus(), "successful Charter reset should report what was preserved and move focus to an enabled action")
	app.settings_close_button.pressed.emit()
	await process_frame
	_expect(app.title_charter_label.text.contains("MARCH CHARTER · 0/2 REGIONS SURVIVED") and not app.veyru_start_button.tooltip_text.contains("Public Archive Signal is active"), "the title should immediately return to a clean Charter and remove development-specific guidance")

	app.settings_button.pressed.emit()
	await process_frame
	app.text_scale_button.pressed.emit()
	if app.autosave_enabled:
		app.autosave_button.pressed.emit()
	var onboarding_marker := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
	onboarding_marker.store_string("completed")
	onboarding_marker.close()
	var journal_file := FileAccess.open(JOURNAL_PATH, FileAccess.WRITE)
	journal_file.store_string("{\"events\":[]}")
	journal_file.close()
	var feedback_file := FileAccess.open(FEEDBACK_PRESERVE_PATH, FileAccess.WRITE)
	feedback_file.store_string("tester-owned export")
	feedback_file.close()
	_expect(bool(app.campaign_progress.unlock("veyru_public_archive_signal").get("ok", false)), "the clean-reset test should recreate a persistent regional development")
	app._refresh_title_state()
	app._refresh_settings()
	_expect(not app.reset_playtest_button.disabled and app.reset_playtest_button.text.contains("AVAILABLE") and app.reset_playtest_button.has_theme_stylebox_override("normal"), "title Settings should expose the clean-start reset as a distinct destructive action when local state exists")
	app.reset_playtest_button.pressed.emit()
	await process_frame
	_expect(app.confirmation_title_label.text == "Start with clean playtest data?" and app.confirmation_confirm_button.text == "RESET PLAYTEST DATA" and app.confirmation_cancel_button.text == "KEEP LOCAL DATA", "clean-start reset should require an unmistakable confirmation")
	_expect(app.confirmation_body_label.text.contains("Continue and its backup") and app.confirmation_body_label.text.contains("current local journal") and app.confirmation_body_label.text.contains("Exported playtest reports remain"), "the clean-start confirmation should enumerate removed and preserved data")
	app.confirmation_cancel_button.pressed.emit()
	await process_frame
	_expect(app.settings_view.visible and app.reset_playtest_button.has_focus() and FileAccess.file_exists(SAVE_PATH) and FileAccess.file_exists(PROGRESS_PATH) and FileAccess.file_exists(FEEDBACK_PRESERVE_PATH), "cancelling clean-start reset should preserve every local data category and restore focus")
	app.reset_playtest_button.pressed.emit()
	await process_frame
	app.confirmation_confirm_button.pressed.emit()
	await process_frame
	for cleared_path in [SAVE_PATH, SAVE_BACKUP_PATH, ONBOARDING_PATH, JOURNAL_PATH, SETTINGS_PATH, PROGRESS_PATH]:
		_expect(not FileAccess.file_exists(cleared_path), "clean-start reset should remove %s" % cleared_path.get_file())
	_expect(FileAccess.file_exists(FEEDBACK_PRESERVE_PATH) and FileAccess.get_file_as_string(FEEDBACK_PRESERVE_PATH) == "tester-owned export", "clean-start reset should preserve previously exported playtest reports exactly")
	_expect(not app.fullscreen_enabled and app.text_scale_percent == 100 and not app.high_contrast_enabled and app.title_veil.color.a < 0.5 and app.controller_layout_id == "south_confirm" and InputMap.event_is_action(_joy_button_for_test(JOY_BUTTON_A), "ui_accept") and InputMap.event_is_action(_joy_button_for_test(JOY_BUTTON_B), "ui_cancel") and not app.reduced_motion and app.interface_audio_percent == 70 and app.interface_audio.volume_percent == 70 and app.autosave_enabled and app.theme.default_font_size == 16, "clean-start reset should immediately restore every device preference default")
	_expect(app.campaign_progress.developments.is_empty() and app.campaign_progress.region_results.is_empty() and app.title_charter_label.text.contains("0/2 REGIONS SURVIVED"), "clean-start reset should rebuild an empty in-memory March Charter")
	_expect(not app.continue_button.visible and app.quick_start_button.visible and app.start_button.text.contains("GUIDED FIRST RUN"), "clean-start reset should immediately restore the first-launch title flow")
	_expect(app.reset_playtest_button.disabled and app.settings_status_label.text.contains("Exported feedback reports were kept") and app.settings_close_button.has_focus(), "successful clean-start reset should disable itself, report preservation, and focus an enabled return action")

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

func _joy_button_for_test(button_index: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = true
	return event
