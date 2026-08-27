class_name LongMarchApp
extends Control

const GAME_SCENE = preload("res://scenes/Main.tscn")
const LongMarchState = preload("res://src/core/fortress_state.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"

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
var guide_button: Button
var settings_button: Button
var guide_close_button: Button
var guide_quick_start_button: Button
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
	theme = _create_menu_theme()
	_build_title_menu()
	_build_guide_overlay()
	_build_settings_overlay()
	_build_pause_menu()
	_build_confirmation_overlay()
	_build_checkpoint_toast()
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

	var utility_actions := HBoxContainer.new()
	utility_actions.add_theme_constant_override("separation", 8)
	actions.add_child(utility_actions)
	guide_button = Button.new()
	guide_button.name = "GuideButton"
	guide_button.text = "VIEW TEST FLOW"
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
	var quit_button := Button.new()
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
	stage_eyebrow.text = "PLAYTEST TARGET · 15–25 MINUTES"
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
	eyebrow.text = "PLAYTEST FIELD GUIDE"
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "One complete Ashgate run"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Test the full decision loop once before optimizing a build. A successful or failed run is useful when you can explain what caused the outcome."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(690, 50)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	content.add_child(_flow_step("1", "ASHGATE · REFIT", "Select modules on the chassis. Check at least one dependency explanation, then accept or decline the convoy contract."))
	content.add_child(_flow_step("2", "ROUTE · COMMIT", "Select a cyan node, compare its fuel, time, risk, pressure, and visibility, then use the separate Commit action."))
	content.add_child(_flow_step("3", "ENCOUNTER · READ", "Advance each combat step. Identify the current enemy target and use no more than one emergency order."))
	content.add_child(_flow_step("4", "MORROWLINE · RECOVER", "Spend up to two settlement actions, refit around damage, and choose the final approach."))
	content.add_child(_flow_step("5", "MERIDIAN · REPORT", "Finish the Siege Beast battle, read the causal result, then record what felt clear or confusing."))
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
	var eyebrow := Label.new()
	eyebrow.text = "APPLICATION SETTINGS"
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "Playtest preferences"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Display and onboarding controls live outside campaign state. Changing them never alters the simulation or route seed."
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
		reduced_motion = bool(config.get_value("accessibility", "reduced_motion", false))
		autosave_enabled = bool(config.get_value("gameplay", "autosave_enabled", true))

func _build_version() -> String:
	return "v%s" % String(ProjectSettings.get_setting("application/config/version", "development"))

func _save_preferences() -> void:
	var config := ConfigFile.new()
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
		settings_button.grab_focus()
	settings_opened_from_pause = false

func _refresh_settings(message: String = "") -> void:
	var fullscreen := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	display_mode_button.text = "FULLSCREEN · ON" if fullscreen else "FULLSCREEN · OFF"
	motion_button.text = "REDUCED MOTION · ON" if reduced_motion else "REDUCED MOTION · OFF"
	autosave_button.text = "AUTOSAVE · ON" if autosave_enabled else "AUTOSAVE · OFF"
	var briefing_complete := FileAccess.file_exists(ONBOARDING_PATH)
	reset_briefing_button.text = "RESET COMPLETED BRIEFING" if briefing_complete else "BRIEFING · ENABLED FOR NEXT RUN"
	reset_briefing_button.disabled = not briefing_complete
	clear_save_button.text = "CLEAR LOCAL SAVE · " + ("AVAILABLE" if FileAccess.file_exists(SAVE_PATH) else "NO SAVE")
	clear_save_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	settings_status_label.text = message if not message.is_empty() else "Preferences are local to this device."

func _toggle_display_mode() -> void:
	var fullscreen := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_settings("Display mode changed. Press the same control to switch back.")
	display_mode_button.grab_focus()

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
	reset_briefing_button.grab_focus()

func _refresh_title_state() -> void:
	var save_info := _saved_run_info()
	var has_valid_save := bool(save_info.get("valid", false))
	continue_button.disabled = not has_valid_save
	continue_button.text = "CONTINUE SAVED MARCH" if has_valid_save else ("CONTINUE  ·  SAVE UNAVAILABLE" if bool(save_info.get("exists", false)) else "CONTINUE  ·  NO SAVE FOUND")
	save_status_label.text = String(save_info.get("summary", "No save yet · New runs save only when you choose Save."))
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
		return {"exists": false, "valid": false, "summary": "No save yet · New runs save only when you choose Save."}
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
	return {"exists": true, "valid": true, "summary": "Saved · Day %d · %s · %s · %d/5" % [int(parsed.get("day", 1)), location, phase, int(parsed.get("campaign_encounters_completed", 0))]}

func _start_new_game() -> void:
	_request_new_game(true)

func _quick_start_game() -> void:
	_request_new_game(false)

func _request_new_game(show_briefing: bool) -> void:
	if autosave_enabled and bool(_saved_run_info().get("valid", false)):
		_request_confirmation("new_guided" if show_briefing else "new_quick")
		return
	_open_stage(false, show_briefing)

func _continue_game() -> void:
	if not bool(_saved_run_info().get("valid", false)):
		_refresh_title_state()
		start_button.grab_focus()
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
		start_button.grab_focus()
		return
	last_checkpoint_reason = "loaded save" if load_saved else ""
	game_view.call_deferred("focus_current_action")
	if not reduced_motion:
		var tween := create_tween()
		tween.tween_property(game_view, "modulate", Color.WHITE, 0.22)

func _show_pause() -> void:
	if game_view == null or pause_view.visible:
		return
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
	pause_summary_label.text = "DAY %d · %s\n%s · %d/5 encounters secured" % [int(run_state.get("day")), location, phase, int(run_state.get("campaign_encounters_completed"))]
	if not message.is_empty():
		pause_save_status_label.text = message
	elif not autosave_enabled:
		pause_save_status_label.text = "Autosave is off · use Save March to preserve progress."
	elif not last_checkpoint_reason.is_empty():
		pause_save_status_label.text = "Autosaved · %s" % last_checkpoint_reason.replace("_", " ").capitalize()
	elif FileAccess.file_exists(SAVE_PATH):
		pause_save_status_label.text = "A local save is available. Save again to capture current progress."
	else:
		pause_save_status_label.text = "This run has not been saved yet."

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
	checkpoint_toast_label.text = "CHECKPOINT SAVED · %s" % reason.replace("_", " ").to_upper()
	checkpoint_toast.modulate = Color.WHITE
	checkpoint_toast.visible = true
	checkpoint_toast_tween = create_tween()
	checkpoint_toast_tween.tween_interval(1.6)
	if not reduced_motion:
		checkpoint_toast_tween.tween_property(checkpoint_toast, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	checkpoint_toast_tween.tween_callback(func() -> void: checkpoint_toast.visible = false)

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
	if action not in ["restart", "title", "clear_save", "new_guided", "new_quick"]:
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
	elif action == "clear_save":
		confirmation_title_label.text = "Clear the local save?"
		confirmation_body_label.text = "Continue progress on this device will be permanently removed. This does not reset the briefing preference."
		confirmation_confirm_button.text = "CLEAR SAVE"
	else:
		confirmation_title_label.text = "Begin a new march?"
		confirmation_body_label.text = "Your existing save remains intact until the new run reaches its first automatic checkpoint. After that, Continue will follow the new march."
		confirmation_confirm_button.text = "START NEW"
	confirmation_cancel_button.text = "KEEP SAVE" if action in ["clear_save", "new_guided", "new_quick"] else "KEEP PLAYING"
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
	elif action == "clear_save":
		var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
		_refresh_title_state()
		_refresh_settings("Local save cleared. Start Game begins a fresh march.")
		clear_save_button.grab_focus()
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
	if game_view == null:
		if guide_view.visible:
			_hide_guide()
			get_viewport().set_input_as_handled()
		elif settings_view.visible:
			_hide_settings()
			get_viewport().set_input_as_handled()
		return
	if pause_view.visible:
		_resume_game()
	else:
		_show_pause()
	get_viewport().set_input_as_handled()
