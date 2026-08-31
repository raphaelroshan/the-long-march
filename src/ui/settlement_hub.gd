class_name SettlementHubView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

signal pause_requested
signal action_requested(station_id: String, action_id: String)

const STATION_ORDER := ["workshop", "quartermaster", "signal_broker", "hiring_post", "assignment_board", "departure_gate"]
const STATION_NAMES := {
	"workshop": "WORKSHOP",
	"quartermaster": "QUARTERMASTER",
	"signal_broker": "SIGNAL BROKER",
	"hiring_post": "HIRING POST",
	"assignment_board": "ASSIGNMENTS",
	"departure_gate": "DEPARTURE GATE"
}

var location_label: Label
var context_label: Label
var place_identity_label: Label
var pressure_label: Label
var route_meaning_label: Label
var pause_button: Button
var value_labels: Dictionary = {}
var bazaar_canvas: BazaarCanvas
var station_buttons: Dictionary = {}
var detail_title: Label
var detail_status: Label
var detail_body: Label
var primary_action_button: Button
var secondary_action_button: Button
var back_button: Button
var selected_station_id: String = "assignment_board"
var current_view: Dictionary = {}
var current_primary_action_id: String = ""
var current_secondary_action_id: String = ""
var high_contrast_enabled: bool = false

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

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 48)
	header.add_theme_constant_override("separation", 12)
	page.add_child(header)
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	location_label = Label.new()
	location_label.text = "ASHGATE DEPOT · FORTRESS AT REST"
	location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 14)
	location_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(location_label)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC"
	pause_button.custom_minimum_size = Vector2(170, 42)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.tooltip_text = "Pause the march without leaving the settlement."
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)

	context_label = Label.new()
	context_label.text = "FORTRESS AT REST · Choose one place in the bazaar."
	context_label.add_theme_color_override("font_color", Color("#b8c4c5"))
	page.add_child(context_label)

	var identity_strip := HBoxContainer.new()
	identity_strip.custom_minimum_size = Vector2(0, 44)
	identity_strip.add_theme_constant_override("separation", 8)
	page.add_child(identity_strip)
	place_identity_label = _identity_card(identity_strip, "PLACE")
	pressure_label = _identity_card(identity_strip, "PRESSURE")
	route_meaning_label = _identity_card(identity_strip, "OUTBOUND ROADS")

	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	page.add_child(body)

	var value_panel := PanelContainer.new()
	value_panel.custom_minimum_size = Vector2(190, 0)
	value_panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d22"), Color("#34474e"), 1, 6, 10))
	body.add_child(value_panel)
	var value_stack := VBoxContainer.new()
	value_stack.add_theme_constant_override("separation", 6)
	value_panel.add_child(value_stack)
	var value_heading := Label.new()
	value_heading.text = "FORTRESS VALUES"
	value_heading.add_theme_font_size_override("font_size", 15)
	value_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	value_stack.add_child(value_heading)
	for value_id in ["hull", "fuel", "power", "heat", "mass", "money", "context"]:
		_add_value_card(value_stack, value_id)

	bazaar_canvas = BazaarCanvas.new()
	bazaar_canvas.custom_minimum_size = Vector2(650, 500)
	bazaar_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bazaar_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(bazaar_canvas)
	for station_id in STATION_ORDER:
		var station_button := Button.new()
		station_button.custom_minimum_size = Vector2(154, 54)
		station_button.focus_mode = Control.FOCUS_ALL
		station_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		station_button.set_meta("station_id", station_id)
		station_button.focus_entered.connect(_select_station.bind(station_id, false))
		station_button.mouse_entered.connect(_select_station.bind(station_id, false))
		station_button.pressed.connect(_select_station.bind(station_id, true))
		station_buttons[station_id] = station_button
		bazaar_canvas.add_child(station_button)
	bazaar_canvas.resized.connect(_layout_station_buttons)
	_layout_station_buttons.call_deferred()

	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(310, 0)
	detail_panel.add_theme_stylebox_override("panel", _flat_style(Color("#151d21"), Color("#536a70"), 2, 6, 12))
	body.add_child(detail_panel)
	var detail_stack := VBoxContainer.new()
	detail_stack.add_theme_constant_override("separation", 9)
	detail_panel.add_child(detail_stack)
	var detail_kicker := Label.new()
	detail_kicker.text = "BAZAAR STATION"
	detail_kicker.add_theme_font_size_override("font_size", 10)
	detail_kicker.add_theme_color_override("font_color", Color("#89999e"))
	detail_stack.add_child(detail_kicker)
	detail_title = Label.new()
	detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_title.add_theme_font_size_override("font_size", 20)
	detail_title.add_theme_color_override("font_color", Color("#e8c58e"))
	detail_stack.add_child(detail_title)
	detail_status = Label.new()
	detail_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_status.add_theme_font_size_override("font_size", 12)
	detail_status.add_theme_color_override("font_color", Color("#9fd2c2"))
	detail_stack.add_child(detail_status)
	detail_body = Label.new()
	detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_body.add_theme_font_size_override("font_size", 13)
	detail_body.add_theme_color_override("font_color", Color("#c8d1d1"))
	detail_stack.add_child(detail_body)
	primary_action_button = Button.new()
	primary_action_button.custom_minimum_size = Vector2(0, 58)
	primary_action_button.pressed.connect(_emit_primary_action)
	detail_stack.add_child(primary_action_button)
	secondary_action_button = Button.new()
	secondary_action_button.custom_minimum_size = Vector2(0, 54)
	secondary_action_button.pressed.connect(_emit_secondary_action)
	detail_stack.add_child(secondary_action_button)
	back_button = Button.new()
	back_button.text = "BACK TO BAZAAR"
	back_button.tooltip_text = "Return focus to the selected bazaar station."
	back_button.pressed.connect(_focus_selected_station)
	detail_stack.add_child(back_button)

	_configure_focus_cycle()
	_refresh_station_detail()

func _identity_card(parent: HBoxContainer, heading: String) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#111a1e"), Color("#32464d"), 1, 4, 6))
	parent.add_child(panel)
	var label := Label.new()
	label.text = "%s · —" % heading
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("#c8d1d1"))
	panel.add_child(label)
	return label

func _add_value_card(parent: VBoxContainer, value_id: String) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 49)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#1a262c"), Color("#34474e"), 1, 4, 5))
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	var title := Label.new()
	title.text = value_id.to_upper() if value_id != "money" else "ASHMARKS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color("#89999e"))
	row.add_child(title)
	var value := Label.new()
	value.text = "—"
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", Color("#f1e6cf"))
	row.add_child(value)
	value_labels[value_id] = value

func _layout_station_buttons() -> void:
	if bazaar_canvas == null or bazaar_canvas.size.x <= 0.0:
		return
	var width := bazaar_canvas.size.x
	var height := bazaar_canvas.size.y
	var positions := {
		"workshop": Vector2(18, 54),
		"signal_broker": Vector2(width - 172, 54),
		"quartermaster": Vector2(18, height - 164),
		"hiring_post": Vector2(width - 172, height - 220),
		"assignment_board": Vector2(width - 172, height - 154),
		"departure_gate": Vector2(width * 0.5 - 77, height - 68)
	}
	for station_id in STATION_ORDER:
		var button := station_buttons.get(station_id) as Button
		if button != null:
			button.position = positions[station_id]

func _configure_focus_cycle() -> void:
	for index in range(STATION_ORDER.size()):
		var button := station_buttons[STATION_ORDER[index]] as Button
		var previous := station_buttons[STATION_ORDER[(index - 1 + STATION_ORDER.size()) % STATION_ORDER.size()]] as Button
		var next := station_buttons[STATION_ORDER[(index + 1) % STATION_ORDER.size()]] as Button
		button.focus_previous = button.get_path_to(previous)
		button.focus_next = button.get_path_to(next)
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(next)
	primary_action_button.focus_neighbor_bottom = primary_action_button.get_path_to(secondary_action_button)
	secondary_action_button.focus_neighbor_top = secondary_action_button.get_path_to(primary_action_button)
	secondary_action_button.focus_neighbor_bottom = secondary_action_button.get_path_to(back_button)
	back_button.focus_neighbor_top = back_button.get_path_to(secondary_action_button)

func _select_station(station_id: String, activate_detail: bool) -> void:
	if station_id not in STATION_ORDER:
		return
	selected_station_id = station_id
	bazaar_canvas.selected_station_id = station_id
	bazaar_canvas.queue_redraw()
	_refresh_station_detail()
	if activate_detail:
		if not primary_action_button.disabled and primary_action_button.visible:
			primary_action_button.grab_focus()
		elif not secondary_action_button.disabled and secondary_action_button.visible:
			secondary_action_button.grab_focus()
		else:
			back_button.grab_focus()

func _station_view(station_id: String) -> Dictionary:
	return current_view.get("stations", {}).get(station_id, {})

func _action_config(action_key: String) -> Dictionary:
	return _station_view(selected_station_id).get(action_key, {})

func _refresh_station_detail() -> void:
	if detail_title == null:
		return
	var station := _station_view(selected_station_id)
	detail_title.text = String(station.get("title", STATION_NAMES.get(selected_station_id, selected_station_id))).to_upper()
	detail_status.text = String(station.get("status", "INSPECT AVAILABLE SERVICES")).to_upper()
	detail_body.text = String(station.get("body", "This station has no current offer."))
	var primary := _action_config("primary")
	current_primary_action_id = String(primary.get("id", ""))
	primary_action_button.visible = not current_primary_action_id.is_empty()
	primary_action_button.text = String(primary.get("label", "CONTINUE"))
	primary_action_button.disabled = not bool(primary.get("enabled", true))
	primary_action_button.tooltip_text = String(primary.get("tooltip", ""))
	var secondary := _action_config("secondary")
	current_secondary_action_id = String(secondary.get("id", ""))
	secondary_action_button.visible = not current_secondary_action_id.is_empty()
	secondary_action_button.text = String(secondary.get("label", "BACK"))
	secondary_action_button.disabled = not bool(secondary.get("enabled", true))
	secondary_action_button.tooltip_text = String(secondary.get("tooltip", ""))
	if not secondary_action_button.visible:
		primary_action_button.focus_neighbor_bottom = primary_action_button.get_path_to(back_button)
		back_button.focus_neighbor_top = back_button.get_path_to(primary_action_button)
	else:
		primary_action_button.focus_neighbor_bottom = primary_action_button.get_path_to(secondary_action_button)
		back_button.focus_neighbor_top = back_button.get_path_to(secondary_action_button)

func _emit_primary_action() -> void:
	if current_primary_action_id.is_empty() or primary_action_button.disabled:
		return
	action_requested.emit(selected_station_id, current_primary_action_id)

func _emit_secondary_action() -> void:
	if current_secondary_action_id.is_empty() or secondary_action_button.disabled:
		return
	action_requested.emit(selected_station_id, current_secondary_action_id)

func _focus_selected_station() -> void:
	var button := station_buttons.get(selected_station_id) as Button
	if button != null:
		button.grab_focus()

func focus_default() -> void:
	var preferred := String(current_view.get("preferred_station", "assignment_board"))
	if preferred not in STATION_ORDER:
		preferred = "assignment_board"
	selected_station_id = preferred
	_refresh_station_detail()
	_focus_selected_station()

func configure(view: Dictionary) -> void:
	current_view = view.duplicate(true)
	location_label.text = "%s · FORTRESS AT REST" % String(view.get("location_name", "SETTLEMENT")).to_upper()
	context_label.text = String(view.get("context", "FORTRESS AT REST · Choose one place in the bazaar."))
	place_identity_label.text = "PLACE · %s" % String(view.get("place_identity", "A working stop on the long road."))
	pressure_label.text = "PRESSURE · %s" % String(view.get("operational_pressure", "No local pressure reported."))
	route_meaning_label.text = "OUTBOUND ROADS · %s" % String(view.get("route_meaning", "Review the route table before departure."))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels.keys():
		var label := value_labels[value_id] as Label
		label.text = String(values.get(value_id, "—"))
		label.add_theme_color_override("font_color", _value_color(value_id, label.text))
	for station_id in STATION_ORDER:
		var button := station_buttons[station_id] as Button
		var station := _station_view(station_id)
		var status := String(station.get("button_status", station.get("status", "OPEN"))).to_upper()
		button.text = "%s\n%s" % [String(STATION_NAMES[station_id]), status]
		button.tooltip_text = String(station.get("tooltip", station.get("body", "Inspect this bazaar station.")))
		_apply_station_style(button, station_id == selected_station_id, String(station.get("tone", "neutral")))
	_refresh_station_detail()
	bazaar_canvas.location_id = String(view.get("location_id", "ashgate_depot"))
	bazaar_canvas.selected_station_id = selected_station_id
	bazaar_canvas.fortress_view = view.get("fortress", {}).duplicate(true)
	bazaar_canvas.high_contrast_enabled = high_contrast_enabled
	bazaar_canvas.queue_redraw()

func _value_color(value_id: String, value: String) -> Color:
	if value_id in ["hull", "fuel", "heat"] and ("CRITICAL" in value or value.begins_with("0")):
		return Color("#ef8375")
	if value_id == "context":
		return Color("#9fd2c2")
	return Color("#f1e6cf")

func _apply_station_style(button: Button, selected: bool, tone: String) -> void:
	var fill := Color("#23323a")
	var border := Color("#52676f")
	if tone == "safe":
		fill = Color("#24443b")
		border = Color("#73c99b")
	elif tone == "warning":
		fill = Color("#4c3c28")
		border = Color("#e8c58e")
	elif tone == "muted":
		fill = Color("#1b2428")
		border = Color("#445157")
	if selected:
		border = Color.WHITE if high_contrast_enabled else Color("#f3dfad")
	button.add_theme_stylebox_override("normal", _flat_style(fill.darkened(0.30) if high_contrast_enabled else fill, border, 3 if selected else 2, 5, 6))
	button.add_theme_stylebox_override("hover", _flat_style(fill.lightened(0.08), Color.WHITE, 3, 5, 5))
	button.add_theme_stylebox_override("pressed", _flat_style(fill.darkened(0.12), Color.WHITE, 3, 5, 5))
	button.add_theme_stylebox_override("focus", _flat_style(fill, Color.WHITE, 4, 5, 4))

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if bazaar_canvas != null:
		bazaar_canvas.high_contrast_enabled = enabled
	configure(current_view)

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class BazaarCanvas extends Control:
	var location_id: String = "ashgate_depot"
	var selected_station_id: String = "assignment_board"
	var fortress_view: Dictionary = {}
	var high_contrast_enabled: bool = false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS

	func _draw() -> void:
		var flooded := location_id == "lantern_quay"
		var sky := Color("#080d10") if high_contrast_enabled else (Color("#17363d") if flooded else Color("#1b292f"))
		var haze := Color("#27363a") if high_contrast_enabled else (Color("#35575c") if flooded else Color("#485052"))
		var ground := Color("#17120e") if high_contrast_enabled else (Color("#10282c") if flooded else Color("#342a21"))
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.72, size.y * 0.18), 72.0, Color(0.82, 0.66, 0.42, 0.12))
		for index in range(7):
			var ridge_y := size.y * (0.26 + index * 0.015)
			draw_line(Vector2(0, ridge_y), Vector2(size.x, ridge_y - 14 + index * 3), haze.darkened(float(index) * 0.035), 18.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.58), Vector2(size.x, size.y * 0.42)), ground, true)
		_draw_place_features(flooded)
		_draw_bazaar_activity(flooded)
		_draw_station_connections()
		_draw_stall(Rect2(Vector2(6, 20), Vector2(190, 128)), "workshop")
		_draw_stall(Rect2(Vector2(size.x - 196, 20), Vector2(190, 128)), "signal_broker")
		_draw_stall(Rect2(Vector2(0, size.y - 205), Vector2(190, 145)), "quartermaster")
		_draw_stall(Rect2(Vector2(size.x - 196, size.y - 260), Vector2(190, 198)), "assignment_board")
		_draw_fortress()
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 90, size.y * 0.77), "FORTRESS AT REST", HORIZONTAL_ALIGNMENT_CENTER, 180, 12, Color("#cdbb95"))

	func selected_station_signature() -> String:
		return "%s · FORTRESS SERVICE LINK" % String(STATION_NAMES.get(selected_station_id, selected_station_id)).to_upper()

	func _draw_station_connections() -> void:
		var fortress_center := Vector2(size.x * 0.50, size.y * 0.52)
		var targets := {
			"workshop": Vector2(101.0, 148.0),
			"signal_broker": Vector2(size.x - 101.0, 148.0),
			"quartermaster": Vector2(101.0, size.y - 205.0),
			"hiring_post": Vector2(size.x - 101.0, size.y - 260.0),
			"assignment_board": Vector2(size.x - 101.0, size.y - 160.0),
			"departure_gate": Vector2(size.x * 0.50, size.y - 74.0)
		}
		var target: Vector2 = targets.get(selected_station_id, fortress_center)
		var route_color := Color.WHITE if high_contrast_enabled else Color("#d4b06e")
		var faint := route_color
		faint.a = 0.22
		draw_dashed_line(fortress_center, target, faint, 3.0, 9.0)
		draw_circle(target, 9.0, Color(0.94, 0.77, 0.48, 0.12))
		draw_arc(target, 12.0, 0, TAU, 20, route_color, 2.0)

	func _draw_bazaar_activity(flooded: bool) -> void:
		var lamp_color := Color("#a8ece4") if flooded else Color("#ffd27d")
		for lamp_ratio in [0.12, 0.34, 0.66, 0.88]:
			var lamp := Vector2(size.x * lamp_ratio, size.y * 0.49)
			draw_line(lamp - Vector2(0, 34), lamp, Color("#756348"), 3.0)
			draw_circle(lamp, 4.5, lamp_color)
			draw_circle(lamp, 12.0, Color(lamp_color.r, lamp_color.g, lamp_color.b, 0.08))
		for person_ratio in [0.20, 0.31, 0.69, 0.80]:
			var person := Vector2(size.x * person_ratio, size.y * 0.70)
			draw_circle(person - Vector2(0, 13), 4.0, Color("#cab58a"))
			draw_line(person - Vector2(0, 8), person + Vector2(0, 10), Color("#766653"), 4.0)
			draw_line(person + Vector2(0, 1), person + Vector2(-6, 13), Color("#766653"), 3.0)
			draw_line(person + Vector2(0, 1), person + Vector2(6, 13), Color("#766653"), 3.0)
		for crate_index in range(3):
			var crate := Rect2(Vector2(size.x * 0.06 + float(crate_index) * 25.0, size.y * 0.52 - float(crate_index % 2) * 14.0), Vector2(22.0, 20.0))
			draw_rect(crate, Color("#694d35"), true)
			draw_rect(crate, Color("#ad8553"), false, 2.0)
			draw_line(crate.position, crate.end, Color("#ad8553"), 1.0)

	func _draw_place_features(flooded: bool) -> void:
		if flooded:
			var dock := Color("#5c827d") if not high_contrast_enabled else Color("#bfe5df")
			draw_line(Vector2(0, size.y * 0.68), Vector2(size.x, size.y * 0.68), dock, 7.0)
			var support_ratios: Array[float] = [0.08, 0.22, 0.78, 0.92]
			for x_ratio: float in support_ratios:
				var x: float = size.x * x_ratio
				draw_line(Vector2(x, size.y * 0.68), Vector2(x - 12.0, size.y * 0.92), dock.darkened(0.25), 5.0)
			for lantern_x in [size.x * 0.18, size.x * 0.82]:
				draw_line(Vector2(lantern_x, size.y * 0.23), Vector2(lantern_x, size.y * 0.34), dock, 3.0)
				draw_circle(Vector2(lantern_x, size.y * 0.36), 7.0, Color("#ffd47f"))
		else:
			var rail := Color("#8d744d") if not high_contrast_enabled else Color("#f2dda2")
			for rail_y in [size.y * 0.69, size.y * 0.82]:
				draw_line(Vector2(0, rail_y), Vector2(size.x, rail_y), rail.darkened(0.15), 5.0)
			for sleeper_index in range(10):
				var x := float(sleeper_index) * size.x / 9.0
				draw_line(Vector2(x, size.y * 0.66), Vector2(x + 22.0, size.y * 0.86), rail.darkened(0.30), 4.0)
			draw_line(Vector2(size.x * 0.50, size.y * 0.16), Vector2(size.x * 0.50, size.y * 0.30), rail, 5.0)
			draw_line(Vector2(size.x * 0.50, size.y * 0.16), Vector2(size.x * 0.61, size.y * 0.12), rail, 4.0)
		_draw_route_sign(flooded)

	func _draw_route_sign(flooded: bool) -> void:
		var post_color := Color("#bfe5df") if flooded else Color("#d0ad6d")
		var sign_center := Vector2(size.x * 0.50, size.y * 0.13)
		draw_line(sign_center, sign_center + Vector2(0, 64), post_color.darkened(0.25), 4.0)
		var left_sign := Rect2(sign_center + Vector2(-132, 4), Vector2(126, 25))
		var right_sign := Rect2(sign_center + Vector2(6, 33), Vector2(126, 25))
		for sign_rect in [left_sign, right_sign]:
			draw_rect(sign_rect, Color("#162328") if flooded else Color("#34291f"), true)
			draw_rect(sign_rect, post_color, false, 2.0)
		var labels := ["PUMP GALLERY", "TRAMWORKS"] if flooded else ["RILL CROSSING", "SOOT ORCHARD"]
		draw_string(ThemeDB.fallback_font, left_sign.position + Vector2(5, 17), "← %s" % labels[0], HORIZONTAL_ALIGNMENT_CENTER, left_sign.size.x - 10, 9, post_color)
		draw_string(ThemeDB.fallback_font, right_sign.position + Vector2(5, 17), "%s →" % labels[1], HORIZONTAL_ALIGNMENT_CENTER, right_sign.size.x - 10, 9, post_color)

	func presentation_signature() -> String:
		return "LANTERN QUAY · FLOOD DOCK · HANGING LAMPS" if location_id == "lantern_quay" else "ASHGATE DEPOT · BLACK RAILS · SIGNAL GANTRY"

	func route_signature() -> String:
		return "PUMP GALLERY · SUNKEN TRAMWORKS" if location_id == "lantern_quay" else "RILL CROSSING · SOOT ORCHARD"

	func _draw_stall(rect: Rect2, station_id: String) -> void:
		var selected := station_id == selected_station_id
		var fill := Color("#2b2420")
		var border := Color("#725c42")
		if station_id == "signal_broker":
			fill = Color("#1b3134")
			border = Color("#5e9b91")
		elif station_id == "assignment_board":
			fill = Color("#332b20")
			border = Color("#b69555")
		if selected:
			border = Color.WHITE if high_contrast_enabled else Color("#f0cf96")
		draw_rect(rect, fill.darkened(0.30) if high_contrast_enabled else fill, true)
		draw_rect(rect, border, false, 3.0 if selected else 2.0)
		var canopy := PackedVector2Array([
			rect.position + Vector2(-5.0, 2.0),
			rect.position + Vector2(rect.size.x * 0.5, -18.0),
			rect.position + Vector2(rect.size.x + 5.0, 2.0)
		])
		draw_polyline(canopy, border, 5.0 if selected else 3.0)
		draw_line(rect.position + Vector2(0, 22), rect.position + Vector2(rect.size.x, 22), border, 2.0)
		for raw_post_x in [rect.position.x + 18, rect.end.x - 18]:
			var post_x: float = float(raw_post_x)
			draw_line(Vector2(post_x, rect.position.y), Vector2(post_x, rect.end.y), border.darkened(0.25), 5.0)
		var icon_rect := Rect2(rect.get_center() - Vector2(19.0, 10.0), Vector2(38.0, 38.0))
		FortressSilhouette.draw_family_mark(self, icon_rect, _station_family(station_id), border.lightened(0.18))
		if selected:
			draw_circle(rect.position + Vector2(rect.size.x * 0.5, 9.0), 5.0, Color("#ffe2a0"))

	func _station_family(station_id: String) -> String:
		match station_id:
			"workshop": return "workshop"
			"quartermaster": return "cargo"
			"signal_broker": return "signal"
			"hiring_post": return "crew_room"
			"assignment_board": return "armor"
			_: return "engine"

	func _draw_fortress() -> void:
		var view := fortress_view.duplicate(true)
		view["mode"] = "rest"
		view["high_contrast"] = high_contrast_enabled
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.22, size.y * 0.23), Vector2(size.x * 0.56, size.y * 0.50)), view)
