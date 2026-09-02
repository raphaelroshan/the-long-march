class_name LongMarchInterfaceAudio
extends Node

const DEFAULT_VOLUME_PERCENT := 70
const VOLUME_LEVELS: Array[int] = [0, 40, 70, 100]
const MIX_RATE := 24000
const SEMANTIC_STREAMS := {
	"route_commit": preload("res://assets/temporary/kenney/interface-sounds/Audio/confirmation_001.ogg"),
	"contact_entry": preload("res://assets/temporary/kenney/rpg-audio/Audio/doorOpen_1.ogg"),
	"contact_step": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalClick.ogg"),
	"arrival": preload("res://assets/temporary/kenney/rpg-audio/Audio/bookPlace1.ogg"),
	"arrival_handoff": preload("res://assets/temporary/kenney/interface-sounds/Audio/open_001.ogg"),
	"service": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalPot1.ogg"),
	"event": preload("res://assets/temporary/kenney/rpg-audio/Audio/bookFlip1.ogg"),
	"intervention": preload("res://assets/temporary/kenney/interface-sounds/Audio/switch_001.ogg"),
	"route_review": preload("res://assets/temporary/kenney/interface-sounds/Audio/open_002.ogg"),
	"debrief": preload("res://assets/temporary/kenney/rpg-audio/Audio/bookOpen.ogg"),
	"threat_road_raiders": preload("res://assets/temporary/kenney/rpg-audio/Audio/drawKnife2.ogg"),
	"threat_climbers": preload("res://assets/temporary/kenney/rpg-audio/Audio/beltHandle2.ogg"),
	"threat_burrowers": preload("res://assets/temporary/kenney/rpg-audio/Audio/creak3.ogg"),
	"threat_storm_front": preload("res://assets/temporary/kenney/interface-sounds/Audio/error_005.ogg"),
	"threat_siege_beast": preload("res://assets/temporary/kenney/interface-sounds/Audio/bong_001.ogg"),
	"threat_flood_surge": preload("res://assets/temporary/kenney/interface-sounds/Audio/drop_004.ogg"),
	"threat_civic_guardian": preload("res://assets/temporary/kenney/interface-sounds/Audio/glitch_004.ogg"),
	"threat_ember_drakes": preload("res://assets/temporary/kenney/rpg-audio/Audio/knifeSlice2.ogg"),
	"threat_lift_saboteurs": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalLatch.ogg"),
	"threat_elevator_warden": preload("res://assets/temporary/kenney/interface-sounds/Audio/drop_003.ogg"),
	"threat_salt_storm": preload("res://assets/temporary/kenney/interface-sounds/Audio/error_008.ogg"),
	"threat_rival_scouts": preload("res://assets/temporary/kenney/rpg-audio/Audio/drawKnife1.ogg"),
	"threat_rival_fortress": preload("res://assets/temporary/kenney/rpg-audio/Audio/doorClose_4.ogg"),
	"threat_signal_hunters": preload("res://assets/temporary/kenney/interface-sounds/Audio/glitch_003.ogg"),
	"threat_bridgebreakers": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalPot2.ogg"),
	"module_place": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalLatch.ogg"),
	"module_rotate": preload("res://assets/temporary/kenney/rpg-audio/Audio/beltHandle1.ogg"),
	"module_remove": preload("res://assets/temporary/kenney/rpg-audio/Audio/doorClose_2.ogg"),
	"module_invalid": preload("res://assets/temporary/kenney/interface-sounds/Audio/error_004.ogg"),
	"contact_impact": preload("res://assets/temporary/kenney/rpg-audio/Audio/metalPot3.ogg")
}
const CHECKPOINT_CUES := {
	"route_started": "route_commit",
	"encounter_advanced": "contact_step",
	"route_secured": "arrival",
	"recovery_reached": "arrival",
	"encounter_resolved": "arrival",
	"run_ended": "debrief",
	"settlement_service": "service",
	"event_resolved": "event",
	"intervention_used": "intervention"
}

var volume_percent: int = DEFAULT_VOLUME_PERCENT
var focus_stream: AudioStreamWAV
var confirm_stream: AudioStreamWAV
var notice_stream: AudioStreamWAV
var warning_stream: AudioStreamWAV
var players: Array[AudioStreamPlayer] = []
var next_player_index: int = 0
var last_cue_kind: String = ""
var last_cue_asset_path: String = ""
var last_semantic_cue_kind: String = ""
var last_semantic_asset_path: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	focus_stream = _make_cue(330.0, 410.0, 0.035, 0.16)
	confirm_stream = _make_cue(510.0, 680.0, 0.065, 0.23)
	notice_stream = _make_cue(440.0, 760.0, 0.12, 0.22)
	warning_stream = _make_cue(235.0, 165.0, 0.14, 0.24)
	for index in range(3):
		var player := AudioStreamPlayer.new()
		player.name = "InterfaceCue%d" % (index + 1)
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		players.append(player)
	_apply_volume()

func _exit_tree() -> void:
	for player in players:
		player.stop()
		player.stream = null
	focus_stream = null
	confirm_stream = null
	notice_stream = null
	warning_stream = null
	var tree := get_tree()
	var node_added_callback := Callable(self, "_on_node_added")
	if tree != null and tree.node_added.is_connected(node_added_callback):
		tree.node_added.disconnect(node_added_callback)

func register_root(root: Node) -> void:
	_register_node(root)
	var node_added_callback := Callable(self, "_on_node_added")
	if not get_tree().node_added.is_connected(node_added_callback):
		get_tree().node_added.connect(node_added_callback)

func set_volume_percent(value: int) -> void:
	volume_percent = value if value in VOLUME_LEVELS else DEFAULT_VOLUME_PERCENT
	_apply_volume()

func play_focus() -> void:
	_play(focus_stream, "focus")

func play_confirm() -> void:
	_play(confirm_stream, "confirm")

func play_notice() -> void:
	_play(notice_stream, "notice")

func play_warning() -> void:
	_play(warning_stream, "warning")

func play_semantic(cue_id: String) -> bool:
	var stream: AudioStream = SEMANTIC_STREAMS.get(cue_id)
	if stream == null or volume_percent <= 0:
		return false
	_play(stream, cue_id)
	last_semantic_cue_kind = cue_id
	last_semantic_asset_path = stream.resource_path
	return true

func play_checkpoint_cue(reason: String, contextual_cue_id: String = "") -> bool:
	if not contextual_cue_id.is_empty() and SEMANTIC_STREAMS.has(contextual_cue_id):
		return play_semantic(contextual_cue_id)
	var cue_id := String(CHECKPOINT_CUES.get(reason, ""))
	return not cue_id.is_empty() and play_semantic(cue_id)

func _register_node(node: Node) -> void:
	if node is BaseButton:
		_register_button(node as BaseButton)
	for child in node.get_children():
		_register_node(child)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_register_button(node as BaseButton)

func _register_button(button: BaseButton) -> void:
	var focus_callback := Callable(self, "_on_button_focused").bind(button)
	var pressed_callback := Callable(self, "_on_button_pressed").bind(button)
	if not button.focus_entered.is_connected(focus_callback):
		button.focus_entered.connect(focus_callback)
	if not button.pressed.is_connected(pressed_callback):
		button.pressed.connect(pressed_callback)

func _on_button_focused(_button: BaseButton) -> void:
	play_focus()

func _on_button_pressed(button: BaseButton) -> void:
	if button.has_meta("long_march_audio_manual_press"):
		return
	var semantic_cue := String(button.get_meta("long_march_audio_cue", ""))
	if not semantic_cue.is_empty() and play_semantic(semantic_cue):
		return
	play_confirm()

func _play(stream: AudioStream, cue_kind: String) -> void:
	if volume_percent <= 0 or stream == null or players.is_empty():
		return
	var player := players[next_player_index]
	next_player_index = (next_player_index + 1) % players.size()
	player.stream = stream
	if AudioServer.get_driver_name() != "Dummy":
		player.play()
	last_cue_kind = cue_kind
	last_cue_asset_path = stream.resource_path

func _apply_volume() -> void:
	var linear_volume := float(volume_percent) / 100.0
	var volume_db := -80.0 if volume_percent <= 0 else linear_to_db(linear_volume)
	for player in players:
		player.volume_db = volume_db

func _make_cue(start_hz: float, end_hz: float, duration: float, gain: float) -> AudioStreamWAV:
	var sample_count := maxi(1, roundi(duration * float(MIX_RATE)))
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var phase := 0.0
	for sample_index in range(sample_count):
		var progress := float(sample_index) / float(maxi(1, sample_count - 1))
		var frequency := lerpf(start_hz, end_hz, progress)
		phase += frequency / float(MIX_RATE)
		var attack := minf(progress / 0.12, 1.0)
		var decay := pow(1.0 - progress, 2.0)
		var wave := sin(TAU * phase) + sin(TAU * phase * 2.0) * 0.18
		var sample_value := clampi(roundi(wave * attack * decay * gain * 32767.0), -32768, 32767)
		bytes.encode_s16(sample_index * 2, sample_value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
