class_name RoadContactView
extends Control

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")
const TEMP_IMPACT_SPARK: Texture2D = preload("res://assets/temporary/kenney/particle-pack/spark_03.png")

const THREAT_PRESENTATION_PROFILES := {
	"road_raiders": {"wind_up": "HARPOON VOLLEY", "response": "SHELL OR REPEATER FIRE", "risk": "Cargo or an exposed system takes repeated damage."},
	"climbers": {"wind_up": "GRAPNEL RUSH", "response": "WALL LIGHT OR REPEATER FIRE", "risk": "Signal, exterior, or crew systems can be disabled before they answer."},
	"burrowers": {"wind_up": "UNDERCARRIAGE BREACH", "response": "LOWER-HULL ARMOR · SHIFTED GUNS · SPARE ENGINE", "risk": "A lower-hull breach can disable movement or field repair."},
	"storm_front": {"wind_up": "ARC DISCHARGE", "response": "SIGNAL · ADJACENT ARMOR · SEAL · VENT", "risk": "Heat rises while exposed signal or sustain systems fail."},
	"siege_beast": {"wind_up": "RAM CHARGE", "response": "SHELL FIRE · FRONT ARMOR", "risk": "A direct hit can break armor or crew capacity before final resolution."},
	"flood_surge": {"wind_up": "SURGE CREST", "response": "CONDENSER · ARMOR · WORKSHOP · SEAL", "risk": "Lower systems take damage while hull pressure compounds."},
	"civic_guardian": {"wind_up": "ARCHIVE BEAM", "response": "SHELL FIRE · PROTECTED CARGO · REDUNDANCY", "risk": "Cargo, signal, crew, or armor can be disabled at the archive gate."}
}

signal pause_requested
signal advance_requested
signal inspect_requested
signal intervention_requested(intervention_id: String)
signal semantic_audio_requested(cue_id: String)

var pause_button: Button
var contact_canvas: ContactCanvas
var phase_label: Label
var battle_phase_label: Label
var order_label: Label
var value_labels: Dictionary = {}
var timeline_labels: Array[Label] = []
var threat_heading: Label
var threat_status: Label
var threat_detail: Label
var counter_readiness_panel: PanelContainer
var counter_readiness_label: Label
var response_posture_panel: PanelContainer
var response_posture_label: Label
var warning_label: Label
var advance_button: Button
var inspect_button: Button
var intervention_heading: Label
var intervention_help: Label
var intervention_grid: GridContainer
var intervention_buttons: Array[Button] = []
var high_contrast_enabled: bool = false
var reduced_motion: bool = false
var current_view: Dictionary = {}

func _ready() -> void:
	_build_ui()
	process_priority = 10
	set_process(true)

func _process(_delta: float) -> void:
	if visible and contact_canvas != null:
		_refresh_battle_phase_label()

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 9) -> StyleBoxFlat:
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
	background.color = Color("#0d1418")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var page := VBoxContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", 10)
	add_child(page)
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 46)
	header.add_theme_constant_override("separation", 12)
	page.add_child(header)
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	phase_label = Label.new()
	phase_label.text = "ROAD CONTACT"
	phase_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	phase_label.add_theme_font_size_override("font_size", 13)
	phase_label.add_theme_color_override("font_color", Color("#efb879"))
	header.add_child(phase_label)
	battle_phase_label = Label.new()
	battle_phase_label.text = "FORECAST"
	battle_phase_label.custom_minimum_size = Vector2(132, 30)
	battle_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_phase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	battle_phase_label.add_theme_font_size_override("font_size", 10)
	header.add_child(battle_phase_label)
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
	_build_value_rail(body)
	var center := VBoxContainer.new()
	center.custom_minimum_size = Vector2(590, 0)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	order_label = Label.new()
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	order_label.custom_minimum_size = Vector2(0, 42)
	order_label.add_theme_font_size_override("font_size", 12)
	order_label.add_theme_color_override("font_color", Color("#d8c389"))
	center.add_child(order_label)
	contact_canvas = ContactCanvas.new()
	contact_canvas.custom_minimum_size = Vector2(590, 430)
	contact_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contact_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contact_canvas.impact_reached.connect(func() -> void: semantic_audio_requested.emit("contact_impact"))
	center.add_child(contact_canvas)
	var timeline := HBoxContainer.new()
	timeline.add_theme_constant_override("separation", 4)
	center.add_child(timeline)
	for step in range(1, 7):
		var label := Label.new()
		label.text = "%02d" % step
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(0, 30)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 10)
		timeline_labels.append(label)
		timeline.add_child(label)
	_build_command_dock(body)

func _build_value_rail(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(190, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#121d22"), Color("#35484f"), 1, 6, 10))
	parent.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	panel.add_child(stack)
	var heading := Label.new()
	heading.text = "FORTRESS STATE"
	heading.add_theme_font_size_override("font_size", 14)
	heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(heading)
	for value_id in ["hull", "power", "heat", "fuel", "pressure", "step", "doctrine"]:
		var receipt := PanelContainer.new()
		receipt.add_theme_stylebox_override("panel", _flat_style(Color("#18242a"), Color("#31434a"), 1, 4, 6))
		stack.add_child(receipt)
		var receipt_stack := VBoxContainer.new()
		receipt_stack.add_theme_constant_override("separation", 1)
		receipt.add_child(receipt_stack)
		var key_label := Label.new()
		key_label.text = value_id.to_upper()
		key_label.add_theme_font_size_override("font_size", 9)
		key_label.add_theme_color_override("font_color", Color("#89999e"))
		receipt_stack.add_child(key_label)
		var value_label := Label.new()
		value_label.text = "—"
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value_label.add_theme_font_size_override("font_size", 14 if value_id != "doctrine" else 11)
		value_label.add_theme_color_override("font_color", Color("#f1e6cf"))
		receipt_stack.add_child(value_label)
		value_labels[value_id] = value_label
	var note := Label.new()
	note.text = "Advance resolves one readable beat. The fortress does not reach its destination until every contact is settled."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(note)

func _build_command_dock(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(326, 0)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#141d21"), Color("#596d72"), 2, 6, 10))
	parent.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	var stack := VBoxContainer.new()
	stack.custom_minimum_size = Vector2(300, 0)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 4)
	scroll.add_child(stack)
	var kicker := Label.new()
	kicker.text = "CONTACT DOSSIER"
	kicker.add_theme_font_size_override("font_size", 9)
	kicker.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(kicker)
	threat_heading = Label.new()
	threat_heading.text = "CONTACT AHEAD"
	threat_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_heading.add_theme_font_size_override("font_size", 19)
	threat_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(threat_heading)
	threat_status = Label.new()
	threat_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_status.add_theme_font_size_override("font_size", 11)
	threat_status.add_theme_color_override("font_color", Color("#efb879"))
	stack.add_child(threat_status)
	threat_detail = Label.new()
	threat_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	threat_detail.custom_minimum_size = Vector2(0, 78)
	threat_detail.add_theme_font_size_override("font_size", 11)
	threat_detail.add_theme_color_override("font_color", Color("#c8d1d1"))
	stack.add_child(threat_detail)
	counter_readiness_panel = PanelContainer.new()
	counter_readiness_panel.custom_minimum_size = Vector2(0, 38)
	stack.add_child(counter_readiness_panel)
	counter_readiness_label = Label.new()
	counter_readiness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter_readiness_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	counter_readiness_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	counter_readiness_label.add_theme_font_size_override("font_size", 10)
	counter_readiness_panel.add_child(counter_readiness_label)
	response_posture_panel = PanelContainer.new()
	response_posture_panel.custom_minimum_size = Vector2(0, 60)
	stack.add_child(response_posture_panel)
	response_posture_label = Label.new()
	response_posture_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_posture_label.add_theme_font_size_override("font_size", 10)
	response_posture_panel.add_child(response_posture_label)
	warning_label = Label.new()
	warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning_label.add_theme_font_size_override("font_size", 10)
	warning_label.add_theme_color_override("font_color", Color("#ff9d8f"))
	stack.add_child(warning_label)
	advance_button = Button.new()
	advance_button.text = "ADVANCE CONTACT"
	advance_button.custom_minimum_size = Vector2(0, 48)
	advance_button.set_meta("long_march_audio_manual_press", true)
	advance_button.pressed.connect(func() -> void: advance_requested.emit())
	stack.add_child(advance_button)
	inspect_button = Button.new()
	inspect_button.text = "INSPECT CHASSIS"
	inspect_button.custom_minimum_size = Vector2(0, 36)
	inspect_button.pressed.connect(func() -> void: inspect_requested.emit())
	stack.add_child(inspect_button)
	intervention_heading = Label.new()
	intervention_heading.text = "EMERGENCY ORDER · 1 AVAILABLE"
	intervention_heading.add_theme_font_size_override("font_size", 12)
	intervention_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	stack.add_child(intervention_heading)
	intervention_help = Label.new()
	intervention_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intervention_help.add_theme_font_size_override("font_size", 9)
	intervention_help.add_theme_color_override("font_color", Color("#aab6ba"))
	stack.add_child(intervention_help)
	intervention_grid = GridContainer.new()
	intervention_grid.columns = 2
	intervention_grid.add_theme_constant_override("h_separation", 6)
	intervention_grid.add_theme_constant_override("v_separation", 6)
	stack.add_child(intervention_grid)
	for intervention_id in ["shift_power", "seal_compartment", "vent_heat", "cut_loose_cargo"]:
		var button := Button.new()
		button.text = intervention_id.replace("_", " ").capitalize()
		button.custom_minimum_size = Vector2(0, 38)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.set_meta("intervention_id", intervention_id)
		button.set_meta("long_march_audio_manual_press", true)
		button.pressed.connect(_emit_intervention.bind(intervention_id))
		button.focus_entered.connect(_show_action_help.bind(button))
		button.mouse_entered.connect(_show_action_help.bind(button))
		button.focus_exited.connect(_restore_action_help)
		button.mouse_exited.connect(_restore_action_help)
		intervention_buttons.append(button)
		intervention_grid.add_child(button)

func configure(view: Dictionary) -> void:
	var previous_target_id := String(current_view.get("active_target_id", ""))
	var advance_was_focused := advance_button != null and advance_button.has_focus()
	current_view = view.duplicate(true)
	phase_label.text = "%s · CONTACT STEP %d OF 6" % [String(view.get("location_name", "ROAD")).to_upper(), int(view.get("step", 0))]
	order_label.text = String(view.get("order", "Read the contact before advancing."))
	var values: Dictionary = view.get("values", {})
	for value_id in value_labels:
		value_labels[value_id].text = String(values.get(value_id, "—"))
	var step := int(view.get("step", 0))
	for index in range(timeline_labels.size()):
		var label := timeline_labels[index]
		var timeline_step := index + 1
		label.text = "%s %02d" % ["✓" if timeline_step <= step else ("▶" if timeline_step == step + 1 else "·"), timeline_step]
		label.add_theme_stylebox_override("normal", _flat_style(Color("#214238") if timeline_step <= step else (Color("#4b3b29") if timeline_step == step + 1 else Color("#172126")), Color("#76c69a") if timeline_step <= step else (Color("#e8c58e") if timeline_step == step + 1 else Color("#314147")), 1, 3, 2))
		label.add_theme_color_override("font_color", Color("#d9f5e5") if timeline_step <= step else (Color("#fff0ce") if timeline_step == step + 1 else Color("#6f7e82")))
	_configure_threat(view)
	warning_label.text = String(view.get("warning", ""))
	warning_label.visible = not warning_label.text.is_empty()
	advance_button.text = String(view.get("advance_label", "ADVANCE CONTACT"))
	advance_button.disabled = not bool(view.get("active", false))
	inspect_button.text = String(view.get("inspect_label", "INSPECT CHASSIS"))
	inspect_button.disabled = not bool(view.get("active", false))
	var actions: Array = view.get("interventions", [])
	for index in range(intervention_buttons.size()):
		var button := intervention_buttons[index]
		if index >= actions.size():
			button.visible = false
			continue
		var action: Dictionary = actions[index]
		button.visible = true
		button.text = String(action.get("short_label", action.get("label", "Emergency order")))
		button.tooltip_text = String(action.get("tooltip", ""))
		button.disabled = not bool(action.get("enabled", false))
	intervention_heading.text = String(view.get("intervention_heading", "EMERGENCY ORDER"))
	_restore_action_help()
	contact_canvas.high_contrast_enabled = high_contrast_enabled
	contact_canvas.reduced_motion = reduced_motion
	contact_canvas.configure(current_view)
	_refresh_battle_phase_label(true)
	_configure_focus()
	var current_target_id := String(current_view.get("active_target_id", ""))
	if advance_was_focused and previous_target_id.is_empty() and not current_target_id.is_empty() and not inspect_button.disabled:
		inspect_button.grab_focus.call_deferred()

func _refresh_battle_phase_label(force: bool = false) -> void:
	var battle_phase := battle_phase_for()
	if not force and battle_phase_label.text == battle_phase:
		return
	battle_phase_label.text = battle_phase
	var active_phase := battle_phase in ["TARGET", "WIND-UP", "RESPONSE", "IMPACT"]
	battle_phase_label.add_theme_stylebox_override("normal", _flat_style(Color("#4b2422") if active_phase else Color("#17312f"), Color.WHITE if high_contrast_enabled else (Color("#ef8375") if active_phase else Color("#6e918f")), 2, 4, 4))
	battle_phase_label.add_theme_color_override("font_color", Color("#fff0df") if active_phase else Color("#bce5d8"))

func battle_phase_for(view: Dictionary = {}) -> String:
	if view.is_empty():
		view = current_view
	var enemies: Array = view.get("enemies", [])
	var has_live_enemy := false
	var has_arrived_enemy := false
	for raw_enemy in enemies:
		var enemy: Dictionary = raw_enemy
		if bool(enemy.get("defeated", false)):
			continue
		has_live_enemy = true
		if bool(enemy.get("arrived", false)):
			has_arrived_enemy = true
	if not has_live_enemy:
		return "SETTLE"
	if not has_arrived_enemy:
		return "FORECAST" if int(view.get("step", 0)) == 0 else "APPROACH"
	if contact_canvas != null and contact_canvas.report_changed and contact_canvas.step_to > contact_canvas.step_from:
		if contact_canvas.transition_progress < 0.14:
			return "APPROACH"
		if contact_canvas.transition_progress < 0.28:
			return "TARGET"
		if contact_canvas.transition_progress < 0.43:
			return "WIND-UP"
		if contact_canvas.transition_progress < 0.58:
			return "RESPONSE"
		if contact_canvas.transition_progress < 0.78:
			return "IMPACT"
		return "CONSEQUENCE"
	return "RESPONSE"

func _configure_threat(view: Dictionary) -> void:
	var enemies: Array = view.get("enemies", [])
	var definitions: Dictionary = view.get("enemy_definitions", {})
	var chosen: Dictionary = {}
	var chosen_distance := 999
	for enemy in enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var definition: Dictionary = definitions.get(String(enemy.get("id", "")), {})
		var distance := 0 if bool(enemy.get("arrived", false)) else maxi(1, int(definition.get("arrival_step", 1)) - int(view.get("step", 0)))
		if chosen.is_empty() or distance < chosen_distance:
			chosen = enemy
			chosen_distance = distance
	if chosen.is_empty():
		threat_heading.text = "ROAD OPEN"
		threat_status.text = "No undefeated contact remains."
		threat_detail.text = "Advance to settle the road and complete arrival."
		counter_readiness_panel.visible = false
		response_posture_panel.visible = false
		return
	var definition: Dictionary = definitions.get(String(chosen.get("id", "")), {})
	var enemy_name := String(definition.get("name", String(chosen.get("id", "threat")).replace("_", " ").capitalize()))
	var profile: Dictionary = THREAT_PRESENTATION_PROFILES.get(String(chosen.get("id", "")), {})
	var risk_text := String(profile.get("risk", "The targeted system may be damaged or disabled."))
	_configure_counter_readiness(String(chosen.get("id", "")), view)
	_configure_response_posture(String(chosen.get("id", "")), view)
	threat_heading.text = enemy_name.to_upper()
	if bool(chosen.get("arrived", false)):
		var impact: Dictionary = chosen.get("impact", {})
		var target_name := _target_name(String(chosen.get("target", "hull")), view)
		threat_status.text = "ACTIVE CONTACT · TARGETING %s" % target_name.to_upper()
		var damage := int(impact.get("damage", 0))
		var durability_line := "%d→%d durability" % [int(impact.get("current_durability", 0)), int(impact.get("remaining_durability", 0))]
		var cascade_lines: Array[String] = []
		for change in impact.get("dependency_changes", []):
			cascade_lines.append("%s → %s" % [String(change.get("name", "System")), String(change.get("to", "offline")).to_upper()])
		threat_detail.text = "INTENT · %s → %s\nWHY · %s\nRESPONSE WINDOW · %s\nRISK IF IGNORED · %s\nNEXT · %d damage · %s%s" % [String(profile.get("wind_up", "CONTACT STRIKE")), target_name.to_upper(), String(impact.get("target_reason", "target route matched")).capitalize(), String(definition.get("counter", "No listed system counter")), risk_text, damage, durability_line, "\nCASCADE · %s" % ", ".join(cascade_lines) if not cascade_lines.is_empty() else ""]
	else:
		threat_status.text = "%d STEP%s OUT · %s" % [chosen_distance, "" if chosen_distance == 1 else "S", String(definition.get("flank", "road approach")).to_upper()]
		threat_detail.text = "APPROACH · %s\nPREFERRED TARGETS · %s\nCOUNTER · %s\nRISK IF IGNORED · %s" % [String(definition.get("route", "road approach")).capitalize(), " / ".join(definition.get("target_tags", [])), String(definition.get("counter", "No listed system counter")), risk_text]

func _configure_counter_readiness(enemy_id: String, view: Dictionary) -> void:
	var readiness: Dictionary = Dictionary(view.get("counter_readiness", {})).get(enemy_id, {})
	var status := String(readiness.get("status", "missing"))
	counter_readiness_label.text = String(readiness.get("text", "NO LISTED MODULE COUNTER READY"))
	counter_readiness_panel.visible = not enemy_id.is_empty()
	var background := Color("#172b25")
	var border := Color("#67b48b")
	var ink := Color("#bfe8cf")
	if status == "offline":
		background = Color("#33221f")
		border = Color("#db806f")
		ink = Color("#ffd0c6")
	elif status in ["missing", "uncertain"]:
		background = Color("#2d291f")
		border = Color("#caa562")
		ink = Color("#f3dba8")
	if high_contrast_enabled:
		background = background.darkened(0.40)
		border = Color.WHITE
		ink = Color.WHITE
	counter_readiness_panel.add_theme_stylebox_override("panel", _flat_style(background, border, 2, 4, 5))
	counter_readiness_label.add_theme_color_override("font_color", ink)

func _configure_response_posture(enemy_id: String, view: Dictionary) -> void:
	var posture: Dictionary = Dictionary(view.get("response_postures", {})).get(enemy_id, {})
	response_posture_panel.visible = not posture.is_empty()
	if posture.is_empty():
		return
	var status := String(posture.get("status", "missing"))
	var background := Color("#17252a")
	var border := Color("#607f87")
	var ink := Color("#d9e6e8")
	if status == "ready":
		background = Color("#142a24")
		border = Color("#67b48b")
		ink = Color("#d9f5e5")
	elif status == "offline":
		background = Color("#30201e")
		border = Color("#db806f")
		ink = Color("#ffd0c6")
	elif status in ["missing", "available"]:
		background = Color("#2b271d")
		border = Color("#caa562")
		ink = Color("#f3dba8")
	if high_contrast_enabled:
		background = background.darkened(0.40)
		border = Color.WHITE
		ink = Color.WHITE
	response_posture_panel.add_theme_stylebox_override("panel", _flat_style(background, border, 1, 4, 7))
	response_posture_label.add_theme_color_override("font_color", ink)
	response_posture_label.text = "%s\n%s" % [String(posture.get("heading", "NEXT RESPONSE")), String(posture.get("text", "Inspect the target before advancing."))]

func contact_readability_summary() -> Dictionary:
	var enemy := contact_canvas._nearest_enemy() if contact_canvas != null else {}
	if enemy.is_empty():
		return {"phase": "settle", "threat": "road open", "target": "", "damage": 0}
	var definitions: Dictionary = current_view.get("enemy_definitions", {})
	var enemy_id := String(enemy.get("id", "threat"))
	var definition: Dictionary = definitions.get(enemy_id, {})
	var impact: Dictionary = enemy.get("impact", {})
	var defense: Dictionary = enemy.get("defense", {})
	return {
		"phase": battle_phase_for().to_lower(),
		"threat": String(definition.get("name", enemy_id.replace("_", " ").capitalize())),
		"target": _target_name(String(enemy.get("target", "")), current_view),
		"damage": int(impact.get("damage", 0)),
		"counter": String(definition.get("counter", "")),
		"defense_damage": int(defense.get("damage", 0)),
		"defense_sources": Array(defense.get("sources", [])).duplicate(),
		"impact_buffer": int(defense.get("impact_buffer", 0)),
		"buffer_source": String(defense.get("buffer_source", "")),
		"durability_before": int(impact.get("current_durability", 0)),
		"durability_after": int(impact.get("remaining_durability", 0)),
		"cascade": _dependency_cascade_text(impact)
	}

func _dependency_cascade_text(impact: Dictionary) -> String:
	var changes: Array[String] = []
	for change in impact.get("dependency_changes", []):
		changes.append("%s %s→%s" % [String(change.get("name", "System")), String(change.get("from", "ready")).to_upper(), String(change.get("to", "offline")).to_upper()])
	return ", ".join(changes) if not changes.is_empty() else "No dependency state changed"

func _target_name(target_id: String, view: Dictionary) -> String:
	return String(view.get("target_names", {}).get(target_id, target_id.replace("_", " ").capitalize()))

func _emit_intervention(intervention_id: String) -> void:
	intervention_requested.emit(intervention_id)

func _show_action_help(button: Button) -> void:
	if button.disabled:
		return
	intervention_help.text = button.tooltip_text

func _restore_action_help() -> void:
	intervention_help.text = String(current_view.get("intervention_help", "Choose one order, or preserve it for a later step."))

func _configure_focus() -> void:
	var controls: Array[Control] = [advance_button, inspect_button]
	for button in intervention_buttons:
		if button.visible and not button.disabled:
			controls.append(button)
	if controls.is_empty():
		return
	for index in range(controls.size()):
		var current := controls[index]
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var next := controls[(index + 1) % controls.size()]
		current.focus_neighbor_top = current.get_path_to(previous)
		current.focus_neighbor_bottom = current.get_path_to(next)
		current.focus_previous = current.get_path_to(previous)
		current.focus_next = current.get_path_to(next)
	var enabled_actions: Array[Button] = []
	for button in intervention_buttons:
		if button.visible and not button.disabled:
			enabled_actions.append(button)
	if enabled_actions.is_empty():
		return
	advance_button.focus_neighbor_bottom = advance_button.get_path_to(inspect_button)
	inspect_button.focus_neighbor_top = inspect_button.get_path_to(advance_button)
	inspect_button.focus_neighbor_bottom = inspect_button.get_path_to(enabled_actions[0])
	for button in enabled_actions:
		var grid_index := intervention_buttons.find(button)
		var same_row_index := grid_index + 1 if grid_index % 2 == 0 else grid_index - 1
		if same_row_index >= 0 and same_row_index < intervention_buttons.size():
			var same_row := intervention_buttons[same_row_index]
			if same_row.visible and not same_row.disabled:
				button.focus_neighbor_right = button.get_path_to(same_row) if grid_index % 2 == 0 else NodePath()
				button.focus_neighbor_left = button.get_path_to(same_row) if grid_index % 2 == 1 else NodePath()
		var above_index := grid_index - 2
		var below_index := grid_index + 2
		var above: Control = intervention_buttons[above_index] if above_index >= 0 and intervention_buttons[above_index].visible and not intervention_buttons[above_index].disabled else inspect_button
		var below: Control = intervention_buttons[below_index] if below_index < intervention_buttons.size() and intervention_buttons[below_index].visible and not intervention_buttons[below_index].disabled else advance_button
		button.focus_neighbor_top = button.get_path_to(above)
		button.focus_neighbor_bottom = button.get_path_to(below)

func focus_default() -> void:
	if not String(current_view.get("active_target_id", "")).is_empty() and not inspect_button.disabled:
		inspect_button.grab_focus()
	else:
		advance_button.grab_focus()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if battle_phase_label != null:
		_refresh_battle_phase_label(true)
	if not current_view.is_empty():
		_configure_threat(current_view)
	if contact_canvas != null:
		contact_canvas.high_contrast_enabled = enabled
		contact_canvas.queue_redraw()

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	if contact_canvas != null:
		contact_canvas.reduced_motion = enabled
		if enabled:
			contact_canvas.finish_transition()

func set_controller_cancel_label(cancel_label: String) -> void:
	if pause_button != null:
		pause_button.text = "PAUSE · ESC / %s" % cancel_label

class ContactCanvas extends Control:
	signal impact_reached

	const THREAT_VISUAL_PROFILES := {
		"road_raiders": {"form": "raider_rig", "lane": "road_flank", "scale": 1.05, "label_y": -43.0},
		"climbers": {"form": "grapnel_climber", "lane": "upper_flank", "scale": 1.0, "label_y": -54.0},
		"burrowers": {"form": "burrower_head", "lane": "under_road", "scale": 1.08, "label_y": -39.0},
		"storm_front": {"form": "storm_mass", "lane": "weather_line", "scale": 1.12, "label_y": -61.0},
		"siege_beast": {"form": "siege_beast", "lane": "direct_road", "scale": 1.22, "label_y": -50.0},
		"flood_surge": {"form": "flood_crest", "lane": "waterline", "scale": 1.14, "label_y": -45.0},
		"civic_guardian": {"form": "civic_guardian", "lane": "archive_gate", "scale": 1.18, "label_y": -75.0}
	}

	var current_view: Dictionary = {}
	var high_contrast_enabled: bool = false
	var reduced_motion: bool = false
	var step_from: float = 0.0
	var step_to: float = 0.0
	var transition_progress: float = 1.0
	var report_changed: bool = false
	var impact_cue_emitted: bool = false
	var fortress_anchors: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true
		set_process(true)

	func threat_visual_signature(enemy_id: String) -> Dictionary:
		var signature: Dictionary = Dictionary(THREAT_VISUAL_PROFILES.get(enemy_id, {"form": "raider_rig", "lane": "road_flank", "scale": 1.0})).duplicate(true)
		signature["enemy_id"] = enemy_id
		return signature

	func configure(view: Dictionary) -> void:
		var next_step := float(view.get("step", 0))
		var previous_step := float(current_view.get("step", next_step))
		var previous_report: Array = current_view.get("recent_report", [])
		var next_report: Array = view.get("recent_report", [])
		report_changed = previous_report != next_report
		current_view = view.duplicate(true)
		step_from = previous_step
		step_to = next_step
		transition_progress = 1.0 if reduced_motion or next_step <= previous_step else 0.0
		impact_cue_emitted = false
		if reduced_motion:
			_emit_impact_once()
		queue_redraw()

	func finish_transition() -> void:
		_emit_impact_once()
		transition_progress = 1.0
		queue_redraw()

	func _process(delta: float) -> void:
		if transition_progress >= 1.0:
			return
		var previous_progress := transition_progress
		transition_progress = minf(1.0, transition_progress + delta * 0.42)
		if previous_progress < 0.58 and transition_progress >= 0.58:
			_emit_impact_once()
		queue_redraw()

	func _emit_impact_once() -> void:
		if impact_cue_emitted or not report_changed or step_to <= step_from or not _resolved_step_has_damage():
			return
		impact_cue_emitted = true
		impact_reached.emit()

	func _draw() -> void:
		var flooded := String(current_view.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
		var sky := Color("#071013") if high_contrast_enabled else (Color("#18363d") if flooded else Color("#31383b"))
		var ground := Color("#0d2427") if flooded else Color("#30271f")
		draw_rect(Rect2(Vector2.ZERO, size), sky, true)
		draw_circle(Vector2(size.x * 0.80, size.y * 0.18), 52.0, Color(0.95, 0.75, 0.43, 0.15))
		_draw_contact_pressure()
		for ridge in range(4):
			var y := size.y * (0.32 + ridge * 0.045)
			draw_line(Vector2(0, y), Vector2(size.x, y - 26.0 + ridge * 8.0), Color("#395358") if flooded else Color("#655b4d"), 24.0)
		draw_rect(Rect2(Vector2(0, size.y * 0.64), Vector2(size.x, size.y * 0.36)), ground, true)
		for road_mark in range(7):
			var x := 28.0 + road_mark * (size.x - 56.0) / 6.0
			draw_line(Vector2(x, size.y * 0.85), Vector2(x + 42.0, size.y * 0.85), Color("#94784f"), 4.0)
		var fortress_rect := _draw_fortress()
		_draw_contacts(fortress_rect)
		_draw_resolution_banner()
		_draw_causal_receipt()
		var caption := "FORTRESS AT CONTACT · DESTINATION PENDING"
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 14), caption, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("#d7c08b"))

	func _draw_fortress() -> Rect2:
		var impact_strength := sin(transition_progress * PI) if _active_contact_has_damage() else 0.0
		var view: Dictionary = current_view.get("fortress", {}).duplicate(true)
		if report_changed and transition_progress < 0.80 and not Dictionary(current_view.get("fortress_before", {})).is_empty():
			view = Dictionary(current_view.get("fortress_before", {})).duplicate(true)
			var active_target_id := String(current_view.get("active_target_id", ""))
			for index in range(Array(view.get("modules", [])).size()):
				var module: Dictionary = view["modules"][index]
				module["targeted"] = String(module.get("id", "")) == active_target_id
				view["modules"][index] = module
		view["mode"] = "contact"
		view["impact"] = impact_strength
		view["high_contrast"] = high_contrast_enabled
		var rendered := FortressSilhouette.draw(self, Rect2(Vector2(size.x * 0.12, size.y * 0.25), Vector2(size.x * 0.64, size.y * 0.50)), view)
		fortress_anchors = Dictionary(rendered.get("anchors", {})).duplicate()
		return rendered.get("body", Rect2())

	func _draw_contact_pressure() -> void:
		var enemy := _nearest_enemy()
		if enemy.is_empty():
			return
		var arrived := bool(enemy.get("arrived", false))
		var lane_color := Color(0.72, 0.25, 0.19, 0.12 if arrived else 0.05)
		var lane := PackedVector2Array([
			Vector2(size.x * 0.58, size.y * 0.18),
			Vector2(size.x, size.y * 0.12),
			Vector2(size.x, size.y * 0.74),
			Vector2(size.x * 0.58, size.y * 0.68)
		])
		draw_colored_polygon(lane, lane_color)
		for line_index in range(3):
			var y := size.y * (0.29 + float(line_index) * 0.12)
			draw_line(Vector2(size.x * 0.68, y), Vector2(size.x * 0.96, y - 14.0), Color(0.88, 0.40, 0.30, 0.14), 2.0)

	func presentation_stage_text() -> String:
		var enemy := _nearest_enemy()
		if enemy.is_empty():
			return "SETTLE · ROAD OPEN · ADVANCE TO ARRIVAL"
		var enemy_id := String(enemy.get("id", "threat"))
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		var definition: Dictionary = definitions.get(enemy_id, {})
		var enemy_name := String(definition.get("name", enemy_id.replace("_", " ").capitalize())).to_upper()
		var arrived := bool(enemy.get("arrived", false))
		if not arrived:
			var distance := maxi(1, int(definition.get("arrival_step", 1)) - int(current_view.get("step", 0)))
			var phase := "FORECAST" if int(current_view.get("step", 0)) == 0 else "APPROACH"
			return "%s · %s · %d STEP%s OUT" % [phase, enemy_name, distance, "" if distance == 1 else "S"]
		var target_name := String(current_view.get("target_names", {}).get(String(enemy.get("target", "hull")), String(enemy.get("target", "hull")).replace("_", " ").capitalize())).to_upper()
		if report_changed and step_to > step_from:
			if transition_progress < 0.14:
				return "APPROACH · %s VIA %s" % [enemy_name, String(definition.get("route", "ROAD APPROACH")).to_upper()]
			if transition_progress < 0.28:
				return "TARGET LOCK · %s → %s" % [enemy_name, target_name]
			if transition_progress < 0.43:
				return "WIND-UP · %s" % _attack_signature(enemy_id)
			if transition_progress < 0.58:
				return "RESPONSE WINDOW · %s" % _response_cue(enemy_id)
			if transition_progress < 0.78:
				return "IMPACT · %s" % _latest_report_line([" hits ", " reaches the hull", " absorbs "])
			return "CONSEQUENCE · %s" % _latest_consequence_text()
		return "RESPONSE READY · %s" % _response_cue(enemy_id)

	func _draw_resolution_banner() -> void:
		var text := presentation_stage_text()
		var banner := Rect2(Vector2(size.x * 0.17, 10), Vector2(size.x * 0.66, 34))
		var urgent := text.begins_with("TARGET") or text.begins_with("WIND-UP") or text.begins_with("IMPACT")
		draw_rect(banner, Color("#461f1c") if urgent else Color("#142328"), true)
		draw_rect(banner, Color.WHITE if high_contrast_enabled else (Color("#ef8375") if urgent else Color("#6e918f")), false, 2.0)
		draw_string(ThemeDB.fallback_font, banner.position + Vector2(8, 22), text, HORIZONTAL_ALIGNMENT_CENTER, banner.size.x - 16, 11, Color("#fff0df"))

	func _draw_causal_receipt() -> void:
		var enemy := _nearest_enemy()
		if enemy.is_empty() or not bool(enemy.get("arrived", false)):
			return
		var enemy_id := String(enemy.get("id", "threat"))
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		var definition: Dictionary = definitions.get(enemy_id, {})
		var threat_name := String(definition.get("name", enemy_id.replace("_", " ").capitalize())).to_upper()
		var target_name := String(current_view.get("target_names", {}).get(String(enemy.get("target", "hull")), String(enemy.get("target", "hull")).replace("_", " ").capitalize())).to_upper()
		var impact: Dictionary = enemy.get("impact", {})
		var phase := ""
		if report_changed and step_to > step_from:
			if transition_progress < 0.28:
				phase = "TARGET"
			elif transition_progress < 0.43:
				phase = "WIND-UP"
			elif transition_progress < 0.58:
				phase = "RESPONSE"
			elif transition_progress < 0.78:
				phase = "IMPACT"
			else:
				phase = "CONSEQUENCE"
		else:
			phase = "RESPONSE"
		var headline := "THREAT → TARGET · %s → %s" % [threat_name, target_name]
		var detail := "COUNTER · %s" % _response_cue(enemy_id)
		if phase == "WIND-UP":
			detail = "WIND-UP · %s · TARGET REMAINS %s" % [_attack_signature(enemy_id), target_name]
		elif phase == "IMPACT":
			detail = "IMPACT · %s %d→%d · %d DAMAGE" % [target_name, int(impact.get("current_durability", 0)), int(impact.get("remaining_durability", 0)), int(impact.get("damage", 0))]
		elif phase == "CONSEQUENCE":
			var cascades: Array[String] = []
			for change in impact.get("dependency_changes", []):
				cascades.append("%s %s→%s" % [String(change.get("name", "System")).to_upper(), String(change.get("from", "ready")).to_upper(), String(change.get("to", "offline")).to_upper()])
			detail = "CASCADE · %s" % (", ".join(cascades) if not cascades.is_empty() else "NO DEPENDENCY STATE CHANGED")
		var receipt := Rect2(Vector2(18, size.y - 92), Vector2(size.x - 36, 62))
		var urgent := phase in ["WIND-UP", "IMPACT", "CONSEQUENCE"]
		draw_rect(receipt, Color("#321d1b") if urgent else Color("#102428"), true)
		draw_rect(receipt, Color.WHITE if high_contrast_enabled else (Color("#db7568") if urgent else Color("#668f8c")), false, 2.0)
		draw_string(ThemeDB.fallback_font, receipt.position + Vector2(10, 22), headline, HORIZONTAL_ALIGNMENT_LEFT, receipt.size.x - 20, 10, Color("#f3dec2"))
		draw_string(ThemeDB.fallback_font, receipt.position + Vector2(10, 45), detail, HORIZONTAL_ALIGNMENT_LEFT, receipt.size.x - 20, 10, Color("#fff0df"))

	func _nearest_enemy() -> Dictionary:
		var chosen: Dictionary = {}
		var chosen_distance := 999
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		for raw_enemy in current_view.get("enemies", []):
			var enemy: Dictionary = raw_enemy
			if bool(enemy.get("defeated", false)):
				continue
			var definition: Dictionary = definitions.get(String(enemy.get("id", "")), {})
			var distance := 0 if bool(enemy.get("arrived", false)) else maxi(1, int(definition.get("arrival_step", 1)) - int(current_view.get("step", 0)))
			if chosen.is_empty() or distance < chosen_distance:
				chosen = enemy
				chosen_distance = distance
		return chosen

	func _attack_signature(enemy_id: String) -> String:
		return String(RoadContactView.THREAT_PRESENTATION_PROFILES.get(enemy_id, {}).get("wind_up", "CONTACT STRIKE"))

	func _response_cue(enemy_id: String) -> String:
		return String(RoadContactView.THREAT_PRESENTATION_PROFILES.get(enemy_id, {}).get("response", "PROTECT THE TARGET OR BREAK CONTACT"))

	func _latest_report_line(markers: Array[String]) -> String:
		var report: Array = current_view.get("recent_report", [])
		for index in range(report.size() - 1, -1, -1):
			var line := String(report[index])
			for marker in markers:
				if marker in line:
					return line.trim_prefix("Step %d: " % int(current_view.get("step", 0)))
		return "The fortress record has not reported a matching effect."

	func _latest_consequence_text() -> String:
		var line := _latest_report_line(["Dependency change:", " restores ", "durability is", " reaches the hull"])
		if line.begins_with("Dependency change: "):
			line = line.trim_prefix("Dependency change: ")
			if " — " in line:
				line = line.get_slice(" — ", 0)
			line = line.replace(" is now ", " → ")
		return line

	func _active_contact_has_damage() -> bool:
		if transition_progress >= 1.0:
			return false
		return _resolved_step_has_damage()

	func _resolved_step_has_damage() -> bool:
		for enemy in current_view.get("enemies", []):
			if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and int(enemy.get("impact", {}).get("damage", 0)) > 0:
				return true
		return false

	func _target_anchor(body: Rect2, target_id: String) -> Vector2:
		if target_id == "hull":
			return body.get_center()
		if "signal" in target_id or "coil" in target_id:
			return body.position + Vector2(232, -52)
		if "engine" in target_id or "coal" in target_id or "fuel" in target_id:
			return body.position + Vector2(55, 83)
		if "armor" in target_id:
			return body.position + Vector2(305, 60)
		if "crew" in target_id or "refugee" in target_id:
			return body.position + Vector2(110, 22)
		if "workshop" in target_id or "parts" in target_id:
			return body.position + Vector2(178, 76)
		return body.position + Vector2(245, 82)

	func _draw_contacts(fortress_rect: Rect2) -> void:
		var enemies: Array = current_view.get("enemies", [])
		var definitions: Dictionary = current_view.get("enemy_definitions", {})
		var animated_step := lerpf(step_from, step_to, transition_progress * transition_progress * (3.0 - 2.0 * transition_progress))
		var target_id := String(current_view.get("active_target_id", ""))
		var target_anchor: Vector2 = fortress_anchors.get(target_id, _target_anchor(fortress_rect, target_id))
		var visible_index := 0
		for enemy in enemies:
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id := String(enemy.get("id", ""))
			var definition: Dictionary = definitions.get(enemy_id, {})
			var visual := threat_visual_signature(enemy_id)
			var arrived := bool(enemy.get("arrived", false))
			var steps_out := maxf(0.0, float(definition.get("arrival_step", 1)) - animated_step)
			var x := fortress_rect.end.x + 46.0 + steps_out * 55.0
			var y := fortress_rect.end.y + 38.0 - float(visible_index % 2) * 62.0
			if enemy_id in ["climbers", "storm_front"]:
				y = fortress_rect.position.y - 48.0 - float(visible_index) * 18.0
			if enemy_id in ["burrowers", "flood_surge"]:
				y = fortress_rect.end.y + 68.0
			x = minf(size.x - 58.0, x)
			var profile_scale := float(visual.get("scale", 1.0))
			var draw_scale := profile_scale * (1.30 if arrived else 1.04)
			_draw_approach_lane(String(visual.get("lane", "road_flank")), Vector2(x, y), fortress_rect, arrived)
			_draw_enemy_symbol(enemy_id, Vector2(x, y), arrived, draw_scale)
			if arrived and not String(enemy.get("target", "")).is_empty():
				var line_color := Color("#ff8275")
				line_color.a = 0.4 + transition_progress * 0.6
				draw_dashed_line(Vector2(x - 16.0, y), target_anchor, line_color, 2.0, 7.0)
				_draw_intent_arrow(Vector2(x - 16.0, y), target_anchor, line_color)
				var pulse_radius := 15.0 + sin(transition_progress * PI) * 8.0
				draw_arc(target_anchor, pulse_radius, 0, TAU, 24, line_color, 3.0)
				if temporary_impact_vfx_active():
					_draw_impact_burst(target_anchor, line_color)
				var target_name := String(current_view.get("target_names", {}).get(String(enemy.get("target", "hull")), String(enemy.get("target", "hull")).replace("_", " ").capitalize())).to_upper()
				draw_string(ThemeDB.fallback_font, target_anchor + Vector2(-70.0, -23.0), target_name, HORIZONTAL_ALIGNMENT_CENTER, 140.0, 10, Color("#fff0df"))
			var name := String(definition.get("name", enemy_id.replace("_", " ").capitalize())).to_upper()
			var label_y := float(visual.get("label_y", -38.0)) * draw_scale
			draw_string(ThemeDB.fallback_font, Vector2(x - 72.0, y + label_y), name, HORIZONTAL_ALIGNMENT_CENTER, 144, 10, Color("#f1d1b2"))
			visible_index += 1

	func _draw_intent_arrow(from: Vector2, to: Vector2, color: Color) -> void:
		var direction := (to - from).normalized()
		if direction == Vector2.ZERO:
			return
		var perpendicular := Vector2(-direction.y, direction.x)
		var tip := to - direction * 10.0
		draw_colored_polygon(PackedVector2Array([tip, tip - direction * 13.0 + perpendicular * 7.0, tip - direction * 13.0 - perpendicular * 7.0]), color)

	func _draw_impact_burst(center: Vector2, color: Color) -> void:
		var strength := sin(clampf((transition_progress - 0.58) / 0.20, 0.0, 1.0) * PI)
		var texture_size := 62.0 + strength * 34.0
		draw_texture_rect(TEMP_IMPACT_SPARK, Rect2(center - Vector2.ONE * texture_size * 0.5, Vector2.ONE * texture_size), false, Color(1.0, 0.48, 0.28, 0.30 + strength * 0.36))
		draw_circle(center, 12.0 + strength * 8.0, Color(color.r, color.g, color.b, 0.22 + strength * 0.28))
		for spoke in range(6):
			var direction := Vector2.from_angle(TAU * float(spoke) / 6.0)
			draw_line(center + direction * 15.0, center + direction * (25.0 + strength * 13.0), color, 2.0 + strength * 2.0)

	func temporary_impact_vfx_active() -> bool:
		return not reduced_motion and report_changed and transition_progress >= 0.58 and transition_progress < 0.78

	func _draw_approach_lane(lane: String, position: Vector2, fortress_rect: Rect2, arrived: bool) -> void:
		var lane_color := Color(0.90, 0.42, 0.32, 0.34 if arrived else 0.18)
		match lane:
			"upper_flank":
				draw_dashed_line(position + Vector2(-70.0, 18.0), fortress_rect.position + Vector2(fortress_rect.size.x * 0.78, -26.0), lane_color, 2.0, 8.0)
			"under_road":
				for crack_index in range(4):
					var crack_x := fortress_rect.end.x + 14.0 + float(crack_index) * 38.0
					draw_polyline(PackedVector2Array([Vector2(crack_x, fortress_rect.end.y + 58.0), Vector2(crack_x + 11.0, fortress_rect.end.y + 48.0), Vector2(crack_x + 19.0, fortress_rect.end.y + 63.0)]), lane_color, 2.0)
			"weather_line":
				for streak_index in range(4):
					var streak_y := fortress_rect.position.y - 62.0 + float(streak_index) * 21.0
					draw_line(Vector2(fortress_rect.end.x + 18.0, streak_y), Vector2(size.x - 14.0, streak_y - 34.0), lane_color, 3.0)
			"waterline":
				for wave_index in range(4):
					var wave_x := fortress_rect.end.x + 18.0 + float(wave_index) * 39.0
					draw_arc(Vector2(wave_x, fortress_rect.end.y + 65.0), 17.0, PI, TAU, 12, lane_color, 3.0)
			"direct_road":
				draw_line(Vector2(fortress_rect.end.x + 16.0, fortress_rect.end.y + 20.0), Vector2(position.x + 36.0, position.y + 20.0), lane_color, 8.0)
				draw_line(Vector2(fortress_rect.end.x + 16.0, fortress_rect.end.y + 34.0), Vector2(position.x + 36.0, position.y + 34.0), lane_color.darkened(0.18), 4.0)
			"archive_gate":
				for rail_index in range(3):
					var rail_y := position.y - 44.0 + float(rail_index) * 22.0
					draw_line(Vector2(fortress_rect.end.x + 24.0, rail_y), Vector2(size.x - 12.0, rail_y), lane_color, 2.0)
			_:
				draw_line(Vector2(fortress_rect.end.x + 18.0, fortress_rect.end.y + 35.0), Vector2(position.x + 26.0, position.y + 35.0), lane_color, 3.0)

	func _draw_enemy_symbol(enemy_id: String, position: Vector2, arrived: bool, scale_amount: float = 1.0) -> void:
		var color := Color("#ff7f70") if arrived else Color("#d8a16e")
		var form := String(threat_visual_signature(enemy_id).get("form", "raider_rig"))
		match form:
			"storm_mass":
				_draw_storm_mass(position, color, scale_amount)
			"flood_crest":
				_draw_flood_crest(position, color, scale_amount)
			"burrower_head":
				_draw_burrower(position, color, scale_amount)
			"grapnel_climber":
				_draw_climber(position, color, scale_amount)
			"siege_beast":
				_draw_siege_beast(position, color, scale_amount)
			"civic_guardian":
				_draw_civic_guardian(position, color, scale_amount)
			_:
				_draw_raider_rig(position, color, scale_amount)

	func _draw_storm_mass(position: Vector2, color: Color, scale_amount: float) -> void:
		for offset in [Vector2(-18, 0), Vector2(0, -8), Vector2(19, 1)]:
			draw_circle(position + offset * scale_amount, 17.0 * scale_amount, color.darkened(0.25))
		draw_arc(position + Vector2(1.0, -2.0) * scale_amount, 33.0 * scale_amount, PI, TAU, 18, color, 3.0 * scale_amount)
		draw_polyline(PackedVector2Array([position + Vector2(-4, 12) * scale_amount, position + Vector2(-12, 35) * scale_amount, position + Vector2(3, 26) * scale_amount, position + Vector2(-2, 47) * scale_amount]), color, 4.0 * scale_amount)

	func _draw_flood_crest(position: Vector2, color: Color, scale_amount: float) -> void:
		var crest := PackedVector2Array([
			position + Vector2(-42.0, 18.0) * scale_amount,
			position + Vector2(-25.0, -12.0) * scale_amount,
			position + Vector2(-5.0, 9.0) * scale_amount,
			position + Vector2(16.0, -18.0) * scale_amount,
			position + Vector2(43.0, 18.0) * scale_amount
		])
		draw_polyline(crest, color, 7.0 * scale_amount)
		draw_arc(position + Vector2(20.0, 11.0) * scale_amount, 19.0 * scale_amount, PI, TAU, 14, color.darkened(0.18), 5.0 * scale_amount)
		draw_line(position + Vector2(-44.0, 25.0) * scale_amount, position + Vector2(47.0, 25.0) * scale_amount, color.darkened(0.34), 4.0 * scale_amount)

	func _draw_burrower(position: Vector2, color: Color, scale_amount: float) -> void:
		for radius in [10.0, 20.0, 30.0]:
			draw_arc(position, radius * scale_amount, PI, TAU, 14, color, 3.0 * scale_amount)
		var head := PackedVector2Array([position + Vector2(-20.0, 0.0) * scale_amount, position + Vector2(0.0, -25.0) * scale_amount, position + Vector2(21.0, 0.0) * scale_amount])
		draw_colored_polygon(head, color.darkened(0.20))
		draw_line(position + Vector2(-18.0, -2.0) * scale_amount, position + Vector2(-32.0, -18.0) * scale_amount, color, 4.0 * scale_amount)
		draw_line(position + Vector2(18.0, -2.0) * scale_amount, position + Vector2(32.0, -18.0) * scale_amount, color, 4.0 * scale_amount)

	func _draw_climber(position: Vector2, color: Color, scale_amount: float) -> void:
		draw_circle(position, 14.0 * scale_amount, color.darkened(0.18))
		draw_circle(position + Vector2(-14.0, 5.0) * scale_amount, 10.0 * scale_amount, color)
		for angle in [-1.0, -0.45, 0.15, 0.75, 1.35, 2.1]:
			var direction := Vector2(cos(float(angle)), sin(float(angle)))
			draw_line(position, position + direction * 31.0 * scale_amount, color, 4.0 * scale_amount)
		draw_line(position + Vector2(9.0, -9.0) * scale_amount, position + Vector2(34.0, -31.0) * scale_amount, color.lightened(0.18), 3.0 * scale_amount)
		draw_arc(position + Vector2(38.0, -34.0) * scale_amount, 8.0 * scale_amount, 0.2, PI + 0.2, 10, color.lightened(0.18), 3.0 * scale_amount)

	func _draw_siege_beast(position: Vector2, color: Color, scale_amount: float) -> void:
		var body := Rect2(position - Vector2(37.0, 19.0) * scale_amount, Vector2(72.0, 38.0) * scale_amount)
		draw_rect(body, color.darkened(0.24), true)
		var head := PackedVector2Array([position + Vector2(-43.0, -8.0) * scale_amount, position + Vector2(-62.0, 8.0) * scale_amount, position + Vector2(-35.0, 19.0) * scale_amount])
		draw_colored_polygon(head, color)
		draw_line(position + Vector2(-54.0, 6.0) * scale_amount, position + Vector2(-72.0, -8.0) * scale_amount, color.lightened(0.15), 5.0 * scale_amount)
		for leg_x in [-24.0, -5.0, 18.0, 33.0]:
			draw_line(position + Vector2(leg_x, 15.0) * scale_amount, position + Vector2(leg_x - 5.0, 39.0) * scale_amount, color, 7.0 * scale_amount)
		for plate_index in range(3):
			draw_line(position + Vector2(-18.0 + plate_index * 21.0, -19.0) * scale_amount, position + Vector2(-10.0 + plate_index * 21.0, -31.0) * scale_amount, color.lightened(0.08), 5.0 * scale_amount)

	func _draw_civic_guardian(position: Vector2, color: Color, scale_amount: float) -> void:
		var torso := Rect2(position - Vector2(22.0, 31.0) * scale_amount, Vector2(44.0, 58.0) * scale_amount)
		draw_rect(torso, color.darkened(0.28), true)
		draw_rect(torso, color, false, 4.0 * scale_amount)
		draw_circle(position + Vector2(0.0, -42.0) * scale_amount, 15.0 * scale_amount, color.darkened(0.18))
		draw_circle(position + Vector2(0.0, -42.0) * scale_amount, 5.0 * scale_amount, color.lightened(0.30))
		draw_arc(position + Vector2(31.0, 0.0) * scale_amount, 25.0 * scale_amount, -PI * 0.5, PI * 0.5, 16, color, 5.0 * scale_amount)
		draw_line(position + Vector2(-14.0, 27.0) * scale_amount, position + Vector2(-22.0, 49.0) * scale_amount, color, 7.0 * scale_amount)
		draw_line(position + Vector2(14.0, 27.0) * scale_amount, position + Vector2(22.0, 49.0) * scale_amount, color, 7.0 * scale_amount)

	func _draw_raider_rig(position: Vector2, color: Color, scale_amount: float) -> void:
		var hull := PackedVector2Array([
			position + Vector2(-32.0, -12.0) * scale_amount,
			position + Vector2(27.0, -12.0) * scale_amount,
			position + Vector2(38.0, 2.0) * scale_amount,
			position + Vector2(30.0, 16.0) * scale_amount,
			position + Vector2(-34.0, 16.0) * scale_amount
		])
		draw_colored_polygon(hull, color.darkened(0.18))
		draw_rect(Rect2(position + Vector2(-8.0, -27.0) * scale_amount, Vector2(28.0, 15.0) * scale_amount), color.darkened(0.34), true)
		for wheel_x in [-20.0, 22.0]:
			draw_circle(position + Vector2(wheel_x, 20.0) * scale_amount, 10.0 * scale_amount, color)
			draw_circle(position + Vector2(wheel_x, 20.0) * scale_amount, 4.0 * scale_amount, color.darkened(0.40))
		draw_line(position + Vector2(-20.0, -13.0) * scale_amount, position + Vector2(25.0, -29.0) * scale_amount, color.lightened(0.12), 5.0 * scale_amount)
		draw_line(position + Vector2(12.0, -27.0) * scale_amount, position + Vector2(36.0, -39.0) * scale_amount, color, 3.0 * scale_amount)
