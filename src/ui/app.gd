class_name LongMarchApp
extends Control

const GAME_SCENE = preload("res://scenes/Main.tscn")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const SAVE_PATH := "user://the_long_march_prototype.save"

var menu_view: Control
var guide_view: Control
var pause_view: Control
var game_view: Control
var start_button: Button
var quick_start_button: Button
var continue_button: Button
var guide_button: Button
var guide_close_button: Button
var guide_quick_start_button: Button
var resume_button: Button
var restart_button: Button
var title_button: Button
var save_status_label: Label

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
	theme = _create_menu_theme()
	_build_title_menu()
	_build_guide_overlay()
	_build_pause_menu()
	_refresh_title_state()
	start_button.grab_focus()

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

	var build_label := Label.new()
	build_label.text = "ASHGATE LOWLANDS · PLAYABLE ALPHA"
	build_label.add_theme_font_size_override("font_size", 13)
	build_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	left.add_child(build_label)

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
	start_button.tooltip_text = "Begin at Ashgate Depot with the five-part Marchmaster briefing."
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
	panel.custom_minimum_size = Vector2(460, 430)
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
	detail.text = "Your fortress state is unchanged. Resume when you are ready to make the next decision."
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.custom_minimum_size = Vector2(390, 58)
	detail.add_theme_color_override("font_color", Color("#b7c1bf"))
	content.add_child(detail)
	resume_button = Button.new()
	resume_button.text = "RESUME MARCH"
	resume_button.custom_minimum_size = Vector2(0, 56)
	resume_button.pressed.connect(_resume_game)
	_accent_button(resume_button)
	content.add_child(resume_button)
	restart_button = Button.new()
	restart_button.text = "RESTART FROM ASHGATE"
	restart_button.custom_minimum_size = Vector2(0, 50)
	restart_button.tooltip_text = "Discard the current unsaved stage state and begin again."
	restart_button.pressed.connect(_restart_game)
	content.add_child(restart_button)
	title_button = Button.new()
	title_button.text = "RETURN TO TITLE"
	title_button.custom_minimum_size = Vector2(0, 50)
	title_button.pressed.connect(_return_to_title)
	content.add_child(title_button)
	var hint := Label.new()
	hint.text = "Esc resumes"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#829092"))
	content.add_child(hint)

func _refresh_title_state() -> void:
	var has_save := FileAccess.file_exists(SAVE_PATH)
	continue_button.disabled = not has_save
	continue_button.text = "CONTINUE SAVED MARCH" if has_save else "CONTINUE  ·  NO SAVE FOUND"
	save_status_label.text = _saved_run_summary() if has_save else "No save yet · New runs save only when you choose Save."

func _saved_run_summary() -> String:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return "A saved march is available on this device."
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return "A saved march is available, but its summary is unreadable."
	var location := String(parsed.get("current_location", "unknown road")).replace("_", " ").capitalize()
	return "Saved · Day %d · %s · %d/5 encounters" % [int(parsed.get("day", 1)), location, int(parsed.get("campaign_encounters_completed", 0))]

func _start_new_game() -> void:
	_open_stage(false, true)

func _quick_start_game() -> void:
	_open_stage(false, false)

func _continue_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_refresh_title_state()
		start_button.grab_focus()
		return
	_open_stage(true, false)

func _open_stage(load_saved: bool, show_briefing: bool) -> void:
	if game_view != null:
		game_view.queue_free()
	game_view = GAME_SCENE.instantiate()
	game_view.set("show_onboarding_on_ready", show_briefing)
	add_child(game_view)
	move_child(game_view, 0)
	menu_view.visible = false
	guide_view.visible = false
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	game_view.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if load_saved:
		game_view.call("_on_load_pressed")
	var tween := create_tween()
	tween.tween_property(game_view, "modulate", Color.WHITE, 0.22)

func _show_pause() -> void:
	if game_view == null or pause_view.visible:
		return
	pause_view.visible = true
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	resume_button.grab_focus()

func _resume_game() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT

func _restart_game() -> void:
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
	if game_view != null:
		var old_game := game_view
		game_view = null
		old_game.queue_free()
	menu_view.visible = true
	_refresh_title_state()
	start_button.grab_focus()

func _quit_game() -> void:
	get_tree().quit()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
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
