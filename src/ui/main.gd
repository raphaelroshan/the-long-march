extends Control

const LongMarchState = preload("res://src/core/fortress_state.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const ENGINE_ICON = preload("res://assets/steam_lance_engine_icon.png")
const CANNON_ICON = preload("res://assets/shell_cannon_icon.png")
const WORKSHOP_ICON = preload("res://assets/field_workshop_icon.png")
const SIGNAL_ICON = preload("res://assets/signal_coil_icon.png")

var state: LongMarchState
var status_label: Label
var journey_label: Label
var encounter_label: Label
var event_label: Label
var log_label: Label
var route_option: OptionButton
var threat_option: OptionButton
var doctrine_option: OptionButton
var module_option: OptionButton
var rotate_button: Button
var remove_button: Button
var travel_button: Button
var advance_encounter_button: Button
var encounter_intervention_button: Button
var refit_label: Label
var fortress_panel: Control
var selected_module_id: String = ""
var selected_module_cell := Vector2i(-1, -1)
var placement_rotated: bool = false

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
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false

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
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	margin.add_child(columns)

	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(left_scroll)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(760, 760)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)

	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	left.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A fortress is only strong if it can keep moving."
	subtitle.add_theme_color_override("font_color", Color("#aab6ba"))
	left.add_child(subtitle)
	var journey_banner := TextureRect.new()
	journey_banner.texture = JOURNEY_BACKGROUND
	journey_banner.custom_minimum_size = Vector2(0, 96)
	journey_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	journey_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	journey_banner.modulate = Color(1.0, 1.0, 1.0, 0.78)
	left.add_child(journey_banner)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#f1e6cf"))
	left.add_child(status_label)
	journey_label = Label.new()
	journey_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journey_label.custom_minimum_size = Vector2(740, 42)
	journey_label.add_theme_color_override("font_color", Color("#d8c389"))
	left.add_child(journey_label)
	encounter_label = Label.new()
	encounter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	encounter_label.custom_minimum_size = Vector2(740, 72)
	encounter_label.add_theme_color_override("font_color", Color("#e89270"))
	left.add_child(encounter_label)

	fortress_panel = FortressPanel.new()
	fortress_panel.custom_minimum_size = Vector2(760, 300)
	fortress_panel.state = state
	fortress_panel.grid_cell_pressed.connect(_on_grid_cell_pressed)
	fortress_panel.rotate_requested.connect(_on_rotate_pressed)
	fortress_panel.remove_requested.connect(_on_remove_pressed)
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

	var right_scroll := ScrollContainer.new()
	right_scroll.custom_minimum_size = Vector2(350, 0)
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(right_scroll)
	var right := PanelContainer.new()
	right.custom_minimum_size = Vector2(350, 760)
	right_scroll.add_child(right)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	right.add_child(controls)

	var control_title := Label.new()
	control_title.text = "MARCHMASTER'S DESK"
	control_title.add_theme_font_size_override("font_size", 20)
	control_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(control_title)
	var asset_row := HBoxContainer.new()
	asset_row.add_theme_constant_override("separation", 5)
	for asset in [ENGINE_ICON, CANNON_ICON, WORKSHOP_ICON, SIGNAL_ICON]:
		var icon := TextureRect.new()
		icon.texture = asset
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		asset_row.add_child(icon)
	controls.add_child(asset_row)

	var refit_title := Label.new()
	refit_title.text = "REFIT CHASSIS"
	refit_title.add_theme_font_size_override("font_size", 17)
	refit_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(refit_title)

	module_option = OptionButton.new()
	var module_ids: Array = LongMarchState.MODULE_DEFS.keys()
	module_ids.sort()
	for module_id in module_ids:
		var definition: Dictionary = LongMarchState.MODULE_DEFS[module_id]
		var shape: Vector2i = definition.get("shape", Vector2i.ONE)
		var mount_text := " · exterior" if "exterior" in definition.get("tags", []) else ""
		module_option.add_item("%s · %dx%d · mass %d%s" % [definition.name, shape.x, shape.y, int(definition.mass), mount_text])
		module_option.set_item_metadata(module_option.item_count - 1, module_id)
	module_option.item_selected.connect(_on_module_selected)
	selected_module_id = "steam_lance_engine"
	selected_module_cell = Vector2i(0, 0)
	_select_module_option(selected_module_id)
	controls.add_child(_labeled_control("Module", module_option))

	var refit_actions := HBoxContainer.new()
	refit_actions.add_theme_constant_override("separation", 8)
	rotate_button = Button.new()
	rotate_button.text = "Rotate"
	rotate_button.tooltip_text = "Rotate the pending or selected module. Shortcut: R while the chassis has focus."
	rotate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotate_button.pressed.connect(_on_rotate_pressed)
	refit_actions.add_child(rotate_button)
	remove_button = Button.new()
	remove_button.text = "Remove selected"
	remove_button.tooltip_text = "Remove the selected installed module. Shortcut: Delete while the chassis has focus."
	remove_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remove_button.pressed.connect(_on_remove_pressed)
	refit_actions.add_child(remove_button)
	controls.add_child(refit_actions)

	refit_label = Label.new()
	refit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	refit_label.custom_minimum_size = Vector2(320, 54)
	refit_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(refit_label)

	route_option = OptionButton.new()
	for route_id in LongMarchState.ROUTES.keys():
		route_option.add_item(LongMarchState.ROUTES[route_id].name)
		route_option.set_item_metadata(route_option.item_count - 1, route_id)
	controls.add_child(_labeled_control("Route", route_option))

	doctrine_option = OptionButton.new()
	for doctrine_id in ["protect_cargo", "protect_crew", "run_hot"]:
		doctrine_option.add_item(doctrine_id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	controls.add_child(_labeled_control("Journey doctrine", doctrine_option))

	threat_option = OptionButton.new()
	for threat_id in LongMarchState.THREATS.keys():
		threat_option.add_item(LongMarchState.THREATS[threat_id].name)
		threat_option.set_item_metadata(threat_option.item_count - 1, threat_id)
	controls.add_child(_labeled_control("Threat", threat_option))

	travel_button = Button.new()
	travel_button.text = "Depart: Ashgate → Morrowline"
	travel_button.tooltip_text = "Pay the route cost and begin the deterministic City 1 → City 2 encounter."
	travel_button.pressed.connect(_on_travel_pressed)
	controls.add_child(travel_button)

	advance_encounter_button = Button.new()
	advance_encounter_button.text = "Advance journey battle"
	advance_encounter_button.tooltip_text = "Resolve one readable encounter step."
	advance_encounter_button.pressed.connect(_on_advance_encounter_pressed)
	controls.add_child(advance_encounter_button)

	encounter_intervention_button = Button.new()
	encounter_intervention_button.text = "Encounter: Shift Power"
	encounter_intervention_button.tooltip_text = "Use the one allowed encounter intervention to prioritize weapons."
	encounter_intervention_button.pressed.connect(_on_encounter_intervention_pressed)
	controls.add_child(encounter_intervention_button)

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

func _on_module_selected(index: int) -> void:
	selected_module_id = String(module_option.get_item_metadata(index))
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false
	_set_event("Selected %s. Choose an empty chassis cell to place it." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
	_refresh_ui()

func _select_module_option(module_id: String) -> void:
	for index in range(module_option.item_count):
		if String(module_option.get_item_metadata(index)) == module_id:
			module_option.select(index)
			return

func _module_requires_exterior(module_id: String) -> bool:
	return "exterior" in state.module_definition(module_id).get("tags", [])

func _selected_installed_module() -> Dictionary:
	if selected_module_cell.x < 0 or selected_module_cell.y < 0:
		return {}
	return state.module_at(selected_module_cell)

func _on_grid_cell_pressed(cell: Vector2i) -> void:
	if not state.can_refit():
		_set_event("Refit is locked while the fortress is on the road. Reset or recover at Ashgate before changing the chassis.")
		return
	var clicked := state.module_at(cell)
	if not clicked.is_empty():
		selected_module_id = String(clicked.get("id", ""))
		selected_module_cell = Vector2i(clicked.get("position", cell))
		placement_rotated = bool(clicked.get("rotated", false))
		_select_module_option(selected_module_id)
		_set_event("Selected installed %s. Click an empty cell to move it, Rotate it, or remove it." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		_refresh_ui()
		return
	var selected_installed := _selected_installed_module()
	var result: Dictionary
	if not selected_installed.is_empty():
		result = state.reposition_module_at(selected_module_cell, cell, placement_rotated)
		if bool(result.get("ok", false)):
			selected_module_cell = cell
			_set_event("Moved %s to cell %d,%d." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), cell.x + 1, cell.y + 1])
		else:
			_set_event("Move blocked: %s." % String(result.get("reason", "unknown")))
	else:
		if state.module_count(selected_module_id) > 0:
			_set_event("That module is already installed. Select it on the chassis to move or remove it.")
			return
		result = state.place_module(selected_module_id, cell, _module_requires_exterior(selected_module_id), placement_rotated)
		if bool(result.get("ok", false)):
			selected_module_cell = cell
			_set_event("Installed %s at cell %d,%d." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), cell.x + 1, cell.y + 1])
		else:
			_set_event("Placement blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_rotate_pressed() -> void:
	if not state.can_refit():
		_set_event("Rotation is only available while refitting at Ashgate Depot.")
		return
	var base_shape := state.module_shape(selected_module_id, false)
	if base_shape.x == base_shape.y:
		_set_event("%s has a square footprint, so rotation does not change its placement." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		return
	var next_rotation := not placement_rotated
	var selected_installed := _selected_installed_module()
	if selected_installed.is_empty():
		placement_rotated = next_rotation
		_set_event("Placement footprint rotated. Choose a chassis cell.")
	else:
		var origin := Vector2i(selected_installed.get("position", selected_module_cell))
		var result := state.reposition_module_at(selected_module_cell, origin, next_rotation)
		if not bool(result.get("ok", false)):
			_set_event("Rotation blocked: %s." % String(result.get("reason", "unknown")))
		else:
			placement_rotated = next_rotation
			selected_module_cell = origin
			_set_event("Rotated %s in place." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
	_refresh_ui()

func _on_remove_pressed() -> void:
	if not state.can_refit():
		_set_event("Removal is only available while refitting at Ashgate Depot.")
		return
	var selected_installed := _selected_installed_module()
	if selected_installed.is_empty():
		_set_event("Select an installed module on the chassis before removing it.")
		return
	var result := state.remove_module_at(selected_module_cell)
	if bool(result.get("ok", false)):
		var removed: Dictionary = result.get("module", {})
		selected_module_id = String(removed.get("id", selected_module_id))
		placement_rotated = bool(removed.get("rotated", false))
		selected_module_cell = Vector2i(-1, -1)
		_set_event("Removed %s. Click an empty cell to place it again." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
	else:
		_set_event("Removal blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_travel_pressed() -> void:
	var route_id := _selected_id(route_option)
	var result := state.begin_journey(route_id, _selected_id(doctrine_option))
	if not bool(result.get("ok", false)):
		_set_event("Departure blocked: %s." % String(result.get("reason", "unknown")))
	else:
		_set_event("Journey begun. Forecast: %s. Advance one battle step at a time." % ", ".join(result.get("forecast", {}).get("threats", [])))
	_refresh_ui()

func _on_advance_encounter_pressed() -> void:
	var result := state.advance_encounter(1.0)
	if not bool(result.get("ok", false)):
		_set_event("Journey battle blocked: %s." % String(result.get("reason", "unknown")))
	elif bool(result.get("resolved", false)):
		_set_event("Journey battle resolved: %s." % String(result.get("outcome", "unknown")).replace("_", " ").capitalize())
	else:
		_set_event("Journey battle step %d resolved. Inspect the target before intervening." % int(result.get("step", 0)))
	_refresh_ui()

func _on_encounter_intervention_pressed() -> void:
	var result := state.use_encounter_intervention("shift_power")
	if not bool(result.get("ok", false)):
		_set_event("Encounter intervention blocked: %s." % String(result.get("reason", "unknown")))
	else:
		_set_event("Encounter intervention used: Shift Power. Weapons now receive priority.")
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
	var selected_definition := state.module_definition(selected_module_id)
	var selected_shape := state.module_shape(selected_module_id, placement_rotated)
	var selected_installed := _selected_installed_module()
	var mount_text := "Exterior mount" if _module_requires_exterior(selected_module_id) else "Interior chassis"
	if state.can_refit():
		refit_label.text = "%s · %dx%d · %s. %s" % [
			String(selected_definition.get("name", "Select a module")),
			selected_shape.x,
			selected_shape.y,
			mount_text,
			"Selected on chassis; click an empty cell to move it." if not selected_installed.is_empty() else "Click an empty cell to place it."
		]
	else:
		refit_label.text = "Refit locked during the journey. The current chassis remains visible for battle inspection."
	module_option.disabled = not state.can_refit()
	rotate_button.disabled = not state.can_refit()
	remove_button.disabled = not state.can_refit() or selected_installed.is_empty()
	travel_button.disabled = state.encounter_active or state.journey_complete
	advance_encounter_button.disabled = not state.encounter_active
	encounter_intervention_button.disabled = not state.encounter_active or state.encounter_intervention_used
	status_label.text = "Day %d  |  Fuel %d  |  Ashmarks %d  |  Hull %d  |  Mass %d/%d  |  Power %d/%d  |  Heat %d/%d" % [snapshot.day, snapshot.fuel, snapshot.money, snapshot.hull_condition, snapshot.mass, snapshot.mass_limit, snapshot.power_draw, snapshot.power_output, snapshot.heat, snapshot.heat_limit]
	journey_label.text = "JOURNEY — Ashgate Depot → Rill Crossing → Morrowline Camp\nCurrent node: %s | Route: %s | Destination: %s" % [String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), String(LongMarchState.ROUTES.get(state.journey_route, {}).get("name", "not chosen")), String(LongMarchState.JOURNEY_NODES.get(state.journey_destination, {}).get("name", state.journey_destination))]
	var encounter_lines: Array[String] = []
	for enemy in state.encounter_enemies:
		var enemy_id: String = String(enemy.get("id", ""))
		var enemy_name: String = String(LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id))
		var enemy_state: String = "defeated" if bool(enemy.get("defeated", false)) else "%d/%d hp" % [int(enemy.get("hp", 0)), int(enemy.get("max_hp", 0))]
		var target: String = String(enemy.get("target", "approaching"))
		encounter_lines.append("%s — %s — target %s" % [enemy_name, enemy_state, target])
	encounter_label.text = "ENCOUNTER — %s | step %d/6 | progress %.0f%%\n%s" % ["active" if state.encounter_active else (state.encounter_outcome if not state.encounter_outcome.is_empty() else "not started"), state.encounter_step, state.encounter_progress * 100.0, " | ".join(encounter_lines) if not encounter_lines.is_empty() else "No active contacts. Depart from Ashgate Depot to begin the test battle."]
	var recent: Array[String] = []
	var start := maxi(0, state.log.size() - 4)
	for index in range(start, state.log.size()):
		recent.append(state.log[index])
	log_label.text = "Log: " + (" | ".join(recent) if not recent.is_empty() else "The crew is waiting for a route order.")
	if event_label.text.is_empty():
		event_label.text = "Refit at Ashgate: choose a module, click the chassis to place or select it, then depart when the machine is ready."
	fortress_panel.state = state
	fortress_panel.placement_module_id = selected_module_id
	fortress_panel.placement_rotated = placement_rotated
	fortress_panel.selected_cell = selected_module_cell
	fortress_panel.queue_redraw()

class FortressPanel extends Control:
	signal grid_cell_pressed(cell: Vector2i)
	signal rotate_requested
	signal remove_requested

	var state: LongMarchState
	const CELL := 58.0
	const ORIGIN := Vector2(28, 22)
	var placement_module_id: String = ""
	var placement_rotated: bool = false
	var selected_cell := Vector2i(-1, -1)
	var cursor_cell := Vector2i(0, 0)
	var family_colors := {
		"engine": Color("#b86f4b"),
		"weapon": Color("#b44949"),
		"workshop": Color("#b69555"),
		"crew_room": Color("#557fa1"),
		"armor": Color("#6f7b84"),
		"cargo": Color("#8e6d4f"),
		"signal": Color("#5e9b91")
	}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = "Click a module to select it, or click an empty cell to place or move. Use arrow keys and Enter after focusing the chassis."

	func _grid_rect() -> Rect2:
		return Rect2(ORIGIN, Vector2(LongMarchState.GRID_WIDTH * CELL, LongMarchState.GRID_HEIGHT * CELL))

	func _cell_from_point(point: Vector2) -> Vector2i:
		if not _grid_rect().has_point(point):
			return Vector2i(-1, -1)
		var relative := point - ORIGIN
		return Vector2i(int(relative.x / CELL), int(relative.y / CELL))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			var next_cell := _cell_from_point(event.position)
			if next_cell.x >= 0:
				cursor_cell = next_cell
				queue_redraw()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked := _cell_from_point(event.position)
			if clicked.x >= 0:
				cursor_cell = clicked
				grab_focus()
				grid_cell_pressed.emit(clicked)
				accept_event()
		elif event.is_action_pressed("ui_left"):
			cursor_cell.x = maxi(0, cursor_cell.x - 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_right"):
			cursor_cell.x = mini(LongMarchState.GRID_WIDTH - 1, cursor_cell.x + 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_up"):
			cursor_cell.y = maxi(0, cursor_cell.y - 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_down"):
			cursor_cell.y = mini(LongMarchState.GRID_HEIGHT - 1, cursor_cell.y + 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_accept"):
			grid_cell_pressed.emit(cursor_cell)
			accept_event()
		elif event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_R:
				rotate_requested.emit()
				accept_event()
			elif event.keycode in [KEY_DELETE, KEY_BACKSPACE]:
				remove_requested.emit()
				accept_event()

	func _module_rect(instance: Dictionary) -> Rect2:
		var position: Vector2i = instance.get("position", Vector2i.ZERO)
		var shape := state.module_shape(String(instance.get("id", "")), bool(instance.get("rotated", false)))
		return Rect2(ORIGIN + Vector2(position.x * CELL, position.y * CELL), Vector2(shape.x * CELL - 3, shape.y * CELL - 3))

	func _draw_module_name(rect: Rect2, name: String) -> void:
		var words := name.split(" ")
		if words.size() > 1 and (rect.size.x < CELL * 1.5 or name.length() > 14):
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 18), String(words[0]), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10, 10, Color("#f7efe0"))
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 34), " ".join(words.slice(1)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10, 10, Color("#f7efe0"))
		else:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 22), name, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 11, Color("#f7efe0"))

	func _draw_preview() -> void:
		if state == null or not state.can_refit() or placement_module_id.is_empty():
			return
		var exterior: bool = "exterior" in state.module_definition(placement_module_id).get("tags", [])
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		var validation: Dictionary
		if selected.is_empty():
			validation = state.validate_module_placement(placement_module_id, cursor_cell, exterior, placement_rotated)
		else:
			validation = state.validate_module_reposition(selected_cell, cursor_cell, placement_rotated)
		var preview := state.module_instance(placement_module_id, cursor_cell, exterior, placement_rotated)
		var color := Color(0.35, 0.85, 0.58, 0.42) if bool(validation.get("ok", false)) else Color(0.92, 0.3, 0.25, 0.42)
		for cell in state.occupied_cells(preview):
			if cell.x >= 0 and cell.x < LongMarchState.GRID_WIDTH and cell.y >= 0 and cell.y < LongMarchState.GRID_HEIGHT:
				draw_rect(Rect2(ORIGIN + Vector2(cell.x * CELL, cell.y * CELL), Vector2(CELL - 3, CELL - 3)), color, true)

	func _draw_refit_details() -> void:
		var x := 410.0
		draw_string(ThemeDB.fallback_font, Vector2(x, 40), "REFIT STATUS", HORIZONTAL_ALIGNMENT_LEFT, 300, 16, Color("#e8c58e"))
		if state == null or placement_module_id.is_empty():
			return
		var definition := state.module_definition(placement_module_id)
		var shape := state.module_shape(placement_module_id, placement_rotated)
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		draw_string(ThemeDB.fallback_font, Vector2(x, 70), String(definition.get("name", placement_module_id)), HORIZONTAL_ALIGNMENT_LEFT, 300, 15, Color("#f1e6cf"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 94), "%dx%d footprint · mass %d · power %d · heat %d" % [shape.x, shape.y, int(definition.get("mass", 0)), int(definition.get("power_draw", 0)), int(definition.get("heat", 0))], HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#aab6ba"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 118), "Exterior mount" if "exterior" in definition.get("tags", []) else "Interior chassis", HORIZONTAL_ALIGNMENT_LEFT, 300, 12, Color("#d8c389"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 154), "Selected module: click empty cell to move" if not selected.is_empty() else "Pending module: click empty cell to place", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#b9c3bf"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 178), "Green preview = valid · red = blocked", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#b9c3bf"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 214), "Keyboard/controller: arrows + confirm", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#8fa3a7"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 236), "R rotates · Delete removes", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#8fa3a7"))

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#18242b"), true)
		draw_string(ThemeDB.fallback_font, Vector2(ORIGIN.x, 14), "CHASSIS GRID — exterior mounts use a bright edge", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#b9c3bf"))
		for y in range(LongMarchState.GRID_HEIGHT):
			for x in range(LongMarchState.GRID_WIDTH):
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#223139"), true)
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#4a5c61"), false, 1.0)
		if state == null:
			return
		_draw_preview()
		for instance in state.modules:
			var definition := state.module_definition(String(instance.get("id", "")))
			var rect := _module_rect(instance)
			var color: Color = family_colors.get(String(definition.get("family", "")), Color("#8b8b8b"))
			draw_rect(rect, color.darkened(0.25) if int(instance.get("durability", 0)) <= 0 else color, true)
			draw_rect(rect, Color("#f0db9a") if bool(instance.get("exterior", false)) else Color("#b9c3bf"), false, 3.0 if bool(instance.get("exterior", false)) else 1.0)
			_draw_module_name(rect, String(definition.get("name", instance.get("id", ""))))
			if selected_cell in state.occupied_cells(instance):
				draw_rect(rect.grow(2), Color("#69d8cf"), false, 3.0)
		var cursor_rect := Rect2(ORIGIN + Vector2(cursor_cell.x * CELL, cursor_cell.y * CELL), Vector2(CELL - 3, CELL - 3))
		draw_rect(cursor_rect, Color("#e8c58e") if has_focus() else Color("#7d8f93"), false, 2.0)
		_draw_refit_details()
