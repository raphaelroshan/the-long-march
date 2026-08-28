class_name LongMarchInterfaceAudio
extends Node

const DEFAULT_VOLUME_PERCENT := 70
const VOLUME_LEVELS: Array[int] = [0, 40, 70, 100]
const MIX_RATE := 24000

var volume_percent: int = DEFAULT_VOLUME_PERCENT
var focus_stream: AudioStreamWAV
var confirm_stream: AudioStreamWAV
var notice_stream: AudioStreamWAV
var warning_stream: AudioStreamWAV
var players: Array[AudioStreamPlayer] = []
var next_player_index: int = 0
var last_cue_kind: String = ""

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
	play_confirm()

func _play(stream: AudioStreamWAV, cue_kind: String) -> void:
	if volume_percent <= 0 or stream == null or players.is_empty():
		return
	var player := players[next_player_index]
	next_player_index = (next_player_index + 1) % players.size()
	player.stream = stream
	if AudioServer.get_driver_name() != "Dummy":
		player.play()
	last_cue_kind = cue_kind

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
