extends Control

const LongMarchState = preload("res://src/core/fortress_state.gd")

var state: LongMarchState
var status_label: Label
var event_label: Label
var log_label: Label
var route_option: OptionButton
var threat_option: OptionButton
var fortress_panel: Control

func _ready() -> void:
	_reset_state()
	_build_ui()
	_refresh_ui()

func _reset_state() -> void:
	state = LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(4, 0))
	state.place_module("field_workshop", Vector2i(0, 1))
	state.place_module("shell_cannon", Vector2i(4, 1), true)
	state.place_module("wall_lamp", Vector2i(5, 2), true)

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#111820")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	margin.add_child(columns)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(780, 0)
	left.add_theme_constant_override("separation", 10)
	columns.add_child(left)

	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	left.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A fortress is only strong if it can keep moving."
	subtitle.add_theme_color_override("font_color", Color("#aab6ba"))
	left.add_child(subtitle)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#f1e6cf"))
	left.add_child(status_label)

	fortress_panel = FortressPanel.new()
	fortress_panel.custom_minimum_size = Vector2(760, 390)
	fortress_panel.state = state
	left.add_child(fortress_panel)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(740, 72)
	event_label.add_theme_color_override("font_color", Color("#e7c18b"))
	left.add_child(event_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	left.add_child(log_label)

	var right := PanelContainer.new()
	right.custom_minimum_size = Vector2(330, 0)
	columns.add_child(right)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	right.add_child(controls)

	var control_title := Label.new()
	control_title.text = "MARCHMASTER'S DESK"
	control_title.add_theme_font_size_override("font_size", 20)
	control_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(control_title)

	route_option = OptionButton.new()
	for route_id in LongMarchState.ROUTES.keys():
		route_option.add_item(LongMarchState.ROUTES[route_id].name)
		route_option.set_item_metadata(route_option.item_count - 1, route_id)
	controls.add_child(_labeled_control("Route", route_option))

	threat_option = OptionButton.new()
	for threat_id in LongMarchState.THREATS.keys():
		threat_option.add_item(LongMarchState.THREATS[threat_id].name)
		threat_option.set_item_metadata(threat_option.item_count - 1, threat_id)
	controls.add_child(_labeled_control("Threat", threat_option))

	var travel_button := Button.new()
	travel_button.text = "Travel selected route"
	travel_button.tooltip_text = "Consume fuel and time, then receive a deterministic threat forecast."
	travel_button.pressed.connect(_on_travel_pressed)
	controls.add_child(travel_button)

	var resolve_button := Button.new()
	resolve_button.text = "Resolve forecasted threat"
	resolve_button.tooltip_text = "Run the automatic encounter against the selected threat."
	resolve_button.pressed.connect(_on_resolve_pressed)
	controls.add_child(resolve_button)

	var shift_button := Button.new()
	shift_button.text = "Shift power"
	shift_button.pressed.connect(func() -> void: _use_intervention("shift_power"))
	controls.add_child(shift_button)

	var seal_button := Button.new()
	seal_button.text = "Seal workshop"
	seal_button.pressed.connect(func() -> void: _use_intervention("seal_compartment", "field_workshop"))
	controls.add_child(seal_button)

	var vent_button := Button.new()
	vent_button.text = "Vent heat"
	vent_button.pressed.connect(func() -> void: _use_intervention("vent_heat"))
	controls.add_child(vent_button)

	var cut_button := Button.new()
	cut_button.text = "Cut loose cargo"
	cut_button.pressed.connect(func() -> void: _use_intervention("cut_loose_cargo"))
	controls.add_child(cut_button)

	var save_button := Button.new()
	save_button.text = "Save prototype state"
	save_button.pressed.connect(_on_save_pressed)
	controls.add_child(save_button)

	var reset_button := Button.new()
	reset_button.text = "Reset run"
	reset_button.pressed.connect(_on_reset_pressed)
	controls.add_child(reset_button)

func _labeled_control(label_text: String, control: Control) -> VBoxContainer:
	var group := VBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#aab6ba"))
	group.add_child(label)
	group.add_child(control)
	return group

func _selected_id(option: OptionButton) -> String:
	if option.selected < 0:
		return ""
	return String(option.get_item_metadata(option.selected))

func _on_travel_pressed() -> void:
	var route_id := _selected_id(route_option)
	var result := state.travel(route_id)
	if not result.ok:
		_set_event("Travel blocked: %s." % result.reason)
	else:
		_set_event("%s. Forecast: %s. Inspect the fortress before resolving the encounter." % [result.summary.current_location if result.summary.has("current_location") else "The fortress advances", result.threat])
	_refresh_ui()

func _on_resolve_pressed() -> void:
	var threat_id := _selected_id(threat_option)
	var result := state.resolve_threat(threat_id)
	if not result.ok:
		_set_event("Encounter blocked: %s." % result.reason)
	else:
		_set_event("The automatic encounter resolved against %s. Target: %s. Damage: %d." % [threat_id, result.target, int(result.damage)])
	_refresh_ui()

func _use_intervention(intervention_id: String, target_module: String = "") -> void:
	var result := state.intervene(intervention_id, target_module)
	if not result.ok:
		_set_event("Intervention blocked: %s." % result.reason)
	else:
		_set_event("Intervention used: %s." % intervention_id.replace("_", " ").capitalize())
	_refresh_ui()

func _on_save_pressed() -> void:
	var file := FileAccess.open("user://the_long_march_prototype.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(state.serialize()))
	_set_event("Prototype state saved. Production will add versioned migrations and storefront adapters.")

func _on_reset_pressed() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("The fortress is back at Ashgate Depot with a clean maintenance slate.")
	_refresh_ui()

func _set_event(text: String) -> void:
	event_label.text = text

func _refresh_ui() -> void:
	var snapshot := state.summary()
	status_label.text = "Day %d  |  Fuel %d  |  Ashmarks %d  |  Hull %d  |  Mass %d/%d  |  Power %d/%d  |  Heat %d/%d" % [snapshot.day, snapshot.fuel, snapshot.money, snapshot.hull_condition, snapshot.mass, snapshot.mass_limit, snapshot.power_draw, snapshot.power_output, snapshot.heat, snapshot.heat_limit]
	var recent: Array[String] = []
	var start := maxi(0, state.log.size() - 4)
	for index in range(start, state.log.size()):
		recent.append(state.log[index])
	log_label.text = "Log: " + (" | ".join(recent) if not recent.is_empty() else "The crew is waiting for a route order.")
	if event_label.text.is_empty():
		event_label.text = "Install a working engine and generator, choose a route, then test the fortress against a forecasted threat."
	fortress_panel.state = state
	fortress_panel.queue_redraw()

class FortressPanel extends Control:
	var state: LongMarchState
	const CELL := 58.0
	const ORIGIN := Vector2(28, 22)
	var family_colors := {
		"engine": Color("#b86f4b"),
		"weapon": Color("#b44949"),
		"workshop": Color("#b69555"),
		"crew_room": Color("#557fa1"),
		"armor": Color("#6f7b84"),
		"cargo": Color("#8e6d4f"),
		"signal": Color("#5e9b91")
	}

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#18242b"), true)
		draw_string(ThemeDB.fallback_font, Vector2(ORIGIN.x, 14), "CHASSIS GRID — exterior mounts shown with a bright edge", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#b9c3bf"))
		for y in range(LongMarchState.GRID_HEIGHT):
			for x in range(LongMarchState.GRID_WIDTH):
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#223139"), true)
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#4a5c61"), false, 1.0)
		if state == null:
			return
		for instance in state.modules:
			var definition := state.module_definition(String(instance.get("id", "")))
			var cells: Array[Vector2i] = state.occupied_cells(instance)
			var rect := Rect2(ORIGIN + Vector2(cells[0].x * CELL, cells[0].y * CELL), Vector2(cells.size() * CELL - 3, CELL - 3))
			var shape: Vector2i = definition.get("shape", Vector2i.ONE)
			rect.size = Vector2(shape.x * CELL - 3, shape.y * CELL - 3)
			var color: Color = family_colors.get(String(definition.get("family", "")), Color("#8b8b8b"))
			draw_rect(rect, color.darkened(0.25) if int(instance.get("durability", 0)) <= 0 else color, true)
			draw_rect(rect, Color("#f0db9a") if bool(instance.get("exterior", false)) else Color("#b9c3bf"), false, 3.0 if bool(instance.get("exterior", false)) else 1.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 20), String(definition.get("name", instance.get("id", ""))), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 10, 11, Color("#f7efe0"))
