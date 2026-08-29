class_name RoadsideEventView
extends Control

signal pause_requested
signal choice_requested(choice_id: String)

var pause_button: Button
var context_label: Label
var value_labels: Dictionary = {}
var tableau: ScenarioCanvas
var location_label: Label
var title_label: Label
var body_label: Label
var choice_buttons: Array[Button] = []
var guidance_label: Label
var high_contrast_enabled: bool = false
var current_view: Dictionary = {}

func _ready() -> void:
	_build_ui()

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 9) -> StyleBoxFlat:
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

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color("#0d1519")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var page := VBoxContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", 10)
	add_child(page)
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 46)
	header.add_theme_constant_override("separation", 12)
	page.add_child(header)
	var game_title := Label.new()
	game_title.text = "THE LONG MARCH"
	game_title.add_theme_font_size_override("font_size", 27)
	game_title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(game_title)
	context_label = Label.new()
	context_label.text = "ROADSIDE OCCURRENCE"
	context_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	context_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	context_label.add_theme_font_size_override("font_size", 13)
	context_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(context_label)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC"
	pause_button.custom_minimum_size = Vector2(170, 42)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)
	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	page.add_child(body)
	_build_value_rail(body)
	var center := VBoxContainer.new()
	center.custom_minimum_size = Vector2(590, 0)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 7)
	body.add_child(center)
	location_label = Label.new()
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 12)
	location_label.add_theme_color_override("font_color", Color("#d8c389"))
	center.add_child(location_label)
	tableau = ScenarioCanvas.new()
	tableau.custom_minimum_size = Vector2(590, 500)
	tableau.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tableau.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(tableau)
	_build_choice_dock(body)

func _build_value_rail(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(190, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#121d22"), Color("#35484f"), 1, 6, 10))
	parent.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	panel.add_child(stack)
	var heading := Label.new()
	heading.text = "MARCH STATE"
	heading.add_theme_font_size_override("font_size", 14)
	heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(heading)
	for value_id in ["day", "fuel", "hull", "ashmarks", "pressure", "trust"]:
		var receipt := PanelContainer.new()
		receipt.add_theme_stylebox_override("panel", _flat_style(Color("#18242a"), Color("#31434a"), 1, 4, 6))
		stack.add_child(receipt)
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 1)
		receipt.add_child(row)
		var key := Label.new()
		key.text = value_id.to_upper()
		key.add_theme_font_size_override("font_size", 9)
		key.add_theme_color_override("font_color", Color("#89999e"))
		row.add_child(key)
		var value := Label.new()
		value.text = "—"
		value.add_theme_font_size_override("font_size", 14)
		value.add_theme_color_override("font_color", Color("#f1e6cf"))
		row.add_child(value)
		value_labels[value_id] = value
	var note := Label.new()
	note.text = "The fortress has stopped here. Choose once; the stated consequence is applied immediately."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(note)

func _build_choice_dock(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(330, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d21"), Color("#596d72"), 2, 6, 11))
	parent.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 9)
	panel.add_child(stack)
	var kicker := Label.new()
	kicker.text = "DECISION AT THE ROADSIDE"
	kicker.add_theme_font_size_override("font_size", 9)
	kicker.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(kicker)
	title_label = Label.new()
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 21)
	title_label.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(title_label)
	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(0, 110)
	body_label.add_theme_font_size_override("font_size", 13)
	body_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	stack.add_child(body_label)
	var choice_heading := Label.new()
	choice_heading.text = "ISSUE ONE ORDER"
	choice_heading.add_theme_font_size_override("font_size", 10)
	choice_heading.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(choice_heading)
	for index in range(3):
		var button := Button.new()
		button.text = "Choice %d" % (index + 1)
		button.custom_minimum_size = Vector2(0, 72)
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_emit_choice.bind(button))
		choice_buttons.append(button)
		stack.add_child(button)
	guidance_label = Label.new()
	guidance_label.text = "No choice advances until you confirm it."
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	guidance_label.add_theme_font_size_override("font_size", 10)
	guidance_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	stack.add_child(guidance_label)

func configure(view: Dictionary) -> void:
	current_view = view.duplicate(true)
	context_label.text = String(view.get("context", "ROADSIDE OCCURRENCE")).to_upper()
	location_label.text = "%s · THE FORTRESS HOLDS POSITION" % String(view.get("location_name", "THE ROAD")).to_upper()
	title_label.text = String(view.get("title", "A DECISION")).to_upper()
	body_label.text = String(view.get("body", "The road waits for an order."))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	var choices: Array = view.get("choices", [])
	for index in range(choice_buttons.size()):
		var button := choice_buttons[index]
		if index >= choices.size():
			button.visible = false
			button.set_meta("choice_id", "")
			continue
		var choice: Dictionary = choices[index]
		var enabled := bool(choice.get("enabled", false))
		var reason := String(choice.get("reason", ""))
		button.visible = true
		button.disabled = not enabled
		button.set_meta("choice_id", String(choice.get("id", "")))
		button.text = "%s\n%s" % [String(choice.get("label", "Choose")), String(choice.get("effect", "No recorded effect"))]
		if not enabled:
			button.text += "\nLOCKED · %s" % reason.to_upper()
		button.tooltip_text = reason
		button.custom_minimum_size.y = 76 if not enabled or button.text.count("\n") >= 2 else 64
	guidance_label.text = String(view.get("guidance", "Choose one response. The listed costs and effects apply immediately."))
	tableau.event_id = String(view.get("event_id", ""))
	tableau.region_id = String(view.get("region_id", "ashgate_lowlands"))
	tableau.high_contrast_enabled = high_contrast_enabled
	tableau.queue_redraw()
	_configure_focus()

func _emit_choice(button: Button) -> void:
	var choice_id := String(button.get_meta("choice_id", ""))
	if not choice_id.is_empty():
		choice_requested.emit(choice_id)

func _configure_focus() -> void:
	var available: Array[Control] = []
	for button in choice_buttons:
		if button.visible and not button.disabled:
			available.append(button)
	for index in range(available.size()):
		var previous := available[(index - 1 + available.size()) % available.size()]
		var next := available[(index + 1) % available.size()]
		available[index].focus_neighbor_top = available[index].get_path_to(previous)
		available[index].focus_neighbor_bottom = available[index].get_path_to(next)
		available[index].focus_previous = available[index].get_path_to(previous)
		available[index].focus_next = available[index].get_path_to(next)

func focus_default() -> void:
	for button in choice_buttons:
		if button.visible and not button.disabled:
			button.grab_focus()
			return

func button_for(choice_id: String) -> Button:
	for button in choice_buttons:
		if String(button.get_meta("choice_id", "")) == choice_id:
			return button
	return null

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if tableau != null:
		tableau.high_contrast_enabled = enabled
		tableau.queue_redraw()

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class ScenarioCanvas extends Control:
	var event_id: String = ""
	var region_id: String = "ashgate_lowlands"
	var high_contrast_enabled: bool = false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var flooded := region_id == "flooded_veyru"
		draw_rect(Rect2(Vector2.ZERO, size), Color("#071013") if high_contrast_enabled else (Color("#17373f") if flooded else Color("#333a3c")), true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.17), 58.0, Color(0.96, 0.76, 0.44, 0.18))
		for ridge in range(4):
			var y := size.y * (0.31 + ridge * 0.05)
			draw_line(Vector2(0, y), Vector2(size.x, y - 26.0 + ridge * 8.0), Color("#39575d") if flooded else Color("#665c4e"), 26.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.65), Vector2(size.x, size.y * 0.35)), Color("#10282c") if flooded else Color("#31271e"), true)
		_draw_fortress(Vector2(size.x * 0.28, size.y * 0.63))
		_draw_subject(Vector2(size.x * 0.73, size.y * 0.61))
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 18), "THE ROAD WAITS FOR YOUR ORDER", HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#dfc990"))

	func _draw_fortress(center: Vector2) -> void:
		var body := Rect2(center - Vector2(132, 64), Vector2(264, 104))
		var metal := Color("#303837") if high_contrast_enabled else Color("#4b4a41")
		var edge := Color("#ead69e") if high_contrast_enabled else Color("#9a825a")
		draw_rect(body, metal, true)
		draw_rect(body, edge, false, 4.0)
		draw_rect(Rect2(body.position + Vector2(25, -36), Vector2(84, 36)), metal.lightened(0.06), true)
		draw_rect(Rect2(body.position + Vector2(25, -36), Vector2(84, 36)), edge, false, 3.0)
		for leg_x in [body.position.x + 46.0, body.position.x + 103.0, body.end.x - 103.0, body.end.x - 46.0]:
			draw_line(Vector2(leg_x, body.end.y), Vector2(leg_x, body.end.y + 43.0), edge, 9.0)
			draw_line(Vector2(leg_x - 13.0, body.end.y + 43.0), Vector2(leg_x + 15.0, body.end.y + 43.0), edge, 7.0)
		for window_x in [body.position.x + 48.0, body.position.x + 102.0, body.position.x + 158.0, body.position.x + 210.0]:
			draw_rect(Rect2(Vector2(window_x, body.position.y + 31), Vector2(20, 22)), Color("#dfa759"), true)

	func _draw_subject(center: Vector2) -> void:
		if event_id in ["salvage_choice", "the_last_dry_room"]:
			_draw_ruin(center)
		elif event_id in ["lost_signal", "archive_broadcast"]:
			_draw_signal(center)
		elif event_id == "toll_decision":
			_draw_barricade(center)
		elif event_id in ["mara_meeting", "mara_workbench_choice", "mara_followup"]:
			_draw_forge(center)
		elif event_id in ["drain_pumps", "registry_salvage"]:
			_draw_floodworks(center)
		else:
			_draw_road_machine(center)

	func _draw_ruin(center: Vector2) -> void:
		draw_rect(Rect2(center - Vector2(88, 90), Vector2(176, 90)), Color("#4a4035"), true)
		for x in [-58.0, -15.0, 32.0, 70.0]:
			draw_line(center + Vector2(x, -88), center + Vector2(x - 18, -133), Color("#242624"), 8.0)
			draw_circle(center + Vector2(x - 20, -140), 16.0, Color(0.85, 0.31, 0.16, 0.65))

	func _draw_signal(center: Vector2) -> void:
		draw_line(center + Vector2(0, 12), center + Vector2(0, -145), Color("#78817c"), 10.0)
		draw_line(center + Vector2(-54, -72), center + Vector2(55, -72), Color("#78817c"), 7.0)
		for radius in [28.0, 48.0, 68.0]:
			draw_arc(center + Vector2(0, -119), radius, -2.6, -0.55, 18, Color("#83d7cf"), 3.0)

	func _draw_barricade(center: Vector2) -> void:
		for x in [-75.0, -25.0, 25.0, 75.0]:
			draw_line(center + Vector2(x, 5), center + Vector2(x - 18, -93), Color("#7c543d"), 13.0)
		draw_line(center + Vector2(-108, -55), center + Vector2(105, -20), Color("#a36a48"), 17.0)
		draw_circle(center + Vector2(0, -72), 28.0, Color("#8e382e"))

	func _draw_forge(center: Vector2) -> void:
		draw_rect(Rect2(center - Vector2(92, 82), Vector2(184, 82)), Color("#443d38"), true)
		draw_rect(Rect2(center + Vector2(-34, -48), Vector2(68, 48)), Color("#1b2020"), true)
		draw_circle(center + Vector2(0, -22), 22.0, Color("#df7b3f"))
		draw_line(center + Vector2(68, -82), center + Vector2(68, -142), Color("#68655d"), 18.0)
		for index in range(3):
			draw_circle(center + Vector2(70 + index * 12, -157 - index * 14), 13.0 + index * 3.0, Color(0.16, 0.19, 0.19, 0.42))

	func _draw_floodworks(center: Vector2) -> void:
		draw_rect(Rect2(center - Vector2(100, 88), Vector2(200, 88)), Color("#3d4c4d"), true)
		for x in [-62.0, 0.0, 62.0]:
			draw_circle(center + Vector2(x, -42), 28.0, Color("#17282b"), false, 7.0)
		for wave in range(3):
			draw_arc(center + Vector2(-45 + wave * 48, 15), 35.0, PI, TAU, 18, Color("#4b8b94"), 5.0)

	func _draw_road_machine(center: Vector2) -> void:
		draw_circle(center + Vector2(0, -35), 55.0, Color("#4c504a"), false, 12.0)
		draw_circle(center + Vector2(0, -35), 15.0, Color("#c18a4c"))
		draw_line(center + Vector2(-78, 0), center + Vector2(82, 0), Color("#75644d"), 13.0)
