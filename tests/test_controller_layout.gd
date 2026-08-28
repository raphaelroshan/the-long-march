extends SceneTree

const ControllerLayout = preload("res://src/support/controller_layout.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _joy_button(button_index: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = true
	return event

func _key(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_expect(ControllerLayout.normalize("unsupported") == ControllerLayout.DEFAULT_LAYOUT, "unsupported controller layouts should normalize to the documented default")
	ControllerLayout.apply(ControllerLayout.EAST_CONFIRM)
	_expect(InputMap.event_is_action(_joy_button(JOY_BUTTON_B), "ui_accept") and InputMap.event_is_action(_joy_button(JOY_BUTTON_A), "ui_cancel"), "east-confirm should swap the two face-button actions")
	_expect(not InputMap.event_is_action(_joy_button(JOY_BUTTON_A), "ui_accept") and not InputMap.event_is_action(_joy_button(JOY_BUTTON_B), "ui_cancel"), "east-confirm should not leave the previous face-button bindings active")
	_expect(InputMap.event_is_action(_key(KEY_ENTER), "ui_accept") and InputMap.event_is_action(_key(KEY_ESCAPE), "ui_cancel"), "controller remapping should preserve keyboard confirm and cancel")
	_expect(ControllerLayout.confirm_label(ControllerLayout.EAST_CONFIRM) == "B" and ControllerLayout.cancel_label(ControllerLayout.EAST_CONFIRM) == "A", "visible button labels should match the remapped actions")
	ControllerLayout.apply(ControllerLayout.SOUTH_CONFIRM)
	_expect(InputMap.event_is_action(_joy_button(JOY_BUTTON_A), "ui_accept") and InputMap.event_is_action(_joy_button(JOY_BUTTON_B), "ui_cancel"), "restoring south-confirm should restore the default face-button actions")
	if failures.is_empty():
		print("PASS: The Long March controller layout")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
