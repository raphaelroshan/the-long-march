class_name RoadContactView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

const THREAT_PRESENTATION_PROFILES := {
	"road_raiders": {"wind_up": "HARPOON VOLLEY", "response": "SHELL OR REPEATER FIRE"},
	"climbers": {"wind_up": "GRAPNEL RUSH", "response": "WALL LIGHT OR REPEATER FIRE"},
	"burrowers": {"wind_up": "UNDERCARRIAGE BREACH", "response": "LOWER-HULL ARMOR · SHIFTED GUNS · SPARE ENGINE"},
	"storm_front": {"wind_up": "ARC DISCHARGE", "response": "SIGNAL · ADJACENT ARMOR · SEAL · VENT"},
	"siege_beast": {"wind_up": "RAM CHARGE", "response": "SHELL FIRE · FRONT ARMOR"},
	"flood_surge": {"wind_up": "SURGE CREST", "response": "CONDENSER · ARMOR · WORKSHOP · SEAL"},
	"civic_guardian": {"wind_up": "ARCHIVE BEAM", "response": "SHELL FIRE · PROTECTED CARGO · REDUNDANCY"}
}

signal pause_requested
signal advance_requested
signal inspect_requested
signal intervention_requested(intervention_id: String)

var pause_button: Button
var contact_canvas: ContactCanvas
var phase_label: Label
var battle_phase_label: Label
var order_label: Label
var value_labels: Dictionary = {}
var timeline_labels: Array[Label] = []
var threat_heading: Label
var threat_status: Label
var threat_detail: Label
var warning_label: Label
var advance_button: Button
var inspect_button: Button
var intervention_heading: Label
var intervention_help: Label
var intervention_buttons: Array[Button] = []
var high_contrast_enabled: bool = false
var reduced_motion: bool = false
var current_view: Dictionary = {}

func _ready() -> void:
	_build_ui()
	process_priority = 10
	set_process(true)

func _process(_delta: float) -> void:
	if visible and contact_canvas != null:
		_refresh_battle_phase_label()

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
	background.color = Color("#0d1418")
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
	phase_label = Label.new()
	phase_label.text = "ROAD CONTACT"
	phase_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	phase_label.add_theme_font_size_override("font_size", 13)
	phase_label.add_theme_color_override("font_color", Color("#efb879"))
	header.add_child(phase_label)
	battle_phase_label = Label.new()
	battle_phase_label.text = "FORECAST"
	battle_phase_label.custom_minimum_size = Vector2(132, 30)
	battle_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_phase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	battle_phase_label.add_theme_font_size_override("font_size", 10)
	header.add_child(battle_phase_label)
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
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	order_label = Label.new()
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_label.custom_minimum_size = Vector2(0, 42)
	order_label.add_theme_font_size_override("font_size", 12)
	order_label.add_theme_color_override("font_color", Color("#d8c389"))
	center.add_child(order_label)
	contact_canvas = ContactCanvas.new()
	contact_canvas.custom_minimum_size = Vector2(590, 430)
	contact_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contact_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(contact_canvas)
	var timeline := HBoxContainer.new()
	timeline.add_theme_constant_override("separation", 4)
	center.add_child(timeline)
	for step in range(1, 7):
		var label := Label.new()
		label.text = "%02d" % step
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(0, 30)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 10)
		timeline_labels.append(label)
		timeline.add_child(label)
	_build_command_dock(body)

func _build_value_rail(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(190, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#121d22"), Color("#35484f"), 1, 6, 10))
	parent.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	panel.add_child(stack)
	var heading := Label.new()
	heading.text = "FORTRESS STATE"
	heading.add_theme_font_size_override("font_size", 14)
	heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(heading)
	for value_id in ["hull", "power", "heat", "fuel", "pressure", "step", "doctrine"]:
		var receipt := PanelContainer.new()
		receipt.add_theme_stylebox_override("panel", _flat_style(Color("#18242a"), Color("#31434a"), 1, 4, 6))
		stack.add_child(receipt)
		var receipt_stack := VBoxContainer.new()
		receipt_stack.add_theme_constant_override("separation", 1)
		receipt.add_child(receipt_stack)
		var key_label := Label.new()
		key_label.text = value_id.to_upper()
		key_label.add_theme_font_size_override("font_size", 9)
		key_label.add_theme_color_override("font_color", Color("#89999e"))
		receipt_stack.add_child(key_label)
		var value_label := Label.new()
		value_label.text = "—"
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value_label.add_theme_font_size_override("font_size", 14 if value_id != "doctrine" else 11)
		value_label.add_theme_color_override("font_color", Color("#f1e6cf"))
		receipt_stack.add_child(value_label)
		value_labels[value_id] = value_label
	var note := Label.new()
	note.text = "Advance resolves one readable beat. The fortress does not reach its destination until every contact is settled."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(note)

func _build_command_dock(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(326, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d21"), Color("#596d72"), 2, 6, 10))
	parent.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.custom_minimum_size = Vector2(300, 0)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 7)
	scroll.add_child(stack)
	var kicker := Label.new()
	kicker.text = "CONTACT DOSSIER"
	kicker.add_theme_font_size_override("font_size", 9)
	kicker.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(kicker)
	threat_heading = Label.new()
	threat_heading.text = "CONTACT AHEAD"
	threat_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_heading.add_theme_font_size_override("font_size", 19)
	threat_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(threat_heading)
	threat_status = Label.new()
	threat_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_status.add_theme_font_size_override("font_size", 11)
	threat_status.add_theme_color_override("font_color", Color("#efb879"))
	stack.add_child(threat_status)
	threat_detail = Label.new()
	threat_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_detail.custom_minimum_size = Vector2(0, 104)
	threat_detail.add_theme_font_size_override("font_size", 11)
	threat_detail.add_theme_color_override("font_color", Color("#c8d1d1"))
	stack.add_child(threat_detail)
	warning_label = Label.new()
	warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning_label.add_theme_font_size_override("font_size", 10)
	warning_label.add_theme_color_override("font_color", Color("#ff9d8f"))
	stack.add_child(warning_label)
	advance_button = Button.new()
	advance_button.text = "ADVANCE CONTACT"
	advance_button.custom_minimum_size = Vector2(0, 58)
	advance_button.pressed.connect(func() -> void: advance_requested.emit())
	stack.add_child(advance_button)
	inspect_button = Button.new()
	inspect_button.text = "INSPECT CHASSIS"
	inspect_button.custom_minimum_size = Vector2(0, 42)
	inspect_button.pressed.connect(func() -> void: inspect_requested.emit())
	stack.add_child(inspect_button)
	intervention_heading = Label.new()
	intervention_heading.text = "EMERGENCY ORDER · 1 AVAILABLE"
	intervention_heading.add_theme_font_size_override("font_size", 12)
	intervention_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(intervention_heading)
	intervention_help = Label.new()
	intervention_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intervention_help.add_theme_font_size_override("font_size", 10)
	intervention_help.add_theme_color_override("font_color", Color("#aab6ba"))
	stack.add_child(intervention_help)
	for intervention_id in ["shift_power", "seal_compartment", "vent_heat", "cut_loose_cargo"]:
		var button := Button.new()
		button.text = intervention_id.replace("_", " ").capitalize()
		button.set_meta("intervention_id", intervention_id)
		button.pressed.connect(_emit_intervention.bind(intervention_id))
		button.focus_entered.connect(_show_action_help.bind(button))
		button.mouse_entered.connect(_show_action_help.bind(button))
		button.focus_exited.connect(_restore_action_help)
		button.mouse_exited.connect(_restore_action_help)
		intervention_buttons.append(button)
		stack.add_child(button)

func configure(view: Dictionary) -> void:
	current_view = view.duplicate(true)
	phase_label.text = "%s · CONTACT STEP %d OF 6" % [String(view.get("location_name", "ROAD")).to_upper(), int(view.get("step", 0))]
	order_label.text = String(view.get("order", "Read the contact before advancing."))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	var step := int(view.get("step", 0))
	for index in range(timeline_labels.size()):
		var label := timeline_labels[index]
		var timeline_step := index + 1
		label.text = "%s %02d" % ["✓" if timeline_step <= step else ("▶" if timeline_step == step + 1 else "·"), timeline_step]
		label.add_theme_stylebox_override("normal", _flat_style(Color("#214238") if timeline_step <= step else (Color("#4b3b29") if timeline_step == step + 1 else Color("#172126")), Color("#76c69a") if timeline_step <= step else (Color("#e8c58e") if timeline_step == step + 1 else Color("#314147")), 1, 3, 2))
		label.add_theme_color_override("font_color", Color("#d9f5e5") if timeline_step <= step else (Color("#fff0ce") if timeline_step == step + 1 else Color("#6f7e82")))
	_configure_threat(view)
	warning_label.text = String(view.get("warning", ""))
	warning_label.visible = not warning_label.text.is_empty()
	advance_button.text = String(view.get("advance_label", "ADVANCE CONTACT"))
	advance_button.disabled = not bool(view.get("active", false))
	inspect_button.text = String(view.get("inspect_label", "INSPECT CHASSIS"))
	inspect_button.disabled = not bool(view.get("active", false))
	var actions: Array = view.get("interventions", [])
	for index in range(intervention_buttons.size()):
		var button := intervention_buttons[index]
		if index >= actions.size():
			button.visible = false
			continue
		var action: Dictionary = actions[index]
		button.visible = true
		button.text = String(action.get("label", "Emergency order"))
		button.tooltip_text = String(action.get("tooltip", ""))
		button.disabled = not bool(action.get("enabled", false))
	intervention_heading.text = String(view.get("intervention_heading", "EMERGENCY ORDER"))
	_restore_action_help()
	contact_canvas.high_contrast_enabled = high_contrast_enabled
	contact_canvas.reduced_motion = reduced_motion
	contact_canvas.configure(current_view)
	_refresh_battle_phase_label(true)
	_configure_focus()

func _refresh_battle_phase_label(force: bool = false) -> void:
	var battle_phase := battle_phase_for()
	if not force and battle_phase_label.text == battle_phase:
		return
	battle_phase_label.text = battle_phase
	var active_phase := battle_phase in ["TARGET", "WIND-UP", "RESPONSE", "IMPACT"]
	battle_phase_label.add_theme_stylebox_override("normal", _flat_style(Color("#4b2422") if active_phase else Color("#17312f"), Color.WHITE if high_contrast_enabled else (Color("#ef8375") if active_phase else Color("#6e918f")), 2, 4, 4))
	battle_phase_label.add_theme_color_override("font_color", Color("#fff0df") if active_phase else Color("#bce5d8"))

func battle_phase_for(view: Dictionary = {}) -> String:
	if view.is_empty():
		view = current_view
	var enemies: Array = view.get("enemies", [])
	var has_live_enemy := false
	var has_arrived_enemy := false
	for raw_enemy in enemies:
		var enemy: Dictionary = raw_enemy
		if bool(enemy.get("defeated", false)):
			continue
		has_live_enemy = true
		if bool(enemy.get("arrived", false)):
			has_arrived_enemy = true
	if not has_live_enemy:
		return "SETTLE"
	if not has_arrived_enemy:
		return "FORECAST" if int(view.get("step", 0)) == 0 else "APPROACH"
	if contact_canvas != null and contact_canvas.report_changed and contact_canvas.step_to > contact_canvas.step_from:
		if contact_canvas.transition_progress < 0.14:
			return "APPROACH"
		if contact_canvas.transition_progress < 0.28:
			return "TARGET"
		if contact_canvas.transition_progress < 0.43:
			return "WIND-UP"
		if contact_canvas.transition_progress < 0.58:
			return "RESPONSE"
		if contact_canvas.transition_progress < 0.78:
			return "IMPACT"
		return "CONSEQUENCE"
	return "RESPONSE"

func _configure_threat(view: Dictionary) -> void:
	var enemies: Array = view.get("enemies", [])
	var definitions: Dictionary = view.get("enemy_definitions", {})
	var chosen: Dictionary = {}
	var chosen_distance := 999
	for enemy in enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var definition: Dictionary = definitions.get(String(enemy.get("id", "")), {})
		var distance := 0 if bool(enemy.get("arrived", false)) else maxi(1, int(definition.get("arrival_step", 1)) - int(view.get("step", 0)))
		if chosen.is_empty() or distance < chosen_distance:
			chosen = enemy
			chosen_distance = distance
	if chosen.is_empty():
		threat_heading.text = "ROAD OPEN"
		threat_status.text = "No undefeated contact remains."
		threat_detail.text = "Advance to settle the road and complete arrival."
		return
	var definition: Dictionary = definitions.get(String(chosen.get("id", "")), {})
	var enemy_name := String(definition.get("name", String(chosen.get("id", "threat")).replace("_", " ").capitalize()))
	threat_heading.text = enemy_name.to_upper()
	if bool(chosen.get("arrived", false)):
		var impact: Dictionary = chosen.get("impact", {})
		var target_name := _target_name(String(chosen.get("target", "hull")), view)
		threat_status.text = "ACTIVE CONTACT · TARGETING %s" % target_name.to_upper()
		var profile: Dictionary = THREAT_PRESENTATION_PROFILES.get(String(chosen.get("id", "")), {})
		var damage := int(impact.get("damage", 0))
		var durability_line := "%d→%d durability" % [int(impact.get("current_durability", 0)), int(impact.get("remaining_durability", 0))]
		var cascade_lines: Array[String] = []
		for change in impact.get("dependency_changes", []):
			cascade_lines.append("%s → %s" % [String(change.get("name", "System")), String(change.get("to", "offline")).to_upper()])
		threat_detail.text = "INTENT · %s → %s\nWHY · %s\nRESPONSE WINDOW · %s\nNEXT · %d damage · %s%s" % [String(profile.get("wind_up", "CONTACT STRIKE")), target_name.to_upper(), String(impact.get("target_reason", "target route matched")).capitalize(), String(definition.get("counter", "No listed system counter")), damage, durability_line, "\nCASCADE · %s" % ", ".join(cascade_lines) if not cascade_lines.is_empty() else ""]
	else:
		threat_status.text = "%d STEP%s OUT · %s" % [chosen_distance, "" if chosen_distance == 1 else "S", String(definition.get("flank", "road approach")).to_upper()]
		threat_detail.text = "APPROACH · %s\nPREFERRED TARGETS · %s\nCOUNTER · %s" % [String(definition.get("route", "road approach")).capitalize(), " / ".join(definition.get("target_tags", [])), String(definition.get("counter", "No listed system counter"))]

func contact_readability_summary() -> Dictionary:
	var enemy := contact_canvas._nearest_enemy() if contact_canvas != null else {}
	if enemy.is_empty():
		return {"phase": "settle", "threat": "road open", "target": "", "damage": 0}
	var definitions: Dictionary = current_view.get("enemy_definitions", {})
	var enemy_id := String(enemy.get("id", "threat"))
	var definition: Dictionary = definitions.get(enemy_id, {})
	var impact: Dictionary = enemy.get("impact", {})
	return {
		"phase": battle_phase_for().to_lower(),
		"threat": String(definition.get("name", enemy_id.replace("_", " ").capitalize())),
		"target": _target_name(String(enemy.get("target", "")), current_view),
		"damage": int(impact.get("damage", 0)),
		"counter": String(definition.get("counter", ""))
	}

func _target_name(target_id: String, view: Dictionary) -> String:
	return String(view.get("target_names", {}).get(target_id, target_id.replace("_", " ").capitalize()))

func _emit_intervention(intervention_id: String) -> void:
	intervention_requested.emit(intervention_id)

func _show_action_help(button: Button) -> void:
	if button.disabled:
		return
	intervention_help.text = button.tooltip_text

func _restore_action_help() -> void:
	intervention_help.text = String(current_view.get("intervention_help", "Choose one order, or preserve it for a later step."))

func _configure_focus() -> void:
	var controls: Array[Control] = [advance_button, inspect_button]
	for button in intervention_buttons:
		if button.visible and not button.disabled:
			controls.append(button)
	if controls.is_empty():
		return
	for index in range(controls.size()):
		var current := controls[index]
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var next := controls[(index + 1) % controls.size()]
		current.focus_neighbor_top = current.get_path_to(previous)
		current.focus_neighbor_bottom = current.get_path_to(next)
		current.focus_previous = current.get_path_to(previous)
		current.focus_next = current.get_path_to(next)

func focus_default() -> void:
	advance_button.grab_focus()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if battle_phase_label != null:
		_refresh_battle_phase_label(true)
	if contact_canvas != null:
		contact_canvas.high_contrast_enabled = enabled
		contact_canvas.queue_redraw()

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if contact_canvas != null:
		contact_canvas.reduced_motion = enabled
		if enabled:
			contact_canvas.finish_transition()

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class ContactCanvas extends Control:
	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false
	var reduced_motion: bool = false
	var step_from: float = 0.0
	var step_to: float = 0.0
	var transition_progress: float = 1.0
	var report_changed: bool = false
	var fortress_anchors: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_process(true)

	func configure(view: Dictionary) -> void:
		var next_step := float(view.get("step", 0))
		var previous_step := float(current_view.get("step", next_step))
		var previous_report: Array = current_view.get("recent_report", [])
		var next_report: Array = view.get("recent_report", [])
		report_changed = previous_report != next_report
		current_view = view.duplicate(true)
		step_from = previous_step
		step_to = next_step
		transition_progress = 1.0 if reduced_motion or next_step <= previous_step else 0.0
		queue_redraw()

	func finish_transition() -> void:
		transition_progress = 1.0
		queue_redraw()

	func _process(delta: float) -> void:
		if transition_progress >= 1.0:
			return
		transition_progress = minf(1.0, transition_progress + delta * 0.42)
		queue_redraw()

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		var sky := Color("#071013") if high_contrast_enabled else (Color("#18363d") if flooded else Color("#31383b"))
		var ground := Color("#0d2427") if flooded else Color("#30271f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.80, size.y * 0.18), 52.0, Color(0.95, 0.75, 0.43, 0.15))
		_draw_contact_pressure()
		for ridge in range(4):
			var y := size.y * (0.32 + ridge * 0.045)
			draw_line(Vector2(0, y), Vector2(size.x, y - 26.0 + ridge * 8.0), Color("#395358") if flooded else Color("#655b4d"), 24.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.64), Vector2(size.x, size.y * 0.36)), ground, true)
		for road_mark in range(7):
			var x := 28.0 + road_mark * (size.x - 56.0) / 6.0
			draw_line(Vector2(x, size.y * 0.85), Vector2(x + 42.0, size.y * 0.85), Color("#94784f"), 4.0)
		var fortress_rect := _draw_fortress()
		_draw_contacts(fortress_rect)
		_draw_resolution_banner()
		var caption := "FORTRESS AT CONTACT · DESTINATION PENDING"
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 14), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#d7c08b"))

	func _draw_fortress() -> Rect2:
		var impact_strength := sin(transition_progress * PI) if _active_contact_has_damage() else 0.0
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		if report_changed and transition_progress < 0.80 and not Dictionary(current_view.get("fortress_before", {})).is_empty():
			view = Dictionary(current_view.get("fortress_before", {})).duplicate(true)
			var active_target_id := String(current_view.get("active_target_id", ""))
			for index in range(Array(view.get("modules", [])).size()):
				var module: Dictionary = view["modules"][index]
				module["targeted"] = String(module.get("id", "")) == active_target_id
				view["modules"][index] = module
		view["mode"] = "contact"
		view["impact"] = impact_strength
		view["high_contrast"] = high_contrast_enabled
		var rendered := FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.12, size.y * 0.25), Vector2(size.x * 0.64, size.y * 0.50)), view)
		fortress_anchors = Dictionary(rendered.get("anchors", {})).duplicate()
		return rendered.get("body", Rect2())

	func _draw_contact_pressure() -> void:
		var enemy := _nearest_enemy()
		if enemy.is_empty():
			return
		var arrived := bool(enemy.get("arrived", false))
		var lane_color := Color(0.72, 0.25, 0.19, 0.12 if arrived else 0.05)
		var lane := PackedVector2Array([
			Vector2(size.x * 0.58, size.y * 0.18),
			Vector2(size.x, size.y * 0.12),
			Vector2(size.x, size.y * 0.74),
			Vector2(size.x * 0.58, size.y * 0.68)
		])
		draw_colored_polygon(lane, lane_color)
		for line_index in range(3):
			var y := size.y * (0.29 + float(line_index) * 0.12)
			draw_line(Vector2(size.x * 0.68, y), Vector2(size.x * 0.96, y - 14.0), Color(0.88, 0.40, 0.30, 0.14), 2.0)

	func presentation_stage_text() -> String:
		var enemy := _nearest_enemy()
		if enemy.is_empty():
			return "SETTLE · ROAD OPEN · ADVANCE TO ARRIVAL"
		var enemy_id := String(enemy.get("id", "threat"))
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		var definition: Dictionary = definitions.get(enemy_id, {})
		var enemy_name := String(definition.get("name", enemy_id.replace("_", " ").capitalize())).to_upper()
		var arrived := bool(enemy.get("arrived", false))
		if not arrived:
			var distance := maxi(1, int(definition.get("arrival_step", 1)) - int(current_view.get("step", 0)))
			var phase := "FORECAST" if int(current_view.get("step", 0)) == 0 else "APPROACH"
			return "%s · %s · %d STEP%s OUT" % [phase, enemy_name, distance, "" if distance == 1 else "S"]
		var target_name := String(current_view.get("target_names", {}).get(String(enemy.get("target", "hull")), String(enemy.get("target", "hull")).replace("_", " ").capitalize())).to_upper()
		if report_changed and step_to > step_from:
			if transition_progress < 0.14:
				return "APPROACH · %s VIA %s" % [enemy_name, String(definition.get("route", "ROAD APPROACH")).to_upper()]
			if transition_progress < 0.28:
				return "TARGET LOCK · %s → %s" % [enemy_name, target_name]
			if transition_progress < 0.43:
				return "WIND-UP · %s" % _attack_signature(enemy_id)
			if transition_progress < 0.58:
				return "RESPONSE WINDOW · %s" % _response_cue(enemy_id)
			if transition_progress < 0.78:
				return "IMPACT · %s" % _latest_report_line([" hits ", " reaches the hull", " absorbs "])
			return "CONSEQUENCE · %s" % _latest_consequence_text()
		return "RESPONSE READY · %s" % _response_cue(enemy_id)

	func _draw_resolution_banner() -> void:
		var text := presentation_stage_text()
		var banner := Rect2(Vector2(size.x * 0.17, 10), Vector2(size.x * 0.66, 34))
		var urgent := text.begins_with("TARGET") or text.begins_with("WIND-UP") or text.begins_with("IMPACT")
		draw_rect(banner, Color("#461f1c") if urgent else Color("#142328"), true)
		draw_rect(banner, Color.WHITE if high_contrast_enabled else (Color("#ef8375") if urgent else Color("#6e918f")), false, 2.0)
		draw_string(ThemeDB.fallback_font, banner.position + Vector2(8, 22), text, HORIZONTAL_ALIGNMENT_CENTER, banner.size.x - 16, 11, Color("#fff0df"))

	func _nearest_enemy() -> Dictionary:
		var chosen: Dictionary = {}
		var chosen_distance := 999
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		for raw_enemy in current_view.get("enemies", []):
			var enemy: Dictionary = raw_enemy
			if bool(enemy.get("defeated", false)):
				continue
			var definition: Dictionary = definitions.get(String(enemy.get("id", "")), {})
			var distance := 0 if bool(enemy.get("arrived", false)) else maxi(1, int(definition.get("arrival_step", 1)) - int(current_view.get("step", 0)))
			if chosen.is_empty() or distance < chosen_distance:
				chosen = enemy
				chosen_distance = distance
		return chosen

	func _attack_signature(enemy_id: String) -> String:
		return String(RoadContactView.THREAT_PRESENTATION_PROFILES.get(enemy_id, {}).get("wind_up", "CONTACT STRIKE"))

	func _response_cue(enemy_id: String) -> String:
		return String(RoadContactView.THREAT_PRESENTATION_PROFILES.get(enemy_id, {}).get("response", "PROTECT THE TARGET OR BREAK CONTACT"))

	func _latest_report_line(markers: Array[String]) -> String:
		var report: Array = current_view.get("recent_report", [])
		for index in range(report.size() - 1, -1, -1):
			var line := String(report[index])
			for marker in markers:
				if marker in line:
					return line.trim_prefix("Step %d: " % int(current_view.get("step", 0)))
		return "The fortress record has not reported a matching effect."

	func _latest_consequence_text() -> String:
		var line := _latest_report_line(["Dependency change:", " restores ", "durability is", " reaches the hull"])
		if line.begins_with("Dependency change: "):
			line = line.trim_prefix("Dependency change: ")
			if " — " in line:
				line = line.get_slice(" — ", 0)
			line = line.replace(" is now ", " → ")
		return line

	func _active_contact_has_damage() -> bool:
		if transition_progress >= 1.0:
			return false
		for enemy in current_view.get("enemies", []):
			if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and int(enemy.get("impact", {}).get("damage", 0)) > 0:
				return true
		return false

	func _target_anchor(body: Rect2, target_id: String) -> Vector2:
		if target_id == "hull":
			return body.get_center()
		if "signal" in target_id or "coil" in target_id:
			return body.position + Vector2(232, -52)
		if "engine" in target_id or "coal" in target_id or "fuel" in target_id:
			return body.position + Vector2(55, 83)
		if "armor" in target_id:
			return body.position + Vector2(305, 60)
		if "crew" in target_id or "refugee" in target_id:
			return body.position + Vector2(110, 22)
		if "workshop" in target_id or "parts" in target_id:
			return body.position + Vector2(178, 76)
		return body.position + Vector2(245, 82)

	func _draw_contacts(fortress_rect: Rect2) -> void:
		var enemies: Array = current_view.get("enemies", [])
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		var animated_step := lerpf(step_from, step_to, transition_progress * transition_progress * (3.0 - 2.0 * transition_progress))
		var target_id := String(current_view.get("active_target_id", ""))
		var target_anchor: Vector2 = fortress_anchors.get(target_id, _target_anchor(fortress_rect, target_id))
		var visible_index := 0
		for enemy in enemies:
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id := String(enemy.get("id", ""))
			var definition: Dictionary = definitions.get(enemy_id, {})
			var arrived := bool(enemy.get("arrived", false))
			var steps_out := maxf(0.0, float(definition.get("arrival_step", 1)) - animated_step)
			var x := fortress_rect.end.x + 46.0 + steps_out * 55.0
			var y := fortress_rect.end.y + 38.0 - float(visible_index % 2) * 62.0
			if enemy_id in ["climbers", "storm_front"]:
				y = fortress_rect.position.y - 48.0 - float(visible_index) * 18.0
			if enemy_id in ["burrowers", "flood_surge"]:
				y = fortress_rect.end.y + 68.0
			x = minf(size.x - 38.0, x)
			_draw_enemy_symbol(enemy_id, Vector2(x, y), arrived, 1.30 if arrived else 1.08)
			if arrived and not String(enemy.get("target", "")).is_empty():
				var line_color := Color("#ff8275")
				line_color.a = 0.4 + transition_progress * 0.6
				draw_dashed_line(Vector2(x - 16.0, y), target_anchor, line_color, 2.0, 7.0)
				_draw_intent_arrow(Vector2(x - 16.0, y), target_anchor, line_color)
				var pulse_radius := 15.0 + sin(transition_progress * PI) * 8.0
				draw_arc(target_anchor, pulse_radius, 0, TAU, 24, line_color, 3.0)
				var target_name := String(current_view.get("target_names", {}).get(String(enemy.get("target", "hull")), String(enemy.get("target", "hull")).replace("_", " ").capitalize())).to_upper()
				draw_string(ThemeDB.fallback_font, target_anchor + Vector2(-70.0, -23.0), target_name, HORIZONTAL_ALIGNMENT_CENTER, 140.0, 10, Color("#fff0df"))
			var name := String(definition.get("name", enemy_id.replace("_", " ").capitalize())).to_upper()
			draw_string(ThemeDB.fallback_font, Vector2(x - 72.0, y - 30.0), name, HORIZONTAL_ALIGNMENT_CENTER, 144, 10, Color("#f1d1b2"))
			visible_index += 1

	func _draw_intent_arrow(from: Vector2, to: Vector2, color: Color) -> void:
		var direction := (to - from).normalized()
		if direction == Vector2.ZERO:
			return
		var perpendicular := Vector2(-direction.y, direction.x)
		var tip := to - direction * 10.0
		draw_colored_polygon(PackedVector2Array([tip, tip - direction * 13.0 + perpendicular * 7.0, tip - direction * 13.0 - perpendicular * 7.0]), color)

	func _draw_enemy_symbol(enemy_id: String, position: Vector2, arrived: bool, scale_amount: float = 1.0) -> void:
		var color := Color("#ff7f70") if arrived else Color("#d8a16e")
		if enemy_id == "storm_front":
			for offset in [Vector2(-18, 0), Vector2(0, -8), Vector2(19, 1)]:
				draw_circle(position + offset * scale_amount, 17.0 * scale_amount, color.darkened(0.25))
			draw_polyline(PackedVector2Array([position + Vector2(-4, 12) * scale_amount, position + Vector2(-12, 35) * scale_amount, position + Vector2(3, 26) * scale_amount, position + Vector2(-2, 47) * scale_amount]), color, 4.0 * scale_amount)
		elif enemy_id == "flood_surge":
			draw_arc(position, 28.0 * scale_amount, PI, TAU, 18, color, 7.0 * scale_amount)
			draw_arc(position + Vector2(25, 6) * scale_amount, 22.0 * scale_amount, PI, TAU, 18, color.darkened(0.18), 6.0 * scale_amount)
		elif enemy_id == "burrowers":
			for radius in [10.0, 20.0, 30.0]:
				draw_arc(position, radius * scale_amount, PI, TAU, 14, color, 3.0 * scale_amount)
		elif enemy_id == "climbers":
			draw_circle(position, 15.0 * scale_amount, color)
			for angle in [0.2, 1.0, 2.1, 2.9]:
				draw_line(position, position + Vector2(cos(angle), sin(angle)) * 30.0 * scale_amount, color, 4.0 * scale_amount)
		elif enemy_id in ["siege_beast", "civic_guardian"]:
			draw_circle(position, 25.0 * scale_amount, color.darkened(0.25))
			draw_rect(Rect2(position - Vector2(24, 12) * scale_amount, Vector2(48, 28) * scale_amount), color, true)
			draw_line(position + Vector2(-18, 15) * scale_amount, position + Vector2(-25, 35) * scale_amount, color, 7.0 * scale_amount)
			draw_line(position + Vector2(18, 15) * scale_amount, position + Vector2(25, 35) * scale_amount, color, 7.0 * scale_amount)
		else:
			draw_rect(Rect2(position - Vector2(27, 14) * scale_amount, Vector2(54, 27) * scale_amount), color.darkened(0.18), true)
			draw_rect(Rect2(position + Vector2(-8, -26) * scale_amount, Vector2(25, 13) * scale_amount), color.darkened(0.34), true)
			draw_circle(position + Vector2(-17, 17) * scale_amount, 9.0 * scale_amount, color)
			draw_circle(position + Vector2(18, 17) * scale_amount, 9.0 * scale_amount, color)
			draw_line(position + Vector2(-22, -14) * scale_amount, position + Vector2(19, -27) * scale_amount, color, 5.0 * scale_amount)
