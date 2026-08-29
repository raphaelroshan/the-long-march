class_name JourneyTransitionView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

signal pause_requested
signal continue_requested

var pause_button: Button
var route_label: Label
var day_label: Label
var fuel_label: Label
var pressure_label: Label
var heat_label: Label
var march_canvas: MarchCanvas
var destination_label: Label
var status_label: Label
var detail_label: Label
var sequence_labels: Array[Label] = []
var continue_button: Button
var high_contrast_enabled: bool = false
var reduced_motion: bool = false
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
	background.color = Color("#10171b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
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
	route_label = Label.new()
	route_label.text = "ON THE ROAD"
	route_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	route_label.add_theme_font_size_override("font_size", 14)
	route_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(route_label)
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
	var value_panel := PanelContainer.new()
	value_panel.custom_minimum_size = Vector2(200, 0)
	value_panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d22"), Color("#34474e"), 1, 6, 10))
	body.add_child(value_panel)
	var value_stack := VBoxContainer.new()
	value_stack.add_theme_constant_override("separation", 9)
	value_panel.add_child(value_stack)
	var value_heading := Label.new()
	value_heading.text = "DEPARTURE RECEIPT"
	value_heading.add_theme_font_size_override("font_size", 15)
	value_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	value_stack.add_child(value_heading)
	day_label = _add_receipt(value_stack, "TIME")
	fuel_label = _add_receipt(value_stack, "FUEL")
	pressure_label = _add_receipt(value_stack, "PRESSURE")
	heat_label = _add_receipt(value_stack, "HEAT")
	var receipt_note := Label.new()
	receipt_note.text = "Costs are already committed.\nThe destination is not secured until this road contact resolves."
	receipt_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	receipt_note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	receipt_note.add_theme_font_size_override("font_size", 11)
	receipt_note.add_theme_color_override("font_color", Color("#9aa8aa"))
	value_stack.add_child(receipt_note)
	march_canvas = MarchCanvas.new()
	march_canvas.custom_minimum_size = Vector2(650, 520)
	march_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	march_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(march_canvas)
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(310, 0)
	detail_panel.add_theme_stylebox_override("panel", _flat_style(Color("#151d21"), Color("#536a70"), 2, 6, 12))
	body.add_child(detail_panel)
	var detail_stack := VBoxContainer.new()
	detail_stack.add_theme_constant_override("separation", 9)
	detail_panel.add_child(detail_stack)
	var kicker := Label.new()
	kicker.text = "ROAD CONTACT"
	kicker.add_theme_font_size_override("font_size", 10)
	kicker.add_theme_color_override("font_color", Color("#89999e"))
	detail_stack.add_child(kicker)
	destination_label = Label.new()
	destination_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	destination_label.add_theme_font_size_override("font_size", 20)
	destination_label.add_theme_color_override("font_color", Color("#e8c58e"))
	detail_stack.add_child(destination_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("#efb879"))
	detail_stack.add_child(status_label)
	detail_label = Label.new()
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_label.add_theme_font_size_override("font_size", 13)
	detail_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	detail_stack.add_child(detail_label)
	var sequence_heading := Label.new()
	sequence_heading.text = "JOURNEY SEQUENCE"
	sequence_heading.add_theme_font_size_override("font_size", 10)
	sequence_heading.add_theme_color_override("font_color", Color("#89999e"))
	detail_stack.add_child(sequence_heading)
	for step_text in ["01  DEPARTED", "02  ROAD IN MOTION", "03  CONTACT AHEAD", "04  ARRIVAL PENDING"]:
		var step_label := Label.new()
		step_label.text = step_text
		step_label.add_theme_font_size_override("font_size", 11)
		sequence_labels.append(step_label)
		detail_stack.add_child(step_label)
	continue_button = Button.new()
	continue_button.text = "CONTINUE TO CONTACT"
	continue_button.custom_minimum_size = Vector2(0, 62)
	continue_button.tooltip_text = "Enter the road encounter. Arrival remains pending until it is resolved."
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	detail_stack.add_child(continue_button)

func _add_receipt(parent: VBoxContainer, heading: String) -> Label:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#1a262c"), Color("#34474e"), 1, 4, 6))
	parent.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	panel.add_child(stack)
	var title := Label.new()
	title.text = heading
	title.add_theme_font_size_override("font_size", 9)
	title.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(title)
	var value := Label.new()
	value.text = "—"
	value.add_theme_font_size_override("font_size", 15)
	value.add_theme_color_override("font_color", Color("#f1e6cf"))
	stack.add_child(value)
	return value

func configure(view: Dictionary) -> void:
	current_view = view.duplicate(true)
	var origin := String(view.get("origin_name", "ORIGIN"))
	var destination := String(view.get("destination_name", "DESTINATION"))
	route_label.text = "%s → %s · ON THE ROAD" % [origin.to_upper(), destination.to_upper()]
	destination_label.text = destination.to_upper()
	status_label.text = String(view.get("status", "CONTACT AHEAD")).to_upper()
	detail_label.text = String(view.get("detail", "The fortress has committed to the road. Resolve the contact before arrival."))
	day_label.text = String(view.get("day_receipt", "—"))
	fuel_label.text = String(view.get("fuel_receipt", "—"))
	pressure_label.text = String(view.get("pressure_receipt", "—"))
	heat_label.text = String(view.get("heat_receipt", "—"))
	continue_button.text = String(view.get("action_label", "CONTINUE TO CONTACT"))
	march_canvas.region_id = String(view.get("region_id", "ashgate_lowlands"))
	march_canvas.destination_name = destination
	march_canvas.fortress_view = view.get("fortress", {}).duplicate(true)
	march_canvas.high_contrast_enabled = high_contrast_enabled
	march_canvas.reduced_motion = reduced_motion
	march_canvas.queue_redraw()
	for index in range(sequence_labels.size()):
		sequence_labels[index].add_theme_color_override("font_color", Color("#9fd2c2") if index <= 2 else Color("#69777c"))

func focus_default() -> void:
	continue_button.grab_focus()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if march_canvas != null:
		march_canvas.high_contrast_enabled = enabled
		march_canvas.queue_redraw()

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if march_canvas != null:
		march_canvas.reduced_motion = enabled

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class MarchCanvas extends Control:
	var region_id: String = "ashgate_lowlands"
	var destination_name: String = ""
	var high_contrast_enabled: bool = false
	var reduced_motion: bool = false
	var travel_offset: float = 0.0
	var fortress_view: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_process(true)

	func _process(delta: float) -> void:
		if not reduced_motion:
			travel_offset = fmod(travel_offset + delta * 74.0, 96.0)
			queue_redraw()

	func _draw() -> void:
		var flooded := region_id == "flooded_veyru"
		var sky := Color("#071014") if high_contrast_enabled else (Color("#19333a") if flooded else Color("#293136"))
		var horizon := Color("#284e55") if flooded else Color("#5a5146")
		var ground := Color("#10262a") if flooded else Color("#30271f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.20), 58.0, Color(0.91, 0.72, 0.42, 0.16))
		for ridge_index in range(5):
			var ridge_y := size.y * (0.30 + ridge_index * 0.035)
			draw_line(Vector2(0, ridge_y), Vector2(size.x, ridge_y - 30 + ridge_index * 8), horizon.darkened(float(ridge_index) * 0.08), 28.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.58), Vector2(size.x, size.y * 0.42)), ground, true)
		for marker_index in range(-1, 9):
			var marker_x := fmod(float(marker_index * 96) - travel_offset, size.x + 96.0)
			if marker_x < -30.0:
				marker_x += size.x + 96.0
			var height := 44.0 + float((marker_index + 9) % 3) * 15.0
			draw_line(Vector2(marker_x, size.y * 0.58), Vector2(marker_x - 18, size.y * 0.58 - height), Color("#161a19"), 8.0)
			draw_line(Vector2(marker_x - 18, size.y * 0.58 - height), Vector2(marker_x - 35, size.y * 0.58 - height - 12), Color("#161a19"), 5.0)
		for road_index in range(9):
			var road_x := fmod(float(road_index * 96) - travel_offset * 1.7, size.x + 96.0)
			draw_line(Vector2(road_x, size.y * 0.82), Vector2(road_x + 46, size.y * 0.82), Color("#8b704d"), 5.0)
		_draw_fortress()
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 120, size.y - 22), "CONTACT BEFORE %s" % destination_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 240, 12, Color("#d7c08b"))

	func _draw_fortress() -> void:
		var view := fortress_view.duplicate(true)
		view["mode"] = "travel"
		view["travel_phase"] = travel_offset if not reduced_motion else 0.0
		view["high_contrast"] = high_contrast_enabled
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.22, size.y * 0.25), Vector2(size.x * 0.56, size.y * 0.48)), view)
