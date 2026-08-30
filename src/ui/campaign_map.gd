class_name CampaignMapView
extends Control

const VisualContrast = preload("res://src/support/visual_contrast.gd")

signal node_selected(node_id: String)
signal route_committed(node_id: String)
signal node_inspected(node_id: String, detail: String)

const MAP_SIZE := Vector2(320, 340)
const NODE_SIZE := Vector2(132, 40)
const NODE_ORDER := [
	"ashgate_depot",
	"rill_crossing",
	"soot_orchard",
	"broken_relay",
	"red_wheel_toll_bridge",
	"morrowline_camp",
	"lower_ash_road",
	"dry_cistern_cut",
	"signal_causeway",
	"cinder_quarry",
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
	"dry_cistern_cut": Vector2(4, 248),
	"cinder_quarry": Vector2(184, 248),
	"meridian_pass": Vector2(94, 296)
}
const SHORT_NAMES := {
	"ashgate_depot": "Ashgate Depot",
	"rill_crossing": "Rill Crossing",
	"soot_orchard": "Soot Orchard",
	"broken_relay": "Broken Relay",
	"red_wheel_toll_bridge": "Red Wheel Toll",
	"morrowline_camp": "Morrowline Camp",
	"lower_ash_road": "Lower Ash Road",
	"dry_cistern_cut": "Dry Cistern Cut",
	"signal_causeway": "Signal Causeway",
	"cinder_quarry": "Cinder Quarry",
	"meridian_pass": "Meridian Pass"
}
const REGION_LAYOUTS := {
	"ashgate_lowlands": {
		"node_order": NODE_ORDER,
		"node_positions": NODE_POSITIONS,
		"short_names": SHORT_NAMES,
		"final_nodes": ["meridian_pass"],
		"closed_reason": "Closed by Break pressure. Ready forecasting gear or Iven Pell can reopen this road."
	},
	"flooded_veyru": {
		"node_order": ["lantern_quay", "pump_gallery", "sunken_tramworks", "veyru_evacuation_camp", "archive_causeway", "drowned_registry", "pilgrim_gantry", "dry_archive_gate", "dry_archive"],
		"node_positions": {
			"lantern_quay": Vector2(94, 8),
			"pump_gallery": Vector2(4, 56),
			"sunken_tramworks": Vector2(184, 56),
			"veyru_evacuation_camp": Vector2(94, 104),
			"archive_causeway": Vector2(4, 152),
			"drowned_registry": Vector2(184, 152),
			"pilgrim_gantry": Vector2(94, 200),
			"dry_archive_gate": Vector2(94, 248),
			"dry_archive": Vector2(94, 296)
		},
		"short_names": {
			"lantern_quay": "Lantern Quay",
			"pump_gallery": "Pump Gallery",
			"sunken_tramworks": "Sunken Tramworks",
			"veyru_evacuation_camp": "Evacuation Camp",
			"archive_causeway": "Archive Causeway",
			"drowned_registry": "Drowned Registry",
			"pilgrim_gantry": "Pilgrim Gantry",
			"dry_archive_gate": "Dry Archive Gate",
			"dry_archive": "Dry Archive"
		},
		"final_nodes": ["dry_archive"],
		"closed_reason": "Closed by rising water. Pilgrim Gantry remains available as the recovery road."
	}
}

var node_buttons: Array[Button] = []
var buttons_by_id: Dictionary = {}
var region_id: String = "ashgate_lowlands"
var node_order: Array[String] = []
var node_positions: Dictionary = {}
var short_names: Dictionary = {}
var final_nodes: Array[String] = []
var closed_reason: String = ""
var node_statuses: Dictionary = {}
var campaign_edges: Dictionary = {}
var current_node: String = ""
var secured_path: Array[String] = []
var available_nodes: Array[String] = []
var closed_nodes: Array[String] = []
var locked_reasons: Dictionary = {}
var outgoing_nodes: Array[String] = []
var current_previews: Dictionary = {}
var interaction_is_blocked: bool = false
var selected_node: String = ""
var current_fuel: int = 0
var current_day: int = 0
var current_pressure: int = 0
var commit_button: Button
var high_contrast_enabled: bool = false
var compact_commit_labels: bool = false

func _init() -> void:
	custom_minimum_size = MAP_SIZE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	resized.connect(_layout_node_buttons)
	_apply_region_layout(region_id)
	_build_node_buttons()
	commit_button = Button.new()
	commit_button.custom_minimum_size = Vector2(0, 64)
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
	_layout_node_buttons.call_deferred()

func _build_node_buttons() -> void:
	for node_id in node_order:
		var button := Button.new()
		button.name = "MapNode_" + String(node_id)
		button.position = node_positions[node_id]
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
	_layout_node_buttons.call_deferred()

func _layout_node_buttons() -> void:
	var offset := Vector2(maxf(0.0, (size.x - MAP_SIZE.x) * 0.5), maxf(0.0, (size.y - MAP_SIZE.y) * 0.5))
	for node_id in node_order:
		var button := buttons_by_id.get(node_id) as Button
		if button != null:
			button.position = Vector2(node_positions.get(node_id, Vector2.ZERO)) + offset
	queue_redraw()

func _apply_region_layout(next_region_id: String) -> void:
	var layout: Dictionary = REGION_LAYOUTS.get(next_region_id, REGION_LAYOUTS["ashgate_lowlands"])
	region_id = next_region_id if REGION_LAYOUTS.has(next_region_id) else "ashgate_lowlands"
	node_order = _to_string_array(layout.get("node_order", NODE_ORDER))
	node_positions = layout.get("node_positions", NODE_POSITIONS).duplicate(true)
	short_names = layout.get("short_names", SHORT_NAMES).duplicate(true)
	final_nodes = _to_string_array(layout.get("final_nodes", ["meridian_pass"]))
	closed_reason = String(layout.get("closed_reason", "This road is closed by regional pressure."))

func set_region_layout(next_region_id: String) -> void:
	var resolved_region := next_region_id if REGION_LAYOUTS.has(next_region_id) else "ashgate_lowlands"
	if resolved_region == region_id and not node_buttons.is_empty():
		return
	for button in node_buttons:
		if is_instance_valid(button):
			button.queue_free()
	node_buttons.clear()
	buttons_by_id.clear()
	node_statuses.clear()
	_apply_region_layout(resolved_region)
	_build_node_buttons()
	queue_redraw()

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

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	queue_redraw()

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
		"locked":
			fill = Color("#3b3428")
			border = Color("#d8a650")
			text_color = Color("#f1ddb5")
		"bypassed":
			fill = Color("#28231f")
			border = Color("#66584d")
			text_color = Color("#a99a8d")
		"blocked":
			fill = Color("#403725")
			border = Color("#d8a650")
			text_color = Color("#f1ddb5")
	if high_contrast_enabled:
		fill = fill.darkened(0.38)
		border = VisualContrast.display_color(border)
		text_color = VisualContrast.display_color(text_color)
	var normal_width := 3 if high_contrast_enabled else 2
	var focus_width := 4 if high_contrast_enabled else 3
	button.add_theme_stylebox_override("normal", _style(fill, border, normal_width))
	button.add_theme_stylebox_override("disabled", _style(fill.darkened(0.08), border.darkened(0.10), normal_width))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.08), border.lightened(0.08), focus_width))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.08), Color.WHITE, focus_width))
	button.add_theme_stylebox_override("focus", _style(fill, Color.WHITE, focus_width))
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_disabled_color", text_color.darkened(0.18))
	button.add_theme_color_override("font_hover_color", text_color.lightened(0.08))
	button.add_theme_color_override("font_focus_color", text_color)

func _preview_tooltip(preview: Dictionary, include_intel_upgrade: bool = true) -> String:
	var visibility := String(preview.get("visibility", "forecast"))
	var development_name := String(preview.get("regional_development", ""))
	var development_detail := "\nRegional development: %s reveals these contacts from an earlier march." % development_name if not development_name.is_empty() else ""
	var days := int(preview.get("days", 0))
	var day_text := "%d day%s" % [days, "" if days == 1 else "s"]
	var risk := float(preview.get("risk", 0.0))
	var risk_band := _risk_band(risk)
	var intel_upgrade := "\nIntel upgrade: ready forecasting gear or Iven Pell reveals exact contacts, lowers route risk by up to 8 points, and reduces encounter pressure by 1." if include_intel_upgrade else ""
	var sustain_effect := "\nSustain: Ready Water Condenser saves 1 fuel on this road." if int(preview.get("fuel_discount", 0)) > 0 else ""
	var route_effect := String(preview.get("route_effect", ""))
	var route_effect_detail := "\nRecovery: %s." % route_effect if not route_effect.is_empty() else ""
	var risk_factors: Array = preview.get("risk_factors", [])
	var risk_detail := ""
	if include_intel_upgrade:
		var factor_text := " · ".join(risk_factors) if not risk_factors.is_empty() else "none visible"
		risk_detail = "\n%s risk factors: %s." % ["Visible" if visibility == "unscouted" else "Current", factor_text]
	if visibility == "known":
		var counters: Array = preview.get("counter_hints", [])
		var counter_detail := "\nPrepare: %s." % " or ".join(counters) if not counters.is_empty() else ""
		var ready_counters: Array = preview.get("ready_counter_names", [])
		var readiness_detail := "\nReady now: %s." % ", ".join(ready_counters) if not ready_counters.is_empty() else "\nReady now: no listed module counter."
		return "Known route · %s · %d fuel · %s risk (%.0f%%) · pressure +%d · reward %d\nThreats: %s%s%s%s%s%s%s" % [day_text, int(preview.get("fuel", 0)), risk_band, risk * 100.0, int(preview.get("pressure_gain", 0)), int(preview.get("reward", 0)), ", ".join(preview.get("threats", [])), counter_detail, readiness_detail, sustain_effect, route_effect_detail, risk_detail, development_detail]
	if visibility == "forecast":
		return "Forecast route · %s · %d fuel · %s risk (%.0f%%) · pressure +%d\nExpected: %s. Exact contacts remain uncertain.%s%s%s%s" % [day_text, int(preview.get("fuel", 0)), risk_band, risk * 100.0, int(preview.get("pressure_gain", 0)), String(preview.get("threat_hint", "uncertain pressure")), sustain_effect, route_effect_detail, risk_detail, intel_upgrade]
	return "Unscouted route · %s · %d fuel\nBroad warning: %s. Risk, reward, and exact contacts are unknown.%s%s%s%s" % [day_text, int(preview.get("fuel", 0)), String(preview.get("threat_hint", "uncertain pressure")), sustain_effect, route_effect_detail, risk_detail, intel_upgrade]

func _risk_band(risk: float) -> String:
	if risk <= 0.18:
		return "LOW"
	if risk <= 0.32:
		return "GUARDED"
	return "HIGH"

func intel_tone_for(node_id: String) -> String:
	var status := status_for(node_id)
	if status == "closed":
		return "danger"
	if status in ["blocked", "locked"]:
		return "warning"
	if status in ["current", "secured"]:
		return "safe"
	if status not in ["available", "selected"]:
		return "neutral"
	var preview: Dictionary = current_previews.get(node_id, {})
	if String(preview.get("visibility", "forecast")) == "unscouted":
		return "unknown"
	match _risk_band(float(preview.get("risk", 0.0))):
		"LOW":
			return "safe"
		"GUARDED":
			return "warning"
		_:
			return "danger"

func _node_state_text(node_id: String, status: String) -> String:
	if status in ["available", "selected"]:
		var preview: Dictionary = current_previews.get(node_id, {})
		var visibility := String(preview.get("visibility", "forecast")).to_upper()
		var risk_text := "UNKNOWN" if visibility == "UNSCOUTED" else _risk_band(float(preview.get("risk", 0.0)))
		return "%s · %s" % ["SELECTED" if status == "selected" else visibility, risk_text]
	if status == "blocked":
		return "DECISION REQUIRED"
	if status == "locked":
		return "SYSTEM REQUIRED"
	return status.to_upper()

func _show_node_detail(node_id: String) -> void:
	node_inspected.emit(node_id, detail_for(node_id))

func _is_reachable_from_current(target_id: String) -> bool:
	if current_node.is_empty():
		return false
	var pending: Array[String] = [current_node]
	var visited := {}
	while not pending.is_empty():
		var node_id: String = pending.pop_back()
		if node_id == target_id:
			return true
		if visited.has(node_id):
			continue
		visited[node_id] = true
		for raw_next_id in campaign_edges.get(node_id, []):
			var next_id := String(raw_next_id)
			if not visited.has(next_id):
				pending.append(next_id)
	return false

func detail_for(node_id: String) -> String:
	var status := status_for(node_id)
	if status == "available":
		return _preview_tooltip(current_previews.get(node_id, {}))
	if status == "selected":
		return "SELECTED — " + _preview_tooltip(current_previews.get(node_id, {}), false)
	if status == "closed":
		return "%s is closed. %s" % [String(short_names.get(node_id, node_id)), closed_reason]
	if status == "locked":
		return String(locked_reasons.get(node_id, "A required fortress system is not Ready."))
	if status == "blocked":
		return "Resolve the current contract or local decision before taking this road."
	if status == "current":
		return "%s is the fortress's current position." % String(short_names.get(node_id, node_id))
	if status == "secured":
		return "%s is secured behind the fortress." % String(short_names.get(node_id, node_id))
	if status == "bypassed":
		return "%s was bypassed and cannot be revisited in this run." % String(short_names.get(node_id, node_id))
	return "%s is charted but not yet reachable." % String(short_names.get(node_id, node_id))

func configure(view: Dictionary) -> void:
	set_region_layout(String(view.get("region_id", "ashgate_lowlands")))
	campaign_edges = view.get("edges", {}).duplicate(true)
	current_node = String(view.get("current_node", ""))
	secured_path = _to_string_array(view.get("secured_path", []))
	available_nodes = _to_string_array(view.get("available_nodes", []))
	closed_nodes = _to_string_array(view.get("closed_nodes", []))
	locked_reasons = view.get("locked_reasons", {}).duplicate(true)
	outgoing_nodes = _to_string_array(view.get("outgoing_nodes", []))
	selected_node = String(view.get("selected_node", ""))
	current_fuel = int(view.get("current_fuel", 0))
	current_day = int(view.get("current_day", 0))
	current_pressure = int(view.get("current_pressure", 0))
	current_previews = view.get("previews", {}).duplicate(true)
	var can_depart := bool(view.get("can_depart", false))
	var departure_block_reason := String(view.get("departure_block_reason", ""))
	var heat_limit := int(view.get("heat_limit", 6))
	var show_commit := bool(view.get("show_commit", true))
	interaction_is_blocked = bool(view.get("interaction_blocked", false))
	node_statuses.clear()
	for node_id in node_order:
		var button: Button = buttons_by_id[node_id]
		var status := "future" if _is_reachable_from_current(node_id) else "bypassed"
		if node_id == current_node:
			status = "current"
		elif node_id in secured_path:
			status = "secured"
		elif node_id in closed_nodes:
			status = "closed"
		elif locked_reasons.has(node_id):
			status = "locked"
		elif interaction_is_blocked and node_id in outgoing_nodes:
			status = "blocked"
		elif node_id == selected_node and node_id in available_nodes:
			status = "selected"
		elif node_id in available_nodes:
			status = "available"
		node_statuses[node_id] = status
		var state_text := _node_state_text(node_id, status)
		button.text = "%s\n%s" % [String(short_names.get(node_id, node_id)), state_text]
		button.disabled = status not in ["available", "selected"] or interaction_is_blocked
		if status in ["available", "selected"]:
			button.tooltip_text = _preview_tooltip(current_previews.get(node_id, {}))
		elif status == "closed":
			button.tooltip_text = closed_reason
		elif status == "locked":
			button.tooltip_text = String(locked_reasons.get(node_id, "A required fortress system is not Ready."))
		elif status == "blocked":
			button.tooltip_text = "Resolve the current contract or local decision before departing."
		elif status == "current":
			button.tooltip_text = "The fortress's current position."
		elif status == "secured":
			button.tooltip_text = "Secured earlier in this run."
		elif status == "bypassed":
			button.tooltip_text = "The march passed this branch; it cannot be revisited in this run."
		else:
			button.tooltip_text = "This node is visible on the regional chart but is not yet reachable."
		_apply_button_style(button, status)
	commit_button.visible = show_commit and not interaction_is_blocked
	commit_button.disabled = selected_node.is_empty() or selected_node not in available_nodes or not can_depart or not departure_block_reason.is_empty() or interaction_is_blocked
	if not selected_node.is_empty() and selected_node in available_nodes:
		var selected_preview: Dictionary = current_previews.get(selected_node, {})
		var predicted_heat := int(selected_preview.get("predicted_heat", 0))
		var visibility := String(selected_preview.get("visibility", "forecast"))
		var risk := float(selected_preview.get("risk", 0.0))
		var fuel_cost := int(selected_preview.get("fuel", 0))
		var fuel_after := maxi(0, current_fuel - fuel_cost)
		var day_after := current_day + int(selected_preview.get("days", 0))
		var pressure_after := current_pressure + int(selected_preview.get("pressure_gain", 0))
		var commit_prefix := "FINAL COMMIT" if selected_node in final_nodes else "COMMIT"
		var overheated := predicted_heat > heat_limit
		var departure_blocked := not departure_block_reason.is_empty() or not can_depart
		var commit_fill := Color("#285348")
		var commit_border := Color("#73c99b")
		if departure_blocked or overheated or (visibility != "unscouted" and _risk_band(risk) == "HIGH"):
			commit_fill = Color("#55312d")
			commit_border = Color("#ef8375")
		elif visibility == "unscouted":
			commit_fill = Color("#3d354b")
			commit_border = Color("#cbb8e8")
		elif _risk_band(risk) == "GUARDED":
			commit_fill = Color("#4d4029")
			commit_border = Color("#e8c58e")
		if high_contrast_enabled:
			commit_fill = commit_fill.darkened(0.38)
			commit_border = VisualContrast.display_color(commit_border)
		var commit_width := 3 if high_contrast_enabled else 2
		var commit_focus_width := 4 if high_contrast_enabled else 3
		commit_button.add_theme_stylebox_override("normal", _style(commit_fill, commit_border, commit_width))
		commit_button.add_theme_stylebox_override("hover", _style(commit_fill.lightened(0.08), commit_border.lightened(0.08), commit_width))
		commit_button.add_theme_stylebox_override("pressed", _style(commit_fill.darkened(0.08), Color.WHITE, commit_width))
		commit_button.add_theme_stylebox_override("focus", _style(commit_fill, Color.WHITE, commit_focus_width))
		commit_button.add_theme_stylebox_override("disabled", _style(commit_fill.darkened(0.10), commit_border.darkened(0.10), commit_width))
		if not departure_block_reason.is_empty() or not can_depart:
			var blocked_copy := departure_block_reason.to_upper().replace(": ", "\n") if not departure_block_reason.is_empty() else "FORTRESS NOT READY"
			commit_button.text = "DEPARTURE BLOCKED\n%s" % blocked_copy
			commit_button.tooltip_text = departure_block_reason if not departure_block_reason.is_empty() else "The fortress cannot depart in its current state."
		elif visibility == "unscouted":
			var days := int(selected_preview.get("days", 0))
			commit_button.text = "%s · %s\nDAY %d→%d · FUEL %d→%d\nRISK UNKNOWN · HEAT %d/%d" % [commit_prefix, String(short_names.get(selected_node, selected_node)).to_upper(), current_day, day_after, current_fuel, fuel_after, predicted_heat, heat_limit] if compact_commit_labels else "%s · %s\nDAY %d→%d · FUEL %d→%d\nRISK UNKNOWN · HEAT %d/%d · PRESSURE UNKNOWN" % [commit_prefix, String(short_names.get(selected_node, selected_node)).to_upper(), current_day, day_after, current_fuel, fuel_after, predicted_heat, heat_limit]
			commit_button.tooltip_text = "Pay %d fuel and advance %d day%s into an unscouted encounter.%s" % [fuel_cost, days, "" if days == 1 else "s", " Failure ends the run; there is no retreat." if selected_node in final_nodes else ""]
		else:
			var days := int(selected_preview.get("days", 0))
			commit_button.text = "%s · %s\nDAY %d→%d · FUEL %d→%d\n%s RISK %.0f%% · HEAT %d/%d · P %d→%d" % [commit_prefix, String(short_names.get(selected_node, selected_node)).to_upper(), current_day, day_after, current_fuel, fuel_after, _risk_band(risk), risk * 100.0, predicted_heat, heat_limit, current_pressure, pressure_after] if compact_commit_labels else "%s · %s\nDAY %d→%d · FUEL %d→%d\n%s RISK (%.0f%%) · HEAT %d/%d · PRESSURE %d→%d" % [commit_prefix, String(short_names.get(selected_node, selected_node)).to_upper(), current_day, day_after, current_fuel, fuel_after, _risk_band(risk), risk * 100.0, predicted_heat, heat_limit, current_pressure, pressure_after]
			commit_button.tooltip_text = "Pay the displayed route costs and begin this encounter.%s" % [" Failure ends the run; there is no retreat." if selected_node in final_nodes else ""]
	elif not available_nodes.is_empty():
		commit_button.text = "Select a route to continue"
		commit_button.tooltip_text = "Choose one of the cyan route nodes before committing."
	elif not current_node.is_empty():
		commit_button.text = "No route selected"
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
	var button := buttons_by_id.get(node_id) as Button
	return button.position + NODE_SIZE * 0.5 if button != null else Vector2(node_positions.get(node_id, Vector2.ZERO)) + NODE_SIZE * 0.5

func _path_contains_edge(from_id: String, to_id: String) -> bool:
	for index in range(secured_path.size() - 1):
		if secured_path[index] == from_id and secured_path[index + 1] == to_id:
			return true
	return false

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#05090c") if high_contrast_enabled else Color("#141e24"), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#a8b8bd") if high_contrast_enabled else Color("#34454c"), false, 2.0 if high_contrast_enabled else 1.0)
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
			elif source == current_node and locked_reasons.has(target):
				color = Color("#d8a650")
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
			if high_contrast_enabled:
				color = VisualContrast.display_color(color)
				width += 1.0
			draw_line(_node_center(source), _node_center(target), color, width, true)
