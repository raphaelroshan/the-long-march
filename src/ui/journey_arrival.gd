class_name JourneyArrivalView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

signal pause_requested
signal continue_requested

var pause_button: Button
var route_label: Label
var receipt_labels: Dictionary = {}
var arrival_canvas: ArrivalCanvas
var outcome_label: Label
var beat_label: Label
var destination_label: Label
var summary_label: Label
var recovery_priority_label: Label
var report_label: Label
var next_label: Label
var continue_button: Button
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
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	route_label = Label.new()
	route_label.text = "ROAD RESOLVED"
	route_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	route_label.add_theme_font_size_override("font_size", 13)
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
	var receipt_panel := PanelContainer.new()
	receipt_panel.custom_minimum_size = Vector2(205, 0)
	receipt_panel.add_theme_stylebox_override("panel", _flat_style(Color("#121d22"), Color("#35484f"), 1, 6, 10))
	body.add_child(receipt_panel)
	var receipt_stack := VBoxContainer.new()
	receipt_stack.add_theme_constant_override("separation", 9)
	receipt_panel.add_child(receipt_stack)
	var receipt_heading := Label.new()
	receipt_heading.text = "ARRIVAL RECEIPT"
	receipt_heading.add_theme_font_size_override("font_size", 14)
	receipt_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	receipt_stack.add_child(receipt_heading)
	for receipt_id in ["outcome", "hull", "ashmarks", "pressure", "systems"]:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _flat_style(Color("#18242a"), Color("#31434a"), 1, 4, 6))
		receipt_stack.add_child(panel)
		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 1)
		panel.add_child(stack)
		var key := Label.new()
		key.text = receipt_id.to_upper()
		key.add_theme_font_size_override("font_size", 9)
		key.add_theme_color_override("font_color", Color("#89999e"))
		stack.add_child(key)
		var value := Label.new()
		value.text = "—"
		value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value.add_theme_font_size_override("font_size", 13)
		value.add_theme_color_override("font_color", Color("#f1e6cf"))
		stack.add_child(value)
		receipt_labels[receipt_id] = value
	var receipt_note := Label.new()
	receipt_note.text = "This receipt records consequences already applied by the resolved road."
	receipt_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	receipt_note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	receipt_note.add_theme_font_size_override("font_size", 10)
	receipt_note.add_theme_color_override("font_color", Color("#89999e"))
	receipt_stack.add_child(receipt_note)
	arrival_canvas = ArrivalCanvas.new()
	arrival_canvas.custom_minimum_size = Vector2(600, 520)
	arrival_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrival_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(arrival_canvas)
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(320, 0)
	detail_panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d21"), Color("#596d72"), 2, 6, 11))
	body.add_child(detail_panel)
	var detail_stack := VBoxContainer.new()
	detail_stack.add_theme_constant_override("separation", 9)
	detail_panel.add_child(detail_stack)
	var kicker := Label.new()
	kicker.text = "ROAD OUTCOME"
	kicker.add_theme_font_size_override("font_size", 9)
	kicker.add_theme_color_override("font_color", Color("#89999e"))
	detail_stack.add_child(kicker)
	outcome_label = Label.new()
	outcome_label.text = "ARRIVAL"
	outcome_label.add_theme_font_size_override("font_size", 19)
	outcome_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	detail_stack.add_child(outcome_label)
	beat_label = Label.new()
	beat_label.text = "ARRIVAL · CONSEQUENCES APPLIED"
	beat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	beat_label.add_theme_font_size_override("font_size", 10)
	beat_label.add_theme_color_override("font_color", Color("#f0cf96"))
	detail_stack.add_child(beat_label)
	destination_label = Label.new()
	destination_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	destination_label.add_theme_font_size_override("font_size", 22)
	destination_label.add_theme_color_override("font_color", Color("#e8c58e"))
	detail_stack.add_child(destination_label)
	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size", 12)
	summary_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	detail_stack.add_child(summary_label)
	var priority_panel := PanelContainer.new()
	priority_panel.add_theme_stylebox_override("panel", _flat_style(Color("#2a211b"), Color("#b07b4e"), 1, 5, 7))
	detail_stack.add_child(priority_panel)
	recovery_priority_label = Label.new()
	recovery_priority_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_priority_label.add_theme_font_size_override("font_size", 10)
	recovery_priority_label.add_theme_color_override("font_color", Color("#f2d49f"))
	priority_panel.add_child(recovery_priority_label)
	var report_heading := Label.new()
	report_heading.text = "LAST ROAD EFFECTS"
	report_heading.add_theme_font_size_override("font_size", 9)
	report_heading.add_theme_color_override("font_color", Color("#89999e"))
	detail_stack.add_child(report_heading)
	report_label = Label.new()
	report_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	report_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report_label.add_theme_font_size_override("font_size", 11)
	report_label.add_theme_color_override("font_color", Color("#aebbbc"))
	detail_stack.add_child(report_label)
	next_label = Label.new()
	next_label.text = "NEXT · Acknowledge the receipt."
	next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_label.add_theme_font_size_override("font_size", 10)
	next_label.add_theme_color_override("font_color", Color("#e7d6b4"))
	detail_stack.add_child(next_label)
	continue_button = Button.new()
	continue_button.text = "ENTER LOCATION"
	continue_button.custom_minimum_size = Vector2(0, 62)
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	detail_stack.add_child(continue_button)

func configure(view: Dictionary) -> void:
	current_view = view.duplicate(true)
	var origin := String(view.get("origin_name", "ROAD"))
	var destination := String(view.get("destination_name", "SAFE STOP"))
	var retreat := bool(view.get("retreat", false))
	route_label.text = "%s → %s · %s" % [origin.to_upper(), destination.to_upper(), "RETREAT COMPLETE" if retreat else "ROAD RESOLVED"]
	outcome_label.text = String(view.get("outcome_label", "ARRIVAL")).to_upper()
	outcome_label.add_theme_color_override("font_color", Color("#ef9a84") if retreat else Color("#9fd2c2"))
	beat_label.text = "RECOVERY · RETREAT COMPLETE · CONSEQUENCES APPLIED" if retreat else "ARRIVAL · ROAD SECURED · CONSEQUENCES APPLIED"
	destination_label.text = destination.to_upper()
	summary_label.text = String(view.get("summary", "The fortress has reached the next stop."))
	recovery_priority_label.text = String(view.get("recovery_priority", "RECOVERY PRIORITY · Review the fortress before the next road."))
	var report: Array = view.get("report", [])
	report_label.text = "• " + "\n• ".join(report) if not report.is_empty() else "• The road is quiet behind the fortress."
	next_label.text = String(view.get("next_decision", "NEXT · Acknowledge the receipt."))
	var receipts: Dictionary = view.get("receipts", {})
	for receipt_id in receipt_labels:
		receipt_labels[receipt_id].text = String(receipts.get(receipt_id, "—"))
	continue_button.text = String(view.get("action_label", "ENTER LOCATION"))
	arrival_canvas.current_view = current_view
	arrival_canvas.high_contrast_enabled = high_contrast_enabled
	arrival_canvas.queue_redraw()

func focus_default() -> void:
	continue_button.grab_focus()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if arrival_canvas != null:
		arrival_canvas.high_contrast_enabled = enabled
		arrival_canvas.queue_redraw()

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class ArrivalCanvas extends Control:
	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		var retreat := bool(current_view.get("retreat", false))
		var sky := Color("#071013") if high_contrast_enabled else (Color("#17383f") if flooded else Color("#353b3b"))
		var ground := Color("#10282c") if flooded else Color("#33291f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.72, size.y * 0.17), 62.0, Color(0.96, 0.78, 0.48, 0.20))
		for ridge in range(4):
			var y := size.y * (0.30 + ridge * 0.05)
			draw_line(Vector2(0, y), Vector2(size.x, y - 24.0 + ridge * 8.0), Color("#3c5b60") if flooded else Color("#665d4f"), 26.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.62), Vector2(size.x, size.y * 0.38)), ground, true)
		_draw_destination(retreat)
		_draw_resting_fortress(retreat)
		var caption := "SAFE STOP REGAINED" if retreat else "FORTRESS AT REST · ROAD SECURED"
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 18), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, Color("#e2cc98"))

	func _draw_destination(retreat: bool) -> void:
		var base_x := size.x * 0.72
		var base_y := size.y * 0.62
		var wall := Color("#50544d") if not retreat else Color("#4d4540")
		draw_rect(Rect2(Vector2(base_x - 80, base_y - 116), Vector2(170, 116)), wall, true)
		draw_rect(Rect2(Vector2(base_x - 92, base_y - 135), Vector2(46, 135)), wall.darkened(0.08), true)
		draw_rect(Rect2(Vector2(base_x + 48, base_y - 150), Vector2(54, 150)), wall.darkened(0.10), true)
		draw_rect(Rect2(Vector2(base_x - 18, base_y - 55), Vector2(42, 55)), Color("#171c1c"), true)
		for lamp_x in [base_x - 62.0, base_x + 71.0]:
			draw_circle(Vector2(lamp_x, base_y - 82), 7.0, Color("#e4a958"))

	func _draw_resting_fortress(retreat: bool) -> void:
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		view["mode"] = "arrival"
		view["high_contrast"] = high_contrast_enabled
		if retreat:
			view["damaged_count"] = maxi(1, int(view.get("damaged_count", 0)))
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.05, size.y * 0.31), Vector2(size.x * 0.52, size.y * 0.43)), view)
