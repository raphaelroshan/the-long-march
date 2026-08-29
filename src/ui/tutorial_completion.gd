class_name TutorialCompletionView
extends Control

signal begin_campaign_requested
signal repeat_lesson_requested(lesson_id: String)
signal title_requested

const REPEATABLE_LESSONS := [
	["place_engine", "1 · Wake the engine"],
	["place_weapon", "2 · Arm the fortress"],
	["inspect_machine", "3 · Trace the chains"],
	["plan_road", "4 · Plan the road"],
	["travel", "5 · Watch the road"],
	["read_contact", "6 · Read the contact"],
	["respond", "7 · Advance and respond"],
	["damage", "8 · Follow the damage"],
	["victory", "9 · Secure the road"],
	["repair", "10 · Restore continuity"]
]

var begin_button: Button
var repeat_option: OptionButton
var repeat_button: Button
var title_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var veil := ColorRect.new()
	veil.color = Color("#071013f4")
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	panel.add_theme_stylebox_override("panel", _style(Color("#10191e"), Color("#d4ae6b"), 3, 10, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "ASHGATE MUSTER YARD · FIRST WATCH COMPLETE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "MARCHMASTER CERTIFIED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var summary := Label.new()
	summary.text = "ENGINE CHAIN · READY\nWEAPON CHAIN · READY\nROAD ANALYZED · MUSTER ROAD\nCONTACT COUNTERED · ROAD RAIDER\nRECOVERY DRILL · COMPLETE"
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_font_size_override("font_size", 15)
	summary.add_theme_color_override("font_color", Color("#d7dfd9"))
	content.add_child(summary)
	var creed := Label.new()
	creed.text = "KEEP MOVEMENT ALIVE. EVERY OTHER VICTORY DEPENDS ON IT."
	creed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	creed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	creed.add_theme_font_size_override("font_size", 17)
	creed.add_theme_color_override("font_color", Color("#e8c58e"))
	content.add_child(creed)
	begin_button = Button.new()
	begin_button.text = "BEGIN THE ASHGATE JOURNEY"
	begin_button.custom_minimum_size = Vector2(0, 58)
	begin_button.pressed.connect(func() -> void: begin_campaign_requested.emit())
	content.add_child(begin_button)
	var replay_row := HBoxContainer.new()
	replay_row.add_theme_constant_override("separation", 8)
	content.add_child(replay_row)
	repeat_option = OptionButton.new()
	repeat_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for lesson in REPEATABLE_LESSONS:
		repeat_option.add_item(String(lesson[1]))
		repeat_option.set_item_metadata(repeat_option.item_count - 1, String(lesson[0]))
	replay_row.add_child(repeat_option)
	repeat_button = Button.new()
	repeat_button.text = "REPEAT LESSON"
	repeat_button.pressed.connect(_repeat_selected)
	replay_row.add_child(repeat_button)
	title_button = Button.new()
	title_button.text = "RETURN TO TITLE"
	title_button.pressed.connect(func() -> void: title_requested.emit())
	content.add_child(title_button)

func open(available_lessons: Array[String]) -> void:
	for index in range(repeat_option.item_count):
		repeat_option.set_item_disabled(index, String(repeat_option.get_item_metadata(index)) not in available_lessons)
	visible = true
	begin_button.grab_focus()

func _repeat_selected() -> void:
	var lesson_id := String(repeat_option.get_item_metadata(repeat_option.selected))
	if not repeat_option.is_item_disabled(repeat_option.selected):
		repeat_lesson_requested.emit(lesson_id)

func _style(background: Color, border: Color, width: int, radius: int, padding: int) -> StyleBoxFlat:
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
