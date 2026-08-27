class_name LongMarchApp
extends Control

const GAME_SCENE = preload("res://scenes/Main.tscn")
const LongMarchState = preload("res://src/core/fortress_state.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const CHECKPOINT_LABELS := {
	"contract_answered": "Contract decision",
	"route_started": "Route committed",
	"event_resolved": "Event resolved",
	"specialist_recruited": "Specialist recruited",
	"module_moved": "Chassis updated",
	"module_installed": "Module installed",
	"module_rotated": "Module rotated",
	"module_stored": "Module stored",
	"encounter_advanced": "Battle step",
	"settlement_service": "Recovery action",
	"intervention_used": "Emergency order",
	"manual save": "Manual save",
	"loaded save": "Loaded save"
}

var menu_view: Control
var guide_view: Control
var settings_view: Control
var pause_view: Control
var confirmation_view: Control
var checkpoint_toast: PanelContainer
var checkpoint_toast_label: Label
var game_view: Control
var start_button: Button
var quick_start_button: Button
var continue_button: Button
var save_recovery_button: Button
var guide_button: Button
var settings_button: Button
var quit_button: Button
var guide_close_button: Button
var guide_quick_start_button: Button
var settings_context_label: Label
var settings_close_button: Button
var display_mode_button: Button
var motion_button: Button
var autosave_button: Button
var reset_briefing_button: Button
var clear_save_button: Button
var settings_status_label: Label
var resume_button: Button
var pause_summary_label: Label
var pause_save_status_label: Label
var pause_save_button: Button
var save_return_button: Button
var pause_briefing_button: Button
var pause_settings_button: Button
var restart_button: Button
var title_button: Button
var title_build_label: Label
var pause_build_label: Label
var confirmation_title_label: Label
var confirmation_body_label: Label
var confirmation_confirm_button: Button
var confirmation_cancel_button: Button
var save_status_label: Label
var pending_confirmation: String = ""
var paused_stage_focus: Control
var fullscreen_enabled: bool = false
var reduced_motion: bool = false
var autosave_enabled: bool = true
var settings_opened_from_pause: bool = false
var last_checkpoint_reason: String = ""
var checkpoint_toast_tween: Tween

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 12) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _create_menu_theme() -> Theme:
	var menu_theme := Theme.new()
	menu_theme.default_font_size = 16
	for control_type in ["Button", "OptionButton"]:
		menu_theme.set_stylebox("normal", control_type, _flat_style(Color("#182329e8"), Color("#59696d"), 1, 6, 12))
		menu_theme.set_stylebox("hover", control_type, _flat_style(Color("#273b40f2"), Color("#79cfc3"), 2, 6, 11))
		menu_theme.set_stylebox("pressed", control_type, _flat_style(Color("#111a1ff2"), Color("#f0cf96"), 2, 6, 11))
		menu_theme.set_stylebox("focus", control_type, _flat_style(Color("#24373cf2"), Color("#f3dfad"), 3, 6, 10))
		menu_theme.set_stylebox("disabled", control_type, _flat_style(Color("#12191ddb"), Color("#354146"), 1, 6, 12))
		menu_theme.set_color("font_color", control_type, Color("#eef3ef"))
		menu_theme.set_color("font_hover_color", control_type, Color("#ffffff"))
		menu_theme.set_color("font_pressed_color", control_type, Color("#fff1ce"))
		menu_theme.set_color("font_focus_color", control_type, Color("#ffffff"))
		menu_theme.set_color("font_disabled_color", control_type, Color("#6c777a"))
	return menu_theme

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_preferences()
	_apply_display_mode()
	theme = _create_menu_theme()
	_build_title_menu()
	_build_guide_overlay()
	_build_settings_overlay()
	_build_pause_menu()
	_build_confirmation_overlay()
	_build_checkpoint_toast()
	_configure_overlay_focus()
	_refresh_title_state()
	_focus_title_primary()

func _build_title_menu() -> void:
	menu_view = Control.new()
	menu_view.name = "TitleMenu"
	menu_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_view)

	var background := TextureRect.new()
	background.texture = JOURNEY_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_view.add_child(background)

	var veil := ColorRect.new()
	veil.color = Color(0.025, 0.035, 0.037, 0.48)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_view.add_child(veil)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 58)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_right", 58)
	margin.add_theme_constant_override("margin_bottom", 36)
	menu_view.add_child(margin)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 42)
	margin.add_child(columns)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(570, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	columns.add_child(left)

	title_build_label = Label.new()
	title_build_label.text = "ASHGATE LOWLANDS · PLAYABLE ALPHA · %s" % _build_version()
	title_build_label.add_theme_font_size_override("font_size", 13)
	title_build_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	left.add_child(title_build_label)

	var title := Label.new()
	title.text = "THE LONG\nMARCH"
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	title.add_theme_constant_override("line_spacing", -10)
	left.add_child(title)

	var promise := Label.new()
	promise.text = "KEEP THE FORTRESS MOVING.\nKEEP ITS PROMISES."
	promise.add_theme_font_size_override("font_size", 18)
	promise.add_theme_color_override("font_color", Color("#d7dfd9"))
	left.add_child(promise)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)

	var action_panel := PanelContainer.new()
	action_panel.custom_minimum_size = Vector2(500, 0)
	action_panel.add_theme_stylebox_override("panel", _flat_style(Color("#0d1519e8"), Color("#8d7655"), 1, 8, 18))
	left.add_child(action_panel)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	action_panel.add_child(actions)

	start_button = Button.new()
	start_button.name = "StartGameButton"
	start_button.text = "START GAME  ·  GUIDED FIRST RUN"
	start_button.custom_minimum_size = Vector2(0, 62)
	start_button.tooltip_text = "Begin at Ashgate Depot with the four-part Marchmaster briefing."
	start_button.pressed.connect(_start_new_game)
	_accent_button(start_button)
	actions.add_child(start_button)

	quick_start_button = Button.new()
	quick_start_button.name = "QuickStartButton"
	quick_start_button.text = "QUICK START  ·  SKIP BRIEFING"
	quick_start_button.custom_minimum_size = Vector2(0, 50)
	quick_start_button.tooltip_text = "Open a fresh Ashgate stage immediately without changing the saved briefing preference."
	quick_start_button.pressed.connect(_quick_start_game)
	actions.add_child(quick_start_button)

	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.custom_minimum_size = Vector2(0, 52)
	continue_button.tooltip_text = "Load the last locally saved fortress state."
	continue_button.pressed.connect(_continue_game)
	actions.add_child(continue_button)
	save_recovery_button = Button.new()
	save_recovery_button.name = "SaveRecoveryButton"
	save_recovery_button.text = "REMOVE UNREADABLE SAVE"
	save_recovery_button.custom_minimum_size = Vector2(0, 44)
	save_recovery_button.tooltip_text = "Remove the local save that cannot be loaded."
	save_recovery_button.visible = false
	save_recovery_button.pressed.connect(_request_confirmation.bind("clear_invalid_save"))
	actions.add_child(save_recovery_button)

	var utility_actions := HBoxContainer.new()
	utility_actions.add_theme_constant_override("separation", 8)
	actions.add_child(utility_actions)
	guide_button = Button.new()
	guide_button.name = "GuideButton"
	guide_button.text = "FIELD GUIDE"
	guide_button.custom_minimum_size = Vector2(0, 44)
	guide_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_button.pressed.connect(_show_guide)
	utility_actions.add_child(guide_button)
	settings_button = Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "SETTINGS"
	settings_button.custom_minimum_size = Vector2(0, 44)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.pressed.connect(_show_settings)
	utility_actions.add_child(settings_button)
	quit_button = Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(0, 44)
	quit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quit_button.pressed.connect(_quit_game)
	utility_actions.add_child(quit_button)

	save_status_label = Label.new()
	save_status_label.add_theme_font_size_override("font_size", 12)
	save_status_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	actions.add_child(save_status_label)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(390, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	var right_spacer := Control.new()
	right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(right_spacer)

	var stage_panel := PanelContainer.new()
	stage_panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191de8"), Color("#4d6263"), 1, 8, 22))
	right.add_child(stage_panel)
	var stage := VBoxContainer.new()
	stage.add_theme_constant_override("separation", 13)
	stage_panel.add_child(stage)

	var stage_eyebrow := Label.new()
	stage_eyebrow.text = "CHAPTER ONE · 15–25 MINUTES"
	stage_eyebrow.add_theme_font_size_override("font_size", 12)
	stage_eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	stage.add_child(stage_eyebrow)
	var stage_title := Label.new()
	stage_title.text = "Ashgate Depot"
	stage_title.add_theme_font_size_override("font_size", 30)
	stage_title.add_theme_color_override("font_color", Color("#f0d29d"))
	stage.add_child(stage_title)
	var briefing := Label.new()
	briefing.text = "The east road is closing. Refit the walking fortress, answer the convoy contract, and choose a route toward Meridian Pass."
	briefing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	briefing.custom_minimum_size = Vector2(330, 72)
	briefing.add_theme_color_override("font_color", Color("#d0d8d5"))
	stage.add_child(briefing)
	var scope := Label.new()
	scope.text = "5 ENCOUNTERS   ·   1 RECOVERY STOP   ·   1 FINAL BATTLE"
	scope.add_theme_font_size_override("font_size", 11)
	scope.add_theme_color_override("font_color", Color("#d8a650"))
	stage.add_child(scope)
	stage.add_child(_stage_rule("01", "Inspect the chassis", "Keep fuel, ammunition, crew, and power connected."))
	stage.add_child(_stage_rule("02", "Choose the first road", "Compare risk, fuel, time, pressure, and what your signal crew can see."))
	stage.add_child(_stage_rule("03", "Survive five encounters", "Read enemy targets, intervene once, and recover at Morrowline."))

	var controls := Label.new()
	controls.text = "MOUSE · KEYBOARD · CONTROLLER\nEnter confirms  ·  Esc pauses or returns"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	controls.add_theme_font_size_override("font_size", 12)
	controls.add_theme_color_override("font_color", Color("#aab6ba"))
	right.add_child(controls)
	_configure_title_focus()

func _configure_title_focus() -> void:
	start_button.focus_neighbor_top = start_button.get_path_to(quit_button)
	start_button.focus_neighbor_bottom = start_button.get_path_to(quick_start_button)
	quick_start_button.focus_neighbor_top = quick_start_button.get_path_to(start_button)
	continue_button.focus_neighbor_top = continue_button.get_path_to(quick_start_button)
	continue_button.focus_neighbor_bottom = continue_button.get_path_to(settings_button)
	save_recovery_button.focus_neighbor_top = save_recovery_button.get_path_to(quick_start_button)
	save_recovery_button.focus_neighbor_bottom = save_recovery_button.get_path_to(settings_button)
	guide_button.focus_neighbor_right = guide_button.get_path_to(settings_button)
	guide_button.focus_neighbor_bottom = guide_button.get_path_to(start_button)
	settings_button.focus_neighbor_left = settings_button.get_path_to(guide_button)
	settings_button.focus_neighbor_right = settings_button.get_path_to(quit_button)
	settings_button.focus_neighbor_bottom = settings_button.get_path_to(start_button)
	quit_button.focus_neighbor_left = quit_button.get_path_to(settings_button)
	quit_button.focus_neighbor_bottom = quit_button.get_path_to(start_button)

func _refresh_title_focus(has_valid_save: bool, has_invalid_save: bool = false) -> void:
	var upper_action := continue_button if has_valid_save else (save_recovery_button if has_invalid_save else quick_start_button)
	quick_start_button.focus_neighbor_bottom = quick_start_button.get_path_to(upper_action if upper_action != quick_start_button else settings_button)
	guide_button.focus_neighbor_top = guide_button.get_path_to(upper_action)
	settings_button.focus_neighbor_top = settings_button.get_path_to(upper_action)
	quit_button.focus_neighbor_top = quit_button.get_path_to(upper_action)

func _configure_overlay_focus() -> void:
	guide_close_button.focus_neighbor_right = guide_close_button.get_path_to(guide_quick_start_button)
	guide_quick_start_button.focus_neighbor_left = guide_quick_start_button.get_path_to(guide_close_button)
	display_mode_button.focus_neighbor_top = display_mode_button.get_path_to(settings_close_button)
	display_mode_button.focus_neighbor_bottom = display_mode_button.get_path_to(motion_button)
	motion_button.focus_neighbor_top = motion_button.get_path_to(display_mode_button)
	motion_button.focus_neighbor_bottom = motion_button.get_path_to(autosave_button)
	autosave_button.focus_neighbor_top = autosave_button.get_path_to(motion_button)
	resume_button.focus_neighbor_bottom = resume_button.get_path_to(pause_save_button)
	pause_save_button.focus_neighbor_top = pause_save_button.get_path_to(resume_button)
	pause_save_button.focus_neighbor_right = pause_save_button.get_path_to(save_return_button)
	pause_save_button.focus_neighbor_bottom = pause_save_button.get_path_to(pause_briefing_button)
	save_return_button.focus_neighbor_top = save_return_button.get_path_to(resume_button)
	save_return_button.focus_neighbor_left = save_return_button.get_path_to(pause_save_button)
	save_return_button.focus_neighbor_bottom = save_return_button.get_path_to(pause_settings_button)
	pause_briefing_button.focus_neighbor_top = pause_briefing_button.get_path_to(pause_save_button)
	pause_briefing_button.focus_neighbor_right = pause_briefing_button.get_path_to(pause_settings_button)
	pause_briefing_button.focus_neighbor_bottom = pause_briefing_button.get_path_to(restart_button)
	pause_settings_button.focus_neighbor_top = pause_settings_button.get_path_to(save_return_button)
	pause_settings_button.focus_neighbor_left = pause_settings_button.get_path_to(pause_briefing_button)
	pause_settings_button.focus_neighbor_bottom = pause_settings_button.get_path_to(title_button)
	restart_button.focus_neighbor_top = restart_button.get_path_to(pause_briefing_button)
	restart_button.focus_neighbor_right = restart_button.get_path_to(title_button)
	restart_button.focus_neighbor_bottom = restart_button.get_path_to(resume_button)
	title_button.focus_neighbor_top = title_button.get_path_to(pause_settings_button)
	title_button.focus_neighbor_left = title_button.get_path_to(restart_button)
	title_button.focus_neighbor_bottom = title_button.get_path_to(resume_button)
	confirmation_cancel_button.focus_neighbor_right = confirmation_cancel_button.get_path_to(confirmation_confirm_button)
	confirmation_confirm_button.focus_neighbor_left = confirmation_confirm_button.get_path_to(confirmation_cancel_button)

func _accent_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _flat_style(Color("#285348f2"), Color("#89d9b1"), 2, 6, 12))
	button.add_theme_stylebox_override("hover", _flat_style(Color("#35695cf7"), Color("#adf0ce"), 2, 6, 12))
	button.add_theme_stylebox_override("pressed", _flat_style(Color("#1c3e35f7"), Color("#ffffff"), 2, 6, 12))
	button.add_theme_stylebox_override("focus", _flat_style(Color("#285348f7"), Color("#ffffff"), 3, 6, 11))

func _clear_button_accent(button: Button) -> void:
	for style_name in ["normal", "hover", "pressed", "focus"]:
		button.remove_theme_stylebox_override(style_name)

func _stage_rule(number: String, title: String, detail: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var number_label := Label.new()
	number_label.text = number
	number_label.custom_minimum_size = Vector2(32, 0)
	number_label.add_theme_font_size_override("font_size", 18)
	number_label.add_theme_color_override("font_color", Color("#d8a650"))
	row.add_child(number_label)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	row.add_child(copy)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", Color("#edf1eb"))
	copy.add_child(title_label)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 12)
	detail_label.add_theme_color_override("font_color", Color("#98a5a5"))
	copy.add_child(detail_label)
	return row

func _build_guide_overlay() -> void:
	guide_view = Control.new()
	guide_view.name = "TestFlowGuide"
	guide_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.mouse_filter = Control.MOUSE_FILTER_STOP
	guide_view.visible = false
	add_child(guide_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 560)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#688587"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "MARCHMASTER'S FIELD GUIDE"
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "The road to Meridian Pass"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Learn the complete march once before optimizing a build. Victory and failure both make sense when you can trace what caused the outcome."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(690, 50)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	content.add_child(_flow_step("1", "ASHGATE · REFIT", "Green systems are ready, amber are strained, and red are offline or blocked. Stored parts are finite; inspect dependencies before moving one."))
	content.add_child(_flow_step("2", "ROUTE · COMMIT", "Known roads name the threat, forecasts reveal its class, and unscouted roads stay broad. Preview fuel, time, risk, pressure, and heat before Commit."))
	content.add_child(_flow_step("3", "ENCOUNTER · READ", "Each advance resolves one combat step. Read arriving enemies and named targets first; only one emergency order is available per encounter."))
	content.add_child(_flow_step("4", "MORROWLINE · RECOVER", "Spend at most two service actions, then refit around lasting damage. Disabled services state the exact missing money, damage, or action."))
	content.add_child(_flow_step("5", "MERIDIAN · DEBRIEF", "Commit to the final road, resolve the Siege Beast, then use the result thresholds and replay goal to plan one deliberate change."))
	var note := Label.new()
	note.text = "QUICK START skips only the introductory briefing. It does not change the simulation, seed, route graph, or save file."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(note)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	guide_close_button = Button.new()
	guide_close_button.text = "BACK TO TITLE"
	guide_close_button.custom_minimum_size = Vector2(180, 50)
	guide_close_button.pressed.connect(_hide_guide)
	actions.add_child(guide_close_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	guide_quick_start_button = Button.new()
	guide_quick_start_button.text = "QUICK START ASHGATE"
	guide_quick_start_button.custom_minimum_size = Vector2(220, 50)
	guide_quick_start_button.pressed.connect(_quick_start_game)
	_accent_button(guide_quick_start_button)
	actions.add_child(guide_quick_start_button)

func _flow_step(number: String, title: String, detail: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var badge := Label.new()
	badge.text = number
	badge.custom_minimum_size = Vector2(36, 36)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color("#f0cf96"))
	badge.add_theme_stylebox_override("normal", _flat_style(Color("#25383a"), Color("#668b85"), 1, 18, 4))
	row.add_child(badge)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 1)
	row.add_child(copy)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color("#edf1eb"))
	copy.add_child(title_label)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 12)
	detail_label.add_theme_color_override("font_color", Color("#9faead"))
	copy.add_child(detail_label)
	return row

func _build_settings_overlay() -> void:
	settings_view = Control.new()
	settings_view.name = "SettingsMenu"
	settings_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_view.visible = false
	add_child(settings_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 660)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#688587"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	panel.add_child(content)
	settings_context_label = Label.new()
	settings_context_label.text = "TITLE MENU · SETTINGS"
	settings_context_label.add_theme_font_size_override("font_size", 12)
	settings_context_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(settings_context_label)
	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Adjust display, accessibility, save behavior, and the guided briefing. These preferences stay on this device."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(550, 44)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	display_mode_button = _settings_action(content, "DISPLAY MODE", "Switch between a window and borderless fullscreen.", _toggle_display_mode)
	motion_button = _settings_action(content, "TRANSITION MOTION", "Reduced motion removes the title-to-stage fade.", _toggle_reduced_motion)
	autosave_button = _settings_action(content, "AUTOMATIC CHECKPOINTS", "Save after committed decisions, refits, and encounter progress.", _toggle_autosave)
	reset_briefing_button = _settings_action(content, "FIRST-RUN BRIEFING", "Show the four-part Marchmaster briefing on the next guided run.", _reset_briefing)
	clear_save_button = _settings_action(content, "LOCAL SAVE", "Permanently remove the local Continue save after confirmation.", _request_confirmation.bind("clear_save"))
	settings_status_label = Label.new()
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.custom_minimum_size = Vector2(550, 34)
	settings_status_label.add_theme_font_size_override("font_size", 12)
	settings_status_label.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(settings_status_label)
	settings_close_button = Button.new()
	settings_close_button.text = "BACK TO TITLE"
	settings_close_button.custom_minimum_size = Vector2(0, 52)
	settings_close_button.pressed.connect(_hide_settings)
	_accent_button(settings_close_button)
	content.add_child(settings_close_button)

func _settings_action(parent: VBoxContainer, title: String, detail: String, callback: Callable) -> Button:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 3)
	parent.add_child(group)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#98a8aa"))
	group.add_child(label)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 42)
	button.tooltip_text = detail
	button.pressed.connect(callback)
	group.add_child(button)
	return button

func _build_pause_menu() -> void:
	pause_view = Control.new()
	pause_view.name = "PauseMenu"
	pause_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_view.visible = false
	add_child(pause_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 580)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#9a805c"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "THE ROAD WAITS"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "MARCH PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var detail := Label.new()
	detail.text = "The road is turn-based. Nothing changes while this menu is open."
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.custom_minimum_size = Vector2(430, 38)
	detail.add_theme_color_override("font_color", Color("#b7c1bf"))
	content.add_child(detail)
	var summary_panel := PanelContainer.new()
	summary_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#405459"), 1, 5, 12))
	content.add_child(summary_panel)
	var summary := VBoxContainer.new()
	summary.add_theme_constant_override("separation", 4)
	summary_panel.add_child(summary)
	pause_summary_label = Label.new()
	pause_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_summary_label.add_theme_color_override("font_color", Color("#e7d6b2"))
	summary.add_child(pause_summary_label)
	pause_save_status_label = Label.new()
	pause_save_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_save_status_label.add_theme_font_size_override("font_size", 12)
	pause_save_status_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	summary.add_child(pause_save_status_label)
	resume_button = Button.new()
	resume_button.text = "RESUME MARCH"
	resume_button.custom_minimum_size = Vector2(0, 54)
	resume_button.pressed.connect(_resume_game)
	_accent_button(resume_button)
	content.add_child(resume_button)
	var save_actions := HBoxContainer.new()
	save_actions.add_theme_constant_override("separation", 8)
	content.add_child(save_actions)
	pause_save_button = Button.new()
	pause_save_button.text = "SAVE MARCH"
	pause_save_button.custom_minimum_size = Vector2(0, 48)
	pause_save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_save_button.pressed.connect(_save_from_pause)
	save_actions.add_child(pause_save_button)
	save_return_button = Button.new()
	save_return_button.text = "SAVE & RETURN"
	save_return_button.custom_minimum_size = Vector2(0, 48)
	save_return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_return_button.pressed.connect(_save_and_return_to_title)
	save_actions.add_child(save_return_button)
	var reference_actions := HBoxContainer.new()
	reference_actions.add_theme_constant_override("separation", 8)
	content.add_child(reference_actions)
	pause_briefing_button = Button.new()
	pause_briefing_button.text = "FIELD BRIEFING"
	pause_briefing_button.custom_minimum_size = Vector2(0, 46)
	pause_briefing_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_briefing_button.pressed.connect(_show_in_run_briefing)
	reference_actions.add_child(pause_briefing_button)
	pause_settings_button = Button.new()
	pause_settings_button.text = "SETTINGS"
	pause_settings_button.custom_minimum_size = Vector2(0, 46)
	pause_settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_settings_button.pressed.connect(_show_settings)
	reference_actions.add_child(pause_settings_button)
	var session_actions := HBoxContainer.new()
	session_actions.add_theme_constant_override("separation", 8)
	content.add_child(session_actions)
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(0, 46)
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	restart_button.tooltip_text = "Discard the current unsaved stage state and begin again."
	restart_button.pressed.connect(_request_confirmation.bind("restart"))
	session_actions.add_child(restart_button)
	title_button = Button.new()
	title_button.text = "EXIT UNSAVED"
	title_button.custom_minimum_size = Vector2(0, 46)
	title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_button.tooltip_text = "Return to the title without updating the local save."
	title_button.pressed.connect(_request_confirmation.bind("title"))
	session_actions.add_child(title_button)
	var hint := Label.new()
	hint.text = "Esc resumes"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#829092"))
	content.add_child(hint)
	pause_build_label = Label.new()
	pause_build_label.text = _build_version()
	pause_build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_build_label.add_theme_font_size_override("font_size", 10)
	pause_build_label.add_theme_color_override("font_color", Color("#667477"))
	content.add_child(pause_build_label)

func _build_confirmation_overlay() -> void:
	confirmation_view = Control.new()
	confirmation_view.name = "ConfirmationDialog"
	confirmation_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.mouse_filter = Control.MOUSE_FILTER_STOP
	confirmation_view.visible = false
	add_child(confirmation_view)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.018, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 320)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#111b20fa"), Color("#c78b63"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "CONFIRM SESSION CHANGE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#e8a97b"))
	content.add_child(eyebrow)
	confirmation_title_label = Label.new()
	confirmation_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_title_label.add_theme_font_size_override("font_size", 28)
	confirmation_title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(confirmation_title_label)
	confirmation_body_label = Label.new()
	confirmation_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirmation_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_body_label.custom_minimum_size = Vector2(430, 70)
	confirmation_body_label.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(confirmation_body_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	confirmation_cancel_button = Button.new()
	confirmation_cancel_button.text = "KEEP PLAYING"
	confirmation_cancel_button.custom_minimum_size = Vector2(0, 52)
	confirmation_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirmation_cancel_button.pressed.connect(_cancel_confirmation)
	_accent_button(confirmation_cancel_button)
	actions.add_child(confirmation_cancel_button)
	confirmation_confirm_button = Button.new()
	confirmation_confirm_button.custom_minimum_size = Vector2(0, 52)
	confirmation_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirmation_confirm_button.pressed.connect(_confirm_pending_action)
	actions.add_child(confirmation_confirm_button)

func _build_checkpoint_toast() -> void:
	checkpoint_toast = PanelContainer.new()
	checkpoint_toast.name = "CheckpointToast"
	checkpoint_toast.set_anchors_preset(Control.PRESET_TOP_LEFT)
	checkpoint_toast.position = Vector2(510, 22)
	checkpoint_toast.size = Vector2(318, 54)
	checkpoint_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	checkpoint_toast.visible = false
	checkpoint_toast.add_theme_stylebox_override("panel", _flat_style(Color("#173027f2"), Color("#76c99d"), 2, 6, 10))
	add_child(checkpoint_toast)
	checkpoint_toast_label = Label.new()
	checkpoint_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	checkpoint_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	checkpoint_toast_label.add_theme_font_size_override("font_size", 12)
	checkpoint_toast_label.add_theme_color_override("font_color", Color("#dcf7e8"))
	checkpoint_toast.add_child(checkpoint_toast_label)

func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		fullscreen_enabled = bool(config.get_value("display", "fullscreen", false))
		reduced_motion = bool(config.get_value("accessibility", "reduced_motion", false))
		autosave_enabled = bool(config.get_value("gameplay", "autosave_enabled", true))

func _build_version() -> String:
	return "v%s" % String(ProjectSettings.get_setting("application/config/version", "development"))

func _save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "fullscreen", fullscreen_enabled)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value("gameplay", "autosave_enabled", autosave_enabled)
	config.save(SETTINGS_PATH)

func _show_settings() -> void:
	settings_opened_from_pause = game_view != null and pause_view.visible
	if settings_opened_from_pause:
		pause_view.visible = false
	settings_view.visible = true
	_refresh_settings()
	display_mode_button.grab_focus()

func _hide_settings() -> void:
	settings_view.visible = false
	if settings_opened_from_pause and game_view != null:
		pause_view.visible = true
		pause_settings_button.grab_focus()
	else:
		_refresh_title_state()
		settings_button.grab_focus()
	settings_opened_from_pause = false

func _refresh_settings(message: String = "") -> void:
	settings_context_label.text = "PAUSED MARCH · SETTINGS" if settings_opened_from_pause else "TITLE MENU · SETTINGS"
	settings_close_button.text = "BACK TO PAUSE" if settings_opened_from_pause else "BACK TO TITLE"
	display_mode_button.text = "FULLSCREEN · ON" if fullscreen_enabled else "FULLSCREEN · OFF"
	motion_button.text = "REDUCED MOTION · ON" if reduced_motion else "REDUCED MOTION · OFF"
	autosave_button.text = "AUTOSAVE · ON" if autosave_enabled else "AUTOSAVE · OFF"
	var briefing_complete := FileAccess.file_exists(ONBOARDING_PATH)
	reset_briefing_button.text = "RESET COMPLETED BRIEFING" if briefing_complete else "BRIEFING · ENABLED FOR NEXT RUN"
	reset_briefing_button.disabled = not briefing_complete
	clear_save_button.text = "CLEAR LOCAL SAVE · " + ("AVAILABLE" if FileAccess.file_exists(SAVE_PATH) else "NO SAVE")
	clear_save_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	_refresh_settings_focus()
	settings_status_label.text = message if not message.is_empty() else "Preferences are local to this device."

func _refresh_settings_focus() -> void:
	var first_optional: Button = reset_briefing_button if not reset_briefing_button.disabled else (clear_save_button if not clear_save_button.disabled else settings_close_button)
	var last_optional: Button = clear_save_button if not clear_save_button.disabled else (reset_briefing_button if not reset_briefing_button.disabled else autosave_button)
	autosave_button.focus_neighbor_bottom = autosave_button.get_path_to(first_optional)
	reset_briefing_button.focus_neighbor_top = reset_briefing_button.get_path_to(autosave_button)
	reset_briefing_button.focus_neighbor_bottom = reset_briefing_button.get_path_to(clear_save_button if not clear_save_button.disabled else settings_close_button)
	clear_save_button.focus_neighbor_top = clear_save_button.get_path_to(reset_briefing_button if not reset_briefing_button.disabled else autosave_button)
	clear_save_button.focus_neighbor_bottom = clear_save_button.get_path_to(settings_close_button)
	settings_close_button.focus_neighbor_top = settings_close_button.get_path_to(last_optional)
	settings_close_button.focus_neighbor_bottom = settings_close_button.get_path_to(display_mode_button)

func _toggle_display_mode() -> void:
	fullscreen_enabled = not fullscreen_enabled
	_apply_display_mode()
	_save_preferences()
	_refresh_settings("Display mode changed. Press the same control to switch back.")
	display_mode_button.grab_focus()

func _apply_display_mode() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _toggle_reduced_motion() -> void:
	reduced_motion = not reduced_motion
	_save_preferences()
	_refresh_settings("Reduced motion enabled." if reduced_motion else "Standard transition motion enabled.")
	motion_button.grab_focus()

func _toggle_autosave() -> void:
	autosave_enabled = not autosave_enabled
	_save_preferences()
	_refresh_settings("Automatic checkpoints enabled." if autosave_enabled else "Automatic checkpoints disabled. Use Save March from the pause menu.")
	autosave_button.grab_focus()

func _reset_briefing() -> void:
	var absolute_path := ProjectSettings.globalize_path(ONBOARDING_PATH)
	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)
	_refresh_settings("The guided briefing will open on the next Guided First Run.")
	settings_close_button.grab_focus()

func _refresh_title_state() -> void:
	var save_info := _saved_run_info()
	var has_valid_save := bool(save_info.get("valid", false))
	var has_invalid_save := bool(save_info.get("exists", false)) and not has_valid_save
	start_button.text = "NEW GAME · GUIDED BRIEFING" if has_valid_save else "START GAME  ·  GUIDED FIRST RUN"
	quick_start_button.text = "NEW QUICK RUN · SKIP BRIEFING" if has_valid_save else "QUICK START  ·  SKIP BRIEFING"
	continue_button.disabled = not has_valid_save
	save_recovery_button.visible = has_invalid_save
	_refresh_title_focus(has_valid_save, has_invalid_save)
	continue_button.text = String(save_info.get("action", "CONTINUE SAVED MARCH")) if has_valid_save else ("CONTINUE  ·  SAVE UNAVAILABLE" if bool(save_info.get("exists", false)) else "CONTINUE  ·  NO SAVE FOUND")
	continue_button.tooltip_text = String(save_info.get("tooltip", "Load the last locally saved fortress state."))
	save_status_label.text = String(save_info.get("summary", _empty_save_summary()))
	var checkpoint_condition := String(save_info.get("condition", ""))
	if not has_valid_save and bool(save_info.get("exists", false)):
		save_status_label.add_theme_color_override("font_color", Color("#e98b72"))
	elif checkpoint_condition == "critical":
		save_status_label.add_theme_color_override("font_color", Color("#e98b72"))
	elif checkpoint_condition == "watch":
		save_status_label.add_theme_color_override("font_color", Color("#d8b568"))
	elif checkpoint_condition == "stable":
		save_status_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	else:
		save_status_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	_clear_button_accent(start_button)
	_clear_button_accent(continue_button)
	_accent_button(continue_button if has_valid_save else start_button)

func _focus_title_primary() -> void:
	if not continue_button.disabled:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()

func _saved_run_info() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"exists": false, "valid": false, "summary": _empty_save_summary()}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"exists": true, "valid": false, "summary": "Save unavailable · The local file could not be opened. Start a new run to replace it."}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"exists": true, "valid": false, "summary": "Save unavailable · Invalid data. Start a new run to replace it."}
	var parsed = parser.data
	if not parsed is Dictionary:
		return {"exists": true, "valid": false, "summary": "Save unavailable · Invalid data. Start a new run to replace it."}
	var schema_version := int(parsed.get("save_version", -1))
	if schema_version != LongMarchState.SAVE_VERSION:
		return {"exists": true, "valid": false, "summary": "Save unavailable · Expected schema %d, found %d." % [LongMarchState.SAVE_VERSION, schema_version]}
	if not parsed.has("phase") or not parsed.has("current_location") or not parsed.has("modules"):
		return {"exists": true, "valid": false, "summary": "Save unavailable · Required campaign state is missing."}
	var validation_state := LongMarchState.new(0)
	var validation := validation_state.load_serialized(parsed)
	if not bool(validation.get("ok", false)):
		return {"exists": true, "valid": false, "summary": "Save unavailable · %s." % String(validation.get("reason", "Campaign state could not be restored"))}
	var location := String(parsed.get("current_location", "unknown road")).replace("_", " ").capitalize()
	var phase := String(parsed.get("phase", "unknown")).replace("_", " ").capitalize()
	var day := int(parsed.get("day", 1))
	var encounters := int(parsed.get("campaign_encounters_completed", 0))
	var fuel := int(parsed.get("fuel", 0))
	var hull := int(parsed.get("hull_condition", 0))
	var heat := int(parsed.get("heat", 0))
	var saved_build := String(parsed.get("build_version", "earlier build"))
	var condition := "critical" if hull <= 3 or fuel <= 1 or heat > LongMarchState.BASE_HEAT_LIMIT else ("watch" if hull <= 6 or fuel <= 2 or heat >= LongMarchState.BASE_HEAT_LIMIT - 1 else "stable")
	return {
		"exists": true,
		"valid": true,
		"day": day,
		"location": location,
		"phase": phase,
		"encounters": encounters,
		"condition": condition,
		"action": "CONTINUE · DAY %d · %s" % [day, location.to_upper()],
		"tooltip": "Resume at %s during %s with %d of 5 encounters secured. Saved by %s." % [location, phase, encounters, saved_build],
		"summary": "Checkpoint · %s · %s · %d/5 · Fuel %d · Hull %d/10 · Heat %d/%d" % [condition.capitalize(), phase, encounters, fuel, hull, heat, LongMarchState.BASE_HEAT_LIMIT]
	}

func _empty_save_summary() -> String:
	return "No saved march · Progress checkpoints after committed decisions." if autosave_enabled else "No saved march · Use Save March from the pause menu."

func _start_new_game() -> void:
	_request_new_game(true)

func _quick_start_game() -> void:
	_request_new_game(false)

func _request_new_game(show_briefing: bool) -> void:
	if bool(_saved_run_info().get("valid", false)):
		_request_confirmation("new_guided" if show_briefing else "new_quick")
		return
	_open_stage(false, show_briefing)

func _continue_game() -> void:
	if not bool(_saved_run_info().get("valid", false)):
		_refresh_title_state()
		(save_recovery_button if save_recovery_button.visible else start_button).grab_focus()
		return
	_open_stage(true, false)

func _open_stage(load_saved: bool, show_briefing: bool) -> void:
	if game_view != null:
		game_view.queue_free()
	game_view = GAME_SCENE.instantiate()
	game_view.set("show_onboarding_on_ready", show_briefing)
	game_view.connect("return_to_title_requested", Callable(self, "_return_to_title"))
	game_view.connect("checkpoint_reached", Callable(self, "_on_checkpoint_reached"))
	add_child(game_view)
	move_child(game_view, 0)
	menu_view.visible = false
	guide_view.visible = false
	settings_view.visible = false
	pause_view.visible = false
	confirmation_view.visible = false
	pending_confirmation = ""
	settings_opened_from_pause = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	game_view.modulate = Color.WHITE if reduced_motion else Color(1.0, 1.0, 1.0, 0.0)
	if load_saved and not bool(game_view.call("load_saved_run")):
		var failed_game := game_view
		game_view = null
		failed_game.queue_free()
		menu_view.visible = true
		_refresh_title_state()
		(save_recovery_button if save_recovery_button.visible else start_button).grab_focus()
		return
	last_checkpoint_reason = "loaded save" if load_saved else ""
	game_view.call_deferred("focus_current_action")
	if not reduced_motion:
		var tween := create_tween()
		tween.tween_property(game_view, "modulate", Color.WHITE, 0.22)

func _show_pause() -> void:
	if game_view == null or pause_view.visible:
		return
	_dismiss_checkpoint_toast()
	var focus_owner := get_viewport().gui_get_focus_owner()
	paused_stage_focus = focus_owner if focus_owner != null and game_view.is_ancestor_of(focus_owner) else null
	_refresh_pause_summary()
	pause_view.visible = true
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	resume_button.grab_focus()

func _refresh_pause_summary(message: String = "") -> void:
	if game_view == null:
		return
	var run_state = game_view.get("state")
	var location := String(run_state.get("current_location")).replace("_", " ").capitalize()
	var phase := String(run_state.get("phase")).replace("_", " ").capitalize()
	var current_run_saved := _current_run_matches_save()
	pause_summary_label.text = "DAY %d · %s\n%s · %d/5 encounters secured\nFUEL %d · HULL %d/10 · HEAT %d/%d" % [int(run_state.get("day")), location, phase, int(run_state.get("campaign_encounters_completed")), int(run_state.get("fuel")), int(run_state.get("hull_condition")), int(run_state.get("heat")), LongMarchState.BASE_HEAT_LIMIT]
	title_button.text = "RETURN TO TITLE" if current_run_saved else "EXIT UNSAVED"
	title_button.tooltip_text = "Return to the title. The current decision is already saved." if current_run_saved else "Return to the title without updating the local save."
	if not message.is_empty():
		pause_save_status_label.text = message
	elif not autosave_enabled:
		pause_save_status_label.text = "Autosave is off · use Save March to preserve progress."
	elif not last_checkpoint_reason.is_empty():
		pause_save_status_label.text = "Current decision saved · %s" % _checkpoint_label(last_checkpoint_reason) if current_run_saved else "Unsaved changes since · %s" % _checkpoint_label(last_checkpoint_reason)
	elif FileAccess.file_exists(SAVE_PATH):
		pause_save_status_label.text = "Current decision is saved." if current_run_saved else "A previous local save is available. Save to capture this decision."
	else:
		pause_save_status_label.text = "This run has not been saved yet."

func _current_run_matches_save() -> bool:
	if game_view == null or not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var saved_state := LongMarchState.new(0)
	var validation := saved_state.load_serialized(parsed)
	if not bool(validation.get("ok", false)):
		return false
	var run_state = game_view.get("state")
	return _saved_values_match(saved_state.serialize(), run_state.serialize())

func _saved_values_match(saved: Variant, live: Variant) -> bool:
	if saved is Dictionary and live is Dictionary:
		if saved.size() != live.size():
			return false
		for key in saved:
			if not live.has(key) or not _saved_values_match(saved[key], live[key]):
				return false
		return true
	if saved is Array and live is Array:
		if saved.size() != live.size():
			return false
		for index in range(saved.size()):
			if not _saved_values_match(saved[index], live[index]):
				return false
		return true
	if (saved is int or saved is float) and (live is int or live is float):
		return is_equal_approx(float(saved), float(live))
	return saved == live

func _save_from_pause() -> bool:
	if game_view == null:
		return false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	var saved := bool(game_view.call("save_run"))
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	_refresh_pause_summary("Saved. Continue will resume from this decision." if saved else "Save failed. Return to the stage and review the error message.")
	if saved:
		last_checkpoint_reason = "manual save"
		pause_save_button.grab_focus()
	return saved

func _on_checkpoint_reached(reason: String) -> void:
	if game_view == null or not autosave_enabled:
		return
	if bool(game_view.call("save_run", true)):
		last_checkpoint_reason = reason
		_show_checkpoint_toast(reason)

func _show_checkpoint_toast(reason: String) -> void:
	if checkpoint_toast_tween != null and checkpoint_toast_tween.is_valid():
		checkpoint_toast_tween.kill()
	checkpoint_toast_label.text = "CHECKPOINT SAVED · %s" % _checkpoint_label(reason).to_upper()
	checkpoint_toast.modulate = Color.WHITE
	checkpoint_toast.visible = true
	checkpoint_toast_tween = create_tween()
	checkpoint_toast_tween.tween_interval(1.6)
	if not reduced_motion:
		checkpoint_toast_tween.tween_property(checkpoint_toast, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	checkpoint_toast_tween.tween_callback(func() -> void: checkpoint_toast.visible = false)

func _dismiss_checkpoint_toast() -> void:
	if checkpoint_toast_tween != null and checkpoint_toast_tween.is_valid():
		checkpoint_toast_tween.kill()
	checkpoint_toast.visible = false

func _checkpoint_label(reason: String) -> String:
	return String(CHECKPOINT_LABELS.get(reason, reason.replace("_", " ").capitalize()))

func _save_and_return_to_title() -> void:
	if _save_from_pause():
		_return_to_title()

func _resume_game() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	if paused_stage_focus != null and is_instance_valid(paused_stage_focus) and paused_stage_focus.is_visible_in_tree() and paused_stage_focus.focus_mode != Control.FOCUS_NONE and not (paused_stage_focus is BaseButton and paused_stage_focus.disabled):
		paused_stage_focus.grab_focus()
	else:
		game_view.call_deferred("focus_current_action")
	paused_stage_focus = null

func _show_in_run_briefing() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	paused_stage_focus = null
	game_view.call("_show_onboarding", true)

func _restart_game() -> void:
	_open_stage(false, false)

func _request_confirmation(action: String) -> void:
	if action not in ["restart", "title", "clear_save", "clear_invalid_save", "new_guided", "new_quick"]:
		return
	if action == "title" and _current_run_matches_save():
		_return_to_title()
		return
	pending_confirmation = action
	if action == "restart":
		confirmation_title_label.text = "Restart from Ashgate?"
		confirmation_body_label.text = "Current stage progress will be discarded. Your existing local save remains available."
		confirmation_confirm_button.text = "RESTART"
	elif action == "title":
		confirmation_title_label.text = "Return without saving?"
		confirmation_body_label.text = "Progress since the last save will be discarded. Choose Save & Return instead if you want to continue later."
		confirmation_confirm_button.text = "RETURN"
	elif action in ["clear_save", "clear_invalid_save"]:
		confirmation_title_label.text = "Clear the local save?"
		confirmation_body_label.text = "This unreadable local file will be permanently removed. Your settings and briefing preference remain unchanged." if action == "clear_invalid_save" else "Continue progress on this device will be permanently removed. This does not reset the briefing preference."
		confirmation_confirm_button.text = "REMOVE SAVE" if action == "clear_invalid_save" else "CLEAR SAVE"
	else:
		var save_info := _saved_run_info()
		var saved_context := "Day %d at %s" % [int(save_info.get("day", 1)), String(save_info.get("location", "the last checkpoint"))]
		confirmation_title_label.text = "Begin a new march?"
		confirmation_body_label.text = ("Your %s save remains intact until the new run reaches its first automatic checkpoint. After that, Continue will follow the new march." if autosave_enabled else "Your %s save remains intact. This run replaces it only if you save manually or enable autosave and reach a checkpoint.") % saved_context
		confirmation_confirm_button.text = "START NEW"
	confirmation_cancel_button.text = "KEEP FILE" if action == "clear_invalid_save" else ("KEEP SAVE" if action in ["clear_save", "new_guided", "new_quick"] else "KEEP PLAYING")
	confirmation_view.visible = true
	confirmation_cancel_button.grab_focus()

func _cancel_confirmation() -> void:
	var previous_action := pending_confirmation
	pending_confirmation = ""
	confirmation_view.visible = false
	if previous_action == "restart":
		restart_button.grab_focus()
	elif previous_action == "clear_save":
		clear_save_button.grab_focus()
	elif previous_action == "clear_invalid_save":
		save_recovery_button.grab_focus()
	elif previous_action == "new_quick":
		quick_start_button.grab_focus()
	elif previous_action == "new_guided":
		start_button.grab_focus()
	else:
		title_button.grab_focus()

func _confirm_pending_action() -> void:
	var action := pending_confirmation
	pending_confirmation = ""
	confirmation_view.visible = false
	if action == "restart":
		_restart_game()
	elif action == "title":
		_return_to_title()
	elif action in ["clear_save", "clear_invalid_save"]:
		var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
		_refresh_title_state()
		if action == "clear_invalid_save":
			start_button.grab_focus()
		else:
			_refresh_settings("Local save cleared. Start Game begins a fresh march.")
			settings_close_button.grab_focus()
	elif action == "new_guided":
		_open_stage(false, true)
	elif action == "new_quick":
		_open_stage(false, false)

func _show_guide() -> void:
	guide_view.visible = true
	guide_quick_start_button.grab_focus()

func _hide_guide() -> void:
	guide_view.visible = false
	guide_button.grab_focus()

func _return_to_title() -> void:
	pause_view.visible = false
	guide_view.visible = false
	settings_view.visible = false
	confirmation_view.visible = false
	pending_confirmation = ""
	paused_stage_focus = null
	settings_opened_from_pause = false
	last_checkpoint_reason = ""
	checkpoint_toast.visible = false
	if game_view != null:
		var old_game := game_view
		game_view = null
		old_game.queue_free()
	menu_view.visible = true
	_refresh_title_state()
	_focus_title_primary()

func _quit_game() -> void:
	get_tree().quit()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if confirmation_view.visible:
		_cancel_confirmation()
		get_viewport().set_input_as_handled()
		return
	if settings_view.visible:
		_hide_settings()
		get_viewport().set_input_as_handled()
		return
	if game_view == null:
		if guide_view.visible:
			_hide_guide()
			get_viewport().set_input_as_handled()
		return
	if pause_view.visible:
		_resume_game()
	else:
		_show_pause()
	get_viewport().set_input_as_handled()
