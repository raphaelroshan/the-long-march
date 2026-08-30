class_name LongMarchApp
extends Control

signal application_quit_requested

const GAME_SCENE = preload("res://scenes/Main.tscn")
const TUTORIAL_INTRO_SCENE = preload("res://scenes/tutorial/TutorialIntro.tscn")
const LongMarchState = preload("res://src/core/fortress_state.gd")
const CampaignProgress = preload("res://src/support/campaign_progress.gd")
const InterfaceAudio = preload("res://src/support/interface_audio.gd")
const VisualContrast = preload("res://src/support/visual_contrast.gd")
const ControllerLayout = preload("res://src/support/controller_layout.gd")
const JOURNEY_BACKGROUND = preload("res://assets/ashgate_journey_background.png")
const SAVE_PATH := "user://the_long_march_prototype.save"
const SAVE_BACKUP_PATH := "user://the_long_march_prototype.backup.save"
const TUTORIAL_SAVE_PATH := "user://the_long_march_tutorial.save"
const TUTORIAL_BACKUP_PATH := "user://the_long_march_tutorial.backup.save"
const TUTORIAL_COMPLETE_PATH := "user://the_long_march_tutorial.complete"
const SETTINGS_PATH := "user://the_long_march_settings.cfg"
const ONBOARDING_PATH := "user://the_long_march_onboarding_v1.complete"
const PROGRESS_PATH := "user://the_long_march_progress.json"
const PLAYTEST_JOURNAL_PATH := "user://the_long_march_playtest_journal.json"
const CHECKPOINT_TOAST_WIDTH := 250.0
const CHECKPOINT_TOAST_HEIGHT := 36.0
const CHECKPOINT_TOAST_GAP := 12.0
const CHECKPOINT_LABELS := {
	"contract_answered": "Contract decision",
	"route_started": "Route committed",
	"event_resolved": "Event resolved",
	"specialist_recruited": "Specialist recruited",
	"module_moved": "Chassis updated",
	"module_installed": "Module installed",
	"module_rotated": "Module rotated",
	"module_stored": "Module stored",
	"encounter_advanced": "Battle step",
	"route_secured": "Road secured",
	"recovery_reached": "Recovery reached",
	"run_ended": "Run ended",
	"encounter_resolved": "Encounter resolved",
	"settlement_service": "Recovery action",
	"intervention_used": "Emergency order",
	"new_run_started": "New march",
	"tutorial_lesson_completed": "Lesson complete",
	"manual save": "Manual save",
	"loaded save": "Loaded save"
}
const TUTORIAL_LESSON_LABELS := {
	"place_engine": "Install the engine",
	"place_weapon": "Install the weapon",
	"inspect_machine": "Trace the dependency chains",
	"plan_road": "Plan the training road",
	"travel": "Continue through travel",
	"read_contact": "Read the contact dossier",
	"respond": "Advance and issue an order",
	"damage": "Inspect battle damage",
	"victory": "Secure the road",
	"repair": "Repair the damaged system",
	"complete": "Review certification"
}

var menu_view: Control
var tutorial_intro: Control
var title_veil: ColorRect
var guide_view: Control
var settings_view: Control
var settings_scroll: ScrollContainer
var settings_section_headers: Dictionary = {}
var settings_active_section: String = "DISPLAY & READABILITY"
var data_info_view: Control
var run_record_view: Control
var pause_view: Control
var confirmation_view: Control
var checkpoint_toast: PanelContainer
var checkpoint_toast_label: Label
var game_view: Control
var tutorial_button: Button
var start_button: Button
var quick_start_button: Button
var veyru_start_button: Button
var continue_button: Button
var save_recovery_button: Button
var guide_button: Button
var settings_button: Button
var quit_button: Button
var guide_close_button: Button
var guide_quick_start_button: Button
var guide_veyru_start_button: Button
var settings_context_label: Label
var settings_close_button: Button
var display_mode_button: Button
var text_scale_button: Button
var contrast_button: Button
var controller_layout_button: Button
var motion_button: Button
var interface_audio_button: Button
var autosave_button: Button
var data_info_button: Button
var reset_briefing_button: Button
var reset_charter_button: Button
var clear_save_button: Button
var reset_playtest_button: Button
var settings_status_label: Label
var data_info_context_label: Label
var data_info_summary_label: Label
var data_info_path_label: Label
var data_info_status_label: Label
var data_info_copy_button: Button
var data_info_close_button: Button
var resume_button: Button
var pause_order_button: Button
var pause_record_button: Button
var pause_summary_label: Label
var pause_save_status_label: Label
var pause_save_button: Button
var save_return_button: Button
var pause_briefing_button: Button
var pause_notes_button: Button
var pause_settings_button: Button
var restart_button: Button
var title_button: Button
var pause_eyebrow_label: Label
var pause_title_label: Label
var pause_detail_label: Label
var pause_hint_label: Label
var title_build_label: Label
var pause_build_label: Label
var run_record_context_label: Label
var run_record_body_label: Label
var run_record_status_label: Label
var run_record_scroll: ScrollContainer
var run_record_copy_button: Button
var run_record_close_button: Button
var title_control_contract_label: Label
var title_input_legend_label: Label
var title_right_spacer: Control
var title_preview_eyebrow_label: Label
var title_preview_title_label: Label
var title_preview_scope_label: Label
var title_preview_rule_title_labels: Array[Label] = []
var title_preview_rule_detail_labels: Array[Label] = []
var confirmation_title_label: Label
var confirmation_body_label: Label
var confirmation_confirm_button: Button
var confirmation_cancel_button: Button
var title_return_notice_panel: PanelContainer
var title_return_notice_label: Label
var save_status_label: Label
var title_region_briefing_label: Label
var title_charter_label: Label
var pending_confirmation: String = ""
var paused_stage_focus: Control
var close_request_focus: Control
var close_request_was_paused: bool = false
var close_request_process_mode: ProcessMode = Node.PROCESS_MODE_INHERIT
var fullscreen_enabled: bool = false
var text_scale_percent: int = 100
var high_contrast_enabled: bool = false
var controller_layout_id: String = ControllerLayout.DEFAULT_LAYOUT
var reduced_motion: bool = false
var interface_audio_percent: int = InterfaceAudio.DEFAULT_VOLUME_PERCENT
var autosave_enabled: bool = true
var settings_opened_from_pause: bool = false
var last_checkpoint_reason: String = ""
var checkpoint_toast_tween: Tween
var campaign_progress: CampaignProgress
var campaign_progress_error: String = ""
var interface_audio: LongMarchInterfaceAudio
var title_preview_id: String = "tutorial"
var focused_title_preview_id: String = "tutorial"
var title_return_notice: String = ""
var title_return_notice_kind: String = ""

func _flat_style(background: Color, border: Color, width: int = 1, radius: int = 6, padding: int = 12) -> StyleBoxFlat:
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

func _create_menu_theme(high_contrast: bool = false) -> Theme:
	var menu_theme := Theme.new()
	menu_theme.default_font_size = 16
	for control_type in ["Button", "OptionButton"]:
		menu_theme.set_stylebox("normal", control_type, _flat_style(Color("#080d10f5") if high_contrast else Color("#182329e8"), Color("#a8b8bd") if high_contrast else Color("#59696d"), 2 if high_contrast else 1, 6, 11 if high_contrast else 12))
		menu_theme.set_stylebox("hover", control_type, _flat_style(Color("#10262bf8") if high_contrast else Color("#273b40f2"), Color("#75efff") if high_contrast else Color("#79cfc3"), 3 if high_contrast else 2, 6, 10 if high_contrast else 11))
		menu_theme.set_stylebox("pressed", control_type, _flat_style(Color("#05090cf8") if high_contrast else Color("#111a1ff2"), Color("#ffe6a3") if high_contrast else Color("#f0cf96"), 3 if high_contrast else 2, 6, 10 if high_contrast else 11))
		menu_theme.set_stylebox("focus", control_type, _flat_style(Color("#10262bf8") if high_contrast else Color("#24373cf2"), Color.WHITE if high_contrast else Color("#f3dfad"), 4 if high_contrast else 3, 6, 9 if high_contrast else 10))
		menu_theme.set_stylebox("disabled", control_type, _flat_style(Color("#11171af2") if high_contrast else Color("#12191ddb"), Color("#718087") if high_contrast else Color("#354146"), 2 if high_contrast else 1, 6, 11 if high_contrast else 12))
		menu_theme.set_color("font_color", control_type, Color("#eef3ef"))
		menu_theme.set_color("font_hover_color", control_type, Color("#ffffff"))
		menu_theme.set_color("font_pressed_color", control_type, Color("#fff1ce"))
		menu_theme.set_color("font_focus_color", control_type, Color("#ffffff"))
		menu_theme.set_color("font_disabled_color", control_type, Color("#b8c4c7") if high_contrast else Color("#6c777a"))
	return menu_theme

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	_load_preferences()
	ControllerLayout.apply(controller_layout_id)
	interface_audio = InterfaceAudio.new()
	interface_audio.name = "InterfaceAudio"
	add_child(interface_audio)
	interface_audio.set_volume_percent(interface_audio_percent)
	campaign_progress = CampaignProgress.new(PROGRESS_PATH)
	var progress_result := campaign_progress.load_progress()
	if not bool(progress_result.get("ok", false)):
		campaign_progress_error = String(progress_result.get("reason", "regional record could not be read"))
	_apply_display_mode()
	theme = _create_menu_theme(high_contrast_enabled)
	_build_title_menu()
	_build_tutorial_intro()
	_build_guide_overlay()
	_build_settings_overlay()
	_build_data_info_overlay()
	_build_pause_menu()
	_build_run_record_overlay()
	_build_confirmation_overlay()
	_build_checkpoint_toast()
	interface_audio.register_root(self)
	_apply_text_scale()
	_apply_visual_contrast()
	_refresh_controller_copy()
	_configure_overlay_focus()
	_refresh_title_state()
	_focus_title_primary()

func _build_title_menu() -> void:
	menu_view = Control.new()
	menu_view.name = "TitleMenu"
	menu_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_view)

	var background := TextureRect.new()
	background.texture = JOURNEY_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_view.add_child(background)

	title_veil = ColorRect.new()
	title_veil.color = Color(0.025, 0.035, 0.037, 0.48)
	title_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_view.add_child(title_veil)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 58)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_right", 58)
	margin.add_theme_constant_override("margin_bottom", 36)
	menu_view.add_child(margin)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 42)
	margin.add_child(columns)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(570, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	columns.add_child(left)

	title_build_label = Label.new()
	title_build_label.text = "A MOVING FORTRESS JOURNEY · %s" % _build_version()
	title_build_label.add_theme_font_size_override("font_size", 13)
	title_build_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	left.add_child(title_build_label)

	var title := Label.new()
	title.text = "THE LONG\nMARCH"
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	title.add_theme_constant_override("line_spacing", -10)
	left.add_child(title)

	var promise := Label.new()
	promise.text = "KEEP THE FORTRESS MOVING.\nKEEP ITS PROMISES."
	promise.add_theme_font_size_override("font_size", 18)
	promise.add_theme_color_override("font_color", Color("#d7dfd9"))
	left.add_child(promise)

	title_control_contract_label = Label.new()
	title_control_contract_label.text = "YOU CONTROL · CHASSIS · ROUTE · DOCTRINE · ONE EMERGENCY ORDER\nBATTLES RESOLVE STEP BY STEP."
	title_control_contract_label.add_theme_font_size_override("font_size", 12)
	title_control_contract_label.add_theme_color_override("font_color", Color("#d8a650"))
	left.add_child(title_control_contract_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)

	var action_panel := PanelContainer.new()
	action_panel.custom_minimum_size = Vector2(500, 0)
	action_panel.add_theme_stylebox_override("panel", _flat_style(Color("#0d1519e8"), Color("#8d7655"), 1, 8, 18))
	left.add_child(action_panel)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	action_panel.add_child(actions)

	tutorial_button = Button.new()
	tutorial_button.name = "TutorialButton"
	tutorial_button.text = "LEARN TO COMMAND"
	tutorial_button.custom_minimum_size = Vector2(0, 64)
	tutorial_button.tooltip_text = "Enter The First Watch, a guided command lesson with its own checkpoint."
	tutorial_button.pressed.connect(_show_tutorial_intro)
	_bind_title_preview(tutorial_button, "tutorial")
	_accent_button(tutorial_button)
	actions.add_child(tutorial_button)

	start_button = Button.new()
	start_button.name = "StartGameButton"
	start_button.text = "NEW JOURNEY  ·  ASHGATE LOWLANDS"
	start_button.custom_minimum_size = Vector2(0, 62)
	start_button.tooltip_text = "Begin the full Ashgate journey with its prepared fortress."
	start_button.pressed.connect(_start_new_game)
	_bind_title_preview(start_button, "ashgate_guided")
	_accent_button(start_button)
	actions.add_child(start_button)

	quick_start_button = Button.new()
	quick_start_button.name = "QuickStartButton"
	quick_start_button.text = "START ASHGATE  ·  SKIP BRIEFING"
	quick_start_button.custom_minimum_size = Vector2(0, 50)
	quick_start_button.tooltip_text = "Open a fresh Ashgate stage immediately without changing the saved briefing preference."
	quick_start_button.pressed.connect(_quick_start_game)
	_bind_title_preview(quick_start_button, "ashgate_quick")
	actions.add_child(quick_start_button)

	veyru_start_button = Button.new()
	veyru_start_button.name = "VeyruStartButton"
	veyru_start_button.text = "START FLOODED VEYRU  ·  RISING WATER"
	veyru_start_button.custom_minimum_size = Vector2(0, 50)
	veyru_start_button.tooltip_text = "Begin the separate five-encounter Flooded Veyru chapter at Lantern Quay."
	veyru_start_button.pressed.connect(_start_veyru_game)
	_bind_title_preview(veyru_start_button, "veyru")
	actions.add_child(veyru_start_button)

	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.custom_minimum_size = Vector2(0, 52)
	continue_button.tooltip_text = "Load the last locally saved fortress state."
	continue_button.pressed.connect(_continue_game)
	_bind_title_preview(continue_button, "continue")
	actions.add_child(continue_button)
	save_recovery_button = Button.new()
	save_recovery_button.name = "SaveRecoveryButton"
	save_recovery_button.text = "REMOVE UNUSABLE SAVE"
	save_recovery_button.custom_minimum_size = Vector2(0, 44)
	save_recovery_button.tooltip_text = "Remove the local save that cannot be loaded."
	save_recovery_button.visible = false
	save_recovery_button.pressed.connect(_on_save_recovery_pressed)
	_bind_title_preview(save_recovery_button, "recovery")
	actions.add_child(save_recovery_button)

	var utility_actions := HBoxContainer.new()
	utility_actions.add_theme_constant_override("separation", 8)
	actions.add_child(utility_actions)
	guide_button = Button.new()
	guide_button.name = "GuideButton"
	guide_button.text = "FIELD GUIDE"
	guide_button.custom_minimum_size = Vector2(0, 44)
	guide_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_button.pressed.connect(_show_guide)
	utility_actions.add_child(guide_button)
	settings_button = Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "SETTINGS"
	settings_button.custom_minimum_size = Vector2(0, 44)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.pressed.connect(_show_settings)
	utility_actions.add_child(settings_button)
	quit_button = Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(0, 44)
	quit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quit_button.pressed.connect(_quit_game)
	utility_actions.add_child(quit_button)

	title_return_notice_panel = PanelContainer.new()
	title_return_notice_panel.visible = false
	title_return_notice_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 8))
	actions.add_child(title_return_notice_panel)
	title_return_notice_label = Label.new()
	title_return_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_return_notice_label.add_theme_font_size_override("font_size", 11)
	title_return_notice_panel.add_child(title_return_notice_label)

	save_status_label = Label.new()
	save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_status_label.add_theme_font_size_override("font_size", 12)
	save_status_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	actions.add_child(save_status_label)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(390, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	title_right_spacer = Control.new()
	title_right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(title_right_spacer)

	var stage_panel := PanelContainer.new()
	stage_panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191de8"), Color("#4d6263"), 1, 8, 22))
	right.add_child(stage_panel)
	var stage := VBoxContainer.new()
	stage.add_theme_constant_override("separation", 13)
	stage_panel.add_child(stage)

	title_preview_eyebrow_label = Label.new()
	title_preview_eyebrow_label.text = "ASHGATE LOWLANDS · FIRST JOURNEY · 15–25 MINUTES"
	title_preview_eyebrow_label.add_theme_font_size_override("font_size", 12)
	title_preview_eyebrow_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	stage.add_child(title_preview_eyebrow_label)
	title_preview_title_label = Label.new()
	title_preview_title_label.text = "Learn the machine"
	title_preview_title_label.add_theme_font_size_override("font_size", 30)
	title_preview_title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	stage.add_child(title_preview_title_label)
	title_region_briefing_label = Label.new()
	title_region_briefing_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_region_briefing_label.custom_minimum_size = Vector2(330, 72)
	title_region_briefing_label.add_theme_color_override("font_color", Color("#d0d8d5"))
	stage.add_child(title_region_briefing_label)
	var charter_panel := PanelContainer.new()
	charter_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 8))
	stage.add_child(charter_panel)
	title_charter_label = Label.new()
	title_charter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_charter_label.add_theme_font_size_override("font_size", 12)
	title_charter_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	charter_panel.add_child(title_charter_label)
	title_preview_scope_label = Label.new()
	title_preview_scope_label.text = "PRESSURE · BLOCKADE WATCH   ·   RECOVERY · MORROWLINE   ·   FINALE · SIEGE BEAST"
	title_preview_scope_label.add_theme_font_size_override("font_size", 11)
	title_preview_scope_label.add_theme_color_override("font_color", Color("#d8a650"))
	stage.add_child(title_preview_scope_label)
	stage.add_child(_stage_rule("01", "Choose the obligation", "Guard Morrowline's parts convoy or travel unbound.", true))
	stage.add_child(_stage_rule("02", "Read signal and road pressure", "Compare known, forecast, and unscouted routes before committing.", true))
	stage.add_child(_stage_rule("03", "Recover before the finale", "Refit at Morrowline, then face the Siege Beast at encounter five.", true))

	title_input_legend_label = Label.new()
	title_input_legend_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title_input_legend_label.add_theme_font_size_override("font_size", 12)
	title_input_legend_label.add_theme_color_override("font_color", Color("#aab6ba"))
	right.add_child(title_input_legend_label)
	_configure_title_focus()

func _configure_title_focus() -> void:
	tutorial_button.focus_neighbor_top = tutorial_button.get_path_to(quit_button)
	tutorial_button.focus_neighbor_bottom = tutorial_button.get_path_to(start_button)
	start_button.focus_neighbor_top = start_button.get_path_to(tutorial_button)
	start_button.focus_neighbor_bottom = start_button.get_path_to(quick_start_button)
	quick_start_button.focus_neighbor_top = quick_start_button.get_path_to(start_button)
	quick_start_button.focus_neighbor_bottom = quick_start_button.get_path_to(veyru_start_button)
	veyru_start_button.focus_neighbor_top = veyru_start_button.get_path_to(quick_start_button)
	continue_button.focus_neighbor_top = continue_button.get_path_to(veyru_start_button)
	continue_button.focus_neighbor_bottom = continue_button.get_path_to(settings_button)
	save_recovery_button.focus_neighbor_top = save_recovery_button.get_path_to(quick_start_button)
	save_recovery_button.focus_neighbor_bottom = save_recovery_button.get_path_to(settings_button)
	guide_button.focus_neighbor_right = guide_button.get_path_to(settings_button)
	guide_button.focus_neighbor_bottom = guide_button.get_path_to(start_button)
	settings_button.focus_neighbor_left = settings_button.get_path_to(guide_button)
	settings_button.focus_neighbor_right = settings_button.get_path_to(quit_button)
	settings_button.focus_neighbor_bottom = settings_button.get_path_to(start_button)
	quit_button.focus_neighbor_left = quit_button.get_path_to(settings_button)
	quit_button.focus_neighbor_bottom = quit_button.get_path_to(start_button)

func _refresh_title_focus(has_valid_save: bool, has_invalid_save: bool = false, show_quick_start: bool = true) -> void:
	var title_actions: Array[Button] = []
	if has_valid_save:
		title_actions.append(continue_button)
	title_actions.append(tutorial_button)
	title_actions.append(start_button)
	if show_quick_start:
		title_actions.append(quick_start_button)
	title_actions.append(veyru_start_button)
	if has_invalid_save:
		title_actions.append(save_recovery_button)
	var active_controls: Array = []
	active_controls.append_array(title_actions)
	active_controls.append_array([guide_button, settings_button, quit_button])
	_configure_focus_cycle(active_controls)
	for index in range(title_actions.size()):
		var action := title_actions[index]
		var previous: Control = quit_button if index == 0 else title_actions[index - 1]
		var following: Control = settings_button if index == title_actions.size() - 1 else title_actions[index + 1]
		action.focus_neighbor_top = action.get_path_to(previous)
		action.focus_neighbor_bottom = action.get_path_to(following)
	var first_action: Button = title_actions[0]
	var last_action: Button = title_actions[-1]
	for utility in [guide_button, settings_button, quit_button]:
		utility.focus_neighbor_top = utility.get_path_to(last_action)
		utility.focus_neighbor_bottom = utility.get_path_to(first_action)

func _configure_overlay_focus() -> void:
	guide_close_button.focus_neighbor_left = guide_close_button.get_path_to(guide_veyru_start_button)
	guide_close_button.focus_neighbor_right = guide_close_button.get_path_to(guide_quick_start_button)
	guide_quick_start_button.focus_neighbor_left = guide_quick_start_button.get_path_to(guide_close_button)
	guide_quick_start_button.focus_neighbor_right = guide_quick_start_button.get_path_to(guide_veyru_start_button)
	guide_veyru_start_button.focus_neighbor_left = guide_veyru_start_button.get_path_to(guide_quick_start_button)
	guide_veyru_start_button.focus_neighbor_right = guide_veyru_start_button.get_path_to(guide_close_button)
	for button in [guide_close_button, guide_quick_start_button, guide_veyru_start_button]:
		button.focus_neighbor_top = button.get_path_to(button)
		button.focus_neighbor_bottom = button.get_path_to(button)
	_configure_focus_cycle([guide_close_button, guide_quick_start_button, guide_veyru_start_button])
	_configure_focus_pair(data_info_close_button, data_info_copy_button)
	_configure_focus_pair(run_record_close_button, run_record_copy_button)
	display_mode_button.focus_neighbor_top = display_mode_button.get_path_to(settings_close_button)
	display_mode_button.focus_neighbor_bottom = display_mode_button.get_path_to(text_scale_button)
	text_scale_button.focus_neighbor_top = text_scale_button.get_path_to(display_mode_button)
	text_scale_button.focus_neighbor_bottom = text_scale_button.get_path_to(contrast_button)
	contrast_button.focus_neighbor_top = contrast_button.get_path_to(text_scale_button)
	contrast_button.focus_neighbor_bottom = contrast_button.get_path_to(controller_layout_button)
	controller_layout_button.focus_neighbor_top = controller_layout_button.get_path_to(contrast_button)
	controller_layout_button.focus_neighbor_bottom = controller_layout_button.get_path_to(motion_button)
	motion_button.focus_neighbor_top = motion_button.get_path_to(controller_layout_button)
	motion_button.focus_neighbor_bottom = motion_button.get_path_to(interface_audio_button)
	interface_audio_button.focus_neighbor_top = interface_audio_button.get_path_to(motion_button)
	interface_audio_button.focus_neighbor_bottom = interface_audio_button.get_path_to(autosave_button)
	autosave_button.focus_neighbor_top = autosave_button.get_path_to(interface_audio_button)
	autosave_button.focus_neighbor_bottom = autosave_button.get_path_to(data_info_button)
	data_info_button.focus_neighbor_top = data_info_button.get_path_to(autosave_button)
	resume_button.focus_neighbor_left = resume_button.get_path_to(pause_order_button)
	resume_button.focus_neighbor_right = resume_button.get_path_to(pause_order_button)
	resume_button.focus_neighbor_top = resume_button.get_path_to(restart_button)
	resume_button.focus_neighbor_bottom = resume_button.get_path_to(pause_save_button)
	pause_order_button.focus_neighbor_left = pause_order_button.get_path_to(resume_button)
	pause_order_button.focus_neighbor_right = pause_order_button.get_path_to(resume_button)
	pause_order_button.focus_neighbor_top = pause_order_button.get_path_to(title_button)
	pause_order_button.focus_neighbor_bottom = pause_order_button.get_path_to(save_return_button)
	pause_save_button.focus_neighbor_top = pause_save_button.get_path_to(resume_button)
	pause_save_button.focus_neighbor_right = pause_save_button.get_path_to(save_return_button)
	pause_save_button.focus_neighbor_bottom = pause_save_button.get_path_to(pause_record_button)
	save_return_button.focus_neighbor_top = save_return_button.get_path_to(pause_order_button)
	save_return_button.focus_neighbor_left = save_return_button.get_path_to(pause_save_button)
	save_return_button.focus_neighbor_bottom = save_return_button.get_path_to(pause_settings_button)
	pause_record_button.focus_neighbor_top = pause_record_button.get_path_to(pause_save_button)
	pause_record_button.focus_neighbor_left = pause_record_button.get_path_to(pause_settings_button)
	pause_record_button.focus_neighbor_right = pause_record_button.get_path_to(pause_briefing_button)
	pause_record_button.focus_neighbor_bottom = pause_record_button.get_path_to(pause_notes_button)
	pause_briefing_button.focus_neighbor_top = pause_briefing_button.get_path_to(pause_save_button)
	pause_briefing_button.focus_neighbor_left = pause_briefing_button.get_path_to(pause_record_button)
	pause_briefing_button.focus_neighbor_right = pause_briefing_button.get_path_to(pause_settings_button)
	pause_briefing_button.focus_neighbor_bottom = pause_briefing_button.get_path_to(pause_notes_button)
	pause_settings_button.focus_neighbor_top = pause_settings_button.get_path_to(save_return_button)
	pause_settings_button.focus_neighbor_left = pause_settings_button.get_path_to(pause_briefing_button)
	pause_settings_button.focus_neighbor_right = pause_settings_button.get_path_to(pause_record_button)
	pause_settings_button.focus_neighbor_bottom = pause_settings_button.get_path_to(pause_notes_button)
	pause_notes_button.focus_neighbor_top = pause_notes_button.get_path_to(pause_briefing_button)
	pause_notes_button.focus_neighbor_bottom = pause_notes_button.get_path_to(restart_button)
	restart_button.focus_neighbor_top = restart_button.get_path_to(pause_notes_button)
	restart_button.focus_neighbor_right = restart_button.get_path_to(title_button)
	restart_button.focus_neighbor_bottom = restart_button.get_path_to(resume_button)
	title_button.focus_neighbor_top = title_button.get_path_to(pause_notes_button)
	title_button.focus_neighbor_left = title_button.get_path_to(restart_button)
	title_button.focus_neighbor_bottom = title_button.get_path_to(pause_order_button)
	_configure_focus_cycle([resume_button, pause_order_button, pause_save_button, save_return_button, pause_record_button, pause_briefing_button, pause_settings_button, pause_notes_button, restart_button, title_button])
	_configure_focus_pair(confirmation_cancel_button, confirmation_confirm_button)

func _build_tutorial_intro() -> void:
	tutorial_intro = TUTORIAL_INTRO_SCENE.instantiate()
	tutorial_intro.name = "TutorialIntroduction"
	tutorial_intro.visible = false
	tutorial_intro.connect("begin_requested", Callable(self, "_begin_tutorial"))
	tutorial_intro.connect("back_requested", Callable(self, "_hide_tutorial_intro"))
	tutorial_intro.connect("skip_requested", Callable(self, "_skip_tutorial_to_campaign"))
	add_child(tutorial_intro)

func _configure_focus_pair(first: Control, second: Control) -> void:
	first.focus_neighbor_left = first.get_path_to(second)
	first.focus_neighbor_right = first.get_path_to(second)
	first.focus_neighbor_top = first.get_path_to(first)
	first.focus_neighbor_bottom = first.get_path_to(first)
	first.focus_previous = first.get_path_to(second)
	first.focus_next = first.get_path_to(second)
	second.focus_neighbor_left = second.get_path_to(first)
	second.focus_neighbor_right = second.get_path_to(first)
	second.focus_neighbor_top = second.get_path_to(second)
	second.focus_neighbor_bottom = second.get_path_to(second)
	second.focus_previous = second.get_path_to(first)
	second.focus_next = second.get_path_to(first)

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

func _accent_button(button: Button) -> void:
	var normal_fill := Color("#102b24fa") if high_contrast_enabled else Color("#285348f2")
	var normal_border := Color("#9fffb7") if high_contrast_enabled else Color("#89d9b1")
	button.add_theme_stylebox_override("normal", _flat_style(normal_fill, normal_border, 3 if high_contrast_enabled else 2, 6, 10 if high_contrast_enabled else 12))
	button.add_theme_stylebox_override("hover", _flat_style(Color("#174035fa") if high_contrast_enabled else Color("#35695cf7"), Color("#c9ffdc") if high_contrast_enabled else Color("#adf0ce"), 3 if high_contrast_enabled else 2, 6, 10 if high_contrast_enabled else 12))
	button.add_theme_stylebox_override("pressed", _flat_style(Color("#081a15fa") if high_contrast_enabled else Color("#1c3e35f7"), Color.WHITE, 3 if high_contrast_enabled else 2, 6, 10 if high_contrast_enabled else 12))
	button.add_theme_stylebox_override("focus", _flat_style(normal_fill, Color.WHITE, 4 if high_contrast_enabled else 3, 6, 9 if high_contrast_enabled else 11))

func _clear_button_accent(button: Button) -> void:
	for style_name in ["normal", "hover", "pressed", "focus"]:
		button.remove_theme_stylebox_override(style_name)

func _warning_button(button: Button) -> void:
	var normal_fill := Color("#2b1014fa") if high_contrast_enabled else Color("#2d211fe8")
	var normal_border := Color("#ff9fa8") if high_contrast_enabled else Color("#8f6254")
	button.add_theme_stylebox_override("normal", _flat_style(normal_fill, normal_border, 2 if high_contrast_enabled else 1, 6, 11 if high_contrast_enabled else 12))
	button.add_theme_stylebox_override("hover", _flat_style(Color("#43171efa") if high_contrast_enabled else Color("#3c2925f2"), Color("#ffc0c4") if high_contrast_enabled else Color("#d48a70"), 3 if high_contrast_enabled else 2, 6, 10 if high_contrast_enabled else 11))
	button.add_theme_stylebox_override("pressed", _flat_style(Color("#1b090cfa") if high_contrast_enabled else Color("#211714f2"), Color("#ffe0e1") if high_contrast_enabled else Color("#efb39d"), 3 if high_contrast_enabled else 2, 6, 10 if high_contrast_enabled else 11))
	button.add_theme_stylebox_override("focus", _flat_style(normal_fill, Color.WHITE, 4 if high_contrast_enabled else 3, 6, 9 if high_contrast_enabled else 10))

func _bind_title_preview(button: Button, preview_id: String) -> void:
	button.set_meta("long_march_title_preview", preview_id)
	button.focus_entered.connect(_focus_title_preview.bind(preview_id))
	button.mouse_entered.connect(_show_title_preview.bind(preview_id))
	button.mouse_exited.connect(_restore_focused_title_preview)

func _focus_title_preview(preview_id: String) -> void:
	focused_title_preview_id = preview_id
	_show_title_preview(preview_id)

func _show_title_preview(preview_id: String) -> void:
	title_preview_id = preview_id
	_refresh_title_preview()

func _restore_focused_title_preview() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and focus_owner.has_meta("long_march_title_preview"):
		focused_title_preview_id = String(focus_owner.get_meta("long_march_title_preview"))
	_show_title_preview(focused_title_preview_id)

func _stage_rule(number: String, title: String, detail: String, track_title_preview: bool = false) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var number_label := Label.new()
	number_label.text = number
	number_label.custom_minimum_size = Vector2(32, 0)
	number_label.add_theme_font_size_override("font_size", 18)
	number_label.add_theme_color_override("font_color", Color("#d8a650"))
	row.add_child(number_label)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	row.add_child(copy)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", Color("#edf1eb"))
	copy.add_child(title_label)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 12)
	detail_label.add_theme_color_override("font_color", Color("#98a5a5"))
	copy.add_child(detail_label)
	if track_title_preview:
		title_preview_rule_title_labels.append(title_label)
		title_preview_rule_detail_labels.append(detail_label)
	return row

func _build_guide_overlay() -> void:
	guide_view = Control.new()
	guide_view.name = "TestFlowGuide"
	guide_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.mouse_filter = Control.MOUSE_FILTER_STOP
	guide_view.visible = false
	add_child(guide_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 560)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#688587"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "MARCHMASTER'S FIELD GUIDE"
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "Two roads, one fortress"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Ashgate and Flooded Veyru use the same fortress rules but test different weaknesses. Victory and failure make sense when you can trace what caused the outcome."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(690, 50)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	content.add_child(_flow_step("1", "PREP · READ DEPENDENCIES", "Green systems are ready, amber are strained, and red are offline or blocked. Stored parts are finite; inspect dependencies before moving one."))
	content.add_child(_flow_step("2", "CONTRACT · NAME THE OBLIGATION", "Guard Ashgate's convoy or carry Veyru's medicines. Accepted work changes danger, rewards, recovery, and the exact system the road may target."))
	content.add_child(_flow_step("3", "ROUTE · READ PRESSURE", "Known roads name contacts and counters; forecasts reveal a hazard class; unscouted roads stay broad. Ashgate reaches Closing at 3 and Break at 5; Veyru reaches Flooding at 3 and Breach at 5."))
	content.add_child(_flow_step("4", "ENCOUNTER · READ", "Each advance resolves one combat step. Read arriving contacts, TARGET, WHY, and NEXT first; only one emergency order is available per encounter."))
	content.add_child(_flow_step("5", "RECOVER · COMMIT · DEBRIEF", "Recover at Morrowline or Evacuation Camp, commit to the fifth encounter, then use the named result thresholds and replay goal to plan one deliberate change."))
	var note := Label.new()
	note.text = "CHAPTER STARTS open the prepared fortress directly. Ashgate skips its introductory overlay; both chapters keep the normal simulation, seed, route graph, and checkpoint rules."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(note)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	guide_close_button = Button.new()
	guide_close_button.text = "BACK TO TITLE"
	guide_close_button.custom_minimum_size = Vector2(150, 50)
	guide_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_close_button.pressed.connect(_hide_guide)
	actions.add_child(guide_close_button)
	guide_quick_start_button = Button.new()
	guide_quick_start_button.text = "QUICK START · ASHGATE"
	guide_quick_start_button.custom_minimum_size = Vector2(190, 50)
	guide_quick_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_quick_start_button.pressed.connect(_quick_start_game)
	_accent_button(guide_quick_start_button)
	actions.add_child(guide_quick_start_button)
	guide_veyru_start_button = Button.new()
	guide_veyru_start_button.text = "START · FLOODED VEYRU"
	guide_veyru_start_button.custom_minimum_size = Vector2(210, 50)
	guide_veyru_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_veyru_start_button.pressed.connect(_start_veyru_game)
	actions.add_child(guide_veyru_start_button)

func _flow_step(number: String, title: String, detail: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var badge := Label.new()
	badge.text = number
	badge.custom_minimum_size = Vector2(36, 36)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color("#f0cf96"))
	badge.add_theme_stylebox_override("normal", _flat_style(Color("#25383a"), Color("#668b85"), 1, 18, 4))
	row.add_child(badge)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 1)
	row.add_child(copy)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color("#edf1eb"))
	copy.add_child(title_label)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 12)
	detail_label.add_theme_color_override("font_color", Color("#9faead"))
	copy.add_child(detail_label)
	return row

func _build_settings_overlay() -> void:
	settings_view = Control.new()
	settings_view.name = "SettingsMenu"
	settings_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_view.visible = false
	add_child(settings_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 620)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#688587"), 2, 8, 20))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	panel.add_child(content)
	settings_context_label = Label.new()
	settings_context_label.text = "TITLE MENU · SETTINGS"
	settings_context_label.add_theme_font_size_override("font_size", 12)
	settings_context_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(settings_context_label)
	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Adjust display, accessibility, controls, interface audio, save behavior, and the guided briefing. These preferences stay on this device."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(550, 36)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	settings_scroll = ScrollContainer.new()
	settings_scroll.name = "SettingsScroll"
	settings_scroll.custom_minimum_size = Vector2(550, 0)
	settings_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	settings_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(settings_scroll)
	var settings_actions := VBoxContainer.new()
	settings_actions.custom_minimum_size = Vector2(550, 0)
	settings_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_actions.add_theme_constant_override("separation", 6)
	settings_scroll.add_child(settings_actions)
	_settings_section(settings_actions, "DISPLAY & READABILITY", "Window · text size · contrast")
	display_mode_button = _settings_action(settings_actions, "DISPLAY & READABILITY", "DISPLAY MODE", "Switch between a window and borderless fullscreen.", _toggle_display_mode)
	text_scale_button = _settings_action(settings_actions, "DISPLAY & READABILITY", "TEXT SIZE", "Increase interface text while preserving the complete 1280×720 decision layout.", _toggle_text_scale)
	contrast_button = _settings_action(settings_actions, "DISPLAY & READABILITY", "VISUAL CONTRAST", "Darken backdrops, brighten muted copy, and strengthen interactive outlines without hiding status text.", _toggle_high_contrast)
	_settings_section(settings_actions, "CONTROLS & FEEDBACK", "Controller · motion · interface audio")
	controller_layout_button = _settings_action(settings_actions, "CONTROLS & FEEDBACK", "CONTROLLER BUTTONS", "Swap the A/B confirm and cancel buttons while Enter and Escape stay fixed.", _toggle_controller_layout)
	motion_button = _settings_action(settings_actions, "CONTROLS & FEEDBACK", "TRANSITION MOTION", "Reduced motion removes the title-to-stage fade.", _toggle_reduced_motion)
	interface_audio_button = _settings_action(settings_actions, "CONTROLS & FEEDBACK", "INTERFACE AUDIO", "Cycle restrained focus, confirmation, warning, and checkpoint cue volume.", _cycle_interface_audio)
	interface_audio_button.set_meta("long_march_audio_manual_press", true)
	_settings_section(settings_actions, "RUNS & LOCAL DATA", "Checkpoints · support info · resets")
	autosave_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "AUTOMATIC CHECKPOINTS", "Save after committed decisions, refits, and encounter progress.", _toggle_autosave)
	data_info_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "BUILD & LOCAL DATA", "Review build identity, offline boundaries, local-file presence, and the exact storage folder.", _show_data_info)
	reset_briefing_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "FIRST-RUN BRIEFING", "Show the seven-step Marchmaster briefing on the next guided run.", _reset_briefing)
	reset_charter_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "MARCH CHARTER", "Remove regional results and developments without changing Continue, settings, or briefing progress.", _request_confirmation.bind("clear_progress"))
	clear_save_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "LOCAL SAVE", "Permanently remove the local Continue save after confirmation.", _request_confirmation.bind("clear_save"))
	reset_playtest_button = _settings_action(settings_actions, "RUNS & LOCAL DATA", "CLEAN PLAYTEST START", "Remove local run, Charter, briefing, preferences, and journal data while preserving exported feedback reports.", _request_confirmation.bind("reset_playtest_data"))
	_warning_button(reset_playtest_button)
	settings_status_label = Label.new()
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.custom_minimum_size = Vector2(550, 28)
	settings_status_label.add_theme_font_size_override("font_size", 12)
	settings_status_label.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(settings_status_label)
	settings_close_button = Button.new()
	settings_close_button.text = "BACK TO TITLE"
	settings_close_button.custom_minimum_size = Vector2(0, 46)
	settings_close_button.pressed.connect(_hide_settings)
	_accent_button(settings_close_button)
	content.add_child(settings_close_button)

func _settings_section(parent: VBoxContainer, title: String, detail: String) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 30)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#536a70"), 1, 5, 7))
	parent.add_child(panel)
	var label := Label.new()
	label.text = "%s  ·  %s" % [title, detail]
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#d8c389"))
	panel.add_child(label)
	settings_section_headers[title] = label

func _settings_action(parent: VBoxContainer, section: String, title: String, detail: String, callback: Callable) -> Button:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 3)
	parent.add_child(group)
	var label := Label.new()
	label.text = "%s · %s" % [title, detail]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#98a8aa"))
	group.add_child(label)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 38)
	button.tooltip_text = detail
	button.set_meta("long_march_settings_section", section)
	button.pressed.connect(_on_settings_action_focused.bind(button))
	button.pressed.connect(callback)
	button.focus_entered.connect(_on_settings_action_focused.bind(button))
	group.add_child(button)
	return button

func _on_settings_action_focused(control: Control) -> void:
	settings_active_section = String(control.get_meta("long_march_settings_section", settings_active_section))
	_refresh_settings_context()
	_ensure_settings_control_visible(control)

func _refresh_settings_context() -> void:
	settings_context_label.text = "%s · SETTINGS · %s" % ["PAUSED MARCH" if settings_opened_from_pause else "TITLE MENU", settings_active_section]

func _ensure_settings_control_visible(control: Control) -> void:
	if settings_scroll == null or control == null or not is_instance_valid(control):
		return
	settings_scroll.ensure_control_visible(control)

func _build_data_info_overlay() -> void:
	data_info_view = Control.new()
	data_info_view.name = "BuildAndLocalData"
	data_info_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_info_view.mouse_filter = Control.MOUSE_FILTER_STOP
	data_info_view.visible = false
	add_child(data_info_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_info_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	data_info_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(650, 610)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191dfb"), Color("#688587"), 2, 8, 22))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	panel.add_child(content)
	data_info_context_label = Label.new()
	data_info_context_label.add_theme_font_size_override("font_size", 12)
	data_info_context_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(data_info_context_label)
	var title := Label.new()
	title.text = "Build & Local Data"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "Everything listed here stays on this device unless you deliberately copy and share an exported report."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(590, 36)
	intro.add_theme_font_size_override("font_size", 14)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	var summary_panel := PanelContainer.new()
	summary_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_panel.add_theme_stylebox_override("panel", _flat_style(Color("#0b1216f5"), Color("#455a60"), 1, 6, 14))
	content.add_child(summary_panel)
	data_info_summary_label = Label.new()
	data_info_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	data_info_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	data_info_summary_label.add_theme_font_size_override("font_size", 13)
	data_info_summary_label.add_theme_color_override("font_color", Color("#d7dfdd"))
	summary_panel.add_child(data_info_summary_label)
	data_info_path_label = Label.new()
	data_info_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	data_info_path_label.add_theme_font_size_override("font_size", 12)
	data_info_path_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(data_info_path_label)
	data_info_status_label = Label.new()
	data_info_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	data_info_status_label.custom_minimum_size = Vector2(590, 26)
	data_info_status_label.add_theme_font_size_override("font_size", 11)
	data_info_status_label.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(data_info_status_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	data_info_close_button = Button.new()
	data_info_close_button.text = "BACK TO SETTINGS"
	data_info_close_button.custom_minimum_size = Vector2(0, 46)
	data_info_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	data_info_close_button.pressed.connect(_hide_data_info)
	actions.add_child(data_info_close_button)
	data_info_copy_button = Button.new()
	data_info_copy_button.text = "COPY DATA FOLDER PATH"
	data_info_copy_button.custom_minimum_size = Vector2(0, 46)
	data_info_copy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	data_info_copy_button.pressed.connect(_copy_data_folder_path)
	_accent_button(data_info_copy_button)
	actions.add_child(data_info_copy_button)

func _build_pause_menu() -> void:
	pause_view = Control.new()
	pause_view.name = "PauseMenu"
	pause_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_view.visible = false
	add_child(pause_view)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.024, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 580)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191df7"), Color("#9a805c"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	pause_eyebrow_label = Label.new()
	pause_eyebrow_label.text = "THE ROAD WAITS"
	pause_eyebrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_eyebrow_label.add_theme_font_size_override("font_size", 12)
	pause_eyebrow_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(pause_eyebrow_label)
	pause_title_label = Label.new()
	pause_title_label.text = "MARCH PAUSED"
	pause_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_title_label.add_theme_font_size_override("font_size", 34)
	pause_title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(pause_title_label)
	pause_detail_label = Label.new()
	pause_detail_label.text = "The road is turn-based. Nothing changes while this menu is open."
	pause_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_detail_label.custom_minimum_size = Vector2(430, 38)
	pause_detail_label.add_theme_color_override("font_color", Color("#b7c1bf"))
	content.add_child(pause_detail_label)
	var summary_panel := PanelContainer.new()
	summary_panel.add_theme_stylebox_override("panel", _flat_style(Color("#172329"), Color("#405459"), 1, 5, 12))
	content.add_child(summary_panel)
	var summary := VBoxContainer.new()
	summary.add_theme_constant_override("separation", 4)
	summary_panel.add_child(summary)
	pause_summary_label = Label.new()
	pause_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_summary_label.add_theme_color_override("font_color", Color("#e7d6b2"))
	summary.add_child(pause_summary_label)
	pause_save_status_label = Label.new()
	pause_save_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_save_status_label.add_theme_font_size_override("font_size", 12)
	pause_save_status_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	summary.add_child(pause_save_status_label)
	var resume_actions := HBoxContainer.new()
	resume_actions.add_theme_constant_override("separation", 8)
	content.add_child(resume_actions)
	resume_button = Button.new()
	resume_button.text = "RESUME HERE"
	resume_button.custom_minimum_size = Vector2(0, 54)
	resume_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resume_button.tooltip_text = "Return to the exact stage control that was focused before Pause."
	resume_button.pressed.connect(_resume_game)
	_accent_button(resume_button)
	resume_actions.add_child(resume_button)
	pause_order_button = Button.new()
	pause_order_button.text = "GO TO ORDER"
	pause_order_button.custom_minimum_size = Vector2(0, 54)
	pause_order_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_order_button.tooltip_text = "Return to the required control without activating it."
	pause_order_button.pressed.connect(_resume_at_current_order)
	resume_actions.add_child(pause_order_button)
	var save_actions := HBoxContainer.new()
	save_actions.add_theme_constant_override("separation", 8)
	content.add_child(save_actions)
	pause_save_button = Button.new()
	pause_save_button.text = "SAVE MARCH"
	pause_save_button.custom_minimum_size = Vector2(0, 48)
	pause_save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_save_button.pressed.connect(_save_from_pause)
	save_actions.add_child(pause_save_button)
	save_return_button = Button.new()
	save_return_button.text = "SAVE & RETURN"
	save_return_button.custom_minimum_size = Vector2(0, 48)
	save_return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_return_button.pressed.connect(_save_and_return_to_title)
	save_actions.add_child(save_return_button)
	var reference_actions := HBoxContainer.new()
	reference_actions.add_theme_constant_override("separation", 8)
	content.add_child(reference_actions)
	pause_record_button = Button.new()
	pause_record_button.text = "MARCH RECORD"
	pause_record_button.custom_minimum_size = Vector2(0, 46)
	pause_record_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_record_button.tooltip_text = "Review this run's path, commitments, damage, next order, and reproducible run ID."
	pause_record_button.pressed.connect(_show_run_record)
	reference_actions.add_child(pause_record_button)
	pause_briefing_button = Button.new()
	pause_briefing_button.text = "FIELD BRIEFING"
	pause_briefing_button.custom_minimum_size = Vector2(0, 46)
	pause_briefing_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_briefing_button.pressed.connect(_show_in_run_briefing)
	reference_actions.add_child(pause_briefing_button)
	pause_settings_button = Button.new()
	pause_settings_button.text = "SETTINGS"
	pause_settings_button.custom_minimum_size = Vector2(0, 46)
	pause_settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_settings_button.pressed.connect(_show_settings)
	reference_actions.add_child(pause_settings_button)
	pause_notes_button = Button.new()
	pause_notes_button.text = "RECORD PLAYTEST NOTES"
	pause_notes_button.custom_minimum_size = Vector2(0, 44)
	pause_notes_button.tooltip_text = "Record what felt clear or confusing at this exact decision. Notes stay local until you choose to share the exported file."
	pause_notes_button.pressed.connect(_show_pause_playtest_notes)
	content.add_child(pause_notes_button)
	var session_actions := HBoxContainer.new()
	session_actions.add_theme_constant_override("separation", 8)
	content.add_child(session_actions)
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(0, 46)
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	restart_button.tooltip_text = "Discard the current unsaved stage state and begin again."
	restart_button.pressed.connect(_on_restart_pressed)
	_warning_button(restart_button)
	session_actions.add_child(restart_button)
	title_button = Button.new()
	title_button.text = "EXIT UNSAVED"
	title_button.custom_minimum_size = Vector2(0, 46)
	title_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_button.tooltip_text = "Return to the title without updating the local save."
	title_button.pressed.connect(_request_confirmation.bind("title"))
	_warning_button(title_button)
	session_actions.add_child(title_button)
	pause_hint_label = Label.new()
	pause_hint_label.text = "%s / Esc resumes" % ControllerLayout.cancel_label(controller_layout_id)
	pause_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_hint_label.add_theme_font_size_override("font_size", 12)
	pause_hint_label.add_theme_color_override("font_color", Color("#829092"))
	content.add_child(pause_hint_label)
	pause_build_label = Label.new()
	pause_build_label.text = _playtest_build_label()
	pause_build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_build_label.add_theme_font_size_override("font_size", 10)
	pause_build_label.add_theme_color_override("font_color", Color("#667477"))
	content.add_child(pause_build_label)

func _build_run_record_overlay() -> void:
	run_record_view = Control.new()
	run_record_view.name = "MarchRecord"
	run_record_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	run_record_view.mouse_filter = Control.MOUSE_FILTER_STOP
	run_record_view.visible = false
	add_child(run_record_view)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.018, 0.93)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	run_record_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	run_record_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 620)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#10191dfb"), Color("#688587"), 2, 8, 22))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	run_record_context_label = Label.new()
	run_record_context_label.add_theme_font_size_override("font_size", 12)
	run_record_context_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	content.add_child(run_record_context_label)
	var title := Label.new()
	title.text = "March Record"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(title)
	var intro := Label.new()
	intro.text = "A read-only account of the road so far. Use it to regain context or attach an exact run identity to playtest notes."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(610, 38)
	intro.add_theme_font_size_override("font_size", 14)
	intro.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(intro)
	var record_panel := PanelContainer.new()
	record_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	record_panel.add_theme_stylebox_override("panel", _flat_style(Color("#0b1216f5"), Color("#455a60"), 1, 6, 12))
	content.add_child(record_panel)
	run_record_scroll = ScrollContainer.new()
	run_record_scroll.custom_minimum_size = Vector2(610, 360)
	run_record_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	run_record_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	record_panel.add_child(run_record_scroll)
	run_record_body_label = Label.new()
	run_record_body_label.custom_minimum_size = Vector2(580, 0)
	run_record_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	run_record_body_label.add_theme_font_size_override("font_size", 12)
	run_record_body_label.add_theme_color_override("font_color", Color("#d7dfdd"))
	run_record_scroll.add_child(run_record_body_label)
	run_record_status_label = Label.new()
	run_record_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	run_record_status_label.custom_minimum_size = Vector2(610, 24)
	run_record_status_label.add_theme_font_size_override("font_size", 11)
	run_record_status_label.add_theme_color_override("font_color", Color("#d8c389"))
	content.add_child(run_record_status_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	run_record_close_button = Button.new()
	run_record_close_button.text = "BACK TO PAUSE"
	run_record_close_button.custom_minimum_size = Vector2(0, 46)
	run_record_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_record_close_button.pressed.connect(_hide_run_record)
	actions.add_child(run_record_close_button)
	run_record_copy_button = Button.new()
	run_record_copy_button.text = "COPY MARCH RECORD"
	run_record_copy_button.custom_minimum_size = Vector2(0, 46)
	run_record_copy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_record_copy_button.tooltip_text = "Copy this read-only text summary. Nothing is opened or sent."
	run_record_copy_button.pressed.connect(_copy_run_record)
	_accent_button(run_record_copy_button)
	actions.add_child(run_record_copy_button)

func _build_confirmation_overlay() -> void:
	confirmation_view = Control.new()
	confirmation_view.name = "ConfirmationDialog"
	confirmation_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.mouse_filter = Control.MOUSE_FILTER_STOP
	confirmation_view.visible = false
	add_child(confirmation_view)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.018, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation_view.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 320)
	panel.add_theme_stylebox_override("panel", _flat_style(Color("#111b20fa"), Color("#c78b63"), 2, 8, 28))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "CONFIRM SESSION CHANGE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("#e8a97b"))
	content.add_child(eyebrow)
	confirmation_title_label = Label.new()
	confirmation_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_title_label.add_theme_font_size_override("font_size", 28)
	confirmation_title_label.add_theme_color_override("font_color", Color("#f0d29d"))
	content.add_child(confirmation_title_label)
	confirmation_body_label = Label.new()
	confirmation_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirmation_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_body_label.custom_minimum_size = Vector2(430, 70)
	confirmation_body_label.add_theme_color_override("font_color", Color("#c7d0ce"))
	content.add_child(confirmation_body_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	confirmation_cancel_button = Button.new()
	confirmation_cancel_button.text = "KEEP PLAYING"
	confirmation_cancel_button.custom_minimum_size = Vector2(0, 52)
	confirmation_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirmation_cancel_button.pressed.connect(_cancel_confirmation)
	_accent_button(confirmation_cancel_button)
	actions.add_child(confirmation_cancel_button)
	confirmation_confirm_button = Button.new()
	confirmation_confirm_button.custom_minimum_size = Vector2(0, 52)
	confirmation_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirmation_confirm_button.pressed.connect(_confirm_pending_action)
	actions.add_child(confirmation_confirm_button)

func _build_checkpoint_toast() -> void:
	checkpoint_toast = PanelContainer.new()
	checkpoint_toast.name = "CheckpointToast"
	checkpoint_toast.set_anchors_preset(Control.PRESET_TOP_LEFT)
	checkpoint_toast.position = Vector2(330, 4)
	checkpoint_toast.custom_minimum_size = Vector2(CHECKPOINT_TOAST_WIDTH, CHECKPOINT_TOAST_HEIGHT)
	checkpoint_toast.size = Vector2(CHECKPOINT_TOAST_WIDTH, CHECKPOINT_TOAST_HEIGHT)
	checkpoint_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	checkpoint_toast.visible = false
	checkpoint_toast.add_theme_stylebox_override("panel", _flat_style(Color("#173027f2"), Color("#76c99d"), 2, 6, 10))
	add_child(checkpoint_toast)
	checkpoint_toast_label = Label.new()
	checkpoint_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	checkpoint_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	checkpoint_toast_label.add_theme_font_size_override("font_size", 12)
	checkpoint_toast_label.add_theme_color_override("font_color", Color("#dcf7e8"))
	checkpoint_toast.add_child(checkpoint_toast_label)

func _load_preferences() -> void:
	fullscreen_enabled = false
	text_scale_percent = 100
	high_contrast_enabled = false
	controller_layout_id = ControllerLayout.DEFAULT_LAYOUT
	reduced_motion = false
	interface_audio_percent = InterfaceAudio.DEFAULT_VOLUME_PERCENT
	autosave_enabled = true
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		fullscreen_enabled = bool(config.get_value("display", "fullscreen", false))
		var stored_scale := int(config.get_value("accessibility", "text_scale_percent", 100))
		text_scale_percent = stored_scale if stored_scale in [100, 110] else 100
		high_contrast_enabled = bool(config.get_value("accessibility", "high_contrast", false))
		controller_layout_id = ControllerLayout.normalize(String(config.get_value("input", "controller_layout", ControllerLayout.DEFAULT_LAYOUT)))
		reduced_motion = bool(config.get_value("accessibility", "reduced_motion", false))
		var stored_audio := int(config.get_value("audio", "interface_percent", InterfaceAudio.DEFAULT_VOLUME_PERCENT))
		interface_audio_percent = stored_audio if stored_audio in InterfaceAudio.VOLUME_LEVELS else InterfaceAudio.DEFAULT_VOLUME_PERCENT
		autosave_enabled = bool(config.get_value("gameplay", "autosave_enabled", true))

func _build_version() -> String:
	return "v%s" % String(ProjectSettings.get_setting("application/config/version", "development"))

func _playtest_build_label() -> String:
	return "BUILD · %s" % _build_version()

func _save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "fullscreen", fullscreen_enabled)
	config.set_value("accessibility", "text_scale_percent", text_scale_percent)
	config.set_value("accessibility", "high_contrast", high_contrast_enabled)
	config.set_value("input", "controller_layout", controller_layout_id)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value("audio", "interface_percent", interface_audio_percent)
	config.set_value("gameplay", "autosave_enabled", autosave_enabled)
	config.save(SETTINGS_PATH)

func _show_settings() -> void:
	settings_opened_from_pause = game_view != null and pause_view.visible
	settings_active_section = "DISPLAY & READABILITY"
	if settings_opened_from_pause:
		pause_view.visible = false
	data_info_view.visible = false
	settings_view.visible = true
	_refresh_settings()
	display_mode_button.grab_focus()
	call_deferred("_reset_settings_scroll")

func _reset_settings_scroll() -> void:
	if settings_scroll != null:
		settings_scroll.scroll_vertical = 0

func _hide_settings() -> void:
	settings_view.visible = false
	if settings_opened_from_pause and game_view != null:
		pause_view.visible = true
		pause_settings_button.grab_focus()
	else:
		_refresh_title_state()
		settings_button.grab_focus()
	settings_opened_from_pause = false

func _refresh_settings(message: String = "") -> void:
	_refresh_settings_context()
	settings_close_button.text = "BACK TO PAUSE" if settings_opened_from_pause else "BACK TO TITLE"
	display_mode_button.text = "FULLSCREEN · ON" if fullscreen_enabled else "FULLSCREEN · OFF"
	text_scale_button.text = "TEXT SIZE · %d%%" % text_scale_percent
	contrast_button.text = "VISUAL CONTRAST · HIGH" if high_contrast_enabled else "VISUAL CONTRAST · STANDARD"
	controller_layout_button.text = "CONTROLLER CONFIRM · %s" % ControllerLayout.confirm_label(controller_layout_id)
	motion_button.text = "REDUCED MOTION · ON" if reduced_motion else "REDUCED MOTION · OFF"
	interface_audio_button.text = "INTERFACE AUDIO · MUTED" if interface_audio_percent == 0 else "INTERFACE AUDIO · %d%%" % interface_audio_percent
	autosave_button.text = "AUTOSAVE · ON" if autosave_enabled else "AUTOSAVE · OFF"
	data_info_button.text = "BUILD & LOCAL DATA · %s" % _build_version()
	var briefing_complete := FileAccess.file_exists(ONBOARDING_PATH)
	reset_briefing_button.text = "RESET COMPLETED BRIEFING" if briefing_complete else "BRIEFING · ENABLED FOR NEXT RUN"
	reset_briefing_button.disabled = not briefing_complete
	var progress_exists := FileAccess.file_exists(PROGRESS_PATH)
	reset_charter_button.text = "RESET MARCH CHARTER · " + ("RETURN TO TITLE" if settings_opened_from_pause else ("AVAILABLE" if progress_exists else "NO RECORD"))
	reset_charter_button.disabled = settings_opened_from_pause or not progress_exists
	clear_save_button.text = "CLEAR LOCAL SAVE · " + ("AVAILABLE" if _has_local_save_files() else "NO SAVE")
	clear_save_button.disabled = not _has_local_save_files()
	reset_playtest_button.text = "RESET PLAYTEST DATA · " + ("RETURN TO TITLE" if settings_opened_from_pause else ("AVAILABLE" if _has_resettable_playtest_data() else "ALREADY CLEAN"))
	reset_playtest_button.disabled = settings_opened_from_pause or not _has_resettable_playtest_data()
	_refresh_settings_focus()
	settings_status_label.text = message if not message.is_empty() else "Preferences are local to this device."

func _refresh_settings_focus() -> void:
	var active_controls: Array = [display_mode_button, text_scale_button, contrast_button, controller_layout_button, motion_button, interface_audio_button, autosave_button, data_info_button]
	for optional_button in [reset_briefing_button, reset_charter_button, clear_save_button, reset_playtest_button]:
		if not optional_button.disabled:
			active_controls.append(optional_button)
	active_controls.append(settings_close_button)
	_configure_vertical_focus_cycle(active_controls)

func _toggle_display_mode() -> void:
	fullscreen_enabled = not fullscreen_enabled
	_apply_display_mode()
	_save_preferences()
	_refresh_settings("Display mode changed. Press the same control to switch back.")
	display_mode_button.grab_focus()

func _apply_display_mode() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _toggle_text_scale() -> void:
	text_scale_percent = 110 if text_scale_percent == 100 else 100
	_apply_text_scale()
	_save_preferences()
	_refresh_settings("Text size increased to 110%. Settings scroll to keep focused controls visible." if text_scale_percent == 110 else "Text size returned to 100%.")
	text_scale_button.grab_focus()
	call_deferred("_ensure_settings_control_visible", text_scale_button)

func _apply_text_scale() -> void:
	_apply_text_scale_to_tree(self)
	if title_control_contract_label != null:
		title_control_contract_label.visible = text_scale_percent == 100
	if title_right_spacer != null:
		title_right_spacer.visible = text_scale_percent == 100

func _apply_text_scale_to_tree(node: Node) -> void:
	if node is Control:
		var control := node as Control
		if control.theme != null:
			if not control.has_meta("long_march_base_theme_font_size"):
				control.set_meta("long_march_base_theme_font_size", control.theme.default_font_size)
			var base_theme_font_size := int(control.get_meta("long_march_base_theme_font_size"))
			control.theme.default_font_size = roundi(float(base_theme_font_size) * float(text_scale_percent) / 100.0)
		if control.has_theme_font_size_override("font_size"):
			if not control.has_meta("long_march_base_font_size"):
				control.set_meta("long_march_base_font_size", control.get_theme_font_size("font_size"))
			var base_font_size := int(control.get_meta("long_march_base_font_size"))
			control.add_theme_font_size_override("font_size", roundi(float(base_font_size) * float(text_scale_percent) / 100.0))
		if control.has_theme_font_size_override("normal_font_size"):
			if not control.has_meta("long_march_base_normal_font_size"):
				control.set_meta("long_march_base_normal_font_size", control.get_theme_font_size("normal_font_size"))
			var base_normal_font_size := int(control.get_meta("long_march_base_normal_font_size"))
			control.add_theme_font_size_override("normal_font_size", roundi(float(base_normal_font_size) * float(text_scale_percent) / 100.0))
	for child in node.get_children():
		_apply_text_scale_to_tree(child)

func _toggle_high_contrast() -> void:
	high_contrast_enabled = not high_contrast_enabled
	_apply_visual_contrast()
	_save_preferences()
	_refresh_settings("High visual contrast enabled. Status names and symbols remain visible." if high_contrast_enabled else "Standard visual contrast restored.")
	contrast_button.grab_focus()
	call_deferred("_ensure_settings_control_visible", contrast_button)

func _apply_visual_contrast() -> void:
	theme = _create_menu_theme(high_contrast_enabled)
	if title_veil != null:
		title_veil.color = Color(0.015, 0.02, 0.024, 0.72 if high_contrast_enabled else 0.48)
	VisualContrast.apply_to_tree(self, high_contrast_enabled)
	if game_view != null:
		game_view.call("set_high_contrast", high_contrast_enabled)
	if tutorial_intro != null:
		tutorial_intro.call("set_high_contrast", high_contrast_enabled)
	_apply_text_scale_to_tree(self)
	_refresh_contrast_button_styles()

func _refresh_contrast_button_styles() -> void:
	for button in [guide_quick_start_button, settings_close_button, data_info_copy_button, run_record_copy_button, resume_button, confirmation_cancel_button]:
		if button != null:
			_accent_button(button)
	for button in [reset_playtest_button, restart_button, title_button]:
		if button != null:
			_warning_button(button)

func _show_data_info() -> void:
	settings_view.visible = false
	data_info_view.visible = true
	_refresh_data_info()
	data_info_close_button.grab_focus()

func _hide_data_info() -> void:
	data_info_view.visible = false
	settings_view.visible = true
	_refresh_settings()
	data_info_button.grab_focus()
	call_deferred("_ensure_settings_control_visible", data_info_button)

func _refresh_data_info(message: String = "") -> void:
	var data_folder := ProjectSettings.globalize_path("user://")
	var feedback_count := _feedback_export_count()
	data_info_context_label.text = "PAUSED MARCH · BUILD & LOCAL DATA" if settings_opened_from_pause else "TITLE MENU · BUILD & LOCAL DATA"
	data_info_summary_label.text = "BUILD IDENTITY\n%s · %s desktop build\n\nOFFLINE BOUNDARY\nNo account login, telemetry SDK, or automatic upload is included. Feedback moves only when you explicitly share an exported JSON report.\n\nLOCAL FILES\nCampaign Continue: %s   ·   Campaign backup: %s\nTutorial checkpoint: %s   ·   Tutorial completed: %s\nMarch Charter: %s   ·   Preferences: %s\nBriefing record: %s   ·   Playtest journal: %s\nExported feedback reports: %d tester-owned file%s" % [
		_build_version(),
		OS.get_name(),
		_file_presence(SAVE_PATH),
		_file_presence(SAVE_BACKUP_PATH),
		_file_presence(TUTORIAL_SAVE_PATH),
		_file_presence(TUTORIAL_COMPLETE_PATH),
		_file_presence(PROGRESS_PATH),
		_file_presence(SETTINGS_PATH),
		_file_presence(ONBOARDING_PATH),
		_file_presence(PLAYTEST_JOURNAL_PATH),
		feedback_count,
		"" if feedback_count == 1 else "s"
	]
	data_info_path_label.text = "LOCAL DATA FOLDER\n%s" % data_folder
	data_info_path_label.tooltip_text = data_folder
	data_info_copy_button.tooltip_text = "Copy this exact local folder path. No file browser or external application will open."
	data_info_status_label.text = message if not message.is_empty() else "Copying places only the folder path on the clipboard. Nothing is opened or sent."

func _copy_data_folder_path() -> void:
	var data_folder := ProjectSettings.globalize_path("user://")
	DisplayServer.clipboard_set(data_folder)
	_refresh_data_info("DATA FOLDER PATH COPIED · Paste it into your file browser when you choose. Nothing was opened or sent.")
	data_info_copy_button.grab_focus()

func _file_presence(path: String) -> String:
	return "AVAILABLE" if FileAccess.file_exists(path) else "NOT CREATED"

func _feedback_export_count() -> int:
	var directory := DirAccess.open("user://")
	if directory == null:
		return 0
	var count := 0
	directory.list_dir_begin()
	var filename := directory.get_next()
	while not filename.is_empty():
		if not directory.current_is_dir() and filename.begins_with("the_long_march_feedback_") and filename.ends_with(".json"):
			count += 1
		filename = directory.get_next()
	directory.list_dir_end()
	return count

func _toggle_controller_layout() -> void:
	controller_layout_id = ControllerLayout.EAST_CONFIRM if controller_layout_id == ControllerLayout.SOUTH_CONFIRM else ControllerLayout.SOUTH_CONFIRM
	_apply_controller_layout()
	_save_preferences()
	_refresh_settings("Controller %s now confirms; %s cancels. Enter and Escape are unchanged." % [ControllerLayout.confirm_label(controller_layout_id), ControllerLayout.cancel_label(controller_layout_id)])
	controller_layout_button.grab_focus()
	call_deferred("_ensure_settings_control_visible", controller_layout_button)

func _apply_controller_layout() -> void:
	ControllerLayout.apply(controller_layout_id)
	_refresh_controller_copy()
	if game_view != null:
		game_view.call("set_controller_layout", controller_layout_id)

func _refresh_controller_copy() -> void:
	var confirm_label := ControllerLayout.confirm_label(controller_layout_id)
	if title_input_legend_label != null:
		title_input_legend_label.text = "MOUSE · KEYBOARD · CONTROLLER\nD-pad / arrows move  ·  %s / Enter confirms  ·  %s / Esc closes panels" % [confirm_label, ControllerLayout.cancel_label(controller_layout_id)]
	if pause_hint_label != null:
		pause_hint_label.text = _pause_cancel_hint()

func _pause_cancel_hint() -> String:
	var cancel_label := ControllerLayout.cancel_label(controller_layout_id)
	var viewing_debrief := game_view != null and String(game_view.get("state").get("phase")) == "results"
	return "%s / Esc returns to debrief" % cancel_label if viewing_debrief else "%s / Esc resumes here" % cancel_label

func _toggle_reduced_motion() -> void:
	reduced_motion = not reduced_motion
	if game_view != null:
		game_view.call("set_reduced_motion", reduced_motion)
	_save_preferences()
	_refresh_settings("Reduced motion enabled." if reduced_motion else "Standard transition motion enabled.")
	motion_button.grab_focus()

func _cycle_interface_audio() -> void:
	var current_index := InterfaceAudio.VOLUME_LEVELS.find(interface_audio_percent)
	interface_audio_percent = InterfaceAudio.VOLUME_LEVELS[(current_index + 1) % InterfaceAudio.VOLUME_LEVELS.size()]
	interface_audio.set_volume_percent(interface_audio_percent)
	_save_preferences()
	if interface_audio_percent == 0:
		_refresh_settings("Interface audio muted. Visual focus, warnings, and receipts remain unchanged.")
	else:
		_refresh_settings("Interface audio set to %d%%. This affects menu and command cues only." % interface_audio_percent)
		interface_audio.play_notice()
	interface_audio_button.grab_focus()
	call_deferred("_ensure_settings_control_visible", interface_audio_button)

func _toggle_autosave() -> void:
	autosave_enabled = not autosave_enabled
	_save_preferences()
	_refresh_settings("Automatic checkpoints enabled." if autosave_enabled else "Automatic checkpoints disabled. Use Save March from the pause menu.")
	autosave_button.grab_focus()

func _reset_briefing() -> void:
	var absolute_path := ProjectSettings.globalize_path(ONBOARDING_PATH)
	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)
	_refresh_title_state()
	_refresh_settings("The guided briefing will open on the next Guided First Run.")
	settings_close_button.grab_focus()

func _refresh_title_state() -> void:
	var save_info := _saved_run_info()
	var tutorial_info := _tutorial_saved_run_info()
	var has_valid_save := bool(save_info.get("valid", false))
	var has_invalid_save := bool(save_info.get("exists", false)) and not has_valid_save
	var has_completed_save := has_valid_save and bool(save_info.get("completed", false))
	var briefing_complete := FileAccess.file_exists(ONBOARDING_PATH)
	var tutorial_complete := FileAccess.file_exists(TUTORIAL_COMPLETE_PATH)
	title_charter_label.text = _march_charter_text()
	var tutorial_lesson := String(tutorial_info.get("tutorial_lesson", ""))
	tutorial_button.text = ("REVIEW TRAINING CERTIFICATE" if tutorial_lesson == "complete" else "RESUME TUTORIAL · %s" % String(tutorial_info.get("next_action", "CURRENT LESSON")).to_upper()) if bool(tutorial_info.get("valid", false)) else "LEARN TO COMMAND"
	tutorial_button.tooltip_text = "Resume The First Watch from its separate tutorial checkpoint." if bool(tutorial_info.get("valid", false)) else "Enter The First Watch, a guided command lesson with its own checkpoint."
	if briefing_complete:
		start_button.text = "PLAY AGAIN · ASHGATE LOWLANDS" if has_completed_save else ("NEW JOURNEY · ASHGATE LOWLANDS" if has_valid_save else "START JOURNEY · ASHGATE LOWLANDS")
		start_button.tooltip_text = "Begin directly at Ashgate Depot. Reset the completed briefing in Settings to see it on the next new game."
	else:
		start_button.text = "PLAY AGAIN · ASHGATE LOWLANDS" if has_completed_save else ("NEW JOURNEY · ASHGATE LOWLANDS" if has_valid_save else "START JOURNEY · ASHGATE LOWLANDS")
		start_button.tooltip_text = "Begin at Ashgate Depot with the seven-step Marchmaster briefing."
	quick_start_button.visible = false
	quick_start_button.text = "REPLAY ASHGATE · SKIP BRIEFING" if has_completed_save else ("NEW ASHGATE · SKIP BRIEFING" if has_valid_save else "START ASHGATE  ·  SKIP BRIEFING")
	veyru_start_button.text = "REPLAY FLOODED VEYRU · RISING WATER" if has_completed_save else ("NEW FLOODED VEYRU RUN · RISING WATER" if has_valid_save else ("START FLOODED VEYRU · RISING WATER" if tutorial_complete else "FLOODED VEYRU · ADVANCED JOURNEY"))
	veyru_start_button.tooltip_text = "%s%s" % ["Begin the separate five-encounter Flooded Veyru chapter at Lantern Quay." if tutorial_complete else "Flooded Veyru remains available, but The First Watch is recommended before this advanced journey.", " Public Archive Signal is active: Drowned Registry contacts will be Known." if campaign_progress.has_development("veyru_public_archive_signal") else ""]
	var ashgate_completed := not campaign_progress.result_for_region("ashgate_lowlands").is_empty()
	var veyru_completed := not campaign_progress.result_for_region("flooded_veyru").is_empty()
	guide_quick_start_button.text = "REPLAY · ASHGATE" if ashgate_completed else ("START NEW · ASHGATE" if has_valid_save else "QUICK START · ASHGATE")
	guide_quick_start_button.tooltip_text = "Begin a fresh Ashgate run without opening the introductory briefing."
	guide_veyru_start_button.text = "REPLAY · FLOODED VEYRU" if veyru_completed else ("START NEW · FLOODED VEYRU" if has_valid_save else "START · FLOODED VEYRU")
	guide_veyru_start_button.tooltip_text = "Begin a fresh Flooded Veyru run at Lantern Quay.%s" % (" Public Archive Signal is active: Drowned Registry contacts will be Known." if campaign_progress.has_development("veyru_public_archive_signal") else "")
	continue_button.visible = has_valid_save
	continue_button.disabled = not has_valid_save
	save_recovery_button.visible = has_invalid_save
	if has_invalid_save and bool(save_info.get("backup_valid", false)):
		save_recovery_button.text = String(save_info.get("backup_action", "RESTORE VALID BACKUP"))
		save_recovery_button.tooltip_text = String(save_info.get("backup_tooltip", "Restore the previous valid local checkpoint."))
	else:
		save_recovery_button.text = "REMOVE UNUSABLE SAVE"
		save_recovery_button.tooltip_text = "Remove the local save data that cannot be loaded."
	var actions := start_button.get_parent()
	if has_valid_save:
		actions.move_child(continue_button, 0)
		actions.move_child(tutorial_button, 1)
		actions.move_child(start_button, 2)
		actions.move_child(quick_start_button, 3)
		actions.move_child(veyru_start_button, 4)
	else:
		actions.move_child(tutorial_button, 0)
		actions.move_child(start_button, 1)
		actions.move_child(quick_start_button, 2)
		actions.move_child(veyru_start_button, 3)
		actions.move_child(continue_button, 4)
		actions.move_child(save_recovery_button, 5)
	_refresh_title_focus(has_valid_save, has_invalid_save, quick_start_button.visible)
	continue_button.text = String(save_info.get("action", "CONTINUE SAVED MARCH")) if has_valid_save else ("CONTINUE  ·  SAVE UNAVAILABLE" if bool(save_info.get("exists", false)) else "CONTINUE  ·  NO SAVE FOUND")
	continue_button.tooltip_text = String(save_info.get("tooltip", "Load the last locally saved fortress state."))
	save_status_label.text = String(save_info.get("summary", _empty_save_summary()))
	_refresh_title_return_notice()
	var checkpoint_condition := String(save_info.get("condition", ""))
	if not has_valid_save and bool(save_info.get("exists", false)):
		save_status_label.add_theme_color_override("font_color", Color("#e98b72"))
	elif checkpoint_condition == "critical":
		save_status_label.add_theme_color_override("font_color", Color("#e98b72"))
	elif checkpoint_condition == "watch":
		save_status_label.add_theme_color_override("font_color", Color("#d8b568"))
	elif checkpoint_condition == "stable":
		save_status_label.add_theme_color_override("font_color", Color("#9fd2c2"))
	else:
		save_status_label.add_theme_color_override("font_color", Color("#9aa8aa"))
	if title_preview_id == "continue" and not has_valid_save:
		title_preview_id = "recovery" if has_invalid_save else "ashgate_guided"
	elif title_preview_id == "recovery" and not has_invalid_save:
		title_preview_id = "continue" if has_valid_save else "ashgate_guided"
	elif title_preview_id == "ashgate_quick" and not quick_start_button.visible:
		title_preview_id = "ashgate_guided"
	if focused_title_preview_id == "continue" and not has_valid_save:
		focused_title_preview_id = "recovery" if has_invalid_save else "ashgate_guided"
	elif focused_title_preview_id == "recovery" and not has_invalid_save:
		focused_title_preview_id = "continue" if has_valid_save else "ashgate_guided"
	elif focused_title_preview_id == "ashgate_quick" and not quick_start_button.visible:
		focused_title_preview_id = "ashgate_guided"
	_refresh_title_preview(save_info)
	_clear_button_accent(start_button)
	_clear_button_accent(continue_button)
	_clear_button_accent(tutorial_button)
	_accent_button(continue_button if has_valid_save else tutorial_button)
	if high_contrast_enabled:
		VisualContrast.apply_to_tree(self, true)

func _refresh_title_preview(save_info: Dictionary = {}) -> void:
	if title_preview_title_label == null or title_preview_rule_title_labels.size() != 3:
		return
	var current_save := save_info if not save_info.is_empty() else _saved_run_info()
	var rule_titles: Array[String] = []
	var rule_details: Array[String] = []
	match title_preview_id:
		"tutorial":
			var tutorial_save := _tutorial_saved_run_info()
			var tutorial_resumable := bool(tutorial_save.get("valid", false))
			title_preview_eyebrow_label.text = "THE FIRST WATCH · %s · 20–30 MINUTES" % ("TUTORIAL CHECKPOINT" if tutorial_resumable else "INTERACTIVE TUTORIAL")
			title_preview_title_label.text = "Resume The First Watch" if tutorial_resumable else "Learn by commanding"
			title_region_briefing_label.text = "Current order: %s. Tutorial progress is stored separately from campaign Continue." % String(tutorial_save.get("next_action", "Continue training")) if tutorial_resumable else "Place the systems that make the fortress move and fight, read a live contact, survive damage, and repair the machine before entering the campaign."
			title_preview_scope_label.text = "LESSONS · PLACEMENT   ·   ROAD · CONTACT   ·   RECOVERY · REPAIR"
			rule_titles = ["Build a working machine", "Read before committing", "Recover after contact"]
			rule_details = ["Place an engine beside fuel and a weapon beside its ammunition support.", "Plan one short road, inspect the approaching enemy, then choose when to advance.", "Trace battle damage through the dependency chain and restore the system that keeps the march alive."]
		"continue":
			if not bool(current_save.get("valid", false)):
				title_preview_id = "recovery" if bool(current_save.get("exists", false)) else "ashgate_guided"
				_refresh_title_preview(current_save)
				return
			var completed := bool(current_save.get("completed", false))
			title_preview_eyebrow_label.text = "LOCAL CHECKPOINT · %s · %s" % [String(current_save.get("region", "SAVED MARCH")).to_upper(), String(current_save.get("save_age", "SAVED EARLIER")).to_upper()]
			title_preview_title_label.text = "Review the saved result" if completed else "Resume the march"
			title_region_briefing_label.text = "%s at %s. Continue restores this exact validated decision; it does not begin a replacement run." % [String(current_save.get("region", "Campaign")), String(current_save.get("location", "the saved location"))]
			title_preview_scope_label.text = "%s · %d/5 SECURED   ·   DAY %d   ·   SAVED BY %s" % [String(current_save.get("phase", "Checkpoint")).to_upper(), int(current_save.get("encounters", 0)), int(current_save.get("day", 1)), String(current_save.get("saved_build", "EARLIER BUILD")).to_upper()]
			rule_titles = ["Return to the waiting decision", "Check the fortress condition", "Keep replacement runs deliberate"]
			rule_details = [String(current_save.get("next_action", "Review the current decision")), "Fuel %d · Hull %d/10 · Heat %d/%d · %s" % [int(current_save.get("fuel", 0)), int(current_save.get("hull", 0)), int(current_save.get("heat", 0)), LongMarchState.BASE_HEAT_LIMIT, String(current_save.get("condition", "unknown")).capitalize()], "New Ashgate or Veyru runs ask before they can replace this Continue slot."]
		"recovery":
			var backup_valid := bool(current_save.get("backup_valid", false))
			title_preview_eyebrow_label.text = "LOCAL CHECKPOINT · RECOVERY REQUIRED"
			title_preview_title_label.text = "Restore the previous checkpoint" if backup_valid else "Remove the unusable checkpoint"
			title_region_briefing_label.text = "The primary Continue file cannot be loaded by this build. New Ashgate and Veyru runs remain available."
			title_preview_scope_label.text = "BACKUP · %s   ·   PRIMARY · UNUSABLE   ·   ACTION · CONFIRM FIRST" % ("VALID" if backup_valid else "NOT AVAILABLE")
			rule_titles = ["Protect valid state", "Make replacement explicit", "Keep both chapters playable"]
			rule_details = ["Restore the validated predecessor before attempting Continue." if backup_valid else "No validated predecessor exists; the broken file cannot be resumed.", "Recovery never silently chooses or deletes a local file.", "Starting a new run remains separate from clearing the unusable checkpoint."]
		"veyru":
			title_preview_eyebrow_label.text = "FLOODED VEYRU · SECOND JOURNEY · 15–25 MINUTES"
			title_preview_title_label.text = "Outrun rising water"
			var development_note := " Public Archive Signal is active: Drowned Registry contacts begin Known." if campaign_progress.has_development("veyru_public_archive_signal") else ""
			var tutorial_note := " Complete The First Watch first if you have not yet placed modules or read a live contact." if not FileAccess.file_exists(TUTORIAL_COMPLETE_PATH) else ""
			title_region_briefing_label.text = "A prepared fortress carries sealed medicine toward the Dry Archive while water closes routes and punishes exposed lower-hull systems.%s%s" % [development_note, tutorial_note]
			title_preview_scope_label.text = "PRESSURE · RISING WATER   ·   RECOVERY · EVACUATION CAMP   ·   FINALE · CIVIC GUARDIAN"
			rule_titles = ["Bind medicine to a real module", "Read a changing map", "Choose what the archive says"]
			rule_details = ["Accept the obligation with a named carrier, or decline before the first road.", "Flooding can close one approach, but never every recovery path.", "Broadcast or seal the archive after five encounters; each choice changes the finale."]
		"ashgate_quick":
			title_preview_eyebrow_label.text = "ASHGATE LOWLANDS · QUICK START · 15–25 MINUTES"
			title_preview_title_label.text = "Use the prepared fortress"
			title_region_briefing_label.text = "Begin at Ashgate Depot with the authored chassis ready and the Marchmaster briefing skipped for fast replay or comparison."
			title_preview_scope_label.text = "PRESSURE · BLOCKADE WATCH   ·   RECOVERY · MORROWLINE   ·   FINALE · SIEGE BEAST"
			rule_titles = ["Answer the convoy contract", "Compare three visibility bands", "Recover before the finale"]
			rule_details = ["Guard Morrowline's parts for a harder approach and payout, or travel unbound.", "Known, Forecast, and Unscouted roads reveal different amounts without hiding all counterplay.", "Refit at Morrowline, then face the Siege Beast at encounter five."]
		_:
			title_preview_id = "ashgate_guided"
			var briefing_available := not FileAccess.file_exists(ONBOARDING_PATH)
			title_preview_eyebrow_label.text = "ASHGATE LOWLANDS · GUIDED FIRST JOURNEY · 15–25 MINUTES" if briefing_available else "ASHGATE LOWLANDS · RETURNING JOURNEY · 15–25 MINUTES"
			title_preview_title_label.text = "Learn the machine" if briefing_available else "Return to Ashgate"
			title_region_briefing_label.text = "Begin at Ashgate Depot with seven short Marchmaster cards covering chassis, dependencies, routes, battle, recovery, and debrief." if briefing_available else "Begin directly at Ashgate Depot with the prepared fortress. The completed Marchmaster briefing remains available from the Field Briefing, or can be reset in Settings."
			title_preview_scope_label.text = "PRESSURE · BLOCKADE WATCH   ·   RECOVERY · MORROWLINE   ·   FINALE · SIEGE BEAST"
			rule_titles = ["Build around a promise", "Read signal and road pressure", "Recover before the finale"]
			rule_details = ["Guard Morrowline's parts for a harder approach and payout, or travel unbound.", "Compare known, forecast, and unscouted routes before committing.", "Refit at Morrowline, then face the Siege Beast at encounter five."]
	for index in range(3):
		title_preview_rule_title_labels[index].text = rule_titles[index]
		title_preview_rule_detail_labels[index].text = rule_details[index]

func _march_charter_text() -> String:
	if not campaign_progress_error.is_empty():
		return "MARCH CHARTER · RECORD UNAVAILABLE\nBoth chapters remain playable; the next terminal result can rebuild this local record."
	var ashgate_result := campaign_progress.result_for_region("ashgate_lowlands")
	var veyru_result := campaign_progress.result_for_region("flooded_veyru")
	var survived := campaign_progress.survived_region_count()
	var next_road := "Choose either chapter"
	if survived > 0 and not campaign_progress.survived_region("ashgate_lowlands"):
		next_road = "Ashgate Lowlands"
	elif survived > 0 and not campaign_progress.survived_region("flooded_veyru"):
		next_road = "Flooded Veyru"
	elif survived == 2:
		next_road = "Both roads remain open for replay"
	return "MARCH CHARTER · %d/2 REGIONS SURVIVED\nAshgate %s · Veyru %s · Next: %s" % [survived, _charter_result_label(ashgate_result), _charter_result_label(veyru_result), next_road]

func _charter_result_label(result_id: String) -> String:
	if result_id.is_empty():
		return "—"
	return result_id.replace("_", " ").capitalize()

func _focus_title_primary() -> void:
	if not continue_button.disabled:
		continue_button.grab_focus()
	else:
		tutorial_button.grab_focus()

func _tutorial_saved_run_info() -> Dictionary:
	var info := _saved_run_info_at(TUTORIAL_SAVE_PATH)
	if not bool(info.get("valid", false)):
		return info
	var file := FileAccess.open(TUTORIAL_SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"exists": true, "valid": false}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not bool(parsed.get("tutorial_mode", false)):
		return {"exists": true, "valid": false}
	var progress: Dictionary = parsed.get("tutorial_progress", {})
	var lesson_id := String(progress.get("lesson_id", "place_engine"))
	info["tutorial_lesson"] = lesson_id
	info["next_action"] = String(TUTORIAL_LESSON_LABELS.get(lesson_id, "Continue training"))
	return info

func _saved_run_info() -> Dictionary:
	var primary := _saved_run_info_at(SAVE_PATH)
	var backup := _saved_run_info_at(SAVE_BACKUP_PATH)
	primary["backup_exists"] = bool(backup.get("exists", false))
	primary["backup_valid"] = bool(backup.get("valid", false))
	if bool(backup.get("valid", false)):
		primary["backup_region"] = String(backup.get("region", "Campaign"))
		primary["backup_location"] = String(backup.get("location", "previous decision"))
		primary["backup_day"] = int(backup.get("day", 1))
		primary["backup_action"] = "RESTORE BACKUP · %s · DAY %d" % [_region_menu_name(String(backup.get("region_id", "ashgate_lowlands"))), int(backup.get("day", 1))]
		primary["backup_tooltip"] = "Restore the valid %s checkpoint at %s from %s." % [String(backup.get("region", "campaign")), String(backup.get("location", "the previous decision")), String(backup.get("saved_build", "an earlier build"))]
		if not bool(primary.get("valid", false)):
			primary["exists"] = true
			primary["summary"] = "%s\nRecovery · Valid backup available · %s · Day %d · %s" % [String(primary.get("summary", "Primary save unavailable.")), String(backup.get("region", "Campaign")), int(backup.get("day", 1)), String(backup.get("location", "previous decision"))]
	return primary

func _saved_run_info_at(save_path: String) -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {"exists": false, "valid": false, "summary": _empty_save_summary()}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {"exists": true, "valid": false, "summary": "Save unavailable · The local file could not be opened. Start a new run to replace it."}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"exists": true, "valid": false, "summary": "Save unavailable · Invalid data. Start a new run to replace it."}
	var parsed = parser.data
	if not parsed is Dictionary:
		return {"exists": true, "valid": false, "summary": "Save unavailable · Invalid data. Start a new run to replace it."}
	var schema_version := int(parsed.get("save_version", -1))
	if schema_version < LongMarchState.MIN_SUPPORTED_SAVE_VERSION or schema_version > LongMarchState.SAVE_VERSION:
		return {"exists": true, "valid": false, "summary": "Save unavailable · This checkpoint uses an incompatible save format. Remove it or start a new run."}
	if not parsed.has("phase") or not parsed.has("current_location") or not parsed.has("modules"):
		return {"exists": true, "valid": false, "summary": "Save unavailable · Required campaign state is missing."}
	var validation_state := LongMarchState.new(0)
	var validation := validation_state.load_serialized(parsed)
	if not bool(validation.get("ok", false)):
		return {"exists": true, "valid": false, "summary": "Save unavailable · %s." % String(validation.get("reason", "Campaign state could not be restored"))}
	var location := String(parsed.get("current_location", "unknown road")).replace("_", " ").capitalize()
	var phase_id := String(parsed.get("phase", "unknown"))
	var phase := phase_id.replace("_", " ").capitalize()
	var result_id := String(parsed.get("final_result", ""))
	var result_name := result_id.replace("_", " ").capitalize()
	var day := int(parsed.get("day", 1))
	var encounters := int(parsed.get("campaign_encounters_completed", 0))
	var fuel := int(parsed.get("fuel", 0))
	var hull := int(parsed.get("hull_condition", 0))
	var heat := int(parsed.get("heat", 0))
	var saved_build := String(parsed.get("build_version", "earlier build"))
	var saved_at_unix := int(parsed.get("saved_at_unix", FileAccess.get_modified_time(save_path)))
	var save_age := _save_age_label(saved_at_unix)
	var current_build := String(ProjectSettings.get_setting("application/config/version", "development"))
	var build_note := "" if saved_build == current_build else "\nCompatible checkpoint from %s" % saved_build
	var region_id := validation_state.campaign_region_id
	var region_name := validation_state.campaign_region_name()
	var region_menu_name := _region_menu_name(region_id)
	var condition := "critical" if hull <= 3 or fuel <= 1 or heat > LongMarchState.BASE_HEAT_LIMIT else ("watch" if hull <= 6 or fuel <= 2 or heat >= LongMarchState.BASE_HEAT_LIMIT - 1 else "stable")
	var completed := phase_id == "results" and not result_id.is_empty()
	var next_action := _saved_next_action(validation_state)
	if completed:
		condition = "stable" if result_id in ["decisive_march", "archive_kept"] else ("watch" if result_id in ["scarred_march", "archive_scarred"] else "critical")
	return {
		"exists": true,
		"valid": true,
		"day": day,
		"location": location,
		"phase": phase,
		"encounters": encounters,
		"condition": condition,
		"completed": completed,
		"result": result_name,
		"region_id": region_id,
		"region": region_name,
		"saved_build": saved_build,
		"save_age": save_age,
		"next_action": next_action,
		"fuel": fuel,
		"hull": hull,
		"heat": heat,
		"action": "VIEW RESULT · %s · %s" % [result_name.to_upper(), region_menu_name] if completed else "CONTINUE · %s · DAY %d · %s" % [region_menu_name, day, location.to_upper()],
		"tooltip": "Review the saved %s debrief from %s in %s. Saved by %s." % [result_name, location, region_name, saved_build] if completed else "Resume %s at %s during %s with %d of 5 encounters secured. Saved by %s." % [region_name, location, phase, encounters, saved_build],
		"summary": "Completed run · %s · %d/5 · %s · %s\nNext · %s · Fuel %d · Hull %d/10 · Heat %d/%d%s" % [result_name, encounters, region_name, save_age, next_action, fuel, hull, heat, LongMarchState.BASE_HEAT_LIMIT, build_note] if completed else "Checkpoint · %s · %s · %s · %d/5 · %s\nNext · %s · Fuel %d · Hull %d/10 · Heat %d/%d%s" % [region_name, condition.capitalize(), phase, encounters, save_age, next_action, fuel, hull, heat, LongMarchState.BASE_HEAT_LIMIT, build_note]
	}

func _saved_next_action(saved_state: LongMarchState) -> String:
	if saved_state.phase == "results":
		return "Review debrief"
	if saved_state.encounter_active:
		return "Resolve battle step %d/6" % mini(saved_state.encounter_step + 1, 6)
	if not saved_state.campaign_event_pending.is_empty():
		var event := saved_state.campaign_event_details()
		return "Resolve %s" % String(event.get("title", "local decision"))
	if saved_state.campaign_region_id == "flooded_veyru" and saved_state.veyru_contract_status == "offered":
		return "Answer medicine contract"
	if saved_state.guard_contract_status == "offered":
		return "Answer convoy contract"
	if saved_state.phase == "settlement" and saved_state.settlement_actions_remaining > 0:
		return "Recover or choose the next road"
	if saved_state.campaign_encounters_completed == 0:
		return "Choose the first road"
	return "Choose the next road"

func _save_age_label(saved_at_unix: int) -> String:
	if saved_at_unix <= 0:
		return "Saved earlier"
	var age_seconds := maxi(0, int(Time.get_unix_time_from_system()) - saved_at_unix)
	if age_seconds < 60:
		return "Saved just now"
	if age_seconds < 3600:
		return "Saved %d min ago" % maxi(1, int(age_seconds / 60))
	if age_seconds < 86400:
		return "Saved %d hr ago" % maxi(1, int(age_seconds / 3600))
	if age_seconds < 2592000:
		return "Saved %d d ago" % maxi(1, int(age_seconds / 86400))
	return "Saved earlier"

func _empty_save_summary() -> String:
	return "No saved march · Autosave begins after your first committed decision." if autosave_enabled else "No saved march · Use Save March from the pause menu."

func _region_menu_name(region_id: String) -> String:
	return "VEYRU" if region_id == "flooded_veyru" else "ASHGATE"

func _region_display_name(region_id: String) -> String:
	return "Flooded Veyru" if region_id == "flooded_veyru" else "Ashgate Lowlands"

func _region_start_name(region_id: String) -> String:
	return "Lantern Quay" if region_id == "flooded_veyru" else "Ashgate Depot"

func _active_region_id() -> String:
	if game_view == null:
		return "ashgate_lowlands"
	return String(game_view.get("state").get("campaign_region_id"))

func _start_new_game() -> void:
	_request_new_game(false)

func _show_tutorial_intro() -> void:
	if bool(_tutorial_saved_run_info().get("valid", false)):
		_open_stage(true, false, "ashgate_lowlands", true)
		return
	menu_view.visible = false
	tutorial_intro.call("open")

func _hide_tutorial_intro() -> void:
	tutorial_intro.visible = false
	menu_view.visible = true
	tutorial_button.grab_focus()

func _begin_tutorial() -> void:
	tutorial_intro.visible = false
	_open_stage(false, false, "ashgate_lowlands", true)

func _skip_tutorial_to_campaign() -> void:
	tutorial_intro.visible = false
	_open_stage(false, false, "ashgate_lowlands")

func _quick_start_game() -> void:
	_request_new_game(false, "ashgate_lowlands")

func _start_veyru_game() -> void:
	_request_new_game(false, "flooded_veyru")

func _request_new_game(show_briefing: bool, region_id: String = "ashgate_lowlands") -> void:
	if bool(_saved_run_info().get("valid", false)):
		_request_confirmation("new_veyru" if region_id == "flooded_veyru" else ("new_guided" if show_briefing else "new_quick"))
		return
	_open_stage(false, show_briefing, region_id)

func _continue_game() -> void:
	if not bool(_saved_run_info().get("valid", false)):
		_refresh_title_state()
		(save_recovery_button if save_recovery_button.visible else start_button).grab_focus()
		return
	_open_stage(true, false)

func _on_save_recovery_pressed() -> void:
	var save_info := _saved_run_info()
	_request_confirmation("restore_backup" if bool(save_info.get("backup_valid", false)) else "clear_invalid_save")

func _has_local_save_files() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(SAVE_BACKUP_PATH)

func _has_resettable_playtest_data() -> bool:
	for path in [SAVE_PATH, SAVE_BACKUP_PATH, TUTORIAL_SAVE_PATH, TUTORIAL_BACKUP_PATH, TUTORIAL_COMPLETE_PATH, SETTINGS_PATH, ONBOARDING_PATH, PROGRESS_PATH, PLAYTEST_JOURNAL_PATH]:
		if FileAccess.file_exists(path):
			return true
	return false

func _restore_save_backup() -> Dictionary:
	var backup_info := _saved_run_info_at(SAVE_BACKUP_PATH)
	if not bool(backup_info.get("valid", false)):
		return {"ok": false, "reason": "no valid backup is available"}
	var backup_text := FileAccess.get_file_as_string(SAVE_BACKUP_PATH)
	var primary_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if primary_file == null:
		return {"ok": false, "reason": error_string(FileAccess.get_open_error())}
	primary_file.store_string(backup_text)
	primary_file.close()
	if not bool(_saved_run_info_at(SAVE_PATH).get("valid", false)):
		return {"ok": false, "reason": "restored checkpoint failed validation"}
	_clear_title_return_notice()
	return {"ok": true}

func _clear_local_save_files() -> Dictionary:
	var result := _remove_local_files([SAVE_PATH, SAVE_BACKUP_PATH])
	if bool(result.get("ok", false)):
		_clear_title_return_notice()
	return result

func _reset_playtest_data() -> Dictionary:
	var removal := _remove_local_files([SAVE_PATH, SAVE_BACKUP_PATH, TUTORIAL_SAVE_PATH, TUTORIAL_BACKUP_PATH, TUTORIAL_COMPLETE_PATH, SETTINGS_PATH, ONBOARDING_PATH, PROGRESS_PATH, PLAYTEST_JOURNAL_PATH])
	_load_preferences()
	_apply_display_mode()
	_apply_text_scale()
	_apply_visual_contrast()
	_apply_controller_layout()
	interface_audio.set_volume_percent(interface_audio_percent)
	campaign_progress = CampaignProgress.new(PROGRESS_PATH)
	var progress_result := campaign_progress.load_progress()
	campaign_progress_error = "" if bool(progress_result.get("ok", false)) else String(progress_result.get("reason", "regional record could not be read"))
	last_checkpoint_reason = ""
	_clear_title_return_notice()
	return removal

func _remove_local_files(paths: Array) -> Dictionary:
	var errors: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			var removal_error := DirAccess.remove_absolute(absolute_path)
			if removal_error != OK:
				errors.append("%s: %s" % [path.get_file(), error_string(removal_error)])
	return {"ok": errors.is_empty(), "reason": "; ".join(errors)}

func _open_stage(load_saved: bool, show_briefing: bool, region_id: String = "ashgate_lowlands", as_tutorial: bool = false) -> void:
	_clear_title_return_notice()
	if game_view != null:
		game_view.queue_free()
	game_view = GAME_SCENE.instantiate()
	game_view.set("tutorial_mode", as_tutorial)
	game_view.set("show_onboarding_on_ready", show_briefing)
	game_view.set("starting_region_id", region_id)
	game_view.set("starting_regional_developments", campaign_progress.developments.duplicate())
	game_view.set("starting_region_results", campaign_progress.region_results.duplicate(true))
	game_view.set("high_contrast_enabled", high_contrast_enabled)
	game_view.set("reduced_motion_enabled", reduced_motion)
	game_view.set("controller_layout_id", controller_layout_id)
	game_view.connect("return_to_title_requested", Callable(self, "_return_to_title"))
	game_view.connect("checkpoint_reached", Callable(self, "_on_checkpoint_reached"))
	game_view.connect("play_again_requested", Callable(self, "_request_replay_confirmation"))
	game_view.connect("march_on_requested", Callable(self, "_request_march_on_confirmation"))
	game_view.connect("pause_requested", Callable(self, "_show_pause"))
	game_view.connect("playtest_notes_closed", Callable(self, "_return_from_playtest_notes"))
	add_child(game_view)
	_apply_text_scale_to_tree(game_view)
	move_child(game_view, 0)
	menu_view.visible = false
	tutorial_intro.visible = false
	guide_view.visible = false
	settings_view.visible = false
	data_info_view.visible = false
	run_record_view.visible = false
	pause_view.visible = false
	confirmation_view.visible = false
	pending_confirmation = ""
	settings_opened_from_pause = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	game_view.modulate = Color.WHITE if reduced_motion else Color(1.0, 1.0, 1.0, 0.0)
	var loaded_ok := bool(game_view.call("load_tutorial_run" if as_tutorial else "load_saved_run")) if load_saved else true
	if load_saved and not loaded_ok:
		var failed_game := game_view
		game_view = null
		failed_game.queue_free()
		menu_view.visible = true
		_refresh_title_state()
		(tutorial_button if as_tutorial else (save_recovery_button if save_recovery_button.visible else start_button)).grab_focus()
		return
	if load_saved:
		_record_campaign_progress()
	last_checkpoint_reason = "loaded save" if load_saved else ""
	game_view.call_deferred("focus_current_action")
	if not reduced_motion:
		var tween := create_tween()
		tween.tween_property(game_view, "modulate", Color.WHITE, 0.22)

func _show_pause() -> void:
	if game_view == null or pause_view.visible:
		return
	_dismiss_checkpoint_toast()
	var focus_owner := get_viewport().gui_get_focus_owner()
	paused_stage_focus = focus_owner if focus_owner != null and game_view.is_ancestor_of(focus_owner) else null
	_refresh_pause_summary()
	pause_view.visible = true
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	resume_button.grab_focus()

func _show_run_record() -> void:
	if game_view == null or not pause_view.visible:
		return
	pause_view.visible = false
	run_record_view.visible = true
	_refresh_run_record()
	run_record_close_button.grab_focus()
	call_deferred("_reset_run_record_scroll")

func _reset_run_record_scroll() -> void:
	if run_record_scroll != null:
		run_record_scroll.scroll_vertical = 0

func _hide_run_record() -> void:
	run_record_view.visible = false
	pause_view.visible = true
	_refresh_pause_summary()
	pause_record_button.grab_focus()

func _refresh_run_record(message: String = "") -> void:
	if game_view == null:
		return
	var run_state = game_view.get("state")
	var viewing_debrief := String(run_state.get("phase")) == "results"
	run_record_context_label.text = "%s · %s" % ["COMPLETED DEBRIEF" if viewing_debrief else "PAUSED MARCH", String(game_view.call("current_run_code"))]
	run_record_body_label.text = String(game_view.call("current_run_record_text"))
	run_record_status_label.text = message if not message.is_empty() else "Read-only record. Copying changes only the local clipboard; nothing is opened or sent."

func _copy_run_record() -> void:
	if game_view == null:
		return
	DisplayServer.clipboard_set(String(game_view.call("current_run_record_text")))
	_refresh_run_record("MARCH RECORD COPIED · Paste it into your notes when you choose. Nothing was opened or sent.")
	run_record_copy_button.grab_focus()

func _refresh_pause_summary(message: String = "") -> void:
	if game_view == null:
		return
	var run_state = game_view.get("state")
	var location := String(run_state.get("current_location")).replace("_", " ").capitalize()
	var phase_id := String(run_state.get("phase"))
	var phase := phase_id.replace("_", " ").capitalize()
	var viewing_debrief := phase_id == "results"
	var current_run_saved := _current_run_matches_save()
	var region_id := String(run_state.get("campaign_region_id"))
	var region_name := _region_display_name(region_id)
	var current_order_destination := String(game_view.call("current_order_destination"))
	pause_eyebrow_label.text = "FINAL REPORT" if viewing_debrief else "THE ROAD WAITS"
	pause_title_label.text = "DEBRIEF OPTIONS" if viewing_debrief else "MARCH PAUSED"
	pause_detail_label.text = "The march has ended. Review the result, save it locally, or adjust settings." if viewing_debrief else "Nothing changes here. Resume where you left off, or return to the current order."
	resume_button.text = "RETURN TO DEBRIEF" if viewing_debrief else "RESUME HERE"
	pause_order_button.text = "GO TO %s" % current_order_destination
	pause_order_button.tooltip_text = "Return to %s without activating it." % current_order_destination.to_lower()
	pause_save_button.text = "SAVE RESULT" if viewing_debrief else "SAVE MARCH"
	restart_button.text = "PLAY AGAIN" if viewing_debrief else "RESTART"
	restart_button.tooltip_text = "Begin another %s march after confirmation." % region_name if viewing_debrief else "Discard the current %s stage state and begin again." % region_name
	pause_hint_label.text = _pause_cancel_hint()
	pause_summary_label.text = "%s · DAY %d · %s\n%s · %d/5 encounters secured · RUN %s\nFUEL %d · HULL %d/10 · HEAT %d/%d" % [region_name.to_upper(), int(run_state.get("day")), location, phase, int(run_state.get("campaign_encounters_completed")), String(game_view.call("current_run_code")), int(run_state.get("fuel")), int(run_state.get("hull_condition")), int(run_state.get("heat")), LongMarchState.BASE_HEAT_LIMIT]
	title_button.text = "RETURN TO TITLE" if current_run_saved else "EXIT UNSAVED"
	title_button.tooltip_text = "Return to the title. The current decision is already saved." if current_run_saved else "Return to the title without updating the local save."
	if current_run_saved:
		_clear_button_accent(title_button)
	else:
		_warning_button(title_button)
	if not message.is_empty():
		pause_save_status_label.text = message
	elif viewing_debrief:
		if current_run_saved:
			pause_save_status_label.text = "This result is saved under Continue."
		elif FileAccess.file_exists(_active_save_path()):
			pause_save_status_label.text = "This result is not saved · the earlier checkpoint is unchanged."
		else:
			pause_save_status_label.text = "This result is not saved yet · use Save Result or Save & Return."
	elif not autosave_enabled:
		pause_save_status_label.text = "Current decision is saved · autosave remains off." if current_run_saved else "Autosave is off · use Save March to preserve progress."
	elif last_checkpoint_reason == "loaded save":
		pause_save_status_label.text = "Current decision matches the loaded checkpoint." if current_run_saved else "Unsaved changes since the loaded checkpoint."
	elif not last_checkpoint_reason.is_empty():
		pause_save_status_label.text = "Current decision saved · %s" % _checkpoint_label(last_checkpoint_reason) if current_run_saved else "Unsaved changes since · %s" % _checkpoint_label(last_checkpoint_reason)
	elif FileAccess.file_exists(_active_save_path()):
		pause_save_status_label.text = "Current decision is saved." if current_run_saved else "A previous local save is available. Save to capture this decision."
	else:
		pause_save_status_label.text = "No decision checkpoint yet · commit a choice or use Save March."

func _current_run_matches_save() -> bool:
	var save_path := _active_save_path()
	if game_view == null or not FileAccess.file_exists(save_path):
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var saved_state := LongMarchState.new(0)
	var validation := saved_state.load_serialized(parsed)
	if not bool(validation.get("ok", false)):
		return false
	var run_state = game_view.get("state")
	return _saved_values_match(saved_state.serialize(), run_state.serialize())

func _active_stage_is_tutorial() -> bool:
	return game_view != null and bool(game_view.get("tutorial_mode"))

func _active_save_path() -> String:
	return TUTORIAL_SAVE_PATH if _active_stage_is_tutorial() else SAVE_PATH

func _save_active_stage(silent: bool = false) -> bool:
	if game_view == null:
		return false
	return bool(game_view.call("save_tutorial_run" if _active_stage_is_tutorial() else "save_run", silent))

func _saved_values_match(saved: Variant, live: Variant) -> bool:
	if saved is Dictionary and live is Dictionary:
		if saved.size() != live.size():
			return false
		for key in saved:
			if not live.has(key) or not _saved_values_match(saved[key], live[key]):
				return false
		return true
	if saved is Array and live is Array:
		if saved.size() != live.size():
			return false
		for index in range(saved.size()):
			if not _saved_values_match(saved[index], live[index]):
				return false
		return true
	if (saved is int or saved is float) and (live is int or live is float):
		return is_equal_approx(float(saved), float(live))
	return saved == live

func _save_from_pause() -> bool:
	if game_view == null:
		return false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	var saved := _save_active_stage()
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	var viewing_debrief := String(game_view.get("state").get("phase")) == "results"
	var success_message := "Result saved. Continue will reopen this debrief." if viewing_debrief else "Saved. Continue will resume from this decision."
	_refresh_pause_summary(success_message if saved else "Save failed. Return to the stage and review the error message.")
	if saved:
		last_checkpoint_reason = "manual save"
		pause_save_button.grab_focus()
	return saved

func _on_checkpoint_reached(reason: String) -> void:
	if game_view == null:
		return
	if not _active_stage_is_tutorial():
		_record_campaign_progress()
	if not autosave_enabled:
		return
	if _save_active_stage(true):
		last_checkpoint_reason = reason
		_show_checkpoint_toast(reason)

func _record_campaign_progress() -> void:
	if game_view == null or _active_stage_is_tutorial():
		return
	var run_state = game_view.get("state")
	var errors: Array[String] = []
	var attempted_write := false
	var development_id := String(run_state.call("earned_regional_development"))
	if not development_id.is_empty():
		attempted_write = true
		var development_result := campaign_progress.unlock(development_id)
		if not bool(development_result.get("ok", false)):
			errors.append(String(development_result.get("reason", "regional development could not be saved")))
	if String(run_state.get("phase")) == "results":
		attempted_write = true
		var chapter_result := campaign_progress.record_region_result(String(run_state.get("campaign_region_id")), String(run_state.get("final_result")))
		if not bool(chapter_result.get("ok", false)):
			errors.append(String(chapter_result.get("reason", "chapter result could not be saved")))
	if attempted_write:
		campaign_progress_error = "; ".join(errors)
	run_state.call("set_regional_developments", campaign_progress.developments)
	game_view.set("starting_regional_developments", campaign_progress.developments.duplicate())
	game_view.set("starting_region_results", campaign_progress.region_results.duplicate(true))

func _show_checkpoint_toast(reason: String) -> void:
	if checkpoint_toast_tween != null and checkpoint_toast_tween.is_valid():
		checkpoint_toast_tween.kill()
	checkpoint_toast_label.text = "SAVED · %s" % _checkpoint_label(reason).to_upper()
	_position_checkpoint_toast()
	checkpoint_toast.modulate = Color.WHITE
	checkpoint_toast.visible = true
	interface_audio.play_notice()
	checkpoint_toast_tween = create_tween()
	checkpoint_toast_tween.tween_interval(1.6)
	if not reduced_motion:
		checkpoint_toast_tween.tween_property(checkpoint_toast, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	checkpoint_toast_tween.tween_callback(func() -> void: checkpoint_toast.visible = false)

func _position_checkpoint_toast() -> void:
	checkpoint_toast.size = Vector2(CHECKPOINT_TOAST_WIDTH, CHECKPOINT_TOAST_HEIGHT)
	var toast_x := 330.0
	if game_view != null:
		var stage_pause_button = game_view.get("pause_button") as Control
		if stage_pause_button != null and stage_pause_button.is_visible_in_tree():
			toast_x = minf(toast_x, maxf(24.0, stage_pause_button.get_global_rect().position.x - checkpoint_toast.size.x - CHECKPOINT_TOAST_GAP))
	checkpoint_toast.position = Vector2(toast_x, 4)

func _dismiss_checkpoint_toast() -> void:
	if checkpoint_toast_tween != null and checkpoint_toast_tween.is_valid():
		checkpoint_toast_tween.kill()
	checkpoint_toast.visible = false

func _checkpoint_label(reason: String) -> String:
	return String(CHECKPOINT_LABELS.get(reason, reason.replace("_", " ").capitalize()))

func _save_and_return_to_title() -> void:
	if _save_from_pause():
		_return_to_title()

func _resume_game() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	if paused_stage_focus != null and is_instance_valid(paused_stage_focus) and paused_stage_focus.is_visible_in_tree() and paused_stage_focus.focus_mode != Control.FOCUS_NONE and not (paused_stage_focus is BaseButton and paused_stage_focus.disabled):
		paused_stage_focus.grab_focus()
	else:
		game_view.call_deferred("focus_current_action")
	paused_stage_focus = null

func _resume_at_current_order() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	paused_stage_focus = null
	game_view.call_deferred("focus_current_action")

func _show_in_run_briefing() -> void:
	if game_view == null:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	paused_stage_focus = null
	game_view.call("_show_onboarding", true)

func _show_pause_playtest_notes() -> void:
	if game_view == null or not pause_view.visible:
		return
	pause_view.visible = false
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	game_view.call("show_playtest_notes", "pause")

func _return_from_playtest_notes() -> void:
	if game_view == null:
		return
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	pause_view.visible = true
	pause_notes_button.grab_focus()

func _restart_game() -> void:
	var region_id := String(game_view.get("state").get("campaign_region_id")) if game_view != null else "ashgate_lowlands"
	_open_stage(false, false, region_id)

func _on_restart_pressed() -> void:
	if game_view != null and String(game_view.get("state").get("phase")) == "results":
		_request_confirmation("replay")
	else:
		_request_confirmation("restart")

func _request_replay_confirmation() -> void:
	if game_view == null:
		return
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	_request_confirmation("replay")

func _request_march_on_confirmation(region_id: String) -> void:
	if game_view == null or region_id not in ["ashgate_lowlands", "flooded_veyru"]:
		return
	if _active_stage_is_tutorial() and region_id == "ashgate_lowlands":
		var marker := FileAccess.open(TUTORIAL_COMPLETE_PATH, FileAccess.WRITE)
		if marker != null:
			marker.store_string("completed")
			marker.close()
		_open_stage(false, false, "ashgate_lowlands")
		return
	if String(game_view.get("state").get("phase")) != "results":
		return
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	_request_confirmation("march_on_ashgate" if region_id == "ashgate_lowlands" else "march_on_veyru")

func _request_confirmation(action: String) -> void:
	if action not in ["restart", "replay", "march_on_ashgate", "march_on_veyru", "quit_save", "title", "restore_backup", "clear_progress", "clear_save", "clear_invalid_save", "reset_playtest_data", "new_guided", "new_quick", "new_veyru"]:
		return
	if action in ["clear_progress", "reset_playtest_data"] and game_view != null:
		return
	if action == "title" and _current_run_matches_save():
		_return_to_title()
		return
	pending_confirmation = action
	if action == "restart":
		var restart_save := _saved_run_info()
		var restart_region_id := _active_region_id()
		var restart_region_name := _region_display_name(restart_region_id)
		var restart_start_name := _region_start_name(restart_region_id)
		confirmation_title_label.text = "Restart %s?" % restart_region_name
		if bool(restart_save.get("valid", false)):
			var saved_context := "%s result from %s" % [String(restart_save.get("result", "completed")), String(restart_save.get("region", "the saved chapter"))] if bool(restart_save.get("completed", false)) else "Day %d at %s in %s" % [int(restart_save.get("day", 1)), String(restart_save.get("location", "the last location")), String(restart_save.get("region", "the saved chapter"))]
			confirmation_body_label.text = ("Current %s progress will reset to %s. Your %s checkpoint remains under Continue until the restarted run reaches its first automatic checkpoint." if autosave_enabled else "Current %s progress will reset to %s. Your %s checkpoint remains under Continue until you save the restarted run.") % [restart_region_name, restart_start_name, saved_context]
		else:
			confirmation_body_label.text = "Current %s progress will reset to %s. There is no usable checkpoint to return to." % [restart_region_name, restart_start_name]
		confirmation_confirm_button.text = "RESTART"
	elif action == "replay":
		var replay_save := _saved_run_info()
		var replay_region_id := _active_region_id()
		var replay_region_name := _region_display_name(replay_region_id)
		var replay_menu_name := "Flooded Veyru" if replay_region_id == "flooded_veyru" else "Ashgate"
		confirmation_title_label.text = "Replay %s?" % replay_region_name
		if _current_run_matches_save():
			confirmation_body_label.text = "Your completed result is saved under Continue. Play Again will replace it with a fresh %s checkpoint immediately." % replay_menu_name if autosave_enabled else "Your completed result remains under Continue until you save the fresh %s run." % replay_menu_name
		elif bool(replay_save.get("valid", false)):
			var saved_context := "%s result from %s" % [String(replay_save.get("result", "completed")), String(replay_save.get("region", "the saved chapter"))] if bool(replay_save.get("completed", false)) else "Day %d at %s in %s" % [int(replay_save.get("day", 1)), String(replay_save.get("location", "the previous checkpoint")), String(replay_save.get("region", "the saved chapter"))]
			confirmation_body_label.text = ("This result is not saved under Continue; it still points to %s. Play Again will replace that checkpoint with a fresh %s run immediately." if autosave_enabled else "This result is not saved under Continue; it still points to %s. That checkpoint remains until you save the fresh %s run.") % [saved_context, replay_menu_name]
		else:
			confirmation_body_label.text = "This result is not saved under Continue. Play Again will create a fresh %s checkpoint immediately." % replay_menu_name if autosave_enabled else "This result is not saved under Continue. Play Again starts a fresh %s run without creating a checkpoint until you save manually." % replay_menu_name
		confirmation_confirm_button.text = "PLAY AGAIN"
	elif action in ["march_on_ashgate", "march_on_veyru"]:
		var next_region_id := "ashgate_lowlands" if action == "march_on_ashgate" else "flooded_veyru"
		var next_region_name := _region_display_name(next_region_id)
		var current_region_name := _region_display_name(_active_region_id())
		confirmation_title_label.text = "Continue to %s?" % next_region_name
		confirmation_body_label.text = "The %s result is recorded in the March Charter. Begin a fresh %s chapter now; Continue keeps its current checkpoint until the next automatic save." % [current_region_name, next_region_name] if autosave_enabled else "The %s result is recorded in the March Charter. Begin a fresh %s chapter now; Continue changes only when you save manually." % [current_region_name, next_region_name]
		confirmation_confirm_button.text = "MARCH ON"
	elif action == "quit_save":
		var run_state = game_view.get("state")
		var region_name := _region_display_name(String(run_state.get("campaign_region_id")))
		var location := String(run_state.get("current_location")).replace("_", " ").capitalize()
		confirmation_title_label.text = "Save before quitting?"
		confirmation_body_label.text = "%s at %s has unsaved changes. Save this exact decision to the local Continue slot, then close the game." % [region_name, location]
		confirmation_confirm_button.text = "SAVE & QUIT"
	elif action == "title":
		confirmation_title_label.text = "Return without saving?"
		confirmation_body_label.text = "Progress since the last save will be discarded. Choose Save & Return instead if you want to continue later."
		confirmation_confirm_button.text = "RETURN"
	elif action == "clear_progress":
		confirmation_title_label.text = "Reset the March Charter?"
		confirmation_body_label.text = "Regional results and Public Archive Signal will be permanently removed. Continue, settings, and briefing progress remain unchanged."
		confirmation_confirm_button.text = "RESET CHARTER"
	elif action == "restore_backup":
		var save_info := _saved_run_info()
		confirmation_title_label.text = "Restore the backup?"
		confirmation_body_label.text = "Replace the unusable Continue file with the valid %s checkpoint from Day %d at %s. The broken file will be discarded; March Charter, settings, and briefing progress remain unchanged." % [String(save_info.get("backup_region", "campaign")), int(save_info.get("backup_day", 1)), String(save_info.get("backup_location", "the previous decision"))]
		confirmation_confirm_button.text = "RESTORE BACKUP"
	elif action in ["clear_save", "clear_invalid_save"]:
		confirmation_title_label.text = "Clear the local save?"
		confirmation_body_label.text = "This local checkpoint cannot be loaded by this build. It and any local recovery backup will be permanently removed; your March Charter, settings, and briefing preference remain unchanged." if action == "clear_invalid_save" else "Continue progress and its local recovery backup will be permanently removed. Your March Charter, settings, and briefing preference remain unchanged."
		confirmation_confirm_button.text = "REMOVE SAVE" if action == "clear_invalid_save" else "CLEAR SAVE"
	elif action == "reset_playtest_data":
		confirmation_title_label.text = "Start with clean playtest data?"
		confirmation_body_label.text = "Continue and its backup, March Charter developments, briefing completion, preferences, and the current local journal will be permanently removed. Exported playtest reports remain available."
		confirmation_confirm_button.text = "RESET PLAYTEST DATA"
	else:
		var save_info := _saved_run_info()
		if bool(save_info.get("completed", false)):
			var result_name := String(save_info.get("result", "completed")).capitalize()
			confirmation_title_label.text = "Begin another march?"
			confirmation_body_label.text = ("Your %s result remains available under Continue until the new run reaches its first automatic checkpoint. After that, Continue will follow the new march." if autosave_enabled else "Your %s result remains available under Continue. It is replaced only if you save manually or enable autosave and reach a checkpoint.") % result_name
			confirmation_confirm_button.text = "PLAY AGAIN"
		else:
			var saved_context := "Day %d at %s" % [int(save_info.get("day", 1)), String(save_info.get("location", "the last checkpoint"))]
			confirmation_title_label.text = "Begin a new march?"
			confirmation_body_label.text = ("Your %s save remains intact until the new run reaches its first automatic checkpoint. After that, Continue will follow the new march." if autosave_enabled else "Your %s save remains intact. This run replaces it only if you save manually or enable autosave and reach a checkpoint.") % saved_context
			confirmation_confirm_button.text = "START NEW"
	if action == "clear_invalid_save":
		confirmation_cancel_button.text = "KEEP FILE"
	elif action == "restore_backup":
		confirmation_cancel_button.text = "KEEP FILES"
	elif action in ["new_guided", "new_quick", "new_veyru"]:
		confirmation_cancel_button.text = "KEEP RESULT" if bool(_saved_run_info().get("completed", false)) else "KEEP SAVE"
	elif action == "clear_save":
		confirmation_cancel_button.text = "KEEP SAVE"
	elif action == "clear_progress":
		confirmation_cancel_button.text = "KEEP CHARTER"
	elif action == "reset_playtest_data":
		confirmation_cancel_button.text = "KEEP LOCAL DATA"
	elif action in ["march_on_ashgate", "march_on_veyru"]:
		confirmation_cancel_button.text = "STAY AT DEBRIEF"
	elif action == "quit_save":
		confirmation_cancel_button.text = "KEEP PLAYING"
	elif action == "replay":
		confirmation_cancel_button.text = "KEEP RESULT"
	else:
		confirmation_cancel_button.text = "KEEP PLAYING"
	confirmation_view.visible = true
	interface_audio.play_warning()
	confirmation_cancel_button.grab_focus()

func _cancel_confirmation() -> void:
	var previous_action := pending_confirmation
	pending_confirmation = ""
	confirmation_view.visible = false
	if previous_action == "restart":
		restart_button.grab_focus()
	elif previous_action == "replay":
		if pause_view.visible:
			restart_button.grab_focus()
		elif game_view != null:
			game_view.process_mode = Node.PROCESS_MODE_INHERIT
			game_view.call_deferred("focus_replay_action")
	elif previous_action in ["march_on_ashgate", "march_on_veyru"]:
		if game_view != null:
			game_view.process_mode = Node.PROCESS_MODE_INHERIT
			game_view.call_deferred("focus_march_on_action")
	elif previous_action == "quit_save":
		if game_view != null:
			game_view.process_mode = close_request_process_mode
			if close_request_focus != null and is_instance_valid(close_request_focus) and close_request_focus.is_visible_in_tree() and close_request_focus.focus_mode != Control.FOCUS_NONE:
				close_request_focus.grab_focus()
			elif settings_view.visible:
				settings_close_button.grab_focus()
			elif close_request_was_paused:
				resume_button.grab_focus()
			else:
				game_view.call_deferred("focus_current_action")
		close_request_focus = null
		close_request_was_paused = false
		close_request_process_mode = Node.PROCESS_MODE_INHERIT
	elif previous_action == "clear_save":
		clear_save_button.grab_focus()
	elif previous_action == "clear_progress":
		reset_charter_button.grab_focus()
	elif previous_action == "reset_playtest_data":
		reset_playtest_button.grab_focus()
	elif previous_action == "clear_invalid_save":
		save_recovery_button.grab_focus()
	elif previous_action == "restore_backup":
		save_recovery_button.grab_focus()
	elif previous_action == "new_quick":
		(guide_quick_start_button if guide_view.visible else quick_start_button).grab_focus()
	elif previous_action == "new_guided":
		start_button.grab_focus()
	elif previous_action == "new_veyru":
		(guide_veyru_start_button if guide_view.visible else veyru_start_button).grab_focus()
	else:
		title_button.grab_focus()

func _confirm_pending_action() -> void:
	var action := pending_confirmation
	pending_confirmation = ""
	confirmation_view.visible = false
	if action == "restart":
		_restart_game()
	elif action == "replay":
		if game_view != null:
			pause_view.visible = false
			paused_stage_focus = null
			game_view.process_mode = Node.PROCESS_MODE_INHERIT
			game_view.call("start_replay_from_results")
	elif action in ["march_on_ashgate", "march_on_veyru"]:
		pause_view.visible = false
		paused_stage_focus = null
		_open_stage(false, false, "ashgate_lowlands" if action == "march_on_ashgate" else "flooded_veyru")
	elif action == "quit_save":
		_save_and_quit()
	elif action == "title":
		_return_to_title()
	elif action == "clear_progress":
		var clear_result := campaign_progress.clear_progress()
		if bool(clear_result.get("ok", false)):
			campaign_progress_error = ""
			_refresh_title_state()
			_refresh_settings("March Charter reset. Continue, settings, and briefing progress were kept.")
			settings_close_button.grab_focus()
		else:
			_refresh_settings("Could not reset the March Charter: %s" % String(clear_result.get("reason", "unknown error")))
			reset_charter_button.grab_focus()
	elif action == "restore_backup":
		var restore_result := _restore_save_backup()
		_refresh_title_state()
		if bool(restore_result.get("ok", false)):
			continue_button.grab_focus()
		else:
			save_status_label.text = "Backup restore failed · %s" % String(restore_result.get("reason", "unknown error"))
			save_recovery_button.grab_focus()
	elif action in ["clear_save", "clear_invalid_save"]:
		var clear_result := _clear_local_save_files()
		_refresh_title_state()
		if not bool(clear_result.get("ok", false)):
			if settings_view.visible:
				_refresh_settings("Could not clear all local save files: %s" % String(clear_result.get("reason", "unknown error")))
				clear_save_button.grab_focus()
			else:
				save_status_label.text = "Save removal incomplete · %s" % String(clear_result.get("reason", "unknown error"))
				save_recovery_button.grab_focus()
		elif action == "clear_invalid_save":
			tutorial_button.grab_focus()
		else:
			_refresh_settings("Continue and its recovery backup were cleared. Start Game begins a fresh march.")
			settings_close_button.grab_focus()
	elif action == "reset_playtest_data":
		var reset_result := _reset_playtest_data()
		_refresh_title_state()
		if bool(reset_result.get("ok", false)):
			_refresh_settings("Clean playtest state restored. Exported feedback reports were kept.")
			settings_close_button.grab_focus()
		else:
			_refresh_settings("Playtest reset was incomplete: %s" % String(reset_result.get("reason", "unknown error")))
			(reset_playtest_button if not reset_playtest_button.disabled else settings_close_button).grab_focus()
	elif action == "new_guided":
		_open_stage(false, true)
	elif action == "new_quick":
		_open_stage(false, false)
	elif action == "new_veyru":
		_open_stage(false, false, "flooded_veyru")

func _show_guide() -> void:
	guide_view.visible = true
	guide_quick_start_button.grab_focus()

func _hide_guide() -> void:
	guide_view.visible = false
	guide_button.grab_focus()

func _return_to_title() -> void:
	_capture_title_return_notice()
	pause_view.visible = false
	guide_view.visible = false
	settings_view.visible = false
	tutorial_intro.visible = false
	data_info_view.visible = false
	run_record_view.visible = false
	confirmation_view.visible = false
	pending_confirmation = ""
	paused_stage_focus = null
	settings_opened_from_pause = false
	last_checkpoint_reason = ""
	checkpoint_toast.visible = false
	if game_view != null:
		var old_game := game_view
		game_view = null
		old_game.queue_free()
	menu_view.visible = true
	_refresh_title_state()
	_focus_title_primary()

func _capture_title_return_notice() -> void:
	if game_view == null:
		return
	var run_state = game_view.get("state")
	var region_name := _region_display_name(String(run_state.get("campaign_region_id")))
	var location := String(run_state.get("current_location")).replace("_", " ").capitalize()
	var day := int(run_state.get("day"))
	var viewing_debrief := String(run_state.get("phase")) == "results"
	var tutorial_run := _active_stage_is_tutorial()
	if _current_run_matches_save():
		title_return_notice_kind = "saved"
		if tutorial_run:
			title_return_notice = "RETURN RECEIPT · TUTORIAL CHECKPOINT SAVED\nThe First Watch remains available under Resume Tutorial."
			return
		if viewing_debrief:
			title_return_notice = "RETURN RECEIPT · RESULT SAVED\n%s debrief remains available under Continue." % region_name
		else:
			title_return_notice = "RETURN RECEIPT · CHECKPOINT SAVED\n%s · Day %d at %s remains available under Continue." % [region_name, day, location]
		return
	var prior_save := _tutorial_saved_run_info() if tutorial_run else _saved_run_info()
	title_return_notice_kind = "discarded"
	if bool(prior_save.get("valid", false)):
		var prior_context := "%s result" % String(prior_save.get("result", "completed"))
		if not bool(prior_save.get("completed", false)):
			prior_context = "%s · Day %d at %s" % [String(prior_save.get("region", "Campaign")), int(prior_save.get("day", 1)), String(prior_save.get("location", "the previous decision"))]
		title_return_notice = "RETURN RECEIPT · UNSAVED %s CHANGES DISCARDED\nContinue still holds the earlier %s." % [region_name.to_upper(), prior_context]
	else:
		title_return_notice = "RETURN RECEIPT · UNSAVED %s CHANGES DISCARDED\nNo Continue checkpoint was created." % region_name.to_upper()

func _refresh_title_return_notice() -> void:
	if title_return_notice_panel == null:
		return
	title_return_notice_panel.visible = not title_return_notice.is_empty()
	save_status_label.visible = not title_return_notice_panel.visible
	if not title_return_notice_panel.visible:
		return
	title_return_notice_label.text = title_return_notice
	if title_return_notice_kind == "discarded":
		title_return_notice_label.add_theme_color_override("font_color", Color("#ffd2c5"))
		title_return_notice_panel.add_theme_stylebox_override("panel", _flat_style(Color("#2a1715"), Color("#d77864"), 1, 5, 8))
	else:
		title_return_notice_label.add_theme_color_override("font_color", Color("#dcf7e8"))
		title_return_notice_panel.add_theme_stylebox_override("panel", _flat_style(Color("#173027"), Color("#76c99d"), 1, 5, 8))

func _clear_title_return_notice() -> void:
	title_return_notice = ""
	title_return_notice_kind = ""
	if title_return_notice_panel != null:
		title_return_notice_panel.visible = false
	if save_status_label != null:
		save_status_label.visible = true

func _quit_game() -> void:
	_perform_application_quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_inside_tree():
		_request_application_close()

func _request_application_close() -> void:
	if confirmation_view != null and confirmation_view.visible:
		return
	if game_view == null or _current_run_matches_save():
		_perform_application_quit()
		return
	close_request_focus = get_viewport().gui_get_focus_owner()
	close_request_was_paused = pause_view.visible or run_record_view.visible or settings_opened_from_pause
	close_request_process_mode = game_view.process_mode
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	_request_confirmation("quit_save")

func _save_and_quit() -> void:
	if game_view == null:
		_perform_application_quit()
		return
	game_view.process_mode = Node.PROCESS_MODE_INHERIT
	if not _active_stage_is_tutorial():
		_record_campaign_progress()
	if _save_active_stage():
		last_checkpoint_reason = "manual save"
		close_request_focus = null
		close_request_was_paused = false
		close_request_process_mode = Node.PROCESS_MODE_INHERIT
		_perform_application_quit()
		return
	game_view.process_mode = Node.PROCESS_MODE_DISABLED
	pending_confirmation = "quit_save"
	confirmation_view.visible = true
	confirmation_title_label.text = "Could not save"
	confirmation_body_label.text = "The game is still open and your latest state was not saved. Check local storage access, then try again or keep playing."
	confirmation_confirm_button.text = "TRY SAVE AGAIN"
	confirmation_cancel_button.text = "KEEP PLAYING"
	confirmation_cancel_button.grab_focus()

func _perform_application_quit() -> void:
	if not application_quit_requested.get_connections().is_empty():
		application_quit_requested.emit()
		return
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if tutorial_intro != null and tutorial_intro.visible:
		_hide_tutorial_intro()
		get_viewport().set_input_as_handled()
		return
	if confirmation_view.visible:
		_cancel_confirmation()
		get_viewport().set_input_as_handled()
		return
	if data_info_view.visible:
		_hide_data_info()
		get_viewport().set_input_as_handled()
		return
	if run_record_view.visible:
		_hide_run_record()
		get_viewport().set_input_as_handled()
		return
	if settings_view.visible:
		_hide_settings()
		get_viewport().set_input_as_handled()
		return
	if game_view == null:
		if guide_view.visible:
			_hide_guide()
			get_viewport().set_input_as_handled()
		return
	if pause_view.visible:
		_resume_game()
	else:
		_show_pause()
	get_viewport().set_input_as_handled()
