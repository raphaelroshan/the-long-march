class_name JourneyPlannerView
extends Control

signal pause_requested
signal return_requested

var pause_button: Button
var return_button: Button
var region_label: Label
var order_label: Label
var receipt_label: Label
var route_stage_label: Label
var value_labels: Dictionary = {}
var map_host: CenterContainer
var comparison_host: ScrollContainer
var comparison_stack: VBoxContainer
var detail_heading: Label
var detail_scroll: ScrollContainer
var detail_stack: VBoxContainer
var action_host: VBoxContainer
var specialist_panel: PanelContainer
var specialist_portrait: SpecialistPortrait
var specialist_name_label: Label
var specialist_role_label: Label
var specialist_belief_label: Label
var specialist_effect_label: Label
var specialist_action: Button
var campaign_map: Control
var high_contrast_enabled: bool = false
var controller_cancel_label: String = "B"

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
	title.text = "PLAN JOURNEY"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	region_label = Label.new()
	region_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	region_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	region_label.add_theme_font_size_override("font_size", 14)
	region_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(region_label)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC"
	pause_button.custom_minimum_size = Vector2(170, 42)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)
	order_label = Label.new()
	order_label.text = "Inspect a reachable road. Selection is reversible; Commit begins travel."
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_label.custom_minimum_size = Vector2(0, 36)
	order_label.add_theme_color_override("font_color", Color("#b8c4c5"))
	page.add_child(order_label)
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
	value_stack.add_theme_constant_override("separation", 4)
	value_panel.add_child(value_stack)
	var value_heading := Label.new()
	value_heading.text = "MARCH READINESS"
	value_heading.add_theme_font_size_override("font_size", 15)
	value_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	value_stack.add_child(value_heading)
	for value_id in ["day", "fuel", "hull", "power", "heat", "mass", "pressure"]:
		_add_value_card(value_stack, value_id)
	return_button = Button.new()
	return_button.text = "RETURN TO BAZAAR"
	return_button.custom_minimum_size = Vector2(0, 36)
	return_button.pressed.connect(func() -> void: return_requested.emit())
	value_stack.add_child(return_button)
	var map_panel := PanelContainer.new()
	map_panel.custom_minimum_size = Vector2(500, 0)
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.add_theme_stylebox_override("panel", _flat_style(Color("#121c21"), Color("#42565e"), 1, 6, 8))
	body.add_child(map_panel)
	var map_stack := VBoxContainer.new()
	map_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_stack.add_theme_constant_override("separation", 6)
	map_panel.add_child(map_stack)
	var map_heading := Label.new()
	map_heading.text = "REGIONAL ROUTE MAP"
	map_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_heading.add_theme_font_size_override("font_size", 15)
	map_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	map_stack.add_child(map_heading)
	route_stage_label = Label.new()
	route_stage_label.text = "INSPECT ROAD · NO COST YET"
	route_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	route_stage_label.add_theme_font_size_override("font_size", 10)
	route_stage_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	map_stack.add_child(route_stage_label)
	map_host = CenterContainer.new()
	map_host.custom_minimum_size = Vector2(0, 340)
	map_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_stack.add_child(map_host)
	comparison_host = ScrollContainer.new()
	comparison_host.custom_minimum_size = Vector2(0, 0)
	comparison_host.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	map_stack.add_child(comparison_host)
	comparison_stack = VBoxContainer.new()
	comparison_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	comparison_host.add_child(comparison_stack)
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(370, 0)
	detail_panel.add_theme_stylebox_override("panel", _flat_style(Color("#151d21"), Color("#536a70"), 2, 6, 10))
	body.add_child(detail_panel)
	var detail_column := VBoxContainer.new()
	detail_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 8)
	detail_panel.add_child(detail_column)
	detail_heading = Label.new()
	detail_heading.text = "SELECTED ROAD"
	detail_heading.add_theme_font_size_override("font_size", 15)
	detail_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	detail_column.add_child(detail_heading)
	detail_scroll = ScrollContainer.new()
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_column.add_child(detail_scroll)
	detail_stack = VBoxContainer.new()
	detail_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_stack.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	detail_stack.add_theme_constant_override("separation", 8)
	detail_scroll.add_child(detail_stack)
	var receipt_panel := PanelContainer.new()
	receipt_panel.add_theme_stylebox_override("panel", _flat_style(Color("#17231f"), Color("#587a68"), 1, 4, 5))
	detail_stack.add_child(receipt_panel)
	receipt_label = Label.new()
	receipt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	receipt_label.add_theme_font_size_override("font_size", 10)
	receipt_label.add_theme_color_override("font_color", Color("#a8d8bf"))
	receipt_panel.add_child(receipt_label)
	specialist_panel = PanelContainer.new()
	specialist_panel.visible = false
	specialist_panel.add_theme_stylebox_override("panel", _flat_style(Color("#17262a"), Color("#5c9d97"), 2, 5, 7))
	detail_stack.add_child(specialist_panel)
	var specialist_stack := VBoxContainer.new()
	specialist_stack.add_theme_constant_override("separation", 5)
	specialist_panel.add_child(specialist_stack)
	var specialist_row := HBoxContainer.new()
	specialist_row.add_theme_constant_override("separation", 9)
	specialist_stack.add_child(specialist_row)
	specialist_portrait = SpecialistPortrait.new()
	specialist_portrait.custom_minimum_size = Vector2(72, 72)
	specialist_row.add_child(specialist_portrait)
	var specialist_copy := VBoxContainer.new()
	specialist_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	specialist_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	specialist_copy.add_theme_constant_override("separation", 1)
	specialist_row.add_child(specialist_copy)
	specialist_name_label = Label.new()
	specialist_name_label.add_theme_font_size_override("font_size", 17)
	specialist_name_label.add_theme_color_override("font_color", Color("#e8c58e"))
	specialist_copy.add_child(specialist_name_label)
	specialist_role_label = Label.new()
	specialist_role_label.add_theme_font_size_override("font_size", 9)
	specialist_role_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	specialist_copy.add_child(specialist_role_label)
	specialist_belief_label = Label.new()
	specialist_belief_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	specialist_belief_label.add_theme_font_size_override("font_size", 10)
	specialist_belief_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	specialist_copy.add_child(specialist_belief_label)
	specialist_effect_label = Label.new()
	specialist_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	specialist_effect_label.add_theme_font_size_override("font_size", 10)
	specialist_effect_label.add_theme_color_override("font_color", Color("#a8d8bf"))
	specialist_stack.add_child(specialist_effect_label)
	action_host = VBoxContainer.new()
	action_host.add_theme_constant_override("separation", 6)
	detail_column.add_child(action_host)

func _add_value_card(parent: VBoxContainer, value_id: String) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 38)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#1a262c"), Color("#34474e"), 1, 4, 5))
	parent.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	var title := Label.new()
	title.text = value_id.to_upper()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color("#89999e"))
	row.add_child(title)
	var value := Label.new()
	value.text = "—"
	value.add_theme_font_size_override("font_size", 15)
	value.add_theme_color_override("font_color", Color("#f1e6cf"))
	row.add_child(value)
	value_labels[value_id] = value

func attach_route_controls(map_control: Control, comparison: Control, route_preview: Control, doctrine: Control, doctrine_detail: Control, commit_intel: Control, action_row: Control, specialist_button: Button) -> void:
	campaign_map = map_control
	map_control.set("compact_commit_labels", true)
	map_control.reparent(map_host, false)
	map_control.custom_minimum_size = Vector2(500, 340)
	comparison.reparent(comparison_stack, false)
	comparison.custom_minimum_size.x = 0
	route_preview.reparent(detail_stack, false)
	doctrine.reparent(detail_stack, false)
	doctrine_detail.reparent(detail_stack, false)
	commit_intel.reparent(detail_stack, false)
	action_row.reparent(action_host, false)
	specialist_action = specialist_button
	specialist_button.reparent(specialist_panel.get_child(0), false)
	specialist_button.custom_minimum_size = Vector2(0, 54)
	specialist_button.add_theme_font_size_override("font_size", 10)
	for control in [route_preview, doctrine, doctrine_detail, commit_intel, action_row]:
		control.custom_minimum_size.x = 0
		control.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	for child in action_row.get_children():
		if child is Button:
			child.add_theme_font_size_override("font_size", 10)

func configure(view: Dictionary) -> void:
	region_label.text = "%s · FORTRESS AT %s" % [String(view.get("region_name", "REGION")).to_upper(), String(view.get("location_name", "CURRENT STOP")).to_upper()]
	order_label.text = String(view.get("order", "Inspect a reachable road. Selection is reversible; Commit begins travel."))
	receipt_label.text = String(view.get("receipt", ""))
	receipt_label.get_parent().visible = not receipt_label.text.is_empty()
	var specialist_card: Dictionary = view.get("specialist_card", {})
	specialist_panel.visible = bool(specialist_card.get("visible", false))
	if specialist_panel.visible:
		specialist_name_label.text = String(specialist_card.get("name", "SPECIALIST")).to_upper()
		specialist_role_label.text = "%s · %s" % [String(specialist_card.get("role", "ROAD SPECIALIST")).to_upper(), String(specialist_card.get("status", "OFFER")).to_upper()]
		specialist_belief_label.text = String(specialist_card.get("belief", "A specialist offers to join the march."))
		specialist_effect_label.text = String(specialist_card.get("effect", "Review the practical effect before recruiting."))
		specialist_portrait.specialist_id = String(specialist_card.get("id", ""))
		specialist_portrait.status_id = "assigned" if String(specialist_card.get("status", "")) == "ASSIGNED TO FORTRESS" else ("ready" if bool(specialist_card.get("available", false)) else "locked")
		specialist_portrait.high_contrast_enabled = high_contrast_enabled
		specialist_portrait.tooltip_text = "%s · %s" % [specialist_name_label.text.capitalize(), specialist_role_label.text.capitalize()]
		specialist_portrait.queue_redraw()
	if specialist_action != null:
		specialist_action.visible = bool(specialist_card.get("show_action", false))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	return_button.visible = bool(view.get("can_return", false))
	return_button.disabled = not return_button.visible
	return_button.text = String(view.get("return_label", "RETURN TO BAZAAR"))
	var route_selected := bool(view.get("route_selected", false))
	detail_heading.text = "SELECTED ROAD" if route_selected else "ROAD DOSSIER"
	route_stage_label.text = "ROUTE SELECTED · REVIEW COSTS → COMMIT" if route_selected else "BROWSE ROAD · NO COST · SELECT TO REVIEW"
	route_stage_label.add_theme_color_override("font_color", Color("#f0cf96") if route_selected else Color("#9fd2c2"))
	pause_button.text = "PAUSE · ROUTE REVIEW" if route_selected else "PAUSE · ESC / %s" % controller_cancel_label
	pause_button.tooltip_text = "Pause with this button. %s or Escape clears the selected route first." % controller_cancel_label if route_selected else "Pause the march without committing a route."

func focus_default() -> void:
	if specialist_panel.visible and specialist_action != null and specialist_action.is_visible_in_tree() and not specialist_action.disabled:
		specialist_action.grab_focus()
		return
	if campaign_map == null:
		return
	for button in campaign_map.node_buttons:
		if button.visible and not button.disabled:
			button.grab_focus()
			return

func show_route_overview() -> void:
	if detail_scroll != null:
		detail_scroll.scroll_vertical = 0

func reveal_commit_context() -> void:
	if detail_scroll == null:
		return
	await get_tree().process_frame
	detail_scroll.scroll_vertical = 100000

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if specialist_portrait != null:
		specialist_portrait.high_contrast_enabled = enabled
		specialist_portrait.queue_redraw()

func set_controller_cancel_label(cancel_label: String) -> void:
	controller_cancel_label = cancel_label
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % controller_cancel_label

class SpecialistPortrait extends Control:
	var specialist_id: String = ""
	var status_id: String = "locked"
	var high_contrast_enabled: bool = false

	func _draw() -> void:
		var border := Color.WHITE if high_contrast_enabled else Color("#8ddbd0")
		var background := Color("#071013") if high_contrast_enabled else Color("#162b30")
		draw_rect(Rect2(Vector2.ZERO, size), background, true)
		draw_rect(Rect2(Vector2.ONE, size - Vector2(2, 2)), border, false, 2.0)
		var center := Vector2(size.x * 0.43, size.y * 0.42)
		var skin := Color.WHITE if high_contrast_enabled else Color("#d9bd82")
		var active := status_id in ["ready", "assigned"]
		var coat := Color("#315c61") if active else Color("#39494c")
		draw_circle(center - Vector2(0, 15), 8.0, skin)
		if specialist_id == "mara_flint":
			draw_line(center - Vector2(7, 22), center + Vector2(8, -22), Color("#542e25"), 6.0)
		else:
			draw_line(center - Vector2(7, 22), center + Vector2(8, -22), Color("#273337"), 5.0)
		var shoulders := PackedVector2Array([
			center + Vector2(-16, 0),
			center + Vector2(15, 0),
			center + Vector2(21, 27),
			center + Vector2(-22, 27)
		])
		draw_colored_polygon(shoulders, coat)
		draw_polyline(PackedVector2Array([shoulders[0], shoulders[1], shoulders[2], shoulders[3], shoulders[0]]), border, 2.0)
		var prop_anchor := center + Vector2(22, -2)
		if specialist_id == "mara_flint":
			draw_line(prop_anchor + Vector2(-4, 24), prop_anchor + Vector2(14, -2), border, 4.0)
			draw_line(prop_anchor + Vector2(8, -8), prop_anchor + Vector2(22, 4), border, 6.0)
		else:
			draw_line(prop_anchor + Vector2(0, 27), prop_anchor + Vector2(0, -16), border, 3.0)
			for radius in [8.0, 14.0]:
				draw_arc(prop_anchor + Vector2(0, -14), radius, -1.15, 1.15, 12, Color(border.r, border.g, border.b, 0.75), 2.0)
		var lamp := Color("#fff1c9") if active or high_contrast_enabled else Color("#75878a")
		draw_circle(Vector2(size.x - 12, 12), 4.0, lamp)

	func presentation_signature() -> String:
		var role := "FORGE MASTER" if specialist_id == "mara_flint" else "SIGNAL OFFICER"
		return "%s · %s · %s" % [specialist_id.to_upper(), role, status_id.to_upper()]
