extends Control

signal return_to_title_requested
signal checkpoint_reached(reason: String)
signal pause_requested

const LongMarchState = preload("res://src/core/fortress_state.gd")
const PlaytestJournal = preload("res://src/support/playtest_journal.gd")
const CampaignMapView = preload("res://src/ui/campaign_map.gd")
const CombatPanel = preload("res://src/ui/combat_panel.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const ENGINE_ICON = preload("res://assets/steam_lance_engine_icon.png")
const CANNON_ICON = preload("res://assets/shell_cannon_icon.png")
const WORKSHOP_ICON = preload("res://assets/field_workshop_icon.png")
const SIGNAL_ICON = preload("res://assets/signal_coil_icon.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const RUN_FLOW_STEPS := ["PREP", "ROADS", "RECOVER", "FINAL", "RESULT"]
const DOCTRINE_DESCRIPTIONS := {
	"protect_cargo": "Cargo guard · Raiders take +1 weapon damage, cargo is targeted less often, and cargo hits deal −1 damage.",
	"protect_crew": "Crew guard · Climbers and the Siege Beast take +1 weapon damage, while crew rooms are targeted less and take −1 damage.",
	"run_hot": "Overdrive · All attacks gain +1 damage, but the fortress gains +2 heat; overheating raises route risk and incoming damage."
}
const ONBOARDING_LABELS := ["COMMAND", "CHASSIS", "ROUTE", "SURVIVE"]
const ROUTE_INTEL_COLORS := {
	"neutral": Color("#d8c389"),
	"safe": Color("#9fddbd"),
	"warning": Color("#e8c58e"),
	"danger": Color("#ef8375"),
	"unknown": Color("#cbb8e8")
}
const ONBOARDING_STEPS := [
	{
		"title": "Your job is continuity",
		"body": "You command a walking fortress through five encounters. Success means reaching Meridian Pass with a machine that can still move and people who can still rely on it—not collecting the largest pile of parts.",
		"action": "FIRST ACTION · Answer the Ashgate convoy contract. The choice changes reward, trust, and road pressure."
	},
	{
		"title": "Read the machine",
		"body": "Select an installed module to see what keeps it Ready. Engines need adjacent fuel; weapons benefit from ammunition lifts; workshops need crew. Choose Edit Chassis; arrows move the gold cursor, A or Enter acts, and B or Escape returns.",
		"action": "TRY THIS · Select the Steam Lance Engine and read its dependency status before changing the layout."
	},
	{
		"title": "Choose, review, then commit",
		"body": "Cyan map nodes are reachable. Known routes reveal exact danger; forecasts reveal a class of danger; unscouted roads remain uncertain. Selecting a route is only a preview. A separate Commit action pays its fuel and time cost.",
		"action": "LOOK FOR · Compare risk, fuel, pressure, visibility, and doctrine before committing the fortress."
	},
	{
		"title": "Read, intervene, recover",
		"body": "Battles advance one readable step at a time. Enemies name their targets and the report explains dependency failures. You may issue one emergency order per encounter, then refit and recover at Morrowline before the final road.",
		"action": "IN CONTACT · Read the current target before advancing. At the end, record what felt clear or confusing."
	}
]

var state: LongMarchState
var metric_labels: Dictionary = {}
var subtitle_label: Label
var pause_button: Button
var journey_banner: TextureRect
var status_label: Label
var left_scroll: ScrollContainer
var right_scroll: ScrollContainer
var journey_label: Label
var encounter_label: Label
var combat_panel: CombatPanel
var event_label: Label
var log_label: Label
var route_option: OptionButton
var doctrine_option: OptionButton
var module_option: OptionButton
var focus_chassis_button: Button
var rotate_button: Button
var remove_button: Button
var travel_button: Button
var advance_encounter_button: Button
var intervention_buttons: Array[Button] = []
var settlement_repair_button: Button
var settlement_refuel_button: Button
var settlement_hull_button: Button
var final_journey_button: Button
var refit_label: Label
var route_preview_label: Label
var refit_title: Label
var module_group: Control
var refit_actions: Control
var route_group: Control
var doctrine_group: Control
var doctrine_detail_label: Label
var intervention_title: Label
var intervention_help_label: Label
var settlement_title: Label
var settlement_group: Control
var campaign_title: Label
var campaign_pressure_label: Label
var campaign_path_label: Label
var campaign_map: CampaignMapView
var campaign_node_buttons: Array[Button] = []
var campaign_commit_button: Button
var selected_campaign_node_id: String = ""
var contract_title: Label
var contract_label: Label
var contract_accept_button: Button
var contract_decline_button: Button
var campaign_event_title: Label
var campaign_event_label: Label
var campaign_event_buttons: Array[Button] = []
var recruit_iven_button: Button
var save_button: Button
var load_button: Button
var guidance_label: Label
var run_flow_panels: Array[PanelContainer] = []
var run_flow_labels: Array[Label] = []
var current_run_flow_step: int = 0
var asset_row: HBoxContainer
var phase_badge: Label
var campaign_progress_bar: ProgressBar
var how_to_play_button: Button
var feedback_button: Button
var results_group: VBoxContainer
var results_summary_label: Label
var results_replay_label: Label
var play_again_button: Button
var results_title_button: Button
var onboarding_overlay: Control
var onboarding_title_label: Label
var onboarding_body_label: Label
var onboarding_action_label: Label
var onboarding_progress_label: Label
var onboarding_step_panels: Array[PanelContainer] = []
var onboarding_step_labels: Array[Label] = []
var onboarding_back_button: Button
var onboarding_next_button: Button
var onboarding_skip_button: Button
var onboarding_step: int = 0
var onboarding_reopened: bool = false
var feedback_overlay: Control
var feedback_clear_text: TextEdit
var feedback_confusing_text: TextEdit
var feedback_score_option: OptionButton
var feedback_status_label: Label
var feedback_save_button: Button
var feedback_close_button: Button
var last_feedback_path: String = ""
var journal: PlaytestJournal
var result_recorded: bool = false
var fortress_panel: Control
var selected_module_id: String = ""
var selected_module_cell := Vector2i(-1, -1)
var placement_rotated: bool = false
var show_onboarding_on_ready: bool = true

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 5, padding: int = 8) -> StyleBoxFlat:
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

func _create_ui_theme() -> Theme:
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 14
	for control_type in ["Button", "OptionButton"]:
		ui_theme.set_stylebox("normal", control_type, _flat_style(Color("#24323a"), Color("#50636b"), 1, 5, 7))
		ui_theme.set_stylebox("hover", control_type, _flat_style(Color("#30434c"), Color("#79cfc3"), 2, 5, 6))
		ui_theme.set_stylebox("pressed", control_type, _flat_style(Color("#172229"), Color("#e8c58e"), 2, 5, 6))
		ui_theme.set_stylebox("focus", control_type, _flat_style(Color("#283942"), Color("#f3dfad"), 2, 5, 6))
		ui_theme.set_stylebox("disabled", control_type, _flat_style(Color("#182127"), Color("#39474d"), 1, 5, 7))
		ui_theme.set_color("font_color", control_type, Color("#eef3ef"))
		ui_theme.set_color("font_hover_color", control_type, Color("#ffffff"))
		ui_theme.set_color("font_pressed_color", control_type, Color("#fff1ce"))
		ui_theme.set_color("font_focus_color", control_type, Color("#ffffff"))
		ui_theme.set_color("font_disabled_color", control_type, Color("#718087"))
	ui_theme.set_stylebox("background", "ProgressBar", _flat_style(Color("#18242b"), Color("#34454c"), 1, 3, 0))
	ui_theme.set_stylebox("fill", "ProgressBar", _flat_style(Color("#5fae91"), Color("#79cfc3"), 0, 3, 0))
	ui_theme.set_color("font_color", "ProgressBar", Color("#f1e6cf"))
	return ui_theme

func _add_metric_chip(parent: HBoxContainer, metric_id: String, title: String, tooltip: String) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(92, 48)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.tooltip_text = tooltip
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#172229"), Color("#34454c"), 1, 4, 5))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 0)
	panel.add_child(stack)
	var title_label := Label.new()
	title_label.text = title.to_upper()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 9)
	title_label.add_theme_color_override("font_color", Color("#89999e"))
	stack.add_child(title_label)
	var value_label := Label.new()
	value_label.text = "—"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color("#f1e6cf"))
	stack.add_child(value_label)
	metric_labels[metric_id] = value_label
	parent.add_child(panel)

func _set_metric(metric_id: String, value: String, color: Color = Color("#f1e6cf")) -> void:
	var label := metric_labels.get(metric_id) as Label
	if label == null:
		return
	label.text = value
	label.add_theme_color_override("font_color", color)

func _accent_button(button: Button, background: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _flat_style(background, border, 2, 5, 7))
	button.add_theme_stylebox_override("hover", _flat_style(background.lightened(0.08), border.lightened(0.12), 2, 5, 7))
	button.add_theme_stylebox_override("pressed", _flat_style(background.darkened(0.1), Color("#ffffff"), 2, 5, 7))
	button.add_theme_stylebox_override("focus", _flat_style(background, Color("#ffffff"), 3, 5, 6))

func _configure_focus_cycle(controls: Array) -> void:
	for index in range(controls.size()):
		var control: Control = controls[index]
		var previous: Control = controls[(index - 1 + controls.size()) % controls.size()]
		var next: Control = controls[(index + 1) % controls.size()]
		control.focus_previous = control.get_path_to(previous)
		control.focus_next = control.get_path_to(next)

func _configure_vertical_focus_cycle(controls: Array) -> void:
	_configure_focus_cycle(controls)
	for index in range(controls.size()):
		var control: Control = controls[index]
		var previous: Control = controls[(index - 1 + controls.size()) % controls.size()]
		var next: Control = controls[(index + 1) % controls.size()]
		control.focus_neighbor_top = control.get_path_to(previous)
		control.focus_neighbor_bottom = control.get_path_to(next)

func _refresh_planning_focus() -> void:
	if state.phase not in ["refit", "map", "settlement"]:
		return
	var active_controls: Array = []
	for control in [contract_accept_button, contract_decline_button, doctrine_option, campaign_commit_button, module_option, focus_chassis_button, rotate_button, remove_button, settlement_repair_button, settlement_refuel_button, settlement_hull_button]:
		if _control_can_receive_focus(control):
			active_controls.append(control)
	for event_button in campaign_event_buttons:
		if _control_can_receive_focus(event_button):
			active_controls.append(event_button)
	if _control_can_receive_focus(recruit_iven_button):
		active_controls.append(recruit_iven_button)
	for node_button in campaign_node_buttons:
		if _control_can_receive_focus(node_button):
			active_controls.append(node_button)
	if _control_can_receive_focus(how_to_play_button):
		active_controls.append(how_to_play_button)
	_configure_vertical_focus_cycle(active_controls)

func _build_run_flow_tracker(parent: VBoxContainer) -> void:
	var heading := Label.new()
	heading.text = "RUN FLOW"
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", Color("#89999e"))
	parent.add_child(heading)
	var tracker := HBoxContainer.new()
	tracker.add_theme_constant_override("separation", 4)
	parent.add_child(tracker)
	for step_name in RUN_FLOW_STEPS:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 42)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tracker.add_child(panel)
		var label := Label.new()
		label.text = String(step_name)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 9)
		panel.add_child(label)
		run_flow_panels.append(panel)
		run_flow_labels.append(label)

func _run_flow_step() -> int:
	if state.phase == "results":
		return 4
	if state.phase == "final_battle" or state.current_location == "meridian_pass" or state.campaign_encounters_completed >= 4:
		return 3
	if state.current_location == "morrowline_camp" or state.campaign_encounters_completed >= 3:
		if state.current_location != "morrowline_camp" and state.campaign_encounters_completed >= 3:
			return 3
		return 2
	if state.guard_contract_status != "offered" or state.campaign_encounters_completed > 0 or state.phase in ["map", "battle"]:
		return 1
	return 0

func _refresh_run_flow_tracker() -> void:
	current_run_flow_step = _run_flow_step()
	for index in range(run_flow_panels.size()):
		var panel := run_flow_panels[index]
		var label := run_flow_labels[index]
		if index < current_run_flow_step:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#183329"), Color("#4e8d72"), 1, 4, 3))
			label.text = "✓\n%s" % RUN_FLOW_STEPS[index]
			label.add_theme_color_override("font_color", Color("#9fddbd"))
		elif index == current_run_flow_step:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#4b405d"), Color("#eee2ff"), 2, 4, 2))
			label.text = "%02d\n%s" % [index + 1, RUN_FLOW_STEPS[index]]
			label.add_theme_color_override("font_color", Color("#ffffff"))
		else:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#182127"), Color("#35474d"), 1, 4, 3))
			label.text = "—\n%s" % RUN_FLOW_STEPS[index]
			label.add_theme_color_override("font_color", Color("#738286"))

func _ready() -> void:
	theme = _create_ui_theme()
	journal = PlaytestJournal.new()
	_reset_state()
	_build_ui()
	_refresh_ui()
	_journal_event("run_started", {"version": String(ProjectSettings.get_setting("application/config/version", "unknown"))})
	if show_onboarding_on_ready and not FileAccess.file_exists(ONBOARDING_PATH):
		_show_onboarding()

func _reset_state() -> void:
	state = LongMarchState.new(1107)
	state.place_module("steam_lance_engine", Vector2i(0, 0))
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(4, 0))
	state.place_module("ammunition_lift", Vector2i(2, 1))
	state.place_module("field_workshop", Vector2i(3, 1))
	state.place_module("repeater_gun", Vector2i(3, 2), true)
	state.seed_starter_inventory()
	state.start_campaign()
	selected_campaign_node_id = ""
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false
	result_recorded = false

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#111820")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	margin.add_child(columns)

	left_scroll = ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(left_scroll)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(760, 760)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	left.add_child(header)
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC / B"
	pause_button.custom_minimum_size = Vector2(150, 42)
	pause_button.tooltip_text = "Pause the march to save, review the briefing, change settings, restart, or return to the title."
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)

	subtitle_label = Label.new()
	subtitle_label.text = "A fortress is only strong if it can keep moving."
	subtitle_label.add_theme_color_override("font_color", Color("#aab6ba"))
	left.add_child(subtitle_label)
	journey_banner = TextureRect.new()
	journey_banner.texture = JOURNEY_BACKGROUND
	journey_banner.custom_minimum_size = Vector2(0, 82)
	journey_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	journey_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	journey_banner.modulate = Color(1.0, 1.0, 1.0, 0.78)
	left.add_child(journey_banner)

	var metric_row := HBoxContainer.new()
	metric_row.add_theme_constant_override("separation", 6)
	_add_metric_chip(metric_row, "day", "Day", "Current campaign day. Travel and some local decisions advance time.")
	_add_metric_chip(metric_row, "fuel", "Fuel", "Routes consume fuel. A connected operational engine is also required.")
	_add_metric_chip(metric_row, "money", "Ashmarks", "Spend Ashmarks on contracts, specialists, repairs, and supplies.")
	_add_metric_chip(metric_row, "hull", "Hull", "The run ends if the fortress hull reaches zero at Meridian Pass.")
	_add_metric_chip(metric_row, "mass", "Mass", "Heavy builds can consume additional fuel on mass-sensitive roads.")
	_add_metric_chip(metric_row, "power", "Power", "Power draw must not exceed available generation.")
	_add_metric_chip(metric_row, "heat", "Heat", "Heat above the limit increases route and combat danger.")
	left.add_child(metric_row)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color("#aab6ba"))
	left.add_child(status_label)
	phase_badge = Label.new()
	phase_badge.add_theme_font_size_override("font_size", 12)
	phase_badge.add_theme_color_override("font_color", Color("#e8c58e"))
	left.add_child(phase_badge)
	journey_label = Label.new()
	journey_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journey_label.custom_minimum_size = Vector2(740, 42)
	journey_label.add_theme_color_override("font_color", Color("#d8c389"))
	left.add_child(journey_label)
	campaign_progress_bar = ProgressBar.new()
	campaign_progress_bar.max_value = 5
	campaign_progress_bar.show_percentage = false
	campaign_progress_bar.custom_minimum_size = Vector2(0, 8)
	campaign_progress_bar.tooltip_text = "Secured encounters in the five-encounter Ashgate Lowlands chapter."
	left.add_child(campaign_progress_bar)
	combat_panel = CombatPanel.new()
	combat_panel.visible = false
	left.add_child(combat_panel)
	encounter_label = Label.new()
	encounter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	encounter_label.custom_minimum_size = Vector2(740, 54)
	encounter_label.add_theme_color_override("font_color", Color("#e89270"))
	left.add_child(encounter_label)

	fortress_panel = FortressPanel.new()
	fortress_panel.custom_minimum_size = Vector2(760, 260)
	fortress_panel.state = state
	fortress_panel.grid_cell_pressed.connect(_on_grid_cell_pressed)
	fortress_panel.rotate_requested.connect(_on_rotate_pressed)
	fortress_panel.remove_requested.connect(_on_remove_pressed)
	fortress_panel.focus_exit_requested.connect(_on_fortress_focus_exit_requested)
	fortress_panel.focus_entered.connect(_scroll_chassis_into_view)
	left.add_child(fortress_panel)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(740, 72)
	event_label.add_theme_color_override("font_color", Color("#e7c18b"))
	left.add_child(event_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	left.add_child(log_label)

	right_scroll = ScrollContainer.new()
	right_scroll.custom_minimum_size = Vector2(370, 0)
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(right_scroll)
	var right := PanelContainer.new()
	right.custom_minimum_size = Vector2(370, 760)
	right.add_theme_stylebox_override("panel", _flat_style(Color("#151d21"), Color("#2c3a40"), 1, 6, 10))
	right_scroll.add_child(right)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	right.add_child(controls)

	var control_title := Label.new()
	control_title.text = "MARCHMASTER'S DESK"
	control_title.add_theme_font_size_override("font_size", 20)
	control_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(control_title)
	asset_row = HBoxContainer.new()
	asset_row.add_theme_constant_override("separation", 5)
	for asset in [ENGINE_ICON, CANNON_ICON, WORKSHOP_ICON, SIGNAL_ICON]:
		var icon := TextureRect.new()
		icon.texture = asset
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		asset_row.add_child(icon)
	controls.add_child(asset_row)
	_build_run_flow_tracker(controls)
	guidance_label = Label.new()
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance_label.custom_minimum_size = Vector2(320, 54)
	guidance_label.add_theme_font_size_override("font_size", 14)
	guidance_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	controls.add_child(guidance_label)

	doctrine_option = OptionButton.new()
	for doctrine_id in ["protect_cargo", "protect_crew", "run_hot"]:
		doctrine_option.add_item(doctrine_id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	doctrine_option.item_selected.connect(_on_departure_option_changed)
	doctrine_group = _labeled_control("Journey doctrine", doctrine_option)
	controls.add_child(doctrine_group)
	doctrine_detail_label = Label.new()
	doctrine_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	doctrine_detail_label.custom_minimum_size = Vector2(320, 48)
	doctrine_detail_label.add_theme_font_size_override("font_size", 12)
	doctrine_detail_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(doctrine_detail_label)

	refit_title = Label.new()
	refit_title.text = "REFIT CHASSIS"
	refit_title.add_theme_font_size_override("font_size", 17)
	refit_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(refit_title)

	module_option = OptionButton.new()
	var module_ids: Array = LongMarchState.MODULE_DEFS.keys()
	module_ids.sort()
	for module_id in module_ids:
		var definition: Dictionary = LongMarchState.MODULE_DEFS[module_id]
		module_option.add_item(String(definition.name))
		module_option.set_item_metadata(module_option.item_count - 1, module_id)
	module_option.item_selected.connect(_on_module_selected)
	selected_module_id = "steam_lance_engine"
	selected_module_cell = Vector2i(0, 0)
	_select_module_option(selected_module_id)
	module_group = _labeled_control("Module", module_option)
	controls.add_child(module_group)
	focus_chassis_button = Button.new()
	focus_chassis_button.text = "EDIT CHASSIS · ARROWS + A"
	focus_chassis_button.tooltip_text = "Move keyboard or controller focus to the chassis. Use arrows to move, A or Enter to select or place, and B or Escape to return."
	focus_chassis_button.pressed.connect(_focus_chassis_for_refit)
	controls.add_child(focus_chassis_button)

	refit_actions = HBoxContainer.new()
	refit_actions.add_theme_constant_override("separation", 8)
	rotate_button = Button.new()
	rotate_button.text = "Rotate"
	rotate_button.tooltip_text = "Rotate the pending or selected module. Shortcut: R while the chassis has focus."
	rotate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotate_button.pressed.connect(_on_rotate_pressed)
	refit_actions.add_child(rotate_button)
	remove_button = Button.new()
	remove_button.text = "Remove selected"
	remove_button.tooltip_text = "Remove the selected installed module. Shortcut: Delete while the chassis has focus."
	remove_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remove_button.pressed.connect(_on_remove_pressed)
	refit_actions.add_child(remove_button)
	controls.add_child(refit_actions)

	refit_label = Label.new()
	refit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	refit_label.custom_minimum_size = Vector2(320, 54)
	refit_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(refit_label)

	settlement_group = VBoxContainer.new()
	settlement_group.add_theme_constant_override("separation", 8)
	settlement_title = Label.new()
	settlement_title.text = "MORROWLINE SERVICES"
	settlement_title.add_theme_font_size_override("font_size", 17)
	settlement_title.add_theme_color_override("font_color", Color("#e8c58e"))
	settlement_group.add_child(settlement_title)
	settlement_repair_button = Button.new()
	settlement_repair_button.text = "Repair selected module"
	settlement_repair_button.pressed.connect(_on_settlement_repair_pressed)
	settlement_group.add_child(settlement_repair_button)
	settlement_refuel_button = Button.new()
	settlement_refuel_button.text = "Buy 2 fuel · 8 Ashmarks"
	settlement_refuel_button.pressed.connect(_on_settlement_refuel_pressed)
	settlement_group.add_child(settlement_refuel_button)
	settlement_hull_button = Button.new()
	settlement_hull_button.text = "Repair 2 hull · 10 Ashmarks"
	settlement_hull_button.pressed.connect(_on_settlement_hull_pressed)
	settlement_group.add_child(settlement_hull_button)
	final_journey_button = Button.new()
	final_journey_button.text = "Depart for Meridian Pass"
	final_journey_button.tooltip_text = "Begin the final Siege Beast encounter using the selected doctrine."
	final_journey_button.pressed.connect(_on_final_journey_pressed)
	settlement_group.add_child(final_journey_button)
	controls.add_child(settlement_group)

	var contract_group := VBoxContainer.new()
	contract_group.add_theme_constant_override("separation", 8)
	controls.add_child(contract_group)
	contract_title = Label.new()
	contract_title.text = "ASHGATE CONTRACT"
	contract_title.add_theme_font_size_override("font_size", 17)
	contract_title.add_theme_color_override("font_color", Color("#e8c58e"))
	contract_group.add_child(contract_title)
	contract_label = Label.new()
	contract_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contract_label.custom_minimum_size = Vector2(320, 54)
	contract_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	contract_group.add_child(contract_label)
	var contract_actions := HBoxContainer.new()
	contract_actions.add_theme_constant_override("separation", 8)
	contract_accept_button = Button.new()
	contract_accept_button.text = "Guard the convoy"
	contract_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_accept_button.pressed.connect(_on_guard_contract_pressed.bind(true))
	_accent_button(contract_accept_button, Color("#285348"), Color("#73c99b"))
	contract_actions.add_child(contract_accept_button)
	contract_decline_button = Button.new()
	contract_decline_button.text = "Travel unbound"
	contract_decline_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_decline_button.pressed.connect(_on_guard_contract_pressed.bind(false))
	contract_actions.add_child(contract_decline_button)
	contract_group.add_child(contract_actions)
	controls.move_child(contract_group, guidance_label.get_index() + 1)

	campaign_title = Label.new()
	campaign_title.text = "ASHGATE LOWLANDS MAP"
	campaign_title.add_theme_font_size_override("font_size", 17)
	campaign_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(campaign_title)
	campaign_pressure_label = Label.new()
	campaign_pressure_label.add_theme_color_override("font_color", Color("#e89270"))
	controls.add_child(campaign_pressure_label)
	campaign_path_label = Label.new()
	campaign_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_path_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(campaign_path_label)
	campaign_map = CampaignMapView.new()
	campaign_map.node_selected.connect(_on_campaign_node_selected)
	campaign_map.route_committed.connect(_on_campaign_route_committed)
	campaign_map.node_inspected.connect(_on_campaign_node_inspected)
	campaign_node_buttons = campaign_map.node_buttons
	campaign_commit_button = campaign_map.commit_button
	campaign_map.remove_child(campaign_commit_button)
	controls.add_child(campaign_commit_button)
	controls.move_child(campaign_commit_button, doctrine_detail_label.get_index() + 1)

	campaign_event_title = Label.new()
	campaign_event_title.add_theme_font_size_override("font_size", 17)
	campaign_event_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(campaign_event_title)
	campaign_event_label = Label.new()
	campaign_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_event_label.custom_minimum_size = Vector2(320, 52)
	campaign_event_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	controls.add_child(campaign_event_label)
	for index in range(3):
		var event_button := Button.new()
		event_button.text = "Node decision %d" % (index + 1)
		event_button.pressed.connect(_on_campaign_event_pressed.bind(index))
		campaign_event_buttons.append(event_button)
		controls.add_child(event_button)
	recruit_iven_button = Button.new()
	recruit_iven_button.text = "Recruit Iven Pell · 12 Ashmarks"
	recruit_iven_button.tooltip_text = "Requires restored relay and operational Crew Quarters. Iven reveals exact immediate threats and helps navigate storms."
	recruit_iven_button.pressed.connect(_on_recruit_iven_pressed)
	controls.add_child(recruit_iven_button)
	controls.add_child(campaign_map)

	route_option = OptionButton.new()
	for route_id in LongMarchState.ROUTES.keys():
		route_option.add_item(LongMarchState.ROUTES[route_id].name)
		route_option.set_item_metadata(route_option.item_count - 1, route_id)
	route_option.item_selected.connect(_on_departure_option_changed)
	route_group = _labeled_control("Route", route_option)
	controls.add_child(route_group)

	route_preview_label = Label.new()
	route_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_preview_label.custom_minimum_size = Vector2(320, 64)
	route_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(route_preview_label)
	controls.move_child(route_preview_label, campaign_map.get_index())

	travel_button = Button.new()
	travel_button.text = "Depart: Ashgate → Morrowline"
	travel_button.tooltip_text = "Pay the route cost and begin the deterministic City 1 → City 2 encounter."
	travel_button.pressed.connect(_on_travel_pressed)
	controls.add_child(travel_button)

	advance_encounter_button = Button.new()
	advance_encounter_button.text = "Advance journey battle"
	advance_encounter_button.tooltip_text = "Resolve one readable encounter step."
	advance_encounter_button.pressed.connect(_on_advance_encounter_pressed)
	_accent_button(advance_encounter_button, Color("#593e28"), Color("#e8c58e"))
	controls.add_child(advance_encounter_button)

	intervention_title = Label.new()
	intervention_title.text = "ENCOUNTER ORDER"
	intervention_title.add_theme_font_size_override("font_size", 17)
	intervention_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(intervention_title)
	intervention_help_label = Label.new()
	intervention_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intervention_help_label.add_theme_font_size_override("font_size", 11)
	intervention_help_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(intervention_help_label)
	for action in [
		{"id": "shift_power", "label": "Shift power · +weapon output / +heat", "tip": "Increase operational weapon damage by one, but add one heat."},
		{"id": "seal_compartment", "label": "Seal selected · protected / offline", "tip": "Prevent enemies from targeting the selected module, but disable it for this encounter."},
		{"id": "vent_heat", "label": "Vent heat · −3 heat / exposed exterior", "tip": "Remove three heat. The next hit against an exterior system deals one additional damage."},
		{"id": "cut_loose_cargo", "label": "Cut loose cargo · preserve mobility", "tip": "Discard a refuge, parts, or fuel cargo module to keep the fortress moving."}
	]:
		var intervention := Button.new()
		intervention.text = String(action.label)
		intervention.tooltip_text = String(action.tip)
		intervention.pressed.connect(_use_intervention.bind(String(action.id)))
		intervention_buttons.append(intervention)
		controls.add_child(intervention)

	save_button = Button.new()
	save_button.text = "Save prototype state"
	save_button.visible = false
	save_button.pressed.connect(_on_save_pressed)
	controls.add_child(save_button)
	load_button = Button.new()
	load_button.text = "Load prototype state"
	load_button.visible = false
	load_button.pressed.connect(_on_load_pressed)
	controls.add_child(load_button)

	var reset_button := Button.new()
	reset_button.text = "Reset run"
	reset_button.visible = false
	reset_button.pressed.connect(_on_reset_pressed)
	controls.add_child(reset_button)

	results_group = VBoxContainer.new()
	results_group.add_theme_constant_override("separation", 8)
	controls.add_child(results_group)
	var results_heading := Label.new()
	results_heading.text = "RUN COMPLETE"
	results_heading.add_theme_font_size_override("font_size", 17)
	results_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	results_group.add_child(results_heading)
	var results_summary_panel := PanelContainer.new()
	results_summary_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 12))
	results_group.add_child(results_summary_panel)
	var results_summary_stack := VBoxContainer.new()
	results_summary_stack.add_theme_constant_override("separation", 7)
	results_summary_panel.add_child(results_summary_stack)
	results_summary_label = Label.new()
	results_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_summary_label.add_theme_font_size_override("font_size", 14)
	results_summary_label.add_theme_color_override("font_color", Color("#d6dfdf"))
	results_summary_stack.add_child(results_summary_label)
	results_replay_label = Label.new()
	results_replay_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_replay_label.add_theme_font_size_override("font_size", 12)
	results_replay_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	results_summary_stack.add_child(results_replay_label)
	feedback_button = Button.new()
	feedback_button.text = "RECORD PLAYTEST NOTES"
	feedback_button.custom_minimum_size = Vector2(0, 50)
	feedback_button.pressed.connect(_show_feedback)
	_accent_button(feedback_button, Color("#285348"), Color("#73c99b"))
	results_group.add_child(feedback_button)
	var results_actions := HBoxContainer.new()
	results_actions.add_theme_constant_override("separation", 8)
	results_group.add_child(results_actions)
	play_again_button = Button.new()
	play_again_button.text = "PLAY AGAIN"
	play_again_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_again_button.pressed.connect(_on_play_again_pressed)
	results_actions.add_child(play_again_button)
	results_title_button = Button.new()
	results_title_button.text = "RETURN TO TITLE"
	results_title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	results_title_button.pressed.connect(_on_results_title_pressed)
	results_actions.add_child(results_title_button)
	feedback_button.focus_neighbor_top = feedback_button.get_path_to(play_again_button)
	feedback_button.focus_neighbor_bottom = feedback_button.get_path_to(play_again_button)
	play_again_button.focus_neighbor_top = play_again_button.get_path_to(feedback_button)
	play_again_button.focus_neighbor_right = play_again_button.get_path_to(results_title_button)
	play_again_button.focus_neighbor_bottom = play_again_button.get_path_to(feedback_button)
	results_title_button.focus_neighbor_top = results_title_button.get_path_to(feedback_button)
	results_title_button.focus_neighbor_left = results_title_button.get_path_to(play_again_button)
	results_title_button.focus_neighbor_bottom = results_title_button.get_path_to(feedback_button)
	_configure_focus_cycle([feedback_button, play_again_button, results_title_button])
	controls.move_child(results_group, guidance_label.get_index() + 1)

	how_to_play_button = Button.new()
	how_to_play_button.text = "OPEN FIELD BRIEFING"
	how_to_play_button.tooltip_text = "Review the four-part Marchmaster briefing without leaving this run."
	how_to_play_button.pressed.connect(_show_onboarding.bind(true))
	controls.add_child(how_to_play_button)

	_build_onboarding_overlay()
	_build_feedback_overlay()
	_connect_desk_focus_scrolling()

func _connect_desk_focus_scrolling() -> void:
	var controls: Array[Control] = [
		contract_accept_button,
		contract_decline_button,
		doctrine_option,
		campaign_commit_button,
		module_option,
		focus_chassis_button,
		rotate_button,
		remove_button,
		settlement_repair_button,
		settlement_refuel_button,
		settlement_hull_button,
		final_journey_button,
		recruit_iven_button,
		route_option,
		travel_button,
		advance_encounter_button,
		feedback_button,
		play_again_button,
		results_title_button,
		how_to_play_button
	]
	controls.append_array(campaign_event_buttons)
	controls.append_array(campaign_node_buttons)
	controls.append_array(intervention_buttons)
	for control in controls:
		control.focus_entered.connect(_on_desk_control_focused.bind(control))

func _on_desk_control_focused(control: Control) -> void:
	_scroll_action_context_into_view.call_deferred(control)

func _build_onboarding_overlay() -> void:
	onboarding_overlay = Control.new()
	onboarding_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	onboarding_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	onboarding_overlay.visible = false
	add_child(onboarding_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.04, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	onboarding_overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	onboarding_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 520)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#111a1ff7"), Color("#688587"), 2, 8, 0))
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "MARCHMASTER'S FIELD BRIEFING"
	eyebrow.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(eyebrow)
	var stepper := HBoxContainer.new()
	stepper.add_theme_constant_override("separation", 6)
	content.add_child(stepper)
	for step_label in ONBOARDING_LABELS:
		var step_panel := PanelContainer.new()
		step_panel.custom_minimum_size = Vector2(0, 38)
		step_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stepper.add_child(step_panel)
		var label := Label.new()
		label.text = String(step_label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		step_panel.add_child(label)
		onboarding_step_panels.append(step_panel)
		onboarding_step_labels.append(label)
	onboarding_title_label = Label.new()
	onboarding_title_label.add_theme_font_size_override("font_size", 28)
	onboarding_title_label.add_theme_color_override("font_color", Color("#e8c58e"))
	content.add_child(onboarding_title_label)
	onboarding_body_label = Label.new()
	onboarding_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	onboarding_body_label.custom_minimum_size = Vector2(650, 120)
	onboarding_body_label.add_theme_font_size_override("font_size", 17)
	onboarding_body_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	content.add_child(onboarding_body_label)
	var action_panel := PanelContainer.new()
	action_panel.add_theme_stylebox_override("panel", _flat_style(Color("#17292a"), Color("#5b8c83"), 1, 5, 12))
	content.add_child(action_panel)
	onboarding_action_label = Label.new()
	onboarding_action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	onboarding_action_label.custom_minimum_size = Vector2(620, 48)
	onboarding_action_label.add_theme_color_override("font_color", Color("#aee4cf"))
	action_panel.add_child(onboarding_action_label)
	onboarding_progress_label = Label.new()
	onboarding_progress_label.text = "D-pad / arrows or Tab move · A / Enter confirms · B / Esc skips"
	onboarding_progress_label.add_theme_color_override("font_color", Color("#8fa3a7"))
	content.add_child(onboarding_progress_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	onboarding_skip_button = Button.new()
	onboarding_skip_button.text = "Skip briefing"
	onboarding_skip_button.pressed.connect(_finish_onboarding.bind(true))
	actions.add_child(onboarding_skip_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	onboarding_back_button = Button.new()
	onboarding_back_button.text = "Previous"
	onboarding_back_button.pressed.connect(_on_onboarding_back)
	actions.add_child(onboarding_back_button)
	onboarding_next_button = Button.new()
	onboarding_next_button.text = "Next"
	onboarding_next_button.pressed.connect(_on_onboarding_next)
	actions.add_child(onboarding_next_button)
	content.add_child(actions)
	onboarding_skip_button.focus_neighbor_left = onboarding_skip_button.get_path_to(onboarding_next_button)
	onboarding_back_button.focus_neighbor_left = onboarding_back_button.get_path_to(onboarding_skip_button)
	onboarding_back_button.focus_neighbor_right = onboarding_back_button.get_path_to(onboarding_next_button)
	onboarding_next_button.focus_neighbor_right = onboarding_next_button.get_path_to(onboarding_skip_button)
	for button in [onboarding_skip_button, onboarding_back_button, onboarding_next_button]:
		button.focus_neighbor_top = button.get_path_to(button)
		button.focus_neighbor_bottom = button.get_path_to(button)

func _build_feedback_overlay() -> void:
	feedback_overlay = Control.new()
	feedback_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	feedback_overlay.visible = false
	add_child(feedback_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.04, 0.9)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 650)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	var title := Label.new()
	title.text = "PLAYTEST NOTES"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	content.add_child(title)
	var privacy := Label.new()
	privacy.text = "This journal stays on this computer. Nothing is uploaded. Saving creates a JSON file you can choose to share."
	privacy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	privacy.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(privacy)
	var clear_label := Label.new()
	clear_label.text = "What felt clear or satisfying?"
	content.add_child(clear_label)
	feedback_clear_text = TextEdit.new()
	feedback_clear_text.custom_minimum_size = Vector2(640, 110)
	feedback_clear_text.placeholder_text = "A decision, explanation, or moment that worked..."
	content.add_child(feedback_clear_text)
	var confusing_label := Label.new()
	confusing_label.text = "What felt confusing or frustrating?"
	content.add_child(confusing_label)
	feedback_confusing_text = TextEdit.new()
	feedback_confusing_text.custom_minimum_size = Vector2(640, 110)
	feedback_confusing_text.placeholder_text = "Where you hesitated, guessed, or lost the causal thread..."
	content.add_child(feedback_confusing_text)
	feedback_score_option = OptionButton.new()
	for label in ["1 — No", "2 — Probably not", "3 — Maybe", "4 — Probably", "5 — Definitely"]:
		feedback_score_option.add_item(label)
	feedback_score_option.select(2)
	content.add_child(_labeled_control("Would you play another run?", feedback_score_option))
	feedback_status_label = Label.new()
	feedback_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_status_label.add_theme_color_override("font_color", Color("#aab6ba"))
	content.add_child(feedback_status_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	feedback_close_button = Button.new()
	feedback_close_button.text = "BACK TO RESULTS"
	feedback_close_button.pressed.connect(_hide_feedback)
	actions.add_child(feedback_close_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	feedback_save_button = Button.new()
	feedback_save_button.text = "SAVE NOTES LOCALLY"
	feedback_save_button.pressed.connect(_save_feedback)
	actions.add_child(feedback_save_button)
	content.add_child(actions)
	feedback_close_button.focus_neighbor_left = feedback_close_button.get_path_to(feedback_save_button)
	feedback_close_button.focus_neighbor_right = feedback_close_button.get_path_to(feedback_save_button)
	feedback_save_button.focus_neighbor_left = feedback_save_button.get_path_to(feedback_close_button)
	feedback_save_button.focus_neighbor_right = feedback_save_button.get_path_to(feedback_close_button)
	feedback_clear_text.focus_neighbor_top = feedback_clear_text.get_path_to(feedback_save_button)
	feedback_clear_text.focus_neighbor_bottom = feedback_clear_text.get_path_to(feedback_confusing_text)
	feedback_confusing_text.focus_neighbor_top = feedback_confusing_text.get_path_to(feedback_clear_text)
	feedback_confusing_text.focus_neighbor_bottom = feedback_confusing_text.get_path_to(feedback_score_option)
	feedback_score_option.focus_neighbor_top = feedback_score_option.get_path_to(feedback_confusing_text)
	feedback_score_option.focus_neighbor_bottom = feedback_score_option.get_path_to(feedback_close_button)
	feedback_close_button.focus_neighbor_top = feedback_close_button.get_path_to(feedback_score_option)
	feedback_close_button.focus_neighbor_bottom = feedback_close_button.get_path_to(feedback_clear_text)
	feedback_save_button.focus_neighbor_top = feedback_save_button.get_path_to(feedback_score_option)
	feedback_save_button.focus_neighbor_bottom = feedback_save_button.get_path_to(feedback_clear_text)
	_configure_focus_cycle([feedback_clear_text, feedback_confusing_text, feedback_score_option, feedback_close_button, feedback_save_button])

func _show_onboarding(reopened: bool = false) -> void:
	onboarding_reopened = reopened
	onboarding_step = 0
	onboarding_overlay.visible = true
	_refresh_onboarding()
	onboarding_next_button.grab_focus()
	if reopened:
		_journal_event("onboarding_reopened")

func _refresh_onboarding() -> void:
	var step: Dictionary = ONBOARDING_STEPS[onboarding_step]
	onboarding_title_label.text = String(step.title)
	onboarding_body_label.text = String(step.body)
	onboarding_action_label.text = String(step.action)
	onboarding_progress_label.text = "Briefing %d of %d  ·  D-pad / arrows or Tab move  ·  A / Enter confirms  ·  B / Esc %s" % [onboarding_step + 1, ONBOARDING_STEPS.size(), "closes" if onboarding_reopened else "skips"]
	for index in range(onboarding_step_panels.size()):
		var panel := onboarding_step_panels[index]
		var label := onboarding_step_labels[index]
		if index < onboarding_step:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#183329"), Color("#4e8d72"), 1, 4, 3))
			label.text = "✓ %s" % ONBOARDING_LABELS[index]
			label.add_theme_color_override("font_color", Color("#9fddbd"))
		elif index == onboarding_step:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#4b405d"), Color("#eee2ff"), 2, 4, 2))
			label.text = "%02d %s" % [index + 1, ONBOARDING_LABELS[index]]
			label.add_theme_color_override("font_color", Color("#ffffff"))
		else:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#182127"), Color("#35474d"), 1, 4, 3))
			label.text = "— %s" % ONBOARDING_LABELS[index]
			label.add_theme_color_override("font_color", Color("#738286"))
	onboarding_back_button.disabled = onboarding_step == 0
	onboarding_skip_button.focus_neighbor_right = onboarding_skip_button.get_path_to(onboarding_next_button if onboarding_back_button.disabled else onboarding_back_button)
	onboarding_next_button.focus_neighbor_left = onboarding_next_button.get_path_to(onboarding_skip_button if onboarding_back_button.disabled else onboarding_back_button)
	var active_actions: Array = [onboarding_skip_button]
	if not onboarding_back_button.disabled:
		active_actions.append(onboarding_back_button)
	active_actions.append(onboarding_next_button)
	_configure_focus_cycle(active_actions)
	onboarding_next_button.text = ("RETURN TO MARCH" if onboarding_reopened else "ENTER ASHGATE") if onboarding_step == ONBOARDING_STEPS.size() - 1 else "NEXT"
	onboarding_skip_button.text = "CLOSE BRIEFING" if onboarding_reopened else "SKIP BRIEFING"

func _on_onboarding_back() -> void:
	onboarding_step = maxi(0, onboarding_step - 1)
	_refresh_onboarding()

func _on_onboarding_next() -> void:
	if onboarding_step >= ONBOARDING_STEPS.size() - 1:
		_finish_onboarding(false)
		return
	onboarding_step += 1
	_refresh_onboarding()

func _finish_onboarding(skipped: bool) -> void:
	var was_reopened := onboarding_reopened
	if not was_reopened:
		var marker := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
		if marker != null:
			marker.store_string(String(ProjectSettings.get_setting("application/config/version", "unknown")))
	onboarding_overlay.visible = false
	_journal_event("onboarding_closed" if was_reopened else ("onboarding_skipped" if skipped else "onboarding_completed"), {"step_reached": onboarding_step + 1})
	onboarding_reopened = false
	focus_current_action.call_deferred()

func _show_feedback() -> void:
	if not last_feedback_path.is_empty() and FileAccess.file_exists(last_feedback_path):
		feedback_status_label.text = "LAST SAVED LOCALLY · %s\nEdits can be saved as a fresh report." % last_feedback_path.get_file()
		feedback_status_label.tooltip_text = last_feedback_path
		feedback_save_button.text = "SAVE AGAIN"
	else:
		last_feedback_path = ""
		feedback_status_label.text = "Nothing is sent automatically. You can save again after editing."
		feedback_status_label.tooltip_text = ""
		feedback_save_button.text = "SAVE NOTES LOCALLY"
	feedback_overlay.visible = true
	feedback_clear_text.grab_focus()
	_journal_event("feedback_opened", {"phase": state.phase})

func _hide_feedback() -> void:
	feedback_overlay.visible = false
	_focus_control(feedback_button)

func _save_feedback() -> void:
	_journal_event("feedback_saved", {"phase": state.phase, "replay_score": feedback_score_option.selected + 1})
	var result: Dictionary = journal.export_feedback(
		feedback_clear_text.text,
		feedback_confusing_text.text,
		feedback_score_option.selected + 1,
		_state_journal_summary(),
		String(ProjectSettings.get_setting("application/config/version", "unknown"))
	)
	if bool(result.get("ok", false)):
		last_feedback_path = String(result.get("path", ""))
		feedback_status_label.text = "SAVED LOCALLY · %s\nBuild %s is included in the report." % [last_feedback_path.get_file(), String(ProjectSettings.get_setting("application/config/version", "unknown"))]
		feedback_status_label.tooltip_text = last_feedback_path
		feedback_save_button.text = "SAVE AGAIN"
		feedback_save_button.grab_focus()
	else:
		last_feedback_path = ""
		feedback_status_label.tooltip_text = ""
		feedback_status_label.text = "Could not save feedback: %s" % String(result.get("reason", "unknown error"))

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if feedback_overlay.visible:
		_hide_feedback()
		get_viewport().set_input_as_handled()
	elif onboarding_overlay.visible:
		_finish_onboarding(true)
		get_viewport().set_input_as_handled()
	elif not selected_campaign_node_id.is_empty():
		var previous_selection := selected_campaign_node_id
		selected_campaign_node_id = ""
		_set_event("Route selection cleared. Choose another road when ready.")
		_refresh_ui()
		var previous_button := campaign_map.button_for(previous_selection) as Button
		if previous_button != null and not previous_button.disabled:
			_focus_control(previous_button)
		get_viewport().set_input_as_handled()

func _journal_event(event_id: String, properties: Dictionary = {}) -> void:
	if journal != null:
		journal.record(event_id, properties)

func _checkpoint(reason: String) -> void:
	checkpoint_reached.emit(reason)

func _state_journal_summary() -> Dictionary:
	var dependencies := state.dependency_summary()
	return {
		"phase": state.phase,
		"day": state.day,
		"fuel": state.fuel,
		"money": state.money,
		"hull": state.hull_condition,
		"route": state.journey_route,
		"doctrine": state.target_doctrine,
		"result": state.final_result,
		"campaign_encounters": state.campaign_encounters_completed,
		"campaign_pressure": state.campaign_pressure,
		"contract": state.guard_contract_status,
		"settlement_trust": state.settlement_trust,
		"specialist": state.specialist_id,
		"ready_systems": int(dependencies.get("ready", 0)),
		"strained_systems": int(dependencies.get("strained", 0)),
		"offline_systems": int(dependencies.get("offline", 0))
	}

func _labeled_control(label_text: String, control: Control) -> VBoxContainer:
	var group := VBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#aab6ba"))
	group.add_child(label)
	group.add_child(control)
	return group

func _selected_id(option: OptionButton) -> String:
	if option.selected < 0:
		return ""
	return String(option.get_item_metadata(option.selected))

func _control_can_receive_focus(control: Control) -> bool:
	if control == null or not is_instance_valid(control) or not control.is_visible_in_tree() or control.focus_mode == Control.FOCUS_NONE:
		return false
	if control is BaseButton and control.disabled:
		return false
	return true

func _focus_control(control: Control) -> bool:
	if not _control_can_receive_focus(control):
		return false
	control.grab_focus()
	return true

func _scroll_action_context_into_view(control: Control) -> void:
	await get_tree().process_frame
	if not _control_can_receive_focus(control) or not control.has_focus() or right_scroll == null or not right_scroll.is_ancestor_of(control):
		return
	var viewport_rect := right_scroll.get_global_rect()
	var previous_scroll := right_scroll.scroll_vertical
	var guidance_rect := guidance_label.get_global_rect()
	var control_rect := control.get_global_rect()
	var guidance_top := guidance_rect.position.y - viewport_rect.position.y + previous_scroll
	var control_bottom := control_rect.end.y - viewport_rect.position.y + previous_scroll
	var context_height := control_bottom - guidance_top
	right_scroll.scroll_vertical = 0
	if control_bottom <= viewport_rect.size.y - 8.0:
		return
	if context_height <= viewport_rect.size.y - 16.0:
		right_scroll.scroll_vertical = maxi(0, ceili(guidance_top - 8.0))
	else:
		right_scroll.scroll_vertical = maxi(0, ceili(control_bottom - viewport_rect.size.y + 8.0))

func focus_current_action() -> void:
	if onboarding_overlay != null and onboarding_overlay.visible:
		_focus_control(onboarding_next_button)
		return
	if feedback_overlay != null and feedback_overlay.visible:
		_focus_control(feedback_clear_text)
		return
	if _focus_control(contract_accept_button):
		return
	for button in campaign_event_buttons:
		if _focus_control(button):
			return
	if state.phase in ["battle", "final_battle"] and _focus_control(advance_encounter_button):
		return
	if _focus_control(campaign_commit_button):
		return
	if state.phase == "settlement":
		for button in [settlement_repair_button, settlement_refuel_button, settlement_hull_button]:
			if _focus_control(button):
				return
	for button in campaign_node_buttons:
		if _focus_control(button):
			return
	if state.phase == "results" and _focus_control(feedback_button):
		return
	_focus_control(travel_button)

func _ensure_current_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if not _control_can_receive_focus(focus_owner):
		focus_current_action.call_deferred()

func _on_departure_option_changed(_index: int) -> void:
	_refresh_ui()

func _on_guard_contract_pressed(accept: bool) -> void:
	var result := state.choose_guard_contract(accept)
	if bool(result.get("ok", false)):
		_set_event("Accepted the Morrowline Parts Guard contract." if accept else "Declined the guard contract. The fortress will travel without the convoy obligation.")
		_journal_event("guard_contract_answered", {"accepted": accept})
		_checkpoint("contract_answered")
	else:
		_set_event("Contract choice blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()
	if bool(result.get("ok", false)):
		focus_current_action.call_deferred()

func _on_campaign_node_pressed(index: int) -> void:
	if index < 0 or index >= campaign_node_buttons.size():
		return
	var node_id := String(campaign_node_buttons[index].get_meta("node_id", ""))
	_on_campaign_node_selected(node_id)

func _on_campaign_node_selected(node_id: String) -> void:
	if node_id.is_empty():
		return
	if node_id not in state.campaign_available_nodes():
		_set_event("That route is not currently available.")
		return
	selected_campaign_node_id = node_id
	var preview := state.campaign_node_preview(node_id, _selected_id(doctrine_option))
	_set_event("Route selected: %s. Review its costs and forecast, then commit when ready." % String(preview.get("name", node_id)))
	_refresh_ui()
	_focus_control(campaign_commit_button)

func _on_campaign_node_inspected(node_id: String, detail: String) -> void:
	if not campaign_map.visible:
		return
	var node_name := String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id))
	_set_route_preview("ROUTE INTEL · %s\n%s" % [node_name.to_upper(), detail], campaign_map.intel_tone_for(node_id))

func _set_route_preview(text: String, tone: String = "neutral") -> void:
	route_preview_label.text = text
	route_preview_label.add_theme_color_override("font_color", ROUTE_INTEL_COLORS.get(tone, ROUTE_INTEL_COLORS.neutral))

func _on_campaign_route_committed(node_id: String) -> void:
	if node_id.is_empty() or node_id != selected_campaign_node_id:
		_set_event("Select a route before committing the fortress.")
		return
	var doctrine := _selected_id(doctrine_option)
	var result := state.begin_campaign_route(node_id, doctrine)
	if bool(result.get("ok", false)):
		selected_campaign_node_id = ""
		_set_event("Departed for %s. Forecast: %s." % [String(LongMarchState.CAMPAIGN_NODES[node_id].name), ", ".join(result.get("forecast", {}).get("threats", []))])
		_journal_event("campaign_node_started", {"node": node_id, "doctrine": doctrine, "pressure": state.campaign_pressure})
		_checkpoint("route_started")
	else:
		_set_event("Route blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_campaign_event_pressed(index: int) -> void:
	if index < 0 or index >= campaign_event_buttons.size():
		return
	var choice_id := String(campaign_event_buttons[index].get_meta("choice_id", ""))
	if choice_id.is_empty():
		return
	var result := state.resolve_campaign_event(choice_id)
	if bool(result.get("ok", false)):
		var result_message := String(result.get("message", "Decision recorded: %s." % choice_id.replace("_", " ").capitalize()))
		_set_event(result_message)
		_journal_event("campaign_event_resolved", {"event": String(result.get("event", "")), "choice": choice_id})
		_checkpoint("event_resolved")
	else:
		_set_event("Decision blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()
	if bool(result.get("ok", false)):
		encounter_label.text = "DECISION CONSEQUENCE\n%s" % String(result.get("message", "Decision recorded."))

func _on_recruit_iven_pressed() -> void:
	var result := state.recruit_iven_pell()
	if bool(result.get("ok", false)):
		_set_event("Iven Pell joins the fortress as signal officer.")
		_journal_event("specialist_recruited", {"specialist": "iven_pell"})
		_checkpoint("specialist_recruited")
	else:
		_set_event("Recruitment blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_module_selected(index: int) -> void:
	selected_module_id = String(module_option.get_item_metadata(index))
	_sync_selected_module_context()
	var module_name := String(state.module_definition(selected_module_id).get("name", selected_module_id))
	if selected_module_cell.x >= 0:
		_set_event("Selected %s on the chassis for inspection or refitting." % module_name)
	elif state.stored_module_count(selected_module_id) > 0:
		_set_event("Selected stored %s. Choose an empty chassis cell to install it." % module_name)
	else:
		_set_event("%s is no longer available in this run." % module_name)
	_refresh_ui()

func _focus_chassis_for_refit() -> void:
	if not state.can_refit():
		return
	if selected_module_cell.x >= 0:
		fortress_panel.cursor_cell = selected_module_cell
	fortress_panel.queue_redraw()
	fortress_panel.grab_focus()

func _on_fortress_focus_exit_requested() -> void:
	if _control_can_receive_focus(focus_chassis_button):
		_focus_control(focus_chassis_button)

func _scroll_chassis_into_view() -> void:
	await get_tree().process_frame
	if not fortress_panel.has_focus() or left_scroll == null or not left_scroll.is_ancestor_of(fortress_panel):
		return
	var viewport_rect := left_scroll.get_global_rect()
	var previous_scroll := left_scroll.scroll_vertical
	var panel_rect := fortress_panel.get_global_rect()
	var panel_top := panel_rect.position.y - viewport_rect.position.y + previous_scroll
	var panel_bottom := panel_rect.end.y - viewport_rect.position.y + previous_scroll
	if panel_top >= 8.0 and panel_bottom <= viewport_rect.size.y - 8.0:
		return
	if panel_rect.size.y <= viewport_rect.size.y - 16.0:
		left_scroll.scroll_vertical = maxi(0, ceili(panel_bottom - viewport_rect.size.y + 8.0))
	else:
		left_scroll.scroll_vertical = maxi(0, ceili(panel_top - 8.0))

func _sync_selected_module_context() -> void:
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false
	for instance in state.modules:
		if String(instance.get("id", "")) == selected_module_id:
			selected_module_cell = Vector2i(instance.get("position", Vector2i(-1, -1)))
			placement_rotated = bool(instance.get("rotated", false))
			break

func _select_module_option(module_id: String) -> void:
	for index in range(module_option.item_count):
		if String(module_option.get_item_metadata(index)) == module_id:
			module_option.select(index)
			return

func _refresh_module_options() -> void:
	var selected_is_available := false
	var fallback_index := -1
	for index in range(module_option.item_count):
		var module_id := String(module_option.get_item_metadata(index))
		var definition := state.module_definition(module_id)
		var instance: Dictionary = {}
		var location := "LOST"
		for installed in state.modules:
			if String(installed.get("id", "")) == module_id:
				instance = installed
				location = "ON CHASSIS"
				break
		if instance.is_empty():
			for stored in state.stored_modules:
				if String(stored.get("id", "")) == module_id:
					instance = stored
					location = "STORED"
					break
		var available := not instance.is_empty()
		module_option.set_item_disabled(index, not available)
		if available and fallback_index < 0:
			fallback_index = index
		if module_id == selected_module_id:
			selected_is_available = available
		if available:
			var maximum := int(definition.get("durability", 1))
			var durability := int(instance.get("durability", maximum))
			module_option.set_item_text(index, "%s · %s · %d/%d" % [String(definition.get("name", module_id)), location, durability, maximum])
		else:
			module_option.set_item_text(index, "%s · LOST" % String(definition.get("name", module_id)))
	if not selected_is_available and fallback_index >= 0:
		module_option.select(fallback_index)
		selected_module_id = String(module_option.get_item_metadata(fallback_index))
		_sync_selected_module_context()

func _module_requires_exterior(module_id: String) -> bool:
	return "exterior" in state.module_definition(module_id).get("tags", [])

func _selected_installed_module() -> Dictionary:
	if selected_module_cell.x < 0 or selected_module_cell.y < 0:
		return {}
	return state.module_at(selected_module_cell)

func _campaign_departure_block_reason(node_id: String) -> String:
	if node_id.is_empty():
		return ""
	if not (state.operational("steam_lance_engine") or state.operational("ash_runner_engine")):
		return "Restore a fuel-connected engine"
	var preview := state.campaign_node_preview(node_id, _selected_id(doctrine_option))
	var fuel_required := int(preview.get("fuel", 0))
	if state.fuel < fuel_required:
		return "Need %d fuel · %d available" % [fuel_required, state.fuel]
	return ""

func _on_grid_cell_pressed(cell: Vector2i) -> void:
	var clicked := state.module_at(cell)
	if not clicked.is_empty():
		selected_module_id = String(clicked.get("id", ""))
		selected_module_cell = Vector2i(clicked.get("position", cell))
		placement_rotated = bool(clicked.get("rotated", false))
		_select_module_option(selected_module_id)
		_set_event("Selected %s for inspection%s." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), " and refitting" if state.can_refit() else " or an encounter order"])
		_refresh_ui()
		return
	if not state.can_refit():
		_set_event("Refit is locked while the fortress is on the road. Select an installed module to inspect or seal it.")
		return
	var selected_installed := _selected_installed_module()
	var result: Dictionary
	if not selected_installed.is_empty():
		result = state.reposition_module_at(selected_module_cell, cell, placement_rotated)
		if bool(result.get("ok", false)):
			selected_module_cell = cell
			_set_event("Moved %s to cell %d,%d." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), cell.x + 1, cell.y + 1])
			_journal_event("module_moved", {"module": selected_module_id, "x": cell.x, "y": cell.y, "rotated": placement_rotated})
			_checkpoint("module_moved")
		else:
			_set_event("Move blocked: %s." % String(result.get("reason", "unknown")))
	else:
		if state.module_count(selected_module_id) > 0:
			_set_event("That module is already installed. Select it on the chassis to move or remove it.")
			return
		result = state.deploy_stored_module(selected_module_id, cell, placement_rotated)
		if bool(result.get("ok", false)):
			selected_module_cell = cell
			_set_event("Installed %s at cell %d,%d." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), cell.x + 1, cell.y + 1])
			_journal_event("module_installed", {"module": selected_module_id, "x": cell.x, "y": cell.y, "rotated": placement_rotated})
			_checkpoint("module_installed")
		else:
			_set_event("Placement blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_rotate_pressed() -> void:
	if not state.can_refit():
		_set_event("Rotation is only available while refitting at a settlement.")
		return
	var base_shape := state.module_shape(selected_module_id, false)
	if base_shape.x == base_shape.y:
		_set_event("%s has a square footprint, so rotation does not change its placement." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		return
	var next_rotation := not placement_rotated
	var selected_installed := _selected_installed_module()
	if selected_installed.is_empty():
		placement_rotated = next_rotation
		_set_event("Placement footprint rotated. Choose a chassis cell.")
	else:
		var origin := Vector2i(selected_installed.get("position", selected_module_cell))
		var result := state.reposition_module_at(selected_module_cell, origin, next_rotation)
		if not bool(result.get("ok", false)):
			_set_event("Rotation blocked: %s." % String(result.get("reason", "unknown")))
		else:
			placement_rotated = next_rotation
			selected_module_cell = origin
			_set_event("Rotated %s in place." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
			_journal_event("module_rotated", {"module": selected_module_id, "rotated": placement_rotated})
			_checkpoint("module_rotated")
	_refresh_ui()

func _on_remove_pressed() -> void:
	if not state.can_refit():
		_set_event("Removal is only available while refitting at a settlement.")
		return
	var selected_installed := _selected_installed_module()
	if selected_installed.is_empty():
		_set_event("Select an installed module on the chassis before removing it.")
		return
	var result := state.remove_module_at(selected_module_cell)
	if bool(result.get("ok", false)):
		var removed: Dictionary = result.get("module", {})
		selected_module_id = String(removed.get("id", selected_module_id))
		placement_rotated = bool(removed.get("rotated", false))
		selected_module_cell = Vector2i(-1, -1)
		_set_event("Removed %s. Click an empty cell to place it again." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		_journal_event("module_stored", {"module": selected_module_id, "durability": int(removed.get("durability", 0))})
		_checkpoint("module_stored")
	else:
		_set_event("Removal blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_travel_pressed() -> void:
	var route_id := _selected_id(route_option)
	var result := state.begin_journey(route_id, _selected_id(doctrine_option))
	if not bool(result.get("ok", false)):
		_set_event("Departure blocked: %s." % String(result.get("reason", "unknown")))
	else:
		_set_event("Journey begun. Forecast: %s. Advance one battle step at a time." % ", ".join(result.get("forecast", {}).get("threats", [])))
		_journal_event("route_started", {"route": route_id, "doctrine": _selected_id(doctrine_option), "risk": state.current_route_risk, "pressure": state.encounter_pressure})
	_refresh_ui()

func _on_advance_encounter_pressed() -> void:
	var result := state.advance_encounter(1.0)
	if not bool(result.get("ok", false)):
		_set_event("Journey battle blocked: %s." % String(result.get("reason", "unknown")))
	elif bool(result.get("resolved", false)):
		_set_event("Journey battle resolved: %s." % String(result.get("outcome", "unknown")).replace("_", " ").capitalize())
		_journal_event("encounter_resolved", {"leg": state.journey_leg, "outcome": state.encounter_outcome, "phase": state.phase})
		if state.phase == "results" and not result_recorded:
			result_recorded = true
			_journal_event("run_completed", _state_journal_summary())
	else:
		_set_event("Journey battle step %d resolved. Inspect the target before intervening." % int(result.get("step", 0)))
		_journal_event("encounter_step", {"leg": state.journey_leg, "step": state.encounter_step, "hull": state.hull_condition})
	if bool(result.get("ok", false)):
		_checkpoint("encounter_advanced")
	_refresh_ui()

func _on_settlement_repair_pressed() -> void:
	var selected := _selected_installed_module()
	if selected.is_empty():
		_set_event("Select a damaged module on the chassis before requesting a Morrowline repair.")
		encounter_label.text = "SERVICE UNAVAILABLE\nSelect a damaged chassis module first."
		return
	var result := state.settlement_repair(String(selected.get("id", "")))
	var service_message := "%s restored +%d durability for %d Ashmarks. %s remains." % [String(state.module_definition(String(selected.get("id", ""))).get("name", "Module")), int(result.get("restored", 0)), int(result.get("cost", 0)), _service_action_count_text()] if bool(result.get("ok", false)) else "Repair blocked: %s." % String(result.get("reason", "unknown"))
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "module_repair", "module": String(selected.get("id", "")), "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_settlement_refuel_pressed() -> void:
	var result := state.settlement_refuel()
	var service_message := "+2 fuel loaded for %d Ashmarks. %s remains." % [int(result.get("cost", 0)), _service_action_count_text()] if bool(result.get("ok", false)) else "Refuel blocked: %s." % String(result.get("reason", "unknown"))
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "refuel", "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_settlement_hull_pressed() -> void:
	var result := state.settlement_repair_hull()
	var service_message := "+%d hull restored for %d Ashmarks. %s remains." % [int(result.get("hull_added", 0)), int(result.get("cost", 0)), _service_action_count_text()] if bool(result.get("ok", false)) else "Hull repair blocked: %s." % String(result.get("reason", "unknown"))
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "hull_repair", "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_final_journey_pressed() -> void:
	var result := state.begin_final_journey(_selected_id(doctrine_option))
	if bool(result.get("ok", false)):
		_set_event("Final march begun. The Siege Beast is blocking Meridian Pass.")
		_journal_event("final_march_started", {"doctrine": _selected_id(doctrine_option), "fuel": state.fuel, "hull": state.hull_condition})
	else:
		_set_event("Final march blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _use_intervention(intervention_id: String, target_module: String = "") -> void:
	if intervention_id == "seal_compartment":
		var selected := _selected_installed_module()
		if selected.is_empty():
			_set_event("Select a module on the chassis before issuing Seal Compartment.")
			return
		target_module = String(selected.get("id", ""))
	var result := state.use_encounter_intervention(intervention_id, target_module)
	if not result.ok:
		_set_event("Intervention blocked: %s." % result.reason)
	else:
		var intervention_result := intervention_id.replace("_", " ").capitalize()
		if intervention_id == "cut_loose_cargo":
			var removed_module := String(result.get("removed_module", "cargo"))
			intervention_result += " — %s discarded" % String(state.module_definition(removed_module).get("name", removed_module)).capitalize()
		_set_event("Intervention used: %s." % intervention_result)
		_journal_event("intervention_used", {"intervention": intervention_id, "target": target_module, "leg": state.journey_leg})
		_checkpoint("intervention_used")
	_refresh_ui()

func save_run(silent: bool = false) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_set_event("Save failed: %s." % error_string(FileAccess.get_open_error()))
		return false
	var payload := state.serialize()
	payload["build_version"] = String(ProjectSettings.get_setting("application/config/version", "unknown"))
	payload["saved_at_unix"] = int(Time.get_unix_time_from_system())
	file.store_string(JSON.stringify(payload))
	if not silent:
		_set_event("Prototype state saved with schema version %d." % LongMarchState.SAVE_VERSION)
		_journal_event("run_saved", {"phase": state.phase, "day": state.day})
		_refresh_ui()
	return true

func _on_save_pressed() -> void:
	save_run()

func load_saved_run() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		_set_event("No prototype save exists yet.")
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_set_event("Load failed: %s." % error_string(FileAccess.get_open_error()))
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_set_event("Load failed: save data is not valid JSON state.")
		return false
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(parsed)
	if not bool(result.get("ok", false)):
		_set_event("Load failed: %s." % String(result.get("reason", "unknown")))
		return false
	state = restored
	selected_campaign_node_id = ""
	selected_module_cell = Vector2i(-1, -1)
	if not state.modules.is_empty():
		selected_module_id = String(state.modules[0].get("id", selected_module_id))
		selected_module_cell = Vector2i(state.modules[0].get("position", Vector2i.ZERO))
		placement_rotated = bool(state.modules[0].get("rotated", false))
		_select_module_option(selected_module_id)
	fortress_panel.state = state
	_set_event("Prototype state loaded.")
	result_recorded = state.phase == "results"
	_journal_event("run_loaded", {"phase": state.phase, "day": state.day})
	_refresh_ui()
	return true

func _on_load_pressed() -> void:
	load_saved_run()

func _on_reset_pressed() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("The fortress is back at Ashgate Depot with a clean maintenance slate.")
	_journal_event("run_reset")
	_refresh_ui()

func _on_play_again_pressed() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("A new Ashgate march is ready. Answer the contract, inspect the chassis, and choose the first road.")
	_journal_event("run_restarted_from_results")
	_refresh_ui()
	focus_current_action.call_deferred()

func _on_results_title_pressed() -> void:
	_journal_event("return_to_title", {"phase": state.phase, "result": state.final_result})
	return_to_title_requested.emit()

func _set_event(text: String) -> void:
	event_label.text = text

func _refresh_campaign_controls() -> void:
	var planning_phase := state.phase in ["refit", "map", "settlement"]
	campaign_title.visible = state.campaign_active and planning_phase
	campaign_pressure_label.visible = state.campaign_active
	campaign_path_label.visible = state.campaign_active
	campaign_map.visible = state.campaign_active and planning_phase
	campaign_pressure_label.text = "Blockade — %s · pressure %d · encounters %d/5" % [state.campaign_pressure_band().capitalize(), state.campaign_pressure, state.campaign_encounters_completed]
	campaign_path_label.text = "Guard contract: %s · Specialist: %s" % [state.guard_contract_status.replace("_", " ").capitalize(), "Iven Pell" if state.specialist_id == "iven_pell" else "none"]

	var contract_offered := state.campaign_active and state.guard_contract_status == "offered" and state.current_location == "ashgate_depot"
	contract_title.visible = contract_offered
	contract_label.visible = contract_offered
	contract_accept_button.visible = contract_offered
	contract_decline_button.visible = contract_offered
	contract_label.text = "Morrowline needs its parts wagon guarded. Accepting adds pressure to the camp approach, then pays 30 Ashmarks and 2 trust if the convoy arrives."

	var options := state.campaign_available_nodes()
	if selected_campaign_node_id not in options or contract_offered or not state.campaign_event_pending.is_empty():
		selected_campaign_node_id = ""
	var state_summary := state.summary()
	var movement_ready := state.operational("steam_lance_engine") or state.operational("ash_runner_engine")
	var phase_can_depart := movement_ready
	if state.phase == "refit":
		phase_can_depart = bool(state_summary.can_travel)
	elif state.phase == "settlement":
		phase_can_depart = bool(state_summary.can_continue)
	var previews := {}
	for node_id in options:
		previews[node_id] = state.campaign_node_preview(node_id, _selected_id(doctrine_option))
	var departure_block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
	var outgoing_nodes: Array[String] = []
	var closed_nodes: Array[String] = []
	for raw_node_id in LongMarchState.CAMPAIGN_EDGES.get(state.current_location, []):
		var node_id := String(raw_node_id)
		outgoing_nodes.append(node_id)
		if state.campaign_node_closed(node_id):
			closed_nodes.append(node_id)
	campaign_map.configure({
		"edges": LongMarchState.CAMPAIGN_EDGES,
		"current_node": state.current_location,
		"secured_path": state.campaign_path,
		"available_nodes": options,
		"closed_nodes": closed_nodes,
		"outgoing_nodes": outgoing_nodes,
		"selected_node": selected_campaign_node_id,
		"previews": previews,
		"can_depart": phase_can_depart,
		"departure_block_reason": departure_block_reason,
		"heat_limit": LongMarchState.BASE_HEAT_LIMIT,
		"show_commit": state.campaign_active and planning_phase,
		"interaction_blocked": contract_offered or not state.campaign_event_pending.is_empty()
	})

	var event := state.campaign_event_details()
	var event_pending := not event.is_empty()
	campaign_event_title.visible = event_pending
	campaign_event_label.visible = event_pending
	if event_pending:
		campaign_event_title.text = String(event.title).to_upper()
		campaign_event_label.text = String(event.body)
	var choices: Array = event.get("choices", [])
	for index in range(campaign_event_buttons.size()):
		var button := campaign_event_buttons[index]
		if not event_pending or index >= choices.size():
			button.visible = false
			button.set_meta("choice_id", "")
			continue
		var choice: Dictionary = choices[index]
		button.visible = true
		var choice_enabled := bool(choice.get("enabled", false))
		var locked_reason := String(choice.get("reason", ""))
		button.text = String(choice.label) if choice_enabled else "%s\nLOCKED · %s" % [String(choice.label), locked_reason.to_upper()]
		button.tooltip_text = "" if choice_enabled else locked_reason
		button.custom_minimum_size = Vector2(0, 42 if choice_enabled else 56)
		button.disabled = not choice_enabled
		button.set_meta("choice_id", String(choice.id))

	var recruit_status := state.iven_recruitment_status()
	recruit_iven_button.visible = state.campaign_active and state.current_location == "broken_relay" and state.phase == "map" and state.specialist_id.is_empty() and state.campaign_event_pending.is_empty()
	var can_recruit_iven := bool(recruit_status.get("available", false))
	var recruit_reason := String(recruit_status.get("reason", ""))
	recruit_iven_button.disabled = not can_recruit_iven
	recruit_iven_button.text = "RECRUIT IVEN PELL · 12 ASHMARKS" if can_recruit_iven else "IVEN PELL UNAVAILABLE\n%s" % recruit_reason.to_upper()
	recruit_iven_button.custom_minimum_size = Vector2(0, 44 if can_recruit_iven else 56)
	recruit_iven_button.tooltip_text = "Adds exact immediate threat forecasts and storm navigation." if can_recruit_iven else recruit_reason

func _refresh_ui() -> void:
	_refresh_module_options()
	var snapshot := state.summary()
	var selected_definition := state.module_definition(selected_module_id)
	var selected_shape := state.module_shape(selected_module_id, placement_rotated)
	var selected_installed := _selected_installed_module()
	_refresh_campaign_controls()
	var mount_text := "Exterior mount" if _module_requires_exterior(selected_module_id) else "Interior chassis"
	if state.can_refit():
		var dependency_text := "Place it to evaluate dependencies."
		if not selected_installed.is_empty():
			var dependency := state.dependency_status(selected_installed)
			var reasons: Array = dependency.get("reasons", [])
			dependency_text = "%s%s" % [String(dependency.get("state", "offline")).capitalize(), ": " + String(reasons[0]) if not reasons.is_empty() else "."]
		refit_label.text = "%s · %dx%d · %s. %s %s" % [
			String(selected_definition.get("name", "Select a module")),
			selected_shape.x,
			selected_shape.y,
			mount_text,
			"Selected on chassis; choose an empty cell to move it." if not selected_installed.is_empty() else "Choose an empty cell to place it.",
			dependency_text
		]
	else:
		refit_label.text = "Refit locked during the journey. The current chassis remains visible for battle inspection."
	module_option.disabled = not state.can_refit()
	focus_chassis_button.disabled = not state.can_refit()
	rotate_button.disabled = not state.can_refit()
	remove_button.disabled = not state.can_refit() or selected_installed.is_empty()
	var is_refit_phase := state.phase in ["refit", "settlement"]
	var is_battle_phase := state.phase in ["battle", "final_battle"]
	subtitle_label.visible = not is_battle_phase
	journey_banner.visible = not is_battle_phase
	asset_row.visible = state.phase in ["refit", "battle", "final_battle"]
	_refresh_run_flow_tracker()
	results_group.visible = state.phase == "results"
	if state.phase == "results":
		results_summary_label.text = _result_summary_text()
		results_replay_label.text = _result_replay_text()
	guidance_label.text = _current_guidance()
	phase_badge.text = "PHASE · %s" % state.phase.replace("_", " ").to_upper()
	refit_title.visible = is_refit_phase
	module_group.visible = is_refit_phase
	focus_chassis_button.visible = is_refit_phase
	refit_actions.visible = is_refit_phase
	refit_label.visible = is_refit_phase
	route_group.visible = state.phase == "refit" and not state.campaign_active
	doctrine_group.visible = state.phase in ["refit", "map", "settlement"]
	doctrine_detail_label.visible = doctrine_group.visible
	var selected_doctrine := _selected_id(doctrine_option)
	doctrine_detail_label.text = String(DOCTRINE_DESCRIPTIONS.get(selected_doctrine, "Choose how the fortress protects itself on the next road."))
	doctrine_detail_label.add_theme_color_override("font_color", Color("#e8c58e") if selected_doctrine == "run_hot" else Color("#aab6ba"))
	if selected_doctrine == "run_hot":
		var predicted_doctrine_heat := state.total_heat() + 2
		if predicted_doctrine_heat > LongMarchState.BASE_HEAT_LIMIT:
			doctrine_detail_label.text = "OVERHEAT WARNING · Predicted heat %d/%d. %s" % [predicted_doctrine_heat, LongMarchState.BASE_HEAT_LIMIT, doctrine_detail_label.text]
			doctrine_detail_label.add_theme_color_override("font_color", Color("#ef8375"))
	route_option.disabled = state.phase != "refit"
	doctrine_option.disabled = state.phase in ["battle", "final_battle", "results"]
	travel_button.visible = state.phase == "refit" and not state.campaign_active
	travel_button.disabled = state.phase != "refit"
	combat_panel.visible = is_battle_phase
	encounter_label.visible = not is_battle_phase
	advance_encounter_button.visible = is_battle_phase
	advance_encounter_button.disabled = not state.encounter_active
	if is_battle_phase:
		advance_encounter_button.text = "ADVANCE · RESOLVE STEP %d OF 6" % mini(state.encounter_step + 1, 6)
	intervention_title.visible = is_battle_phase
	intervention_help_label.visible = is_battle_phase
	intervention_title.text = "ENCOUNTER ORDER · %s" % ("SPENT" if state.encounter_intervention_used else "1 AVAILABLE")
	intervention_help_label.text = "Choose once per encounter. Seal target: %s." % (String(selected_definition.get("name", selected_module_id)) if not selected_installed.is_empty() else "select a chassis module first")
	for index in range(intervention_buttons.size()):
		intervention_buttons[index].visible = is_battle_phase
		intervention_buttons[index].disabled = not state.encounter_active or state.encounter_intervention_used or (index == 1 and selected_installed.is_empty()) or (index == 3 and state.sacrificable_cargo_id().is_empty())
	if intervention_buttons.size() >= 4:
		intervention_buttons[1].text = "Seal %s · protected / offline" % (String(selected_definition.get("name", "selected")) if not selected_installed.is_empty() else "selected module")
		var cargo_id := state.sacrificable_cargo_id()
		if cargo_id.is_empty():
			intervention_buttons[3].text = "Cut loose cargo · none available"
			intervention_buttons[3].tooltip_text = "No installed cargo module can be sacrificed."
		else:
			var cargo_definition := state.module_definition(cargo_id)
			var cargo_tags: Array = cargo_definition.get("tags", [])
			var cargo_cost := "lose shelter" if "refuge" in cargo_tags else ("lose repair supply" if "parts" in cargo_tags else ("lose fuel feed" if "fuel" in cargo_tags else "lose module"))
			intervention_buttons[3].text = "Cut loose %s · %s" % [String(cargo_definition.get("name", cargo_id)), cargo_cost]
			intervention_buttons[3].tooltip_text = "Permanently remove this installed module for the rest of the run to reduce mass and enemy cargo incentive."
	if is_battle_phase:
		var combat_actions: Array = [advance_encounter_button]
		for intervention_button in intervention_buttons:
			if not intervention_button.disabled:
				combat_actions.append(intervention_button)
		combat_actions.append(how_to_play_button)
		_configure_vertical_focus_cycle(combat_actions)
	settlement_group.visible = state.phase == "settlement"
	settlement_title.visible = state.phase == "settlement"
	settlement_repair_button.visible = state.phase == "settlement"
	settlement_refuel_button.visible = state.phase == "settlement"
	settlement_hull_button.visible = state.phase == "settlement"
	final_journey_button.visible = state.phase == "settlement" and not state.campaign_active
	var action_word := "ACTION" if state.settlement_actions_remaining == 1 else "ACTIONS"
	settlement_title.text = "MORROWLINE SERVICES · %d %s LEFT" % [state.settlement_actions_remaining, action_word]
	var repair_missing := 0
	var repair_cost := 0
	if not selected_installed.is_empty():
		var repair_maximum := int(selected_definition.get("durability", 1))
		repair_missing = maxi(0, repair_maximum - int(selected_installed.get("durability", 0)))
		repair_cost = mini(2, repair_missing) * 4
	var services_open := state.phase == "settlement" and state.settlement_actions_remaining > 0
	settlement_repair_button.disabled = not services_open or selected_installed.is_empty() or repair_missing <= 0 or state.money < repair_cost
	if selected_installed.is_empty():
		settlement_repair_button.text = "REPAIR MODULE · SELECT A DAMAGED SYSTEM"
	elif repair_missing <= 0:
		settlement_repair_button.text = "%s · FULL DURABILITY" % String(selected_definition.get("name", "Selected module")).to_upper()
	else:
		settlement_repair_button.text = "REPAIR %s +%d · %d ASHMARKS" % [String(selected_definition.get("name", "module")).to_upper(), mini(2, repair_missing), repair_cost]
	settlement_refuel_button.text = "BUY +2 FUEL · 8 ASHMARKS"
	settlement_refuel_button.disabled = not services_open or state.money < 8
	settlement_hull_button.text = "HULL · FULL" if state.hull_condition >= 10 else "REPAIR +2 HULL · 10 ASHMARKS"
	settlement_hull_button.disabled = not services_open or state.hull_condition >= 10 or state.money < 10
	final_journey_button.disabled = state.phase != "settlement"
	_refresh_planning_focus()
	load_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	if state.campaign_active and state.phase in ["refit", "map", "settlement"]:
		if not state.campaign_event_pending.is_empty():
			_set_route_preview("A local decision blocks departure. Resolve it before choosing the next road.", "warning")
		elif state.guard_contract_status == "offered":
			_set_route_preview("The first map branches are visible after the Ashgate contract is answered.")
		elif not selected_campaign_node_id.is_empty():
			var block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
			var selected_detail := campaign_map.detail_for(selected_campaign_node_id)
			_set_route_preview("ROUTE READY · %s\n%s%s" % [String(LongMarchState.CAMPAIGN_NODES.get(selected_campaign_node_id, {}).get("name", selected_campaign_node_id)).to_upper(), selected_detail, " Departure blocked: %s." % block_reason if not block_reason.is_empty() else ""], "danger" if not block_reason.is_empty() else campaign_map.intel_tone_for(selected_campaign_node_id))
		else:
			_set_route_preview("Select a forward node to review it. Signal readiness and Iven Pell improve how much each route reveals.")
	elif state.phase == "refit":
		var departure := state.route_preview(_selected_id(route_option), _selected_id(doctrine_option))
		if bool(departure.get("ok", false)):
			var risk := float(departure.risk)
			_set_route_preview("Departure forecast — %d day(s), %d fuel, %.0f%% risk, pressure %d, predicted heat %d/%d." % [int(departure.days), int(departure.fuel), risk * 100.0, int(departure.pressure), int(departure.predicted_heat), LongMarchState.BASE_HEAT_LIMIT], "safe" if risk <= 0.18 else ("warning" if risk <= 0.32 else "danger"))
	elif state.phase == "settlement":
		_set_route_preview("Morrowline recovery — %d service action(s) remain. Refit freely, then choose a doctrine for Meridian Pass." % state.settlement_actions_remaining, "safe")
	elif state.phase == "results":
		_set_route_preview("Run complete — %s." % state.final_result.replace("_", " ").capitalize(), "safe")
	else:
		var active_risk := state.current_route_risk
		_set_route_preview("On the road — risk %.0f%%, pressure %d, doctrine %s." % [active_risk * 100.0, state.encounter_pressure, state.encounter_target_doctrine.replace("_", " ").capitalize()], "safe" if active_risk <= 0.18 else ("warning" if active_risk <= 0.32 else "danger"))
	var focus_owner := get_viewport().gui_get_focus_owner()
	if campaign_map.visible and focus_owner in campaign_node_buttons:
		var focused_node_id := String(focus_owner.get_meta("node_id", ""))
		_on_campaign_node_inspected(focused_node_id, campaign_map.detail_for(focused_node_id))
	var dependencies: Dictionary = snapshot.dependencies
	var safe_color := Color("#8bd6ad")
	var warning_color := Color("#e8c58e")
	var danger_color := Color("#ef8375")
	_set_metric("day", str(snapshot.day))
	_set_metric("fuel", str(snapshot.fuel), danger_color if snapshot.fuel <= 2 else (warning_color if snapshot.fuel <= 4 else safe_color))
	_set_metric("money", str(snapshot.money))
	_set_metric("hull", "%d/10" % snapshot.hull_condition, danger_color if snapshot.hull_condition <= 3 else (warning_color if snapshot.hull_condition <= 6 else safe_color))
	_set_metric("mass", "%d/%d" % [snapshot.mass, snapshot.mass_limit], danger_color if snapshot.mass > snapshot.mass_limit else (warning_color if snapshot.mass >= snapshot.mass_limit else Color("#f1e6cf")))
	_set_metric("power", "%d/%d" % [snapshot.power_draw, snapshot.power_output], danger_color if snapshot.power_draw > snapshot.power_output else safe_color)
	_set_metric("heat", "%d/%d" % [snapshot.heat, snapshot.heat_limit], danger_color if snapshot.heat > snapshot.heat_limit else (warning_color if snapshot.heat >= snapshot.heat_limit - 1 else safe_color))
	status_label.text = "SYSTEMS · %d ready   %d strained   %d offline%s" % [int(dependencies.ready), int(dependencies.strained), int(dependencies.offline), "   ·   BLOCKADE %s %d" % [state.campaign_pressure_band().to_upper(), state.campaign_pressure] if state.campaign_active else ""]
	campaign_progress_bar.visible = state.campaign_active
	campaign_progress_bar.value = state.campaign_encounters_completed
	var combat_view := state.encounter_summary()
	combat_view["location_name"] = String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node))
	combat_view["doctrine"] = state.encounter_target_doctrine
	combat_view["command_points"] = state.command_points
	combat_panel.configure(combat_view, LongMarchState.ENCOUNTER_ENEMIES)
	var route_name := String(LongMarchState.ROUTES.get(state.journey_route, {}).get("name", "Meridian Pass" if state.journey_route == "meridian_pass" else "not chosen"))
	if state.campaign_active:
		var path_names: Array[String] = []
		for node_id in state.campaign_path:
			path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)))
		journey_label.text = "ROAD OUT — %s\nPhase: %s | Current node: %s | Encounter %d/5" % [" → ".join(path_names), state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), state.campaign_encounters_completed]
	else:
		journey_label.text = "JOURNEY — Ashgate Depot → Morrowline Camp → Meridian Pass\nPhase: %s | Current node: %s | Route: %s" % [state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), route_name]
	if state.phase == "results":
		encounter_label.text = "RUN RESULT — %s\nDay %d · Hull %d/10 · Ashmarks %d · Trust %d · Contract %s · %d systems offline" % [state.final_result.replace("_", " ").capitalize(), state.day, state.hull_condition, state.money, state.settlement_trust, state.guard_contract_status.replace("_", " ").capitalize(), int(dependencies.offline)]
		encounter_label.add_theme_color_override("font_color", Color("#f0d29d"))
	elif not state.encounter_outcome.is_empty():
		var last_consequence := state.encounter_report[-1] if not state.encounter_report.is_empty() else "The road is clear."
		encounter_label.text = "AFTER-ACTION — %s · resolved in %d step(s)\n%s" % [state.encounter_outcome.replace("_", " ").to_upper(), state.encounter_step, String(last_consequence)]
		encounter_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	else:
		var selected_block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
		var selected_node_name := String(LongMarchState.CAMPAIGN_NODES.get(selected_campaign_node_id, {}).get("name", selected_campaign_node_id))
		var selected_instruction := "%s selected · %s" % [selected_node_name, "Resolve departure block: %s." % selected_block_reason if not selected_block_reason.is_empty() else "Review its costs and doctrine, then commit when ready."]
		if state.guard_contract_status == "offered":
			encounter_label.text = "ASHGATE PREPARATION\nAnswer the convoy contract to open the first roads."
		elif not state.campaign_event_pending.is_empty():
			encounter_label.text = "LOCAL DECISION\nResolve the current situation before choosing the next road."
		elif state.phase == "settlement":
			encounter_label.text = "MORROWLINE RECOVERY\nUse up to two service actions, refit freely, then prepare for the final road."
		elif selected_campaign_node_id.is_empty():
			encounter_label.text = "ROUTE PLANNING\nSelect a cyan route and review its costs."
		else:
			encounter_label.text = "ROUTE READY FOR REVIEW\n%s" % selected_instruction
		encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
	var recent: Array[String] = []
	var start := maxi(0, state.log.size() - 4)
	for index in range(start, state.log.size()):
		recent.append(state.log[index])
	log_label.text = "RECENT ORDERS & DAMAGE\n• " + ("\n• ".join(recent) if not recent.is_empty() else "The crew is waiting for a route order.")
	if event_label.text.is_empty():
		event_label.text = "Ashgate is ready. Inspect the chassis, answer the contract, then choose a highlighted map node."
	fortress_panel.state = state
	fortress_panel.placement_module_id = selected_module_id
	fortress_panel.placement_rotated = placement_rotated
	fortress_panel.selected_cell = selected_module_cell
	fortress_panel.combat_target_ids.clear()
	if is_battle_phase:
		for enemy in state.encounter_enemies:
			var target_id := String(enemy.get("target", ""))
			if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and not target_id.is_empty() and target_id != "hull" and target_id not in fortress_panel.combat_target_ids:
				fortress_panel.combat_target_ids.append(target_id)
	fortress_panel.queue_redraw()
	_ensure_current_focus()

func _current_guidance() -> String:
	if state.phase == "results":
		return "RUN COMPLETE · Inspect the surviving systems, then record playtest notes while the decisions are fresh."
	if state.phase in ["battle", "final_battle"]:
		var active_targets: Array[String] = []
		var nearest_enemy := ""
		var nearest_steps := 99
		for enemy in state.encounter_enemies:
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id := String(enemy.get("id", ""))
			var definition: Dictionary = LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {})
			if bool(enemy.get("arrived", false)):
				var target_id := String(enemy.get("target", "hull"))
				var target_name := "Hull" if target_id == "hull" else String(state.module_definition(target_id).get("name", target_id.replace("_", " ").capitalize()))
				if target_name not in active_targets:
					active_targets.append(target_name)
			else:
				var steps_out := maxi(1, int(definition.get("arrival_step", 0)) - state.encounter_step)
				if steps_out < nearest_steps:
					nearest_steps = steps_out
					nearest_enemy = String(definition.get("name", enemy_id))
		var order_status := "The emergency order is spent." if state.encounter_intervention_used else "One emergency order remains."
		if not active_targets.is_empty():
			return "CURRENT ORDER · %s under threat. Read cause and effect, then advance. %s" % [" and ".join(active_targets), order_status]
		if not nearest_enemy.is_empty():
			return "CURRENT ORDER · %s is %d step%s out. Advance to step %d. %s" % [nearest_enemy, nearest_steps, "" if nearest_steps == 1 else "s", mini(state.encounter_step + 1, 6), order_status]
		return "CURRENT ORDER · Advance the encounter and watch for a new target. %s" % order_status
	if not state.campaign_event_pending.is_empty():
		return "DECISION REQUIRED · Resolve the local event below before the fortress can depart."
	if state.guard_contract_status == "offered":
		return "CURRENT ORDER · Decide whether to guard Morrowline's parts convoy. This unlocks the first roads."
	if not selected_campaign_node_id.is_empty():
		var node_name := String(LongMarchState.CAMPAIGN_NODES.get(selected_campaign_node_id, {}).get("name", selected_campaign_node_id))
		var block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
		if not block_reason.is_empty():
			return "DEPARTURE BLOCKED · %s. Refit or recover, then review this route again." % block_reason
		return "ROUTE READY · %s is selected. Review its costs and doctrine, then press Commit." % node_name
	if state.phase == "settlement":
		return "RECOVERY · %s remains. Repair or refuel, refit freely, then choose the next road." % _service_action_count_text()
	if state.campaign_active and state.phase in ["refit", "map"]:
		return "CURRENT ORDER · Select one cyan route on the map. Selection previews it; Commit begins travel."
	return "CURRENT ORDER · Prepare the fortress, review the route forecast, then depart when movement is ready."

func _result_summary_text() -> String:
	match state.final_result:
		"decisive_march":
			return "DECISIVE MARCH · Meridian Pass is open. Every final contact was defeated, the fortress retained at least 7 hull, and the convoy contract survived."
		"scarred_march":
			var missed: Array[String] = []
			if state.hull_condition < 7:
				missed.append("hull ended at %d/10 (7 required)" % state.hull_condition)
			var undefeated := 0
			for enemy in state.encounter_enemies:
				if not bool(enemy.get("defeated", false)):
					undefeated += 1
			if undefeated > 0:
				missed.append("%d final contact%s remained" % [undefeated, "" if undefeated == 1 else "s"])
			if state.guard_contract_status == "failed":
				missed.append("the convoy contract failed")
			return "SCARRED MARCH · The fortress crossed, but missed a decisive result because %s." % (", ".join(missed) if not missed.is_empty() else "the final approach left lasting damage")
		"march_failed":
			if state.hull_condition <= 0:
				return "MARCH FAILED · The fortress hull reached zero at Meridian Pass."
			return "MARCH FAILED · No operational, fuel-connected engine remained to carry the fortress through Meridian Pass."
	return "RUN COMPLETE · The chapter ended with an unclassified result."

func _result_replay_text() -> String:
	if state.final_result == "decisive_march":
		return "NEXT RUN · Test a different doctrine or road and see whether the fortress can remain decisive."
	if state.final_result == "scarred_march":
		return "NEXT RUN · Preserve hull before Meridian Pass and use the Morrowline service budget on the system that protects the final approach."
	return "NEXT RUN · Protect movement first: keep one engine fuel-connected, then preserve hull for the final commitment."

func _service_action_count_text() -> String:
	return "%d service action%s" % [state.settlement_actions_remaining, "" if state.settlement_actions_remaining == 1 else "s"]

class FortressPanel extends Control:
	signal grid_cell_pressed(cell: Vector2i)
	signal rotate_requested
	signal remove_requested
	signal focus_exit_requested

	var state: LongMarchState
	const CELL := 50.0
	const ORIGIN := Vector2(28, 22)
	var placement_module_id: String = ""
	var placement_rotated: bool = false
	var selected_cell := Vector2i(-1, -1)
	var cursor_cell := Vector2i(0, 0)
	var combat_target_ids: Array[String] = []
	var family_colors := {
		"engine": Color("#b86f4b"),
		"weapon": Color("#b44949"),
		"workshop": Color("#b69555"),
		"crew_room": Color("#557fa1"),
		"armor": Color("#6f7b84"),
		"cargo": Color("#8e6d4f"),
		"signal": Color("#5e9b91")
	}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = "Click a module to select it, or click an empty cell to place or move. With keyboard or controller focus, use arrows and A or Enter; B or Escape returns to the desk."
		focus_entered.connect(queue_redraw)
		focus_exited.connect(queue_redraw)

	func _grid_rect() -> Rect2:
		return Rect2(ORIGIN, Vector2(LongMarchState.GRID_WIDTH * CELL, LongMarchState.GRID_HEIGHT * CELL))

	func _cell_from_point(point: Vector2) -> Vector2i:
		if not _grid_rect().has_point(point):
			return Vector2i(-1, -1)
		var relative := point - ORIGIN
		return Vector2i(int(relative.x / CELL), int(relative.y / CELL))

	func _placement_validation() -> Dictionary:
		if state == null or not state.can_refit() or placement_module_id.is_empty():
			return {"ok": false, "reason": "refit is not available"}
		var exterior: bool = "exterior" in state.module_definition(placement_module_id).get("tags", [])
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		if selected.is_empty():
			return state.validate_module_placement(placement_module_id, cursor_cell, exterior, placement_rotated)
		return state.validate_module_reposition(selected_cell, cursor_cell, placement_rotated)

	func placement_status_text() -> String:
		if state != null:
			var hovered := state.module_at(cursor_cell)
			if not hovered.is_empty():
				var hovered_name := String(state.module_definition(String(hovered.get("id", ""))).get("name", "module")).to_upper()
				if selected_cell in state.occupied_cells(hovered):
					return "SELECTED · %s · MOVE TO AN EMPTY CELL" % hovered_name
				return "SELECT %s · A / ENTER TO INSPECT" % hovered_name
		var validation := _placement_validation()
		if bool(validation.get("ok", false)):
			return "PLACEMENT READY · A / ENTER TO APPLY"
		return "BLOCKED · %s" % String(validation.get("reason", "invalid placement")).to_upper()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			var next_cell := _cell_from_point(event.position)
			if next_cell.x >= 0:
				cursor_cell = next_cell
				queue_redraw()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked := _cell_from_point(event.position)
			if clicked.x >= 0:
				cursor_cell = clicked
				grab_focus()
				grid_cell_pressed.emit(clicked)
				accept_event()
		elif event.is_action_pressed("ui_left"):
			cursor_cell.x = maxi(0, cursor_cell.x - 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_right"):
			cursor_cell.x = mini(LongMarchState.GRID_WIDTH - 1, cursor_cell.x + 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_up"):
			cursor_cell.y = maxi(0, cursor_cell.y - 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_down"):
			cursor_cell.y = mini(LongMarchState.GRID_HEIGHT - 1, cursor_cell.y + 1)
			queue_redraw()
			accept_event()
		elif event.is_action_pressed("ui_accept"):
			grid_cell_pressed.emit(cursor_cell)
			accept_event()
		elif event.is_action_pressed("ui_cancel") and state != null and state.can_refit():
			focus_exit_requested.emit()
			accept_event()
		elif event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_R:
				rotate_requested.emit()
				accept_event()
			elif event.keycode in [KEY_DELETE, KEY_BACKSPACE]:
				remove_requested.emit()
				accept_event()

	func _module_rect(instance: Dictionary) -> Rect2:
		var position: Vector2i = instance.get("position", Vector2i.ZERO)
		var shape := state.module_shape(String(instance.get("id", "")), bool(instance.get("rotated", false)))
		return Rect2(ORIGIN + Vector2(position.x * CELL, position.y * CELL), Vector2(shape.x * CELL - 3, shape.y * CELL - 3))

	func _draw_module_name(rect: Rect2, name: String) -> void:
		var words := name.split(" ")
		if words.size() > 1 and (rect.size.x < CELL * 1.5 or name.length() > 14):
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 18), String(words[0]), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10, 10, Color("#f7efe0"))
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 34), " ".join(words.slice(1)), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10, 10, Color("#f7efe0"))
		else:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 22), name, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 11, Color("#f7efe0"))

	func _draw_preview() -> void:
		if state == null or not state.can_refit() or placement_module_id.is_empty():
			return
		if not state.module_at(cursor_cell).is_empty():
			return
		var exterior: bool = "exterior" in state.module_definition(placement_module_id).get("tags", [])
		var validation := _placement_validation()
		var preview := state.module_instance(placement_module_id, cursor_cell, exterior, placement_rotated)
		var color := Color(0.35, 0.85, 0.58, 0.42) if bool(validation.get("ok", false)) else Color(0.92, 0.3, 0.25, 0.42)
		for cell in state.occupied_cells(preview):
			if cell.x >= 0 and cell.x < LongMarchState.GRID_WIDTH and cell.y >= 0 and cell.y < LongMarchState.GRID_HEIGHT:
				draw_rect(Rect2(ORIGIN + Vector2(cell.x * CELL, cell.y * CELL), Vector2(CELL - 3, CELL - 3)), color, true)

	func _draw_refit_details() -> void:
		var x := 370.0
		draw_string(ThemeDB.fallback_font, Vector2(x, 40), "REFIT STATUS" if state != null and state.can_refit() else "SYSTEM STATUS", HORIZONTAL_ALIGNMENT_LEFT, 300, 16, Color("#e8c58e"))
		if state == null or placement_module_id.is_empty():
			return
		var definition := state.module_definition(placement_module_id)
		var shape := state.module_shape(placement_module_id, placement_rotated)
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		draw_string(ThemeDB.fallback_font, Vector2(x, 70), String(definition.get("name", placement_module_id)), HORIZONTAL_ALIGNMENT_LEFT, 300, 15, Color("#f1e6cf"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 94), "%dx%d footprint · mass %d · power %d · heat %d" % [shape.x, shape.y, int(definition.get("mass", 0)), int(definition.get("power_draw", 0)), int(definition.get("heat", 0))], HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#aab6ba"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 118), "Exterior mount" if "exterior" in definition.get("tags", []) else "Interior chassis", HORIZONTAL_ALIGNMENT_LEFT, 300, 12, Color("#d8c389"))
		if not selected.is_empty():
			var dependency := state.dependency_status(selected)
			var state_name := String(dependency.get("state", "offline"))
			var state_color := Color("#73c99b") if state_name == "ready" else (Color("#e3ad55") if state_name == "strained" else Color("#e06f61"))
			var reasons: Array = dependency.get("reasons", [])
			var benefits: Array = dependency.get("benefits", [])
			draw_string(ThemeDB.fallback_font, Vector2(x, 154), "System state: " + state_name.capitalize(), HORIZONTAL_ALIGNMENT_LEFT, 320, 13, state_color)
			draw_string(ThemeDB.fallback_font, Vector2(x, 178), String(reasons[0]) if not reasons.is_empty() else "All required connections are satisfied.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#b9c3bf"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 200), String(benefits[0]) if not benefits.is_empty() else "Move it to change its dependency graph.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		else:
			draw_string(ThemeDB.fallback_font, Vector2(x, 154), "Pending module: choose an empty cell", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#b9c3bf"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 178), "Connections are evaluated after placement.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		if state.can_refit():
			var hovered := state.module_at(cursor_cell)
			var placement_validation := _placement_validation()
			var status_color := Color("#f0cf96") if not hovered.is_empty() else (Color("#73c99b") if bool(placement_validation.get("ok", false)) else Color("#ef8375"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 228), placement_status_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 11, status_color)
			draw_string(ThemeDB.fallback_font, Vector2(x, 246), "Arrows move · A confirms · B returns", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		else:
			draw_string(ThemeDB.fallback_font, Vector2(x, 228), "Select another module to inspect battle damage.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#b9c3bf"))

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#18242b"), true)
		if has_focus():
			draw_rect(Rect2(Vector2.ZERO, size).grow(-2), Color("#f0cf96"), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(ORIGIN.x, 14), "CHASSIS EDIT MODE — arrows move · A acts · B returns" if has_focus() else "CHASSIS GRID — exterior mounts use a bright edge", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f0cf96") if has_focus() else Color("#b9c3bf"))
		for y in range(LongMarchState.GRID_HEIGHT):
			for x in range(LongMarchState.GRID_WIDTH):
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#223139"), true)
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#4a5c61"), false, 1.0)
		if state == null:
			return
		_draw_preview()
		for instance in state.modules:
			var definition := state.module_definition(String(instance.get("id", "")))
			var rect := _module_rect(instance)
			var color: Color = family_colors.get(String(definition.get("family", "")), Color("#8b8b8b"))
			var dependency := state.dependency_status(instance)
			var state_name := String(dependency.get("state", "offline"))
			var fill_color := color
			if state_name == "offline":
				fill_color = color.darkened(0.55)
			elif state_name == "strained":
				fill_color = color.lerp(Color("#b9823f"), 0.38)
			draw_rect(rect, fill_color, true)
			draw_rect(rect, Color("#f0db9a") if bool(instance.get("exterior", false)) else Color("#b9c3bf"), false, 3.0 if bool(instance.get("exterior", false)) else 1.0)
			if state_name != "ready":
				draw_rect(rect.grow(-3), Color("#e3ad55") if state_name == "strained" else Color("#e06f61"), false, 2.0)
			_draw_module_name(rect, String(definition.get("name", instance.get("id", ""))))
			var maximum := maxi(1, int(definition.get("durability", 1)))
			var durability := maxi(0, int(instance.get("durability", 0)))
			var durability_ratio := clampf(float(durability) / float(maximum), 0.0, 1.0)
			var bar_rect := Rect2(rect.position + Vector2(4, rect.size.y - 7), Vector2(rect.size.x - 8, 4))
			draw_rect(bar_rect, Color("#172026"), true)
			draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * durability_ratio, bar_rect.size.y)), Color("#73c99b") if durability_ratio > 0.5 else (Color("#e8c58e") if durability_ratio > 0.25 else Color("#ef8375")), true)
			if String(instance.get("id", "")) in combat_target_ids:
				draw_rect(rect.grow(3), Color("#ff806f"), false, 4.0)
			if selected_cell in state.occupied_cells(instance):
				draw_rect(rect.grow(2), Color("#69d8cf"), false, 3.0)
		var cursor_rect := Rect2(ORIGIN + Vector2(cursor_cell.x * CELL, cursor_cell.y * CELL), Vector2(CELL - 3, CELL - 3))
		draw_rect(cursor_rect, Color("#e8c58e") if has_focus() else Color("#7d8f93"), false, 2.0)
		_draw_refit_details()
