class_name DebriefPanelView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

signal pause_requested
signal inspect_requested
signal notes_requested
signal replay_requested
signal march_on_requested
signal title_requested

var pause_button: Button
var headline_label: Label
var region_label: Label
var outcome_label: Label
var timeline_labels: Array[RichTextLabel] = []
var journey_label: RichTextLabel
var commitments_label: RichTextLabel
var consequence_label: RichTextLabel
var condition_label: RichTextLabel
var experiment_label: RichTextLabel
var inspect_button: Button
var notes_button: Button
var march_on_button: Button
var replay_button: Button
var title_button: Button
var fortress_canvas: DebriefFortressCanvas
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
	background.color = Color("#0c1418")
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
	var game_title := Label.new()
	game_title.text = "THE LONG MARCH"
	game_title.add_theme_font_size_override("font_size", 27)
	game_title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(game_title)
	region_label = Label.new()
	region_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	region_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	region_label.add_theme_font_size_override("font_size", 12)
	region_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	header.add_child(region_label)
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

	var route_panel := PanelContainer.new()
	route_panel.custom_minimum_size = Vector2(255, 0)
	route_panel.add_theme_stylebox_override("panel", _style(Color("#121d22"), Color("#35484f"), 1, 6, 12))
	body.add_child(route_panel)
	var route_stack := VBoxContainer.new()
	route_stack.add_theme_constant_override("separation", 8)
	route_panel.add_child(route_stack)
	var route_heading := Label.new()
	route_heading.text = "THE ROAD TAKEN"
	route_heading.add_theme_font_size_override("font_size", 15)
	route_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	route_stack.add_child(route_heading)
	for index in range(5):
		var step := RichTextLabel.new()
		step.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		step.custom_minimum_size = Vector2(0, 52)
		step.fit_content = false
		step.scroll_active = false
		step.add_theme_stylebox_override("normal", _style(Color("#18242a"), Color("#31434a"), 1, 4, 7))
		step.add_theme_font_size_override("normal_font_size", 11)
		step.add_theme_color_override("default_color", Color("#c8d1d1"))
		route_stack.add_child(step)
		timeline_labels.append(step)
	journey_label = RichTextLabel.new()
	journey_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journey_label.custom_minimum_size = Vector2(0, 90)
	journey_label.fit_content = false
	journey_label.scroll_active = true
	journey_label.add_theme_font_size_override("normal_font_size", 10)
	journey_label.add_theme_color_override("default_color", Color("#89999e"))
	route_stack.add_child(journey_label)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	var result_panel := PanelContainer.new()
	result_panel.add_theme_stylebox_override("panel", _style(Color("#172329"), Color("#8d7655"), 2, 7, 13))
	center.add_child(result_panel)
	var result_stack := VBoxContainer.new()
	result_panel.add_child(result_stack)
	outcome_label = Label.new()
	outcome_label.text = "JOURNEY COMPLETE"
	outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome_label.add_theme_font_size_override("font_size", 11)
	outcome_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	result_stack.add_child(outcome_label)
	headline_label = Label.new()
	headline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	headline_label.add_theme_font_size_override("font_size", 34)
	headline_label.add_theme_color_override("font_color", Color("#f0d29d"))
	result_stack.add_child(headline_label)
	fortress_canvas = DebriefFortressCanvas.new()
	fortress_canvas.custom_minimum_size = Vector2(500, 250)
	fortress_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(fortress_canvas)
	condition_label = RichTextLabel.new()
	condition_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	condition_label.custom_minimum_size = Vector2(0, 72)
	condition_label.fit_content = false
	condition_label.scroll_active = true
	condition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	condition_label.add_theme_font_size_override("normal_font_size", 11)
	condition_label.add_theme_color_override("default_color", Color("#c8d1d1"))
	center.add_child(condition_label)

	var lesson_panel := PanelContainer.new()
	lesson_panel.custom_minimum_size = Vector2(350, 0)
	lesson_panel.clip_contents = true
	lesson_panel.add_theme_stylebox_override("panel", _style(Color("#111b20"), Color("#536a70"), 1, 6, 13))
	body.add_child(lesson_panel)
	var lesson_stack := VBoxContainer.new()
	lesson_stack.add_theme_constant_override("separation", 8)
	lesson_panel.add_child(lesson_stack)
	var lesson_content := VBoxContainer.new()
	lesson_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lesson_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lesson_content.add_theme_constant_override("separation", 6)
	lesson_stack.add_child(lesson_content)
	var commitments_heading := Label.new()
	commitments_heading.text = "WHAT THE FORTRESS CARRIED"
	commitments_heading.add_theme_font_size_override("font_size", 12)
	commitments_heading.add_theme_color_override("font_color", Color("#9fd2c2"))
	lesson_content.add_child(commitments_heading)
	commitments_label = RichTextLabel.new()
	commitments_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	commitments_label.custom_minimum_size = Vector2(0, 74)
	commitments_label.fit_content = false
	commitments_label.scroll_active = true
	commitments_label.add_theme_font_size_override("normal_font_size", 12)
	commitments_label.add_theme_color_override("default_color", Color("#d7dfd9"))
	lesson_content.add_child(commitments_label)
	var cause_heading := Label.new()
	cause_heading.text = "WHY THIS MARCH ENDED HERE"
	cause_heading.add_theme_font_size_override("font_size", 12)
	cause_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	lesson_content.add_child(cause_heading)
	consequence_label = RichTextLabel.new()
	consequence_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	consequence_label.custom_minimum_size = Vector2(0, 90)
	consequence_label.fit_content = false
	consequence_label.scroll_active = true
	consequence_label.add_theme_font_size_override("normal_font_size", 12)
	consequence_label.add_theme_color_override("default_color", Color("#f1e6cf"))
	lesson_content.add_child(consequence_label)
	var experiment_heading := Label.new()
	experiment_heading.text = "NEXT EXPERIMENT"
	experiment_heading.add_theme_font_size_override("font_size", 12)
	experiment_heading.add_theme_color_override("font_color", Color("#9fd2c2"))
	lesson_content.add_child(experiment_heading)
	experiment_label = RichTextLabel.new()
	experiment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	experiment_label.custom_minimum_size = Vector2(0, 58)
	experiment_label.fit_content = false
	experiment_label.scroll_active = true
	experiment_label.add_theme_font_size_override("normal_font_size", 12)
	experiment_label.add_theme_color_override("default_color", Color("#c8d1d1"))
	lesson_content.add_child(experiment_label)
	inspect_button = Button.new()
	inspect_button.text = "INSPECT FINAL FORTRESS"
	inspect_button.pressed.connect(func() -> void: inspect_requested.emit())
	lesson_stack.add_child(inspect_button)
	notes_button = Button.new()
	notes_button.text = "RECORD JOURNEY NOTES"
	notes_button.pressed.connect(func() -> void: notes_requested.emit())
	lesson_stack.add_child(notes_button)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	page.add_child(actions)
	march_on_button = Button.new()
	march_on_button.custom_minimum_size = Vector2(0, 54)
	march_on_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	march_on_button.pressed.connect(func() -> void: march_on_requested.emit())
	actions.add_child(march_on_button)
	replay_button = Button.new()
	replay_button.text = "REPLAY THIS JOURNEY"
	replay_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	replay_button.pressed.connect(func() -> void: replay_requested.emit())
	actions.add_child(replay_button)
	title_button = Button.new()
	title_button.text = "SAVE RESULT & RETURN"
	title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_button.pressed.connect(func() -> void: title_requested.emit())
	actions.add_child(title_button)
	_configure_focus()

func configure(view: Dictionary) -> void:
	region_label.text = "%s · DAY %d · %s" % [String(view.get("region_name", "JOURNEY")).to_upper(), int(view.get("day", 1)), String(view.get("run_code", "RUN"))]
	outcome_label.text = String(view.get("outcome_label", "JOURNEY COMPLETE")).to_upper()
	headline_label.text = String(view.get("headline", "MARCH COMPLETE")).to_upper()
	var tone := String(view.get("tone", "stable"))
	headline_label.add_theme_color_override("font_color", Color("#9fddbd") if tone == "stable" else (Color("#e8c58e") if tone == "scarred" else Color("#ef8375")))
	var timeline: Array = view.get("timeline", [])
	for index in range(timeline_labels.size()):
		var step := timeline_labels[index]
		if index < timeline.size():
			var item: Dictionary = timeline[index]
			step.text = "%02d  %s\n%s" % [index + 1, String(item.get("name", "Road")).to_upper(), String(item.get("status", "Secured"))]
			step.add_theme_color_override("default_color", Color("#9fddbd") if String(item.get("tone", "stable")) == "stable" else Color("#e8c58e"))
		else:
			step.text = "%02d  ROAD NOT REACHED" % (index + 1)
			step.add_theme_color_override("default_color", Color("#647378"))
	journey_label.text = String(view.get("journey", "No route record available."))
	commitments_label.text = String(view.get("commitments", "No commitments recorded."))
	consequence_label.text = String(view.get("consequence", "No causal summary available."))
	condition_label.text = String(view.get("condition", "Fortress condition unavailable."))
	experiment_label.text = String(view.get("experiment", "Try a different route or layout."))
	march_on_button.text = String(view.get("march_on_label", "MARCH ON"))
	fortress_canvas.configure(view)

func focus_default() -> void:
	inspect_button.grab_focus()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	fortress_canvas.high_contrast_enabled = enabled
	fortress_canvas.queue_redraw()

func set_controller_cancel_label(cancel_label: String) -> void:
	pause_button.text = "PAUSE · ESC / %s" % cancel_label

func _configure_focus() -> void:
	var controls: Array[Control] = [inspect_button, notes_button, march_on_button, replay_button, title_button]
	for index in range(controls.size()):
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var next := controls[(index + 1) % controls.size()]
		controls[index].focus_previous = controls[index].get_path_to(previous)
		controls[index].focus_next = controls[index].get_path_to(next)
		controls[index].focus_neighbor_top = controls[index].get_path_to(previous)
		controls[index].focus_neighbor_bottom = controls[index].get_path_to(next)

class DebriefFortressCanvas extends Control:
	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false

	func configure(view: Dictionary) -> void:
		current_view = view.duplicate(true)
		queue_redraw()

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		draw_rect(Rect2(Vector2.ZERO, size), Color("#071013") if high_contrast_enabled else (Color("#17363d") if flooded else Color("#30383a")), true)
		draw_circle(Vector2(size.x * 0.78, size.y * 0.18), 42.0, Color(0.95, 0.75, 0.43, 0.17))
		draw_rect(Rect2(Vector2(0, size.y * 0.68), Vector2(size.x, size.y * 0.32)), Color("#10282c") if flooded else Color("#30271f"), true)
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		view["mode"] = "debrief"
		view["high_contrast"] = high_contrast_enabled
		FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.18, size.y * 0.17), Vector2(size.x * 0.64, size.y * 0.58)), view)
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 14), "THE SAME FORTRESS RETURNS · DAMAGE REMAINS", HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#e2cc98"))
