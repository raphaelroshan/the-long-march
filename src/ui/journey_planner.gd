class_name JourneyPlannerView
extends Control

signal pause_requested
signal return_requested

var pause_button: Button
var return_button: Button
var region_label: Label
var order_label: Label
var receipt_label: Label
var value_labels: Dictionary = {}
var map_host: CenterContainer
var comparison_host: ScrollContainer
var comparison_stack: VBoxContainer
var detail_scroll: ScrollContainer
var detail_stack: VBoxContainer
var action_host: VBoxContainer
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
	var detail_heading := Label.new()
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

func attach_route_controls(map_control: Control, comparison: Control, route_preview: Control, doctrine: Control, doctrine_detail: Control, commit_intel: Control, action_row: Control) -> void:
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
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	return_button.visible = bool(view.get("can_return", false))
	return_button.disabled = not return_button.visible
	return_button.text = String(view.get("return_label", "RETURN TO BAZAAR"))
	var route_selected := bool(view.get("route_selected", false))
	pause_button.text = "PAUSE · ROUTE REVIEW" if route_selected else "PAUSE · ESC / %s" % controller_cancel_label
	pause_button.tooltip_text = "Pause with this button. %s or Escape clears the selected route first." % controller_cancel_label if route_selected else "Pause the march without committing a route."

func focus_default() -> void:
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

func set_controller_cancel_label(cancel_label: String) -> void:
	controller_cancel_label = cancel_label
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % controller_cancel_label
