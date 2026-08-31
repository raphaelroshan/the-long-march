extends Control

signal return_to_title_requested
signal checkpoint_reached(reason: String)
signal play_again_requested
signal march_on_requested(region_id: String)
signal pause_requested
signal playtest_notes_closed

const LongMarchState = preload("res://src/core/fortress_state.gd")
const PlaytestJournal = preload("res://src/support/playtest_journal.gd")
const VisualContrast = preload("res://src/support/visual_contrast.gd")
const ControllerLayout = preload("res://src/support/controller_layout.gd")
const TutorialDirectorScript = preload("res://src/tutorial/tutorial_director.gd")
const TutorialObjectiveViewScript = preload("res://src/ui/tutorial_objective.gd")
const TutorialCompletionViewScript = preload("res://src/ui/tutorial_completion.gd")
const CampaignMapView = preload("res://src/ui/campaign_map.gd")
const CombatPanel = preload("res://src/ui/combat_panel.gd")
const SettlementHubScene = preload("res://scenes/settlement/SettlementHub.tscn")
const JourneyTransitionScene = preload("res://scenes/journey/JourneyTransition.tscn")
const JourneyPlannerScene = preload("res://scenes/journey/JourneyPlanner.tscn")
const RoadContactScene = preload("res://scenes/journey/RoadContact.tscn")
const JourneyArrivalScene = preload("res://scenes/journey/JourneyArrival.tscn")
const RoadsideEventScene = preload("res://scenes/journey/RoadsideEvent.tscn")
const DebriefPanelScene = preload("res://scenes/debrief/DebriefPanel.tscn")
const RecoveryPanelScene = preload("res://scenes/recovery/RecoveryPanel.tscn")
const FortressSilhouetteRenderer = preload("res://src/ui/fortress_silhouette.gd")
const SettlementPresenter = preload("res://src/presentation/settlement_presenter.gd")
const RoutePresenter = preload("res://src/presentation/route_presenter.gd")
const ContactPresenter = preload("res://src/presentation/contact_presenter.gd")
const RecoveryPresenter = preload("res://src/presentation/recovery_presenter.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const ENGINE_ICON = preload("res://assets/steam_lance_engine_icon.png")
const CANNON_ICON = preload("res://assets/shell_cannon_icon.png")
const WORKSHOP_ICON = preload("res://assets/field_workshop_icon.png")
const SIGNAL_ICON = preload("res://assets/signal_coil_icon.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SAVE_BACKUP_PATH := "user://the_long_march_prototype.backup.save"
const TUTORIAL_SAVE_PATH := "user://the_long_march_tutorial.save"
const TUTORIAL_BACKUP_PATH := "user://the_long_march_tutorial.backup.save"
const TUTORIAL_COMPLETE_PATH := "user://the_long_march_tutorial.complete"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const RUN_FLOW_STEPS := ["PREP", "ROADS", "RECOVER", "FINAL", "RESULT"]
const DOCTRINE_DESCRIPTIONS := {
	"protect_cargo": "Cargo guard · Raiders take +1 weapon damage, cargo is targeted less often, and cargo hits deal −1 damage.",
	"protect_crew": "Crew guard · Climbers and the Siege Beast take +1 weapon damage, while crew rooms are targeted less and take −1 damage.",
	"run_hot": "Overdrive · All attacks gain +1 damage, but the fortress gains +2 heat; overheating raises route risk and incoming damage."
}
const DOCTRINE_COMMIT_SUMMARIES := {
	"protect_cargo": "Raiders take +1 weapon damage · cargo hits −1",
	"protect_crew": "Climbers / Siege Beast take +1 · crew hits −1",
	"run_hot": "all attacks +1 · heat +2 · overheating raises danger"
}
const ONBOARDING_LABELS := ["COMMAND", "ENGINE", "WEAPON", "REPAIR", "SIGNAL", "ROAD", "CONTACT"]
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
		"title": "Keep movement alive",
		"body": "The Steam Lance Engine needs a working adjacent Coal Cell. If that link is lost, movement stops and departure can be blocked. Select the engine to read its dependency card. Choose Edit Chassis; arrows move the gold cursor, A or Enter acts, and B or Escape returns.",
		"action": "TRY THIS · Select the Steam Lance Engine and find DEPENDS ON, IF LOST, and COUNTER."
	},
	{
		"title": "Feed the weapons",
		"body": "Weapons need shared power. An adjacent Ammunition Lift provides full output; without it, a gun remains strained and fires emergency ammunition for less damage.",
		"action": "TRY THIS · Inspect the Repeater Gun, then locate the Ammunition Lift connected beside it."
	},
	{
		"title": "Keep repairs staffed",
		"body": "The Field Workshop needs adjacent Crew Quarters to operate. An adjacent Parts Crate improves each repair from a temporary patch to a stronger restoration.",
		"action": "TRY THIS · Inspect the Field Workshop and decide which crew or parts link you would protect first."
	},
	{
		"title": "Trade exposure for knowledge",
		"body": "Signal systems need power and exterior visibility for exact forecasts. Without a clear exterior signal, route information stays broad; exposed signal equipment is easier for Climbers and storms to reach.",
		"action": "LOOK FOR · Compare exact, forecast, and unscouted route information before exposing a signal module."
	},
	{
		"title": "Choose, review, then commit",
		"body": "Cyan map nodes are reachable. Known routes reveal exact contacts and counters; forecasts reveal a hazard class; unscouted roads remain broad. Watch becomes Closing at 3 pressure and Break at 5. Selecting a route is only a preview.",
		"action": "LOOK FOR · Compare fuel, time, risk, pressure, doctrine, and whether the chassis answers any revealed counter before Commit."
	},
	{
		"title": "Read the contact",
		"body": "Battles advance one readable step at a time. Each contact names its target, why it chose that system, and the next hit. You may issue one emergency order per encounter, then refit and recover at Morrowline before the final road.",
		"action": "IN CONTACT · Read TARGET, WHY, and NEXT before advancing. At the end, record what felt clear or confusing."
	}
]
const VEYRU_ONBOARDING_LABELS := ["COMMAND", "ENGINE", "SUSTAIN", "REPAIR", "CARRIER", "WATER", "ARCHIVE"]
const VEYRU_ONBOARDING_STEPS := [
	{
		"title": "Your job is delivery",
		"body": "You command a walking fortress through five flooded encounters. Success means reaching the Dry Archive with a machine that still moves; the sealed medicines are an obligation you may accept, protect, lose, or refuse.",
		"action": "FIRST ACTION · Answer Lantern Quay's medicine contract. The accepted cases reserve one named system as their carrier."
	},
	{
		"title": "Keep movement above water",
		"body": "The Steam Lance Engine needs a working adjacent Coal Cell. If that link is lost, movement stops and departure can be blocked. Select the engine to read its dependency card before changing the prepared layout.",
		"action": "TRY THIS · Select the Steam Lance Engine and find DEPENDS ON, IF LOST, and COUNTER."
	},
	{
		"title": "Maintain the condenser",
		"body": "The Water Condenser needs shared power and an adjacent operational Field Workshop to become Ready. A Ready condenser reduces Flood Surge damage away from itself, but its heat and two-cell footprint leave no spare mass in the prepared fortress.",
		"action": "TRY THIS · Inspect the Water Condenser, then trace its workshop and power requirements."
	},
	{
		"title": "Keep repairs staffed",
		"body": "The Field Workshop needs adjacent Crew Quarters. After contact it repairs the weakest damaged operational system, which can preserve the medicine carrier or movement chain without erasing every consequence.",
		"action": "TRY THIS · Inspect the Field Workshop and decide whether its crew link or the exposed carrier needs more protection."
	},
	{
		"title": "Protect the named carrier",
		"body": "Accepting the contract names the Refugee Bunk or Parts Crate carrying the medicines. Flood contacts and the Civic Guardian value that system. Losing it fails the delivery but does not end the chapter.",
		"action": "LOOK FOR · Read the carrier beside the contract, then compare Protect Cargo, armor, repair, and Seal Compartment."
	},
	{
		"title": "Read the rising water",
		"body": "Low Water covers pressure 0–2. Flooding at 3–4 strengthens Flood Surge. Breach at 5 closes Drowned Registry but opens Pilgrim Gantry, the guaranteed recovery road. Selecting a route is only a preview.",
		"action": "LOOK FOR · Compare fuel, time, water gain, route knowledge, and whether recovery follows before Commit."
	},
	{
		"title": "Choose what the archive says",
		"body": "Battles advance one readable step at a time and allow one emergency order per encounter. At Dry Archive Gate, broadcasting adds public trust and a final Climber contact; sealing lowers water and protects the carrier.",
		"action": "IN CONTACT · Read TARGET, WHY, and NEXT before advancing. At the gate, read both complete consequences before choosing."
	}
]

var state: LongMarchState
var main_columns: HBoxContainer
var settlement_hub: SettlementHubView
var settlement_hub_active: bool = true
var settlement_detail_mode: String = "hub"
var settlement_hub_return_button: Button
var journey_transition: JourneyTransitionView
var journey_transition_active: bool = false
var journey_transition_view: Dictionary = {}
var journey_planner: JourneyPlannerView
var journey_planner_active: bool = false
var road_contact: RoadContactView
var contact_inspection_active: bool = false
var journey_arrival: JourneyArrivalView
var journey_arrival_active: bool = false
var journey_arrival_view: Dictionary = {}
var journey_departure_snapshot: Dictionary = {}
var roadside_event: RoadsideEventView
var debrief_panel: DebriefPanelView
var debrief_inspection_active: bool = false
var contact_fortress_before: Dictionary = {}
var recovery_panel: RecoveryPanelView
var last_recovery_receipt: String = ""
var last_journey_receipt: String = ""
var metric_labels: Dictionary = {}
var metric_panels: Dictionary = {}
var subtitle_label: Label
var pause_button: Button
var journey_banner: TextureRect
var status_label: Label
var left_scroll: ScrollContainer
var right_scroll: ScrollContainer
var desk_scroll_tail: Control
var pending_desk_scroll_control: Control
var desk_scroll_queued: bool = false
var desk_scroll_frames_remaining: int = 0
var journey_label: Label
var encounter_label: Label
var combat_panel: CombatPanel
var advance_warning_label: Label
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
var combat_inspect_button: Button
var intervention_buttons: Array[Button] = []
var settlement_repair_button: Button
var settlement_refuel_button: Button
var settlement_hull_button: Button
var settlement_routes_button: Button
var final_journey_button: Button
var refit_label: Label
var dependency_card_panel: PanelContainer
var dependency_card_label: Label
var route_preview_label: Label
var refit_title: Label
var module_group: Control
var refit_actions: Control
var route_group: Control
var doctrine_group: Control
var doctrine_detail_label: Label
var intervention_title: Label
var intervention_help_label: Label
var intervention_preview_texts: Dictionary = {}
var intervention_overview_text: String = ""
var settlement_title: Label
var settlement_group: Control
var campaign_title: Label
var campaign_pressure_label: Label
var campaign_path_label: Label
var campaign_comparison_panel: PanelContainer
var campaign_comparison_label: Label
var campaign_map: CampaignMapView
var campaign_node_buttons: Array[Button] = []
var campaign_commit_button: Button
var campaign_cancel_button: Button
var campaign_commit_intel_label: Label
var campaign_action_row: HBoxContainer
var selected_campaign_node_id: String = ""
var contract_title: Label
var contract_label: Label
var contract_group: Control
var contract_accept_button: Button
var contract_decline_button: Button
var campaign_event_title: Label
var campaign_event_label: Label
var campaign_event_buttons: Array[Button] = []
var recruit_iven_button: Button
var save_button: Button
var load_button: Button
var guidance_label: Label
var current_order_button: Button
var run_flow_panels: Array[PanelContainer] = []
var run_flow_labels: Array[Label] = []
var run_flow_heading_row: HBoxContainer
var run_flow_tracker: HBoxContainer
var current_run_flow_step: int = 0
var asset_row: HBoxContainer
var phase_badge: Label
var campaign_progress_bar: ProgressBar
var how_to_play_button: Button
var feedback_button: Button
var results_group: VBoxContainer
var results_heading: Label
var results_summary_label: Label
var results_record_label: Label
var results_replay_label: Label
var results_inspect_button: Button
var march_on_button: Button
var play_again_button: Button
var results_title_button: Button
var onboarding_overlay: Control
var onboarding_title_label: Label
var onboarding_body_label: Label
var onboarding_action_label: Label
var onboarding_progress_label: Label
var onboarding_step_buttons: Array[Button] = []
var onboarding_viewed_steps: Dictionary = {}
var onboarding_back_button: Button
var onboarding_next_button: Button
var onboarding_skip_button: Button
var onboarding_step: int = 0
var onboarding_reopened: bool = false
var feedback_overlay: Control
var feedback_context_label: Label
var feedback_clear_text: TextEdit
var feedback_confusing_text: TextEdit
var feedback_score_option: OptionButton
var feedback_status_label: Label
var feedback_save_button: Button
var feedback_path_button: Button
var feedback_close_button: Button
var last_feedback_path: String = ""
var feedback_return_context: String = "results"
var journal: PlaytestJournal
var result_recorded: bool = false
var results_chassis_reviewed: bool = false
var last_rendered_phase: String = ""
var fortress_panel: Control
var selected_module_id: String = ""
var selected_module_cell := Vector2i(-1, -1)
var placement_rotated: bool = false
var last_synced_combat_target_id: String = ""
var show_onboarding_on_ready: bool = true
var tutorial_mode: bool = false
var tutorial_director: TutorialDirector
var tutorial_objective_view: TutorialObjectiveView
var tutorial_completion_view: TutorialCompletionView
var tutorial_lesson_snapshot: Dictionary = {}
var tutorial_lesson_snapshots: Dictionary = {}
var tutorial_director_snapshots: Dictionary = {}
var starting_region_id: String = "ashgate_lowlands"
var starting_regional_developments: Array[String] = []
var starting_region_results: Dictionary = {}
var high_contrast_enabled: bool = false
var reduced_motion_enabled: bool = false
var controller_layout_id: String = ControllerLayout.DEFAULT_LAYOUT

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

func _create_ui_theme(high_contrast: bool = false) -> Theme:
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 14
	for control_type in ["Button", "OptionButton"]:
		ui_theme.set_stylebox("normal", control_type, _flat_style(Color("#080d10") if high_contrast else Color("#24323a"), Color("#a8b8bd") if high_contrast else Color("#50636b"), 2 if high_contrast else 1, 5, 6 if high_contrast else 7))
		ui_theme.set_stylebox("hover", control_type, _flat_style(Color("#10262b") if high_contrast else Color("#30434c"), Color("#75efff") if high_contrast else Color("#79cfc3"), 3 if high_contrast else 2, 5, 5 if high_contrast else 6))
		ui_theme.set_stylebox("pressed", control_type, _flat_style(Color("#05090c") if high_contrast else Color("#172229"), Color("#ffe6a3") if high_contrast else Color("#e8c58e"), 3 if high_contrast else 2, 5, 5 if high_contrast else 6))
		ui_theme.set_stylebox("focus", control_type, _flat_style(Color("#10262b") if high_contrast else Color("#283942"), Color.WHITE if high_contrast else Color("#f3dfad"), 4 if high_contrast else 2, 5, 4 if high_contrast else 6))
		ui_theme.set_stylebox("disabled", control_type, _flat_style(Color("#11171a") if high_contrast else Color("#182127"), Color("#718087") if high_contrast else Color("#39474d"), 2 if high_contrast else 1, 5, 6 if high_contrast else 7))
		ui_theme.set_color("font_color", control_type, Color("#eef3ef"))
		ui_theme.set_color("font_hover_color", control_type, Color("#ffffff"))
		ui_theme.set_color("font_pressed_color", control_type, Color("#fff1ce"))
		ui_theme.set_color("font_focus_color", control_type, Color("#ffffff"))
		ui_theme.set_color("font_disabled_color", control_type, Color("#c5d0d3") if high_contrast else Color("#718087"))
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
	metric_panels[metric_id] = panel
	parent.add_child(panel)

func _set_metric(metric_id: String, value: String, color: Color = Color("#f1e6cf")) -> void:
	var label := metric_labels.get(metric_id) as Label
	if label == null:
		return
	label.text = value
	label.add_theme_color_override("font_color", color)

func _accent_button(button: Button, background: Color, border: Color) -> void:
	var adjusted_background := background.darkened(0.35) if high_contrast_enabled else background
	var adjusted_border := VisualContrast.display_color(border) if high_contrast_enabled else border
	button.add_theme_stylebox_override("normal", _flat_style(adjusted_background, adjusted_border, 3 if high_contrast_enabled else 2, 5, 5 if high_contrast_enabled else 7))
	button.add_theme_stylebox_override("hover", _flat_style(adjusted_background.lightened(0.08), adjusted_border.lightened(0.08), 3 if high_contrast_enabled else 2, 5, 5 if high_contrast_enabled else 7))
	button.add_theme_stylebox_override("pressed", _flat_style(adjusted_background.darkened(0.1), Color.WHITE, 3 if high_contrast_enabled else 2, 5, 5 if high_contrast_enabled else 7))
	button.add_theme_stylebox_override("focus", _flat_style(adjusted_background, Color.WHITE, 4 if high_contrast_enabled else 3, 5, 4 if high_contrast_enabled else 6))

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
	for control in [contract_accept_button, contract_decline_button, doctrine_option, campaign_commit_button, module_option, focus_chassis_button, rotate_button, remove_button, settlement_repair_button, settlement_refuel_button, settlement_hull_button, settlement_routes_button]:
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
	if _control_can_receive_focus(current_order_button):
		active_controls.append(current_order_button)
	if _control_can_receive_focus(how_to_play_button):
		active_controls.append(how_to_play_button)
	_configure_vertical_focus_cycle(active_controls)

func _build_run_flow_tracker(parent: VBoxContainer) -> void:
	var heading_row := HBoxContainer.new()
	run_flow_heading_row = heading_row
	heading_row.add_theme_constant_override("separation", 8)
	parent.add_child(heading_row)
	var heading := Label.new()
	heading.text = "RUN FLOW"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", Color("#89999e"))
	heading_row.add_child(heading)
	current_order_button = Button.new()
	current_order_button.text = "GO TO ORDER ↓"
	current_order_button.custom_minimum_size = Vector2(132, 28)
	current_order_button.add_theme_font_size_override("font_size", 10)
	current_order_button.tooltip_text = "Move focus to the required control without activating it."
	current_order_button.pressed.connect(focus_current_action)
	heading_row.add_child(current_order_button)
	var tracker := HBoxContainer.new()
	run_flow_tracker = tracker
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
	if state.phase == "final_battle" or state.current_location == state.campaign_final_node_id() or state.campaign_encounters_completed >= 4:
		return 3
	if state.phase == "battle" and state.campaign_encounters_completed >= 3:
		return 3
	if state.campaign_region_id == "flooded_veyru":
		if state.current_location == "veyru_evacuation_camp" or state.campaign_encounters_completed >= 2:
			if state.current_location != "veyru_evacuation_camp" and state.campaign_encounters_completed >= 3:
				return 3
			return 2
		if state.veyru_contract_status != "offered" or state.campaign_encounters_completed > 0 or state.phase in ["map", "battle"]:
			return 1
		return 0
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
		var failed_final := state.phase == "results" and state.final_result == "march_failed" and index == 3
		if failed_final:
			panel.add_theme_stylebox_override("panel", _flat_style(Color("#482929"), Color("#e06f61"), 2, 4, 2))
			label.text = "×\n%s" % RUN_FLOW_STEPS[index]
			label.add_theme_color_override("font_color", Color("#ffd4cd"))
		elif index < current_run_flow_step:
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
	theme = _create_ui_theme(high_contrast_enabled)
	journal = PlaytestJournal.new()
	_reset_state()
	_build_ui()
	if tutorial_mode:
		_initialize_tutorial_ui()
	campaign_map.set_high_contrast(high_contrast_enabled)
	combat_panel.set_high_contrast(high_contrast_enabled)
	settlement_hub.set_high_contrast(high_contrast_enabled)
	settlement_hub.set_reduced_motion(reduced_motion_enabled)
	journey_transition.set_high_contrast(high_contrast_enabled)
	journey_transition.set_reduced_motion(reduced_motion_enabled)
	journey_planner.set_high_contrast(high_contrast_enabled)
	road_contact.set_high_contrast(high_contrast_enabled)
	road_contact.set_reduced_motion(reduced_motion_enabled)
	journey_arrival.set_high_contrast(high_contrast_enabled)
	roadside_event.set_high_contrast(high_contrast_enabled)
	debrief_panel.set_high_contrast(high_contrast_enabled)
	recovery_panel.set_high_contrast(high_contrast_enabled)
	_refresh_controller_copy()
	_refresh_ui()
	if tutorial_mode:
		_refresh_tutorial_ui()
	_journal_event("run_started", {"version": String(ProjectSettings.get_setting("application/config/version", "unknown"))})
	if show_onboarding_on_ready and not FileAccess.file_exists(ONBOARDING_PATH):
		_show_onboarding()

func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	theme = _create_ui_theme(high_contrast_enabled)
	if not high_contrast_enabled:
		VisualContrast.apply_to_tree(self, false)
	if campaign_map != null:
		campaign_map.set_high_contrast(high_contrast_enabled)
	if combat_panel != null:
		combat_panel.set_high_contrast(high_contrast_enabled)
	if settlement_hub != null:
		settlement_hub.set_high_contrast(high_contrast_enabled)
	if journey_transition != null:
		journey_transition.set_high_contrast(high_contrast_enabled)
	if journey_planner != null:
		journey_planner.set_high_contrast(high_contrast_enabled)
	if road_contact != null:
		road_contact.set_high_contrast(high_contrast_enabled)
	if journey_arrival != null:
		journey_arrival.set_high_contrast(high_contrast_enabled)
	if roadside_event != null:
		roadside_event.set_high_contrast(high_contrast_enabled)
	if debrief_panel != null:
		debrief_panel.set_high_contrast(high_contrast_enabled)
	if recovery_panel != null:
		recovery_panel.set_high_contrast(high_contrast_enabled)
	for button_data in [
		[contract_accept_button, Color("#285348"), Color("#73c99b")],
		[advance_encounter_button, Color("#593e28"), Color("#e8c58e")],
		[feedback_button, Color("#285348"), Color("#73c99b")],
		[march_on_button, Color("#5a4528"), Color("#e3b963")]
	]:
		if button_data[0] != null:
			_accent_button(button_data[0], button_data[1], button_data[2])
	_refresh_ui()

func set_controller_layout(layout_id: String) -> void:
	controller_layout_id = ControllerLayout.normalize(layout_id)
	_refresh_controller_copy()
	_refresh_ui()

func _controller_confirm_label() -> String:
	return ControllerLayout.confirm_label(controller_layout_id)

func _controller_cancel_label() -> String:
	return ControllerLayout.cancel_label(controller_layout_id)

func _confirm_shortcut() -> String:
	return "%s / Enter" % _controller_confirm_label()

func _cancel_shortcut(spaced: bool = true) -> String:
	return "%s / Esc" % _controller_cancel_label() if spaced else "%s/Esc" % _controller_cancel_label()

func _refresh_controller_copy() -> void:
	if focus_chassis_button != null:
		focus_chassis_button.text = "EDIT CHASSIS · ARROWS + %s" % _controller_confirm_label()
		focus_chassis_button.tooltip_text = "Move keyboard or controller focus to the chassis. Use arrows to move, %s to select or place, and %s to return." % [_confirm_shortcut(), _cancel_shortcut()]
	if combat_inspect_button != null:
		combat_inspect_button.tooltip_text = "Move keyboard or controller focus to the chassis. Choose a system with %s to return directly to Seal Compartment." % _confirm_shortcut()
	if results_inspect_button != null:
		results_inspect_button.tooltip_text = "Move keyboard or controller focus to the final chassis. Use arrows to review systems, %s to inspect one, and %s to return to the debrief." % [_confirm_shortcut(), _cancel_shortcut()]
	if fortress_panel != null:
		fortress_panel.set_controller_labels(_controller_confirm_label(), _controller_cancel_label())
	if settlement_hub != null:
		settlement_hub.set_controller_cancel_label(_controller_cancel_label())
	if journey_transition != null:
		journey_transition.set_controller_cancel_label(_controller_cancel_label())
	if journey_planner != null:
		journey_planner.set_controller_cancel_label(_controller_cancel_label())
	if road_contact != null:
		road_contact.set_controller_cancel_label(_controller_cancel_label())
	if journey_arrival != null:
		journey_arrival.set_controller_cancel_label(_controller_cancel_label())
	if roadside_event != null:
		roadside_event.set_controller_cancel_label(_controller_cancel_label())
	if debrief_panel != null:
		debrief_panel.set_controller_cancel_label(_controller_cancel_label())
	if recovery_panel != null:
		recovery_panel.set_controller_cancel_label(_controller_cancel_label())

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion_enabled = enabled
	if settlement_hub != null:
		settlement_hub.set_reduced_motion(enabled)
	if journey_transition != null:
		journey_transition.set_reduced_motion(enabled)
	if road_contact != null:
		road_contact.set_reduced_motion(enabled)

func _reset_state() -> void:
	state = LongMarchState.new(3301 if tutorial_mode else (2204 if starting_region_id == "flooded_veyru" else 1107))
	if tutorial_mode:
		state.start_tutorial()
		tutorial_director = TutorialDirectorScript.new()
	elif starting_region_id == "flooded_veyru":
		state.place_module("steam_lance_engine", Vector2i(0, 0))
		state.place_module("coal_cell", Vector2i(0, 1))
		state.place_module("generator_core", Vector2i(2, 0))
		state.place_module("crew_quarters", Vector2i(2, 1))
		state.place_module("field_workshop", Vector2i(2, 2))
		state.place_module("water_condenser", Vector2i(2, 3))
		state.place_module("parts_crate", Vector2i(4, 2))
	else:
		state.place_module("steam_lance_engine", Vector2i(0, 0))
		state.place_module("coal_cell", Vector2i(0, 1))
		state.place_module("generator_core", Vector2i(2, 0))
		state.place_module("crew_quarters", Vector2i(4, 0))
		state.place_module("ammunition_lift", Vector2i(2, 1))
		state.place_module("field_workshop", Vector2i(3, 1))
		state.place_module("repeater_gun", Vector2i(3, 2), true)
	if not tutorial_mode:
		state.seed_starter_inventory()
		if starting_region_id == "flooded_veyru":
			state.start_flooded_veyru()
		else:
			state.start_campaign()
	state.set_regional_developments(starting_regional_developments)
	selected_campaign_node_id = ""
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false
	last_synced_combat_target_id = ""
	result_recorded = false
	results_chassis_reviewed = false
	last_rendered_phase = ""
	settlement_hub_active = true
	settlement_detail_mode = "hub"
	journey_transition_active = false
	journey_transition_view = {}
	journey_planner_active = false
	contact_inspection_active = false
	journey_arrival_active = false
	journey_arrival_view = {}
	journey_departure_snapshot = {}
	debrief_inspection_active = false
	contact_fortress_before = {}
	last_recovery_receipt = ""
	last_journey_receipt = ""
	if tutorial_mode:
		tutorial_lesson_snapshot = state.serialize()
		tutorial_lesson_snapshots = {"place_engine": tutorial_lesson_snapshot.duplicate(true)}
		tutorial_director_snapshots = {"place_engine": tutorial_director.serialize()}

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

	main_columns = HBoxContainer.new()
	main_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_columns.add_theme_constant_override("separation", 18)
	margin.add_child(main_columns)

	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(760, 0)
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 10)
	main_columns.add_child(left_column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	left_column.add_child(header)
	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	header.add_child(title)
	pause_button = Button.new()
	pause_button.text = "PAUSE · ESC / %s" % _controller_cancel_label()
	pause_button.custom_minimum_size = Vector2(240, 42)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.tooltip_text = "Pause the march to save, review the briefing, change settings, restart, or return to the title."
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	header.add_child(pause_button)

	left_scroll = ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_column.add_child(left_scroll)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(760, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)

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
	fortress_panel.focus_entered.connect(_refresh_pause_action_hint)
	fortress_panel.focus_exited.connect(func() -> void: _refresh_pause_action_hint.call_deferred())
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
	main_columns.add_child(right_scroll)
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
	settlement_hub_return_button = Button.new()
	settlement_hub_return_button.text = "RETURN TO SETTLEMENT BAZAAR"
	settlement_hub_return_button.custom_minimum_size = Vector2(0, 46)
	settlement_hub_return_button.tooltip_text = "Leave the detailed workbench or map and return to the settlement overview."
	settlement_hub_return_button.visible = false
	settlement_hub_return_button.pressed.connect(_on_return_to_settlement_hub)
	controls.add_child(settlement_hub_return_button)
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
	focus_chassis_button.text = "EDIT CHASSIS"
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
	dependency_card_panel = PanelContainer.new()
	dependency_card_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 10))
	controls.add_child(dependency_card_panel)
	dependency_card_label = Label.new()
	dependency_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dependency_card_label.custom_minimum_size = Vector2(300, 116)
	dependency_card_label.add_theme_font_size_override("font_size", 11)
	dependency_card_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	dependency_card_panel.add_child(dependency_card_label)

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
	settlement_routes_button = Button.new()
	settlement_routes_button.text = "REVIEW NEXT ROADS"
	settlement_routes_button.custom_minimum_size = Vector2(0, 56)
	settlement_routes_button.tooltip_text = "Move to the next-road map without spending a service action or committing the fortress."
	settlement_routes_button.pressed.connect(_on_settlement_routes_pressed)
	settlement_group.add_child(settlement_routes_button)
	final_journey_button = Button.new()
	final_journey_button.text = "Depart for Meridian Pass"
	final_journey_button.tooltip_text = "Begin the final Siege Beast encounter using the selected doctrine."
	final_journey_button.pressed.connect(_on_final_journey_pressed)
	settlement_group.add_child(final_journey_button)
	controls.add_child(settlement_group)

	contract_group = VBoxContainer.new()
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
	var contract_actions := VBoxContainer.new()
	contract_actions.add_theme_constant_override("separation", 8)
	contract_accept_button = Button.new()
	contract_accept_button.text = "GUARD THE CONVOY\nMORROWLINE · EACH ENEMY +1 HP\nON ARRIVAL · +30 ASHMARKS · +2 TRUST"
	contract_accept_button.custom_minimum_size = Vector2(0, 74)
	contract_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_accept_button.tooltip_text = "Accept a harder Morrowline approach in exchange for payment, trust, and 2 Morrowline service actions if the convoy arrives."
	contract_accept_button.pressed.connect(_on_guard_contract_pressed.bind(true))
	_accent_button(contract_accept_button, Color("#285348"), Color("#73c99b"))
	contract_actions.add_child(contract_accept_button)
	contract_decline_button = Button.new()
	contract_decline_button.text = "TRAVEL UNBOUND\nNO EXTRA ENEMY HP\nNO CONTRACT PAYOUT OR TRUST"
	contract_decline_button.custom_minimum_size = Vector2(0, 68)
	contract_decline_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_decline_button.tooltip_text = "Decline the escort, avoid its extra enemy endurance, and forgo the contract reward."
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
	campaign_pressure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_pressure_label.custom_minimum_size = Vector2(320, 36)
	campaign_pressure_label.add_theme_color_override("font_color", Color("#e89270"))
	controls.add_child(campaign_pressure_label)
	campaign_path_label = Label.new()
	campaign_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_path_label.add_theme_color_override("font_color", Color("#aab6ba"))
	controls.add_child(campaign_path_label)
	campaign_comparison_panel = PanelContainer.new()
	campaign_comparison_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 9))
	controls.add_child(campaign_comparison_panel)
	campaign_comparison_label = Label.new()
	campaign_comparison_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_comparison_label.add_theme_font_size_override("font_size", 11)
	campaign_comparison_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	campaign_comparison_panel.add_child(campaign_comparison_label)
	campaign_map = CampaignMapView.new()
	campaign_map.node_selected.connect(_on_campaign_node_selected)
	campaign_map.route_committed.connect(_on_campaign_route_committed)
	campaign_map.node_inspected.connect(_on_campaign_node_inspected)
	campaign_node_buttons = campaign_map.node_buttons
	campaign_commit_button = campaign_map.commit_button
	campaign_commit_button.set_meta("long_march_audio_manual_press", true)
	campaign_map.remove_child(campaign_commit_button)

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
	campaign_commit_intel_label = Label.new()
	campaign_commit_intel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_commit_intel_label.add_theme_font_size_override("font_size", 11)
	campaign_commit_intel_label.add_theme_color_override("font_color", Color("#aab6ba"))
	campaign_commit_intel_label.visible = false
	controls.add_child(campaign_commit_intel_label)
	campaign_action_row = HBoxContainer.new()
	campaign_action_row.add_theme_constant_override("separation", 8)
	controls.add_child(campaign_action_row)
	campaign_action_row.add_child(campaign_commit_button)
	campaign_cancel_button = Button.new()
	campaign_cancel_button.text = "CANCEL\nBACK TO MAP"
	campaign_cancel_button.tooltip_text = "Clear this route preview without spending fuel, advancing time, or beginning the encounter."
	campaign_cancel_button.custom_minimum_size = Vector2(110, 64)
	campaign_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	campaign_cancel_button.size_flags_stretch_ratio = 0.48
	campaign_cancel_button.visible = false
	campaign_cancel_button.pressed.connect(_on_campaign_route_cancelled)
	campaign_action_row.add_child(campaign_cancel_button)
	campaign_commit_button.focus_neighbor_bottom = campaign_commit_button.get_path_to(campaign_cancel_button)
	campaign_cancel_button.focus_neighbor_top = campaign_cancel_button.get_path_to(campaign_commit_button)

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
	travel_button.set_meta("long_march_audio_cue", "route_commit")
	travel_button.pressed.connect(_on_travel_pressed)
	controls.add_child(travel_button)

	advance_encounter_button = Button.new()
	advance_encounter_button.text = "Advance journey battle"
	advance_encounter_button.custom_minimum_size = Vector2(0, 54)
	advance_encounter_button.tooltip_text = "Resolve one readable encounter step."
	advance_encounter_button.pressed.connect(_on_advance_encounter_pressed)
	_accent_button(advance_encounter_button, Color("#593e28"), Color("#e8c58e"))
	controls.add_child(advance_encounter_button)
	advance_warning_label = Label.new()
	advance_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advance_warning_label.add_theme_font_size_override("font_size", 11)
	advance_warning_label.add_theme_color_override("font_color", Color("#ff9d8f"))
	advance_warning_label.visible = false
	controls.add_child(advance_warning_label)
	combat_inspect_button = Button.new()
	combat_inspect_button.text = "INSPECT CHASSIS · CHOOSE SEAL TARGET"
	combat_inspect_button.custom_minimum_size = Vector2(0, 44)
	combat_inspect_button.tooltip_text = "Move keyboard or controller focus to the chassis. Choose a system with A or Enter to return directly to Seal Compartment."
	combat_inspect_button.pressed.connect(_focus_chassis_for_combat)
	controls.add_child(combat_inspect_button)

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
		intervention.set_meta("intervention_id", String(action.id))
		intervention.pressed.connect(_use_intervention.bind(String(action.id)))
		intervention.focus_entered.connect(_show_intervention_preview.bind(String(action.id)))
		intervention.focus_exited.connect(_restore_intervention_preview_deferred)
		intervention.mouse_entered.connect(_show_intervention_preview.bind(String(action.id)))
		intervention.mouse_exited.connect(_restore_intervention_preview_deferred)
		intervention_buttons.append(intervention)
		controls.add_child(intervention)

	save_button = Button.new()
	save_button.text = "Save march"
	save_button.visible = false
	save_button.pressed.connect(_on_save_pressed)
	controls.add_child(save_button)
	load_button = Button.new()
	load_button.text = "Load march"
	load_button.visible = false
	load_button.pressed.connect(_on_load_pressed)
	controls.add_child(load_button)

	var reset_button := Button.new()
	reset_button.text = "Reset run"
	reset_button.visible = false
	reset_button.pressed.connect(_on_reset_pressed)
	controls.add_child(reset_button)

	results_group = VBoxContainer.new()
	results_group.add_theme_constant_override("separation", 6)
	controls.add_child(results_group)
	results_heading = Label.new()
	results_heading.text = "MARCH DEBRIEF"
	results_heading.add_theme_font_size_override("font_size", 17)
	results_heading.add_theme_color_override("font_color", Color("#e8c58e"))
	results_group.add_child(results_heading)
	results_inspect_button = Button.new()
	results_inspect_button.text = "INSPECT FINAL CHASSIS"
	results_inspect_button.custom_minimum_size = Vector2(0, 44)
	results_inspect_button.tooltip_text = "Move keyboard or controller focus to the final chassis. Use arrows to review systems, A or Enter to inspect one, and B or Escape to return to the debrief."
	results_inspect_button.pressed.connect(_focus_chassis_for_results)
	results_group.add_child(results_inspect_button)
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
	results_record_label = Label.new()
	results_record_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_record_label.add_theme_font_size_override("font_size", 11)
	results_record_label.add_theme_color_override("font_color", Color("#aab6ba"))
	results_summary_stack.add_child(results_record_label)
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
	march_on_button = Button.new()
	march_on_button.text = "MARCH ON"
	march_on_button.custom_minimum_size = Vector2(0, 54)
	march_on_button.tooltip_text = "Begin a fresh journey in the other playable region after confirmation."
	march_on_button.pressed.connect(_on_march_on_pressed)
	_accent_button(march_on_button, Color("#5a4528"), Color("#e3b963"))
	results_group.add_child(march_on_button)
	var results_actions := HBoxContainer.new()
	results_actions.add_theme_constant_override("separation", 8)
	results_group.add_child(results_actions)
	play_again_button = Button.new()
	play_again_button.text = "PLAY AGAIN"
	play_again_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_again_button.pressed.connect(_on_play_again_pressed)
	results_actions.add_child(play_again_button)
	results_title_button = Button.new()
	results_title_button.text = "SAVE RESULT & RETURN"
	results_title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	results_title_button.tooltip_text = "Save the completed run to the local Continue slot, then return to the title."
	results_title_button.pressed.connect(_on_results_title_pressed)
	results_actions.add_child(results_title_button)
	current_order_button.focus_neighbor_top = current_order_button.get_path_to(results_title_button)
	current_order_button.focus_neighbor_bottom = current_order_button.get_path_to(results_inspect_button)
	results_inspect_button.focus_neighbor_top = results_inspect_button.get_path_to(current_order_button)
	results_inspect_button.focus_neighbor_bottom = results_inspect_button.get_path_to(feedback_button)
	feedback_button.focus_neighbor_top = feedback_button.get_path_to(results_inspect_button)
	feedback_button.focus_neighbor_bottom = feedback_button.get_path_to(march_on_button)
	march_on_button.focus_neighbor_top = march_on_button.get_path_to(feedback_button)
	march_on_button.focus_neighbor_bottom = march_on_button.get_path_to(play_again_button)
	play_again_button.focus_neighbor_top = play_again_button.get_path_to(march_on_button)
	play_again_button.focus_neighbor_right = play_again_button.get_path_to(results_title_button)
	play_again_button.focus_neighbor_bottom = play_again_button.get_path_to(feedback_button)
	results_title_button.focus_neighbor_top = results_title_button.get_path_to(march_on_button)
	results_title_button.focus_neighbor_left = results_title_button.get_path_to(play_again_button)
	results_title_button.focus_neighbor_bottom = results_title_button.get_path_to(current_order_button)
	_configure_focus_cycle([current_order_button, results_inspect_button, feedback_button, march_on_button, play_again_button, results_title_button])
	controls.move_child(results_group, guidance_label.get_index() + 1)

	how_to_play_button = Button.new()
	how_to_play_button.text = "OPEN FIELD BRIEFING"
	how_to_play_button.tooltip_text = "Review the seven-step Marchmaster briefing without leaving this run."
	how_to_play_button.pressed.connect(_show_onboarding.bind(true))
	controls.add_child(how_to_play_button)
	desk_scroll_tail = Control.new()
	desk_scroll_tail.name = "DeskScrollTail"
	desk_scroll_tail.custom_minimum_size = Vector2(0, 32)
	desk_scroll_tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controls.add_child(desk_scroll_tail)

	settlement_hub = SettlementHubScene.instantiate()
	settlement_hub.pause_requested.connect(func() -> void: pause_requested.emit())
	settlement_hub.action_requested.connect(_on_settlement_hub_action)
	margin.add_child(settlement_hub)
	recovery_panel = RecoveryPanelScene.instantiate()
	recovery_panel.pause_requested.connect(func() -> void: pause_requested.emit())
	recovery_panel.repair_requested.connect(_on_recovery_repair_requested)
	recovery_panel.refuel_requested.connect(_on_recovery_refuel_requested)
	recovery_panel.hull_requested.connect(_on_recovery_hull_requested)
	recovery_panel.routes_requested.connect(_on_settlement_routes_pressed)
	margin.add_child(recovery_panel)
	journey_transition = JourneyTransitionScene.instantiate()
	journey_transition.pause_requested.connect(func() -> void: pause_requested.emit())
	journey_transition.continue_requested.connect(_on_journey_transition_continued)
	margin.add_child(journey_transition)
	journey_planner = JourneyPlannerScene.instantiate()
	journey_planner.pause_requested.connect(func() -> void: pause_requested.emit())
	journey_planner.return_requested.connect(_on_journey_planner_returned)
	margin.add_child(journey_planner)
	journey_planner.attach_route_controls(campaign_map, campaign_comparison_panel, route_preview_label, doctrine_group, doctrine_detail_label, campaign_commit_intel_label, campaign_action_row)
	road_contact = RoadContactScene.instantiate()
	road_contact.pause_requested.connect(func() -> void: pause_requested.emit())
	road_contact.advance_requested.connect(_on_advance_encounter_pressed)
	road_contact.inspect_requested.connect(_focus_chassis_for_combat)
	road_contact.intervention_requested.connect(_use_intervention)
	margin.add_child(road_contact)
	roadside_event = RoadsideEventScene.instantiate()
	roadside_event.pause_requested.connect(func() -> void: pause_requested.emit())
	roadside_event.choice_requested.connect(_on_roadside_event_choice)
	margin.add_child(roadside_event)
	journey_arrival = JourneyArrivalScene.instantiate()
	journey_arrival.pause_requested.connect(func() -> void: pause_requested.emit())
	journey_arrival.continue_requested.connect(_on_journey_arrival_continued)
	margin.add_child(journey_arrival)
	debrief_panel = DebriefPanelScene.instantiate()
	debrief_panel.pause_requested.connect(func() -> void: pause_requested.emit())
	debrief_panel.inspect_requested.connect(_open_debrief_inspection)
	debrief_panel.notes_requested.connect(_open_debrief_notes)
	debrief_panel.replay_requested.connect(_on_play_again_pressed)
	debrief_panel.march_on_requested.connect(_on_march_on_pressed)
	debrief_panel.title_requested.connect(_on_results_title_pressed)
	margin.add_child(debrief_panel)

	_build_onboarding_overlay()
	_build_feedback_overlay()
	_connect_desk_focus_scrolling()

func _initialize_tutorial_ui() -> void:
	tutorial_objective_view = TutorialObjectiveViewScript.new()
	tutorial_objective_view.name = "TutorialObjective"
	tutorial_objective_view.show_me_requested.connect(_tutorial_show_me)
	tutorial_objective_view.reset_requested.connect(_reset_tutorial_lesson)
	tutorial_objective_view.skip_requested.connect(func() -> void: return_to_title_requested.emit())
	var controls := guidance_label.get_parent()
	controls.add_child(tutorial_objective_view)
	controls.move_child(tutorial_objective_view, guidance_label.get_index())
	tutorial_completion_view = TutorialCompletionViewScript.new()
	tutorial_completion_view.name = "TutorialCompletion"
	tutorial_completion_view.visible = false
	tutorial_completion_view.begin_campaign_requested.connect(func() -> void: march_on_requested.emit("ashgate_lowlands"))
	tutorial_completion_view.repeat_lesson_requested.connect(_repeat_tutorial_lesson)
	tutorial_completion_view.title_requested.connect(func() -> void: return_to_title_requested.emit())
	add_child(tutorial_completion_view)

func _refresh_tutorial_ui() -> void:
	if not tutorial_mode or tutorial_director == null or tutorial_objective_view == null:
		return
	var complete := tutorial_director.lesson_id == "complete"
	tutorial_objective_view.configure(tutorial_director.current_copy(), tutorial_director.receipt)
	tutorial_objective_view.visible = not complete and not onboarding_overlay.visible and not feedback_overlay.visible
	if tutorial_completion_view != null:
		tutorial_completion_view.visible = complete
		if complete:
			tutorial_completion_view.open(tutorial_director.completed_lessons)
			tutorial_completion_view.move_to_front()

func _tutorial_advance(next_lesson: String, receipt: String) -> void:
	if not tutorial_mode or tutorial_director == null:
		return
	if tutorial_director.advance(next_lesson, receipt):
		tutorial_lesson_snapshot = state.serialize()
		tutorial_lesson_snapshots[next_lesson] = tutorial_lesson_snapshot.duplicate(true)
		tutorial_director_snapshots[next_lesson] = tutorial_director.serialize()
		_checkpoint("tutorial_lesson_completed")
		if next_lesson == "complete":
			_mark_tutorial_complete()
		_refresh_tutorial_ui()

func _mark_tutorial_complete() -> void:
	var marker := FileAccess.open(TUTORIAL_COMPLETE_PATH, FileAccess.WRITE)
	if marker != null:
		marker.store_string("completed")
		marker.close()

func _tutorial_observe_state() -> void:
	if not tutorial_mode or tutorial_director == null:
		return
	var previous := tutorial_director.lesson_id
	if tutorial_director.observe_state(state):
		tutorial_lesson_snapshot = state.serialize()
		tutorial_lesson_snapshots[tutorial_director.lesson_id] = tutorial_lesson_snapshot.duplicate(true)
		tutorial_director_snapshots[tutorial_director.lesson_id] = tutorial_director.serialize()
		_checkpoint("tutorial_lesson_completed")
		if previous == "place_engine":
			selected_module_id = "repeater_gun"
			selected_module_cell = Vector2i(-1, -1)
			placement_rotated = true
			_select_module_option(selected_module_id)
		_refresh_tutorial_ui()

func _tutorial_observe_inspection(module_id: String) -> void:
	if not tutorial_mode or tutorial_director == null:
		return
	if tutorial_director.observe_inspection(module_id):
		tutorial_lesson_snapshot = state.serialize()
		tutorial_lesson_snapshots[tutorial_director.lesson_id] = tutorial_lesson_snapshot.duplicate(true)
		tutorial_director_snapshots[tutorial_director.lesson_id] = tutorial_director.serialize()
		_checkpoint("tutorial_lesson_completed")
		_refresh_tutorial_ui()
		return
	if tutorial_director.lesson_id == "damage":
		var module: Dictionary = {}
		for installed in state.modules:
			if String(installed.get("id", "")) == module_id:
				module = installed
				break
		var maximum := int(state.module_definition(module_id).get("durability", 0))
		if not module.is_empty() and int(module.get("durability", maximum)) < maximum:
			_tutorial_advance("victory", "DAMAGE TRACED · Durability changed, and the system card shows whether the dependency chain still holds.")

func _reset_tutorial_lesson() -> void:
	if not tutorial_mode or tutorial_director == null or tutorial_lesson_snapshot.is_empty():
		return
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(tutorial_lesson_snapshot)
	if not bool(result.get("ok", false)):
		_set_event("Lesson reset failed: %s." % String(result.get("reason", "snapshot unavailable")))
		return
	state = restored
	if tutorial_director_snapshots.has(tutorial_director.lesson_id):
		tutorial_director.restore(tutorial_director_snapshots[tutorial_director.lesson_id])
	fortress_panel.state = state
	selected_module_cell = Vector2i(-1, -1)
	selected_module_id = "steam_lance_engine" if tutorial_director.lesson_id == "place_engine" else ("repeater_gun" if tutorial_director.lesson_id == "place_weapon" else selected_module_id)
	_select_module_option(selected_module_id)
	journey_transition_active = false
	journey_arrival_active = false
	contact_inspection_active = false
	_set_event("Lesson reset. The fortress has returned to the start of this order.")
	_refresh_ui()

func _repeat_tutorial_lesson(lesson_id: String) -> void:
	if not tutorial_mode or tutorial_director == null or not tutorial_lesson_snapshots.has(lesson_id):
		return
	var restored := LongMarchState.new(0)
	var snapshot: Dictionary = tutorial_lesson_snapshots[lesson_id]
	var result := restored.load_serialized(snapshot)
	if not bool(result.get("ok", false)):
		return
	state = restored
	fortress_panel.state = state
	tutorial_director.lesson_id = lesson_id
	if tutorial_director_snapshots.has(lesson_id):
		tutorial_director.restore(tutorial_director_snapshots[lesson_id])
	tutorial_director.receipt = "LESSON REOPENED · Complete the current order to continue."
	tutorial_lesson_snapshot = snapshot.duplicate(true)
	journey_transition_active = lesson_id == "travel"
	journey_arrival_active = false
	contact_inspection_active = false
	if journey_transition_active:
		journey_transition_view = _restore_journey_transition_view()
	tutorial_completion_view.visible = false
	_refresh_ui()
	_tutorial_show_me.call_deferred()

func _tutorial_show_me() -> void:
	if not tutorial_mode or tutorial_director == null:
		return
	match tutorial_director.lesson_id:
		"place_engine":
			selected_module_id = "steam_lance_engine"
			selected_module_cell = Vector2i(-1, -1)
			_select_module_option(selected_module_id)
			_focus_control(focus_chassis_button)
		"place_weapon":
			selected_module_id = "repeater_gun"
			selected_module_cell = Vector2i(-1, -1)
			placement_rotated = true
			_select_module_option(selected_module_id)
			_focus_control(focus_chassis_button)
		"inspect_machine", "damage":
			if state.can_refit():
				_focus_chassis_for_refit()
			else:
				_focus_chassis_for_combat()
		"plan_road":
			_focus_control(route_option)
		"travel":
			if journey_transition.visible:
				journey_transition.focus_default()
		"read_contact", "respond", "victory":
			if road_contact.visible:
				road_contact.focus_default()
		"repair":
			_focus_control(settlement_repair_button)
		"complete":
			march_on_requested.emit("ashgate_lowlands")

func _connect_desk_focus_scrolling() -> void:
	var controls: Array[Control] = [
		contract_accept_button,
		contract_decline_button,
		doctrine_option,
		campaign_commit_button,
		campaign_cancel_button,
		module_option,
		focus_chassis_button,
		rotate_button,
		remove_button,
		settlement_repair_button,
		settlement_refuel_button,
		settlement_hull_button,
		settlement_routes_button,
		final_journey_button,
		recruit_iven_button,
		route_option,
		travel_button,
		advance_encounter_button,
		combat_inspect_button,
		results_inspect_button,
		feedback_button,
		march_on_button,
		play_again_button,
		results_title_button,
		current_order_button,
		how_to_play_button
	]
	controls.append_array(campaign_event_buttons)
	controls.append_array(campaign_node_buttons)
	controls.append_array(intervention_buttons)
	for control in controls:
		_connect_desk_focus_scroll(control)

func _connect_desk_focus_scroll(control: Control) -> void:
	var callback := _on_desk_control_focused.bind(control)
	if not control.focus_entered.is_connected(callback):
		control.focus_entered.connect(callback)

func _connect_campaign_node_focus_scrolling() -> void:
	for control in campaign_node_buttons:
		_connect_desk_focus_scroll(control)

func _on_desk_control_focused(control: Control) -> void:
	pending_desk_scroll_control = control
	desk_scroll_frames_remaining = 2
	if desk_scroll_queued:
		return
	desk_scroll_queued = true
	get_tree().process_frame.connect(_advance_pending_desk_scroll, CONNECT_ONE_SHOT)

func _advance_pending_desk_scroll() -> void:
	_scroll_action_context_into_view(pending_desk_scroll_control)
	desk_scroll_frames_remaining -= 1
	if desk_scroll_frames_remaining > 0:
		get_tree().process_frame.connect(_advance_pending_desk_scroll, CONNECT_ONE_SHOT)
		return
	desk_scroll_queued = false
	desk_scroll_frames_remaining = 0
	pending_desk_scroll_control = null

func _show_intervention_preview(intervention_id: String) -> void:
	if state.phase not in ["battle", "final_battle"] or state.encounter_intervention_used:
		return
	var preview_text := String(intervention_preview_texts.get(intervention_id, ""))
	if not preview_text.is_empty():
		intervention_help_label.text = preview_text

func _restore_intervention_preview_deferred() -> void:
	_apply_focused_intervention_preview.call_deferred()

func _apply_focused_intervention_preview() -> void:
	if state.phase not in ["battle", "final_battle"] or state.encounter_intervention_used:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Button:
		var focused_button := focused as Button
		if focused_button in intervention_buttons:
			_show_intervention_preview(String(focused_button.get_meta("intervention_id", "")))
			return
	intervention_help_label.text = intervention_overview_text

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
	for index in range(_active_onboarding_labels().size()):
		var step_button := Button.new()
		step_button.custom_minimum_size = Vector2(0, 38)
		step_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		step_button.add_theme_font_size_override("font_size", 10)
		step_button.tooltip_text = "Open this briefing topic without changing the march."
		step_button.pressed.connect(_on_onboarding_topic_pressed.bind(index))
		stepper.add_child(step_button)
		onboarding_step_buttons.append(step_button)
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
	onboarding_progress_label.text = "D-pad / arrows or Tab move · %s confirms · %s skips" % [_confirm_shortcut(), _cancel_shortcut()]
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
	panel.name = "FeedbackPanel"
	panel.custom_minimum_size = Vector2(700, 650)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191dfa"), Color("#688587"), 2, 8, 0))
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
	feedback_context_label = Label.new()
	feedback_context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_context_label.add_theme_font_size_override("font_size", 12)
	feedback_context_label.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(feedback_context_label)
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
	feedback_path_button = Button.new()
	feedback_path_button.text = "COPY REPORT PATH"
	feedback_path_button.tooltip_text = "Save a report first."
	feedback_path_button.visible = false
	feedback_path_button.pressed.connect(_copy_feedback_path)
	actions.add_child(feedback_path_button)
	feedback_save_button = Button.new()
	feedback_save_button.text = "SAVE NOTES LOCALLY"
	feedback_save_button.pressed.connect(_save_feedback)
	actions.add_child(feedback_save_button)
	content.add_child(actions)
	_configure_feedback_focus()

func _configure_feedback_focus() -> void:
	var has_report := feedback_path_button.visible and not feedback_path_button.disabled
	var action_before_save: Control = feedback_path_button if has_report else feedback_close_button
	feedback_close_button.focus_neighbor_left = feedback_close_button.get_path_to(feedback_save_button)
	feedback_close_button.focus_neighbor_right = feedback_close_button.get_path_to(feedback_path_button if has_report else feedback_save_button)
	feedback_path_button.focus_neighbor_left = feedback_path_button.get_path_to(feedback_close_button)
	feedback_path_button.focus_neighbor_right = feedback_path_button.get_path_to(feedback_save_button)
	feedback_save_button.focus_neighbor_left = feedback_save_button.get_path_to(action_before_save)
	feedback_save_button.focus_neighbor_right = feedback_save_button.get_path_to(feedback_close_button)
	feedback_clear_text.focus_neighbor_top = feedback_clear_text.get_path_to(feedback_save_button)
	feedback_clear_text.focus_neighbor_bottom = feedback_clear_text.get_path_to(feedback_confusing_text)
	feedback_confusing_text.focus_neighbor_top = feedback_confusing_text.get_path_to(feedback_clear_text)
	feedback_confusing_text.focus_neighbor_bottom = feedback_confusing_text.get_path_to(feedback_score_option)
	feedback_score_option.focus_neighbor_top = feedback_score_option.get_path_to(feedback_confusing_text)
	feedback_score_option.focus_neighbor_bottom = feedback_score_option.get_path_to(feedback_close_button)
	feedback_close_button.focus_neighbor_top = feedback_close_button.get_path_to(feedback_score_option)
	feedback_close_button.focus_neighbor_bottom = feedback_close_button.get_path_to(feedback_clear_text)
	feedback_path_button.focus_neighbor_top = feedback_path_button.get_path_to(feedback_score_option)
	feedback_path_button.focus_neighbor_bottom = feedback_path_button.get_path_to(feedback_clear_text)
	feedback_save_button.focus_neighbor_top = feedback_save_button.get_path_to(feedback_score_option)
	feedback_save_button.focus_neighbor_bottom = feedback_save_button.get_path_to(feedback_clear_text)
	var focus_controls: Array = [feedback_clear_text, feedback_confusing_text, feedback_score_option, feedback_close_button]
	if has_report:
		focus_controls.append(feedback_path_button)
	focus_controls.append(feedback_save_button)
	_configure_focus_cycle(focus_controls)

func _show_onboarding(reopened: bool = false) -> void:
	onboarding_reopened = reopened
	onboarding_step = _contextual_onboarding_step() if reopened else 0
	onboarding_viewed_steps = {onboarding_step: true}
	onboarding_overlay.visible = true
	_refresh_onboarding()
	onboarding_next_button.grab_focus()
	if reopened:
		_journal_event("onboarding_reopened")

func _active_onboarding_labels() -> Array:
	return VEYRU_ONBOARDING_LABELS if state.campaign_region_id == "flooded_veyru" else ONBOARDING_LABELS

func _active_onboarding_steps() -> Array:
	return VEYRU_ONBOARDING_STEPS if state.campaign_region_id == "flooded_veyru" else ONBOARDING_STEPS

func _contextual_onboarding_step() -> int:
	if state.phase in ["battle", "final_battle", "results"]:
		return 6
	if _active_contract_status() == "offered":
		return 0
	if not state.campaign_event_pending.is_empty():
		if state.campaign_event_pending == "archive_broadcast":
			return 6
		if state.campaign_event_pending.begins_with("mara_"):
			return 3
		return 5
	if state.phase == "settlement":
		return 3
	if state.campaign_active and state.phase in ["refit", "map"]:
		return 5
	return 0

func _on_onboarding_topic_pressed(step_index: int) -> void:
	var steps := _active_onboarding_steps()
	if step_index < 0 or step_index >= steps.size():
		return
	onboarding_step = step_index
	onboarding_viewed_steps[onboarding_step] = true
	_refresh_onboarding()
	onboarding_step_buttons[onboarding_step].grab_focus()

func _refresh_onboarding() -> void:
	var steps := _active_onboarding_steps()
	var labels := _active_onboarding_labels()
	onboarding_step = mini(onboarding_step, steps.size() - 1)
	var step: Dictionary = steps[onboarding_step]
	onboarding_title_label.text = String(step.title)
	onboarding_body_label.text = String(step.body)
	onboarding_action_label.text = String(step.action)
	onboarding_progress_label.text = "%s briefing %d of %d  ·  D-pad / arrows or Tab move  ·  %s confirms  ·  %s %s" % ["Veyru" if state.campaign_region_id == "flooded_veyru" else "Ashgate", onboarding_step + 1, steps.size(), _confirm_shortcut(), _cancel_shortcut(), "closes" if onboarding_reopened else "closes for this run"]
	for index in range(onboarding_step_buttons.size()):
		var button := onboarding_step_buttons[index]
		var is_current := index == onboarding_step
		var was_viewed := onboarding_viewed_steps.has(index)
		button.text = "%s %02d %s" % ["●" if is_current else ("✓" if was_viewed else "—"), index + 1, labels[index]]
		button.add_theme_color_override("font_color", Color("#ffffff") if is_current else (Color("#9fddbd") if was_viewed else Color("#87979b")))
		button.add_theme_color_override("font_hover_color", Color("#ffffff"))
		button.add_theme_color_override("font_focus_color", Color("#ffffff"))
		button.add_theme_stylebox_override("normal", _flat_style(Color("#4b405d") if is_current else (Color("#183329") if was_viewed else Color("#182127")), Color("#eee2ff") if is_current else (Color("#4e8d72") if was_viewed else Color("#35474d")), 2 if is_current else 1, 4, 2))
		button.add_theme_stylebox_override("hover", _flat_style(Color("#354c50"), Color("#9fd2c2"), 2, 4, 2))
		button.add_theme_stylebox_override("pressed", _flat_style(Color("#283c40"), Color("#f0d29d"), 2, 4, 2))
		button.add_theme_stylebox_override("focus", _flat_style(Color("#4b405d") if is_current else Color("#25383a"), Color.WHITE, 3, 4, 1))
	onboarding_back_button.disabled = onboarding_step == 0
	onboarding_skip_button.focus_neighbor_right = onboarding_skip_button.get_path_to(onboarding_next_button if onboarding_back_button.disabled else onboarding_back_button)
	onboarding_next_button.focus_neighbor_left = onboarding_next_button.get_path_to(onboarding_skip_button if onboarding_back_button.disabled else onboarding_back_button)
	var current_topic_button := onboarding_step_buttons[onboarding_step]
	for index in range(onboarding_step_buttons.size()):
		var button := onboarding_step_buttons[index]
		var previous_topic := onboarding_step_buttons[(index - 1 + onboarding_step_buttons.size()) % onboarding_step_buttons.size()]
		var next_topic := onboarding_step_buttons[(index + 1) % onboarding_step_buttons.size()]
		button.focus_neighbor_left = button.get_path_to(previous_topic)
		button.focus_neighbor_right = button.get_path_to(next_topic)
		button.focus_neighbor_top = button.get_path_to(button)
		button.focus_neighbor_bottom = button.get_path_to(onboarding_next_button)
	for button in [onboarding_skip_button, onboarding_back_button, onboarding_next_button]:
		button.focus_neighbor_top = button.get_path_to(current_topic_button)
	var active_actions: Array = [onboarding_skip_button]
	if not onboarding_back_button.disabled:
		active_actions.append(onboarding_back_button)
	active_actions.append(onboarding_next_button)
	var focus_controls: Array = onboarding_step_buttons.duplicate()
	focus_controls.append_array(active_actions)
	_configure_focus_cycle(focus_controls)
	onboarding_next_button.text = ("RETURN TO MARCH" if onboarding_reopened else "ENTER %s" % ("VEYRU" if state.campaign_region_id == "flooded_veyru" else "ASHGATE")) if onboarding_step == steps.size() - 1 else "NEXT"
	onboarding_skip_button.text = "CLOSE BRIEFING" if onboarding_reopened else "SKIP FOR THIS RUN"

func _on_onboarding_back() -> void:
	onboarding_step = maxi(0, onboarding_step - 1)
	onboarding_viewed_steps[onboarding_step] = true
	_refresh_onboarding()

func _on_onboarding_next() -> void:
	if onboarding_step >= _active_onboarding_steps().size() - 1:
		_finish_onboarding(false)
		return
	onboarding_step += 1
	onboarding_viewed_steps[onboarding_step] = true
	_refresh_onboarding()

func _finish_onboarding(skipped: bool) -> void:
	var was_reopened := onboarding_reopened
	if not was_reopened and not skipped:
		var marker := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
		if marker != null:
			marker.store_string(String(ProjectSettings.get_setting("application/config/version", "unknown")))
	onboarding_overlay.visible = false
	_journal_event("onboarding_closed" if was_reopened else ("onboarding_skipped" if skipped else "onboarding_completed"), {"step_reached": onboarding_step + 1})
	onboarding_reopened = false
	focus_current_action.call_deferred()

func show_playtest_notes(return_context: String = "results") -> void:
	feedback_return_context = return_context if return_context in ["results", "pause"] else "results"
	_show_feedback()

func _show_feedback() -> void:
	feedback_context_label.text = "%s · DAY %d · %s · %s" % [
		state.campaign_region_name().to_upper(),
		state.day,
		state.current_location.replace("_", " ").capitalize(),
		state.phase.replace("_", " ").capitalize()
	]
	feedback_close_button.text = "BACK TO PAUSE" if feedback_return_context == "pause" else "BACK TO RESULTS"
	if not last_feedback_path.is_empty() and FileAccess.file_exists(last_feedback_path):
		feedback_status_label.text = "LAST SAVED LOCALLY · %s\nEdits can be saved as a fresh report." % last_feedback_path.get_file()
		feedback_status_label.tooltip_text = last_feedback_path
		feedback_save_button.text = "SAVE AGAIN"
		feedback_path_button.visible = true
		feedback_path_button.disabled = false
		feedback_path_button.tooltip_text = last_feedback_path
	else:
		last_feedback_path = ""
		feedback_status_label.text = "Nothing is sent automatically. Save a local copy when you are ready."
		feedback_status_label.tooltip_text = ""
		feedback_save_button.text = "SAVE NOTES LOCALLY"
		feedback_path_button.visible = false
		feedback_path_button.disabled = true
		feedback_path_button.tooltip_text = "Save a report first."
	_configure_feedback_focus()
	feedback_overlay.visible = true
	feedback_clear_text.grab_focus()
	_journal_event("feedback_opened", {"phase": state.phase, "opened_from": feedback_return_context})

func _hide_feedback() -> void:
	feedback_overlay.visible = false
	if feedback_return_context == "pause":
		feedback_return_context = "results"
		playtest_notes_closed.emit()
	else:
		_focus_control(debrief_panel.notes_button if debrief_panel != null and debrief_panel.visible else feedback_button)

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
		feedback_path_button.visible = true
		feedback_path_button.disabled = false
		feedback_path_button.tooltip_text = last_feedback_path
		_configure_feedback_focus()
		feedback_save_button.grab_focus()
	else:
		last_feedback_path = ""
		feedback_status_label.tooltip_text = ""
		feedback_status_label.text = "Could not save feedback: %s" % String(result.get("reason", "unknown error"))
		feedback_path_button.visible = false
		feedback_path_button.disabled = true
		feedback_path_button.tooltip_text = "Save a report first."
		_configure_feedback_focus()

func _copy_feedback_path() -> void:
	if last_feedback_path.is_empty() or not FileAccess.file_exists(last_feedback_path):
		last_feedback_path = ""
		feedback_status_label.text = "The saved report is no longer available. Save notes again to create a new file."
		feedback_status_label.tooltip_text = ""
		feedback_path_button.visible = false
		feedback_path_button.disabled = true
		feedback_path_button.tooltip_text = "Save a report first."
		_configure_feedback_focus()
		feedback_save_button.grab_focus()
		return
	DisplayServer.clipboard_set(last_feedback_path)
	feedback_status_label.text = "REPORT PATH COPIED · %s\nPaste it into your file browser or message when you choose to share the report." % last_feedback_path.get_file()
	feedback_status_label.tooltip_text = last_feedback_path
	feedback_path_button.grab_focus()
	_journal_event("feedback_path_copied", {"phase": state.phase})

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if feedback_overlay.visible:
		_hide_feedback()
		get_viewport().set_input_as_handled()
	elif onboarding_overlay.visible:
		_finish_onboarding(true)
		get_viewport().set_input_as_handled()
	elif _clear_campaign_route_selection():
		get_viewport().set_input_as_handled()

func _journal_event(event_id: String, properties: Dictionary = {}) -> void:
	if journal != null:
		journal.record(event_id, properties)

func _checkpoint(reason: String) -> void:
	checkpoint_reached.emit(reason)

func _state_journal_summary() -> Dictionary:
	var dependencies := state.dependency_summary()
	return {
		"run_code": current_run_code(),
		"seed": state.seed,
		"phase": state.phase,
		"day": state.day,
		"fuel": state.fuel,
		"money": state.money,
		"hull": state.hull_condition,
		"route": state.journey_route,
		"doctrine": state.target_doctrine,
		"result": state.final_result,
		"campaign_encounters": state.campaign_encounters_completed,
		"campaign_path": state.campaign_path.duplicate(),
		"campaign_decisions": state.campaign_decisions.duplicate(true),
		"campaign_pressure": state.campaign_pressure,
		"campaign_region": state.campaign_region_id,
		"contract": _active_contract_status(),
		"settlement_trust": state.settlement_trust,
		"unused_recovery_actions": state.settlement_actions_remaining,
		"specialist": state.specialist_id,
		"mara_result": state.mara_debrief_line() if state.campaign_decisions.has("mara_meeting") else "",
		"occurrence_history": state.occurrence_history.duplicate(true),
		"ready_systems": int(dependencies.get("ready", 0)),
		"strained_systems": int(dependencies.get("strained", 0)),
		"offline_systems": int(dependencies.get("offline", 0))
	}

func _fortress_presentation_snapshot(active_target_id: String = "") -> Dictionary:
	var modules: Array[Dictionary] = []
	var damaged_count := 0
	var offline_count := 0
	for instance in state.modules:
		var module_id := String(instance.get("id", ""))
		var definition := state.module_definition(module_id)
		var family := String(definition.get("family", "cargo"))
		if "generator" in definition.get("tags", []):
			family = "power"
		var dependency := state.dependency_status(instance)
		var state_name := String(dependency.get("state", "offline"))
		var damaged := int(instance.get("durability", 0)) < int(definition.get("durability", 1))
		if damaged:
			damaged_count += 1
		if state_name == "offline":
			offline_count += 1
		modules.append({
			"id": module_id,
			"family": family,
			"state": state_name,
			"damaged": damaged,
			"sealed": bool(instance.get("sealed", false)),
			"targeted": module_id == active_target_id
		})
	return {
		"modules": modules,
		"hull": state.hull_condition,
		"damaged_count": damaged_count,
		"offline_count": offline_count,
		"active_target_id": active_target_id,
		"region_id": state.campaign_region_id,
		"heat": state.heat,
		"heat_limit": LongMarchState.BASE_HEAT_LIMIT
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

func _desk_context_anchor_for(control: Control) -> Control:
	if control in campaign_node_buttons and campaign_title.visible:
		return campaign_title
	if control in [campaign_commit_button, campaign_cancel_button] and route_preview_label.visible:
		return route_preview_label
	if control in campaign_event_buttons and campaign_event_title.visible:
		return campaign_event_title
	return guidance_label

func _scroll_action_context_into_view(control: Control) -> void:
	if not _control_can_receive_focus(control) or not control.has_focus() or right_scroll == null or not right_scroll.is_ancestor_of(control):
		return
	var viewport_rect := right_scroll.get_global_rect()
	var previous_scroll := right_scroll.scroll_vertical
	var context_anchor := _desk_context_anchor_for(control)
	var context_top := context_anchor.get_global_rect().position.y - viewport_rect.position.y + previous_scroll
	var control_rect := dependency_card_panel.get_global_rect() if dependency_card_panel.visible and control in [module_option, focus_chassis_button, rotate_button, remove_button] else control.get_global_rect()
	var control_bottom := control_rect.end.y - viewport_rect.position.y + previous_scroll
	if control in campaign_event_buttons and campaign_event_title.visible:
		for event_button in campaign_event_buttons:
			if event_button.visible:
				control_bottom = maxf(control_bottom, event_button.get_global_rect().end.y - viewport_rect.position.y + previous_scroll)
	var context_height := control_bottom - context_top
	right_scroll.scroll_vertical = 0
	if control_bottom <= viewport_rect.size.y - 8.0:
		return
	if context_height <= viewport_rect.size.y - 16.0:
		right_scroll.scroll_vertical = maxi(0, ceili(context_top - 8.0))
	else:
		right_scroll.scroll_vertical = maxi(0, ceili(control_bottom - viewport_rect.size.y + 8.0))

func focus_current_action() -> void:
	if onboarding_overlay != null and onboarding_overlay.visible:
		_focus_control(onboarding_next_button)
		return
	if feedback_overlay != null and feedback_overlay.visible:
		_focus_control(feedback_clear_text)
		return
	if debrief_panel != null and debrief_panel.visible:
		debrief_panel.focus_default()
		return
	if recovery_panel != null and recovery_panel.visible:
		recovery_panel.focus_default()
		return
	if journey_transition != null and journey_transition.visible:
		journey_transition.focus_default()
		return
	if journey_arrival != null and journey_arrival.visible:
		journey_arrival.focus_default()
		return
	if roadside_event != null and roadside_event.visible:
		roadside_event.focus_default()
		return
	if road_contact != null and road_contact.visible:
		road_contact.focus_default()
		return
	if tutorial_mode and tutorial_objective_view != null and tutorial_objective_view.visible:
		_focus_control(tutorial_objective_view.show_me_button)
		return
	if journey_planner != null and journey_planner.visible:
		if not selected_campaign_node_id.is_empty() and _focus_control(campaign_commit_button):
			return
		journey_planner.focus_default()
		return
	if settlement_hub != null and settlement_hub.visible:
		settlement_hub.focus_default()
		return
	if _settlement_hub_available() and not settlement_hub_active:
		if settlement_detail_mode == "workshop" and _focus_control(focus_chassis_button):
			return
		if settlement_detail_mode == "journey":
			if not selected_campaign_node_id.is_empty() and _focus_control(campaign_commit_button):
				return
			for button in campaign_node_buttons:
				if _focus_control(button):
					return
	if state.phase == "results":
		if not results_chassis_reviewed and _focus_control(results_inspect_button):
			return
		if _focus_control(feedback_button):
			return
	if state.phase in ["battle", "final_battle"] and _focus_control(advance_encounter_button):
		return
	if not state.campaign_event_pending.is_empty():
		for button in campaign_event_buttons:
			if _focus_control(button):
				return
	if _active_contract_status() == "offered" and _focus_control(contract_accept_button):
		return
	if not selected_campaign_node_id.is_empty() and _focus_control(campaign_commit_button):
		return
	if state.phase == "settlement":
		for button in [settlement_repair_button, settlement_refuel_button, settlement_hull_button]:
			if _focus_control(button):
				return
		if _focus_control(settlement_routes_button):
			return
	for button in campaign_node_buttons:
		if _focus_control(button):
			return
	_focus_control(travel_button)

func _ensure_current_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if not _control_can_receive_focus(focus_owner):
		focus_current_action.call_deferred()

func _on_departure_option_changed(_index: int) -> void:
	_refresh_ui()
	_refresh_tutorial_ui()

func _on_guard_contract_pressed(accept: bool) -> void:
	var result := state.choose_veyru_medicine_contract(accept) if state.campaign_region_id == "flooded_veyru" else state.choose_guard_contract(accept)
	if bool(result.get("ok", false)):
		var contract_message := String(result.get("message", "Contract decision recorded."))
		last_journey_receipt = "CONTRACT · %s" % contract_message
		_set_event("CONTRACT DECISION\n%s" % contract_message)
		_journal_event("medicine_contract_answered" if state.campaign_region_id == "flooded_veyru" else "guard_contract_answered", {"accepted": accept})
		_checkpoint("contract_answered")
	else:
		_set_event("Contract choice blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()
	if bool(result.get("ok", false)):
		encounter_label.text = "CONTRACT DECISION\n%s" % String(result.get("message", "Contract decision recorded."))
		focus_current_action.call_deferred()

func _on_settlement_hub_action(_station_id: String, action_id: String) -> void:
	match action_id:
		"accept_assignment":
			_on_guard_contract_pressed(true)
		"decline_assignment":
			_on_guard_contract_pressed(false)
		"open_workshop":
			settlement_hub_active = false
			settlement_detail_mode = "workshop"
			_set_event("The fortress enters the workshop. Inspect dependencies and refit the chassis; return to the bazaar when ready.")
			_refresh_ui()
			_focus_control.call_deferred(focus_chassis_button)
		"review_supplies":
			settlement_hub_active = false
			settlement_detail_mode = "workshop"
			_set_event("The quartermaster opens the fortress stores. Review carried modules, fuel, and current capacity.")
			_refresh_ui()
			_focus_control.call_deferred(module_option)
		"select_experiment_quarry":
			_on_mastery_experiment_selected("ashgate_quarry_adaptation")
		"select_experiment_signal":
			_on_mastery_experiment_selected("ashgate_signal_discipline")
		"plan_journey":
			if _active_contract_status() == "offered":
				_set_event("Answer the settlement assignment before planning the first road.")
				_refresh_ui()
				return
			settlement_hub_active = false
			settlement_detail_mode = "journey"
			journey_planner_active = true
			_set_event("The departure gate opens the route table. Inspect a highlighted destination, then confirm the journey separately.")
			_refresh_ui()
			focus_current_action.call_deferred()

func _on_mastery_experiment_selected(experiment_id: String) -> void:
	var result := state.choose_mastery_experiment(experiment_id)
	if not bool(result.get("ok", false)):
		_set_event("Field experiment blocked: %s." % String(result.get("reason", "unknown")))
		_refresh_ui()
		return
	var experiment: Dictionary = result.get("experiment", {})
	last_journey_receipt = "FIELD ORDER · %s · %s" % [String(experiment.get("title", "Experiment")).to_upper(), String(experiment.get("proof", "Complete the stated objective."))]
	_set_event(String(result.get("message", "Field experiment selected.")))
	_journal_event("mastery_experiment_selected", {"id": experiment_id})
	_checkpoint("mastery_experiment_selected")
	_refresh_ui()

func _on_return_to_settlement_hub() -> void:
	if not _settlement_hub_available():
		return
	selected_campaign_node_id = ""
	settlement_hub_active = true
	settlement_detail_mode = "hub"
	journey_planner_active = false
	_set_event("Returned to the settlement bazaar. No route, fuel, or time was committed.")
	_refresh_ui()
	settlement_hub.focus_default.call_deferred()

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
	_set_event("Route selected: %s. Review its costs and forecast, then commit when ready. %s cancels selection." % [String(preview.get("name", node_id)), _cancel_shortcut(false)])
	_refresh_ui()
	if journey_planner != null and journey_planner.visible:
		journey_planner.reveal_commit_context()
	if not _focus_control(campaign_commit_button):
		_focus_control(campaign_cancel_button)
	_show_selected_route_preview(node_id)

func _clear_campaign_route_selection() -> bool:
	if selected_campaign_node_id.is_empty():
		return false
	var previous_selection := selected_campaign_node_id
	selected_campaign_node_id = ""
	_set_event("Route preview cancelled. No fuel, time, or pressure was spent.")
	_refresh_ui()
	if journey_planner != null and journey_planner.visible:
		journey_planner.show_route_overview()
	var previous_button := campaign_map.button_for(previous_selection) as Button
	if previous_button != null and not previous_button.disabled:
		_focus_control(previous_button)
	return true

func _on_campaign_route_cancelled() -> void:
	_clear_campaign_route_selection()

func _on_campaign_node_inspected(node_id: String, detail: String) -> void:
	if not campaign_map.visible:
		return
	if node_id == selected_campaign_node_id:
		_show_selected_route_preview(node_id)
		return
	var node_name := String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id))
	_set_route_preview("ROUTE INTEL · %s\n%s" % [node_name.to_upper(), detail], campaign_map.intel_tone_for(node_id))

func _set_route_preview(text: String, tone: String = "neutral") -> void:
	route_preview_label.text = text
	route_preview_label.add_theme_color_override("font_color", ROUTE_INTEL_COLORS.get(tone, ROUTE_INTEL_COLORS.neutral))

func _show_selected_route_preview(node_id: String) -> void:
	var block_reason := _campaign_departure_block_reason(node_id)
	var selected_detail := campaign_map.detail_for(node_id)
	var node_name := String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)).to_upper()
	var final_warning := "\nFINAL COMMITMENT · Failure ends the run; there is no retreat." if node_id == state.campaign_final_node_id() else ""
	if journey_planner != null and journey_planner.visible:
		var preview := state.campaign_node_preview(node_id, _selected_id(doctrine_option))
		var concise_detail := "%d day%s · %d fuel · %s risk" % [int(preview.get("days", 0)), "" if int(preview.get("days", 0)) == 1 else "s", int(preview.get("fuel", 0)), String(preview.get("risk_band", "unknown")).to_upper()]
		var route_effect := String(preview.get("route_effect", ""))
		var effect_line := "\nRECOVERY · %s." % route_effect if not route_effect.is_empty() else ""
		_set_route_preview("ROUTE READY · %s\n%s%s%s%s" % [node_name, concise_detail, effect_line, "\nBLOCKED · %s" % block_reason if not block_reason.is_empty() else "", final_warning], "danger" if not block_reason.is_empty() or node_id == state.campaign_final_node_id() else campaign_map.intel_tone_for(node_id))
		return
	_set_route_preview("ROUTE READY · %s\n%s%s%s" % [node_name, selected_detail, " Departure blocked: %s." % block_reason if not block_reason.is_empty() else "", final_warning], "danger" if not block_reason.is_empty() or node_id == state.campaign_final_node_id() else campaign_map.intel_tone_for(node_id))

func _on_campaign_route_committed(node_id: String) -> void:
	if node_id.is_empty() or node_id != selected_campaign_node_id:
		_set_event("Select a route before committing the fortress.")
		return
	var doctrine := _selected_id(doctrine_option)
	var origin_id := state.current_location
	var day_before := state.day
	var fuel_before := state.fuel
	var pressure_before := state.campaign_pressure
	var route_preview := state.campaign_node_preview(node_id, doctrine)
	var result := state.begin_campaign_route(node_id, doctrine)
	if bool(result.get("ok", false)):
		selected_campaign_node_id = ""
		settlement_hub_active = true
		settlement_detail_mode = "hub"
		journey_transition_active = true
		journey_arrival_active = false
		journey_arrival_view = {}
		journey_planner_active = false
		journey_transition_view = _build_journey_transition_view(origin_id, node_id, route_preview, day_before, fuel_before, pressure_before)
		last_journey_receipt = "ROUTE COMMITTED · %s · Day +%d · Fuel −%d · Pressure +%d" % [String(LongMarchState.CAMPAIGN_NODES[node_id].name), state.day - day_before, fuel_before - state.fuel, state.campaign_pressure - pressure_before]
		journey_departure_snapshot = {"origin_id": origin_id, "destination_id": node_id, "day": day_before, "fuel": fuel_before, "hull": state.hull_condition, "money": state.money, "pressure": pressure_before, "doctrine": doctrine}
		_set_event("Departed for %s. Forecast: %s." % [String(LongMarchState.CAMPAIGN_NODES[node_id].name), ", ".join(result.get("forecast", {}).get("threats", []))])
		_journal_event("campaign_node_started", {"node": node_id, "doctrine": doctrine, "pressure": state.campaign_pressure})
		_checkpoint("route_started")
	else:
		_set_event("Route blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _build_journey_transition_view(origin_id: String, destination_id: String, preview: Dictionary, day_before: int, fuel_before: int, pressure_before: int) -> Dictionary:
	return RoutePresenter.build_transition(state, origin_id, destination_id, preview, {"day": day_before, "fuel": fuel_before, "pressure": pressure_before}, {"tutorial": tutorial_mode, "promise": _journey_promise_summary(), "fortress": _fortress_presentation_snapshot()})

func _restore_journey_transition_view() -> Dictionary:
	var destination_id := state.campaign_target_node
	var origin_id := String(state.campaign_path[-1]) if not state.campaign_path.is_empty() else ("lantern_quay" if state.campaign_region_id == "flooded_veyru" else "ashgate_depot")
	var preview := state.campaign_node_preview(destination_id, state.encounter_target_doctrine)
	var days := int(preview.get("days", 0))
	var fuel_cost := int(preview.get("fuel", 0))
	var pressure_gain := int(preview.get("pressure_gain", 0))
	var matching_snapshot := String(journey_departure_snapshot.get("destination_id", "")) == destination_id
	var day_before := int(journey_departure_snapshot.get("day", state.day - days)) if matching_snapshot else state.day - days
	var fuel_before := int(journey_departure_snapshot.get("fuel", state.fuel + fuel_cost)) if matching_snapshot else state.fuel + fuel_cost
	var pressure_before := int(journey_departure_snapshot.get("pressure", state.campaign_pressure - pressure_gain)) if matching_snapshot else state.campaign_pressure - pressure_gain
	return _build_journey_transition_view(origin_id, destination_id, preview, day_before, fuel_before, pressure_before)

func _journey_promise_summary() -> String:
	if tutorial_mode:
		return "TRAINING ORDER · Prove movement, contact reading, one emergency response, and repair."
	if state.campaign_region_id == "flooded_veyru":
		var carrier_name := String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "the assigned carrier")) if not state.veyru_medicine_carrier_id.is_empty() else "no assigned carrier"
		match state.veyru_contract_status:
			"accepted":
				return "PROMISE · Deliver Lantern Quay's sealed medicines in %s." % carrier_name
			"completed":
				return "PROMISE KEPT · Lantern Quay's medicines reached the Dry Archive."
			"failed":
				return "PROMISE BROKEN · The medicine carrier failed; the march continues."
			_:
				return "PROMISE DECLINED · Preserve cargo freedom instead of carrying the medicine cases."
	match state.guard_contract_status:
		"accepted":
			return "PROMISE · Guard Morrowline's parts convoy through the Lowlands."
		"completed":
			return "PROMISE KEPT · Morrowline's parts convoy arrived under guard."
		"failed":
			return "PROMISE BROKEN · The parts convoy did not reach Morrowline."
		_:
			return "PROMISE DECLINED · Travel without Morrowline's convoy obligation."

func _on_journey_transition_continued() -> void:
	if not journey_transition_active:
		return
	journey_transition_active = false
	if tutorial_mode:
		_tutorial_advance("read_contact", "TRAVEL COMPLETE · Fuel and time are already spent. The road remains contested until contact is clear.")
	_set_event("Road contact engaged. Read the incoming threats before advancing the encounter.")
	_refresh_ui()
	road_contact.focus_default.call_deferred()

func _on_journey_arrival_continued() -> void:
	if not journey_arrival_active:
		return
	journey_arrival_active = false
	journey_arrival_view = {}
	_set_event("Arrival acknowledged. The fortress is ready for its next local order.")
	_refresh_ui()
	if recovery_panel != null and recovery_panel.visible:
		recovery_panel.focus_default()
	else:
		focus_current_action.call_deferred()

func _open_debrief_inspection() -> void:
	if state.phase != "results":
		return
	debrief_inspection_active = true
	results_chassis_reviewed = true
	left_scroll.scroll_vertical = 0
	right_scroll.scroll_vertical = 0
	_refresh_ui()
	_focus_chassis_for_results.call_deferred()

func _open_debrief_notes() -> void:
	feedback_return_context = "results"
	_show_feedback()

func _on_journey_planner_returned() -> void:
	selected_campaign_node_id = ""
	journey_planner_active = false
	if _settlement_hub_available():
		_on_return_to_settlement_hub()
		return
	_refresh_ui()
	if state.phase == "settlement":
		if recovery_panel != null and recovery_panel.visible:
			recovery_panel.routes_button.call_deferred("grab_focus")
		else:
			_focus_control.call_deferred(settlement_routes_button)

func _on_campaign_event_pressed(index: int) -> void:
	if index < 0 or index >= campaign_event_buttons.size():
		return
	var choice_id := String(campaign_event_buttons[index].get_meta("choice_id", ""))
	if choice_id.is_empty():
		return
	var result := state.resolve_campaign_event(choice_id)
	if bool(result.get("ok", false)):
		var result_message := String(result.get("message", "Decision recorded: %s." % choice_id.replace("_", " ").capitalize()))
		last_journey_receipt = "DECISION · %s" % result_message
		_set_event(result_message)
		_journal_event("campaign_event_resolved", {"event": String(result.get("event", "")), "choice": choice_id})
		_checkpoint("event_resolved")
	else:
		_set_event("Decision blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()
	if bool(result.get("ok", false)):
		if state.campaign_event_pending.is_empty():
			encounter_label.text = "DECISION CONSEQUENCE\n%s\nNEXT · %s" % [String(result.get("message", "Decision recorded.")), _current_guidance_action()]
		else:
			var next_event := state.campaign_event_details()
			encounter_label.text = "DECISION CONTINUES · %s\n%s" % [String(next_event.get("title", "Local event")).to_upper(), String(result.get("message", "Decision recorded."))]
			_focus_first_campaign_event_choice()

func _on_roadside_event_choice(choice_id: String) -> void:
	for index in range(campaign_event_buttons.size()):
		if String(campaign_event_buttons[index].get_meta("choice_id", "")) == choice_id:
			_on_campaign_event_pressed(index)
			return

func _current_guidance_action() -> String:
	var guidance := _current_guidance()
	var separator := guidance.find(" · ")
	return guidance.substr(separator + 3) if separator >= 0 else guidance

func _focus_first_campaign_event_choice() -> void:
	if roadside_event != null and roadside_event.visible:
		roadside_event.focus_default()
		return
	for button in campaign_event_buttons:
		if _focus_control(button):
			_on_desk_control_focused(button)
			return

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
		var preview_cell := _first_open_cell_for_selected_module()
		if preview_cell.x >= 0:
			fortress_panel.cursor_cell = preview_cell
		_set_event("Selected stored %s. Choose an empty chassis cell to install it." % module_name)
	else:
		_set_event("%s is no longer available in this run." % module_name)
	_refresh_ui()
	if module_option.has_focus():
		_on_desk_control_focused(module_option)

func _focus_chassis_for_refit() -> void:
	if not state.can_refit():
		return
	if selected_module_cell.x >= 0:
		fortress_panel.cursor_cell = selected_module_cell
	fortress_panel.queue_redraw()
	fortress_panel.grab_focus()

func _focus_chassis_for_combat() -> void:
	if state.phase not in ["battle", "final_battle"]:
		return
	contact_inspection_active = true
	if road_contact != null:
		road_contact.visible = false
	var active_target_id := _active_combat_target_id()
	if not active_target_id.is_empty():
		for instance in state.modules:
			if String(instance.get("id", "")) == active_target_id:
				fortress_panel.cursor_cell = Vector2i(instance.get("position", Vector2i.ZERO))
				break
	elif selected_module_cell.x >= 0:
		fortress_panel.cursor_cell = selected_module_cell
	fortress_panel.queue_redraw()
	fortress_panel.grab_focus()

func _focus_chassis_for_results() -> void:
	if state.phase != "results":
		return
	if not results_chassis_reviewed:
		results_chassis_reviewed = true
		_refresh_ui()
	left_scroll.scroll_vertical = 0
	right_scroll.scroll_vertical = 0
	var selected_instance := _selected_installed_module()
	if not selected_instance.is_empty():
		fortress_panel.cursor_cell = Vector2i(selected_instance.get("position", Vector2i.ZERO))
	elif not state.modules.is_empty():
		fortress_panel.cursor_cell = Vector2i(state.modules[0].get("position", Vector2i.ZERO))
	fortress_panel.queue_redraw()
	fortress_panel.grab_focus()

func _active_combat_target_id() -> String:
	for enemy in state.encounter_enemies:
		var target_id := String(enemy.get("target", ""))
		if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and not target_id.is_empty() and target_id != "hull":
			return target_id
	return ""

func _hull_is_under_threat() -> bool:
	for enemy in state.encounter_enemies:
		if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and String(enemy.get("target", "")) == "hull":
			return true
	return false

func _sync_new_active_combat_target() -> void:
	if state.phase not in ["battle", "final_battle"]:
		last_synced_combat_target_id = ""
		return
	var active_target_id := _active_combat_target_id()
	if active_target_id.is_empty():
		last_synced_combat_target_id = ""
		return
	if active_target_id == last_synced_combat_target_id:
		return
	last_synced_combat_target_id = active_target_id
	selected_module_id = active_target_id
	_sync_selected_module_context()
	_select_module_option(active_target_id)

func _on_fortress_focus_exit_requested() -> void:
	if state.phase in ["battle", "final_battle"]:
		contact_inspection_active = false
		_refresh_ui()
		if road_contact != null and road_contact.visible:
			road_contact.inspect_button.grab_focus()
		elif _control_can_receive_focus(combat_inspect_button):
			_focus_control(combat_inspect_button)
	elif state.phase == "results" and debrief_inspection_active:
		debrief_inspection_active = false
		_refresh_ui()
		debrief_panel.inspect_button.call_deferred("grab_focus")
	elif state.phase == "results" and _control_can_receive_focus(results_inspect_button):
		_focus_control(results_inspect_button)
	elif _control_can_receive_focus(focus_chassis_button):
		_focus_control(focus_chassis_button)

func _refresh_pause_action_hint() -> void:
	if fortress_panel != null and fortress_panel.has_focus():
		pause_button.text = "PAUSE · CHASSIS ACTIVE"
		pause_button.tooltip_text = "Pause with this button. B or Escape leaves chassis inspection first."
	elif not selected_campaign_node_id.is_empty():
		pause_button.text = "PAUSE · ROUTE REVIEW"
		pause_button.tooltip_text = "Pause with this button. B or Escape clears the selected route first."
	else:
		pause_button.text = "PAUSE · ESC / %s" % _controller_cancel_label()
		pause_button.tooltip_text = "Pause the march to save, review the briefing, change settings, restart, or return to the title."

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

func _module_power_text(definition: Dictionary) -> String:
	var output := int(definition.get("power_output", 0))
	var draw := int(definition.get("power_draw", 0))
	if output > 0:
		return "+%d" % output
	if draw > 0:
		return "−%d" % draw
	return "0"

func _stored_module_capacity_warning(definition: Dictionary, selected_installed: Dictionary) -> String:
	if not selected_installed.is_empty():
		return ""
	var warnings: Array[String] = []
	var excess_mass := state.total_mass() + int(definition.get("mass", 0)) - LongMarchState.BASE_MASS_LIMIT
	if excess_mass > 0:
		warnings.append("Remove at least %d mass" % excess_mass)
	if "exterior" in definition.get("tags", []):
		var mounts_used := 0
		for instance in state.modules:
			if bool(instance.get("exterior", false)):
				mounts_used += 1
		if mounts_used >= LongMarchState.MAX_EXTERIOR_MOUNTS:
			warnings.append("free one exterior mount")
	return "\nCAPACITY · %s." % "; ".join(warnings) if not warnings.is_empty() else ""

func _first_open_cell_for_selected_module() -> Vector2i:
	var shape := state.module_shape(selected_module_id, placement_rotated)
	for y in range(LongMarchState.GRID_HEIGHT - shape.y + 1):
		for x in range(LongMarchState.GRID_WIDTH - shape.x + 1):
			var origin := Vector2i(x, y)
			var clear := true
			for offset_y in range(shape.y):
				for offset_x in range(shape.x):
					if not state.module_at(origin + Vector2i(offset_x, offset_y)).is_empty():
						clear = false
						break
				if not clear:
					break
			if clear:
				return origin
	return Vector2i(-1, -1)

func _selected_installed_module() -> Dictionary:
	if selected_module_cell.x < 0 or selected_module_cell.y < 0:
		return {}
	return state.module_at(selected_module_cell)

func _most_damaged_installed_module() -> Dictionary:
	var candidate: Dictionary = {}
	var largest_shortfall := 0
	for instance in state.modules:
		var module_id := String(instance.get("id", ""))
		var maximum := int(state.module_definition(module_id).get("durability", 1))
		var current := int(instance.get("durability", maximum))
		var shortfall := maximum - current
		if shortfall > largest_shortfall:
			candidate = instance.duplicate(true)
			candidate["maximum_durability"] = maximum
			largest_shortfall = shortfall
	return candidate

func _repair_priority_view() -> Dictionary:
	var candidate := _most_damaged_installed_module()
	if candidate.is_empty():
		return {
			"headline": "REPAIR PRIORITY · All installed systems are at full durability.",
			"effect": "WHY IT MATTERS · No damage is currently threatening a dependency chain."
		}
	var module_id := String(candidate.get("id", ""))
	var definition := state.module_definition(module_id)
	var card := state.module_dependency_card(candidate)
	var status := state.dependency_status(candidate)
	var current := int(candidate.get("durability", 0))
	var maximum := int(candidate.get("maximum_durability", definition.get("durability", 1)))
	var module_name := String(definition.get("name", module_id.replace("_", " ").capitalize()))
	return {
		"module_id": module_id,
		"name": module_name,
		"current": current,
		"maximum": maximum,
		"state": String(status.get("state", "offline")),
		"headline": "REPAIR PRIORITY · %s · %d/%d · %s" % [module_name.to_upper(), current, maximum, String(status.get("state", "offline")).to_upper()],
		"effect": "WHY IT MATTERS · %s RISK IF LOST · %s" % [String(definition.get("capability", "This system supports the march.")), String(card.get("next_failure", "Further damage can remove this system's capability."))],
		"counter": String(card.get("legal_counter", "Repair this system before departure."))
	}

func _campaign_departure_block_reason(node_id: String) -> String:
	if node_id.is_empty():
		return ""
	if not (state.operational("steam_lance_engine") or state.operational("ash_runner_engine")):
		return String(_movement_failure_diagnosis().get("cause", "No operational, fuel-connected engine remained"))
	var preview := state.campaign_node_preview(node_id, _selected_id(doctrine_option))
	var fuel_required := int(preview.get("fuel", 0))
	if state.fuel < fuel_required:
		return "Need %d fuel · %d available" % [fuel_required, state.fuel]
	return ""

func current_location_is_region_start() -> bool:
	return state.current_location == ("lantern_quay" if state.campaign_region_id == "flooded_veyru" else "ashgate_depot")

func _settlement_hub_available() -> bool:
	return state != null and state.campaign_active and state.phase == "refit" and current_location_is_region_start()

func _settlement_hub_view(snapshot: Dictionary) -> Dictionary:
	return SettlementPresenter.build(state, snapshot, _fortress_presentation_snapshot())

func _refresh_settlement_hub(snapshot: Dictionary) -> void:
	if settlement_hub == null or main_columns == null:
		return
	var available := _settlement_hub_available()
	var show_hub := available and settlement_hub_active
	settlement_hub.visible = show_hub
	main_columns.visible = not show_hub
	settlement_hub_return_button.visible = available and not show_hub
	if available:
		var location_name := String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", "settlement"))
		settlement_hub_return_button.text = "RETURN TO %s BAZAAR" % location_name.to_upper()
		settlement_hub.configure(_settlement_hub_view(snapshot))

func _refresh_journey_transition() -> void:
	if journey_transition == null:
		return
	if state.encounter_step > 0 or state.phase not in ["battle", "final_battle"]:
		journey_transition_active = false
	var show_transition := journey_transition_active and state.encounter_active
	journey_transition.visible = show_transition
	if not show_transition:
		return
	if journey_transition_view.is_empty():
		journey_transition_view = _restore_journey_transition_view()
	settlement_hub.visible = false
	main_columns.visible = false
	journey_planner.visible = false
	journey_transition.configure(journey_transition_view)

func _journey_planner_should_show() -> bool:
	if not state.campaign_active or not state.campaign_event_pending.is_empty():
		return false
	if _settlement_hub_available():
		return not settlement_hub_active and settlement_detail_mode == "journey"
	if state.phase == "map":
		return true
	return state.phase == "settlement" and journey_planner_active

func _refresh_journey_planner(snapshot: Dictionary) -> void:
	if journey_planner == null:
		return
	var show_planner := _journey_planner_should_show()
	journey_planner.visible = show_planner
	if not show_planner:
		return
	main_columns.visible = false
	settlement_hub.visible = false
	var location_name := String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location))
	journey_planner.configure(RoutePresenter.build_planner(state, snapshot, {
		"order": _current_guidance(),
		"receipt": _journey_planner_receipt(),
		"route_selected": not selected_campaign_node_id.is_empty(),
		"can_return": _settlement_hub_available() or state.phase == "settlement",
		"return_label": "RETURN TO %s BAZAAR" % location_name.to_upper() if _settlement_hub_available() else "RETURN TO RECOVERY"
	}))


func _journey_planner_receipt() -> String:
	if last_journey_receipt.is_empty():
		return ""
	return "LAST RECEIPT · %s" % last_journey_receipt

func _refresh_road_contact(snapshot: Dictionary, combat_view: Dictionary) -> void:
	if road_contact == null:
		return
	var battle_active := state.phase in ["battle", "final_battle"] and state.encounter_active
	var show_contact := battle_active and not journey_transition_active and not contact_inspection_active
	road_contact.visible = show_contact
	if not show_contact:
		return
	settlement_hub.visible = false
	journey_planner.visible = false
	journey_transition.visible = false
	var active_target_id := ContactPresenter.active_target_id(combat_view)
	var action_views: Array[Dictionary] = []
	for button in intervention_buttons:
		var intervention_id := String(button.get_meta("intervention_id", ""))
		action_views.append({
			"id": intervention_id,
			"label": button.text,
			"tooltip": String(intervention_preview_texts.get(intervention_id, button.tooltip_text)),
			"enabled": not button.disabled
		})
	road_contact.configure(ContactPresenter.build(state, snapshot, combat_view, {
		"order": _current_guidance(),
		"warning": _critical_combat_warning(),
		"advance_label": _advance_encounter_action_text(),
		"inspect_label": combat_inspect_button.text,
		"intervention_heading": intervention_title.text,
		"intervention_help": intervention_help_label.text,
		"interventions": action_views,
		"active_target_id": active_target_id,
		"fortress": _fortress_presentation_snapshot(active_target_id),
		"fortress_before": contact_fortress_before
	}))

func _refresh_journey_arrival() -> void:
	if journey_arrival == null:
		return
	journey_arrival.visible = journey_arrival_active
	if not journey_arrival_active:
		return
	settlement_hub.visible = false
	journey_planner.visible = false
	journey_transition.visible = false
	road_contact.visible = false
	roadside_event.visible = false
	main_columns.visible = false
	journey_arrival.configure(journey_arrival_view)

func _refresh_debrief() -> void:
	if debrief_panel == null:
		return
	var show_debrief := state.phase == "results" and not journey_arrival_active and not debrief_inspection_active and not tutorial_mode
	debrief_panel.visible = show_debrief
	if not show_debrief:
		return
	main_columns.visible = false
	settlement_hub.visible = false
	journey_planner.visible = false
	journey_transition.visible = false
	road_contact.visible = false
	roadside_event.visible = false
	journey_arrival.visible = false
	debrief_panel.configure(_debrief_view())

func _refresh_recovery_panel(snapshot: Dictionary) -> void:
	if recovery_panel == null:
		return
	var show_recovery := state.phase == "settlement" and state.campaign_active and not tutorial_mode and not journey_arrival_active and state.campaign_event_pending.is_empty() and not journey_planner_active
	recovery_panel.visible = show_recovery
	if not show_recovery:
		return
	main_columns.visible = false
	settlement_hub.visible = false
	journey_planner.visible = false
	journey_transition.visible = false
	road_contact.visible = false
	roadside_event.visible = false
	journey_arrival.visible = false
	debrief_panel.visible = false
	var location_name := _recovery_location_name()
	var repair_priority := _repair_priority_view()
	recovery_panel.configure(RecoveryPresenter.build(state, _fortress_presentation_snapshot(String(repair_priority.get("module_id", ""))), {
		"repair_text": settlement_repair_button.text,
		"repair_tooltip": settlement_repair_button.tooltip_text,
		"repair_disabled": settlement_repair_button.disabled,
		"refuel_text": settlement_refuel_button.text,
		"refuel_tooltip": settlement_refuel_button.tooltip_text,
		"refuel_disabled": settlement_refuel_button.disabled,
		"hull_text": settlement_hull_button.text,
		"hull_tooltip": settlement_hull_button.tooltip_text,
		"hull_disabled": settlement_hull_button.disabled,
		"routes_text": settlement_routes_button.text,
		"repair_priority_view": repair_priority
	}, last_recovery_receipt, location_name))

func _on_recovery_repair_requested() -> void:
	_on_settlement_repair_pressed()
	if recovery_panel != null and recovery_panel.visible:
		recovery_panel.repair_button.call_deferred("grab_focus")

func _on_recovery_refuel_requested() -> void:
	_on_settlement_refuel_pressed()
	if recovery_panel != null and recovery_panel.visible:
		recovery_panel.refuel_button.call_deferred("grab_focus")

func _on_recovery_hull_requested() -> void:
	_on_settlement_hull_pressed()
	if recovery_panel != null and recovery_panel.visible:
		recovery_panel.hull_button.call_deferred("grab_focus")

func _debrief_view() -> Dictionary:
	return DebriefPresenter.build(state, _fortress_presentation_snapshot(), {
		"run_code": current_run_code(),
		"contract_status": _active_contract_status(),
		"decision_record": _campaign_decision_record_text(),
		"result_summary": _result_summary_text(),
		"causal_chain": _debrief_causal_chain(),
		"system_condition": _result_system_condition_text().replace("Damage: ", "Damaged systems · ").replace("\nUnavailable: ", "\nUnavailable systems · "),
		"replay_text": _result_replay_text(),
		"starting_region_results": starting_region_results
	})

func _debrief_causal_chain() -> String:
	var doctrine := state.encounter_target_doctrine.replace("_", " ").capitalize()
	match state.final_result:
		"decisive_march":
			return "%s doctrine → every final contact defeated → Meridian Pass opened." % doctrine
		"archive_kept":
			var carrier_name := String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "medicine carrier"))
			return "%s remained operational → sealed medicines arrived → the archive commitment held." % carrier_name
		"archive_scarred":
			if state.veyru_contract_status != "completed":
				return "Medicine carrier exposed → delivery ended %s → the archive was secured at a cost." % state.veyru_contract_status.replace("_", " ")
			return "Final-road damage → hull fell to %d/10 → the archive was secured at a cost." % state.hull_condition
		"scarred_march":
			var remaining_contacts := _undefeated_final_contacts()
			if not remaining_contacts.is_empty():
				return "%s survived step 6 → the road remained contested → the decisive threshold was missed." % ", ".join(remaining_contacts)
			if state.settlement_actions_remaining > 0:
				return "%d unused Morrowline service action%s → hull ended at %d/10 → the decisive threshold was missed." % [state.settlement_actions_remaining, "" if state.settlement_actions_remaining == 1 else "s", state.hull_condition]
			return "Accumulated damage → hull ended at %d/10 → the decisive threshold was missed." % state.hull_condition
		"march_failed", "veyru_lost":
			if state.hull_condition <= 0:
				return "Uncontained impacts → hull reached zero → the march stopped."
			var diagnosis := _movement_failure_diagnosis()
			return "%s → movement failed → the march stopped." % String(diagnosis.get("cause", "The movement chain broke"))
	return "The road's commitments and damage produced an unclassified result."

func _refresh_roadside_event(snapshot: Dictionary) -> void:
	if roadside_event == null:
		return
	var event := state.campaign_event_details()
	var show_event := not event.is_empty() and not journey_arrival_active and state.phase not in ["battle", "final_battle", "results"]
	roadside_event.visible = show_event
	if not show_event:
		return
	settlement_hub.visible = false
	journey_planner.visible = false
	journey_transition.visible = false
	road_contact.visible = false
	var event_id := String(event.get("id", state.campaign_event_pending))
	var occurrence := event_id in LongMarchState.OCCURRENCE_DEFS
	roadside_event.configure({
		"event_id": event_id,
		"region_id": state.campaign_region_id,
		"context": "ROADSIDE OCCURRENCE" if occurrence else "LOCATION DECISION",
		"location_name": String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location)),
		"title": String(event.get("title", "Roadside decision")),
		"body": String(event.get("body", "The fortress waits for an order.")),
		"choices": event.get("choices", []),
		"story": _roadside_event_story(event_id, event),
		"guidance": "Choose one response. Every listed cost or benefit is applied immediately; departure remains blocked until the decision is complete.",
		"values": {
			"day": str(snapshot.get("day", state.day)),
			"fuel": str(snapshot.get("fuel", state.fuel)),
			"hull": "%d/10" % state.hull_condition,
			"ashmarks": str(state.money),
			"pressure": "%s · %d" % [state.campaign_pressure_band().replace("_", " ").to_upper(), state.campaign_pressure],
			"trust": str(state.settlement_trust)
		},
		"fortress": _fortress_presentation_snapshot()
	})

func _roadside_event_story(event_id: String, event: Dictionary) -> Dictionary:
	if event_id == "boiler_heartbeat":
		var choices: Array = event.get("choices", [])
		return {
			"motif": "boiler_cadence_choice",
			"show_card": false,
			"heading": "DAMAGED ENGINE · STOP OR CARRY THE BEARING",
			"detail": "Inspect: %s. March: %s." % [String(choices[0].get("effect", "repair the engine with time and pressure")) if choices.size() > 0 else "repair the engine with time and pressure", String(choices[1].get("effect", "risk the bearing to lower pressure")) if choices.size() > 1 else "risk the bearing to lower pressure"]
		}
	if event_id == "lift_chain_sings":
		return {
			"motif": "lift_chain_choice",
			"show_card": false,
			"heading": "AMMUNITION LIFT · BRACE OR CARRY THE LOAD",
			"detail": "Brace: spend 6 Ashmarks to lower future route risk. Carry: lower pressure now and lose 1 Ammunition Lift durability."
		}
	if event_id == "the_miller_with_a_broken_wheel":
		return {
			"motif": "miller_wheel_choice",
			"show_card": false,
			"heading": "BROKEN WHEEL · WORKSHOP TIME OR ROAD TIME",
			"detail": "Help: gain fuel and trust, but spend a day, add pressure, and strain the workshop. Leave: lower pressure and lose trust."
		}
	if event_id == "mara_workbench_choice":
		var choices: Array = event.get("choices", [])
		var repair_target := String(choices[0].get("label", "Rebuild the damaged system")).trim_prefix("Rebuild ") if not choices.is_empty() else "the damaged system"
		return {
			"motif": "mara_core_choice",
			"heading": "MARA'S FORGE CORE · ONE USE ONLY",
			"detail": "Machine: restore %s now (+1 day, +1 pressure). Shelter: reduce every Refugee Bunk hit by 1; no repair now." % repair_target,
			"target_name": repair_target
		}
	if event_id == "mara_followup":
		var preview := state.mara_followup_preview()
		var repair_path := String(preview.get("path", "")) == "repair"
		var target_name := String(state.module_definition(state.mara_repaired_module_id).get("name", "repaired system")) if repair_path else "Refugee Bunk"
		return {
			"motif": "mara_core_callback",
			"heading": "FOURTH-ROAD PROMISE CHECK · %s" % ("HELD" if bool(preview.get("held", false)) else "FAILED"),
			"detail": "%s was the workbench commitment. %s" % [target_name, String(preview.get("effect", "No result available"))],
			"target_name": target_name,
			"held": bool(preview.get("held", false))
		}
	if event_id == "drain_pumps":
		return {
			"motif": "pump_gallery_choice",
			"heading": "OLD DRAIN · ONE DAY AGAINST TWO WATER",
			"detail": "Hold: spend 1 day to lower rising water by 2. Leave: spend no time and carry the current flood clock into every remaining road."
		}
	if event_id == "the_last_dry_room":
		var choices: Array = event.get("choices", [])
		return {
			"motif": "dry_room_choice",
			"heading": "ONE SEALED ROOM · TWO CLAIMS",
			"detail": "Families: %s. Repair stock: %s." % [String(choices[0].get("effect", "shelter the families")) if choices.size() > 0 else "shelter the families", String(choices[1].get("effect", "preserve the parts")) if choices.size() > 1 else "preserve the parts"]
		}
	return {}

func _build_journey_arrival_view(result: Dictionary, before: Dictionary) -> Dictionary:
	var outcome := String(result.get("outcome", state.encounter_outcome))
	var retreat := outcome == "forced_retreat"
	var origin_id := String(before.get("origin_id", state.current_location))
	var destination_id := String(result.get("recovered_to", state.current_location)) if retreat else String(before.get("destination_id", state.current_location))
	if destination_id.is_empty():
		destination_id = state.current_location
	var destination_definition: Dictionary = LongMarchState.JOURNEY_NODES.get(destination_id, {})
	var origin_name := String(LongMarchState.JOURNEY_NODES.get(origin_id, {}).get("name", origin_id.replace("_", " ").capitalize()))
	var destination_name := String(destination_definition.get("name", destination_id.replace("_", " ").capitalize()))
	if tutorial_mode:
		origin_name = "Ashgate Muster Yard"
		destination_name = "Muster Road Recovery Siding"
		destination_id = "muster_recovery_siding"
	var snapshot := state.summary()
	var dependencies: Dictionary = snapshot.get("dependencies", {})
	var recent_report: Array[String] = []
	var report: Array = result.get("report", [])
	for index in range(maxi(0, report.size() - 4), report.size()):
		var report_line := String(report[index])
		if tutorial_mode and report_line.begins_with("Outcome:"):
			report_line = "Outcome: training road secured. The Muster Yard records the drill and opens the recovery siding."
		recent_report.append(report_line)
	var outcome_copy := outcome.replace("_", " ").capitalize()
	var summary := "The fortress has withdrawn to %s. Repairs preserve the run, but time, pressure, and Ashmarks have already changed." % destination_name if retreat else "%s is secured. The fortress is at rest; review the road receipt before issuing the next local order." % destination_name
	var action_label := "CONTINUE TO MARCH DEBRIEF" if state.phase == "results" else ("ENTER %s" % ("BAZAAR" if state.phase in ["refit", "settlement"] else ("LOCAL DECISION" if not state.campaign_event_pending.is_empty() else "JOURNEY MAP")))
	var next_decision := "NEXT · Open the Debrief and review what the fortress carried." if state.phase == "results" else ("NEXT · Enter recovery and choose whether to repair, refuel, or preserve both actions." if state.phase in ["refit", "settlement"] else ("NEXT · Resolve the local occurrence before choosing another road." if not state.campaign_event_pending.is_empty() else "NEXT · Return to the route map and choose the next commitment."))
	if tutorial_mode:
		summary = "The training road is secured. Review the damage receipt, then enter the recovery siding and restore the affected system."
		action_label = "ENTER RECOVERY SIDING"
		next_decision = "NEXT · Enter recovery and restore the affected system."
	var repair_priority := _repair_priority_view()
	return {
		"region_id": state.campaign_region_id,
		"origin_id": origin_id,
		"origin_name": origin_name,
		"destination_id": destination_id,
		"destination_kind": "training" if tutorial_mode else String(destination_definition.get("kind", "outpost")),
		"destination_name": destination_name,
		"retreat": retreat,
		"outcome_label": "FORCED RETREAT" if retreat else outcome_copy,
		"summary": summary,
		"recovery_priority": String(repair_priority.get("headline", "REPAIR PRIORITY · Review the fortress before the next road.")) + "\n" + String(repair_priority.get("effect", "")),
		"report": recent_report,
		"next_decision": next_decision,
		"action_label": action_label,
		"fortress": _fortress_presentation_snapshot(),
		"receipts": {
			"outcome": outcome_copy,
			"hull": "%d → %d" % [int(before.get("hull", state.hull_condition)), state.hull_condition],
			"ashmarks": "%d → %d  ·  %s" % [int(before.get("money", state.money)), state.money, _signed_change(state.money - int(before.get("money", state.money)))],
			"pressure": "%d → %d  ·  %s" % [int(before.get("pressure", state.campaign_pressure)), state.campaign_pressure, _signed_change(state.campaign_pressure - int(before.get("pressure", state.campaign_pressure)))],
			"systems": "%d ready · %d strained\n%d offline" % [int(dependencies.get("ready", 0)), int(dependencies.get("strained", 0)), int(dependencies.get("offline", 0))]
		}
	}

func _signed_change(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)

func _apply_start_detail_visibility() -> void:
	if not _settlement_hub_available() or settlement_hub_active:
		return
	var show_workshop := settlement_detail_mode == "workshop"
	var show_journey := settlement_detail_mode == "journey"
	contract_group.visible = false
	for control in [refit_title, module_group, focus_chassis_button, refit_actions, refit_label, dependency_card_panel]:
		control.visible = show_workshop
	for control in [campaign_title, campaign_pressure_label, campaign_path_label, campaign_map, campaign_commit_button.get_parent(), doctrine_group, doctrine_detail_label, route_preview_label]:
		control.visible = show_journey
	campaign_comparison_panel.visible = show_journey and campaign_comparison_panel.visible
	campaign_commit_intel_label.visible = show_journey and campaign_commit_intel_label.visible
	asset_row.visible = show_workshop

func _active_contract_status() -> String:
	return state.veyru_contract_status if state.campaign_region_id == "flooded_veyru" else state.guard_contract_status

func _recovery_location_name() -> String:
	if tutorial_mode:
		return "Muster Yard"
	return "Evacuation Camp" if state.campaign_region_id == "flooded_veyru" else "Morrowline"

func _on_grid_cell_pressed(cell: Vector2i) -> void:
	var clicked := state.module_at(cell)
	if not clicked.is_empty():
		selected_module_id = String(clicked.get("id", ""))
		selected_module_cell = Vector2i(clicked.get("position", cell))
		placement_rotated = bool(clicked.get("rotated", false))
		_select_module_option(selected_module_id)
		var selection_context := " and refitting" if state.can_refit() else (" or an encounter order" if state.phase in ["battle", "final_battle"] else (" in the final chassis" if state.phase == "results" else ""))
		_set_event("Selected %s for inspection%s." % [String(state.module_definition(selected_module_id).get("name", selected_module_id)), selection_context])
		_tutorial_observe_inspection(selected_module_id)
		if state.phase in ["battle", "final_battle"]:
			contact_inspection_active = false
		_refresh_ui()
		if state.phase in ["battle", "final_battle"]:
			if road_contact != null and road_contact.visible:
				_focus_control(road_contact.intervention_buttons[1] if not road_contact.intervention_buttons[1].disabled else road_contact.advance_button)
			else:
				_focus_control(intervention_buttons[1] if not intervention_buttons[1].disabled else advance_encounter_button)
		elif state.phase == "results":
			fortress_panel.call_deferred("grab_focus")
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
			_tutorial_observe_state()
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
			_tutorial_observe_state()
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
		_set_event("Removed %s. Choose an empty chassis cell to place it again." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		_journal_event("module_stored", {"module": selected_module_id, "durability": int(removed.get("durability", 0))})
		_checkpoint("module_stored")
	else:
		_set_event("Removal blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_travel_pressed() -> void:
	var route_id := _selected_id(route_option)
	var before := {"origin_id": state.current_location, "destination_id": state.journey_destination, "hull": state.hull_condition, "money": state.money, "pressure": state.campaign_pressure}
	var result := state.begin_tutorial_journey(_selected_id(doctrine_option)) if tutorial_mode else state.begin_journey(route_id, _selected_id(doctrine_option))
	if not bool(result.get("ok", false)):
		_set_event("Departure blocked: %s." % String(result.get("reason", "unknown")))
	else:
		journey_departure_snapshot = before
		if tutorial_mode:
			_tutorial_advance("travel", "ROAD COMMITTED · The Long Road spent %d fuel and %d days before contact." % [int(result.get("fuel", 0)), int(result.get("days", 0))])
			journey_transition_active = true
			journey_arrival_active = false
			journey_transition_view = _build_journey_transition_view("ashgate_depot", "rill_crossing", {"visibility": "known", "threats": ["Road Raider"]}, int(before.get("day", 1)), int(before.get("fuel", state.fuel)), int(before.get("pressure", 0)))
		_set_event("Journey begun. Forecast: %s. Advance one battle step at a time." % ", ".join(result.get("forecast", {}).get("threats", [])))
		_journal_event("route_started", {"route": route_id, "doctrine": _selected_id(doctrine_option), "risk": state.current_route_risk, "pressure": state.encounter_pressure})
	_refresh_ui()

func _encounter_checkpoint_reason(resolved: bool) -> String:
	if not resolved:
		return "encounter_advanced"
	if state.phase == "results":
		return "run_ended"
	if state.phase == "settlement" or state.encounter_outcome in ["protected_arrival", "damaged_arrival"]:
		return "recovery_reached"
	if state.encounter_outcome == "route_secured":
		return "route_secured"
	return "encounter_resolved"

func contact_audio_cue_for_step(step: int, enemies: Array) -> String:
	for raw_enemy in enemies:
		var enemy: Dictionary = raw_enemy
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id := String(enemy.get("id", ""))
		var definition: Dictionary = LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {})
		if definition.is_empty():
			continue
		var cue_step := maxi(1, int(definition.get("arrival_step", 1)) - 1)
		if step == cue_step:
			return "threat_%s" % enemy_id
	return ""

func checkpoint_audio_cue(reason: String) -> String:
	if reason != "encounter_advanced" or state == null:
		return ""
	return contact_audio_cue_for_step(state.encounter_step, state.encounter_enemies)

func _on_advance_encounter_pressed() -> void:
	if tutorial_mode and tutorial_director != null and tutorial_director.lesson_id == "read_contact" and not tutorial_director.premature_advance_seen:
		tutorial_director.premature_advance_seen = true
		_set_event("READ BEFORE ADVANCING · The Road Raider is two steps away, seeks cargo or exterior systems, and is countered by the Repeater Gun. Press Advance again when ready.")
		_refresh_tutorial_ui()
		return
	if tutorial_mode and tutorial_director != null and tutorial_director.lesson_id == "read_contact":
		_tutorial_advance("respond", "CONTACT READ · You know the approach, preferred targets, counter, and next possible consequence.")
	var before: Dictionary = journey_departure_snapshot.duplicate(true) if not journey_departure_snapshot.is_empty() else {
		"origin_id": state.current_location,
		"destination_id": state.campaign_target_node if state.campaign_active else state.journey_destination,
		"hull": state.hull_condition,
		"money": state.money,
		"pressure": state.campaign_pressure
	}
	contact_fortress_before = _fortress_presentation_snapshot()
	var result := state.advance_encounter(1.0)
	var encounter_resolved := bool(result.get("resolved", false))
	if not bool(result.get("ok", false)):
		_set_event("Journey battle blocked: %s." % String(result.get("reason", "unknown")))
	elif encounter_resolved:
		journey_arrival_active = true
		journey_arrival_view = _build_journey_arrival_view(result, before)
		journey_departure_snapshot = {}
		var secured_name := String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location))
		last_journey_receipt = "ROAD · %s · %s" % [secured_name, String(result.get("outcome", "resolved")).replace("_", " ").capitalize()]
		_set_event("Journey battle resolved: %s." % String(result.get("outcome", "unknown")).replace("_", " ").capitalize())
		if tutorial_mode:
			_tutorial_advance("repair", "ROAD SECURED · The fortress survived the contact and reached its recovery siding.")
		_journal_event("encounter_resolved", {"leg": state.journey_leg, "outcome": state.encounter_outcome, "phase": state.phase})
		if state.phase == "results" and not result_recorded:
			result_recorded = true
			_journal_event("run_completed", _state_journal_summary())
	else:
		_set_event("Journey battle step %d resolved. Inspect the target before intervening." % int(result.get("step", 0)))
		_journal_event("encounter_step", {"leg": state.journey_leg, "step": state.encounter_step, "hull": state.hull_condition})
		if tutorial_mode and tutorial_director != null and tutorial_director.lesson_id == "damage" and _most_damaged_installed_module().is_empty():
			_set_event("The target remains protected for now. Advance once more and watch the damage report.")
	if bool(result.get("ok", false)):
		_checkpoint(_encounter_checkpoint_reason(encounter_resolved))
	_refresh_ui()

func _on_settlement_repair_pressed() -> void:
	var selected := _selected_installed_module()
	var selected_definition := state.module_definition(String(selected.get("id", ""))) if not selected.is_empty() else {}
	var selected_maximum := int(selected_definition.get("durability", 0))
	if selected.is_empty() or int(selected.get("durability", 0)) >= selected_maximum:
		var candidate := _most_damaged_installed_module()
		if candidate.is_empty():
			_set_event("Every installed module is already fully repaired.")
			encounter_label.text = "SERVICE UNAVAILABLE\nEvery installed module is already fully repaired."
			return
		selected_module_id = String(candidate.get("id", ""))
		selected_module_cell = Vector2i(candidate.get("position", Vector2i.ZERO))
		placement_rotated = bool(candidate.get("rotated", false))
		_select_module_option(selected_module_id)
		_set_event("Selected %s for repair review. No service action spent." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
		_refresh_ui()
		_focus_control(settlement_repair_button)
		return
	var result := state.settlement_repair(String(selected.get("id", "")))
	var service_message := "%s restored +%d durability for %d Ashmarks. %s." % [String(state.module_definition(String(selected.get("id", ""))).get("name", "Module")), int(result.get("restored", 0)), int(result.get("cost", 0)), _service_action_status_text()] if bool(result.get("ok", false)) else "Repair blocked: %s." % String(result.get("reason", "unknown"))
	last_recovery_receipt = service_message
	last_journey_receipt = "SERVICE · %s" % service_message
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "module_repair", "module": String(selected.get("id", "")), "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
		if tutorial_mode:
			_tutorial_advance("complete", "SYSTEM RESTORED · The repaired module and its dependent systems are ready for the next road.")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_settlement_refuel_pressed() -> void:
	var result := state.settlement_refuel()
	var service_message := "+%d fuel loaded for %d Ashmarks. %s." % [int(result.get("fuel_added", 0)), int(result.get("cost", 0)), _service_action_status_text()] if bool(result.get("ok", false)) else "Refuel blocked: %s." % String(result.get("reason", "unknown"))
	last_recovery_receipt = service_message
	last_journey_receipt = "SERVICE · %s" % service_message
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "refuel", "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_settlement_hull_pressed() -> void:
	var result := state.settlement_repair_hull()
	var service_message := "+%d hull restored for %d Ashmarks. %s." % [int(result.get("hull_added", 0)), int(result.get("cost", 0)), _service_action_status_text()] if bool(result.get("ok", false)) else "Hull repair blocked: %s." % String(result.get("reason", "unknown"))
	last_recovery_receipt = service_message
	last_journey_receipt = "SERVICE · %s" % service_message
	_set_event(service_message)
	_journal_event("settlement_service", {"service": "hull_repair", "ok": bool(result.get("ok", false))})
	if bool(result.get("ok", false)):
		_checkpoint("settlement_service")
	_refresh_ui()
	encounter_label.text = "%s\n%s" % ["SERVICE COMPLETE" if bool(result.get("ok", false)) else "SERVICE UNAVAILABLE", service_message]

func _on_settlement_routes_pressed() -> void:
	if state.phase != "settlement" or not state.campaign_active:
		return
	journey_planner_active = true
	_refresh_ui()
	for raw_node_id in state.campaign_available_nodes():
		var node_id := String(raw_node_id)
		var node_button := campaign_map.button_for(node_id) as Button
		if _focus_control(node_button):
			_set_event("Recovery remains open. Select a highlighted road to preview it; no service action has been spent.")
			_set_route_preview("NEXT ROAD · Select a highlighted node to compare its cost, risk, pressure, and forecast before committing.", "safe")
			return

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
		_set_event("Intervention used: %s." % String(result.get("effect", intervention_id.replace("_", " ").capitalize())))
		_journal_event("intervention_used", {"intervention": intervention_id, "target": target_module, "leg": state.journey_leg})
		_checkpoint("intervention_used")
		if tutorial_mode and tutorial_director != null and tutorial_director.lesson_id == "respond":
			_tutorial_advance("damage", "ORDER ISSUED · Read the receipt before advancing; it names the protection, redirect, or power change.")
	_refresh_ui()

func save_run(silent: bool = false) -> bool:
	return _save_run_to_paths(SAVE_PATH, SAVE_BACKUP_PATH, silent)

func save_tutorial_run(silent: bool = false) -> bool:
	return _save_run_to_paths(TUTORIAL_SAVE_PATH, TUTORIAL_BACKUP_PATH, silent)

func _save_run_to_paths(save_path: String, backup_path: String, silent: bool) -> bool:
	var backup_result := _preserve_valid_save_backup(save_path, backup_path)
	if not bool(backup_result.get("ok", false)):
		_set_event("Save failed before overwrite: %s." % String(backup_result.get("reason", "backup could not be written")))
		return false
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		_set_event("Save failed: %s." % error_string(FileAccess.get_open_error()))
		return false
	var payload := state.serialize()
	payload["tutorial_mode"] = tutorial_mode
	if tutorial_mode and tutorial_director != null:
		payload["tutorial_progress"] = tutorial_director.serialize()
		payload["tutorial_lesson_snapshot"] = tutorial_lesson_snapshot.duplicate(true)
		payload["tutorial_lesson_snapshots"] = tutorial_lesson_snapshots.duplicate(true)
		payload["tutorial_director_snapshots"] = tutorial_director_snapshots.duplicate(true)
	payload["build_version"] = String(ProjectSettings.get_setting("application/config/version", "unknown"))
	payload["saved_at_unix"] = int(Time.get_unix_time_from_system())
	payload["presentation"] = {
		"journey_departure_snapshot": journey_departure_snapshot.duplicate(true),
		"journey_arrival_active": journey_arrival_active,
		"journey_arrival_view": journey_arrival_view.duplicate(true),
		"last_recovery_receipt": last_recovery_receipt,
		"last_journey_receipt": last_journey_receipt
	}
	file.store_string(JSON.stringify(payload))
	file.close()
	if not silent:
		_set_event("March saved locally. Continue will resume from this decision.")
		_journal_event("run_saved", {"phase": state.phase, "day": state.day})
		_refresh_ui()
	return true

func _preserve_valid_save_backup(save_path: String = SAVE_PATH, backup_path: String = SAVE_BACKUP_PATH) -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {"ok": true, "backed_up": false}
	var existing_text := FileAccess.get_file_as_string(save_path)
	if not _serialized_save_text_is_valid(existing_text):
		return {"ok": true, "backed_up": false}
	var previous_backup := FileAccess.get_file_as_string(backup_path) if FileAccess.file_exists(backup_path) else ""
	var backup_file := FileAccess.open(backup_path, FileAccess.WRITE)
	if backup_file == null:
		return {"ok": false, "reason": "backup could not be opened: %s" % error_string(FileAccess.get_open_error())}
	backup_file.store_string(existing_text)
	backup_file.close()
	if _serialized_save_text_is_valid(FileAccess.get_file_as_string(backup_path)):
		return {"ok": true, "backed_up": true}
	if not previous_backup.is_empty():
		var restore_file := FileAccess.open(backup_path, FileAccess.WRITE)
		if restore_file != null:
			restore_file.store_string(previous_backup)
			restore_file.close()
	return {"ok": false, "reason": "backup validation failed"}

func _serialized_save_text_is_valid(serialized_text: String) -> bool:
	var parser := JSON.new()
	if parser.parse(serialized_text) != OK:
		return false
	var parsed = parser.data
	if not parsed is Dictionary:
		return false
	return bool(LongMarchState.new(0).load_serialized(parsed).get("ok", false))

func _on_save_pressed() -> void:
	save_run()

func load_saved_run() -> bool:
	return _load_saved_run_from_path(SAVE_PATH)

func load_tutorial_run() -> bool:
	return _load_saved_run_from_path(TUTORIAL_SAVE_PATH)

func _load_saved_run_from_path(save_path: String) -> bool:
	if not FileAccess.file_exists(save_path):
		_set_event("No local march checkpoint exists yet.")
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
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
	tutorial_mode = bool(parsed.get("tutorial_mode", false))
	if tutorial_mode:
		if tutorial_director == null:
			tutorial_director = TutorialDirectorScript.new()
		tutorial_director.restore(parsed.get("tutorial_progress", {}))
		tutorial_lesson_snapshot = Dictionary(parsed.get("tutorial_lesson_snapshot", state.serialize())).duplicate(true)
		tutorial_lesson_snapshots = Dictionary(parsed.get("tutorial_lesson_snapshots", {tutorial_director.lesson_id: tutorial_lesson_snapshot})).duplicate(true)
		tutorial_director_snapshots = Dictionary(parsed.get("tutorial_director_snapshots", {tutorial_director.lesson_id: tutorial_director.serialize()})).duplicate(true)
	starting_region_id = state.campaign_region_id
	var presentation: Dictionary = parsed.get("presentation", {})
	settlement_hub_active = true
	settlement_detail_mode = "hub"
	journey_arrival_active = bool(presentation.get("journey_arrival_active", false)) and not state.encounter_active
	journey_arrival_view = Dictionary(presentation.get("journey_arrival_view", {})).duplicate(true) if journey_arrival_active else {}
	journey_departure_snapshot = Dictionary(presentation.get("journey_departure_snapshot", {})).duplicate(true)
	journey_transition_active = not journey_arrival_active and state.phase in ["battle", "final_battle"] and state.encounter_active and state.encounter_step == 0
	journey_transition_view = _restore_journey_transition_view() if journey_transition_active else {}
	journey_planner_active = false
	contact_inspection_active = false
	debrief_inspection_active = false
	contact_fortress_before = {}
	last_recovery_receipt = String(presentation.get("last_recovery_receipt", ""))
	last_journey_receipt = String(presentation.get("last_journey_receipt", ""))
	selected_campaign_node_id = ""
	selected_module_cell = Vector2i(-1, -1)
	if not state.modules.is_empty():
		selected_module_id = String(state.modules[0].get("id", selected_module_id))
		selected_module_cell = Vector2i(state.modules[0].get("position", Vector2i.ZERO))
		placement_rotated = bool(state.modules[0].get("rotated", false))
		_select_module_option(selected_module_id)
	fortress_panel.state = state
	_set_event("March restored from the local checkpoint.")
	result_recorded = state.phase == "results"
	results_chassis_reviewed = false
	last_rendered_phase = ""
	_journal_event("run_loaded", {"phase": state.phase, "day": state.day})
	_refresh_tutorial_ui()
	_refresh_ui()
	return true

func _on_load_pressed() -> void:
	load_saved_run()

func _on_reset_pressed() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("The fortress is back at %s with a clean maintenance slate." % String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location)))
	_journal_event("run_reset")
	_refresh_ui()

func _on_play_again_pressed() -> void:
	if not play_again_requested.get_connections().is_empty():
		play_again_requested.emit()
		return
	start_replay_from_results()

func focus_replay_action() -> void:
	_focus_control(debrief_panel.replay_button if debrief_panel != null and debrief_panel.visible else play_again_button)

func focus_march_on_action() -> void:
	_focus_control(debrief_panel.march_on_button if debrief_panel != null and debrief_panel.visible else march_on_button)

func _on_march_on_pressed() -> void:
	if state.phase != "results":
		return
	var next_region_id := "ashgate_lowlands" if state.campaign_region_id == "flooded_veyru" else "flooded_veyru"
	_journal_event("march_on_requested", {"from_region": state.campaign_region_id, "to_region": next_region_id, "result": state.final_result})
	march_on_requested.emit(next_region_id)

func start_replay_from_results() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("A new %s march is ready. Answer the contract, inspect the chassis, and choose the first road." % state.campaign_region_name())
	_journal_event("run_restarted_from_results")
	_checkpoint("new_run_started")
	_refresh_ui()
	focus_current_action.call_deferred()

func _on_results_title_pressed() -> void:
	if not save_run():
		_set_event("Could not save the completed result. It remains open; use Pause to review save options.")
		_refresh_ui()
		_focus_control(debrief_panel.title_button if debrief_panel != null and debrief_panel.visible else results_title_button)
		return
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
	var pressure_band := state.campaign_pressure_band()
	campaign_title.text = "%s MAP" % state.campaign_region_name().to_upper()
	campaign_progress_bar.tooltip_text = "Secured encounters in the five-encounter %s chapter." % state.campaign_region_name()
	var pressure_effect := "Closing begins at 3 · Break at 5 can close Signal Causeway."
	var pressure_color := Color("#d8b568")
	if state.campaign_region_id == "flooded_veyru":
		pressure_effect = "Flooding begins at 3 · Breach at 5 closes Drowned Registry and opens Pilgrim Gantry."
		if pressure_band == "flooding":
			pressure_effect = "Flood Surge gains damage · Breach at 5 opens the guaranteed high-road recovery route."
			pressure_color = Color("#e89270")
		elif pressure_band == "breach":
			pressure_effect = "Drowned Registry is closed · Pilgrim Gantry is open and cannot close."
			pressure_color = Color("#ef8375")
	else:
		if pressure_band == "closing":
			pressure_effect = "Break begins at 5 and can close Signal Causeway without forecasting."
			pressure_color = Color("#e89270")
		elif pressure_band == "break":
			if state.campaign_node_closed("signal_causeway"):
				pressure_effect = "Signal Causeway is closed · ready forecasting gear or Iven Pell can reopen it."
			else:
				pressure_effect = "Forecasting keeps Signal Causeway open despite Break pressure."
			pressure_color = Color("#ef8375")
	campaign_pressure_label.text = "%s — %s · pressure %d · secured %d/5\n%s" % [state.campaign_pressure_name(), pressure_band.replace("_", " ").capitalize(), state.campaign_pressure, state.campaign_encounters_completed, pressure_effect]
	campaign_pressure_label.add_theme_color_override("font_color", pressure_color)
	var active_contract_status := state.veyru_contract_status if state.campaign_region_id == "flooded_veyru" else state.guard_contract_status
	if state.campaign_region_id == "flooded_veyru":
		var carrier_name := String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "none")) if not state.veyru_medicine_carrier_id.is_empty() else "none"
		campaign_path_label.text = "Medicine contract: %s · Carrier: %s" % [active_contract_status.replace("_", " ").capitalize(), carrier_name]
		if state.has_regional_development("veyru_public_archive_signal"):
			campaign_path_label.text += "\nRegional development: Public Archive Signal · Drowned Registry contacts known"
	else:
		campaign_path_label.text = "Guard contract: %s · Specialist: %s" % [active_contract_status.replace("_", " ").capitalize(), state.specialist_name()]

	var contract_offered := state.campaign_active and active_contract_status == "offered" and current_location_is_region_start()
	contract_title.visible = contract_offered
	contract_label.visible = contract_offered
	contract_accept_button.visible = contract_offered
	contract_decline_button.visible = contract_offered
	contract_accept_button.disabled = false
	contract_decline_button.disabled = false
	if state.campaign_region_id == "flooded_veyru":
		var medicine_status := state.veyru_medicine_contract_status()
		var carrier_name := String(medicine_status.get("carrier_name", "No carrier"))
		contract_title.text = "LANTERN QUAY CONTRACT"
		contract_label.text = "Carry sealed medicine cases to the Dry Archive. Flood contacts will value the exact reserved carrier shown below."
		contract_accept_button.text = "CARRY SEALED MEDICINES\nCARRIER · %s\nDELIVERY · +28 ASHMARKS · +2 TRUST · +1 CAMP ACTION" % carrier_name.to_upper()
		contract_accept_button.tooltip_text = "Reserve %s as the medicine carrier. Losing it fails the delivery but does not end the run." % carrier_name
		contract_accept_button.disabled = not bool(medicine_status.get("available", false))
		if contract_accept_button.disabled:
			contract_accept_button.text += "\nLOCKED · %s" % String(medicine_status.get("reason", "No carrier available")).to_upper()
		contract_decline_button.text = "DECLINE THE DELIVERY\nNO RESERVED CARRIER · MOBILITY +1\nONE CAMP ACTION · NO DELIVERY REWARD"
		contract_decline_button.tooltip_text = "Keep cargo capacity free and gain one Mobility tendency, but forgo the medicine reward and extra camp action."
	else:
		contract_title.text = "ASHGATE CONTRACT"
		contract_label.text = "Morrowline's parts wagon is exposed. Decide whether its payment and trust are worth a harder camp approach."
		contract_accept_button.text = "GUARD THE CONVOY\nMORROWLINE · EACH ENEMY +1 HP\nON ARRIVAL · +30 ASHMARKS · +2 TRUST"
		contract_accept_button.tooltip_text = "Accept a harder Morrowline approach in exchange for payment, trust, and 2 Morrowline service actions if the convoy arrives."
		contract_decline_button.text = "TRAVEL UNBOUND\nNO EXTRA ENEMY HP\nNO CONTRACT PAYOUT OR TRUST"
		contract_decline_button.tooltip_text = "Decline the escort, avoid its extra enemy endurance, and forgo the contract reward."

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
	var comparison_lines: Array[String] = ["COMPARE AVAILABLE ROADS · CONTRACT %s" % active_contract_status.replace("_", " ").to_upper()]
	for route in state.campaign_route_comparison(_selected_id(doctrine_option)):
		var visibility := String(route.get("visibility", "unscouted"))
		var development_name := String(route.get("regional_development", ""))
		var confidence_text := "%s · %s" % [visibility.to_upper(), development_name.to_upper()] if not development_name.is_empty() else visibility.to_upper()
		var risk_text := "RISK UNKNOWN" if visibility == "unscouted" else "%s %.0f%% RISK" % [String(route.get("risk_band", "high")).to_upper(), float(route.get("risk", 0.0)) * 100.0]
		var fuel_text := "%d FUEL" % int(route.get("fuel", 0))
		if int(route.get("fuel_discount", 0)) > 0:
			fuel_text += " · CONDENSER -%d" % int(route.get("fuel_discount", 0))
		var threats: Array = route.get("threats", [])
		var threat_text := ", ".join(threats) if not threats.is_empty() else String(route.get("threat_hint", "uncertain pressure"))
		var next_stops: Array = route.get("next_stops", [])
		comparison_lines.append("%s · %dD · %s · %s · %s · PRESSURE +%d\n%s · NEXT %s · %s" % [String(route.get("name", "Road")).to_upper(), int(route.get("days", 0)), fuel_text, confidence_text, risk_text, int(route.get("pressure_gain", 0)), threat_text.to_upper(), " / ".join(next_stops) if not next_stops.is_empty() else "FINAL", "RECOVERY FOLLOWS" if bool(route.get("settlement_follows", false)) else "NO SETTLEMENT NEXT"])
	campaign_comparison_panel.visible = state.campaign_active and planning_phase and not contract_offered and state.campaign_event_pending.is_empty() and options.size() > 1 and selected_campaign_node_id.is_empty()
	campaign_comparison_label.text = "\n".join(comparison_lines)
	var departure_block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
	var outgoing_nodes: Array[String] = []
	var closed_nodes: Array[String] = []
	var locked_reasons: Dictionary = {}
	var active_campaign_edges := state.campaign_edges()
	for raw_node_id in active_campaign_edges.get(state.current_location, []):
		var node_id := String(raw_node_id)
		outgoing_nodes.append(node_id)
		if state.campaign_node_closed(node_id):
			closed_nodes.append(node_id)
		var lock_reason := state.campaign_node_lock_reason(node_id)
		if not lock_reason.is_empty():
			locked_reasons[node_id] = lock_reason
	campaign_map.configure({
		"region_id": state.campaign_region_id,
		"edges": active_campaign_edges,
		"current_node": state.current_location,
		"secured_path": state.campaign_path,
		"available_nodes": options,
		"closed_nodes": closed_nodes,
		"locked_reasons": locked_reasons,
		"outgoing_nodes": outgoing_nodes,
		"selected_node": selected_campaign_node_id,
		"previews": previews,
		"assignment_markers": RoutePresenter.build_assignment_markers(state),
		"can_depart": phase_can_depart,
		"departure_block_reason": departure_block_reason,
		"heat_limit": LongMarchState.BASE_HEAT_LIMIT,
		"current_fuel": state.fuel,
		"current_day": state.day,
		"current_pressure": state.campaign_pressure,
		"show_commit": state.campaign_active and planning_phase,
		"interaction_blocked": contract_offered or not state.campaign_event_pending.is_empty()
	})
	_connect_campaign_node_focus_scrolling()
	campaign_cancel_button.visible = planning_phase and not selected_campaign_node_id.is_empty()
	var selected_preview: Dictionary = previews.get(selected_campaign_node_id, {})
	campaign_commit_intel_label.visible = planning_phase and not selected_preview.is_empty()
	if not selected_preview.is_empty():
		var visibility := String(selected_preview.get("visibility", "unscouted"))
		var threat_hint := String(selected_preview.get("threat_hint", "uncertain pressure"))
		var doctrine_id := _selected_id(doctrine_option)
		if visibility == "known":
			var counters: Array = selected_preview.get("counter_hints", [])
			campaign_commit_intel_label.text = "KNOWN CONTACTS · %s%s" % [", ".join(selected_preview.get("threats", [])), "\nPREPARE · %s" % " or ".join(counters) if not counters.is_empty() else ""]
			var ready_counters: Array = selected_preview.get("ready_counter_names", [])
			campaign_commit_intel_label.text += "\nREADY NOW · %s" % (", ".join(ready_counters) if not ready_counters.is_empty() else "NO LISTED MODULE COUNTER")
			campaign_commit_intel_label.add_theme_color_override("font_color", Color("#9fddbd"))
		elif visibility == "forecast":
			campaign_commit_intel_label.text = "EXPECTED HAZARD · %s · Exact contacts remain uncertain." % threat_hint
			campaign_commit_intel_label.add_theme_color_override("font_color", Color("#e8c58e"))
		else:
			campaign_commit_intel_label.text = "BROAD WARNING · %s · Risk, reward, and exact contacts are unknown." % threat_hint
			campaign_commit_intel_label.add_theme_color_override("font_color", Color("#cbb8e8"))
		campaign_commit_intel_label.text += "\nDOCTRINE · %s · %s" % [doctrine_id.replace("_", " ").to_upper(), String(DOCTRINE_COMMIT_SUMMARIES.get(doctrine_id, "review its current effects above"))]
		if doctrine_id == "run_hot" and int(selected_preview.get("predicted_heat", 0)) > LongMarchState.BASE_HEAT_LIMIT:
			campaign_commit_intel_label.add_theme_color_override("font_color", Color("#ef8375"))
		if state.phase == "settlement" and state.settlement_actions_remaining > 0:
			var service_word := "action" if state.settlement_actions_remaining == 1 else "actions"
			var service_verb := "remains" if state.settlement_actions_remaining == 1 else "remain"
			campaign_commit_intel_label.text += "\nUNUSED RECOVERY · %d service %s %s. Departing ends access to them." % [state.settlement_actions_remaining, service_word, service_verb]
			if not (doctrine_id == "run_hot" and int(selected_preview.get("predicted_heat", 0)) > LongMarchState.BASE_HEAT_LIMIT):
				campaign_commit_intel_label.add_theme_color_override("font_color", Color("#e8c58e"))

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
		var effect := String(choice.get("effect", ""))
		var choice_text := "%s\n%s" % [String(choice.label), effect]
		button.text = choice_text if choice_enabled else "%s\nLOCKED · %s" % [choice_text, locked_reason.to_upper()]
		button.tooltip_text = "" if choice_enabled else locked_reason
		var line_count := choice_text.count("\n") + 1
		button.custom_minimum_size = Vector2(0, 72 if line_count >= 3 and choice_enabled else (88 if line_count >= 3 else (56 if choice_enabled else 72)))
		button.disabled = not choice_enabled
		button.set_meta("choice_id", String(choice.id))

	var recruit_status := state.iven_recruitment_status()
	recruit_iven_button.visible = state.campaign_active and state.current_location == "broken_relay" and state.phase == "map" and state.specialist_id.is_empty() and state.campaign_event_pending.is_empty()
	var can_recruit_iven := bool(recruit_status.get("available", false))
	var recruit_reason := String(recruit_status.get("reason", ""))
	recruit_iven_button.disabled = not can_recruit_iven
	var recruit_offer := "RECRUIT IVEN PELL · 12 ASHMARKS\nREVEAL CONTACTS · RISK UP TO -8pt\nENCOUNTER PRESSURE -1 · ANTI-STORM DAMAGE +2"
	recruit_iven_button.text = recruit_offer if can_recruit_iven else "%s\nLOCKED · %s" % [recruit_offer, recruit_reason.to_upper()]
	recruit_iven_button.custom_minimum_size = Vector2(0, 72 if can_recruit_iven else 90)
	recruit_iven_button.tooltip_text = "Adds exact immediate threat forecasts and storm navigation." if can_recruit_iven else recruit_reason

func _refresh_ui() -> void:
	var entered_results := state.phase == "results" and last_rendered_phase != "results"
	if entered_results:
		results_chassis_reviewed = false
		left_scroll.scroll_vertical = 0
		right_scroll.scroll_vertical = 0
	last_rendered_phase = state.phase
	_sync_new_active_combat_target()
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
			var dependency_state := String(dependency.get("state", "offline"))
			var current_durability := int(selected_installed.get("durability", 0))
			var maximum_durability := int(selected_definition.get("durability", 1))
			var condition_text := "Damaged · %d/%d durability · %s" % [current_durability, maximum_durability, dependency_state] if current_durability > 0 and current_durability < maximum_durability else dependency_state.capitalize()
			dependency_text = "%s%s" % [condition_text, ": " + String(reasons[0]) if not reasons.is_empty() else "."]
		var capacity_warning := _stored_module_capacity_warning(selected_definition, selected_installed)
		refit_label.text = "%s · %dx%d · mass %d · power %s · heat %d · %s. %s %s\nROLE · %s%s" % [
			String(selected_definition.get("name", "Select a module")),
			selected_shape.x,
			selected_shape.y,
			int(selected_definition.get("mass", 0)),
			_module_power_text(selected_definition),
			int(selected_definition.get("heat", 0)),
			mount_text,
			"On chassis for inspection. Use Edit Chassis or click the grid to move it." if not selected_installed.is_empty() else "Stored for placement. Use Edit Chassis or click an empty grid cell.",
			dependency_text,
			String(selected_definition.get("capability", "No field capability recorded.")),
			capacity_warning
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
	journey_banner.visible = not is_battle_phase and state.phase != "results"
	asset_row.visible = state.phase in ["refit", "battle", "final_battle"]
	_refresh_run_flow_tracker()
	results_group.visible = state.phase == "results"
	if state.phase == "results":
		results_summary_label.text = _result_summary_text()
		results_record_label.text = _result_record_text()
		results_replay_label.text = _result_replay_text()
		_configure_vertical_focus_cycle([current_order_button, results_inspect_button, feedback_button, march_on_button, play_again_button, results_title_button])
		var next_region_id := "ashgate_lowlands" if state.campaign_region_id == "flooded_veyru" else "flooded_veyru"
		var next_region_name := "ASHGATE LOWLANDS" if next_region_id == "ashgate_lowlands" else "FLOODED VEYRU"
		var next_region_result := String(starting_region_results.get(next_region_id, ""))
		march_on_button.text = "%s · %s" % ["REVISIT" if next_region_result in ["decisive_march", "scarred_march", "archive_kept", "archive_scarred"] else "MARCH ON", next_region_name]
		march_on_button.tooltip_text = "Begin a fresh %s run. This result remains in the March Charter; the local Continue slot changes only at the next save." % ("Ashgate" if next_region_id == "ashgate_lowlands" else "Flooded Veyru")
	guidance_label.text = _current_guidance()
	current_order_button.text = _current_action_jump_label()
	current_order_button.tooltip_text = "Move focus to %s without activating it." % _current_action_jump_target().to_lower()
	_refresh_pause_action_hint()
	phase_badge.text = "PHASE · %s" % state.phase.replace("_", " ").to_upper()
	refit_title.visible = is_refit_phase
	module_group.visible = is_refit_phase
	focus_chassis_button.visible = is_refit_phase
	refit_actions.visible = is_refit_phase
	refit_label.visible = is_refit_phase
	dependency_card_panel.visible = is_refit_phase
	if is_refit_phase and not selected_installed.is_empty():
		var dependency_card := state.module_dependency_card(selected_installed)
		dependency_card_label.text = "DEPENDENCY · %s\nDEPENDS ON · %s\nNOW · %s — %s\nIF LOST · %s\nCOUNTER · %s" % [String(dependency_card.get("name", "MODULE")).to_upper(), String(dependency_card.get("direct_dependency", "unknown")), String(dependency_card.get("state", "offline")).to_upper(), String(dependency_card.get("current_detail", "status unavailable")), String(dependency_card.get("next_failure", "No downstream effect recorded.")), String(dependency_card.get("legal_counter", "No legal counter recorded."))]
		var dependency_card_state := String(dependency_card.get("state", "offline"))
		dependency_card_label.add_theme_color_override("font_color", Color("#c8d1d1") if dependency_card_state == "ready" else (Color("#e8c58e") if dependency_card_state == "strained" else Color("#ef8375")))
	elif is_refit_phase:
		dependency_card_label.text = "DEPENDENCY · NOT INSTALLED\nPlace the selected module on the chassis to evaluate its live connections, failure chain, and legal counter."
		dependency_card_label.add_theme_color_override("font_color", Color("#89999e"))
	if state.phase == "settlement" and settlement_group.get_index() > doctrine_group.get_index():
		settlement_group.get_parent().move_child(settlement_group, doctrine_group.get_index())
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
	var advance_warning := _critical_combat_warning() if is_battle_phase else ""
	advance_warning_label.visible = is_battle_phase and not advance_warning.is_empty()
	advance_warning_label.text = "NEXT STEP WARNING · %s" % advance_warning
	if is_battle_phase:
		advance_encounter_button.text = _advance_encounter_action_text()
	combat_inspect_button.visible = is_battle_phase
	combat_inspect_button.disabled = not state.encounter_active
	var active_combat_target_id := _active_combat_target_id()
	var hull_under_threat := _hull_is_under_threat()
	if not active_combat_target_id.is_empty():
		var active_combat_target_name := String(state.module_definition(active_combat_target_id).get("name", active_combat_target_id.replace("_", " ").capitalize()))
		combat_inspect_button.text = "INSPECT TARGET · %s" % active_combat_target_name.to_upper()
	elif hull_under_threat:
		combat_inspect_button.text = "INSPECT CHASSIS · HULL EXPOSED"
	else:
		combat_inspect_button.text = "INSPECT CHASSIS · %s" % ("REVIEW DAMAGE" if state.encounter_intervention_used else "CHOOSE SEAL TARGET")
	results_inspect_button.visible = state.phase == "results"
	results_inspect_button.disabled = state.modules.is_empty()
	fortress_panel.custom_minimum_size.y = 230.0 if state.phase == "results" else 260.0
	fortress_panel.refresh_interaction_copy()
	intervention_title.visible = is_battle_phase
	intervention_help_label.visible = is_battle_phase
	intervention_title.text = "ENCOUNTER ORDER · %s" % ("SPENT" if state.encounter_intervention_used else "1 AVAILABLE")
	var seal_preview: Dictionary = state.encounter_seal_preview(selected_module_id) if not selected_installed.is_empty() else {"valid": false, "retargets": []}
	var seal_redirects: Array[String] = []
	for retarget in seal_preview.get("retargets", []):
		seal_redirects.append("%s → %s" % [String(retarget.get("enemy_name", "Threat")), String(retarget.get("target_name", "Hull"))])
	var cargo_id := state.sacrificable_cargo_id()
	var cargo_definition := state.module_definition(cargo_id) if not cargo_id.is_empty() else {}
	var cargo_tags: Array = cargo_definition.get("tags", [])
	var cargo_cost := "lose shelter" if "refuge" in cargo_tags else ("lose repair supply" if "parts" in cargo_tags else ("lose fuel feed" if "fuel" in cargo_tags else "lose module"))
	var cut_preview: Dictionary = state.encounter_cut_loose_preview()
	var cut_redirects: Array[String] = []
	for retarget in cut_preview.get("retargets", []):
		cut_redirects.append("%s → %s" % [String(retarget.get("enemy_name", "Threat")), String(retarget.get("target_name", "Hull"))])
	var vent_preview := state.encounter_vent_heat_preview()
	var vent_exposures: Array[String] = []
	for hit in vent_preview.get("affected_hits", []):
		vent_exposures.append("%s → %s %d→%d damage" % [String(hit.get("enemy_name", "Threat")), String(hit.get("target_name", "system")), int(hit.get("damage_before", 0)), int(hit.get("damage_after", 0))])
	var shift_preview := state.encounter_shift_power_preview()
	var shift_attacks: Array[String] = []
	for attack in shift_preview.get("affected_attacks", []):
		var attack_text := "%s %d→%d damage" % [String(attack.get("enemy_name", "Threat")), int(attack.get("damage_before", 0)), int(attack.get("damage_after", 0))]
		if attack_text not in shift_attacks:
			shift_attacks.append(attack_text)
	var selected_name := String(selected_definition.get("name", selected_module_id)) if not selected_installed.is_empty() else "no module selected"
	var shift_help := "SHIFT POWER · Heat %d→%d%s." % [int(shift_preview.get("heat_before", state.heat)), int(shift_preview.get("heat_after", state.heat)), "; attacks %s" % ", ".join(shift_attacks) if not shift_attacks.is_empty() else "; no operational weapon attack changes"]
	var seal_help := "SEAL COMPARTMENT · %s goes offline%s." % [selected_name, "; redirects %s" % ", ".join(seal_redirects) if not seal_redirects.is_empty() else "; no active threat currently targets it"] if bool(seal_preview.get("valid", false)) else "SEAL COMPARTMENT · %s." % String(seal_preview.get("reason", "select a chassis module first"))
	if hull_under_threat:
		seal_help += " This does not prevent the hull-directed hit."
	var cut_help := "CUT LOOSE CARGO · No installed cargo is available." if cargo_id.is_empty() else "CUT LOOSE CARGO · %s permanently removed (%s)%s." % [String(cargo_definition.get("name", cargo_id)), cargo_cost, "; redirects %s" % ", ".join(cut_redirects) if not cut_redirects.is_empty() else "; no active threat currently targets it"]
	var vent_help := "VENT HEAT · %d heat removed%s." % [int(vent_preview.get("heat_removed", 0)), "; exposed %s" % ", ".join(vent_exposures) if not vent_exposures.is_empty() else "; no current exterior target"]
	intervention_preview_texts = {"shift_power": shift_help, "seal_compartment": seal_help, "vent_heat": vent_help, "cut_loose_cargo": cut_help}
	if active_combat_target_id.is_empty() and not hull_under_threat:
		intervention_overview_text = "NO TARGET ASSIGNED · The order remains available after Advance unless the encounter ends. Review CONTACT NEXT before waiting. Focus or hover an order for exact effects. Seal target: %s." % selected_name
	else:
		intervention_overview_text = "Choose one emergency order. Focus or hover an action for its exact benefit and cost. Seal target: %s." % selected_name
	if state.encounter_intervention_used:
		intervention_help_label.text = "Emergency order spent. Hull is exposed; review the predicted hit, then advance." if hull_under_threat else "Emergency order spent. Inspect the predicted damage, then advance; one order returns next encounter."
	else:
		_apply_focused_intervention_preview()
	for index in range(intervention_buttons.size()):
		intervention_buttons[index].visible = is_battle_phase
		intervention_buttons[index].disabled = not state.encounter_active or state.encounter_intervention_used or (index == 1 and (selected_installed.is_empty() or not bool(seal_preview.get("valid", false)))) or (index == 3 and state.sacrificable_cargo_id().is_empty())
	if intervention_buttons.size() >= 4:
		intervention_buttons[0].text = "Shift power · attacks %s / heat %d→%d" % ["; ".join(shift_attacks) if not shift_attacks.is_empty() else "unchanged", int(shift_preview.get("heat_before", state.heat)), int(shift_preview.get("heat_after", state.heat))]
		intervention_buttons[0].tooltip_text = "Set weapon priority for the rest of this encounter. %s" % ["Attack changes: %s." % ", ".join(shift_attacks) if not shift_attacks.is_empty() else "No operational weapon attack currently gains damage."]
		var seal_target_name := String(selected_definition.get("name", "selected")) if not selected_installed.is_empty() else "selected module"
		intervention_buttons[1].text = "Seal %s · %s" % [seal_target_name, seal_redirects[0] if seal_redirects.size() == 1 else ("redirects %d threats" % seal_redirects.size() if seal_redirects.size() > 1 else "protected / offline")]
		intervention_buttons[1].tooltip_text = "Spend the encounter order. %s goes offline until the encounter ends.%s" % [seal_target_name, " Redirects %s." % ", ".join(seal_redirects) if not seal_redirects.is_empty() else " No active threat currently targets it."]
		intervention_buttons[2].text = "Vent heat · -%d heat / exterior +1" % int(vent_preview.get("heat_removed", 0))
		intervention_buttons[2].tooltip_text = "Reduce heat from %d to %d.%s" % [int(vent_preview.get("heat_before", state.heat)), int(vent_preview.get("heat_after", state.heat)), " Exposes %s." % ", ".join(vent_exposures) if not vent_exposures.is_empty() else " No current exterior target would take extra damage."]
		if cargo_id.is_empty():
			intervention_buttons[3].text = "Cut loose cargo · none available"
			intervention_buttons[3].tooltip_text = "No installed cargo module can be sacrificed."
		else:
			intervention_buttons[3].text = "Cut loose %s · %s" % [String(cargo_definition.get("name", cargo_id)), cargo_cost]
			intervention_buttons[3].tooltip_text = "Permanently remove this installed module for the rest of the run to reduce mass and enemy cargo incentive.%s" % [" Redirects %s." % ", ".join(cut_redirects) if not cut_redirects.is_empty() else " No active threat currently targets it."]
	if is_battle_phase:
		var combat_actions: Array = [current_order_button, advance_encounter_button, combat_inspect_button]
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
	settlement_routes_button.visible = state.phase == "settlement" and state.campaign_active
	final_journey_button.visible = state.phase == "settlement" and not state.campaign_active
	var action_word := "ACTION" if state.settlement_actions_remaining == 1 else "ACTIONS"
	settlement_title.text = "%s SERVICES · %d %s LEFT" % [_recovery_location_name().to_upper(), state.settlement_actions_remaining, action_word]
	var repair_missing := 0
	var repair_cost := 0
	var repair_candidate := _most_damaged_installed_module()
	if not selected_installed.is_empty():
		var repair_preview := state.settlement_repair_preview(selected_module_id)
		repair_missing = maxi(0, int(repair_preview.get("after", 0)) - int(repair_preview.get("before", 0)))
		repair_cost = int(repair_preview.get("cost", 0))
	var services_open := state.phase == "settlement" and state.settlement_actions_remaining > 0
	settlement_repair_button.disabled = not services_open
	if not services_open:
		settlement_repair_button.text = "REPAIR MODULE\nLOCKED · NO SERVICE ACTIONS LEFT"
		settlement_repair_button.tooltip_text = "No %s service actions remain." % _recovery_location_name()
	elif selected_installed.is_empty() or repair_missing <= 0:
		if repair_candidate.is_empty():
			settlement_repair_button.text = "REPAIR MODULE · ALL SYSTEMS FULL"
			settlement_repair_button.tooltip_text = "No installed system currently needs repair."
			settlement_repair_button.disabled = true
		else:
			var candidate_id := String(repair_candidate.get("id", ""))
			var candidate_name := String(state.module_definition(candidate_id).get("name", candidate_id))
			settlement_repair_button.text = "REVIEW %s · %d/%d\nNO COST · PRESS AGAIN TO REPAIR" % [candidate_name.to_upper(), int(repair_candidate.get("durability", 0)), int(repair_candidate.get("maximum_durability", 1))]
			settlement_repair_button.tooltip_text = "Select and inspect %s without spending a service action; press again to confirm its repair." % candidate_name
	else:
		var repair_preview := state.settlement_repair_preview(selected_module_id)
		var repair_amount := int(repair_preview.get("restored", 0))
		var mara_bonus := int(repair_preview.get("mara_bonus", 0))
		var durability_before := int(selected_installed.get("durability", 0))
		settlement_repair_button.text = "REPAIR %s +%d · %d ASHMARKS%s\nDURABILITY %d→%d · ACTIONS %d→%d" % [String(selected_definition.get("name", "module")).to_upper(), repair_amount, repair_cost, " · MARA +%d" % mara_bonus if mara_bonus > 0 else "", durability_before, int(repair_preview.get("after", durability_before)), state.settlement_actions_remaining, maxi(0, state.settlement_actions_remaining - 1)]
		settlement_repair_button.tooltip_text = "Restore %d durability to %s for %d Ashmarks.%s" % [repair_amount, String(selected_definition.get("name", "the selected module")), repair_cost, " Mara supplies the final point." if mara_bonus > 0 else ""]
		if state.money < repair_cost:
			settlement_repair_button.disabled = true
			settlement_repair_button.text += "\nLOCKED · HAVE %d ASHMARKS" % state.money
	if state.campaign_region_id == "flooded_veyru":
		settlement_refuel_button.text = "TAKE +1 EMERGENCY FUEL · FREE\nFUEL %d→%d · ACTIONS %d→%d" % [state.fuel, state.fuel + 1, state.settlement_actions_remaining, maxi(0, state.settlement_actions_remaining - 1)]
		settlement_refuel_button.disabled = not services_open or state.fuel >= 2
		if not services_open:
			settlement_refuel_button.text += "\nLOCKED · NO SERVICE ACTIONS LEFT"
		elif state.fuel >= 2:
			settlement_refuel_button.text += "\nLOCKED · RESERVED FOR FUEL BELOW 2"
	else:
		settlement_refuel_button.text = "BUY +2 FUEL · 8 ASHMARKS\nFUEL %d→%d · ACTIONS %d→%d" % [state.fuel, state.fuel + 2, state.settlement_actions_remaining, maxi(0, state.settlement_actions_remaining - 1)]
		settlement_refuel_button.disabled = not services_open or state.money < 8
		if not services_open:
			settlement_refuel_button.text += "\nLOCKED · NO SERVICE ACTIONS LEFT"
		elif state.money < 8:
			settlement_refuel_button.text += "\nLOCKED · HAVE %d ASHMARKS" % state.money
	var hull_repair_amount := mini(2, 10 - state.hull_condition)
	settlement_hull_button.text = "HULL · FULL" if state.hull_condition >= 10 else "REPAIR +%d HULL · 10 ASHMARKS\nHULL %d→%d · ACTIONS %d→%d" % [hull_repair_amount, state.hull_condition, state.hull_condition + hull_repair_amount, state.settlement_actions_remaining, maxi(0, state.settlement_actions_remaining - 1)]
	settlement_hull_button.disabled = not services_open or state.hull_condition >= 10 or state.money < 10
	if state.hull_condition < 10:
		if not services_open:
			settlement_hull_button.text += "\nLOCKED · NO SERVICE ACTIONS LEFT"
		elif state.money < 10:
			settlement_hull_button.text += "\nLOCKED · HAVE %d ASHMARKS" % state.money
	for service_button in [settlement_repair_button, settlement_refuel_button, settlement_hull_button]:
		var line_breaks: int = service_button.text.count("\n")
		service_button.custom_minimum_size.y = 72 if line_breaks >= 2 else (56 if line_breaks == 1 else 42)
	settlement_routes_button.text = "REVIEW NEXT ROADS\nKEEP %d SERVICE ACTION%s AVAILABLE" % [state.settlement_actions_remaining, "" if state.settlement_actions_remaining == 1 else "S"] if state.settlement_actions_remaining > 0 else "RECOVERY COMPLETE · REVIEW NEXT ROADS\nSELECT A ROUTE TO PREVIEW IT"
	final_journey_button.disabled = state.phase != "settlement"
	_refresh_planning_focus()
	load_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	if state.campaign_active and state.phase in ["refit", "map", "settlement"]:
		if not state.campaign_event_pending.is_empty():
			_set_route_preview("A local decision blocks departure. Resolve it before choosing the next road.", "warning")
		elif _active_contract_status() == "offered":
			_set_route_preview("The first map branches are visible after the %s contract is answered." % ("Lantern Quay medicine" if state.campaign_region_id == "flooded_veyru" else "Ashgate convoy"))
		elif not selected_campaign_node_id.is_empty():
			_show_selected_route_preview(selected_campaign_node_id)
		elif state.phase == "settlement":
			_set_route_preview("%s recovery — %s. Refit freely, then choose a doctrine and the next road." % [_recovery_location_name(), _service_action_status_text()], "safe")
		else:
			_set_route_preview("Select a forward node to review it. Signal readiness and Iven Pell improve how much each route reveals.")
	elif state.phase == "refit":
		var departure := state.route_preview(_selected_id(route_option), _selected_id(doctrine_option))
		if bool(departure.get("ok", false)):
			var risk := float(departure.risk)
			var days := int(departure.days)
			_set_route_preview("Departure forecast — %d day%s, %d fuel, %.0f%% risk, pressure %d, predicted heat %d/%d." % [days, "" if days == 1 else "s", int(departure.fuel), risk * 100.0, int(departure.pressure), int(departure.predicted_heat), LongMarchState.BASE_HEAT_LIMIT], "safe" if risk <= 0.18 else ("warning" if risk <= 0.32 else "danger"))
	elif state.phase == "settlement":
		_set_route_preview("Morrowline recovery — %s. Refit freely, then choose a doctrine for Meridian Pass." % _service_action_status_text(), "safe")
	elif state.phase == "results":
		_set_route_preview("Run complete — %s." % state.final_result.replace("_", " ").capitalize(), "safe")
	else:
		var active_risk := state.current_route_risk
		_set_route_preview("On the road — risk %.0f%%, pressure %d, doctrine %s." % [active_risk * 100.0, state.encounter_pressure, state.encounter_target_doctrine.replace("_", " ").capitalize()], "safe" if active_risk <= 0.18 else ("warning" if active_risk <= 0.32 else "danger"))
	var focus_owner := get_viewport().gui_get_focus_owner()
	if campaign_map.visible and focus_owner is Button and focus_owner in campaign_node_buttons:
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
	status_label.text = "SYSTEMS · %d ready   %d strained   %d offline%s" % [int(dependencies.ready), int(dependencies.strained), int(dependencies.offline), "   ·   %s %s %d" % [state.campaign_pressure_name().to_upper(), state.campaign_pressure_band().replace("_", " ").to_upper(), state.campaign_pressure] if state.campaign_active else ""]
	campaign_progress_bar.visible = state.campaign_active
	campaign_progress_bar.value = state.campaign_encounters_completed
	var combat_view := state.encounter_summary()
	combat_view["location_name"] = String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node))
	combat_view["doctrine"] = state.encounter_target_doctrine
	var combat_target_names := {"hull": "Hull"}
	for instance in state.modules:
		var combat_module_id := String(instance.get("id", ""))
		combat_target_names[combat_module_id] = String(state.module_definition(combat_module_id).get("name", combat_module_id.replace("_", " ").capitalize()))
	combat_view["target_names"] = combat_target_names
	combat_panel.configure(combat_view, LongMarchState.ENCOUNTER_ENEMIES)
	var route_name := String(LongMarchState.ROUTES.get(state.journey_route, {}).get("name", "Meridian Pass" if state.journey_route == "meridian_pass" else "not chosen"))
	if state.campaign_active:
		var path_names: Array[String] = []
		var visible_path: Array[String] = state.campaign_path.duplicate()
		if is_battle_phase and state.journey_node not in visible_path:
			visible_path.append(state.journey_node)
		for node_id in visible_path:
			path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)))
		var progress_text := "Encounter %d/5 underway" % mini(state.campaign_encounters_completed + 1, 5) if is_battle_phase else "%d/5 encounters secured" % state.campaign_encounters_completed
		journey_label.text = "%s — %s\nPhase: %s | Current node: %s | %s" % [state.campaign_region_name().to_upper(), " → ".join(path_names), state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), progress_text]
	else:
		journey_label.text = "JOURNEY — Ashgate Depot → Morrowline Camp → Meridian Pass\nPhase: %s | Current node: %s | Route: %s" % [state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), route_name]
	var selected_block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
	var selected_node_name := String(LongMarchState.CAMPAIGN_NODES.get(selected_campaign_node_id, {}).get("name", selected_campaign_node_id))
	var selected_review := "Resolve departure block: %s." % selected_block_reason if not selected_block_reason.is_empty() else ("Final commitment: failure ends the run; there is no retreat. Review costs and doctrine, then commit when ready." if selected_campaign_node_id == state.campaign_final_node_id() else "Review its costs and doctrine, then commit when ready.")
	var selected_instruction := "%s selected · %s %s cancels selection." % [selected_node_name, selected_review, _cancel_shortcut(false)]
	if state.phase == "results":
		encounter_label.text = "RUN RESULT — %s\nDay %d · Hull %d/10 · Ashmarks %d · Trust %d · Contract %s · %d systems offline" % [state.final_result.replace("_", " ").capitalize(), state.day, state.hull_condition, state.money, state.settlement_trust, _active_contract_status().replace("_", " ").capitalize(), int(dependencies.offline)]
		encounter_label.add_theme_color_override("font_color", Color("#f0d29d"))
	elif not selected_campaign_node_id.is_empty():
		encounter_label.text = "ROUTE READY FOR REVIEW\n%s" % selected_instruction
		encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
	elif not state.campaign_event_pending.is_empty():
		var pending_event := state.campaign_event_details()
		encounter_label.text = "DECISION REQUIRED · %s\nChoose one response below before the fortress can depart." % String(pending_event.get("title", "Local event")).to_upper()
		encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
	elif state.phase == "settlement" and state.encounter_outcome != "forced_retreat":
		encounter_label.text = "%s RECOVERY\n%s. Refit freely, then prepare for the next road." % [_recovery_location_name().to_upper(), _service_action_status_text()]
		encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
	elif not state.encounter_outcome.is_empty():
		var last_consequence := state.encounter_report[-1] if not state.encounter_report.is_empty() else "The road is clear."
		encounter_label.text = "AFTER-ACTION — %s · resolved in %d step%s\n%s" % [state.encounter_outcome.replace("_", " ").to_upper(), state.encounter_step, "" if state.encounter_step == 1 else "s", String(last_consequence)]
		encounter_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	else:
		if _active_contract_status() == "offered":
			encounter_label.text = "%s PREPARATION\nAnswer the %s contract to open the first roads." % [state.campaign_region_name().to_upper(), "medicine" if state.campaign_region_id == "flooded_veyru" else "convoy"]
		elif state.phase == "settlement":
			encounter_label.text = "%s RECOVERY\n%s. Refit freely, then prepare for the next road." % [_recovery_location_name().to_upper(), _service_action_status_text()]
		else:
			encounter_label.text = "ROUTE PLANNING\nSelect a cyan route and review its costs."
		encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
	var recent: Array[String] = []
	var start := maxi(0, state.log.size() - 4)
	for index in range(start, state.log.size()):
		recent.append(state.log[index])
	log_label.text = "RECENT ORDERS & DAMAGE\n• " + ("\n• ".join(recent) if not recent.is_empty() else "The crew is waiting for a route order.")
	if event_label.text.is_empty():
		event_label.text = "%s is ready. Inspect the chassis, answer the contract, then choose a highlighted map node." % String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location))
	fortress_panel.state = state
	fortress_panel.placement_module_id = selected_module_id
	fortress_panel.placement_rotated = placement_rotated
	fortress_panel.selected_cell = selected_module_cell
	fortress_panel.combat_target_ids.clear()
	fortress_panel.hull_under_threat = is_battle_phase and hull_under_threat
	if is_battle_phase:
		for enemy in state.encounter_enemies:
			var target_id := String(enemy.get("target", ""))
			if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)) and not target_id.is_empty() and target_id != "hull" and target_id not in fortress_panel.combat_target_ids:
				fortress_panel.combat_target_ids.append(target_id)
	fortress_panel.queue_redraw()
	if tutorial_mode:
		var tutorial_lesson := tutorial_director.lesson_id
		var tutorial_refit_lesson := tutorial_lesson in ["place_engine", "place_weapon", "inspect_machine"]
		subtitle_label.text = "THE FIRST WATCH · Ashgate Muster Yard"
		journey_label.text = "MUSTER YARD DRILL\nBuild the dependency chains, then take the fortress onto one controlled road contact."
		if state.phase == "refit":
			encounter_label.text = "CURRENT LESSON\n%s" % String(tutorial_director.current_copy().get("action", "Prepare the fortress."))
			encounter_label.add_theme_color_override("font_color", Color("#d8c389"))
		for hidden_metric in ["day", "money"]:
			if metric_panels.has(hidden_metric):
				metric_panels[hidden_metric].visible = false
		guidance_label.visible = false
		run_flow_heading_row.visible = false
		run_flow_tracker.visible = false
		asset_row.visible = false
		refit_title.visible = tutorial_refit_lesson
		module_group.visible = tutorial_refit_lesson
		focus_chassis_button.visible = tutorial_refit_lesson
		refit_actions.visible = tutorial_refit_lesson
		refit_label.visible = tutorial_refit_lesson
		dependency_card_panel.visible = tutorial_refit_lesson
		doctrine_group.visible = tutorial_lesson == "plan_road"
		doctrine_detail_label.visible = tutorial_lesson == "plan_road"
		route_group.visible = tutorial_lesson == "plan_road"
		route_preview_label.visible = tutorial_lesson == "plan_road"
		travel_button.visible = tutorial_lesson == "plan_road"
		settlement_refuel_button.visible = false
		settlement_hull_button.visible = false
		settlement_routes_button.visible = false
		final_journey_button.visible = false
		how_to_play_button.visible = false
	_apply_start_detail_visibility()
	_refresh_settlement_hub(snapshot)
	_refresh_journey_planner(snapshot)
	_refresh_journey_transition()
	_refresh_road_contact(snapshot, combat_view)
	_refresh_roadside_event(snapshot)
	_refresh_journey_arrival()
	_refresh_debrief()
	_refresh_recovery_panel(snapshot)
	_refresh_tutorial_ui()
	if high_contrast_enabled:
		VisualContrast.apply_to_tree(self, true)
	_ensure_current_focus()

func _current_guidance() -> String:
	if tutorial_mode and tutorial_director != null:
		var tutorial_copy := tutorial_director.current_copy()
		return "FIRST WATCH · %s" % String(tutorial_copy.get("action", "Follow the current lesson."))
	if state.phase == "results":
		return "DEBRIEF · Final chassis reviewed. Record playtest notes while the decisions are fresh." if results_chassis_reviewed else "DEBRIEF · Inspect the surviving systems, then record playtest notes while the decisions are fresh."
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
			var critical_warning := _critical_combat_warning()
			if not critical_warning.is_empty():
				var critical_action := "No emergency order remains; inspect the forecast, then advance." if state.encounter_intervention_used else "Review the emergency orders before advancing."
				return "CURRENT ORDER · %s %s" % [critical_warning, critical_action]
			return "CURRENT ORDER · %s under threat. Read cause and effect, then advance. %s" % [" and ".join(active_targets), order_status]
		if not nearest_enemy.is_empty():
			return "CURRENT ORDER · %s is %d step%s out. Advance to step %d. %s" % [nearest_enemy, nearest_steps, "" if nearest_steps == 1 else "s", mini(state.encounter_step + 1, 6), order_status]
		return "CURRENT ORDER · Advance the encounter and watch for a new target. %s" % order_status
	if not state.campaign_event_pending.is_empty():
		return "DECISION REQUIRED · Resolve the local event below before the fortress can depart."
	if _settlement_hub_available() and not settlement_hub_active:
		if settlement_detail_mode == "workshop":
			return "WORKSHOP · Inspect dependencies and refit the chassis. Return to the bazaar when preparation is complete."
		if settlement_detail_mode == "journey" and selected_campaign_node_id.is_empty():
			return "ROUTE TABLE · Select one highlighted destination to inspect it; Commit is a separate action."
	if _active_contract_status() == "offered":
		return "CURRENT ORDER · Decide whether to carry Lantern Quay's sealed medicines. This unlocks the first roads." if state.campaign_region_id == "flooded_veyru" else "CURRENT ORDER · Decide whether to guard Morrowline's parts convoy. This unlocks the first roads."
	if not selected_campaign_node_id.is_empty():
		var node_name := String(LongMarchState.CAMPAIGN_NODES.get(selected_campaign_node_id, {}).get("name", selected_campaign_node_id))
		var block_reason := _campaign_departure_block_reason(selected_campaign_node_id)
		if not block_reason.is_empty():
			return "DEPARTURE BLOCKED · %s. Refit or recover, then review this route again. %s cancels selection." % [block_reason, _cancel_shortcut(false)]
		if selected_campaign_node_id == state.campaign_final_node_id():
			return "FINAL COMMITMENT · %s is selected. Failure ends the run; there is no retreat. Review costs and doctrine, then press Commit. %s cancels selection." % [node_name, _cancel_shortcut(false)]
		return "ROUTE READY · %s is selected. Review its costs and doctrine, then press Commit. %s cancels selection." % [node_name, _cancel_shortcut(false)]
	if state.encounter_outcome == "forced_retreat":
		if state.phase == "settlement":
			return "RETREAT TO %s · %s. Review the after-action losses, recover, and refit before choosing another road." % [_recovery_location_name().to_upper(), _service_action_status_text()]
		return "RETREAT RECOVERED · Review the exact losses at left and the patched movement chain, refit if needed, then choose another road."
	if state.phase == "settlement":
		return "RECOVERY · %s. Repair or refuel, refit freely, then choose the next road." % _service_action_status_text()
	if state.campaign_active and state.phase in ["refit", "map"]:
		return "CURRENT ORDER · Select one cyan route on the map. Selection previews it; Commit begins travel."
	return "CURRENT ORDER · Prepare the fortress, review the route forecast, then depart when movement is ready."

func _current_action_jump_label() -> String:
	if state.phase == "results":
		return "GO TO FEEDBACK ↓" if results_chassis_reviewed else "GO TO CHASSIS REVIEW ↓"
	if state.phase in ["battle", "final_battle"]:
		return "GO TO BATTLE STEP ↓"
	if not state.campaign_event_pending.is_empty():
		return "GO TO DECISION ↓"
	if _settlement_hub_available() and not settlement_hub_active and (settlement_detail_mode == "workshop" or selected_campaign_node_id.is_empty()):
		return "GO TO CHASSIS ↓" if settlement_detail_mode == "workshop" else "GO TO ROUTES ↓"
	if _active_contract_status() == "offered":
		return "GO TO CONTRACT ↓"
	if not selected_campaign_node_id.is_empty() and _campaign_departure_block_reason(selected_campaign_node_id).is_empty():
		return "GO TO COMMIT ↓"
	if state.phase == "settlement" and state.settlement_actions_remaining > 0:
		return "GO TO RECOVERY ↓"
	if state.campaign_active and state.phase in ["refit", "map", "settlement"]:
		return "GO TO ROUTES ↓"
	return "GO TO DEPARTURE ↓"

func _current_action_jump_target() -> String:
	return _current_action_jump_label().trim_prefix("GO TO ").trim_suffix(" ↓").replace("_", " ")

func current_order_destination() -> String:
	return _current_action_jump_target()

func _critical_combat_warning() -> String:
	var best_priority := 0
	var best_warning := ""
	for enemy in state.encounter_enemies:
		if bool(enemy.get("defeated", false)) or not bool(enemy.get("arrived", false)):
			continue
		var impact: Dictionary = state.encounter_enemy_impact_preview(enemy)
		if impact.is_empty():
			continue
		var target_id := String(impact.get("target", ""))
		var target_name := "Hull" if target_id == "hull" else String(state.module_definition(target_id).get("name", target_id.replace("_", " ").capitalize()))
		var remaining := int(impact.get("remaining_durability", 1))
		var priority := 0
		var warning := ""
		if target_id == "hull" and remaining <= 0:
			priority = 3
			warning = "Hull collapse is predicted on the next step."
		elif remaining <= 0:
			priority = 2
			warning = "%s will be disabled." % target_name
			var dependency_changes: Array = impact.get("dependency_changes", [])
			if not dependency_changes.is_empty():
				var cascade_names: Array[String] = []
				for index in range(mini(2, dependency_changes.size())):
					var change: Dictionary = dependency_changes[index]
					cascade_names.append("%s → %s" % [String(change.get("name", "System")), String(change.get("to", "offline")).capitalize()])
				var hidden_count := dependency_changes.size() - cascade_names.size()
				warning = "%s · Cascade: %s%s." % [warning.trim_suffix("."), ", ".join(cascade_names), ", and %d more" % hidden_count if hidden_count > 0 else ""]
		elif int(impact.get("armor_absorbed", 0)) > 0 and int(impact.get("armor_remaining_durability", 1)) <= 0:
			priority = 1
			var armor_id := String(impact.get("armor_id", ""))
			var armor_name := String(state.module_definition(armor_id).get("name", armor_id.replace("_", " ").capitalize()))
			warning = "%s will break while protecting %s." % [armor_name, target_name]
		if priority > best_priority:
			best_priority = priority
			best_warning = warning
	return best_warning

func _advance_encounter_action_text() -> String:
	var next_step := mini(state.encounter_step + 1, 6)
	var arriving_names: Array[String] = []
	var active_targets: Array[String] = []
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
		elif int(definition.get("arrival_step", 0)) == next_step:
			arriving_names.append(String(definition.get("name", enemy_id)).to_upper())
	var consequence := ""
	if not arriving_names.is_empty():
		consequence = "\nCONTACT NEXT · %s" % " + ".join(arriving_names)
	elif not active_targets.is_empty():
		consequence = "\nACTIVE TARGET · %s" % " + ".join(active_targets).to_upper()
	return "ADVANCE · RESOLVE STEP %d OF 6%s" % [next_step, consequence]

func _result_summary_text() -> String:
	match state.final_result:
		"archive_kept":
			var carrier_name := String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "medicine carrier"))
			return "ARCHIVE KEPT · The %s delivered the sealed medicines, the fortress retained %d/10 hull, and the archive commitment held." % [carrier_name, state.hull_condition]
		"archive_scarred":
			var missed: Array[String] = []
			if state.hull_condition < 6:
				missed.append("hull ended at %d/10 (6 required)" % state.hull_condition)
			if state.veyru_contract_status != "completed":
				missed.append("medicine delivery ended %s" % state.veyru_contract_status.replace("_", " "))
			return "ARCHIVE SCARRED · The fortress reached the vault, but %s." % (" and ".join(missed) if not missed.is_empty() else "the final approach left lasting damage")
		"veyru_lost":
			if state.hull_condition <= 0:
				return "VEYRU LOST · The fortress hull reached zero at the Dry Archive."
			return "VEYRU LOST · %s at the Dry Archive." % String(_movement_failure_diagnosis().get("cause", "No operational, fuel-connected engine remained"))
		"decisive_march":
			var contract_note := "the guard contract was completed" if state.guard_contract_status == "completed" else ("the fortress travelled without the guard contract" if state.guard_contract_status == "declined" else "the guard contract was not completed")
			return "DECISIVE MARCH · Meridian Pass is open. Every final contact was defeated, the fortress retained %d/10 hull, and %s." % [state.hull_condition, contract_note]
		"scarred_march":
			var missed: Array[String] = []
			if state.hull_condition < 7:
				missed.append("hull ended at %d/10 (7 required)" % state.hull_condition)
			var undefeated := _undefeated_final_contacts().size()
			if undefeated > 0:
				missed.append("%d final contact%s remained" % [undefeated, "" if undefeated == 1 else "s"])
			return "SCARRED MARCH · The fortress crossed, but missed a decisive result because %s." % (", ".join(missed) if not missed.is_empty() else "the final approach left lasting damage")
		"march_failed":
			if state.hull_condition <= 0:
				return "MARCH FAILED · The fortress hull reached zero at Meridian Pass."
			return "MARCH FAILED · %s at Meridian Pass." % String(_movement_failure_diagnosis().get("cause", "No operational, fuel-connected engine remained"))
	return "UNCLASSIFIED DEBRIEF · The completed run has no recognized outcome."

func _result_replay_text() -> String:
	if state.final_result == "archive_kept":
		return "NEXT RUN · Test the other archive commitment or take the Registry shortcut under higher water."
	if state.final_result == "archive_scarred":
		if state.veyru_contract_status != "completed":
			return "NEXT RUN · CARRIER FIRST · Protect the named medicine system with doctrine, armor, sealing, or the safer Causeway."
		return "NEXT RUN · HULL FIRST · Spend an Evacuation Camp action before the final two contacts and reach the archive at 6/10 hull or better."
	if state.final_result == "veyru_lost":
		return "NEXT RUN · RECOVERY FIRST · Preserve the movement chain and use Pilgrim Gantry after a retreat or at Breach water."
	if state.final_result == "decisive_march":
		return "NEXT RUN · Test a different doctrine or road and see whether the fortress can remain decisive."
	if state.final_result == "scarred_march":
		var remaining_contacts := _undefeated_final_contacts()
		if state.hull_condition < 7:
			var hull_needed := 7 - state.hull_condition
			var contact_note := " Also prepare for %s." % ", ".join(remaining_contacts) if not remaining_contacts.is_empty() else ""
			var recovery_note := "%d Morrowline service action%s went unused; spend %s on hull or armor." % [state.settlement_actions_remaining, "" if state.settlement_actions_remaining == 1 else "s", "it" if state.settlement_actions_remaining == 1 else "one"] if state.settlement_actions_remaining > 0 else "Reserve a Morrowline service for hull or armor."
			return "NEXT RUN · HULL FIRST · Reach Meridian Pass with at least %d more hull. %s%s" % [hull_needed, recovery_note, contact_note]
		if not remaining_contacts.is_empty():
			var counters: Array[String] = []
			for enemy in state.encounter_enemies:
				if bool(enemy.get("defeated", false)):
					continue
				var enemy_id := String(enemy.get("id", ""))
				var counter := String(LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {}).get("counter", "increase reliable damage"))
				if counter not in counters:
					counters.append(counter)
			return "NEXT RUN · CONTACTS FIRST · Defeat %s before step 6; prepare %s." % [", ".join(remaining_contacts), " or ".join(counters)]
		return "NEXT RUN · Review the final causal report and preserve the system that produced the scarred result."
	if state.hull_condition <= 0:
		var recovery_note := "%d Morrowline service action%s went unused; spend %s on the hull." % [state.settlement_actions_remaining, "" if state.settlement_actions_remaining == 1 else "s", "it" if state.settlement_actions_remaining == 1 else "one"] if state.settlement_actions_remaining > 0 else "Reserve one Morrowline service for the hull."
		return "NEXT RUN · HULL FIRST · %s Then inspect active targets before spending the final Seal order." % recovery_note
	return "NEXT RUN · MOVEMENT FIRST · %s Preserve one Seal order for threats targeting that system." % String(_movement_failure_diagnosis().get("action", "Keep one engine fuel-connected."))

func _undefeated_final_contacts() -> Array[String]:
	var contacts: Array[String] = []
	for enemy in state.encounter_enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id := String(enemy.get("id", ""))
		var enemy_name := String(LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id.replace("_", " ").capitalize()))
		if enemy_name not in contacts:
			contacts.append(enemy_name)
	return contacts

func _movement_failure_diagnosis() -> Dictionary:
	for module in state.modules:
		var module_id := String(module.get("id", ""))
		var definition := state.module_definition(module_id)
		if "engine" not in definition.get("tags", []):
			continue
		var module_name := String(definition.get("name", module_id.replace("_", " ").capitalize()))
		var durability := int(module.get("durability", 0))
		var maximum := int(definition.get("durability", 0))
		if durability <= 0:
			return {
				"cause": "%s reached 0/%d durability" % [module_name, maximum],
				"action": "Repair %s above 0 durability before the final road." % module_name
			}
		var dependency := state.dependency_status(module)
		if String(dependency.get("state", "offline")) != "ready":
			var reasons: Array = dependency.get("reasons", [])
			var reason := String(reasons[0]) if not reasons.is_empty() else "its required connection was missing"
			return {
				"cause": "%s was offline: %s" % [module_name, reason],
				"action": "Keep %s ready: %s." % [module_name, reason]
			}
	return {
		"cause": "No engine remained installed",
		"action": "Carry and connect an engine before committing to %s." % String(LongMarchState.JOURNEY_NODES.get(state.campaign_final_node_id(), {}).get("name", "the final road"))
	}

func _result_record_text() -> String:
	var path_names: Array[String] = []
	for node_id in state.campaign_path:
		path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)))
	var dependencies: Dictionary = state.dependency_summary()
	var specialist_name := state.specialist_name()
	var stopping_line := ""
	if state.final_result in ["march_failed", "veyru_lost"] and state.current_location not in state.campaign_path:
		stopping_line = "\nStopped at: %s · %d/5 encounters secured" % [String(LongMarchState.CAMPAIGN_NODES.get(state.current_location, {}).get("name", state.current_location)), state.campaign_encounters_completed]
	var mara_line := "\n%s" % state.mara_debrief_line() if state.campaign_decisions.has("mara_meeting") else ""
	var occurrence_lines := state.occurrence_debrief_lines()
	var occurrence_block := "\n%s" % "\n".join(occurrence_lines) if not occurrence_lines.is_empty() else ""
	var carrier_record := " · Carrier: %s" % String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "none")) if state.campaign_region_id == "flooded_veyru" and not state.veyru_medicine_carrier_id.is_empty() else ""
	var development_record := "\nRegional development: PUBLIC ARCHIVE SIGNAL · future Veyru runs reveal Drowned Registry contacts" if state.earned_regional_development() == "veyru_public_archive_signal" else ""
	return "RUN RECORD · %s · %s%s\n%s: %s %d · Contract: %s%s · Specialist: %s\nKey decisions: %s%s%s%s\n%s recovery: %s\nFinal doctrine: %s\nSystems: %d ready · %d strained · %d offline\n%s" % [
		current_run_code(),
		" → ".join(path_names),
		stopping_line,
		state.campaign_pressure_name(),
		state.campaign_pressure_band().replace("_", " ").capitalize(),
		state.campaign_pressure,
		_active_contract_status().replace("_", " ").capitalize(),
		carrier_record,
		specialist_name,
		_campaign_decision_record_text(),
		mara_line,
		occurrence_block,
		development_record,
		_recovery_location_name(),
		_unused_recovery_text() if state.settlement_actions_remaining > 0 else "all service actions spent",
		state.encounter_target_doctrine.replace("_", " ").capitalize(),
		int(dependencies.get("ready", 0)),
		int(dependencies.get("strained", 0)),
		int(dependencies.get("offline", 0)),
		_result_system_condition_text()
	]

func current_run_code() -> String:
	var region_code := "VEY" if state.campaign_region_id == "flooded_veyru" else "ASH"
	return "%s-%d" % [region_code, state.seed]

func current_run_record_text() -> String:
	var path_names: Array[String] = []
	var visible_path: Array[String] = state.campaign_path.duplicate()
	if state.phase in ["battle", "final_battle"] and state.journey_node not in visible_path:
		visible_path.append(state.journey_node)
	for node_id in visible_path:
		path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)))
	var current_location_name := String(LongMarchState.CAMPAIGN_NODES.get(state.current_location, LongMarchState.JOURNEY_NODES.get(state.current_location, {})).get("name", state.current_location.replace("_", " ").capitalize()))
	var dependencies := state.dependency_summary()
	var contract_text := _active_contract_status().replace("_", " ").capitalize()
	if state.campaign_region_id == "flooded_veyru" and not state.veyru_medicine_carrier_id.is_empty():
		contract_text += " · Carrier: %s" % String(state.module_definition(state.veyru_medicine_carrier_id).get("name", state.veyru_medicine_carrier_id.replace("_", " ").capitalize()))
	var occurrence_lines := state.occurrence_debrief_lines()
	var occurrence_text := "; ".join(occurrence_lines) if not occurrence_lines.is_empty() else "none recorded"
	var decision_text := _campaign_decision_record_text()
	if decision_text in ["no route events on this path", "no regional decisions recorded"]:
		decision_text = "none recorded"
	var doctrine := state.encounter_target_doctrine if state.phase in ["battle", "final_battle", "results"] else _selected_id(doctrine_option)
	var next_order := _current_guidance().replace("CURRENT ORDER · ", "").replace("DEBRIEF · ", "")
	return "RUN ID · %s\n%s · DAY %d · %s · %s\n\nNEXT ORDER\n%s\n\nPROGRESS\n%d/5 encounters secured · %s · %s %d\nPath · %s\n\nCOMMITMENTS\nContract · %s\nDoctrine · %s\nSpecialist · %s\nDecisions · %s\nRoad occurrences · %s\n\nFORTRESS CONDITION\nFuel %d · Hull %d/10 · Heat %d/%d\nSystems · %d ready · %d strained · %d offline\n%s" % [
		current_run_code(),
		state.campaign_region_name().to_upper(),
		state.day,
		current_location_name,
		state.phase.replace("_", " ").capitalize(),
		next_order,
		state.campaign_encounters_completed,
		state.campaign_pressure_name(),
		state.campaign_pressure_band().replace("_", " ").capitalize(),
		state.campaign_pressure,
		" → ".join(path_names),
		contract_text,
		doctrine.replace("_", " ").capitalize(),
		state.specialist_name(),
		decision_text,
		occurrence_text,
		state.fuel,
		state.hull_condition,
		state.heat,
		LongMarchState.BASE_HEAT_LIMIT,
		int(dependencies.get("ready", 0)),
		int(dependencies.get("strained", 0)),
		int(dependencies.get("offline", 0)),
		_result_system_condition_text()
	]

func _campaign_decision_record_text() -> String:
	var decisions: Array[String] = []
	var recorded: Dictionary = state.campaign_decisions
	if state.campaign_region_id == "flooded_veyru":
		if recorded.has("drain_pumps"):
			decisions.append("Pump Gallery — %s" % ("drained the lower roads" if String(recorded.drain_pumps) == "drain_gallery" else "kept moving"))
		if recorded.has("registry_salvage"):
			decisions.append("Drowned Registry — %s" % ("recovered sealed records" if String(recorded.registry_salvage) == "recover_records" else "abandoned the flooded stacks"))
		if recorded.has("archive_broadcast"):
			decisions.append("Dry Archive — %s" % ("broadcast publicly" if String(recorded.archive_broadcast) == "broadcast_archive" else "sealed the signal"))
		return "; ".join(decisions) if not decisions.is_empty() else "no regional decisions recorded"
	if "soot_orchard" in state.campaign_path:
		var orchard_choice := String(recorded.get("salvage_choice", "rescue_workers" if state.workers_rescued else "take_fuel"))
		decisions.append("Soot Orchard — %s" % ("rescued workers" if orchard_choice == "rescue_workers" else "recovered fuel"))
	if "broken_relay" in state.campaign_path:
		var relay_choice := String(recorded.get("lost_signal", "restore_relay" if state.relay_repaired else "move_silent"))
		decisions.append("Broken Relay — %s" % ("restored broadcast" if relay_choice == "restore_relay" else "moved silently"))
	if "red_wheel_toll_bridge" in state.campaign_path:
		var toll_choice := String(recorded.get("toll_decision", ""))
		decisions.append("Red Wheel — %s" % ("paid toll" if toll_choice == "pay_toll" else ("broke blockade" if toll_choice == "break_blockade" else "decision not recorded")))
	return "; ".join(decisions) if not decisions.is_empty() else "no route events on this path"

func _unused_recovery_text() -> String:
	var count := state.settlement_actions_remaining
	return "%d service action%s left unused" % [count, "" if count == 1 else "s"]

func _result_system_condition_text() -> String:
	var damaged: Array[String] = []
	var unavailable: Array[String] = []
	for module in state.modules:
		var module_id := String(module.get("id", ""))
		var definition := state.module_definition(module_id)
		var module_name := String(definition.get("name", module_id.replace("_", " ").capitalize()))
		var current := int(module.get("durability", 0))
		var maximum := int(definition.get("durability", 0))
		if current < maximum:
			damaged.append("%s %d/%d" % [module_name, current, maximum])
		var dependency := state.dependency_status(module)
		if String(dependency.get("state", "offline")) != "offline":
			continue
		var reasons: Array = dependency.get("reasons", [])
		var reason := String(reasons[0]) if not reasons.is_empty() else "unavailable"
		unavailable.append("%s — %s" % [module_name, reason])
	return "Damage: %s\nUnavailable: %s" % [", ".join(damaged) if not damaged.is_empty() else "none", "; ".join(unavailable) if not unavailable.is_empty() else "none"]

func _service_action_status_text() -> String:
	var count := state.settlement_actions_remaining
	return "%d service action%s %s" % [count, "" if count == 1 else "s", "remains" if count == 1 else "remain"]

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
	var hull_under_threat: bool = false
	var controller_confirm_label: String = "A"
	var controller_cancel_label: String = "B"
	var pointer_inside: bool = false
	var family_colors := {
		"engine": Color("#b86f4b"),
		"weapon": Color("#b44949"),
		"power": Color("#a78845"),
		"workshop": Color("#b69555"),
		"crew_room": Color("#557fa1"),
		"armor": Color("#6f7b84"),
		"cargo": Color("#8e6d4f"),
		"signal": Color("#5e9b91"),
		"sustain": Color("#4f8790")
	}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_refresh_controller_tooltip()
		focus_entered.connect(queue_redraw)
		focus_exited.connect(queue_redraw)
		mouse_entered.connect(_set_pointer_inside.bind(true))
		mouse_exited.connect(_set_pointer_inside.bind(false))

	func _set_pointer_inside(value: bool) -> void:
		pointer_inside = value
		queue_redraw()

	func set_controller_labels(confirm_label: String, cancel_label: String) -> void:
		controller_confirm_label = confirm_label
		controller_cancel_label = cancel_label
		_refresh_controller_tooltip()
		queue_redraw()

	func refresh_interaction_copy() -> void:
		_refresh_controller_tooltip()
		queue_redraw()

	func _refresh_controller_tooltip() -> void:
		if state != null and state.phase in ["battle", "final_battle"]:
			tooltip_text = "Click a system to inspect it or choose a seal target. With keyboard or controller focus, use arrows and %s or Enter; %s or Escape returns to the encounter orders." % [controller_confirm_label, controller_cancel_label]
		elif state != null and state.phase == "results":
			tooltip_text = "Click a surviving system to inspect the final fortress. With keyboard or controller focus, use arrows and %s or Enter; %s or Escape returns to the debrief." % [controller_confirm_label, controller_cancel_label]
		elif state != null and not state.can_refit():
			tooltip_text = "Click a system to inspect its condition. Refit becomes available at a road stop."
		else:
			tooltip_text = "Click a module to select it, or click an empty cell to place or move. With keyboard or controller focus, use arrows and %s or Enter; %s or Escape returns to the desk." % [controller_confirm_label, controller_cancel_label]

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
					if has_focus():
						return "SELECTED · %s · MOVE TO AN EMPTY CELL" % hovered_name
					return "INSPECT · %s · EDIT CHASSIS TO MOVE" % hovered_name
				if has_focus():
					return "SELECT %s · %s / ENTER TO INSPECT" % [hovered_name, controller_confirm_label]
				return "CLICK TO INSPECT · %s" % hovered_name
		var validation := _placement_validation()
		if not has_focus():
			if not pointer_inside:
				var selected_name := String(state.module_definition(placement_module_id).get("name", "module")).to_upper()
				if selected_cell.x < 0:
					if bool(validation.get("ok", false)):
						return "STORED · %s · OPEN EDIT CHASSIS TO PLACE" % selected_name
					return "PLACEMENT BLOCKED · %s" % String(validation.get("reason", "invalid placement")).to_upper()
				return "INSPECT · %s · OPEN EDIT CHASSIS" % selected_name
			var pointer_action := "MOVE HERE" if selected_cell.x >= 0 else "PLACE HERE"
			if bool(validation.get("ok", false)):
				return "CLICK TO %s" % pointer_action
			return "PREVIEW BLOCKED · %s" % String(validation.get("reason", "invalid placement")).to_upper()
		if bool(validation.get("ok", false)):
			return "PLACEMENT READY · %s / ENTER TO APPLY" % controller_confirm_label
		return "BLOCKED · %s" % String(validation.get("reason", "invalid placement")).to_upper()

	func exterior_mount_count() -> int:
		if state == null:
			return 0
		var count := 0
		for instance in state.modules:
			if bool(instance.get("exterior", false)):
				count += 1
		return count

	func interaction_heading() -> String:
		var mount_status := "MOUNTS %d/%d" % [exterior_mount_count(), LongMarchState.MAX_EXTERIOR_MOUNTS]
		if not has_focus():
			if state != null and state.phase in ["battle", "final_battle"]:
				return "CHASSIS OVERVIEW · %s — Inspect Chassis chooses a seal target" % mount_status
			if state != null and state.phase == "results":
				return "CHASSIS OVERVIEW · %s — Inspect Final Chassis reviews survivors" % mount_status
			if state != null and not state.can_refit():
				return "CHASSIS OVERVIEW · %s — inspection only between road stops" % mount_status
			return "CHASSIS OVERVIEW · %s — read-only until Edit Chassis" % mount_status
		if state != null and state.can_refit():
			return "CHASSIS EDIT MODE · %s — arrows move · %s acts · %s returns" % [mount_status, controller_confirm_label, controller_cancel_label]
		if state != null and state.phase == "results":
			return "CHASSIS REVIEW · %s — arrows move · %s inspects · %s returns" % [mount_status, controller_confirm_label, controller_cancel_label]
		return "CHASSIS INSPECTION · %s — arrows move · %s selects · %s returns" % [mount_status, controller_confirm_label, controller_cancel_label]

	func locked_mode_help_text() -> String:
		if state == null:
			return "Chassis data is unavailable."
		if state.phase in ["battle", "final_battle"]:
			return "TARGETING · Inspect another system or choose Seal."
		if state.phase == "results":
			return "REVIEW · Compare another surviving system."
		return "REFIT LOCKED · Inspect condition; refit at a road stop."

	func inspection_detail_heading() -> String:
		if state == null:
			return "SYSTEM STATUS"
		if state.can_refit():
			return "REFIT STATUS" if has_focus() else "INSPECTED SYSTEM"
		if state.phase in ["battle", "final_battle"]:
			return "BATTLE SYSTEM"
		if state.phase == "results":
			return "FINAL SYSTEM"
		return "SYSTEM STATUS"

	func selected_capability_text() -> String:
		if state == null or placement_module_id.is_empty():
			return "No field capability recorded."
		return String(state.module_definition(placement_module_id).get("capability", "No field capability recorded."))

	func selected_power_text() -> String:
		if state == null or placement_module_id.is_empty():
			return "0"
		var definition := state.module_definition(placement_module_id)
		var output := int(definition.get("power_output", 0))
		var draw := int(definition.get("power_draw", 0))
		if output > 0:
			return "+%d" % output
		if draw > 0:
			return "−%d" % draw
		return "0"

	func selected_system_state_text() -> String:
		if state == null or selected_cell.x < 0:
			return "System state unavailable"
		var selected := state.module_at(selected_cell)
		if selected.is_empty():
			return "System state unavailable"
		var definition := state.module_definition(String(selected.get("id", "")))
		var dependency := state.dependency_status(selected)
		var state_name := String(dependency.get("state", "offline"))
		var current_durability := int(selected.get("durability", 0))
		var maximum_durability := int(definition.get("durability", 1))
		if current_durability > 0 and current_durability < maximum_durability:
			if state_name == "ready":
				return "System state: Damaged but ready · %d/%d" % [current_durability, maximum_durability]
			return "System state: %s · damaged %d/%d" % [state_name.capitalize(), current_durability, maximum_durability]
		return "System state: %s" % state_name.capitalize()

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
		elif event.is_action_pressed("ui_cancel"):
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
		draw_string(ThemeDB.fallback_font, Vector2(x, 40), inspection_detail_heading(), HORIZONTAL_ALIGNMENT_LEFT, 300, 16, Color("#e8c58e"))
		if state == null or placement_module_id.is_empty():
			return
		var definition := state.module_definition(placement_module_id)
		var shape := state.module_shape(placement_module_id, placement_rotated)
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		draw_string(ThemeDB.fallback_font, Vector2(x, 70), String(definition.get("name", placement_module_id)), HORIZONTAL_ALIGNMENT_LEFT, 300, 15, Color("#f1e6cf"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 94), "%dx%d footprint · mass %d · power %s · heat %d" % [shape.x, shape.y, int(definition.get("mass", 0)), selected_power_text(), int(definition.get("heat", 0))], HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#aab6ba"))
		draw_string(ThemeDB.fallback_font, Vector2(x, 118), "Exterior mount" if "exterior" in definition.get("tags", []) else "Interior chassis", HORIZONTAL_ALIGNMENT_LEFT, 300, 12, Color("#d8c389"))
		if not selected.is_empty():
			var dependency := state.dependency_status(selected)
			var state_name := String(dependency.get("state", "offline"))
			var definition_maximum_durability := int(definition.get("durability", 1))
			var selected_is_damaged := int(selected.get("durability", 0)) > 0 and int(selected.get("durability", 0)) < definition_maximum_durability
			var state_color := Color("#e3ad55") if selected_is_damaged or state_name == "strained" else (Color("#73c99b") if state_name == "ready" else Color("#e06f61"))
			var reasons: Array = dependency.get("reasons", [])
			draw_string(ThemeDB.fallback_font, Vector2(x, 154), selected_system_state_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 13, state_color)
			draw_string(ThemeDB.fallback_font, Vector2(x, 178), String(reasons[0]) if not reasons.is_empty() else "All required connections are satisfied.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#b9c3bf"))
			draw_multiline_string(ThemeDB.fallback_font, Vector2(x, 200), "ROLE · %s" % selected_capability_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 11, 2, Color("#8fa3a7"))
		else:
			draw_string(ThemeDB.fallback_font, Vector2(x, 154), "Pending module: choose an empty cell", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#b9c3bf"))
			draw_multiline_string(ThemeDB.fallback_font, Vector2(x, 178), "ROLE · %s" % selected_capability_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 11, 2, Color("#8fa3a7"))
		if state.can_refit():
			var hovered := state.module_at(cursor_cell)
			var placement_validation := _placement_validation()
			var status_color := Color("#f0cf96") if not hovered.is_empty() else (Color("#73c99b") if bool(placement_validation.get("ok", false)) else Color("#ef8375"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 228), placement_status_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 11, status_color)
			if has_focus():
				draw_string(ThemeDB.fallback_font, Vector2(x, 246), "Arrows move · %s confirms · %s returns" % [controller_confirm_label, controller_cancel_label], HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		else:
			draw_multiline_string(ThemeDB.fallback_font, Vector2(x, 228), locked_mode_help_text(), HORIZONTAL_ALIGNMENT_LEFT, 320, 11, 2, Color("#b9c3bf"))

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#18242b"), true)
		if has_focus():
			draw_rect(Rect2(Vector2.ZERO, size).grow(-2), Color("#f0cf96"), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(ORIGIN.x, 14), interaction_heading(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f0cf96") if has_focus() else Color("#b9c3bf"))
		for y in range(LongMarchState.GRID_HEIGHT):
			for x in range(LongMarchState.GRID_WIDTH):
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#223139"), true)
				draw_rect(Rect2(ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 3, CELL - 3)), Color("#4a5c61"), false, 1.0)
		if state == null:
			return
		if hull_under_threat:
			draw_rect(_grid_rect().grow(5), Color("#ff806f"), false, 4.0)
			draw_string(ThemeDB.fallback_font, Vector2(size.x - 152, 14), "HULL TARGETED", HORIZONTAL_ALIGNMENT_RIGHT, 128, 12, Color("#ff9d8f"))
		_draw_preview()
		for instance in state.modules:
			var definition := state.module_definition(String(instance.get("id", "")))
			var rect := _module_rect(instance)
			var family := "power" if "generator" in definition.get("tags", []) else String(definition.get("family", ""))
			var color: Color = family_colors.get(family, Color("#8b8b8b"))
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
			FortressSilhouetteRenderer.draw_family_mark(self, rect.grow(-9), family, Color(1.0, 1.0, 1.0, 0.20))
			_draw_module_name(rect, String(definition.get("name", instance.get("id", ""))))
			var maximum := maxi(1, int(definition.get("durability", 1)))
			var durability := maxi(0, int(instance.get("durability", 0)))
			var durability_ratio := clampf(float(durability) / float(maximum), 0.0, 1.0)
			var bar_rect := Rect2(rect.position + Vector2(4, rect.size.y - 7), Vector2(rect.size.x - 8, 4))
			draw_rect(bar_rect, Color("#172026"), true)
			draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * durability_ratio, bar_rect.size.y)), Color("#73c99b") if durability_ratio > 0.5 else (Color("#e8c58e") if durability_ratio > 0.25 else Color("#ef8375")), true)
			if bool(instance.get("sealed", false)):
				draw_rect(rect.grow(-5), Color("#f0d28f"), false, 3.0)
				draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 24, 14), "S", HORIZONTAL_ALIGNMENT_CENTER, 18, 11, Color("#fff0ba"))
			elif state_name == "offline":
				draw_line(rect.position + Vector2(6, 6), rect.end - Vector2(6, 6), Color("#ff8a7e"), 3.0)
				draw_line(Vector2(rect.end.x - 6, rect.position.y + 6), Vector2(rect.position.x + 6, rect.end.y - 6), Color("#ff8a7e"), 3.0)
			elif state_name == "strained":
				draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 24, 15), "!", HORIZONTAL_ALIGNMENT_CENTER, 18, 13, Color("#fff0ba"))
			if durability < maximum:
				draw_polyline(PackedVector2Array([rect.position + Vector2(rect.size.x * 0.72, 4), rect.position + Vector2(rect.size.x * 0.58, rect.size.y * 0.38), rect.position + Vector2(rect.size.x * 0.70, rect.size.y * 0.58), rect.position + Vector2(rect.size.x * 0.54, rect.size.y - 8)]), Color("#ffd28e"), 2.0)
			if String(instance.get("id", "")) in combat_target_ids:
				draw_rect(rect.grow(3), Color("#ff806f"), false, 4.0)
			if selected_cell in state.occupied_cells(instance):
				draw_rect(rect.grow(2), Color("#69d8cf") if has_focus() else Color("#568d8c"), false, 3.0 if has_focus() else 2.0)
		if has_focus() or pointer_inside:
			var cursor_rect := Rect2(ORIGIN + Vector2(cursor_cell.x * CELL, cursor_cell.y * CELL), Vector2(CELL - 3, CELL - 3))
			draw_rect(cursor_rect, Color("#e8c58e") if has_focus() else Color("#7d8f93"), false, 2.0)
		_draw_refit_details()
