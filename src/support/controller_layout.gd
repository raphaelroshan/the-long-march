class_name LongMarchControllerLayout
extends RefCounted

const SOUTH_CONFIRM := "south_confirm"
const EAST_CONFIRM := "east_confirm"
const DEFAULT_LAYOUT := SOUTH_CONFIRM
const LAYOUTS: Array[String] = [SOUTH_CONFIRM, EAST_CONFIRM]

static func normalize(layout_id: String) -> String:
	return layout_id if layout_id in LAYOUTS else DEFAULT_LAYOUT

static func confirm_uses_south(layout_id: String) -> bool:
	return normalize(layout_id) == SOUTH_CONFIRM

static func confirm_label(layout_id: String) -> String:
	return "A" if confirm_uses_south(layout_id) else "B"

static func cancel_label(layout_id: String) -> String:
	return "B" if confirm_uses_south(layout_id) else "A"

static func apply(layout_id: String) -> void:
	var south_confirms := confirm_uses_south(layout_id)
	_replace_joypad_button("ui_accept", JOY_BUTTON_A if south_confirms else JOY_BUTTON_B)
	_replace_joypad_button("ui_cancel", JOY_BUTTON_B if south_confirms else JOY_BUTTON_A)

static func _replace_joypad_button(action: StringName, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			InputMap.action_erase_event(action, event)
	var replacement := InputEventJoypadButton.new()
	replacement.button_index = button_index
	InputMap.action_add_event(action, replacement)
