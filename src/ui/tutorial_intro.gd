class_name TutorialIntroView
extends Control

signal begin_requested
signal back_requested
signal skip_requested

const PAGES := [
	{
		"eyebrow": "ASHGATE MUSTER YARD",
		"title": "A MOVING SETTLEMENT",
		"body": "The fortress is engine, workshop, shelter, and weapon in one walking machine. Every room you place changes what it can carry through the road.",
		"caption": "KEEP THE MACHINE MOVING · KEEP ITS PEOPLE ALIVE"
	},
	{
		"eyebrow": "SYSTEMS DEPEND ON SYSTEMS",
		"title": "BUILD THE CHAIN",
		"body": "Engines need nearby fuel. Weapons need power and ammunition support. Workshops need crew. When one system fails, another may fail with it.",
		"caption": "PLACEMENT IS PREPARATION"
	},
	{
		"eyebrow": "YOUR FIRST COMMAND",
		"title": "READ THE ROAD",
		"body": "Choose a route, study what approaches, and advance contact one step at a time. Repair what matters, secure the road, and bring the fortress home.",
		"caption": "SURVIVAL IS CONTINUITY, NOT PERFECTION"
	}
]

var page_index: int = 0
var eyebrow_label: Label
var title_label: Label
var body_label: Label
var caption_label: Label
var progress_label: Label
var back_page_button: Button
var next_button: Button
var title_button: Button
var skip_button: Button
var canvas: IntroCanvas
var high_contrast_enabled: bool = false

func _ready() -> void:
	_build_ui()
	_refresh_page()

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 10) -> StyleBoxFlat:
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
	background.color = Color("#0b1216")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 34)
	margin.add_child(columns)
	canvas = IntroCanvas.new()
	canvas.custom_minimum_size = Vector2(690, 0)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(canvas)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(410, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191eea"), Color("#8d7655"), 2, 8, 20))
	columns.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	panel.add_child(stack)
	var game_label := Label.new()
	game_label.text = "THE LONG MARCH"
	game_label.add_theme_font_size_override("font_size", 18)
	game_label.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(game_label)
	eyebrow_label = Label.new()
	eyebrow_label.add_theme_font_size_override("font_size", 11)
	eyebrow_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	stack.add_child(eyebrow_label)
	title_label = Label.new()
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	stack.add_child(title_label)
	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(0, 150)
	body_label.add_theme_font_size_override("font_size", 17)
	body_label.add_theme_color_override("font_color", Color("#d7dfd9"))
	stack.add_child(body_label)
	var caption_panel := PanelContainer.new()
	caption_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 10))
	stack.add_child(caption_panel)
	caption_label = Label.new()
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption_label.add_theme_font_size_override("font_size", 12)
	caption_label.add_theme_color_override("font_color", Color("#aee4cf"))
	caption_panel.add_child(caption_label)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)
	progress_label = Label.new()
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(progress_label)
	skip_button = Button.new()
	skip_button.text = "SKIP TUTORIAL · START ASHGATE JOURNEY"
	skip_button.tooltip_text = "Begin the full Ashgate journey now. You can return to Learn to Command from the title."
	skip_button.pressed.connect(func() -> void: skip_requested.emit())
	stack.add_child(skip_button)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	stack.add_child(actions)
	title_button = Button.new()
	title_button.text = "BACK TO TITLE"
	title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_button.pressed.connect(func() -> void: back_requested.emit())
	actions.add_child(title_button)
	back_page_button = Button.new()
	back_page_button.text = "PREVIOUS"
	back_page_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_page_button.pressed.connect(_previous_page)
	actions.add_child(back_page_button)
	next_button = Button.new()
	next_button.text = "NEXT"
	next_button.custom_minimum_size = Vector2(0, 54)
	next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_button.pressed.connect(_next_page)
	actions.add_child(next_button)
	_configure_focus()

func _configure_focus() -> void:
	var controls: Array[Control] = [skip_button, title_button, back_page_button, next_button]
	for index in range(controls.size()):
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var next := controls[(index + 1) % controls.size()]
		controls[index].focus_neighbor_left = controls[index].get_path_to(previous)
		controls[index].focus_neighbor_right = controls[index].get_path_to(next)
		controls[index].focus_previous = controls[index].get_path_to(previous)
		controls[index].focus_next = controls[index].get_path_to(next)

func open() -> void:
	page_index = 0
	visible = true
	_refresh_page()
	next_button.grab_focus()

func _previous_page() -> void:
	page_index = maxi(0, page_index - 1)
	_refresh_page()
	(back_page_button if page_index > 0 else next_button).grab_focus()

func _next_page() -> void:
	if page_index >= PAGES.size() - 1:
		begin_requested.emit()
		return
	page_index += 1
	_refresh_page()
	next_button.grab_focus()

func _refresh_page() -> void:
	var page: Dictionary = PAGES[page_index]
	eyebrow_label.text = String(page.eyebrow)
	title_label.text = String(page.title)
	body_label.text = String(page.body)
	caption_label.text = String(page.caption)
	progress_label.text = "INTRODUCTION · %d OF %d" % [page_index + 1, PAGES.size()]
	back_page_button.disabled = page_index == 0
	next_button.text = "ENTER THE MUSTER YARD" if page_index == PAGES.size() - 1 else "NEXT"
	canvas.page_index = page_index
	canvas.high_contrast_enabled = high_contrast_enabled
	canvas.queue_redraw()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if canvas != null:
		canvas.high_contrast_enabled = enabled
		canvas.queue_redraw()

class IntroCanvas extends Control:
	var page_index: int = 0
	var high_contrast_enabled: bool = false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#071013") if high_contrast_enabled else Color("#263337"), true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.19), 66.0, Color(0.96, 0.76, 0.44, 0.20))
		for ridge in range(5):
			var y := size.y * (0.31 + ridge * 0.045)
			draw_line(Vector2(0, y), Vector2(size.x, y - 30.0 + ridge * 8.0), Color("#645b4f").darkened(float(ridge) * 0.06), 28.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.66), Vector2(size.x, size.y * 0.34)), Color("#30261e"), true)
		_draw_fortress(Vector2(size.x * 0.43, size.y * 0.62))
		if page_index == 1:
			_draw_dependency_lines(Vector2(size.x * 0.43, size.y * 0.62))
		elif page_index == 2:
			_draw_road_markers()

	func _draw_fortress(center: Vector2) -> void:
		var body := Rect2(center - Vector2(185, 82), Vector2(370, 140))
		var metal := Color("#303837") if high_contrast_enabled else Color("#4b4a41")
		var edge := Color("#ead69e") if high_contrast_enabled else Color("#9a825a")
		draw_rect(body, metal, true)
		draw_rect(body, edge, false, 5.0)
		draw_rect(Rect2(body.position + Vector2(34, -48), Vector2(112, 48)), metal.lightened(0.06), true)
		draw_rect(Rect2(body.position + Vector2(34, -48), Vector2(112, 48)), edge, false, 4.0)
		draw_line(body.position + Vector2(276, 0), body.position + Vector2(276, -82), edge, 6.0)
		for leg_x in [body.position.x + 58.0, body.position.x + 136.0, body.end.x - 136.0, body.end.x - 58.0]:
			draw_line(Vector2(leg_x, body.end.y), Vector2(leg_x - 10, body.end.y + 58), edge, 12.0)
			draw_line(Vector2(leg_x - 26, body.end.y + 58), Vector2(leg_x + 18, body.end.y + 58), edge, 9.0)
		for window_x in [body.position.x + 64.0, body.position.x + 128.0, body.position.x + 202.0, body.position.x + 278.0]:
			draw_rect(Rect2(Vector2(window_x, body.position.y + 42), Vector2(27, 30)), Color("#dfa759"), true)

	func _draw_dependency_lines(center: Vector2) -> void:
		var anchors := [center + Vector2(-120, 5), center + Vector2(-45, 38), center + Vector2(45, 8), center + Vector2(125, 38)]
		for index in range(anchors.size() - 1):
			draw_dashed_line(anchors[index], anchors[index + 1], Color("#78d3c5"), 3.0, 8.0)
		for anchor in anchors:
			draw_circle(anchor, 11.0, Color("#e8c58e"))

	func _draw_road_markers() -> void:
		for index in range(5):
			var x := size.x * 0.64 + index * 54.0
			draw_line(Vector2(x, size.y * 0.82), Vector2(x + 28, size.y * 0.82), Color("#b28d58"), 5.0)
		draw_circle(Vector2(size.x * 0.86, size.y * 0.62), 24.0, Color("#9e453a"))
