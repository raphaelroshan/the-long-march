extends SceneTree

const InterfaceAudio = preload("res://src/support/interface_audio.gd")
const MainView = preload("res://src/ui/main.gd")

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
	_expect(audio.SEMANTIC_STREAMS.size() == 17 and String(audio.SEMANTIC_STREAMS["route_commit"].resource_path).ends_with("confirmation_001.ogg") and String(audio.SEMANTIC_STREAMS["debrief"].resource_path).ends_with("bookOpen.ogg"), "the journey should load distinct licensed temporary cues for commitment, threat approach, and Debrief")
	var main_view := MainView.new()
	var threat_arrivals := {"road_raiders": 2, "climbers": 3, "burrowers": 3, "storm_front": 1, "siege_beast": 4, "flood_surge": 1, "civic_guardian": 3}
	for threat_id in threat_arrivals:
		var cue_step: int = maxi(1, int(threat_arrivals[threat_id]) - 1)
		var cue_id := main_view.contact_audio_cue_for_step(cue_step, [{"id": threat_id, "defeated": false}])
		_expect(cue_id == "threat_%s" % threat_id and audio.SEMANTIC_STREAMS.has(cue_id), "%s should route its warning step to one stable family cue" % threat_id)
	_expect(main_view.contact_audio_cue_for_step(1, [{"id": "road_raiders", "defeated": true}]).is_empty(), "defeated contacts should not announce another approach")
	main_view.free()
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
	var transition_button := Button.new()
	transition_button.set_meta("long_march_audio_cue", "contact_entry")
	host.add_child(transition_button)
	await process_frame
	transition_button.pressed.emit()
	_expect(audio.last_semantic_cue_kind == "contact_entry" and audio.last_semantic_asset_path.ends_with("doorOpen_1.ogg"), "a tagged journey transition should replace the generic click with its semantic cue")
	_expect(audio.play_checkpoint_cue("route_started") and audio.last_semantic_cue_kind == "route_commit" and audio.last_semantic_asset_path.ends_with("confirmation_001.ogg"), "a successful route checkpoint should play its route-commit cue")
	_expect(audio.play_checkpoint_cue("settlement_service") and audio.last_semantic_cue_kind == "service" and audio.last_semantic_asset_path.ends_with("metalPot1.ogg"), "a completed recovery service should play a distinct material cue")
	_expect(audio.play_checkpoint_cue("encounter_advanced", "threat_burrowers") and audio.last_semantic_cue_kind == "threat_burrowers" and audio.last_semantic_asset_path.ends_with("creak3.ogg"), "a threat warning should replace the generic contact step with its family cue")
	_expect(audio.play_checkpoint_cue("encounter_advanced", "unknown_threat") and audio.last_semantic_cue_kind == "contact_step", "an unknown or non-warning contact step should retain the bounded generic mechanism cue")
	var cue_before_unknown := audio.last_semantic_cue_kind
	_expect(not audio.play_checkpoint_cue("module_moved") and audio.last_semantic_cue_kind == cue_before_unknown, "checkpoints without a semantic mapping should leave the normal save notice in control")
	audio.set_volume_percent(0)
	var muted_last_cue := audio.last_cue_kind
	var muted_last_semantic := audio.last_semantic_cue_kind
	audio.play_warning()
	_expect(audio.last_cue_kind == muted_last_cue and audio.players[0].volume_db <= -79.0, "muting should suppress cues without changing any visual control behavior")
	_expect(not audio.play_semantic("debrief") and audio.last_semantic_cue_kind == muted_last_semantic, "muting should suppress semantic journey cues as well as generated interface cues")
	host.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March interface audio")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
