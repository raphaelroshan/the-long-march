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
var promise_label: Label
var phase_label: Label
var detail_label: Label
var next_label: Label
var sequence_labels: Array[Label] = []
var continue_button: Button
var high_contrast_enabled: bool = false
var reduced_motion: bool = false
var current_view: Dictionary = {}
var presentation_beat_index: int = 0
var presentation_elapsed: float = 0.0

func _ready() -> void:
	_build_ui()
	set_process(true)


func _process(delta: float) -> void:
	if not visible or current_view.is_empty() or reduced_motion or presentation_beat_index >= 2:
		return
	presentation_elapsed += delta
	if presentation_elapsed >= 1.0:
		_set_presentation_beat(2)
	elif presentation_elapsed >= 0.35:
		_set_presentation_beat(1)

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
	receipt_note.text = "Costs are committed.\nArrival remains pending until contact resolves."
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
	kicker.text = "DEPARTURE ORDER"
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
	promise_label = Label.new()
	promise_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	promise_label.add_theme_font_size_override("font_size", 12)
	promise_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	detail_stack.add_child(promise_label)
	phase_label = Label.new()
	phase_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	phase_label.add_theme_font_size_override("font_size", 11)
	phase_label.add_theme_color_override("font_color", Color("#f0cf96"))
	detail_stack.add_child(phase_label)
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
	next_label = Label.new()
	next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_label.add_theme_font_size_override("font_size", 11)
	next_label.add_theme_color_override("font_color", Color("#e7d6b4"))
	detail_stack.add_child(next_label)
	continue_button = Button.new()
	continue_button.text = "CONTINUE TO CONTACT"
	continue_button.custom_minimum_size = Vector2(0, 62)
	continue_button.tooltip_text = "Enter the road encounter. Arrival remains pending until it is resolved."
	continue_button.set_meta("long_march_audio_cue", "contact_entry")
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
	presentation_elapsed = 0.0
	var origin := String(view.get("origin_name", "ORIGIN"))
	var destination := String(view.get("destination_name", "DESTINATION"))
	route_label.text = "%s → %s · ON THE ROAD" % [origin.to_upper(), destination.to_upper()]
	destination_label.text = destination.to_upper()
	promise_label.text = String(view.get("promise", "PROMISE · Keep the fortress moving."))
	phase_label.text = String(view.get("phase", "PHASE · DEPARTING · COSTS COMMITTED"))
	detail_label.text = String(view.get("detail", "The fortress has committed to the road. Resolve the contact before arrival."))
	day_label.text = String(view.get("day_receipt", "—"))
	fuel_label.text = String(view.get("fuel_receipt", "—"))
	pressure_label.text = String(view.get("pressure_receipt", "—"))
	heat_label.text = String(view.get("heat_receipt", "—"))
	march_canvas.region_id = String(view.get("region_id", "ashgate_lowlands"))
	march_canvas.destination_id = String(view.get("destination_visual_id", view.get("destination_id", "")))
	march_canvas.destination_name = destination
	march_canvas.contact_name = String(view.get("contact_name", "contact ahead"))
	march_canvas.fortress_view = view.get("fortress", {}).duplicate(true)
	march_canvas.high_contrast_enabled = high_contrast_enabled
	march_canvas.reduced_motion = reduced_motion
	march_canvas.travel_offset = 0.0
	march_canvas.queue_redraw()
	_set_presentation_beat(2 if reduced_motion else 0)


func _set_presentation_beat(index: int) -> void:
	presentation_beat_index = clampi(index, 0, 2)
	if march_canvas != null:
		march_canvas.presentation_beat_index = presentation_beat_index
		march_canvas.queue_redraw()
	for sequence_index in range(sequence_labels.size()):
		var color := Color("#69777c")
		if sequence_index < presentation_beat_index:
			color = Color("#9fddbd")
		elif sequence_index == presentation_beat_index:
			color = Color("#f0cf96")
		sequence_labels[sequence_index].add_theme_color_override("font_color", color)
	match presentation_beat_index:
		0:
			status_label.text = "DEPARTURE LOCKED"
			next_label.text = "NEXT · Skip the march beat or watch the fortress take the road."
			continue_button.text = String(current_view.get("skip_action_label", "SKIP MARCH · ENTER CONTACT"))
		1:
			status_label.text = "ROAD IN MOTION"
			next_label.text = String(current_view.get("motion_next", "NEXT · Contact is closing. Enter when ready."))
			continue_button.text = String(current_view.get("skip_action_label", "SKIP MARCH · ENTER CONTACT"))
		_:
			status_label.text = String(current_view.get("status", "CONTACT AHEAD")).to_upper()
			next_label.text = String(current_view.get("next_decision", "NEXT · Read the contact, then continue."))
			continue_button.text = String(current_view.get("action_label", "ENTER CONTACT"))
	continue_button.tooltip_text = "%s Arrival remains pending until the authoritative contact resolves." % next_label.text


func presentation_beat() -> String:
	return ["departed", "road_in_motion", "contact_ahead"][presentation_beat_index]

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
	if not current_view.is_empty():
		presentation_elapsed = 1.0 if enabled else 0.0
		_set_presentation_beat(2 if enabled else 0)

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class MarchCanvas extends Control:
	const TEMP_TRAVEL_DUST_A: Texture2D = preload("res://assets/temporary/kenney/particle-pack/smoke_01.png")
	const TEMP_TRAVEL_DUST_B: Texture2D = preload("res://assets/temporary/kenney/particle-pack/smoke_02.png")
	const ROUTE_VISUALS := {
		"muster_road": {"motif": "training", "marker": "MUSTER POSTS"},
		"rill_crossing": {"motif": "crossing", "marker": "BRIDGE RIBS"},
		"soot_orchard": {"motif": "orchard", "marker": "BLACKENED ORCHARD"},
		"broken_relay": {"motif": "relay", "marker": "BROKEN RELAY"},
		"red_wheel_toll_bridge": {"motif": "blockade", "marker": "RED WHEEL GANTRY"},
		"morrowline_camp": {"motif": "camp", "marker": "CONVOY CAMP"},
		"lower_ash_road": {"motif": "lower_cut", "marker": "LOWER-HULL STAKES"},
		"dry_cistern_cut": {"motif": "cistern", "marker": "BURIED CISTERNS"},
		"signal_causeway": {"motif": "relay", "marker": "CAUSEWAY PYLONS"},
		"cinder_quarry": {"motif": "quarry", "marker": "QUARRY TERRACES"},
		"meridian_pass": {"motif": "pass", "marker": "PASS PENNANTS"},
		"pump_gallery": {"motif": "pump", "marker": "GALLERY WHEEL"},
		"sunken_tramworks": {"motif": "tram", "marker": "SUNKEN RAILS"},
		"veyru_evacuation_camp": {"motif": "camp", "marker": "RAISED SHELTERS"},
		"archive_causeway": {"motif": "crossing", "marker": "ARCHIVE CAUSEWAY"},
		"drowned_registry": {"motif": "archive", "marker": "DROWNED STACKS"},
		"pilgrim_gantry": {"motif": "gantry", "marker": "PILGRIM GANTRY"},
		"dry_archive_gate": {"motif": "archive", "marker": "ARCHIVE GATE"},
		"dry_archive": {"motif": "archive", "marker": "DRY ARCHIVE"},
		"charcoal_monastery": {"motif": "monastery", "marker": "CHARCOAL BELLS"},
		"red_cut": {"motif": "pass", "marker": "RED CUT GRADES"},
		"old_lift_station": {"motif": "gantry", "marker": "OLD LIFT TOWERS"},
		"long_slope": {"motif": "pass", "marker": "LONG SLOPE"},
		"slag_tunnel": {"motif": "tunnel", "marker": "SLAG TUNNEL"},
		"ash_chapel_bypass": {"motif": "monastery", "marker": "ASH CHAPEL"},
		"lift_engine_house": {"motif": "gantry", "marker": "LIFT ENGINE"},
		"switchback_commune": {"motif": "gantry", "marker": "SWITCHBACK LIFT"}
	}

	var region_id: String = "ashgate_lowlands"
	var destination_id: String = ""
	var destination_name: String = ""
	var contact_name: String = "contact ahead"
	var high_contrast_enabled: bool = false
	var reduced_motion: bool = false
	var travel_offset: float = 0.0
	var presentation_beat_index: int = 0
	var fortress_view: Dictionary = {}

	func beat_visual_signature() -> String:
		if presentation_beat_index == 1:
			return "%s PASSING" % String(route_visual_signature().get("marker", "ROAD LANDMARK"))
		return ["GATE RECEDING", "ROAD LANDMARK PASSING", "CONTACT ON HORIZON"][clampi(presentation_beat_index, 0, 2)]

	func route_visual_signature() -> Dictionary:
		var profile: Dictionary = Dictionary(ROUTE_VISUALS.get(destination_id, {"motif": "road", "marker": "ROAD LANDMARK"})).duplicate(true)
		profile["destination_id"] = destination_id
		return profile

	func motion_signature() -> Dictionary:
		match clampi(presentation_beat_index, 0, 2):
			0:
				return {"pace": "gathering", "speed_scale": 0.32, "fortress_mode": "departing", "temporary_vfx": false}
			1:
				return {"pace": "full_march", "speed_scale": 1.0, "fortress_mode": "travel", "temporary_vfx": not reduced_motion}
			_:
				return {"pace": "contact_brace", "speed_scale": 0.0, "fortress_mode": "contact", "temporary_vfx": false}

	func temporary_travel_vfx_active() -> bool:
		return bool(motion_signature().get("temporary_vfx", false))

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true
		set_process(true)

	func _process(delta: float) -> void:
		if reduced_motion:
			return
		var speed_scale := float(motion_signature().get("speed_scale", 0.0))
		if speed_scale <= 0.0:
			return
		travel_offset = fmod(travel_offset + delta * 74.0 * speed_scale, 96.0)
		queue_redraw()

	func _draw() -> void:
		var flooded := region_id == "flooded_veyru"
		var cinder := region_id == "cinder_spine"
		var sky := Color("#071014") if high_contrast_enabled else (Color("#19333a") if flooded else (Color("#321716") if cinder else Color("#293136")))
		var far_horizon := Color("#1f4249") if flooded else (Color("#603026") if cinder else Color("#47463f"))
		var horizon := Color("#284e55") if flooded else (Color("#8b4a32") if cinder else Color("#625849"))
		var ground := Color("#10262a") if flooded else (Color("#281611") if cinder else Color("#30271f"))
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.18), 64.0, Color(0.91, 0.72, 0.42, 0.18))
		_draw_far_silhouette(far_horizon)
		for ridge_index in range(5):
			var ridge_y := size.y * (0.30 + ridge_index * 0.035)
			draw_line(Vector2(0, ridge_y), Vector2(size.x, ridge_y - 30 + ridge_index * 8), horizon.darkened(float(ridge_index) * 0.08), 28.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.58), Vector2(size.x, size.y * 0.42)), ground, true)
		_draw_road_edge(flooded, cinder)
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
		_draw_beat_landmark(flooded)
		_draw_travel_atmosphere(flooded)
		_draw_fortress()
		_draw_contact_horizon()
		var caption := "%s  ·  CONTACT BEFORE %s" % [beat_visual_signature(), destination_name.to_upper()]
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 210, size.y - 22), caption, HORIZONTAL_ALIGNMENT_CENTER, 420, 12, Color("#e1c98f"))

	func _draw_far_silhouette(color: Color) -> void:
		for tower_index in range(6):
			var x := fmod(float(tower_index) * 168.0 - travel_offset * 0.12, size.x + 180.0) - 40.0
			var height := 24.0 + float((tower_index + 1) % 3) * 16.0
			draw_rect(Rect2(Vector2(x, size.y * 0.29 - height), Vector2(28.0, height)), color.darkened(0.18), true)
			draw_line(Vector2(x + 14.0, size.y * 0.29 - height), Vector2(x + 14.0, size.y * 0.29 - height - 18.0), color, 3.0)

	func _draw_road_edge(flooded: bool, cinder: bool) -> void:
		var edge_color := Color("#66a6a3") if flooded else (Color("#bd673d") if cinder else Color("#806443"))
		draw_line(Vector2(0, size.y * 0.64), Vector2(size.x, size.y * 0.62), edge_color.darkened(0.22), 5.0)
		draw_line(Vector2(0, size.y * 0.92), Vector2(size.x, size.y * 0.92), edge_color.darkened(0.34), 4.0)
		if flooded:
			for wave_index in range(6):
				var wave_x := fmod(float(wave_index) * 142.0 - travel_offset * 0.9, size.x + 142.0)
				draw_arc(Vector2(wave_x, size.y * 0.72), 24.0, PI, TAU, 12, Color(0.39, 0.70, 0.72, 0.42), 3.0)
		elif cinder:
			for ember_index in range(7):
				var ember_x := fmod(float(ember_index) * 107.0 - travel_offset * 0.4, size.x + 107.0)
				draw_circle(Vector2(ember_x, size.y * (0.68 + float(ember_index % 3) * 0.07)), 3.0, Color(0.96, 0.36, 0.16, 0.48))

	func _draw_beat_landmark(flooded: bool) -> void:
		var accent := Color("#9fddd4") if flooded else Color("#d3aa68")
		match presentation_beat_index:
			0:
				var gate_x := 56.0 - travel_offset * 0.28
				draw_line(Vector2(gate_x, size.y * 0.57), Vector2(gate_x, size.y * 0.22), accent.darkened(0.32), 11.0)
				draw_line(Vector2(gate_x, size.y * 0.24), Vector2(gate_x + 96.0, size.y * 0.24), accent.darkened(0.16), 8.0)
				draw_string(ThemeDB.fallback_font, Vector2(gate_x + 7.0, size.y * 0.21), "DEPARTURE GATE", HORIZONTAL_ALIGNMENT_LEFT, 130.0, 10, accent)
			1:
				var landmark_x := fmod(size.x * 0.82 - travel_offset * 0.55, size.x + 220.0)
				_draw_route_landmark(landmark_x, size.y * 0.57, flooded, accent, route_visual_signature())
			2:
				for plume_index in range(3):
					var plume := Color(0.16, 0.12, 0.10, 0.34 - float(plume_index) * 0.06)
					draw_circle(Vector2(size.x * 0.92 + float(plume_index) * 15.0, size.y * 0.48 - float(plume_index) * 18.0), 14.0 + float(plume_index) * 5.0, plume)

	func _draw_route_landmark(x: float, road_y: float, flooded: bool, accent: Color, profile: Dictionary) -> void:
		var structure := accent.darkened(0.30)
		match String(profile.get("motif", "road")):
			"training":
				for offset in [-34.0, 34.0]:
					draw_line(Vector2(x + offset, road_y), Vector2(x + offset, road_y - 92.0), structure, 6.0)
					draw_line(Vector2(x - 38.0, road_y - 72.0), Vector2(x + 38.0, road_y - 72.0), accent, 4.0)
			"crossing":
				for offset in [-50.0, 50.0]:
					draw_rect(Rect2(Vector2(x + offset - 8.0, road_y - 92.0), Vector2(16.0, 92.0)), structure, true)
				draw_line(Vector2(x - 58.0, road_y - 66.0), Vector2(x - 10.0, road_y - 58.0), accent, 6.0)
				draw_line(Vector2(x + 12.0, road_y - 56.0), Vector2(x + 58.0, road_y - 66.0), accent, 6.0)
			"orchard":
				for offset in [-48.0, 0.0, 46.0]:
					var trunk_height := 62.0 + absf(offset) * 0.28
					draw_line(Vector2(x + offset, road_y), Vector2(x + offset - 5.0, road_y - trunk_height), structure, 8.0)
					draw_line(Vector2(x + offset - 4.0, road_y - trunk_height + 17.0), Vector2(x + offset + 19.0, road_y - trunk_height - 3.0), accent.darkened(0.18), 4.0)
			"relay":
				draw_line(Vector2(x, road_y), Vector2(x + 15.0, road_y - 126.0), structure, 8.0)
				draw_line(Vector2(x + 14.0, road_y - 118.0), Vector2(x + 54.0, road_y - 90.0), accent, 3.0)
				draw_arc(Vector2(x + 16.0, road_y - 124.0), 24.0, -0.9, 0.7, 12, accent, 3.0)
			"blockade":
				draw_line(Vector2(x - 56.0, road_y), Vector2(x - 56.0, road_y - 92.0), structure, 8.0)
				draw_line(Vector2(x + 56.0, road_y), Vector2(x + 56.0, road_y - 92.0), structure, 8.0)
				draw_line(Vector2(x - 60.0, road_y - 86.0), Vector2(x + 60.0, road_y - 86.0), accent, 8.0)
				draw_circle(Vector2(x, road_y - 58.0), 18.0, Color("#8f3f35"), false, 5.0)
			"camp":
				for offset in [-48.0, 42.0]:
					var tent := PackedVector2Array([Vector2(x + offset - 34.0, road_y), Vector2(x + offset, road_y - 58.0), Vector2(x + offset + 34.0, road_y)])
					draw_colored_polygon(tent, structure)
					draw_polyline(tent, accent, 3.0)
			"lower_cut":
				draw_line(Vector2(x - 72.0, road_y - 56.0), Vector2(x + 72.0, road_y - 18.0), structure, 18.0)
				for offset in [-54.0, -12.0, 34.0]:
					draw_line(Vector2(x + offset, road_y), Vector2(x + offset - 9.0, road_y - 42.0), accent, 4.0)
			"cistern":
				for offset in [-44.0, 32.0]:
					draw_arc(Vector2(x + offset, road_y - 8.0), 34.0, PI, TAU, 16, accent, 6.0)
				draw_line(Vector2(x - 80.0, road_y - 8.0), Vector2(x + 76.0, road_y - 8.0), structure, 7.0)
			"quarry":
				for level in range(4):
					var width := 126.0 - float(level) * 24.0
					draw_line(Vector2(x - width * 0.5, road_y - float(level) * 22.0), Vector2(x + width * 0.5, road_y - float(level) * 22.0), accent.darkened(float(level) * 0.08), 8.0)
			"pass":
				draw_line(Vector2(x - 62.0, road_y), Vector2(x - 32.0, road_y - 118.0), structure, 22.0)
				draw_line(Vector2(x + 62.0, road_y), Vector2(x + 34.0, road_y - 118.0), structure, 22.0)
				draw_line(Vector2(x, road_y - 34.0), Vector2(x, road_y - 96.0), accent, 3.0)
				draw_colored_polygon(PackedVector2Array([Vector2(x + 3.0, road_y - 94.0), Vector2(x + 28.0, road_y - 84.0), Vector2(x + 3.0, road_y - 74.0)]), Color("#b95d4f"))
			"pump":
				draw_circle(Vector2(x, road_y - 42.0), 38.0, structure, false, 8.0)
				for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
					draw_line(Vector2(x, road_y - 42.0), Vector2(x, road_y - 42.0) + Vector2(cos(angle), sin(angle)) * 34.0, accent, 4.0)
				draw_line(Vector2(x - 64.0, road_y - 4.0), Vector2(x + 62.0, road_y - 4.0), accent, 6.0)
			"tram":
				for offset in [-18.0, 18.0]:
					draw_line(Vector2(x - 72.0, road_y + offset), Vector2(x + 72.0, road_y + offset - 12.0), accent, 4.0)
				draw_rect(Rect2(Vector2(x - 35.0, road_y - 72.0), Vector2(70.0, 45.0)), structure, true)
			"archive":
				for offset in [-48.0, 48.0]:
					draw_rect(Rect2(Vector2(x + offset - 10.0, road_y - 105.0), Vector2(20.0, 105.0)), structure, true)
				draw_line(Vector2(x - 60.0, road_y - 100.0), Vector2(x + 60.0, road_y - 100.0), accent, 7.0)
				draw_circle(Vector2(x, road_y - 72.0), 9.0, accent, false, 3.0)
			"gantry":
				draw_line(Vector2(x - 52.0, road_y), Vector2(x - 36.0, road_y - 118.0), structure, 7.0)
				draw_line(Vector2(x + 52.0, road_y), Vector2(x + 36.0, road_y - 118.0), structure, 7.0)
				draw_line(Vector2(x - 40.0, road_y - 105.0), Vector2(x + 40.0, road_y - 105.0), accent, 5.0)
				for offset in [-20.0, 0.0, 20.0]:
					draw_line(Vector2(x + offset, road_y - 104.0), Vector2(x + offset, road_y - 48.0), accent.darkened(0.25), 2.0)
			_:
				draw_line(Vector2(x, road_y), Vector2(x, road_y - 92.0), structure, 8.0)
				draw_line(Vector2(x - 45.0, road_y - 72.0), Vector2(x + 38.0, road_y - 72.0), accent, 6.0)

	func _draw_contact_horizon() -> void:
		if presentation_beat_index < 2:
			return
		var marker := Vector2(size.x * 0.90, size.y * 0.57)
		var danger := Color.WHITE if high_contrast_enabled else Color("#ef8375")
		draw_circle(marker, 12.0, danger.darkened(0.28))
		draw_arc(marker, 22.0, 0, TAU, 20, danger, 3.0)
		draw_line(marker + Vector2(-42.0, -42.0), marker + Vector2(0, -18.0), danger, 2.0)
		draw_string(ThemeDB.fallback_font, marker + Vector2(-120.0, -51.0), contact_name.to_upper(), HORIZONTAL_ALIGNMENT_RIGHT, 112.0, 10, danger)

	func _draw_travel_atmosphere(flooded: bool) -> void:
		if not temporary_travel_vfx_active():
			return
		var base_position := Vector2(size.x * 0.28, size.y * 0.73)
		var dust_tint := Color(0.30, 0.48, 0.48, 0.16) if flooded else Color(0.64, 0.45, 0.25, 0.20)
		if high_contrast_enabled:
			dust_tint.a = 0.13
		for puff_index in range(3):
			var cycle := fmod(travel_offset * 1.55 + float(puff_index) * 37.0, 118.0)
			var texture := TEMP_TRAVEL_DUST_A if int(floor(cycle / 24.0)) % 2 == 0 else TEMP_TRAVEL_DUST_B
			var puff_size := 62.0 + float(puff_index) * 17.0
			var puff_position := base_position + Vector2(-cycle - float(puff_index) * 18.0, float(puff_index % 2) * 12.0)
			draw_texture_rect(texture, Rect2(puff_position, Vector2(puff_size, puff_size * 0.58)), false, dust_tint)
		for streak_index in range(4):
			var streak_x := fmod(float(streak_index) * 137.0 - travel_offset * 2.25, size.x + 150.0)
			var streak_y := size.y * (0.68 + float(streak_index % 3) * 0.07)
			draw_line(Vector2(streak_x, streak_y), Vector2(streak_x + 54.0, streak_y - 2.0), dust_tint.lightened(0.18), 2.0)

	func _draw_fortress() -> void:
		var view := fortress_view.duplicate(true)
		var signature := motion_signature()
		view["mode"] = String(signature.get("fortress_mode", "travel"))
		view["travel_phase"] = travel_offset if not reduced_motion and presentation_beat_index < 2 else 0.0
		view["high_contrast"] = high_contrast_enabled
		var bob := sin(travel_offset * 0.09) * 3.0 if temporary_travel_vfx_active() else 0.0
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.22, size.y * 0.25 + bob), Vector2(size.x * 0.56, size.y * 0.48)), view)
