extends Control

const LongMarchState = preload("res://src/core/fortress_state.gd")
const PlaytestJournal = preload("res://src/support/playtest_journal.gd")
const CampaignMapView = preload("res://src/ui/campaign_map.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const ENGINE_ICON = preload("res://assets/steam_lance_engine_icon.png")
const CANNON_ICON = preload("res://assets/shell_cannon_icon.png")
const WORKSHOP_ICON = preload("res://assets/field_workshop_icon.png")
const SIGNAL_ICON = preload("res://assets/signal_coil_icon.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const ONBOARDING_STEPS := [
	{
		"title": "Keep the fortress moving",
		"body": "You are the Marchmaster of a walking fortress. Your job is not to build the largest machine; it is to keep a connected, repairable machine moving from Ashgate to Meridian Pass. Every useful module costs space, mass, power, heat, or exposure."
	},
	{
		"title": "Build around dependencies",
		"body": "Select a module on the chassis to inspect it. Engines need orthogonally adjacent fuel. Weapons prefer an adjacent Ammunition Lift. Workshops need adjacent Crew Quarters and work better beside Parts. Ready, strained, and offline states update immediately as you refit."
	},
	{
		"title": "Choose a road and a promise",
		"body": "The authored map shows two or three forward nodes with known, forecast, or unscouted information. The visible blockade clock changes optional routes but never removes the only recovery road. Your doctrine changes who the fortress protects and how it fights."
	},
	{
		"title": "Read the battle",
		"body": "Advance one encounter step at a time. Enemies name their target, modules explain their attacks, and dependency failures appear in the report. You may issue one emergency order per encounter. Select a module first if you intend to seal it."
	},
	{
		"title": "Recover, adapt, finish",
		"body": "Morrowline gives you two paid service actions and free refitting midway through the five-encounter chapter. Save whenever you need to stop. At the end, use Playtest feedback to create a local JSON bundle; nothing is uploaded automatically."
	}
]

var state: LongMarchState
var status_label: Label
var journey_label: Label
var encounter_label: Label
var event_label: Label
var log_label: Label
var route_option: OptionButton
var doctrine_option: OptionButton
var module_option: OptionButton
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
var intervention_title: Label
var settlement_title: Label
var settlement_group: Control
var campaign_title: Label
var campaign_pressure_label: Label
var campaign_path_label: Label
var campaign_map: CampaignMapView
var campaign_node_buttons: Array[Button] = []
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
var how_to_play_button: Button
var feedback_button: Button
var onboarding_overlay: Control
var onboarding_title_label: Label
var onboarding_body_label: Label
var onboarding_progress_label: Label
var onboarding_back_button: Button
var onboarding_next_button: Button
var onboarding_skip_button: Button
var onboarding_step: int = 0
var feedback_overlay: Control
var feedback_clear_text: TextEdit
var feedback_confusing_text: TextEdit
var feedback_score_option: OptionButton
var feedback_status_label: Label
var feedback_save_button: Button
var journal: PlaytestJournal
var result_recorded: bool = false
var fortress_panel: Control
var selected_module_id: String = ""
var selected_module_cell := Vector2i(-1, -1)
var placement_rotated: bool = false

func _ready() -> void:
	journal = PlaytestJournal.new()
	_reset_state()
	_build_ui()
	_refresh_ui()
	_journal_event("run_started", {"version": String(ProjectSettings.get_setting("application/config/version", "unknown"))})
	if not FileAccess.file_exists(ONBOARDING_PATH):
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

	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(left_scroll)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(760, 760)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)

	var title := Label.new()
	title.text = "THE LONG MARCH"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e8c58e"))
	left.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A fortress is only strong if it can keep moving."
	subtitle.add_theme_color_override("font_color", Color("#aab6ba"))
	left.add_child(subtitle)
	var journey_banner := TextureRect.new()
	journey_banner.texture = JOURNEY_BACKGROUND
	journey_banner.custom_minimum_size = Vector2(0, 96)
	journey_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	journey_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	journey_banner.modulate = Color(1.0, 1.0, 1.0, 0.78)
	left.add_child(journey_banner)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#f1e6cf"))
	left.add_child(status_label)
	journey_label = Label.new()
	journey_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journey_label.custom_minimum_size = Vector2(740, 42)
	journey_label.add_theme_color_override("font_color", Color("#d8c389"))
	left.add_child(journey_label)
	encounter_label = Label.new()
	encounter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	encounter_label.custom_minimum_size = Vector2(740, 72)
	encounter_label.add_theme_color_override("font_color", Color("#e89270"))
	left.add_child(encounter_label)

	fortress_panel = FortressPanel.new()
	fortress_panel.custom_minimum_size = Vector2(760, 300)
	fortress_panel.state = state
	fortress_panel.grid_cell_pressed.connect(_on_grid_cell_pressed)
	fortress_panel.rotate_requested.connect(_on_rotate_pressed)
	fortress_panel.remove_requested.connect(_on_remove_pressed)
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

	var right_scroll := ScrollContainer.new()
	right_scroll.custom_minimum_size = Vector2(350, 0)
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(right_scroll)
	var right := PanelContainer.new()
	right.custom_minimum_size = Vector2(350, 760)
	right_scroll.add_child(right)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	right.add_child(controls)

	var control_title := Label.new()
	control_title.text = "MARCHMASTER'S DESK"
	control_title.add_theme_font_size_override("font_size", 20)
	control_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(control_title)
	var asset_row := HBoxContainer.new()
	asset_row.add_theme_constant_override("separation", 5)
	for asset in [ENGINE_ICON, CANNON_ICON, WORKSHOP_ICON, SIGNAL_ICON]:
		var icon := TextureRect.new()
		icon.texture = asset
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		asset_row.add_child(icon)
	controls.add_child(asset_row)
	guidance_label = Label.new()
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance_label.custom_minimum_size = Vector2(320, 54)
	guidance_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	controls.add_child(guidance_label)

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
		var shape: Vector2i = definition.get("shape", Vector2i.ONE)
		var mount_text := " · exterior" if "exterior" in definition.get("tags", []) else ""
		module_option.add_item("%s · %dx%d · mass %d%s" % [definition.name, shape.x, shape.y, int(definition.mass), mount_text])
		module_option.set_item_metadata(module_option.item_count - 1, module_id)
	module_option.item_selected.connect(_on_module_selected)
	selected_module_id = "steam_lance_engine"
	selected_module_cell = Vector2i(0, 0)
	_select_module_option(selected_module_id)
	module_group = _labeled_control("Module", module_option)
	controls.add_child(module_group)

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

	contract_title = Label.new()
	contract_title.text = "ASHGATE CONTRACT"
	contract_title.add_theme_font_size_override("font_size", 17)
	contract_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(contract_title)
	contract_label = Label.new()
	contract_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contract_label.custom_minimum_size = Vector2(320, 54)
	contract_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	controls.add_child(contract_label)
	var contract_actions := HBoxContainer.new()
	contract_actions.add_theme_constant_override("separation", 8)
	contract_accept_button = Button.new()
	contract_accept_button.text = "Guard the convoy"
	contract_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_accept_button.pressed.connect(_on_guard_contract_pressed.bind(true))
	contract_actions.add_child(contract_accept_button)
	contract_decline_button = Button.new()
	contract_decline_button.text = "Travel unbound"
	contract_decline_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_decline_button.pressed.connect(_on_guard_contract_pressed.bind(false))
	contract_actions.add_child(contract_decline_button)
	controls.add_child(contract_actions)

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
	campaign_node_buttons = campaign_map.node_buttons

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

	doctrine_option = OptionButton.new()
	for doctrine_id in ["protect_cargo", "protect_crew", "run_hot"]:
		doctrine_option.add_item(doctrine_id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	doctrine_option.item_selected.connect(_on_departure_option_changed)
	doctrine_group = _labeled_control("Journey doctrine", doctrine_option)
	controls.add_child(doctrine_group)
	route_preview_label = Label.new()
	route_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_preview_label.custom_minimum_size = Vector2(320, 64)
	route_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(route_preview_label)

	travel_button = Button.new()
	travel_button.text = "Depart: Ashgate → Morrowline"
	travel_button.tooltip_text = "Pay the route cost and begin the deterministic City 1 → City 2 encounter."
	travel_button.pressed.connect(_on_travel_pressed)
	controls.add_child(travel_button)

	advance_encounter_button = Button.new()
	advance_encounter_button.text = "Advance journey battle"
	advance_encounter_button.tooltip_text = "Resolve one readable encounter step."
	advance_encounter_button.pressed.connect(_on_advance_encounter_pressed)
	controls.add_child(advance_encounter_button)

	intervention_title = Label.new()
	intervention_title.text = "ENCOUNTER ORDER"
	intervention_title.add_theme_font_size_override("font_size", 17)
	intervention_title.add_theme_color_override("font_color", Color("#e8c58e"))
	controls.add_child(intervention_title)
	for action in [
		{"id": "shift_power", "label": "Shift power to weapons"},
		{"id": "seal_compartment", "label": "Seal selected module"},
		{"id": "vent_heat", "label": "Vent heat"},
		{"id": "cut_loose_cargo", "label": "Cut loose cargo"}
	]:
		var intervention := Button.new()
		intervention.text = String(action.label)
		intervention.pressed.connect(_use_intervention.bind(String(action.id)))
		intervention_buttons.append(intervention)
		controls.add_child(intervention)

	save_button = Button.new()
	save_button.text = "Save prototype state"
	save_button.pressed.connect(_on_save_pressed)
	controls.add_child(save_button)
	load_button = Button.new()
	load_button.text = "Load prototype state"
	load_button.pressed.connect(_on_load_pressed)
	controls.add_child(load_button)

	var reset_button := Button.new()
	reset_button.text = "Reset run"
	reset_button.pressed.connect(_on_reset_pressed)
	controls.add_child(reset_button)

	var playtest_actions := HBoxContainer.new()
	playtest_actions.add_theme_constant_override("separation", 8)
	how_to_play_button = Button.new()
	how_to_play_button.text = "How to play"
	how_to_play_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	how_to_play_button.pressed.connect(_show_onboarding.bind(true))
	playtest_actions.add_child(how_to_play_button)
	feedback_button = Button.new()
	feedback_button.text = "Playtest feedback"
	feedback_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feedback_button.pressed.connect(_show_feedback)
	playtest_actions.add_child(feedback_button)
	controls.add_child(playtest_actions)

	_build_onboarding_overlay()
	_build_feedback_overlay()

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
	panel.custom_minimum_size = Vector2(660, 430)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	margin.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "MARCHMASTER'S FIELD BRIEFING"
	eyebrow.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(eyebrow)
	onboarding_title_label = Label.new()
	onboarding_title_label.add_theme_font_size_override("font_size", 28)
	onboarding_title_label.add_theme_color_override("font_color", Color("#e8c58e"))
	content.add_child(onboarding_title_label)
	onboarding_body_label = Label.new()
	onboarding_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	onboarding_body_label.custom_minimum_size = Vector2(600, 190)
	onboarding_body_label.add_theme_font_size_override("font_size", 17)
	onboarding_body_label.add_theme_color_override("font_color", Color("#c8d1d1"))
	content.add_child(onboarding_body_label)
	onboarding_progress_label = Label.new()
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
	onboarding_back_button.text = "Back"
	onboarding_back_button.pressed.connect(_on_onboarding_back)
	actions.add_child(onboarding_back_button)
	onboarding_next_button = Button.new()
	onboarding_next_button.text = "Next"
	onboarding_next_button.pressed.connect(_on_onboarding_next)
	actions.add_child(onboarding_next_button)
	content.add_child(actions)

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
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_hide_feedback)
	actions.add_child(close_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	feedback_save_button = Button.new()
	feedback_save_button.text = "Save feedback bundle"
	feedback_save_button.pressed.connect(_save_feedback)
	actions.add_child(feedback_save_button)
	content.add_child(actions)

func _show_onboarding(reopened: bool = false) -> void:
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
	onboarding_progress_label.text = "Briefing %d of %d" % [onboarding_step + 1, ONBOARDING_STEPS.size()]
	onboarding_back_button.disabled = onboarding_step == 0
	onboarding_next_button.text = "Begin the march" if onboarding_step == ONBOARDING_STEPS.size() - 1 else "Next"

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
	var marker := FileAccess.open(ONBOARDING_PATH, FileAccess.WRITE)
	if marker != null:
		marker.store_string(String(ProjectSettings.get_setting("application/config/version", "unknown")))
	onboarding_overlay.visible = false
	_journal_event("onboarding_skipped" if skipped else "onboarding_completed", {"step_reached": onboarding_step + 1})
	travel_button.grab_focus()

func _show_feedback() -> void:
	feedback_status_label.text = ""
	feedback_overlay.visible = true
	feedback_clear_text.grab_focus()
	_journal_event("feedback_opened", {"phase": state.phase})

func _hide_feedback() -> void:
	feedback_overlay.visible = false
	feedback_button.grab_focus()

func _save_feedback() -> void:
	_journal_event("feedback_saved", {"phase": state.phase, "replay_score": feedback_score_option.selected + 1})
	var result: Dictionary = journal.export_feedback(
		feedback_clear_text.text,
		feedback_confusing_text.text,
		feedback_score_option.selected + 1,
		_state_journal_summary()
	)
	if bool(result.get("ok", false)):
		feedback_status_label.text = "Saved locally: %s" % String(result.get("path", ""))
	else:
		feedback_status_label.text = "Could not save feedback: %s" % String(result.get("reason", "unknown error"))

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if feedback_overlay.visible:
		_hide_feedback()
		get_viewport().set_input_as_handled()
	elif onboarding_overlay.visible:
		_finish_onboarding(true)
		get_viewport().set_input_as_handled()

func _journal_event(event_id: String, properties: Dictionary = {}) -> void:
	if journal != null:
		journal.record(event_id, properties)

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

func _on_departure_option_changed(_index: int) -> void:
	_refresh_ui()

func _on_guard_contract_pressed(accept: bool) -> void:
	var result := state.choose_guard_contract(accept)
	if bool(result.get("ok", false)):
		_set_event("Accepted the Morrowline Parts Guard contract." if accept else "Declined the guard contract. The fortress will travel without the convoy obligation.")
		_journal_event("guard_contract_answered", {"accepted": accept})
	else:
		_set_event("Contract choice blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_campaign_node_pressed(index: int) -> void:
	if index < 0 or index >= campaign_node_buttons.size():
		return
	var node_id := String(campaign_node_buttons[index].get_meta("node_id", ""))
	_on_campaign_node_selected(node_id)

func _on_campaign_node_selected(node_id: String) -> void:
	if node_id.is_empty():
		return
	var doctrine := _selected_id(doctrine_option)
	var result := state.begin_campaign_route(node_id, doctrine)
	if bool(result.get("ok", false)):
		_set_event("Departed for %s. Forecast: %s." % [String(LongMarchState.CAMPAIGN_NODES[node_id].name), ", ".join(result.get("forecast", {}).get("threats", []))])
		_journal_event("campaign_node_started", {"node": node_id, "doctrine": doctrine, "pressure": state.campaign_pressure})
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
		_set_event("Decision recorded: %s." % choice_id.replace("_", " ").capitalize())
		_journal_event("campaign_event_resolved", {"event": String(result.get("event", "")), "choice": choice_id})
	else:
		_set_event("Decision blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_recruit_iven_pressed() -> void:
	var result := state.recruit_iven_pell()
	if bool(result.get("ok", false)):
		_set_event("Iven Pell joins the fortress as signal officer.")
		_journal_event("specialist_recruited", {"specialist": "iven_pell"})
	else:
		_set_event("Recruitment blocked: %s." % String(result.get("reason", "unknown")))
	_refresh_ui()

func _on_module_selected(index: int) -> void:
	selected_module_id = String(module_option.get_item_metadata(index))
	selected_module_cell = Vector2i(-1, -1)
	placement_rotated = false
	_set_event("Selected %s. Choose an empty chassis cell to place it." % String(state.module_definition(selected_module_id).get("name", selected_module_id)))
	_refresh_ui()

func _select_module_option(module_id: String) -> void:
	for index in range(module_option.item_count):
		if String(module_option.get_item_metadata(index)) == module_id:
			module_option.select(index)
			return

func _module_requires_exterior(module_id: String) -> bool:
	return "exterior" in state.module_definition(module_id).get("tags", [])

func _selected_installed_module() -> Dictionary:
	if selected_module_cell.x < 0 or selected_module_cell.y < 0:
		return {}
	return state.module_at(selected_module_cell)

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
	_refresh_ui()

func _on_settlement_repair_pressed() -> void:
	var selected := _selected_installed_module()
	if selected.is_empty():
		_set_event("Select a damaged module on the chassis before requesting a Morrowline repair.")
		return
	var result := state.settlement_repair(String(selected.get("id", "")))
	_set_event("Settlement repair complete." if bool(result.get("ok", false)) else "Settlement repair blocked: %s." % String(result.get("reason", "unknown")))
	_journal_event("settlement_service", {"service": "module_repair", "module": String(selected.get("id", "")), "ok": bool(result.get("ok", false))})
	_refresh_ui()

func _on_settlement_refuel_pressed() -> void:
	var result := state.settlement_refuel()
	_set_event("Morrowline loaded 2 fuel." if bool(result.get("ok", false)) else "Refuel blocked: %s." % String(result.get("reason", "unknown")))
	_journal_event("settlement_service", {"service": "refuel", "ok": bool(result.get("ok", false))})
	_refresh_ui()

func _on_settlement_hull_pressed() -> void:
	var result := state.settlement_repair_hull()
	_set_event("Morrowline repaired the hull." if bool(result.get("ok", false)) else "Hull repair blocked: %s." % String(result.get("reason", "unknown")))
	_journal_event("settlement_service", {"service": "hull_repair", "ok": bool(result.get("ok", false))})
	_refresh_ui()

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
		_set_event("Intervention used: %s." % intervention_id.replace("_", " ").capitalize())
		_journal_event("intervention_used", {"intervention": intervention_id, "target": target_module, "leg": state.journey_leg})
	_refresh_ui()

func _on_save_pressed() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_set_event("Save failed: %s." % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(state.serialize()))
	_set_event("Prototype state saved with schema version %d." % LongMarchState.SAVE_VERSION)
	_journal_event("run_saved", {"phase": state.phase, "day": state.day})
	_refresh_ui()

func _on_load_pressed() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_set_event("No prototype save exists yet.")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_set_event("Load failed: %s." % error_string(FileAccess.get_open_error()))
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_set_event("Load failed: save data is not valid JSON state.")
		return
	var restored := LongMarchState.new(0)
	var result := restored.load_serialized(parsed)
	if not bool(result.get("ok", false)):
		_set_event("Load failed: %s." % String(result.get("reason", "unknown")))
		return
	state = restored
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

func _on_reset_pressed() -> void:
	_reset_state()
	fortress_panel.state = state
	_set_event("The fortress is back at Ashgate Depot with a clean maintenance slate.")
	_journal_event("run_reset")
	_refresh_ui()

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
		"previews": previews,
		"can_depart": phase_can_depart,
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
		button.text = String(choice.label)
		button.disabled = not bool(choice.get("enabled", false))
		button.set_meta("choice_id", String(choice.id))

	var recruit_status := state.iven_recruitment_status()
	recruit_iven_button.visible = state.campaign_active and state.current_location == "broken_relay" and state.phase == "map" and state.specialist_id.is_empty() and state.campaign_event_pending.is_empty()
	recruit_iven_button.disabled = not bool(recruit_status.get("available", false))
	recruit_iven_button.tooltip_text = String(recruit_status.get("reason", ""))

func _refresh_ui() -> void:
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
			"Selected on chassis; click an empty cell to move it." if not selected_installed.is_empty() else "Click an empty cell to place it.",
			dependency_text
		]
	else:
		refit_label.text = "Refit locked during the journey. The current chassis remains visible for battle inspection."
	module_option.disabled = not state.can_refit()
	rotate_button.disabled = not state.can_refit()
	remove_button.disabled = not state.can_refit() or selected_installed.is_empty()
	var is_refit_phase := state.phase in ["refit", "settlement"]
	var is_battle_phase := state.phase in ["battle", "final_battle"]
	match state.phase:
		"refit":
			guidance_label.text = "NEXT — Inspect dependencies, answer the guard contract, then choose one of the visible map nodes."
		"map":
			guidance_label.text = "NEXT — Resolve any local decision, compare the forward nodes, then commit to the next road."
		"battle", "final_battle":
			guidance_label.text = "NEXT — Advance one step, read each target and causal line, then spend at most one emergency order."
		"settlement":
			guidance_label.text = "NEXT — Spend up to two service actions, refit around the damage, then choose a doctrine for Meridian Pass."
		"results":
			guidance_label.text = "RUN COMPLETE — Inspect the surviving systems, then save a local playtest feedback bundle while the decisions are fresh."
	refit_title.visible = is_refit_phase
	module_group.visible = is_refit_phase
	refit_actions.visible = is_refit_phase
	refit_label.visible = is_refit_phase
	route_group.visible = state.phase == "refit" and not state.campaign_active
	doctrine_group.visible = state.phase in ["refit", "map", "settlement"]
	route_option.disabled = state.phase != "refit"
	doctrine_option.disabled = state.phase in ["battle", "final_battle", "results"]
	travel_button.visible = state.phase == "refit" and not state.campaign_active
	travel_button.disabled = state.phase != "refit"
	advance_encounter_button.visible = is_battle_phase
	advance_encounter_button.disabled = not state.encounter_active
	intervention_title.visible = is_battle_phase
	for index in range(intervention_buttons.size()):
		intervention_buttons[index].visible = is_battle_phase
		intervention_buttons[index].disabled = not state.encounter_active or state.encounter_intervention_used or (index == 1 and selected_installed.is_empty())
	settlement_group.visible = state.phase == "settlement"
	settlement_title.visible = state.phase == "settlement"
	settlement_repair_button.visible = state.phase == "settlement"
	settlement_refuel_button.visible = state.phase == "settlement"
	settlement_hull_button.visible = state.phase == "settlement"
	final_journey_button.visible = state.phase == "settlement" and not state.campaign_active
	settlement_repair_button.disabled = state.phase != "settlement" or selected_installed.is_empty() or state.settlement_actions_remaining <= 0
	settlement_refuel_button.disabled = state.phase != "settlement" or state.settlement_actions_remaining <= 0
	settlement_hull_button.disabled = state.phase != "settlement" or state.settlement_actions_remaining <= 0
	final_journey_button.disabled = state.phase != "settlement"
	load_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	if state.campaign_active and state.phase in ["refit", "map", "settlement"]:
		if not state.campaign_event_pending.is_empty():
			route_preview_label.text = "A local decision blocks departure. Resolve it before choosing the next road."
		elif state.guard_contract_status == "offered":
			route_preview_label.text = "The first map branches are visible after the Ashgate contract is answered."
		else:
			route_preview_label.text = "Choose a forward node. Signal readiness and Iven Pell improve how much of each route is revealed."
	elif state.phase == "refit":
		var departure := state.route_preview(_selected_id(route_option), _selected_id(doctrine_option))
		if bool(departure.get("ok", false)):
			route_preview_label.text = "Departure forecast — %d day(s), %d fuel, %.0f%% risk, pressure %d, predicted heat %d/%d." % [int(departure.days), int(departure.fuel), float(departure.risk) * 100.0, int(departure.pressure), int(departure.predicted_heat), LongMarchState.BASE_HEAT_LIMIT]
	elif state.phase == "settlement":
		route_preview_label.text = "Morrowline recovery — %d service action(s) remain. Refit freely, then choose a doctrine for Meridian Pass." % state.settlement_actions_remaining
	elif state.phase == "results":
		route_preview_label.text = "Run complete — %s." % state.final_result.replace("_", " ").capitalize()
	else:
		route_preview_label.text = "On the road — risk %.0f%%, pressure %d, doctrine %s." % [state.current_route_risk * 100.0, state.encounter_pressure, state.encounter_target_doctrine.replace("_", " ").capitalize()]
	var dependencies: Dictionary = snapshot.dependencies
	status_label.text = "Day %d  |  Fuel %d  |  Ashmarks %d  |  Hull %d  |  Mass %d/%d  |  Power %d/%d  |  Heat %d/%d\nSystems — %d ready · %d strained · %d offline%s" % [snapshot.day, snapshot.fuel, snapshot.money, snapshot.hull_condition, snapshot.mass, snapshot.mass_limit, snapshot.power_draw, snapshot.power_output, snapshot.heat, snapshot.heat_limit, int(dependencies.ready), int(dependencies.strained), int(dependencies.offline), " · Blockade %s %d" % [state.campaign_pressure_band().capitalize(), state.campaign_pressure] if state.campaign_active else ""]
	var route_name := String(LongMarchState.ROUTES.get(state.journey_route, {}).get("name", "Meridian Pass" if state.journey_route == "meridian_pass" else "not chosen"))
	if state.campaign_active:
		var path_names: Array[String] = []
		for node_id in state.campaign_path:
			path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id)))
		journey_label.text = "ROAD OUT — %s\nPhase: %s | Current node: %s | Encounter %d/5" % [" → ".join(path_names), state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), state.campaign_encounters_completed]
	else:
		journey_label.text = "JOURNEY — Ashgate Depot → Morrowline Camp → Meridian Pass\nPhase: %s | Current node: %s | Route: %s" % [state.phase.replace("_", " ").capitalize(), String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)), route_name]
	var encounter_lines: Array[String] = []
	for enemy in state.encounter_enemies:
		var enemy_id: String = String(enemy.get("id", ""))
		var enemy_name: String = String(LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id))
		var enemy_state: String
		if bool(enemy.get("defeated", false)):
			enemy_state = "cleared" if enemy_id == "storm_front" else "defeated"
		elif enemy_id == "storm_front":
			enemy_state = "pressure %d/%d" % [int(enemy.get("hp", 0)), int(enemy.get("max_hp", 0))]
		else:
			enemy_state = "%d/%d hp" % [int(enemy.get("hp", 0)), int(enemy.get("max_hp", 0))]
		var target: String = String(enemy.get("target", "approaching"))
		encounter_lines.append("%s — %s — target %s" % [enemy_name, enemy_state, target])
	if state.phase == "results":
		encounter_label.text = "RUN RESULT — %s\nDay %d · Hull %d/10 · Ashmarks %d · Trust %d · Contract %s · %d systems offline" % [state.final_result.replace("_", " ").capitalize(), state.day, state.hull_condition, state.money, state.settlement_trust, state.guard_contract_status.replace("_", " ").capitalize(), int(dependencies.offline)]
	else:
		encounter_label.text = "ENCOUNTER — %s | step %d/6 | progress %.0f%%\n%s" % ["active" if state.encounter_active else (state.encounter_outcome if not state.encounter_outcome.is_empty() else "not started"), state.encounter_step, state.encounter_progress * 100.0, " | ".join(encounter_lines) if not encounter_lines.is_empty() else "No active contacts. Depart from Ashgate Depot to begin the test battle."]
	var recent: Array[String] = []
	var start := maxi(0, state.log.size() - 4)
	for index in range(start, state.log.size()):
		recent.append(state.log[index])
	log_label.text = "Log: " + (" | ".join(recent) if not recent.is_empty() else "The crew is waiting for a route order.")
	if event_label.text.is_empty():
		event_label.text = "Refit at Ashgate: choose a module, click the chassis to place or select it, then depart when the machine is ready."
	fortress_panel.state = state
	fortress_panel.placement_module_id = selected_module_id
	fortress_panel.placement_rotated = placement_rotated
	fortress_panel.selected_cell = selected_module_cell
	fortress_panel.queue_redraw()

class FortressPanel extends Control:
	signal grid_cell_pressed(cell: Vector2i)
	signal rotate_requested
	signal remove_requested

	var state: LongMarchState
	const CELL := 58.0
	const ORIGIN := Vector2(28, 22)
	var placement_module_id: String = ""
	var placement_rotated: bool = false
	var selected_cell := Vector2i(-1, -1)
	var cursor_cell := Vector2i(0, 0)
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
		tooltip_text = "Click a module to select it, or click an empty cell to place or move. Use arrow keys and Enter after focusing the chassis."

	func _grid_rect() -> Rect2:
		return Rect2(ORIGIN, Vector2(LongMarchState.GRID_WIDTH * CELL, LongMarchState.GRID_HEIGHT * CELL))

	func _cell_from_point(point: Vector2) -> Vector2i:
		if not _grid_rect().has_point(point):
			return Vector2i(-1, -1)
		var relative := point - ORIGIN
		return Vector2i(int(relative.x / CELL), int(relative.y / CELL))

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
		var exterior: bool = "exterior" in state.module_definition(placement_module_id).get("tags", [])
		var selected := state.module_at(selected_cell) if selected_cell.x >= 0 else {}
		var validation: Dictionary
		if selected.is_empty():
			validation = state.validate_module_placement(placement_module_id, cursor_cell, exterior, placement_rotated)
		else:
			validation = state.validate_module_reposition(selected_cell, cursor_cell, placement_rotated)
		var preview := state.module_instance(placement_module_id, cursor_cell, exterior, placement_rotated)
		var color := Color(0.35, 0.85, 0.58, 0.42) if bool(validation.get("ok", false)) else Color(0.92, 0.3, 0.25, 0.42)
		for cell in state.occupied_cells(preview):
			if cell.x >= 0 and cell.x < LongMarchState.GRID_WIDTH and cell.y >= 0 and cell.y < LongMarchState.GRID_HEIGHT:
				draw_rect(Rect2(ORIGIN + Vector2(cell.x * CELL, cell.y * CELL), Vector2(CELL - 3, CELL - 3)), color, true)

	func _draw_refit_details() -> void:
		var x := 410.0
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
			draw_string(ThemeDB.fallback_font, Vector2(x, 154), "Pending module: click empty cell to place", HORIZONTAL_ALIGNMENT_LEFT, 320, 12, Color("#b9c3bf"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 178), "Connections are evaluated after placement.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		if state.can_refit():
			draw_string(ThemeDB.fallback_font, Vector2(x, 236), "Green preview = valid · red = blocked", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#b9c3bf"))
			draw_string(ThemeDB.fallback_font, Vector2(x, 258), "Arrows + confirm · R rotates · Delete removes", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#8fa3a7"))
		else:
			draw_string(ThemeDB.fallback_font, Vector2(x, 236), "Select another module to inspect battle damage.", HORIZONTAL_ALIGNMENT_LEFT, 320, 11, Color("#b9c3bf"))

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#18242b"), true)
		draw_string(ThemeDB.fallback_font, Vector2(ORIGIN.x, 14), "CHASSIS GRID — exterior mounts use a bright edge", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#b9c3bf"))
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
			if selected_cell in state.occupied_cells(instance):
				draw_rect(rect.grow(2), Color("#69d8cf"), false, 3.0)
		var cursor_rect := Rect2(ORIGIN + Vector2(cursor_cell.x * CELL, cursor_cell.y * CELL), Vector2(CELL - 3, CELL - 3))
		draw_rect(cursor_rect, Color("#e8c58e") if has_focus() else Color("#7d8f93"), false, 2.0)
		_draw_refit_details()
