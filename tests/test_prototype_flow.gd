extends SceneTree

const CampaignMapView = preload("res://src/ui/campaign_map.gd")

var game: Control
var failures: Array[String] = []
var return_to_title_requested: bool = false
var last_checkpoint_reason: String = ""

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _mark_return_to_title_requested() -> void:
	return_to_title_requested = true

func _record_checkpoint(reason: String) -> void:
	last_checkpoint_reason = reason

func _module_picker_index(module_id: String) -> int:
	for index in range(game.module_option.item_count):
		if String(game.module_option.get_item_metadata(index)) == module_id:
			return index
	return -1

func _init() -> void:
	call_deferred("_run")

func _press_campaign_node(node_id: String) -> void:
	for button in game.campaign_node_buttons:
		if button.visible and String(button.get_meta("node_id", "")) == node_id:
			_expect(not button.disabled, "campaign node button should be enabled: " + node_id)
			if button.disabled:
				return
			button.pressed.emit()
			await process_frame
			await process_frame
			await process_frame
			_expect(game.selected_campaign_node_id == node_id and game.state.phase in ["refit", "map", "settlement"], "selecting a map node should wait for explicit route confirmation: " + node_id)
			_expect(game.guidance_label.text.begins_with("ROUTE READY"), "selecting a route should update the current objective before commitment")
			_expect(not game.campaign_map.commit_button.disabled, "selected route should enable the commit control: " + node_id)
			_expect(game.campaign_map.commit_button.has_focus(), "route selection should move keyboard or controller focus to confirmation")
			_expect(game.right_scroll.get_global_rect().encloses(game.campaign_commit_intel_label.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.campaign_commit_button.get_global_rect()), "route confirmation should keep its compact intel and Commit action visible together")
			game.campaign_map.commit_button.pressed.emit()
			await process_frame
			return
	_expect(false, "campaign node button should be available: " + node_id)

func _press_campaign_event(choice_id: String) -> void:
	for button in game.campaign_event_buttons:
		if button.visible and String(button.get_meta("choice_id", "")) == choice_id:
			button.pressed.emit()
			await process_frame
			return
	_expect(false, "campaign event choice should be available: " + choice_id)

func _advance_until_phase(expected_phase: String) -> void:
	if game.state.encounter_active:
		game.advance_encounter_button.pressed.emit()
		await process_frame
		if game.state.encounter_active and not game.state.encounter_intervention_used:
			game.intervention_buttons[0].pressed.emit()
			await process_frame
			_expect(game.event_label.text.contains("Weapon priority") and game.event_label.text.contains("heat +1"), "an emergency order should immediately report its exact benefit and cost")
			_expect(game.combat_panel.causal_label.text.contains("Weapon priority") and game.combat_panel.causal_label.text.contains("heat +1"), "the persistent cause-and-effect report should retain the emergency order result")
			_expect(game.intervention_title.text.contains("SPENT") and game.intervention_help_label.text.begins_with("Emergency order spent") and game.intervention_help_label.text.contains("one order returns next encounter"), "spent intervention guidance should direct the player back to damage review and advancement")
			_expect(game.advance_encounter_button.get_node_or_null(game.advance_encounter_button.focus_neighbor_bottom) == game.combat_inspect_button and game.combat_inspect_button.get_node_or_null(game.combat_inspect_button.focus_neighbor_bottom) == game.how_to_play_button and game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_top) == game.combat_inspect_button, "spending the emergency order should remove disabled interventions while retaining chassis inspection in controller navigation")
			_expect(game.advance_encounter_button.has_focus(), "spending an emergency order should return focus to encounter advancement")
	for _step in range(8):
		if game.state.phase == expected_phase:
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame

func _run() -> void:
	var save_path := ProjectSettings.globalize_path("user://the_long_march_prototype.save")
	var backup_path := ProjectSettings.globalize_path("user://the_long_march_prototype.backup.save")
	var onboarding_path := ProjectSettings.globalize_path("user://the_long_march_onboarding_v1.complete")
	var journal_path := ProjectSettings.globalize_path("user://the_long_march_playtest_journal.json")
	for path in [save_path, backup_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	game.return_to_title_requested.connect(_mark_return_to_title_requested)
	game.checkpoint_reached.connect(_record_checkpoint)
	root.add_child(game)
	await process_frame
	await process_frame
	var veyru_map := CampaignMapView.new()
	root.add_child(veyru_map)
	veyru_map.configure({
		"region_id": "flooded_veyru",
		"edges": {"lantern_quay": ["pump_gallery", "sunken_tramworks"], "pump_gallery": ["veyru_evacuation_camp"], "sunken_tramworks": ["veyru_evacuation_camp"], "veyru_evacuation_camp": ["archive_causeway", "drowned_registry", "pilgrim_gantry"], "archive_causeway": ["dry_archive_gate"], "drowned_registry": ["dry_archive_gate"], "pilgrim_gantry": ["dry_archive_gate"], "dry_archive_gate": ["dry_archive"]},
		"current_node": "lantern_quay",
		"secured_path": ["lantern_quay"],
		"available_nodes": ["pump_gallery", "sunken_tramworks"],
		"closed_nodes": [],
		"locked_reasons": {},
		"outgoing_nodes": ["pump_gallery", "sunken_tramworks"],
		"previews": {"pump_gallery": {"visibility": "known", "days": 2, "fuel": 1, "risk": 0.22, "pressure_gain": 2, "reward": 12, "threats": ["Flood Surge"]}, "sunken_tramworks": {"visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.34, "pressure_gain": 1, "reward": 18, "threat_hint": "submerged rail movement"}},
		"current_fuel": 6,
		"current_day": 1,
		"current_pressure": 0,
		"can_depart": true,
		"show_commit": true,
		"interaction_blocked": false
	})
	_expect(veyru_map.region_id == "flooded_veyru" and veyru_map.node_buttons.size() == 9 and veyru_map.button_for("lantern_quay") != null and veyru_map.button_for("ashgate_depot") == null, "the campaign map should rebuild from the isolated Flooded Veyru layout without retaining Ashgate nodes")
	_expect(veyru_map.status_for("pump_gallery") == "available" and veyru_map.status_for("sunken_tramworks") == "available" and veyru_map.button_for("pump_gallery").text.contains("KNOWN · GUARDED"), "the Veyru layout should preserve route status and intel rendering contracts")
	veyru_map.configure({
		"region_id": "flooded_veyru",
		"edges": {"veyru_evacuation_camp": ["pilgrim_gantry"]},
		"current_node": "veyru_evacuation_camp",
		"secured_path": ["lantern_quay", "veyru_evacuation_camp"],
		"available_nodes": ["pilgrim_gantry"],
		"closed_nodes": ["drowned_registry"],
		"outgoing_nodes": ["pilgrim_gantry", "drowned_registry"],
		"previews": {"pilgrim_gantry": {"visibility": "known", "days": 2, "fuel": 1, "risk": 0.18, "pressure_gain": -1, "reward": 0, "threats": ["Flood Surge"]}},
		"current_fuel": 3,
		"current_day": 4,
		"current_pressure": 5,
		"can_depart": true
	})
	_expect(veyru_map.status_for("pilgrim_gantry") == "available" and veyru_map.detail_for("drowned_registry").contains("Pilgrim Gantry remains available"), "Veyru map copy should explain the guaranteed recovery road when rising water closes an optional branch")
	veyru_map.queue_free()
	var combat_receipt: String = game.combat_panel._latest_causal_lines([
		"Step 3: the road pressure advances.",
		"Shell Cannon fires a burst into the Burrower.",
		"Lower Hull Plate absorbs 2 damage intended for Coal Cell.",
		"Burrower hits Coal Cell for 1; durability is 0.",
		"Dependency change: March Engine is now offline — engine has no adjacent Coal Cell.",
		"Field Workshop restores Coal Cell by 1 durability."
	])
	_expect(combat_receipt.contains("Lower Hull Plate absorbs") and combat_receipt.contains("Burrower hits Coal Cell") and combat_receipt.contains("March Engine is now offline") and combat_receipt.contains("Field Workshop restores"), "the combat receipt should preserve the latest impact from mitigation through dependency failure and repair")
	_expect(not combat_receipt.contains("Shell Cannon fires"), "the combat receipt should prefer the latest incoming cause-and-effect chain over older outgoing detail")
	_expect(game.onboarding_overlay.visible, "a first run should open the Marchmaster briefing")
	_expect(game.ONBOARDING_STEPS.size() == 7 and game.onboarding_step_buttons.size() == 7, "the guided briefing should teach each core dependency and journey decision through seven directly reachable topics")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_skip_button, "the first briefing step should route left around its disabled Previous action")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_next) == game.onboarding_step_buttons[0] and game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_top) == game.onboarding_step_buttons[0], "the briefing should trap Tab and vertical focus while exposing its topic rail")
	_expect(game.onboarding_progress_label.text.contains("D-pad") and game.onboarding_progress_label.text.contains("A / Enter"), "the briefing should name controller and keyboard navigation together")
	_expect(game.onboarding_action_label.text.begins_with("FIRST ACTION"), "each briefing page should name a concrete player action")
	var briefing_state_before_topics: Dictionary = game.state.serialize()
	game.onboarding_step_buttons[5].pressed.emit()
	await process_frame
	_expect(game.onboarding_step == 5 and game.onboarding_title_label.text == "Choose, review, then commit" and game.onboarding_step_buttons[5].has_focus(), "the briefing topic rail should jump directly to route guidance and retain controller focus")
	_expect(game.state.serialize() == briefing_state_before_topics, "browsing briefing topics should not mutate deterministic campaign state")
	game.onboarding_step_buttons[0].pressed.emit()
	await process_frame
	_expect(game.guidance_label.text.begins_with("CURRENT ORDER") and game.guidance_label.text.contains("convoy"), "the opening objective should identify the contract decision")
	_expect(game.encounter_label.text.begins_with("ASHGATE LOWLANDS PREPARATION") and not game.encounter_label.text.contains("NO ENCOUNTER"), "the opening status should frame preparation as progress rather than an empty state")
	_expect(game.how_to_play_button.text == "OPEN FIELD BRIEFING", "the live-stage help action should use the same player-facing name as the pause menu")
	for _step in range(game.ONBOARDING_STEPS.size()):
		if _step == 1:
			_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_back_button, "later briefing steps should restore Previous to controller navigation")
			_expect(game.onboarding_skip_button.get_node_or_null(game.onboarding_skip_button.focus_next) == game.onboarding_back_button, "later briefing steps should restore Previous to the modal Tab cycle")
			_expect(game.onboarding_body_label.text.contains("adjacent Coal Cell") and game.onboarding_body_label.text.contains("Edit Chassis") and game.onboarding_body_label.text.contains("B or Escape returns"), "the engine briefing should teach movement dependency and chassis controls together")
		if _step == 2:
			_expect(game.onboarding_body_label.text.contains("Ammunition Lift") and game.onboarding_body_label.text.contains("emergency ammunition"), "the weapon briefing should explain full and strained ammunition states")
		if _step == 3:
			_expect(game.onboarding_body_label.text.contains("Crew Quarters") and game.onboarding_body_label.text.contains("Parts Crate"), "the workshop briefing should separate staffing from repair supply")
		if _step == 4:
			_expect(game.onboarding_body_label.text.contains("exterior visibility") and game.onboarding_body_label.text.contains("exact forecasts"), "the signal briefing should explain the information-for-exposure tradeoff")
		if _step == 5:
			_expect(game.onboarding_body_label.text.contains("contacts and counters") and game.onboarding_body_label.text.contains("Closing at 3") and game.onboarding_body_label.text.contains("Break at 5"), "the route briefing should explain what exact scouting reveals and when blockade pressure escalates")
			_expect(game.onboarding_action_label.text.contains("whether the chassis answers") and game.onboarding_action_label.text.contains("Commit"), "the route briefing should turn revealed counters into a concrete pre-commit check")
		if _step == game.ONBOARDING_STEPS.size() - 1:
			_expect(game.onboarding_next_button.text == "ENTER ASHGATE", "the final briefing action should clearly enter the playable stage")
		game.onboarding_next_button.pressed.emit()
		await process_frame
	_expect(not game.onboarding_overlay.visible and FileAccess.file_exists(onboarding_path), "completing onboarding should dismiss it and persist the choice")
	_expect(game.state.phase == "refit", "prototype should begin in Ashgate refit")
	_expect(game.current_run_flow_step == 0 and game.run_flow_labels[0].text.contains("PREP"), "the stage tracker should begin at fortress preparation")
	_expect(game.metric_labels.size() == 7 and game.metric_labels["fuel"].text == "6", "the HUD should expose the seven core operating resources")
	_expect(game.current_run_code() == "ASH-1107", "the playable stage should expose a stable chapter-and-seed run identity")
	var opening_record: String = game.current_run_record_text()
	_expect(opening_record.contains("RUN ID · ASH-1107") and opening_record.contains("ASHGATE LOWLANDS · DAY 1 · Ashgate Depot · Refit") and opening_record.contains("Contract · Offered"), "the live March Record should identify the opening run and its unresolved obligation")
	_expect(opening_record.contains("Systems · 6 ready · 1 strained · 0 offline") and opening_record.contains("NEXT ORDER") and opening_record.contains("guard Morrowline"), "the live March Record should preserve current system condition and the authoritative next order")
	_expect(game.contract_accept_button.text.contains("EACH ENEMY +1 HP") and game.contract_accept_button.text.contains("+30 ASHMARKS · +2 TRUST") and game.contract_decline_button.text.contains("NO EXTRA ENEMY HP") and game.contract_decline_button.text.contains("NO CONTRACT PAYOUT OR TRUST"), "the opening contract actions should disclose both sides of the combat and reward tradeoff before commitment")
	_expect(game.contract_accept_button.get_node_or_null(game.contract_accept_button.focus_neighbor_bottom) == game.contract_decline_button and game.contract_decline_button.get_node_or_null(game.contract_decline_button.focus_neighbor_bottom) == game.doctrine_option, "opening planning controls should follow the visible contract-to-doctrine order")
	_expect(game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_bottom) == game.contract_accept_button, "planning controls should wrap to the current mandatory decision")
	_expect(game.current_order_button.text == "GO TO CONTRACT ↓" and game.current_order_button.tooltip_text.contains("without activating it"), "the persistent jump action should name the opening contract without implying activation")
	_expect(not game.fortress_panel.has_focus() and game.fortress_panel.interaction_heading().contains("CHASSIS OVERVIEW") and game.fortress_panel.placement_status_text().begins_with("INSPECT") and game.fortress_panel.placement_status_text().contains("EDIT CHASSIS TO MOVE"), "the untouched opening should present the selected engine as passive inspection rather than an active move command")
	_expect(game.refit_label.text.contains("On chassis for inspection") and game.refit_label.text.contains("Use Edit Chassis or click the grid to move it"), "the opening module summary should explain how inspection becomes an intentional refit action")
	game.how_to_play_button.grab_focus()
	await process_frame
	await process_frame
	_expect(game.right_scroll.get_global_rect().encloses(game.how_to_play_button.get_global_rect()), "manual focus navigation should scroll the field briefing action fully into view")
	var state_before_order_jump: Dictionary = game.state.serialize()
	game.current_order_button.grab_focus()
	game.current_order_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(game.contract_accept_button.has_focus() and game.right_scroll.get_global_rect().encloses(game.contract_accept_button.get_global_rect()), "Go to Contract should focus and reveal the mandatory choice")
	_expect(game.state.serialize() == state_before_order_jump, "jumping to the current order should never activate or mutate the decision")
	_expect(game.doctrine_detail_label.text.contains("Raiders") and game.doctrine_detail_label.text.contains("−1 damage"), "the default doctrine should explain its real targeting and mitigation effects")
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	await process_frame
	_expect(game.doctrine_detail_label.text.contains("+2 heat") and game.doctrine_detail_label.text.contains("incoming damage"), "Run Hot should disclose both its offensive benefit and thermal risk")
	game.doctrine_option.select(0)
	game.doctrine_option.item_selected.emit(0)
	await process_frame
	var generator_index := _module_picker_index("generator_core")
	game.module_option.select(generator_index)
	game.module_option.item_selected.emit(generator_index)
	await process_frame
	_expect(game.selected_module_cell == Vector2i(2, 0) and game.module_option.get_item_text(generator_index).contains("ON CHASSIS"), "the module picker should navigate directly to installed systems")
	_expect(game.refit_label.text.contains("power +4") and game.refit_label.text.contains("ROLE · Adds 4 power") and game.refit_label.text.contains("disable every powered system") and game.fortress_panel.selected_power_text() == "+4" and game.fortress_panel.selected_capability_text().contains("Adds 4 power"), "the selected module summary and chassis status should distinguish Generator Core output and explain its strategic capability")
	var cannon_index := _module_picker_index("shell_cannon")
	game.module_option.select(cannon_index)
	game.module_option.item_selected.emit(cannon_index)
	await process_frame
	_expect(game.selected_module_cell.x < 0 and game.module_option.get_item_text(cannon_index).contains("STORED"), "the module picker should distinguish stored modules ready for placement")
	_expect(game.refit_label.text.contains("power −2") and game.refit_label.text.contains("Stored for placement") and game.refit_label.text.contains("Deals 3 damage to Raiders and Siege Beasts") and game.refit_label.text.contains("adjacent ammunition"), "stored module planning should distinguish inspection from placement while showing Shell Cannon consumption, role, and dependency")
	_expect(game.fortress_panel.cursor_cell == Vector2i(0, 2) and game.fortress_panel.placement_status_text().contains("MASS LIMIT") and game.refit_label.text.contains("CAPACITY · Remove at least 3 mass"), "selecting a stored module should move its preview to the first open footprint and disclose a global capacity blocker immediately")
	var stored_cannon: Dictionary = {}
	for index in range(game.state.stored_modules.size()):
		if String(game.state.stored_modules[index].get("id", "")) == "shell_cannon":
			stored_cannon = game.state.stored_modules[index]
			game.state.stored_modules.remove_at(index)
			break
	game._refresh_ui()
	_expect(game.module_option.is_item_disabled(cannon_index) and game.module_option.get_item_text(cannon_index).contains("LOST"), "a permanently unavailable module should be disabled and marked lost")
	game.state.stored_modules.append(stored_cannon)
	var engine_index := _module_picker_index("steam_lance_engine")
	game.module_option.grab_focus()
	game.module_option.select(engine_index)
	game.module_option.item_selected.emit(engine_index)
	await process_frame
	await process_frame
	_expect(game.dependency_card_label.text.contains("DEPENDENCY · STEAM LANCE ENGINE") and game.dependency_card_label.text.contains("DEPENDS ON · adjacent Coal Cell") and game.dependency_card_label.text.contains("IF LOST · Losing the adjacent Coal Cell stops movement") and game.dependency_card_label.text.contains("COUNTER · Keep a working Coal Cell adjacent"), "the module inspector should present the engine dependency, current risk, downstream failure, and legal counter together")
	_expect(game.right_scroll.get_global_rect().encloses(game.dependency_card_panel.get_global_rect()), "focusing an installed module should keep its complete dependency card visible")
	var before_remove_copy: Dictionary = game.state.serialize()
	game.remove_button.pressed.emit()
	await process_frame
	_expect(game.event_label.text.contains("Choose an empty chassis cell") and not game.event_label.text.contains("Click an empty cell"), "refit receipts should remain input-neutral after removing a module")
	game.state.load_serialized(before_remove_copy)
	game.selected_module_id = "steam_lance_engine"
	game._sync_selected_module_context()
	game._select_module_option("steam_lance_engine")
	game._refresh_ui()
	_expect(game.focus_chassis_button.visible and not game.focus_chassis_button.disabled, "refit should expose an explicit keyboard and controller path into the chassis")
	_expect(game.module_option.get_node_or_null(game.module_option.focus_neighbor_bottom) == game.focus_chassis_button and game.focus_chassis_button.get_node_or_null(game.focus_chassis_button.focus_neighbor_bottom) == game.rotate_button, "planning navigation should include module selection, chassis editing, and refit actions in visible order")
	game.focus_chassis_button.pressed.emit()
	await process_frame
	await process_frame
	game._refresh_ui()
	_expect(game.fortress_panel.has_focus() and game.fortress_panel.cursor_cell == game.selected_module_cell and game.fortress_panel.interaction_heading().contains("EDIT MODE") and game.fortress_panel.interaction_heading().contains("MOUNTS 1/2"), "Edit Chassis should focus the selected module cell and expose current exterior-mount capacity in its mode heading")
	_expect(not game.left_scroll.is_ancestor_of(game.pause_button) and game.get_global_rect().encloses(game.pause_button.get_global_rect()), "active chassis editing should keep the fixed pointer-accessible Pause action outside the evidence scroll")
	_expect(game.pause_button.text.contains("CHASSIS ACTIVE") and game.pause_button.tooltip_text.contains("leaves chassis inspection first"), "the persistent pause action should not claim that B or Escape pauses while chassis controls own cancel")
	_expect(game.left_scroll.get_global_rect().encloses(game.fortress_panel.get_global_rect()), "entering chassis edit mode should reveal the complete grid")
	_expect(game.fortress_panel.placement_status_text().begins_with("SELECTED") and game.fortress_panel.placement_status_text().contains("STEAM LANCE ENGINE"), "the chassis should identify the selected module under its cursor")
	var chassis_right := InputEventAction.new()
	chassis_right.action = "ui_right"
	chassis_right.pressed = true
	game.fortress_panel._gui_input(chassis_right)
	var chassis_down := InputEventAction.new()
	chassis_down.action = "ui_down"
	chassis_down.pressed = true
	game.fortress_panel._gui_input(chassis_down)
	_expect(game.fortress_panel.cursor_cell == Vector2i(1, 1), "focused chassis controls should move the gold cursor with directional input")
	_expect(game.fortress_panel.placement_status_text().contains("BLOCKED") and game.fortress_panel.placement_status_text().contains("OVERLAPS"), "the chassis should explain an invalid preview before the player commits it")
	game.fortress_panel._gui_input(chassis_down)
	game.fortress_panel._gui_input(chassis_down)
	_expect(game.fortress_panel.cursor_cell == Vector2i(1, 3) and game.fortress_panel.placement_status_text().begins_with("PLACEMENT READY"), "the chassis should confirm a valid move before the player commits it")
	var chassis_cancel := InputEventAction.new()
	chassis_cancel.action = "ui_cancel"
	chassis_cancel.pressed = true
	game.fortress_panel._gui_input(chassis_cancel)
	await process_frame
	_expect(game.focus_chassis_button.has_focus(), "B or Escape should return chassis focus to the visible desk action")
	_expect(game.pause_button.text.contains("ESC / B"), "leaving chassis controls should restore the ordinary pause shortcut hint")
	_expect(game.campaign_map.visible and game.campaign_node_buttons.size() == 10, "the campaign should render the full authored node graph")
	var condenser_picker_index := _module_picker_index("water_condenser")
	_expect(condenser_picker_index >= 0 and game.module_option.get_item_text(condenser_picker_index).contains("STORED"), "the Water Condenser should appear as a finite stored module in the refit picker")
	var campaign_action_row: Control = game.campaign_commit_button.get_parent()
	_expect(game.campaign_commit_intel_label.get_parent() == game.campaign_map.get_parent() and game.campaign_commit_intel_label.get_index() == game.campaign_map.get_index() + 1 and campaign_action_row.get_parent() == game.campaign_map.get_parent() and campaign_action_row.get_index() == game.campaign_commit_intel_label.get_index() + 1 and game.campaign_cancel_button.get_parent() == campaign_action_row, "route commitment and its reversible exit should remain grouped in one row directly below the map and compact intel")
	_expect(game.campaign_map.status_for("ashgate_depot") == "current", "the map should mark Ashgate as the current node")
	_expect(game.campaign_map.status_for("rill_crossing") == "blocked" and game.campaign_map.status_for("soot_orchard") == "blocked", "the opening roads should visibly wait for the contract decision")
	game.contract_accept_button.pressed.emit()
	await process_frame
	await process_frame
	await process_frame
	_expect(game.state.guard_contract_status == "accepted", "the guard contract should be selectable through the UI")
	_expect(game.event_label.text.begins_with("CONTRACT DECISION") and game.encounter_label.text.begins_with("CONTRACT DECISION") and game.encounter_label.text.contains("each enemy") and game.encounter_label.text.contains("30 Ashmarks") and game.encounter_label.text.contains("2 trust"), "the accepted contract should leave an exact above-fold consequence receipt after its choice cards disappear")
	_expect(game.guidance_label.text.contains("Select one cyan route"), "the objective should advance immediately after the contract is answered")
	_expect(game.current_order_button.text == "GO TO ROUTES ↓", "the jump action should advance from contract to the available route choices")
	var route_briefing_state: Dictionary = game.state.serialize()
	game._show_onboarding(true)
	await process_frame
	_expect(game.onboarding_step == 5 and game.onboarding_title_label.text == "Choose, review, then commit" and game.onboarding_step_buttons[5].text.begins_with("●"), "reopening Field Briefing during route planning should land on the active road topic")
	game._finish_onboarding(true)
	await process_frame
	await process_frame
	_expect(game.state.serialize() == route_briefing_state, "opening and closing contextual route guidance should preserve the live campaign state")
	_expect(game.current_run_flow_step == 1 and game.run_flow_labels[0].text.begins_with("✓"), "answering the contract should advance the tracker to the Lowlands roads")
	_expect(game.campaign_map.status_for("rill_crossing") == "available" and not game.campaign_map.button_for("rill_crossing").disabled, "answering the contract should activate the opening map nodes")
	_expect(game.campaign_comparison_panel.visible and game.campaign_comparison_label.text.contains("RILL CROSSING · 1D · 1 FUEL · KNOWN · LOW 14% RISK") and game.campaign_comparison_label.text.contains("SOOT ORCHARD · 2D · 2 FUEL · FORECAST · GUARDED 27% RISK") and game.campaign_comparison_label.text.contains("PRESSURE +1") and game.campaign_comparison_label.text.contains("NO SETTLEMENT NEXT"), "route planning should compare confidence, days, fuel, risk band, pressure, threat clue, and onward recovery before selection")
	_expect(game.campaign_pressure_label.text.contains("Closing begins at 3") and game.campaign_pressure_label.text.contains("Break at 5"), "Watch pressure should explain both upcoming closure thresholds before route choice")
	_expect(game.campaign_map.button_for("rill_crossing").text.contains("KNOWN · LOW") and game.campaign_map.button_for("soot_orchard").text.contains("FORECAST · GUARDED"), "available map nodes should expose compact scouting and risk comparisons before focus")
	_expect(game.campaign_map.button_for("rill_crossing").has_focus(), "resolving the contract should hand controller focus to the first route")
	_expect(game.right_scroll.get_global_rect().encloses(game.campaign_map.button_for("rill_crossing").get_global_rect()), "route focus should scroll the selected action fully into view")
	var route_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	var route_asset_rect: Rect2 = game.asset_row.get_global_rect()
	_expect(not route_asset_rect.intersects(route_viewport_rect) or route_viewport_rect.encloses(route_asset_rect), "route focus should not leave the command-desk icon row partially clipped")
	var route_doctrine_rect: Rect2 = game.doctrine_detail_label.get_global_rect()
	_expect(not route_doctrine_rect.intersects(route_viewport_rect) or route_viewport_rect.encloses(route_doctrine_rect), "route focus should not begin midway through the preceding doctrine explanation")
	_expect(game._desk_context_anchor_for(game.campaign_map.button_for("rill_crossing")) == game.campaign_title, "route focus should anchor scrolling at the map heading instead of the generic desk guidance")
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	_expect(game.campaign_comparison_label.text.contains("RILL CROSSING · 1D · 1 FUEL · KNOWN · GUARDED 22% RISK"), "route comparison should update its risk band and value when doctrine changes before selection")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	_expect(game.campaign_commit_intel_label.visible and game.campaign_commit_intel_label.text.contains("KNOWN CONTACTS") and game.campaign_commit_intel_label.text.contains("Road Raider") and game.campaign_commit_intel_label.text.contains("PREPARE") and game.campaign_commit_intel_label.text.contains("repeater gun") and game.campaign_commit_intel_label.text.contains("READY NOW · Repeater Gun"), "route commitment should keep known contacts, their counters, and current chassis readiness adjacent to the final action")
	_expect(game.campaign_commit_intel_label.text.contains("DOCTRINE · RUN HOT") and game.campaign_commit_intel_label.text.contains("all attacks +1") and game.campaign_commit_intel_label.text.contains("heat +2"), "route commitment should restate the selected doctrine and its core tradeoff")
	_expect(game.doctrine_detail_label.text.begins_with("OVERHEAT WARNING") and game.campaign_map.commit_button.text.contains("HEAT 7/6"), "an overheating doctrine should expose predicted heat in the route commitment")
	_expect(game.encounter_label.text.contains("Rill Crossing selected") and game.encounter_label.text.contains("B/Esc cancels selection"), "the route-review status should name the road being considered and expose its controller-safe exit")
	_expect(game.route_preview_label.text.contains("ROUTE READY · RILL CROSSING") and not game.route_preview_label.text.contains("SOOT ORCHARD"), "route selection should replace stale focus intel with the road being committed")
	_expect(game.guidance_label.text.contains("B/Esc cancels selection"), "the route-ready current order should keep cancellation discoverable without a pointer tooltip")
	_expect(game.current_order_button.text == "GO TO COMMIT ↓", "a valid selected route should retarget the jump action to explicit commitment")
	_expect(game._desk_context_anchor_for(game.campaign_commit_button) == game.route_preview_label, "route confirmation should anchor scrolling at the selected-road summary")
	_expect(game.pause_button.text.contains("ROUTE REVIEW") and game.pause_button.tooltip_text.contains("clears the selected route first"), "the persistent pause action should disclose that B or Escape cancels route review before pausing")
	_expect(game.campaign_cancel_button.visible and game.campaign_cancel_button.text.contains("CANCEL") and game.campaign_cancel_button.text.contains("BACK TO MAP") and game.campaign_cancel_button.tooltip_text.contains("without spending fuel"), "route review should expose a compact pointer-accessible reversible exit beside Commit")
	game.campaign_cancel_button.pressed.emit()
	await process_frame
	_expect(game.selected_campaign_node_id.is_empty() and game.campaign_map.button_for("rill_crossing").has_focus() and game.event_label.text.contains("No fuel, time, or pressure was spent"), "the visible cancel action should return to the map and confirm that previewing had no cost")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	var route_cancel := InputEventJoypadButton.new()
	route_cancel.button_index = JOY_BUTTON_B
	route_cancel.pressed = true
	game._unhandled_input(route_cancel)
	await process_frame
	_expect(game.selected_campaign_node_id.is_empty() and game.campaign_map.button_for("rill_crossing").has_focus() and game.encounter_label.text.begins_with("ROUTE PLANNING"), "controller cancel should leave route preview without departing and restore route focus")
	_expect(game.pause_button.text.contains("ESC / B"), "cancelling route review should restore the ordinary pause shortcut hint")
	game.doctrine_option.select(0)
	game.doctrine_option.item_selected.emit(0)
	game._refresh_ui()
	var available_fuel: int = game.state.fuel
	game.state.fuel = 0
	game._refresh_ui()
	_expect(not game.campaign_map.button_for("rill_crossing").disabled, "a blocked fortress should still be able to inspect an available route")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	_expect(game.campaign_map.commit_button.disabled and game.campaign_map.commit_button.text.contains("NEED 1 FUEL"), "route commitment should explain an exact fuel shortfall")
	_expect(game.guidance_label.text.begins_with("DEPARTURE BLOCKED"), "the current order should explain why the selected route cannot begin")
	game.state.fuel = available_fuel
	var departure_coal_index: int = game.state._module_index_by_id("coal_cell")
	var departure_coal_durability: int = int(game.state.modules[departure_coal_index].get("durability", 0))
	game.state.modules[departure_coal_index]["durability"] = 0
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.campaign_map.commit_button.disabled and game.campaign_map.commit_button.text.contains("STEAM LANCE ENGINE WAS OFFLINE") and game.campaign_map.commit_button.text.contains("ENGINE HAS NO ADJACENT COAL CELL") and game.route_preview_label.text.contains("engine has no adjacent Coal Cell"), "an engine-blocked departure should name the exact system and missing dependency")
	game.state.modules[departure_coal_index]["durability"] = departure_coal_durability
	game.state._recalculate()
	game.selected_campaign_node_id = ""
	game._refresh_ui()
	game.campaign_map.button_for("rill_crossing").grab_focus()
	await process_frame
	_expect(game.route_preview_label.text.contains("ROUTE INTEL · RILL CROSSING") and game.route_preview_label.text.contains("Known route") and game.route_preview_label.text.contains("1 day") and not game.route_preview_label.text.contains("day(s)") and game.route_preview_label.text.contains("LOW risk") and game.route_preview_label.text.contains("Prepare:") and game.route_preview_label.text.contains("repeater gun") and game.route_preview_label.text.contains("Ready now: Repeater Gun"), "keyboard or controller focus should expose naturally phrased route intel, known counters, and current readiness above the map")
	_expect(game.route_preview_label.text.contains("Current risk factors: baseline 14%."), "known route intel should expose the baseline behind its displayed risk")
	_expect(game.route_preview_label.get_theme_color("font_color") == Color("#9fddbd"), "low-risk route intel should use the safe scan color while retaining its text label")
	game.campaign_map.button_for("soot_orchard").grab_focus()
	await process_frame
	_expect(game.route_preview_label.text.contains("GUARDED risk") and game.route_preview_label.get_theme_color("font_color") == Color("#e8c58e"), "guarded route intel should be visually distinct from a low-risk road")
	_expect(game.route_preview_label.text.contains("ready forecasting gear or Iven Pell") and game.route_preview_label.text.contains("reduces encounter pressure by 1"), "uncertain route intel should explain exactly how scouting improves it")
	_expect(game.route_preview_label.text.contains("baseline 22%") and game.route_preview_label.text.contains("heavy fortress +5pt, +1 fuel"), "route intel should explain how the current chassis changes visible risk and fuel costs")
	game.campaign_map.button_for("rill_crossing").grab_focus()
	await process_frame
	await _press_campaign_node("rill_crossing")
	await process_frame
	_expect(game.state.phase == "battle", "the first map choice should begin a road encounter")
	_expect(game.journey_label.text.contains("Ashgate Depot → Rill Crossing") and game.journey_label.text.contains("Encounter 1/5 underway") and not game.journey_label.text.contains("Encounter 0/5"), "the journey header should include the active road destination and count the first encounter rather than showing zero progress")
	_expect(game.campaign_pressure_label.text.contains("secured 0/5") and not game.campaign_pressure_label.text.contains("encounters 0/5"), "the blockade summary should identify its zero as secured encounters while the first battle is underway")
	_expect(game.advance_encounter_button.has_focus(), "committing a route should hand controller focus to the encounter timeline")
	_expect(game.current_order_button.text == "GO TO BATTLE STEP ↓", "battle entry should retarget the persistent jump action to the next timeline step")
	_expect(game.right_scroll.get_global_rect().encloses(game.advance_encounter_button.get_global_rect()), "battle focus should scroll encounter advancement into view")
	var battle_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	var battle_asset_rect: Rect2 = game.asset_row.get_global_rect()
	_expect(not battle_asset_rect.intersects(battle_viewport_rect) or battle_viewport_rect.encloses(battle_asset_rect), "battle focus should settle after layout changes without clipping the icon row")
	_expect(game.combat_panel.visible and game.combat_panel.step_panels.size() == 6, "battle state should expose the six-step encounter timeline")
	_expect(game.combat_panel.title_label.text.begins_with("CONTACT APPROACHING"), "the battle heading should distinguish a tracked approach from an enemy already in contact")
	_expect(game.combat_panel.enemy_panels[0].visible and game.combat_panel.enemy_names[0].text == "ROAD RAIDER", "battle state should expose a readable enemy card")
	_expect(game.combat_panel.step_labels[0].text == "NEXT · 1" and game.advance_encounter_button.text.contains("STEP 1 OF 6"), "combat controls should identify the exact next timeline step")
	_expect(game.combat_panel.enemy_states[0].text.contains("2 STEPS OUT") and game.guidance_label.text.contains("2 steps out"), "approaching enemies should use a live countdown before contact")
	_expect(not game.advance_warning_label.visible, "the advance action should not reserve warning space when the next step has no critical consequence")
	_expect(game.combat_panel.enemy_counters[0].text.contains("Seeks: cargo / exterior") and game.combat_panel.enemy_counters[0].text.contains("Protect Cargo active") and game.combat_panel.enemy_counters[0].text.contains("Counter:"), "enemy cards should expose targeting priorities, active doctrine protection, and counters without relying on a tooltip")
	_expect(game.combat_panel.order_label.text.contains("Emergency order: 1 available") and game.combat_panel.order_label.text.contains("Next step 1/6") and not game.combat_panel.order_label.text.contains("CP") and not game.combat_panel.order_label.text.contains("Step 0"), "combat status should describe the actual order budget and next timeline step without exposing internal counters")
	var battle_briefing_state: Dictionary = game.state.serialize()
	game.how_to_play_button.pressed.emit()
	await process_frame
	_expect(game.onboarding_step == 6 and game.onboarding_title_label.text == "Read the contact" and game.onboarding_body_label.text.contains("next hit"), "reopening Field Briefing during battle should land on contact-reading guidance")
	game._finish_onboarding(true)
	await process_frame
	await process_frame
	_expect(game.state.serialize() == battle_briefing_state and game.advance_encounter_button.has_focus(), "closing contextual battle guidance should return to the next authoritative step without advancing it")
	var initial_shift_preview: Dictionary = game.state.encounter_shift_power_preview()
	_expect(game.intervention_help_label.text.contains("NO TARGET ASSIGNED") and game.intervention_help_label.text.contains("remains available after Advance") and game.intervention_help_label.text.contains("Review CONTACT NEXT") and game.intervention_buttons[0].text.contains("heat %d→%d" % [int(initial_shift_preview.get("heat_before", 0)), int(initial_shift_preview.get("heat_after", 0))]), "the pre-contact order panel should explain that waiting preserves the order while pointing back to the arrival forecast")
	game.intervention_buttons[0].grab_focus()
	await process_frame
	await process_frame
	_expect(game.intervention_help_label.text.begins_with("SHIFT POWER") and game.intervention_help_label.text.contains("Heat %d→%d" % [int(initial_shift_preview.get("heat_before", 0)), int(initial_shift_preview.get("heat_after", 0))]), "focusing Shift Power should expose its exact heat and attack changes")
	_expect(game._desk_context_anchor_for(game.intervention_buttons[0]) == game.guidance_label, "emergency-order focus should retain the current battle order as its context anchor")
	_expect(game.desk_scroll_tail.custom_minimum_size.y >= 32.0 and game.desk_scroll_tail.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the desk should reserve non-interactive trailing room for clean lower-section focus")
	var order_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	var current_order_rect: Rect2 = game.guidance_label.get_global_rect()
	var order_title_rect: Rect2 = game.intervention_title.get_global_rect()
	var order_button_rect: Rect2 = game.intervention_buttons[0].get_global_rect()
	_expect(current_order_rect.position.y >= order_viewport_rect.position.y and current_order_rect.end.y <= order_viewport_rect.end.y and order_title_rect.position.y >= order_viewport_rect.position.y and order_title_rect.end.y <= order_viewport_rect.end.y and order_button_rect.position.y >= order_viewport_rect.position.y and order_button_rect.end.y <= order_viewport_rect.end.y, "focused emergency orders should reveal the current battle order, complete Encounter Order heading, and focused action together")
	game.advance_encounter_button.grab_focus()
	await process_frame
	_expect(game.intervention_help_label.text.contains("NO TARGET ASSIGNED") and game.intervention_help_label.text.contains("Focus or hover"), "leaving the emergency orders before contact should restore the timing-aware comparison prompt")
	_expect(game.intervention_buttons[3].text.contains("Coal Cell") and game.intervention_buttons[3].text.contains("fuel feed"), "cutting loose cargo should disclose the exact module and dependency cost before use")
	_expect(game.combat_inspect_button.visible and not game.combat_inspect_button.disabled and game.combat_inspect_button.text.contains("CHOOSE SEAL TARGET"), "battle controls should expose a controller path into chassis target selection")
	_expect(game.fortress_panel.interaction_heading().contains("Inspect Chassis chooses a seal target") and not game.fortress_panel.interaction_heading().contains("Edit Chassis"), "the passive battle chassis should describe the action that is actually available in this phase")
	_expect(game.fortress_panel.inspection_detail_heading() == "BATTLE SYSTEM" and game.fortress_panel.locked_mode_help_text().begins_with("TARGETING") and ThemeDB.fallback_font.get_string_size(game.fortress_panel.locked_mode_help_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x <= 320.0, "battle inspection detail copy should name its phase and fit the fixed status column")
	game.combat_inspect_button.pressed.emit()
	await process_frame
	_expect(game.fortress_panel.has_focus() and game.fortress_panel.interaction_heading().contains("CHASSIS INSPECTION") and not game.fortress_panel.interaction_heading().contains("EDIT MODE"), "the combat inspection action should enter a clearly named non-refit chassis mode")
	_expect(game.get_global_rect().encloses(game.pause_button.get_global_rect()), "battle chassis inspection should keep the fixed pointer-accessible Pause action visible")
	game.fortress_panel.cursor_cell = Vector2i(0, 1)
	var battle_chassis_select := InputEventAction.new()
	battle_chassis_select.action = "ui_accept"
	battle_chassis_select.pressed = true
	game.fortress_panel._gui_input(battle_chassis_select)
	await process_frame
	_expect(game.selected_module_id == "coal_cell" and game.intervention_buttons[1].has_focus() and game.intervention_buttons[1].text.contains("Coal Cell"), "selecting a combat system should return focus to the matching Seal order")
	var original_raider: Dictionary = game.state.encounter_enemies[0].duplicate(true)
	game.selected_module_id = "steam_lance_engine"
	game._sync_selected_module_context()
	game._select_module_option("steam_lance_engine")
	game.state.encounter_enemies[0]["arrived"] = true
	game.state.encounter_enemies[0]["target"] = "coal_cell"
	var coal_index: int = game.state._module_index_by_id("coal_cell")
	var coal_durability := int(game.state.modules[coal_index].get("durability", 0))
	var raider_damage_bonus := int(game.state.encounter_enemies[0].get("damage_bonus", 0))
	game.state.modules[coal_index]["durability"] = 1
	game.state.encounter_enemies[0]["damage_bonus"] = 1
	game._refresh_ui()
	_expect(game.combat_inspect_button.text.contains("INSPECT TARGET · COAL CELL") and game.selected_module_id == "coal_cell" and game.intervention_buttons[1].text.contains("Coal Cell"), "a newly active threat should become the default inspected and sealed system")
	_expect(not game.fortress_panel.hull_under_threat and "coal_cell" in game.fortress_panel.combat_target_ids, "a module-directed contact should highlight only its chassis target")
	game.intervention_buttons[1].grab_focus()
	await process_frame
	var displayed_seal_preview: Dictionary = game.state.encounter_seal_preview("coal_cell")
	var displayed_redirects: Array = displayed_seal_preview.get("retargets", [])
	var displayed_redirect_text: String = "%s → %s" % [String(displayed_redirects[0].get("enemy_name", "")), String(displayed_redirects[0].get("target_name", ""))] if not displayed_redirects.is_empty() else ""
	_expect(displayed_redirects.size() == 1 and game.intervention_help_label.text.begins_with("SEAL COMPARTMENT") and game.intervention_help_label.text.contains(displayed_redirect_text) and game.intervention_buttons[1].text.contains(displayed_redirect_text), "the only Seal order should preview its replacement target before commitment")
	_expect(game.guidance_label.text.contains("Coal Cell will be disabled") and game.guidance_label.text.contains("Steam Lance Engine → Offline") and game.guidance_label.text.contains("Review the emergency orders"), "the current order should promote a predicted dependency cascade before the player advances")
	_expect(game.advance_warning_label.visible and game.advance_warning_label.text.contains("Coal Cell will be disabled") and game.advance_warning_label.text.contains("Steam Lance Engine → Offline"), "a critical next-step consequence should remain adjacent to the Advance action")
	var pre_seal_state: Dictionary = game.state.serialize()
	game.intervention_buttons[1].pressed.emit()
	await process_frame
	var redirected_target := String(game.state.encounter_enemies[0].get("target", ""))
	var redirected_name := "Hull" if redirected_target == "hull" else String(game.state.module_definition(redirected_target).get("name", redirected_target))
	_expect(redirected_target != "coal_cell" and game.event_label.text.contains("redirected") and game.event_label.text.contains(redirected_name), "Seal should immediately disclose the threat's replacement target in its receipt")
	_expect(game.combat_panel.enemy_states[0].text.contains("TARGET · %s" % redirected_name.to_upper()) and not game.combat_panel.enemy_states[0].text.contains("TARGET · COAL CELL"), "enemy cards should replace the sealed target and its stale impact preview before the player advances")
	game.state.load_serialized(pre_seal_state)
	game.last_synced_combat_target_id = ""
	game._refresh_ui()
	var pre_cut_state: Dictionary = game.state.serialize()
	var exterior_target_id := ""
	for instance in game.state.modules:
		if bool(instance.get("exterior", false)):
			exterior_target_id = String(instance.get("id", ""))
			break
	game.state.encounter_enemies[0]["arrived"] = true
	game.state.encounter_enemies[0]["target"] = exterior_target_id
	game.last_synced_combat_target_id = ""
	game._refresh_ui()
	var displayed_vent_preview: Dictionary = game.state.encounter_vent_heat_preview()
	var displayed_vent_hits: Array = displayed_vent_preview.get("affected_hits", [])
	var displayed_vent_target := String(displayed_vent_hits[0].get("target_name", "")) if not displayed_vent_hits.is_empty() else ""
	game.intervention_buttons[2].grab_focus()
	await process_frame
	_expect(game.intervention_buttons[2].text.contains("-%d heat" % int(displayed_vent_preview.get("heat_removed", 0))) and game.intervention_help_label.text.begins_with("VENT HEAT") and game.intervention_help_label.text.contains(displayed_vent_target), "Vent Heat should preview its exact cooling and the exterior system exposed to extra damage")
	var sacrificed_cargo_id: String = game.state.sacrificable_cargo_id()
	game.state.encounter_enemies[0]["arrived"] = true
	game.state.encounter_enemies[0]["target"] = sacrificed_cargo_id
	game.last_synced_combat_target_id = ""
	game._refresh_ui()
	var displayed_cut_preview: Dictionary = game.state.encounter_cut_loose_preview()
	var displayed_cut_redirects: Array = displayed_cut_preview.get("retargets", [])
	var displayed_cut_text: String = "%s → %s" % [String(displayed_cut_redirects[0].get("enemy_name", "")), String(displayed_cut_redirects[0].get("target_name", ""))] if not displayed_cut_redirects.is_empty() else ""
	game.intervention_buttons[3].grab_focus()
	await process_frame
	_expect(game.intervention_help_label.text.begins_with("CUT LOOSE CARGO") and game.intervention_help_label.text.contains(displayed_cut_text), "the cargo-sacrifice order should preview its permanent loss and replacement target before commitment")
	game.intervention_buttons[3].pressed.emit()
	await process_frame
	var post_cut_target: String = String(game.state.encounter_enemies[0].get("target", ""))
	var post_cut_name: String = "Hull" if post_cut_target == "hull" else String(game.state.module_definition(post_cut_target).get("name", post_cut_target))
	_expect(post_cut_target != sacrificed_cargo_id and game.event_label.text.contains("redirected") and game.event_label.text.contains(post_cut_name), "cutting loose targeted cargo should immediately disclose where the threat redirects")
	_expect(game.combat_panel.enemy_states[0].text.contains("TARGET · %s" % post_cut_name.to_upper()), "enemy cards should immediately replace a discarded cargo target")
	game.state.load_serialized(pre_cut_state)
	game.last_synced_combat_target_id = ""
	game._refresh_ui()
	game.state.encounter_intervention_used = true
	game._refresh_ui()
	_expect(game.guidance_label.text.contains("No emergency order remains") and not game.guidance_label.text.contains("Review the emergency orders"), "critical guidance should stop recommending unavailable orders after the encounter budget is spent")
	game.state.encounter_intervention_used = false
	game.state.modules[coal_index]["durability"] = coal_durability
	game.state.encounter_enemies[0]["damage_bonus"] = raider_damage_bonus
	game.selected_module_id = "steam_lance_engine"
	game._sync_selected_module_context()
	game._select_module_option("steam_lance_engine")
	game._refresh_ui()
	_expect(game.selected_module_id == "steam_lance_engine" and game.intervention_buttons[1].text.contains("Steam Lance Engine"), "refreshing the same threat should preserve a deliberate alternate seal target")
	game.fortress_panel.cursor_cell = Vector2i(5, 3)
	game.combat_inspect_button.pressed.emit()
	await process_frame
	_expect(game.fortress_panel.cursor_cell == Vector2i(0, 1), "battle inspection should jump directly to the active target module")
	game.state.encounter_enemies[0] = original_raider
	game._refresh_ui()
	game.fortress_panel.grab_focus()
	var battle_chassis_cancel := InputEventAction.new()
	battle_chassis_cancel.action = "ui_cancel"
	battle_chassis_cancel.pressed = true
	game.fortress_panel._gui_input(battle_chassis_cancel)
	await process_frame
	_expect(game.combat_inspect_button.has_focus(), "B or Escape should return battle inspection focus to its visible desk action")
	game.advance_encounter_button.grab_focus()
	await process_frame
	_expect(game.advance_encounter_button.get_node_or_null(game.advance_encounter_button.focus_neighbor_bottom) == game.combat_inspect_button and game.combat_inspect_button.get_node_or_null(game.combat_inspect_button.focus_neighbor_bottom) == game.intervention_buttons[0] and game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_bottom) == game.current_order_button, "combat actions should form a visible vertical controller loop through chassis inspection and the persistent order jump")
	_expect(game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_next) == game.current_order_button and game.current_order_button.get_node_or_null(game.current_order_button.focus_next) == game.advance_encounter_button, "combat Tab navigation should remain inside the active command set while including the order jump")
	game.advance_encounter_button.pressed.emit()
	await process_frame
	_expect(game.combat_panel.enemy_states[0].text.contains("1 STEP OUT") and game.advance_encounter_button.text.contains("STEP 2 OF 6") and game.advance_encounter_button.text.contains("CONTACT NEXT · ROAD RAIDER") and game.combat_panel.order_label.text.contains("Next step 2/6") and game.combat_panel.step_labels[1].text == "CONTACT · 2", "the arrival countdown, timeline, combat status, and advance action should agree and warn before contact")
	_expect(game.combat_panel.causal_label.text.contains("Repeater Gun") and not game.combat_panel.causal_label.text.contains("repeater_gun"), "the visible causal report should use authored system names rather than internal content IDs")
	var target_card_preview: Dictionary = game.state.encounter_summary()
	var target_enemy: Dictionary = target_card_preview.enemies[0]
	target_enemy["arrived"] = true
	target_enemy["defeated"] = false
	target_enemy["target"] = "coal_cell"
	target_enemy["impact"] = {"damage": 1, "current_durability": 1, "remaining_durability": 0, "target_reason": "matches cargo, valuable cargo, damaged condition", "armor_absorbed": 1, "armor_id": "front_armor_plate", "armor_current_durability": 1, "armor_remaining_durability": 0, "dependency_changes": [{"module_id": "steam_lance_engine", "name": "Steam Lance Engine", "from": "ready", "to": "offline"}]}
	target_card_preview.enemies[0] = target_enemy
	target_card_preview["target_names"] = {"hull": "Hull", "coal_cell": "Coal Cell", "front_armor_plate": "Front Armor Plate"}
	game.combat_panel.configure(target_card_preview, game.state.ENCOUNTER_ENEMIES)
	_expect(game.combat_panel.title_label.text.begins_with("ACTIVE CONTACT"), "the battle heading should change when an undefeated enemy reaches the fortress")
	_expect(game.combat_panel.enemy_states[0].text.contains("TARGET · COAL CELL") and game.combat_panel.enemy_states[0].text.contains("WHY · MATCHES CARGO") and game.combat_panel.enemy_states[0].text.contains("VALUABLE CARGO") and game.combat_panel.enemy_states[0].text.contains("NEXT · 1 DAMAGE · 1→0 · DISABLES SYSTEM") and game.combat_panel.enemy_states[0].text.contains("ARMOR · FRONT ARMOR PLATE · 1→0 · BREAKS") and game.combat_panel.enemy_states[0].text.contains("CASCADE · STEAM LANCE ENGINE → OFFLINE") and not game.combat_panel.enemy_states[0].text.contains("coal_cell"), "contact cards should translate target IDs and expose target rationale, damage, armor, and downstream dependency consequences")
	target_enemy["target"] = "refugee_bunk"
	target_enemy["impact"] = {"damage": 0, "current_durability": 3, "remaining_durability": 3, "target_reason": "matches cargo, valuable cargo", "mara_effect": "refuge_bracing", "dependency_changes": []}
	target_card_preview.enemies[0] = target_enemy
	target_card_preview["target_names"] = {"hull": "Hull", "refugee_bunk": "Refugee Bunk"}
	game.combat_panel.configure(target_card_preview, game.state.ENCOUNTER_ENEMIES)
	_expect(game.combat_panel.enemy_states[0].text.contains("TARGET · REFUGEE BUNK") and game.combat_panel.enemy_states[0].text.contains("MARA · FORGE-CORE BRACING ABSORBS 1"), "the combat card should explain Mara's refuge mitigation before the hit lands")
	var pre_hull_preview_enemy: Dictionary = game.state.encounter_enemies[0].duplicate(true)
	var pre_hull_preview_condition: int = game.state.hull_condition
	game.state.encounter_enemies[0]["arrived"] = true
	game.state.encounter_enemies[0]["target"] = "hull"
	game.state.hull_condition = 1
	game._refresh_ui()
	game.intervention_buttons[1].grab_focus()
	await process_frame
	_expect(game.combat_inspect_button.text.contains("HULL EXPOSED") and game.intervention_help_label.text.contains("does not prevent the hull-directed hit"), "a hull-directed contact should explain that Seal cannot prevent its current attack")
	_expect(game.advance_warning_label.visible and game.advance_warning_label.text.contains("Hull collapse is predicted"), "a terminal hull forecast should be repeated beside the Advance action")
	_expect(game.fortress_panel.hull_under_threat and game.fortress_panel.combat_target_ids.is_empty(), "a hull-directed contact should mark the whole chassis instead of implying one module is targeted")
	game.state.hull_condition = pre_hull_preview_condition
	game.state.encounter_enemies[0] = pre_hull_preview_enemy
	game._refresh_ui()
	_expect(not game.fortress_panel.hull_under_threat, "the whole-chassis threat treatment should clear when the enemy resumes a module target")
	await _advance_until_phase("map")
	_expect(int(game.campaign_progress_bar.value) == 1, "the region progress bar should advance after a secured encounter")
	_expect(game.state.campaign_event_pending == "lift_chain_sings" and game.encounter_label.text.begins_with("DECISION REQUIRED · THE LIFT CHAIN SINGS"), "the first eligible seeded occurrence should replace the generic after-action prompt with one primary road decision")
	_expect(game.journey_label.text.contains("1/5 encounters secured"), "planning between roads should distinguish completed encounters from one currently underway")
	_expect(game.campaign_pressure_label.text.contains("secured 1/5"), "the blockade summary should agree with completed campaign progress between roads")
	_expect(game.campaign_map.status_for("rill_crossing") == "current" and game.campaign_map.status_for("ashgate_depot") == "secured", "the map should retain the secured route and move the current marker")
	_expect(game.campaign_map.status_for("soot_orchard") == "bypassed" and game.campaign_map.button_for("soot_orchard").text.contains("BYPASSED") and game.campaign_map.detail_for("soot_orchard").contains("cannot be revisited"), "the unchosen opening branch should be marked bypassed rather than presented as a future destination")
	await process_frame
	await process_frame
	_expect(game.campaign_event_title.text == "THE LIFT CHAIN SINGS" and game.campaign_event_buttons[0].text.contains("Ashmarks -6") and game.campaign_event_buttons[0].text.contains("Future route risk -2%") and game.campaign_event_buttons[1].text.contains("Ammunition Lift -1 durability"), "the seeded occurrence card should disclose both dependency tradeoffs before commitment")
	_expect(game.right_scroll.get_global_rect().encloses(game.campaign_event_title.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.campaign_event_buttons[1].get_global_rect()), "the complete occurrence card should stay visible at the reference viewport")
	_expect(game.current_order_button.text == "GO TO DECISION ↓", "a blocking road occurrence should retarget the jump action to its choice card")
	game.current_order_button.pressed.emit()
	await process_frame
	_expect(game.campaign_event_buttons[0].has_focus(), "Go to Decision should focus the first legal event response without choosing it")
	await _press_campaign_event("brace_lift_chain")
	_expect(game.state.occurrence_history.size() == 1 and game.event_label.text.contains("future route risk falls by 2%"), "resolving an occurrence should immediately expose its consequence and retain one audit record")
	_expect(game.campaign_map.button_for("red_wheel_toll_bridge").text.contains("UNSCOUTED · UNKNOWN"), "an available unscouted node should advertise uncertainty without exposing its hidden risk")
	game.campaign_map.button_for("red_wheel_toll_bridge").grab_focus()
	await process_frame
	_expect(game.route_preview_label.text.contains("Unscouted route") and game.route_preview_label.text.contains("unknown"), "focusing an unscouted road should preserve uncertainty in the visible route intel")
	_expect(game.route_preview_label.text.contains("ready forecasting gear or Iven Pell"), "an unscouted road should teach the player how to reveal its hidden information")
	_expect(game.route_preview_label.text.contains("Visible risk factors:") and game.route_preview_label.text.contains("blockade +"), "unscouted intel should expose player-created risk without revealing the hidden route baseline")
	_expect(game.route_preview_label.get_theme_color("font_color") == Color("#cbb8e8"), "unscouted route intel should carry a distinct unknown-information tone")
	var before_retreat: Dictionary = game.state.serialize()
	game.state.campaign_last_safe_node = "rill_crossing"
	game.state.campaign_target_node = "red_wheel_toll_bridge"
	game.state.current_location = "red_wheel_toll_bridge"
	game.state.phase = "battle"
	game.state.hull_condition = 0
	game.state.fuel = 0
	var retreat_result: Dictionary = game.state._campaign_recover_from_failure()
	game._refresh_ui()
	game.focus_current_action()
	await process_frame
	_expect(bool(retreat_result.get("ok", false)) and game.state.phase == "map", "a non-final loss should return the campaign to its last safe planning node")
	_expect(game.guidance_label.text.begins_with("RETREAT RECOVERED") and game.guidance_label.text.contains("patched movement chain"), "post-retreat guidance should acknowledge recovery before asking for another road")
	_expect(game.encounter_label.text.begins_with("AFTER-ACTION — FORCED RETREAT") and game.encounter_label.text.contains("Crew repair:"), "the retreat receipt should remain above the fold beside its next action")
	var retreat_focus_is_route := false
	var retreat_route_button: Button
	for route_button in game.campaign_node_buttons:
		if route_button.has_focus() and not route_button.disabled:
			retreat_focus_is_route = true
			retreat_route_button = route_button
			break
	_expect(retreat_focus_is_route, "forced-retreat recovery should hand controller focus to an available route")
	retreat_route_button.pressed.emit()
	await process_frame
	var retreat_route_id := String(retreat_route_button.get_meta("node_id", ""))
	var retreat_route_name := String(game.state.CAMPAIGN_NODES.get(retreat_route_id, {}).get("name", retreat_route_id))
	_expect(game.encounter_label.text.begins_with("ROUTE READY FOR REVIEW") and game.encounter_label.text.contains("%s selected" % retreat_route_name), "selecting a new road after retreat should replace the recovered after-action receipt with the current route review")
	game._unhandled_input(route_cancel)
	await process_frame
	_expect(game.encounter_label.text.begins_with("AFTER-ACTION — FORCED RETREAT"), "cancelling post-retreat route review should restore the unresolved recovery receipt")
	game.state.load_serialized(before_retreat)
	game._refresh_ui()
	game.campaign_map.button_for("red_wheel_toll_bridge").pressed.emit()
	await process_frame
	_expect(game.campaign_commit_button.text.contains("RISK UNKNOWN") and game.campaign_commit_button.text.contains("FUEL %d→%d" % [game.state.fuel, game.state.fuel - int(game.state.campaign_node_preview("red_wheel_toll_bridge", game._selected_id(game.doctrine_option)).get("fuel", 0))]) and not game.campaign_commit_button.text.contains("36%"), "selecting an unscouted road should show known resource balances without revealing hidden risk")
	_expect(game.campaign_commit_intel_label.visible and game.campaign_commit_intel_label.text.contains("BROAD WARNING") and game.campaign_commit_intel_label.text.contains("organized blockade") and game.campaign_commit_intel_label.text.contains("exact contacts are unknown"), "unscouted commitment should retain its broad warning without leaking hidden contacts")
	_expect(not game.route_preview_label.text.contains("Visible risk factors:") and not game.route_preview_label.text.contains("Intel upgrade:"), "selected-route confirmation should collapse optional scouting guidance to keep Commit adjacent to the map")
	var unknown_commit_style := game.campaign_commit_button.get_theme_stylebox("normal") as StyleBoxFlat
	_expect(unknown_commit_style != null and unknown_commit_style.border_color == Color("#cbb8e8"), "an unscouted commitment should use the same unknown-information tone as its intel")
	game._unhandled_input(route_cancel)
	await process_frame
	await _press_campaign_node("broken_relay")
	await _advance_until_phase("map")
	_expect(game.state.campaign_event_pending == "lost_signal", "the Broken Relay should surface its authored decision")
	_expect(game.encounter_label.text.begins_with("DECISION REQUIRED · THE SILENCE BETWEEN LAMPS") and game.encounter_label.text.contains("before the fortress can depart"), "an authored event should replace the previous after-action with its current blocking decision")
	_expect(game.fortress_panel.locked_mode_help_text().contains("refit at a road stop") and not game.fortress_panel.locked_mode_help_text().contains("TARGETING") and ThemeDB.fallback_font.get_string_size(game.fortress_panel.locked_mode_help_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x <= 320.0, "map-event chassis guidance should describe the refit lock and fit the fixed status column without battle language")
	_expect(game.campaign_map.status_for("morrowline_camp") == "blocked", "the map should show that a local decision blocks the next road")
	_expect(game.campaign_event_buttons[0].disabled and game.campaign_event_buttons[0].text.contains("REQUIRES AN OPERATIONAL SIGNAL SYSTEM"), "locked event choices should state their missing capability without requiring hover")
	_expect(game.campaign_event_buttons[0].text.contains("Exact forecasts") and game.campaign_event_buttons[0].text.contains("Pressure +1"), "a locked event choice should still teach its complete payoff and cost")
	_expect(game.campaign_event_buttons[1].text.contains("Pressure -1") and game.campaign_event_buttons[1].text.contains("Future risk -3%"), "an available event choice should disclose its exact consequence before commitment")
	await _press_campaign_event("move_silent")
	_expect(game.event_label.text.contains("pressure falls by 1") and game.event_label.text.contains("risk falls by 3%"), "event resolution should immediately explain its mechanical consequences")
	_expect(game.encounter_label.text.begins_with("DECISION CONSEQUENCE") and game.encounter_label.text.contains("risk falls by 3%"), "the event consequence should appear above the fold immediately after selection")
	_expect(game.recruit_iven_button.visible and game.recruit_iven_button.disabled and game.recruit_iven_button.text.contains("RELAY IS RESTORED"), "unavailable specialist recruitment should state its unmet requirement without hover")
	_expect(game.recruit_iven_button.text.contains("REVEAL CONTACTS") and game.recruit_iven_button.text.contains("ANTI-STORM DAMAGE +2"), "locked recruitment should still disclose Iven's exact route and combat benefits")
	_expect(game.campaign_map.status_for("morrowline_camp") == "available", "resolving the relay decision should activate Morrowline")
	await _press_campaign_node("morrowline_camp")
	await _advance_until_phase("settlement")
	await process_frame
	_expect(game.state.phase == "settlement" and game.state.campaign_encounters_completed == 3, "the third encounter should open Morrowline services")
	_expect(game.current_run_flow_step == 2 and game.run_flow_labels[2].text.contains("RECOVER"), "reaching Morrowline should advance the tracker to recovery")
	_expect(game.state.guard_contract_status == "completed", "the protected convoy should complete the guard contract")
	var mara_workshop_index: int = game.state._module_index_by_id("field_workshop")
	game.state.modules[mara_workshop_index]["durability"] = 1
	game.state._recalculate()
	game._refresh_ui()
	await process_frame
	_expect(game.state.campaign_event_pending == "mara_meeting" and game.campaign_event_title.text == "THE FORGE WITHOUT A ROOF", "Mara's meeting should interrupt Morrowline departure through the existing event card")
	game._show_onboarding(true)
	await process_frame
	_expect(game.onboarding_step == 3 and game.onboarding_title_label.text == "Keep repairs staffed", "Mara's settlement decision should reopen Field Briefing at the repair topic")
	game._finish_onboarding(true)
	await process_frame
	await process_frame
	_expect(game.campaign_event_buttons[0].text.contains("Workshop repairs +1") and game.campaign_event_buttons[1].text.contains("Keep specialist berth open"), "Mara's recruitment choice should expose both its mechanical benefit and opportunity cost")
	await _press_campaign_event("recruit_mara")
	await process_frame
	await process_frame
	_expect(game.state.specialist_id == "mara_flint" and game.state.campaign_event_pending == "mara_workbench_choice", "recruiting Mara should visibly advance to her one-core decision")
	_expect(game.encounter_label.text.begins_with("DECISION CONTINUES · ONE SOUND CORE") and game.campaign_event_buttons[0].text.contains("Rebuild Field Workshop") and game.campaign_event_buttons[0].text.contains("Day +1") and game.campaign_event_buttons[1].text.contains("damage -1 per hit"), "the workbench card should identify the deterministic repair target and complete tradeoffs")
	_expect(game.right_scroll.get_global_rect().encloses(game.campaign_event_title.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.campaign_event_buttons[1].get_global_rect()), "a chained event should scroll its title and both choices into the visible command desk")
	await _press_campaign_event("rebuild_weakest")
	_expect(game.state.campaign_event_pending.is_empty() and int(game.state.modules[mara_workshop_index].durability) == 3 and game.campaign_path_label.text.contains("Specialist: Mara Flint"), "choosing machine recovery should repair the workshop, clear the blocking event, and retain Mara in the campaign status")
	_expect(game.settlement_title.text.contains("2 ACTIONS LEFT"), "the settlement should expose its limited service budget")
	_expect(game.current_order_button.text == "GO TO RECOVERY ↓", "clearing the settlement event should retarget the jump action to available recovery services")
	game.current_order_button.pressed.emit()
	await process_frame
	_expect(game.get_viewport().gui_get_focus_owner() in [game.settlement_repair_button, game.settlement_refuel_button, game.settlement_hull_button], "Go to Recovery should focus the first legal service without spending an action")
	_expect(game.guidance_label.text.contains("2 service actions remain") and game.route_preview_label.text.contains("2 service actions remain"), "Morrowline guidance should state the plural service budget consistently")
	_expect(game.settlement_group.get_index() < game.doctrine_group.get_index(), "Morrowline should place its primary recovery actions before optional doctrine and chassis controls")
	_expect(game.settlement_refuel_button.text.contains("FUEL %d→%d" % [game.state.fuel, game.state.fuel + 2]) and game.settlement_refuel_button.text.contains("ACTIONS 2→1"), "refueling should preview both the resource change and shared service budget before purchase")
	if game.state.hull_condition < 10:
		_expect(game.settlement_hull_button.text.contains("HULL %d→%d" % [game.state.hull_condition, mini(10, game.state.hull_condition + 2)]) and game.settlement_hull_button.text.contains("ACTIONS 2→1"), "hull repair should preview both restoration and shared service budget before purchase")
	else:
		_expect(game.settlement_hull_button.text.contains("HULL · FULL"), "full hull should remain a clear disabled service state")
	var mara_crew_index: int = game.state._module_index_by_id("crew_quarters")
	var mara_crew_before: int = int(game.state.modules[mara_crew_index].get("durability", 0))
	game.state.modules[mara_crew_index]["durability"] = 1
	game.selected_module_id = "crew_quarters"
	game._select_module_option("crew_quarters")
	game._sync_selected_module_context()
	game._refresh_ui()
	_expect(game.settlement_repair_button.text.contains("REPAIR CREW QUARTERS +3") and game.settlement_repair_button.text.contains("8 ASHMARKS · MARA +1") and game.settlement_repair_button.text.contains("DURABILITY 1→4"), "Mara's settlement service preview should show the extra free durability and unchanged price before commitment")
	game.state.modules[mara_crew_index]["durability"] = mara_crew_before
	game.selected_module_id = "steam_lance_engine"
	game._select_module_option("steam_lance_engine")
	game._sync_selected_module_context()
	game._refresh_ui()
	var handoff_money: int = game.state.money
	var handoff_actions: int = game.state.settlement_actions_remaining
	game.settlement_routes_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(game.get_viewport().gui_get_focus_owner() in game.campaign_node_buttons and game.selected_campaign_node_id.is_empty(), "Review Next Roads should move focus to route selection without choosing a road for the player")
	var focused_route_rect: Rect2 = game.get_viewport().gui_get_focus_owner().get_global_rect()
	var recovery_route_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	_expect(focused_route_rect.position.y >= recovery_route_viewport_rect.position.y and focused_route_rect.end.y <= recovery_route_viewport_rect.end.y, "the recovery handoff should scroll its focused route fully into the visible command desk")
	_expect(game.state.money == handoff_money and game.state.settlement_actions_remaining == handoff_actions and game.event_label.text.contains("no service action has been spent"), "the recovery handoff should preserve resources and explicitly state its no-cost semantics")
	game.campaign_map.button_for("lower_ash_road").pressed.emit()
	await process_frame
	_expect(game.campaign_commit_intel_label.text.contains("UNUSED RECOVERY · 2 service actions remain") and game.campaign_commit_intel_label.text.contains("Departing ends access"), "route commitment should warn before both unused Morrowline services become inaccessible")
	game.selected_campaign_node_id = ""
	game._refresh_ui()
	game.settlement_refuel_button.grab_focus()
	_expect(game.settlement_repair_button.disabled and game.settlement_repair_button.text.contains("ALL SYSTEMS FULL"), "a settlement with no damage should explain why repair is unavailable")
	_expect(game.settlement_refuel_button.has_focus(), "settlement focus should skip unavailable services and land on the first viable action")
	var recovery_previous := game.settlement_refuel_button.get_node_or_null(game.settlement_refuel_button.focus_previous) as BaseButton
	_expect(recovery_previous != null and recovery_previous != game.settlement_repair_button and not recovery_previous.disabled, "settlement Tab navigation should skip the unavailable repair action while retaining refit controls")
	var recovery_next := game.settlement_refuel_button.get_node_or_null(game.settlement_refuel_button.focus_next) as BaseButton
	_expect(recovery_next != null and not recovery_next.disabled, "settlement navigation should lead only to an enabled recovery or route action")
	game.selected_module_id = "steam_lance_engine"
	game._select_module_option("steam_lance_engine")
	game._sync_selected_module_context()
	var damaged_workshop_index: int = game.state._module_index_by_id("field_workshop")
	var workshop_before: int = int(game.state.modules[damaged_workshop_index].get("durability", 0))
	game.state.modules[damaged_workshop_index]["durability"] = 1
	game.state._recalculate()
	game._refresh_ui()
	_expect(not game.settlement_repair_button.disabled and game.settlement_repair_button.text.contains("REVIEW FIELD WORKSHOP") and game.settlement_repair_button.text.contains("1/3") and game.settlement_repair_button.text.contains("NO COST · PRESS AGAIN TO REPAIR"), "repair should offer a clearly reversible inspection handoff to the most damaged system when the current selection is already full")
	var actions_before_repair_selection: int = game.state.settlement_actions_remaining
	game.settlement_repair_button.pressed.emit()
	await process_frame
	_expect(game.selected_module_id == "field_workshop" and game.settlement_repair_button.has_focus() and game.settlement_repair_button.text.contains("REPAIR FIELD WORKSHOP +2") and game.settlement_repair_button.text.contains("DURABILITY 1→3") and game.settlement_repair_button.text.contains("ACTIONS 2→1") and game.state.settlement_actions_remaining == actions_before_repair_selection, "selecting the recommended repair target should reveal its exact durability and action-budget consequences without spending an action")
	_expect(game.refit_label.text.contains("Damaged · 1/3 durability · strained") and game.fortress_panel.selected_system_state_text().contains("Strained · damaged 1/3"), "a damaged operational module should disclose its condition alongside its dependency state instead of appearing fully healthy")
	game.state.modules[damaged_workshop_index]["durability"] = workshop_before
	game.state._recalculate()
	game._refresh_ui()
	var recovery_money: int = game.state.money
	var recovery_hull: int = game.state.hull_condition
	var recovery_actions: int = game.state.settlement_actions_remaining
	game.state.money = 3
	game.state.hull_condition = 9
	game._refresh_ui()
	_expect(game.settlement_refuel_button.disabled and game.settlement_refuel_button.text.contains("HAVE 3 ASHMARKS"), "an unaffordable fuel service should name the player's current funds")
	_expect(game.settlement_hull_button.disabled and game.settlement_hull_button.text.contains("REPAIR +1 HULL") and game.settlement_hull_button.text.contains("HAVE 3 ASHMARKS"), "an unaffordable near-full hull service should name both its exact benefit and the player's current funds")
	game.state.money = recovery_money
	game.state.settlement_actions_remaining = 0
	game._refresh_ui()
	_expect(game.settlement_repair_button.text.contains("NO SERVICE ACTIONS LEFT") and game.settlement_refuel_button.text.contains("NO SERVICE ACTIONS LEFT") and game.settlement_hull_button.text.contains("NO SERVICE ACTIONS LEFT"), "exhausted recovery services should state the shared action-budget blocker")
	_expect(game.guidance_label.text.contains("0 service actions remain") and not game.guidance_label.text.contains("actions remains"), "exhausted recovery guidance should retain correct plural grammar")
	game.campaign_map.button_for("lower_ash_road").pressed.emit()
	await process_frame
	_expect(not game.campaign_commit_intel_label.text.contains("UNUSED RECOVERY"), "route commitment should not show a forfeiture warning after every service has been spent")
	game.selected_campaign_node_id = ""
	game.state.hull_condition = recovery_hull
	game.state.settlement_actions_remaining = recovery_actions
	game._refresh_ui()
	_expect(game.campaign_map.status_for("dry_cistern_cut") == "locked", "Morrowline should keep Dry Cistern Cut visible when the Water Condenser requirement is unmet")
	_expect(game.campaign_map.detail_for("dry_cistern_cut").contains("Ready Water Condenser") and game.campaign_map.detail_for("dry_cistern_cut").contains("Field Workshop"), "the locked dry road should explain the exact system and maintenance requirement")
	_expect(game.campaign_map._preview_tooltip({"visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.28, "pressure_gain": 1, "threat_hint": "dry weather line", "fuel_discount": 1}).contains("Water Condenser saves 1 fuel"), "an unlocked dry-road preview should explain why its displayed fuel cost is reduced")
	var saved_pressure: int = game.state.campaign_pressure
	game.state.campaign_pressure = 5
	game._refresh_ui()
	_expect(game.campaign_map.status_for("signal_causeway") == "closed" and game.campaign_map.status_for("lower_ash_road") == "available", "the visual map should show Break closing only the optional causeway")
	_expect(game.campaign_map.detail_for("signal_causeway").contains("Ready forecasting gear or Iven Pell"), "a closed route should name both ways to restore access")
	_expect(game.campaign_pressure_label.text.contains("Signal Causeway is closed") and game.campaign_pressure_label.text.contains("can reopen it"), "Break pressure should explain the live closure and both recovery paths")
	game.state.campaign_pressure = saved_pressure
	game._refresh_ui()
	var saved_money: int = game.state.money
	game.save_button.pressed.emit()
	await process_frame
	_expect(not game.load_button.disabled, "saving should immediately enable the visible load control")
	game.state.money = 1
	game.load_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "settlement" and game.state.money == saved_money, "JSON save/load should restore settlement state")
	game.settlement_refuel_button.pressed.emit()
	await process_frame
	_expect(game.state.settlement_actions_remaining == 1, "settlement service should consume one action")
	_expect(game.settlement_title.text.contains("1 ACTION LEFT"), "the service budget should update immediately after use")
	_expect(game.encounter_label.text.begins_with("SERVICE COMPLETE") and game.encounter_label.text.contains("+2 fuel") and game.encounter_label.text.contains("1 service action remains"), "settlement services should report cost, effect, and remaining budget above the fold")
	game._refresh_ui()
	_expect(game.encounter_label.text.begins_with("MORROWLINE RECOVERY") and game.encounter_label.text.contains("1 service action remains") and not game.encounter_label.text.contains("up to two"), "ordinary recovery refreshes should retain the live remaining service budget")
	game.campaign_map.button_for("lower_ash_road").pressed.emit()
	await process_frame
	var high_risk_commit_style := game.campaign_commit_button.get_theme_stylebox("normal") as StyleBoxFlat
	_expect(game.campaign_commit_button.text.contains("HIGH RISK") and high_risk_commit_style != null and high_risk_commit_style.border_color == Color("#ef8375"), "a known high-risk commitment should carry the danger treatment before departure")
	_expect(game.campaign_commit_intel_label.text.contains("UNUSED RECOVERY · 1 service action remains") and not game.campaign_commit_intel_label.text.contains("1 service actions"), "the final Morrowline departure warning should use the live singular service budget")
	game.campaign_commit_button.pressed.emit()
	await process_frame
	_expect(game.current_run_flow_step == 3 and game.run_flow_labels[3].text.contains("FINAL"), "leaving Morrowline should advance the tracker to the final approach")
	await _advance_until_phase("map")
	_expect(game.state.campaign_encounters_completed == 4, "the lower-hull route should become the fourth encounter")
	_expect(game.state.campaign_event_pending == "mara_followup" and game.campaign_event_title.text == "WHAT HELD", "the fourth road should surface Mara's later callback before Meridian Pass")
	var mara_followup_choice := String(game.campaign_event_buttons[0].get_meta("choice_id", ""))
	_expect(mara_followup_choice in ["record_repair_held", "record_repair_failed"] and game.campaign_event_buttons[0].text.to_upper().contains("PRESSURE"), "Mara's callback should preview whether the repaired system earned pressure recovery")
	await _press_campaign_event(mara_followup_choice)
	_expect(game.state.campaign_event_pending.is_empty(), "acknowledging Mara's callback should reopen final route selection")
	game.campaign_map.button_for("meridian_pass").pressed.emit()
	await process_frame
	await process_frame
	_expect(game.campaign_commit_button.text.begins_with("FINAL COMMIT · MERIDIAN PASS") and game.campaign_commit_button.text.contains("FUEL %d→" % game.state.fuel) and game.route_preview_label.text.contains("FINAL COMMITMENT") and game.route_preview_label.text.contains("no retreat"), "Meridian Pass selection should expose resulting resources and its run-ending stakes before commitment")
	_expect(game.encounter_label.text.begins_with("ROUTE READY FOR REVIEW") and game.encounter_label.text.contains("failure ends the run") and game.encounter_label.text.contains("no retreat") and game.guidance_label.text.begins_with("FINAL COMMITMENT"), "the final road's terminal stakes should remain visible outside the scrollable map details")
	game.campaign_commit_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "final_battle", "the fifth map node should begin the final battle")
	await _advance_until_phase("results")
	await process_frame
	await process_frame
	_expect(game.state.phase == "results" and game.state.run_complete and game.state.campaign_encounters_completed == 5, "the five-encounter campaign should produce a completed run")
	_expect(game.current_run_flow_step == 4 and game.run_flow_labels[4].text.contains("RESULT"), "the completed run should finish the stage tracker")
	_expect(game.results_group.visible and game.results_inspect_button.visible and game.march_on_button.visible and game.play_again_button.visible and game.results_title_button.visible and not game.journey_banner.visible, "results should expose final chassis review and follow-up actions while retiring the completed journey's decorative banner")
	_expect(game.results_heading.text == "MARCH DEBRIEF" and game.guidance_label.text.begins_with("DEBRIEF"), "the result frame should remain neutral enough to describe both successful crossings and terminal failures")
	_expect(game.results_inspect_button.has_focus() and game.current_order_button.text == "GO TO CHASSIS REVIEW ↓" and game.current_order_button.get_node_or_null(game.current_order_button.focus_neighbor_bottom) == game.results_inspect_button, "a newly opened debrief should focus and name final chassis review before asking for feedback")
	_expect(game.right_scroll.get_global_rect().encloses(game.results_heading.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.results_inspect_button.get_global_rect()), "debrief arrival should reset inherited battle scrolling and keep both the outcome heading and first action visible")
	_expect(game.fortress_panel.interaction_heading().contains("Inspect Final Chassis reviews survivors") and not game.fortress_panel.interaction_heading().contains("Edit Chassis"), "the passive result chassis should describe debrief review instead of an unavailable refit action")
	game.current_order_button.pressed.emit()
	await process_frame
	_expect(game.results_inspect_button.has_focus(), "Go to Chassis Review should focus the debrief's first interpretation action without opening it")
	game.results_inspect_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(game.fortress_panel.has_focus() and game.fortress_panel.interaction_heading().contains("CHASSIS REVIEW") and game.fortress_panel.inspection_detail_heading() == "FINAL SYSTEM" and game.fortress_panel.locked_mode_help_text().begins_with("REVIEW") and ThemeDB.fallback_font.get_string_size(game.fortress_panel.locked_mode_help_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x <= 320.0 and game.fortress_panel.tooltip_text.contains("returns to the debrief") and game.current_order_button.text == "GO TO FEEDBACK ↓" and game.guidance_label.text.contains("Final chassis reviewed"), "Inspect Final Chassis should enter a fitted result-specific review mode and advance the debrief handoff toward feedback")
	_expect(game.get_global_rect().encloses(game.pause_button.get_global_rect()) and game.left_scroll.get_global_rect().encloses(game.fortress_panel.get_global_rect()), "active final chassis review should keep both the fixed Pause action and complete inspector visible at 720p")
	var result_chassis_select := InputEventAction.new()
	result_chassis_select.action = "ui_accept"
	result_chassis_select.pressed = true
	game.fortress_panel._gui_input(result_chassis_select)
	await process_frame
	_expect(game.fortress_panel.has_focus() and game.event_label.text.contains("in the final chassis"), "selecting a result system should update its inspection context without leaving chassis review")
	var result_chassis_cancel := InputEventAction.new()
	result_chassis_cancel.action = "ui_cancel"
	result_chassis_cancel.pressed = true
	game.fortress_panel._gui_input(result_chassis_cancel)
	await process_frame
	_expect(game.results_inspect_button.has_focus(), "B or Escape should return final chassis review to its visible debrief action")
	game.current_order_button.pressed.emit()
	await process_frame
	_expect(game.feedback_button.has_focus(), "Go to Feedback should focus the debrief's primary follow-up without opening it")
	_expect(game.results_title_button.text == "SAVE RESULT & RETURN", "the result screen should make persistence explicit before leaving the completed run")
	_expect(game.results_summary_label.text.begins_with("SCARRED MARCH") and game.results_summary_label.text.contains("7 required"), "the result should explain the missed decisive threshold")
	_expect(game.results_record_label.text.contains("Rill Crossing") and game.results_record_label.text.contains("Meridian Pass") and game.results_record_label.text.contains("Blockade:") and game.results_record_label.text.contains("Contract:") and game.results_record_label.text.contains("Key decisions: Broken Relay — moved silently") and game.results_record_label.text.contains("Mara Flint — rebuilt Field Workshop") and game.results_record_label.text.contains("Road occurrence — The Lift Chain Sings: Brace Lift Chain") and game.results_record_label.text.contains("Morrowline recovery: 1 service action left unused") and game.results_record_label.text.contains("Final doctrine:") and game.results_record_label.text.contains("Systems:") and game.results_record_label.text.contains("Damage:"), "the debrief card should retain the path, Mara's causal outcome, occurrence record, authored decisions, unused recovery, doctrine, and named operating condition needed to interpret the run")
	_expect(game.results_replay_label.text.begins_with("NEXT RUN") and game.results_replay_label.text.contains("1 Morrowline service action went unused") and game.results_replay_label.text.contains("spend it on hull or armor"), "a hull-shortfall result should turn unused recovery into a concrete replay lesson")
	var completed_path: Array[String] = game.state.campaign_path.duplicate()
	var completed_encounters: int = game.state.campaign_encounters_completed
	var completed_hull: int = game.state.hull_condition
	var completed_services: int = game.state.settlement_actions_remaining
	var completed_result: String = game.state.final_result
	var completed_outcome: String = game.state.encounter_outcome
	var completed_enemies: Array[Dictionary] = []
	for completed_enemy in game.state.encounter_enemies:
		completed_enemies.append(completed_enemy.duplicate(true))
	game.state.hull_condition = 8
	game.state.final_result = "scarred_march"
	game.state.encounter_enemies[0]["defeated"] = false
	game.state.encounter_enemies[0]["hp"] = 2
	for enemy_index in range(1, game.state.encounter_enemies.size()):
		game.state.encounter_enemies[enemy_index]["defeated"] = true
		game.state.encounter_enemies[enemy_index]["hp"] = 0
	game._refresh_ui()
	_expect(game.results_summary_label.text.contains("1 final contact remained") and not game.results_summary_label.text.contains("convoy contract failed"), "scarred results should name only thresholds that actually determine the outcome")
	_expect(game.results_replay_label.text.contains("CONTACTS FIRST") and game.results_replay_label.text.contains("Siege Beast") and game.results_replay_label.text.contains("shell cannon and front armor"), "a contact-only scarred result should recommend the authored counter for the surviving threat")
	game.state.final_result = "decisive_march"
	game.state.settlement_actions_remaining = 0
	game.state.guard_contract_status = "declined"
	for enemy in game.state.encounter_enemies:
		enemy["defeated"] = true
		enemy["hp"] = 0
	game._refresh_ui()
	_expect(game.results_summary_label.text.contains("travelled without the guard contract") and not game.results_summary_label.text.contains("contract survived"), "a decisive result should describe a declined contract accurately rather than treating it as a victory condition")
	_expect(game.results_record_label.text.contains("RUN RECORD · ASH-1107") and game.results_record_label.text.contains("Morrowline recovery: all service actions spent"), "the debrief should retain the reproducible run identity and distinguish fully used recovery from services left behind")
	game.state.guard_contract_status = "completed"
	game.state.settlement_actions_remaining = completed_services
	game.state.encounter_enemies = completed_enemies
	game.state.campaign_path.pop_back()
	game.state.campaign_encounters_completed = 4
	game.state.final_result = "march_failed"
	game.state.encounter_outcome = "march_failed"
	game.state.hull_condition = 0
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.results_heading.text == "MARCH DEBRIEF" and game.guidance_label.text.begins_with("DEBRIEF"), "a failed final road should still open a debrief rather than present a success-coded completion heading")
	_expect(game.results_summary_label.text.contains("hull reached zero"), "a hull failure should name the exact terminal cause")
	_expect(game.results_replay_label.text.contains("HULL FIRST") and game.results_replay_label.text.contains("Morrowline service"), "a hull failure should recommend a matching next-run adjustment")
	_expect(game.results_record_label.text.contains("Stopped at: Meridian Pass") and game.results_record_label.text.contains("4/5 encounters secured"), "a failed final road should remain visible beside the secured path")
	_expect(game.run_flow_labels[3].text.begins_with("×") and game.run_flow_labels[4].text.contains("RESULT"), "a terminal Meridian failure should mark the final stage as failed instead of completed")
	var failed_engine_index: int = game.state._module_index_by_id("steam_lance_engine")
	var failed_engine_before: int = int(game.state.modules[failed_engine_index].get("durability", 0))
	game.state.hull_condition = 6
	game.state.modules[failed_engine_index]["durability"] = 0
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.results_summary_label.text.contains("Steam Lance Engine reached 0/4 durability"), "a movement failure should identify the disabled engine and its condition")
	_expect(game.results_replay_label.text.contains("MOVEMENT FIRST") and game.results_replay_label.text.contains("Repair Steam Lance Engine"), "an engine failure should recommend repairing the system that ended the run")
	_expect(game.results_record_label.text.contains("Damage: Steam Lance Engine 0/4") and game.results_record_label.text.contains("Unavailable: Steam Lance Engine"), "the run record should name the damaged and unavailable system instead of reporting only aggregate counts")
	game.state.campaign_path = completed_path
	game.state.campaign_encounters_completed = completed_encounters
	game.state.hull_condition = completed_hull
	game.state.modules[failed_engine_index]["durability"] = failed_engine_before
	game.state.final_result = completed_result
	game.state.encounter_outcome = completed_outcome
	game.state.encounter_enemies = completed_enemies
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.feedback_button.has_focus(), "the completed run should hand controller focus to playtest feedback")
	_expect(game.feedback_button.get_node_or_null(game.feedback_button.focus_neighbor_bottom) == game.march_on_button and game.march_on_button.get_node_or_null(game.march_on_button.focus_neighbor_bottom) == game.play_again_button and game.play_again_button.get_node_or_null(game.play_again_button.focus_neighbor_right) == game.results_title_button, "the result actions should follow their visible controller layout")
	_expect(game.results_title_button.get_node_or_null(game.results_title_button.focus_next) == game.current_order_button and game.current_order_button.get_node_or_null(game.current_order_button.focus_next) == game.results_inspect_button and game.results_inspect_button.get_node_or_null(game.results_inspect_button.focus_next) == game.feedback_button and game.feedback_button.get_node_or_null(game.feedback_button.focus_previous) == game.results_inspect_button, "the result actions should form a closed Tab cycle through the order jump and final chassis review")
	game.march_on_button.grab_focus()
	await process_frame
	await process_frame
	await process_frame
	_expect(game.right_scroll.get_global_rect().encloses(game.march_on_button.get_global_rect()), "focusing March On should scroll its full destination label into the 720p desk viewport")
	game.feedback_button.grab_focus()
	game.feedback_button.pressed.emit()
	await process_frame
	var feedback_panel := game.feedback_overlay.find_child("FeedbackPanel", true, false) as PanelContainer
	var feedback_surface := feedback_panel.get_theme_stylebox("panel") as StyleBoxFlat if feedback_panel != null else null
	_expect(feedback_panel != null and feedback_surface != null and feedback_surface.bg_color.a > 0.95 and feedback_surface.border_width_left == 2, "the feedback form should use an opaque bordered modal surface over the completed run")
	await process_frame
	_expect(game.feedback_overlay.visible, "the final screen should provide an accessible feedback form")
	_expect(game.feedback_close_button.text == "BACK TO RESULTS" and game.feedback_save_button.text == "SAVE NOTES LOCALLY" and not game.feedback_path_button.visible, "the unsaved feedback form should expose clear local-only actions without promising a report path yet")
	_expect(game.feedback_context_label.text.contains("ASHGATE LOWLANDS") and game.feedback_context_label.text.contains("Results"), "result notes should retain the completed run context")
	_expect(game.feedback_status_label.text == "Nothing is sent automatically. Save a local copy when you are ready.", "the untouched feedback form should use a first-save prompt rather than implying that notes were already saved")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_neighbor_left) == game.feedback_close_button, "the feedback actions should have explicit horizontal controller navigation")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_next) == game.feedback_clear_text and game.feedback_clear_text.get_node_or_null(game.feedback_clear_text.focus_previous) == game.feedback_save_button, "the feedback form should trap Tab navigation across fields and actions")
	game.feedback_clear_text.text = "The route consequences were clear."
	game.feedback_confusing_text.text = "The final repair tradeoff needs another run."
	game.feedback_score_option.select(3)
	game.feedback_save_button.pressed.emit()
	await process_frame
	_expect(not game.last_feedback_path.is_empty() and FileAccess.file_exists(game.last_feedback_path), "saving feedback should create a local bundle")
	var feedback_bundle = JSON.parse_string(FileAccess.get_file_as_string(game.last_feedback_path))
	var feedback_final_state: Dictionary = feedback_bundle.get("final_state", {}) if feedback_bundle is Dictionary else {}
	_expect(feedback_final_state.get("campaign_path", []).size() == 6 and String(feedback_final_state.get("campaign_decisions", {}).get("lost_signal", "")) == "move_silent" and int(feedback_final_state.get("unused_recovery_actions", -1)) == completed_services, "local feedback should retain the path, authored decisions, and unused recovery behind the tester's notes")
	_expect(String(feedback_final_state.get("run_code", "")) == "ASH-1107" and int(feedback_final_state.get("seed", -1)) == 1107, "local feedback should include the same visible run identity and authoritative seed used by the deterministic simulation")
	_expect(game.feedback_status_label.text.begins_with("SAVED LOCALLY") and game.feedback_status_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))) and game.feedback_save_button.text == "SAVE AGAIN" and game.feedback_save_button.has_focus(), "saved feedback should provide a clear versioned receipt and repeat action")
	_expect(game.feedback_path_button.visible and not game.feedback_path_button.disabled and game.feedback_path_button.tooltip_text == game.last_feedback_path, "a saved report should expose its complete path through a controller-accessible receipt action")
	_expect(game.feedback_close_button.get_node_or_null(game.feedback_close_button.focus_neighbor_right) == game.feedback_path_button and game.feedback_path_button.get_node_or_null(game.feedback_path_button.focus_neighbor_right) == game.feedback_save_button and game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_neighbor_left) == game.feedback_path_button, "the saved-report action row should follow its visible controller order")
	game.feedback_path_button.pressed.emit()
	await process_frame
	_expect(game.feedback_status_label.text.begins_with("REPORT PATH COPIED") and game.feedback_status_label.text.contains(game.last_feedback_path.get_file()) and game.feedback_path_button.has_focus(), "copying the report path should produce a visible receipt and preserve action focus")
	game._hide_feedback()
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_status_label.text.begins_with("LAST SAVED LOCALLY") and game.feedback_save_button.text == "SAVE AGAIN" and game.feedback_path_button.visible, "reopening feedback should preserve the previous local-save receipt and path action")
	DirAccess.remove_absolute(game.last_feedback_path)
	game.feedback_path_button.pressed.emit()
	await process_frame
	_expect(game.last_feedback_path.is_empty() and not game.feedback_path_button.visible and game.feedback_save_button.has_focus() and game.feedback_status_label.text.contains("no longer available"), "a missing exported report should remove the stale path action and direct the tester to save again")
	var controller_cancel := InputEventJoypadButton.new()
	controller_cancel.button_index = JOY_BUTTON_B
	controller_cancel.pressed = true
	game._unhandled_input(controller_cancel)
	await process_frame
	_expect(not game.feedback_overlay.visible and game.feedback_button.has_focus(), "controller cancel should close the feedback modal and restore result focus")
	_expect(FileAccess.file_exists(journal_path), "the UI flow should leave a local-only playtest journal")
	game.results_title_button.pressed.emit()
	await process_frame
	_expect(return_to_title_requested, "the completed stage should be able to request the application title")
	var result_save = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	_expect(result_save is Dictionary and String(result_save.get("phase", "")) == "results" and String(result_save.get("final_result", "")) == completed_result, "returning from results should first persist the completed run even when shell autosave is unavailable")
	_expect(game.save_run(true) and FileAccess.file_exists(backup_path), "overwriting the completed result should create a predecessor backup")
	var protected_backup_text := FileAccess.get_file_as_string(backup_path)
	var corrupt_primary := FileAccess.open(save_path, FileAccess.WRITE)
	corrupt_primary.store_string("{invalid primary")
	corrupt_primary.close()
	_expect(game.save_run(true) and FileAccess.get_file_as_string(backup_path) == protected_backup_text, "saving over an invalid primary should preserve the last validated backup instead of promoting corrupt bytes")
	game.play_again_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "refit" and game.current_run_flow_step == 0 and game.contract_accept_button.has_focus(), "Play Again should create a fresh focused Ashgate stage")
	_expect(last_checkpoint_reason == "new_run_started", "Play Again should request a fresh checkpoint instead of leaving Continue on the completed result")
	for path in [save_path, backup_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if not game.last_feedback_path.is_empty() and FileAccess.file_exists(game.last_feedback_path):
		DirAccess.remove_absolute(game.last_feedback_path)
	if failures.is_empty():
		print("PASS: The Long March complete prototype flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
