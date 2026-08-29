class_name TutorialObjectiveView
extends PanelContainer

signal show_me_requested
signal reset_requested
signal skip_requested

var lesson_label: Label
var title_label: Label
var reason_label: Label
var action_label: Label
var receipt_label: Label
var show_me_button: Button
var reset_button: Button
var skip_button: Button

func _ready() -> void:
	custom_minimum_size = Vector2(365, 0)
	add_theme_stylebox_override("panel", _style(Color("#10191ef4"), Color("#c39a5b"), 2, 8, 16))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)
	lesson_label = Label.new()
	lesson_label.add_theme_font_size_override("font_size", 11)
	lesson_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(lesson_label)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title_label)
	reason_label = Label.new()
	reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reason_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	content.add_child(reason_label)
	var order_panel := PanelContainer.new()
	order_panel.add_theme_stylebox_override("panel", _style(Color("#172329"), Color("#536a70"), 1, 5, 10))
	content.add_child(order_panel)
	action_label = Label.new()
	action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_label.add_theme_font_size_override("font_size", 15)
	action_label.add_theme_color_override("font_color", Color("#ffffff"))
	order_panel.add_child(action_label)
	receipt_label = Label.new()
	receipt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	receipt_label.add_theme_font_size_override("font_size", 11)
	receipt_label.add_theme_color_override("font_color", Color("#9fddbd"))
	receipt_label.visible = false
	content.add_child(receipt_label)
	show_me_button = Button.new()
	show_me_button.custom_minimum_size = Vector2(0, 46)
	show_me_button.pressed.connect(func() -> void: show_me_requested.emit())
	content.add_child(show_me_button)
	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 8)
	content.add_child(utility)
	reset_button = Button.new()
	reset_button.text = "RESET LESSON"
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(func() -> void: reset_requested.emit())
	utility.add_child(reset_button)
	skip_button = Button.new()
	skip_button.text = "LEAVE TUTORIAL"
	skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skip_button.pressed.connect(func() -> void: skip_requested.emit())
	utility.add_child(skip_button)

func configure(data: Dictionary, receipt: String = "") -> void:
	lesson_label.text = "FIRST WATCH · LESSON %s OF 10" % String(data.get("number", "01")) if String(data.get("number", "")) != "COMPLETE" else "MARCHMASTER CERTIFICATION"
	title_label.text = String(data.get("title", "Current order")).to_upper()
	reason_label.text = String(data.get("reason", ""))
	action_label.text = "CURRENT ORDER\n%s" % String(data.get("action", "Continue."))
	show_me_button.text = String(data.get("show", "SHOW ME"))
	receipt_label.text = receipt
	receipt_label.visible = not receipt.is_empty()
	reset_button.visible = String(data.get("number", "")) != "COMPLETE"

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
