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
	continue_button.set_meta("long_march_audio_cue", "arrival_handoff")
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
	const DESTINATION_VISUALS := {
		"muster_recovery_siding": {"motif": "camp", "marker": "RECOVERY SIDING", "accent": "#d0a85f"},
		"rill_crossing": {"motif": "crossing", "marker": "BROKEN RAIL CROSSING", "accent": "#bd6b54"},
		"soot_orchard": {"motif": "salvage", "marker": "BLACKENED ORCHARD", "accent": "#c58b48"},
		"broken_relay": {"motif": "relay", "marker": "BROKEN RELAY", "accent": "#729eaa"},
		"red_wheel_toll_bridge": {"motif": "crossing", "marker": "RED WHEEL GANTRY", "accent": "#c75f55"},
		"morrowline_camp": {"motif": "camp", "marker": "MORROWLINE CONVOY", "accent": "#d3a561"},
		"lower_ash_road": {"motif": "industrial", "marker": "LOWER ASH CUT", "accent": "#a58458"},
		"dry_cistern_cut": {"motif": "industrial", "marker": "DRY CISTERN", "accent": "#c4a16c"},
		"signal_causeway": {"motif": "relay", "marker": "SIGNAL CAUSEWAY", "accent": "#6ca9a5"},
		"cinder_quarry": {"motif": "salvage", "marker": "CINDER QUARRY", "accent": "#b8784d"},
		"meridian_pass": {"motif": "finale", "marker": "MERIDIAN PASS", "accent": "#d6b06c"},
		"pump_gallery": {"motif": "industrial", "marker": "PUMP GALLERY", "accent": "#62a8aa"},
		"sunken_tramworks": {"motif": "industrial", "marker": "SUNKEN TRAMWORKS", "accent": "#6b9da3"},
		"veyru_evacuation_camp": {"motif": "camp", "marker": "EVACUATION PLATFORM", "accent": "#75b5ae"},
		"archive_causeway": {"motif": "crossing", "marker": "ARCHIVE CAUSEWAY", "accent": "#70aaa8"},
		"drowned_registry": {"motif": "salvage", "marker": "DROWNED REGISTRY", "accent": "#6c979e"},
		"pilgrim_gantry": {"motif": "crossing", "marker": "PILGRIM GANTRY", "accent": "#8cb7ab"},
		"dry_archive_gate": {"motif": "archive", "marker": "DRY ARCHIVE GATE", "accent": "#92bbb0"},
		"dry_archive": {"motif": "archive", "marker": "THE DRY ARCHIVE", "accent": "#b6c9ac"}
	}

	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false

	func arrival_visual_signature() -> Dictionary:
		var destination_id := String(current_view.get("destination_id", ""))
		var signature: Dictionary = Dictionary(DESTINATION_VISUALS.get(destination_id, {
			"motif": "finale" if String(current_view.get("destination_kind", "")) == "finale" else "outpost",
			"marker": String(current_view.get("destination_name", "SAFE STOP")).to_upper(),
			"accent": "#8da9a4" if String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru" else "#b49360"
		})).duplicate(true)
		signature["destination_id"] = destination_id
		signature["retreat"] = bool(current_view.get("retreat", false))
		return signature

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		var retreat := bool(current_view.get("retreat", false))
		var signature := arrival_visual_signature()
		var sky := Color("#071013") if high_contrast_enabled else (Color("#17383f") if flooded else Color("#353b3b"))
		var ground := Color("#10282c") if flooded else Color("#33291f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.72, size.y * 0.17), 62.0, Color(0.96, 0.78, 0.48, 0.20))
		for ridge in range(4):
			var y := size.y * (0.30 + ridge * 0.05)
			draw_line(Vector2(0, y), Vector2(size.x, y - 24.0 + ridge * 8.0), Color("#3c5b60") if flooded else Color("#665d4f"), 26.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.62), Vector2(size.x, size.y * 0.38)), ground, true)
		_draw_approach(flooded, signature)
		_draw_destination(retreat, flooded, signature)
		_draw_resting_fortress(retreat)
		var destination_name := String(current_view.get("destination_name", signature.get("marker", "SAFE STOP"))).to_upper()
		var caption := "SAFE STOP REGAINED · %s" % destination_name if retreat else "%s REACHED · ROAD SECURED" % destination_name
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 18), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, Color("#e2cc98"))

	func _draw_approach(flooded: bool, signature: Dictionary) -> void:
		var accent := Color(String(signature.get("accent", "#b49360")))
		if flooded:
			for wave_index in range(5):
				var wave_x := size.x * (0.48 + float(wave_index) * 0.11)
				draw_arc(Vector2(wave_x, size.y * 0.72), 18.0, PI, TAU, 12, accent.darkened(0.28), 2.0)
		else:
			for sleeper_index in range(5):
				var sleeper_x := size.x * (0.49 + float(sleeper_index) * 0.105)
				draw_line(Vector2(sleeper_x, size.y * 0.71), Vector2(sleeper_x + 32.0, size.y * 0.71), accent.darkened(0.42), 4.0)

	func _draw_destination(retreat: bool, flooded: bool, signature: Dictionary) -> void:
		var base_x := size.x * 0.72
		var base_y := size.y * 0.62
		var accent := Color.WHITE if high_contrast_enabled else Color(String(signature.get("accent", "#b49360")))
		var structure := Color("#54615e") if flooded else Color("#57564d")
		if retreat:
			accent = Color("#ef9a84") if not high_contrast_enabled else Color.WHITE
		match String(signature.get("motif", "outpost")):
			"crossing":
				_draw_crossing(base_x, base_y, structure, accent, flooded)
			"camp":
				_draw_camp(base_x, base_y, structure, accent, flooded)
			"relay":
				_draw_relay(base_x, base_y, structure, accent)
			"salvage":
				_draw_salvage(base_x, base_y, structure, accent, flooded)
			"industrial":
				_draw_industrial(base_x, base_y, structure, accent, flooded)
			"archive":
				_draw_archive(base_x, base_y, structure, accent, flooded)
			"finale":
				_draw_finale(base_x, base_y, structure, accent)
			_:
				_draw_outpost(base_x, base_y, structure, accent)
		var marker_width := minf(220.0, size.x * 0.34)
		var marker_rect := Rect2(Vector2(base_x - marker_width * 0.5, base_y - 188.0), Vector2(marker_width, 28.0))
		draw_rect(marker_rect, Color(0.06, 0.09, 0.10, 0.88), true)
		draw_rect(marker_rect, accent, false, 2.0)
		draw_string(ThemeDB.fallback_font, marker_rect.position + Vector2(0, 19.0), String(signature.get("marker", "SAFE STOP")), HORIZONTAL_ALIGNMENT_CENTER, marker_rect.size.x, 10, accent)

	func _draw_crossing(x: float, y: float, structure: Color, accent: Color, flooded: bool) -> void:
		for raw_side in [-1.0, 1.0]:
			var side: float = float(raw_side)
			var tower_x: float = x + side * 70.0
			draw_rect(Rect2(Vector2(tower_x - 13.0, y - 126.0), Vector2(26.0, 126.0)), structure.darkened(0.08), true)
			draw_line(Vector2(tower_x, y - 126.0), Vector2(tower_x, y - 151.0), accent, 3.0)
		draw_line(Vector2(x - 72.0, y - 92.0), Vector2(x - 12.0, y - 84.0), accent.darkened(0.22), 8.0)
		draw_line(Vector2(x + 14.0, y - 82.0), Vector2(x + 72.0, y - 92.0), accent.darkened(0.22), 8.0)
		draw_circle(Vector2(x, y - 58.0), 24.0, accent.darkened(0.38), false, 6.0)
		if flooded:
			draw_line(Vector2(x - 92.0, y - 12.0), Vector2(x + 92.0, y - 12.0), accent.darkened(0.34), 4.0)

	func _draw_camp(x: float, y: float, structure: Color, accent: Color, flooded: bool) -> void:
		var platform_y := y - (20.0 if flooded else 0.0)
		draw_line(Vector2(x - 105.0, platform_y), Vector2(x + 108.0, platform_y), accent.darkened(0.38), 8.0)
		for raw_side in [-1.0, 1.0]:
			var side: float = float(raw_side)
			var tent_x: float = x + side * 62.0
			var tent := PackedVector2Array([Vector2(tent_x - 42.0, platform_y), Vector2(tent_x, platform_y - 74.0), Vector2(tent_x + 42.0, platform_y)])
			draw_colored_polygon(tent, structure)
			draw_polyline(PackedVector2Array([tent[0], tent[1], tent[2]]), accent.darkened(0.22), 4.0)
		draw_rect(Rect2(Vector2(x - 24.0, platform_y - 43.0), Vector2(48.0, 43.0)), structure.darkened(0.12), true)
		draw_circle(Vector2(x, platform_y - 60.0), 7.0, accent)

	func _draw_relay(x: float, y: float, structure: Color, accent: Color) -> void:
		draw_rect(Rect2(Vector2(x - 88.0, y - 52.0), Vector2(176.0, 52.0)), structure.darkened(0.10), true)
		draw_line(Vector2(x - 15.0, y - 48.0), Vector2(x + 22.0, y - 151.0), accent.darkened(0.12), 7.0)
		draw_line(Vector2(x + 20.0, y - 146.0), Vector2(x + 70.0, y - 111.0), accent, 3.0)
		draw_arc(Vector2(x + 22.0, y - 148.0), 24.0, -0.9, 0.7, 12, accent, 3.0)
		draw_line(Vector2(x - 88.0, y - 34.0), Vector2(x + 88.0, y - 34.0), accent.darkened(0.38), 3.0)

	func _draw_salvage(x: float, y: float, structure: Color, accent: Color, flooded: bool) -> void:
		for index in range(3):
			var item_x := x - 72.0 + float(index) * 68.0
			var height := 72.0 + float(index % 2) * 34.0
			draw_line(Vector2(item_x, y), Vector2(item_x + 6.0, y - height), structure.darkened(0.16), 11.0)
			draw_line(Vector2(item_x + 5.0, y - height * 0.72), Vector2(item_x + 34.0, y - height * 0.88), accent.darkened(0.28), 5.0)
		for plate_index in range(3):
			draw_rect(Rect2(Vector2(x + 20.0 + plate_index * 12.0, y - 24.0 - plate_index * 13.0), Vector2(70.0, 9.0)), accent.darkened(0.40), true)
		if flooded:
			draw_line(Vector2(x - 105.0, y - 18.0), Vector2(x + 108.0, y - 18.0), accent.darkened(0.30), 3.0)

	func _draw_industrial(x: float, y: float, structure: Color, accent: Color, flooded: bool) -> void:
		for index in range(3):
			var tank_x := x - 76.0 + float(index) * 64.0
			var tank_height := 62.0 + float(index) * 17.0
			draw_rect(Rect2(Vector2(tank_x, y - tank_height), Vector2(42.0, tank_height)), structure.darkened(float(index) * 0.05), true)
			draw_arc(Vector2(tank_x + 21.0, y - tank_height), 21.0, PI, TAU, 12, accent.darkened(0.22), 4.0)
		draw_line(Vector2(x - 84.0, y - 36.0), Vector2(x + 86.0, y - 36.0), accent.darkened(0.32), 5.0)
		draw_circle(Vector2(x + 70.0, y - 66.0), 19.0, accent.darkened(0.32), false, 5.0)
		if flooded:
			draw_line(Vector2(x - 100.0, y - 12.0), Vector2(x + 104.0, y - 12.0), accent, 2.0)

	func _draw_archive(x: float, y: float, structure: Color, accent: Color, flooded: bool) -> void:
		draw_rect(Rect2(Vector2(x - 91.0, y - 128.0), Vector2(182.0, 128.0)), structure, true)
		for column_x in [x - 65.0, x + 65.0]:
			draw_rect(Rect2(Vector2(column_x - 13.0, y - 152.0), Vector2(26.0, 152.0)), structure.darkened(0.12), true)
		draw_rect(Rect2(Vector2(x - 25.0, y - 64.0), Vector2(50.0, 64.0)), Color("#11191a"), true)
		draw_circle(Vector2(x, y - 102.0), 12.0, accent, false, 4.0)
		if flooded:
			draw_line(Vector2(x - 105.0, y - 19.0), Vector2(x + 105.0, y - 19.0), accent.darkened(0.25), 4.0)

	func _draw_finale(x: float, y: float, structure: Color, accent: Color) -> void:
		for raw_side in [-1.0, 1.0]:
			var side: float = float(raw_side)
			var pillar_x: float = x + side * 70.0
			draw_rect(Rect2(Vector2(pillar_x - 19.0, y - 142.0), Vector2(38.0, 142.0)), structure.darkened(0.08), true)
			draw_line(Vector2(pillar_x, y - 142.0), Vector2(pillar_x + side * 28.0, y - 168.0), accent, 4.0)
		draw_rect(Rect2(Vector2(x - 72.0, y - 111.0), Vector2(144.0, 24.0)), structure, true)
		draw_rect(Rect2(Vector2(x - 28.0, y - 87.0), Vector2(56.0, 87.0)), Color("#11191a"), true)

	func _draw_outpost(x: float, y: float, structure: Color, accent: Color) -> void:
		draw_rect(Rect2(Vector2(x - 80.0, y - 116.0), Vector2(170.0, 116.0)), structure, true)
		draw_rect(Rect2(Vector2(x - 92.0, y - 135.0), Vector2(46.0, 135.0)), structure.darkened(0.08), true)
		draw_rect(Rect2(Vector2(x + 48.0, y - 150.0), Vector2(54.0, 150.0)), structure.darkened(0.10), true)
		draw_rect(Rect2(Vector2(x - 18.0, y - 55.0), Vector2(42.0, 55.0)), Color("#171c1c"), true)
		for lamp_x in [x - 62.0, x + 71.0]:
			draw_circle(Vector2(lamp_x, y - 82.0), 7.0, accent)

	func _draw_resting_fortress(retreat: bool) -> void:
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		view["mode"] = "arrival"
		view["high_contrast"] = high_contrast_enabled
		if retreat:
			view["damaged_count"] = maxi(1, int(view.get("damaged_count", 0)))
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.05, size.y * 0.31), Vector2(size.x * 0.52, size.y * 0.43)), view)
