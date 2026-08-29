class_name RecoveryPanelView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

signal pause_requested
signal repair_requested
signal refuel_requested
signal hull_requested
signal routes_requested

var pause_button: Button
var location_label: Label
var context_label: Label
var value_labels: Dictionary = {}
var recovery_canvas: RecoveryCanvas
var receipt_label: Label
var repair_button: Button
var refuel_button: Button
var hull_button: Button
var routes_button: Button
var high_contrast_enabled: bool = false

func _ready() -> void:
	_build_ui()

func _style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 10) -> StyleBoxFlat:
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
	header.custom_minimum_size = Vector2(0, 48)
	header.add_theme_constant_override("separation", 12)
	page.add_child(header)
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	location_label = Label.new()
	location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 13)
	location_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(location_label)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC"
	pause_button.custom_minimum_size = Vector2(170, 42)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)
	context_label = Label.new()
	context_label.add_theme_color_override("font_color", Color("#d8c389"))
	page.add_child(context_label)
	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	page.add_child(body)
	var values_panel := PanelContainer.new()
	values_panel.custom_minimum_size = Vector2(205, 0)
	values_panel.add_theme_stylebox_override("panel", _style(Color("#121d22"), Color("#35484f"), 1, 6, 10))
	body.add_child(values_panel)
	var values_stack := VBoxContainer.new()
	values_stack.add_theme_constant_override("separation", 7)
	values_panel.add_child(values_stack)
	var values_heading := Label.new()
	values_heading.text = "RECOVERY LEDGER"
	values_heading.add_theme_font_size_override("font_size", 14)
	values_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	values_stack.add_child(values_heading)
	for value_id in ["hull", "fuel", "money", "actions", "trust", "pressure"]:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(Color("#18242a"), Color("#31434a"), 1, 4, 6))
		values_stack.add_child(card)
		var stack := VBoxContainer.new()
		card.add_child(stack)
		var label := Label.new()
		label.text = value_id.to_upper()
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color("#89999e"))
		stack.add_child(label)
		var value := Label.new()
		value.add_theme_font_size_override("font_size", 17)
		value.add_theme_color_override("font_color", Color("#f1e6cf"))
		stack.add_child(value)
		value_labels[value_id] = value
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	recovery_canvas = RecoveryCanvas.new()
	recovery_canvas.custom_minimum_size = Vector2(590, 410)
	recovery_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recovery_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(recovery_canvas)
	var receipt_panel := PanelContainer.new()
	receipt_panel.add_theme_stylebox_override("panel", _style(Color("#172329"), Color("#716346"), 1, 5, 8))
	center.add_child(receipt_panel)
	receipt_label = Label.new()
	receipt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	receipt_label.custom_minimum_size = Vector2(0, 48)
	receipt_label.add_theme_color_override("font_color", Color("#e7d6b4"))
	receipt_panel.add_child(receipt_label)
	var services_panel := PanelContainer.new()
	services_panel.custom_minimum_size = Vector2(345, 0)
	services_panel.add_theme_stylebox_override("panel", _style(Color("#111b20"), Color("#536a70"), 1, 6, 11))
	body.add_child(services_panel)
	var services := VBoxContainer.new()
	services.add_theme_constant_override("separation", 9)
	services_panel.add_child(services)
	var heading := Label.new()
	heading.text = "LOCAL SERVICES"
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", Color("#e8c58e"))
	services.add_child(heading)
	var help := Label.new()
	help.text = "Each service spends one recovery opportunity. Review its before → after preview; the receipt records what you committed."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_color_override("font_color", Color("#aab6ba"))
	services.add_child(help)
	repair_button = _service_button(services, repair_requested)
	refuel_button = _service_button(services, refuel_requested)
	hull_button = _service_button(services, hull_requested)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	services.add_child(spacer)
	routes_button = Button.new()
	routes_button.custom_minimum_size = Vector2(0, 62)
	routes_button.pressed.connect(func() -> void: routes_requested.emit())
	services.add_child(routes_button)
	_configure_focus()

func _service_button(parent: VBoxContainer, callback: Signal) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 82)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(func() -> void: callback.emit())
	parent.add_child(button)
	return button

func configure(view: Dictionary) -> void:
	location_label.text = "%s · FIELD RECOVERY" % String(view.get("location_name", "ROAD STOP")).to_upper()
	context_label.text = String(view.get("context", "Choose what the fortress can restore before the next road."))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	repair_button.text = String(view.get("repair_text", "REPAIR MODULE"))
	repair_button.tooltip_text = String(view.get("repair_tooltip", "Review module repair."))
	repair_button.disabled = bool(view.get("repair_disabled", false))
	refuel_button.text = String(view.get("refuel_text", "REFUEL"))
	refuel_button.tooltip_text = String(view.get("refuel_tooltip", "Review fuel service."))
	refuel_button.disabled = bool(view.get("refuel_disabled", false))
	hull_button.text = String(view.get("hull_text", "REPAIR HULL"))
	hull_button.tooltip_text = String(view.get("hull_tooltip", "Review hull repair."))
	hull_button.disabled = bool(view.get("hull_disabled", false))
	routes_button.text = String(view.get("routes_text", "REVIEW NEXT ROADS"))
	receipt_label.text = "LAST RECEIPT · %s" % String(view.get("receipt", "The road stop is ready. No recovery service has been spent here yet."))
	recovery_canvas.current_view = view.duplicate(true)
	recovery_canvas.high_contrast_enabled = high_contrast_enabled
	recovery_canvas.queue_redraw()
	_configure_focus()

func focus_default() -> void:
	for button in [repair_button, refuel_button, hull_button, routes_button]:
		if not button.disabled:
			button.grab_focus()
			return

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if recovery_canvas != null:
		recovery_canvas.high_contrast_enabled = enabled
		recovery_canvas.queue_redraw()

func set_controller_cancel_label(cancel_label: String) -> void:
	pause_button.text = "PAUSE · ESC / %s" % cancel_label

func _configure_focus() -> void:
	var controls: Array[Control] = []
	for button in [repair_button, refuel_button, hull_button, routes_button]:
		if not button.disabled:
			controls.append(button)
	if controls.is_empty():
		return
	for index in range(controls.size()):
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var next := controls[(index + 1) % controls.size()]
		controls[index].focus_neighbor_top = controls[index].get_path_to(previous)
		controls[index].focus_neighbor_bottom = controls[index].get_path_to(next)
		controls[index].focus_previous = controls[index].get_path_to(previous)
		controls[index].focus_next = controls[index].get_path_to(next)

class RecoveryCanvas extends Control:
	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		var sky := Color("#071013") if high_contrast_enabled else (Color("#17373e") if flooded else Color("#333a3b"))
		var ground := Color("#10282c") if flooded else Color("#30271f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.17), 52.0, Color(0.95, 0.75, 0.43, 0.16))
		for ridge in range(4):
			var y := size.y * (0.30 + float(ridge) * 0.05)
			draw_line(Vector2(0, y), Vector2(size.x, y - 22.0 + float(ridge) * 7.0), Color("#39565b") if flooded else Color("#665c4e"), 24.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.66), Vector2(size.x, size.y * 0.34)), ground, true)
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		view["mode"] = "rest"
		view["high_contrast"] = high_contrast_enabled
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.15, size.y * 0.25), Vector2(size.x * 0.70, size.y * 0.52)), view)
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 14), String(current_view.get("caption", "ONE STOP · FINITE TIME · THE ROAD CONTINUES")), HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#e2cc98"))
