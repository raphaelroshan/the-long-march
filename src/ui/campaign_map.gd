class_name CampaignMapView
extends Control

signal node_selected(node_id: String)
signal route_committed(node_id: String)

const MAP_SIZE := Vector2(320, 356)
const NODE_SIZE := Vector2(132, 40)
const NODE_ORDER := [
	"ashgate_depot",
	"rill_crossing",
	"soot_orchard",
	"broken_relay",
	"red_wheel_toll_bridge",
	"morrowline_camp",
	"lower_ash_road",
	"signal_causeway",
	"meridian_pass"
]
const NODE_POSITIONS := {
	"ashgate_depot": Vector2(94, 8),
	"rill_crossing": Vector2(4, 56),
	"soot_orchard": Vector2(184, 56),
	"broken_relay": Vector2(4, 104),
	"red_wheel_toll_bridge": Vector2(184, 104),
	"morrowline_camp": Vector2(94, 152),
	"lower_ash_road": Vector2(4, 200),
	"signal_causeway": Vector2(184, 200),
	"meridian_pass": Vector2(94, 248)
}
const SHORT_NAMES := {
	"ashgate_depot": "Ashgate Depot",
	"rill_crossing": "Rill Crossing",
	"soot_orchard": "Soot Orchard",
	"broken_relay": "Broken Relay",
	"red_wheel_toll_bridge": "Red Wheel Toll",
	"morrowline_camp": "Morrowline Camp",
	"lower_ash_road": "Lower Ash Road",
	"signal_causeway": "Signal Causeway",
	"meridian_pass": "Meridian Pass"
}

var node_buttons: Array[Button] = []
var buttons_by_id: Dictionary = {}
var node_statuses: Dictionary = {}
var campaign_edges: Dictionary = {}
var current_node: String = ""
var secured_path: Array[String] = []
var available_nodes: Array[String] = []
var closed_nodes: Array[String] = []
var outgoing_nodes: Array[String] = []
var current_previews: Dictionary = {}
var interaction_is_blocked: bool = false
var selected_node: String = ""
var detail_label: Label
var commit_button: Button

func _init() -> void:
	custom_minimum_size = MAP_SIZE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_node_buttons()
	detail_label = Label.new()
	detail_label.position = Vector2(8, 296)
	detail_label.size = Vector2(304, 55)
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 11)
	detail_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	add_child(detail_label)
	commit_button = Button.new()
	commit_button.custom_minimum_size = Vector2(0, 48)
	commit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commit_button.text = "Select a route to continue"
	commit_button.disabled = true
	commit_button.focus_mode = Control.FOCUS_ALL
	commit_button.pressed.connect(_on_commit_pressed)
	commit_button.add_theme_stylebox_override("normal", _style(Color("#285348"), Color("#73c99b"), 2))
	commit_button.add_theme_stylebox_override("hover", _style(Color("#32665a"), Color("#8fe2bd"), 2))
	commit_button.add_theme_stylebox_override("pressed", _style(Color("#1d3c34"), Color("#ffffff"), 2))
	commit_button.add_theme_stylebox_override("focus", _style(Color("#285348"), Color("#ffffff"), 3))
	add_child(commit_button)

func _build_node_buttons() -> void:
	for node_id in NODE_ORDER:
		var button := Button.new()
		button.name = "MapNode_" + String(node_id)
		button.position = NODE_POSITIONS[node_id]
		button.size = NODE_SIZE
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 11)
		button.set_meta("node_id", node_id)
		button.pressed.connect(_on_node_pressed.bind(node_id))
		button.focus_entered.connect(_show_node_detail.bind(node_id))
		button.mouse_entered.connect(_show_node_detail.bind(node_id))
		node_buttons.append(button)
		buttons_by_id[node_id] = button
		add_child(button)

func _on_node_pressed(node_id: String) -> void:
	var button: Button = buttons_by_id.get(node_id)
	if button == null or button.disabled:
		return
	node_selected.emit(node_id)

func _on_commit_pressed() -> void:
	if selected_node.is_empty() or commit_button.disabled:
		return
	route_committed.emit(selected_node)

func _style(fill: Color, border: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(5)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func _apply_button_style(button: Button, status: String) -> void:
	var fill := Color("#1b252b")
	var border := Color("#536268")
	var text_color := Color("#819095")
	match status:
		"current":
			fill = Color("#5b482b")
			border = Color("#e8c58e")
			text_color = Color("#fff1ce")
		"secured":
			fill = Color("#24443b")
			border = Color("#73c99b")
			text_color = Color("#d4f1e4")
		"available":
			fill = Color("#214752")
			border = Color("#69d8cf")
			text_color = Color("#e3fffb")
		"selected":
			fill = Color("#4b405d")
			border = Color("#eee2ff")
			text_color = Color("#ffffff")
		"closed":
			fill = Color("#482929")
			border = Color("#e06f61")
			text_color = Color("#ffd4cd")
		"blocked":
			fill = Color("#403725")
			border = Color("#d8a650")
			text_color = Color("#f1ddb5")
	button.add_theme_stylebox_override("normal", _style(fill, border))
	button.add_theme_stylebox_override("disabled", _style(fill.darkened(0.12), border.darkened(0.18)))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.08), border.lightened(0.12), 3))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.08), Color("#ffffff"), 3))
	button.add_theme_stylebox_override("focus", _style(fill, Color("#ffffff"), 3))
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_disabled_color", text_color.darkened(0.18))
	button.add_theme_color_override("font_hover_color", text_color.lightened(0.08))
	button.add_theme_color_override("font_focus_color", text_color)

func _preview_tooltip(preview: Dictionary) -> String:
	var visibility := String(preview.get("visibility", "forecast"))
	if visibility == "known":
		return "Known route · %d day(s) · %d fuel · %.0f%% risk · pressure +%d · reward %d\nThreats: %s" % [int(preview.get("days", 0)), int(preview.get("fuel", 0)), float(preview.get("risk", 0.0)) * 100.0, int(preview.get("pressure_gain", 0)), int(preview.get("reward", 0)), ", ".join(preview.get("threats", []))]
	if visibility == "forecast":
		return "Forecast route · %d day(s) · %d fuel · %.0f%% risk · pressure +%d\nExpected: %s. Exact contacts remain uncertain." % [int(preview.get("days", 0)), int(preview.get("fuel", 0)), float(preview.get("risk", 0.0)) * 100.0, int(preview.get("pressure_gain", 0)), String(preview.get("threat_hint", "uncertain pressure"))]
	return "Unscouted route · %d day(s) · %d fuel\nBroad warning: %s. Risk, reward, and exact contacts are unknown." % [int(preview.get("days", 0)), int(preview.get("fuel", 0)), String(preview.get("threat_hint", "uncertain pressure"))]

func _show_node_detail(node_id: String) -> void:
	var status := status_for(node_id)
	if status in ["available", "selected"]:
		detail_label.text = ("SELECTED — " if status == "selected" else "") + _preview_tooltip(current_previews.get(node_id, {}))
	elif status == "closed":
		detail_label.text = "%s is closed at Break pressure. Reliable forecasting can reopen it." % String(SHORT_NAMES.get(node_id, node_id))
	elif status == "blocked":
		detail_label.text = "Resolve the current contract or local decision before taking this road."
	elif status == "current":
		detail_label.text = "%s is the fortress's current position." % String(SHORT_NAMES.get(node_id, node_id))
	elif status == "secured":
		detail_label.text = "%s is secured behind the fortress." % String(SHORT_NAMES.get(node_id, node_id))
	else:
		detail_label.text = "%s is charted but not yet reachable." % String(SHORT_NAMES.get(node_id, node_id))

func configure(view: Dictionary) -> void:
	campaign_edges = view.get("edges", {}).duplicate(true)
	current_node = String(view.get("current_node", ""))
	secured_path = _to_string_array(view.get("secured_path", []))
	available_nodes = _to_string_array(view.get("available_nodes", []))
	closed_nodes = _to_string_array(view.get("closed_nodes", []))
	outgoing_nodes = _to_string_array(view.get("outgoing_nodes", []))
	selected_node = String(view.get("selected_node", ""))
	current_previews = view.get("previews", {}).duplicate(true)
	var can_depart := bool(view.get("can_depart", false))
	var show_commit := bool(view.get("show_commit", true))
	interaction_is_blocked = bool(view.get("interaction_blocked", false))
	node_statuses.clear()
	for node_id in NODE_ORDER:
		var button: Button = buttons_by_id[node_id]
		var status := "future"
		if node_id == current_node:
			status = "current"
		elif node_id in secured_path:
			status = "secured"
		elif node_id in closed_nodes:
			status = "closed"
		elif interaction_is_blocked and node_id in outgoing_nodes:
			status = "blocked"
		elif node_id == selected_node and node_id in available_nodes:
			status = "selected"
		elif node_id in available_nodes:
			status = "available"
		node_statuses[node_id] = status
		var state_text := status.capitalize()
		if status == "available":
			state_text = String(current_previews.get(node_id, {}).get("visibility", "forecast")).capitalize()
		elif status == "selected":
			state_text = "Selected"
		elif status == "blocked":
			state_text = "Decision required"
		button.text = "%s\n%s" % [String(SHORT_NAMES.get(node_id, node_id)), state_text]
		button.disabled = status not in ["available", "selected"] or not can_depart or interaction_is_blocked
		if status in ["available", "selected"]:
			button.tooltip_text = _preview_tooltip(current_previews.get(node_id, {}))
		elif status == "closed":
			button.tooltip_text = "Closed by Break pressure. Reliable forecasting can reopen this road."
		elif status == "blocked":
			button.tooltip_text = "Resolve the current contract or local decision before departing."
		elif status == "current":
			button.tooltip_text = "The fortress's current position."
		elif status == "secured":
			button.tooltip_text = "Secured earlier in this run."
		else:
			button.tooltip_text = "This node is visible on the regional chart but is not yet reachable."
		_apply_button_style(button, status)
	commit_button.visible = show_commit and not interaction_is_blocked
	commit_button.disabled = selected_node.is_empty() or selected_node not in available_nodes or not can_depart or interaction_is_blocked
	if not selected_node.is_empty() and selected_node in available_nodes:
		var selected_preview: Dictionary = current_previews.get(selected_node, {})
		commit_button.text = "COMMIT · %s\n%d day(s) · %d fuel · %.0f%% risk · pressure +%d" % [String(SHORT_NAMES.get(selected_node, selected_node)), int(selected_preview.get("days", 0)), int(selected_preview.get("fuel", 0)), float(selected_preview.get("risk", 0.0)) * 100.0, int(selected_preview.get("pressure_gain", 0))]
		commit_button.tooltip_text = "Pay the displayed route costs and begin this encounter."
		_show_node_detail(selected_node)
	elif not available_nodes.is_empty():
		commit_button.text = "Select a route to continue"
		commit_button.tooltip_text = "Choose one of the cyan route nodes before committing."
		_show_node_detail(available_nodes[0])
	elif not current_node.is_empty():
		commit_button.text = "No route selected"
		_show_node_detail(current_node)
	queue_redraw()

func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(String(item))
	return result

func status_for(node_id: String) -> String:
	return String(node_statuses.get(node_id, "future"))

func button_for(node_id: String) -> Button:
	return buttons_by_id.get(node_id)

func _node_center(node_id: String) -> Vector2:
	return Vector2(NODE_POSITIONS.get(node_id, Vector2.ZERO)) + NODE_SIZE * 0.5

func _path_contains_edge(from_id: String, to_id: String) -> bool:
	for index in range(secured_path.size() - 1):
		if secured_path[index] == from_id and secured_path[index + 1] == to_id:
			return true
	return false

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#141e24"), true)
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("#34454c"), false, 1.0)
	for raw_source in campaign_edges.keys():
		var source := String(raw_source)
		for raw_target in campaign_edges.get(source, []):
			var target := String(raw_target)
			var color := Color("#39484e")
			var width := 2.0
			if _path_contains_edge(source, target):
				color = Color("#73c99b")
				width = 4.0
			elif source == current_node and target in closed_nodes:
				color = Color("#e06f61")
				width = 3.0
			elif source == current_node and target in available_nodes:
				if target == selected_node:
					color = Color("#eee2ff")
					width = 4.0
				else:
					color = Color("#69d8cf")
					width = 3.0
			elif source == current_node and target in outgoing_nodes:
				color = Color("#d8a650")
				width = 3.0
			draw_line(_node_center(source), _node_center(target), color, width, true)
