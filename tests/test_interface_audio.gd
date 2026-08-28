extends SceneTree

const InterfaceAudio = preload("res://src/support/interface_audio.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var host := Control.new()
	root.add_child(host)
	var audio := InterfaceAudio.new()
	host.add_child(audio)
	await process_frame
	_expect(audio.players.size() == 3, "interface audio should keep a small overlap-safe player pool")
	_expect(audio.focus_stream != null and audio.focus_stream.data.size() > 0 and audio.focus_stream.mix_rate == InterfaceAudio.MIX_RATE, "focus feedback should be a generated deterministic PCM cue")
	_expect(audio.confirm_stream != null and audio.notice_stream != null and audio.warning_stream != null, "the controller should provide distinct confirmation, notice, and warning cues")
	audio.set_volume_percent(55)
	_expect(audio.volume_percent == InterfaceAudio.DEFAULT_VOLUME_PERCENT, "unsupported stored volume should normalize to the documented default")
	audio.set_volume_percent(40)
	_expect(audio.volume_percent == 40 and is_equal_approx(audio.players[0].volume_db, linear_to_db(0.4)), "supported volume should apply consistently to every cue player")
	audio.register_root(host)
	var dynamic_button := Button.new()
	dynamic_button.text = "DYNAMIC ACTION"
	host.add_child(dynamic_button)
	await process_frame
	var focus_callback := Callable(audio, "_on_button_focused").bind(dynamic_button)
	var pressed_callback := Callable(audio, "_on_button_pressed").bind(dynamic_button)
	_expect(dynamic_button.focus_entered.is_connected(focus_callback) and dynamic_button.pressed.is_connected(pressed_callback), "buttons added after registration should receive the same input-neutral audio feedback")
	dynamic_button.grab_focus()
	await process_frame
	_expect(audio.last_cue_kind == "focus", "keyboard or controller focus should trigger the quiet navigation cue")
	dynamic_button.pressed.emit()
	_expect(audio.last_cue_kind == "confirm", "button activation should trigger the confirmation cue")
	audio.set_volume_percent(0)
	var muted_last_cue := audio.last_cue_kind
	audio.play_warning()
	_expect(audio.last_cue_kind == muted_last_cue and audio.players[0].volume_db <= -79.0, "muting should suppress cues without changing any visual control behavior")
	host.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March interface audio")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
