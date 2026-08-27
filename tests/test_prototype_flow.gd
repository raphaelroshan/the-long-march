extends SceneTree

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
			_expect(game.right_scroll.get_global_rect().encloses(game.route_preview_label.get_global_rect()) and game.right_scroll.get_global_rect().encloses(game.campaign_map.get_global_rect()), "route confirmation should keep its intel and map visible with the adjacent Commit action")
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
			_expect(game.advance_encounter_button.get_node_or_null(game.advance_encounter_button.focus_neighbor_bottom) == game.combat_inspect_button and game.combat_inspect_button.get_node_or_null(game.combat_inspect_button.focus_neighbor_bottom) == game.how_to_play_button and game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_top) == game.combat_inspect_button, "spending the emergency order should remove disabled interventions while retaining chassis inspection in controller navigation")
			_expect(game.advance_encounter_button.has_focus(), "spending an emergency order should return focus to encounter advancement")
	for _step in range(8):
		if game.state.phase == expected_phase:
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame

func _run() -> void:
	var save_path := ProjectSettings.globalize_path("user://the_long_march_prototype.save")
	var onboarding_path := ProjectSettings.globalize_path("user://the_long_march_onboarding_v1.complete")
	var journal_path := ProjectSettings.globalize_path("user://the_long_march_playtest_journal.json")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	game.return_to_title_requested.connect(_mark_return_to_title_requested)
	game.checkpoint_reached.connect(_record_checkpoint)
	root.add_child(game)
	await process_frame
	await process_frame
	_expect(game.onboarding_overlay.visible, "a first run should open the Marchmaster briefing")
	_expect(game.ONBOARDING_STEPS.size() == 4 and game.onboarding_step_panels.size() == 4, "the guided briefing should use four concise, visible stages")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_skip_button, "the first briefing step should route left around its disabled Previous action")
	_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_next) == game.onboarding_skip_button and game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_top) == game.onboarding_next_button, "the briefing should trap Tab and vertical focus inside its actions")
	_expect(game.onboarding_progress_label.text.contains("D-pad") and game.onboarding_progress_label.text.contains("A / Enter"), "the briefing should name controller and keyboard navigation together")
	_expect(game.onboarding_action_label.text.begins_with("FIRST ACTION"), "each briefing page should name a concrete player action")
	_expect(game.guidance_label.text.begins_with("CURRENT ORDER") and game.guidance_label.text.contains("convoy"), "the opening objective should identify the contract decision")
	_expect(game.encounter_label.text.begins_with("ASHGATE PREPARATION") and not game.encounter_label.text.contains("NO ENCOUNTER"), "the opening status should frame preparation as progress rather than an empty state")
	_expect(game.how_to_play_button.text == "OPEN FIELD BRIEFING", "the live-stage help action should use the same player-facing name as the pause menu")
	for _step in range(game.ONBOARDING_STEPS.size()):
		if _step == 1:
			_expect(game.onboarding_next_button.get_node_or_null(game.onboarding_next_button.focus_neighbor_left) == game.onboarding_back_button, "later briefing steps should restore Previous to controller navigation")
			_expect(game.onboarding_skip_button.get_node_or_null(game.onboarding_skip_button.focus_next) == game.onboarding_back_button, "later briefing steps should restore Previous to the modal Tab cycle")
			_expect(game.onboarding_body_label.text.contains("Edit Chassis") and game.onboarding_body_label.text.contains("B or Escape returns"), "the briefing should explain how controller users enter and leave chassis editing")
		if _step == game.ONBOARDING_STEPS.size() - 1:
			_expect(game.onboarding_next_button.text == "ENTER ASHGATE", "the final briefing action should clearly enter the playable stage")
		game.onboarding_next_button.pressed.emit()
		await process_frame
	_expect(not game.onboarding_overlay.visible and FileAccess.file_exists(onboarding_path), "completing onboarding should dismiss it and persist the choice")
	_expect(game.state.phase == "refit", "prototype should begin in Ashgate refit")
	_expect(game.current_run_flow_step == 0 and game.run_flow_labels[0].text.contains("PREP"), "the stage tracker should begin at fortress preparation")
	_expect(game.metric_labels.size() == 7 and game.metric_labels["fuel"].text == "6", "the HUD should expose the seven core operating resources")
	_expect(game.contract_accept_button.get_node_or_null(game.contract_accept_button.focus_neighbor_bottom) == game.contract_decline_button and game.contract_decline_button.get_node_or_null(game.contract_decline_button.focus_neighbor_bottom) == game.doctrine_option, "opening planning controls should follow the visible contract-to-doctrine order")
	_expect(game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_bottom) == game.contract_accept_button, "planning controls should wrap to the current mandatory decision")
	game.how_to_play_button.grab_focus()
	await process_frame
	await process_frame
	_expect(game.right_scroll.get_global_rect().encloses(game.how_to_play_button.get_global_rect()), "manual focus navigation should scroll the field briefing action fully into view")
	game.contract_accept_button.grab_focus()
	await process_frame
	await process_frame
	_expect(game.right_scroll.get_global_rect().encloses(game.contract_accept_button.get_global_rect()), "manual focus navigation should scroll back to the current contract action")
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
	var cannon_index := _module_picker_index("shell_cannon")
	game.module_option.select(cannon_index)
	game.module_option.item_selected.emit(cannon_index)
	await process_frame
	_expect(game.selected_module_cell.x < 0 and game.module_option.get_item_text(cannon_index).contains("STORED"), "the module picker should distinguish stored modules ready for placement")
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
	game.module_option.select(engine_index)
	game.module_option.item_selected.emit(engine_index)
	await process_frame
	_expect(game.focus_chassis_button.visible and not game.focus_chassis_button.disabled, "refit should expose an explicit keyboard and controller path into the chassis")
	_expect(game.module_option.get_node_or_null(game.module_option.focus_neighbor_bottom) == game.focus_chassis_button and game.focus_chassis_button.get_node_or_null(game.focus_chassis_button.focus_neighbor_bottom) == game.rotate_button, "planning navigation should include module selection, chassis editing, and refit actions in visible order")
	game.focus_chassis_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(game.fortress_panel.has_focus() and game.fortress_panel.cursor_cell == game.selected_module_cell and game.fortress_panel.interaction_heading().contains("EDIT MODE"), "Edit Chassis should focus the selected module cell in a clearly named refit mode")
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
	_expect(game.campaign_map.visible and game.campaign_node_buttons.size() == 9, "the campaign should render the full authored node graph")
	_expect(game.campaign_commit_button.get_parent() == game.campaign_map.get_parent() and game.campaign_commit_button.get_index() == game.campaign_map.get_index() + 1, "route commitment should remain directly below the map it confirms")
	_expect(game.campaign_map.status_for("ashgate_depot") == "current", "the map should mark Ashgate as the current node")
	_expect(game.campaign_map.status_for("rill_crossing") == "blocked" and game.campaign_map.status_for("soot_orchard") == "blocked", "the opening roads should visibly wait for the contract decision")
	game.contract_accept_button.pressed.emit()
	await process_frame
	await process_frame
	await process_frame
	_expect(game.state.guard_contract_status == "accepted", "the guard contract should be selectable through the UI")
	_expect(game.guidance_label.text.contains("Select one cyan route"), "the objective should advance immediately after the contract is answered")
	_expect(game.current_run_flow_step == 1 and game.run_flow_labels[0].text.begins_with("✓"), "answering the contract should advance the tracker to the Lowlands roads")
	_expect(game.campaign_map.status_for("rill_crossing") == "available" and not game.campaign_map.button_for("rill_crossing").disabled, "answering the contract should activate the opening map nodes")
	_expect(game.campaign_map.button_for("rill_crossing").text.contains("KNOWN · LOW") and game.campaign_map.button_for("soot_orchard").text.contains("FORECAST · GUARDED"), "available map nodes should expose compact scouting and risk comparisons before focus")
	_expect(game.campaign_map.button_for("rill_crossing").has_focus(), "resolving the contract should hand controller focus to the first route")
	_expect(game.encounter_label.text.begins_with("ROUTE PLANNING"), "the post-contract status should name the next actionable phase")
	_expect(game.right_scroll.get_global_rect().encloses(game.campaign_map.button_for("rill_crossing").get_global_rect()), "route focus should scroll the selected action fully into view")
	var route_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	var route_asset_rect: Rect2 = game.asset_row.get_global_rect()
	_expect(not route_asset_rect.intersects(route_viewport_rect) or route_viewport_rect.encloses(route_asset_rect), "route focus should not leave the command-desk icon row partially clipped")
	game.doctrine_option.select(2)
	game.doctrine_option.item_selected.emit(2)
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await process_frame
	_expect(game.doctrine_detail_label.text.begins_with("OVERHEAT WARNING") and game.campaign_map.commit_button.text.contains("HEAT 7/6"), "an overheating doctrine should expose predicted heat in the route commitment")
	_expect(game.encounter_label.text.contains("Rill Crossing selected"), "the route-review status should name the road being considered")
	_expect(game.route_preview_label.text.contains("ROUTE READY · RILL CROSSING") and not game.route_preview_label.text.contains("SOOT ORCHARD"), "route selection should replace stale focus intel with the road being committed")
	var route_cancel := InputEventJoypadButton.new()
	route_cancel.button_index = JOY_BUTTON_B
	route_cancel.pressed = true
	game._unhandled_input(route_cancel)
	await process_frame
	_expect(game.selected_campaign_node_id.is_empty() and game.campaign_map.button_for("rill_crossing").has_focus() and game.encounter_label.text.begins_with("ROUTE PLANNING"), "controller cancel should leave route preview without departing and restore route focus")
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
	game.selected_campaign_node_id = ""
	game._refresh_ui()
	game.campaign_map.button_for("rill_crossing").grab_focus()
	await process_frame
	_expect(game.route_preview_label.text.contains("ROUTE INTEL · RILL CROSSING") and game.route_preview_label.text.contains("Known route") and game.route_preview_label.text.contains("LOW risk"), "keyboard or controller focus should expose readable route intel above the map")
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
	_expect(game.right_scroll.get_global_rect().encloses(game.advance_encounter_button.get_global_rect()), "battle focus should scroll encounter advancement into view")
	var battle_viewport_rect: Rect2 = game.right_scroll.get_global_rect()
	var battle_asset_rect: Rect2 = game.asset_row.get_global_rect()
	_expect(not battle_asset_rect.intersects(battle_viewport_rect) or battle_viewport_rect.encloses(battle_asset_rect), "battle focus should settle after layout changes without clipping the icon row")
	_expect(game.combat_panel.visible and game.combat_panel.step_panels.size() == 6, "battle state should expose the six-step encounter timeline")
	_expect(game.combat_panel.enemy_panels[0].visible and game.combat_panel.enemy_names[0].text == "ROAD RAIDER", "battle state should expose a readable enemy card")
	_expect(game.combat_panel.step_labels[0].text == "NEXT · 1" and game.advance_encounter_button.text.contains("STEP 1 OF 6"), "combat controls should identify the exact next timeline step")
	_expect(game.combat_panel.enemy_states[0].text.contains("2 STEPS OUT") and game.guidance_label.text.contains("2 steps out"), "approaching enemies should use a live countdown before contact")
	_expect(game.combat_panel.order_label.text.contains("Emergency order: 1 available") and game.combat_panel.order_label.text.contains("Next step 1/6") and not game.combat_panel.order_label.text.contains("CP") and not game.combat_panel.order_label.text.contains("Step 0"), "combat status should describe the actual order budget and next timeline step without exposing internal counters")
	_expect(game.intervention_buttons[3].text.contains("Coal Cell") and game.intervention_buttons[3].text.contains("fuel feed"), "cutting loose cargo should disclose the exact module and dependency cost before use")
	_expect(game.combat_inspect_button.visible and not game.combat_inspect_button.disabled and game.combat_inspect_button.text.contains("CHOOSE SEAL TARGET"), "battle controls should expose a controller path into chassis target selection")
	game.combat_inspect_button.pressed.emit()
	await process_frame
	_expect(game.fortress_panel.has_focus() and game.fortress_panel.interaction_heading().contains("CHASSIS INSPECTION") and not game.fortress_panel.interaction_heading().contains("EDIT MODE"), "the combat inspection action should enter a clearly named non-refit chassis mode")
	game.fortress_panel.cursor_cell = Vector2i(0, 1)
	var battle_chassis_select := InputEventAction.new()
	battle_chassis_select.action = "ui_accept"
	battle_chassis_select.pressed = true
	game.fortress_panel._gui_input(battle_chassis_select)
	await process_frame
	_expect(game.selected_module_id == "coal_cell" and game.intervention_buttons[1].has_focus() and game.intervention_buttons[1].text.contains("Coal Cell"), "selecting a combat system should return focus to the matching Seal order")
	var original_raider: Dictionary = game.state.encounter_enemies[0].duplicate(true)
	game.state.encounter_enemies[0]["arrived"] = true
	game.state.encounter_enemies[0]["target"] = "coal_cell"
	game._refresh_ui()
	_expect(game.combat_inspect_button.text.contains("INSPECT TARGET · COAL CELL"), "battle inspection should name an active enemy target before the player enters the chassis")
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
	_expect(game.advance_encounter_button.get_node_or_null(game.advance_encounter_button.focus_neighbor_bottom) == game.combat_inspect_button and game.combat_inspect_button.get_node_or_null(game.combat_inspect_button.focus_neighbor_bottom) == game.intervention_buttons[0] and game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_neighbor_bottom) == game.advance_encounter_button, "combat actions should form a visible vertical controller loop through chassis inspection")
	_expect(game.how_to_play_button.get_node_or_null(game.how_to_play_button.focus_next) == game.advance_encounter_button, "combat Tab navigation should remain inside the active command set")
	game.advance_encounter_button.pressed.emit()
	await process_frame
	_expect(game.combat_panel.enemy_states[0].text.contains("1 STEP OUT") and game.advance_encounter_button.text.contains("STEP 2 OF 6") and game.advance_encounter_button.text.contains("CONTACT NEXT · ROAD RAIDER") and game.combat_panel.order_label.text.contains("Next step 2/6") and game.combat_panel.step_labels[1].text == "CONTACT · 2", "the arrival countdown, timeline, combat status, and advance action should agree and warn before contact")
	var target_card_preview: Dictionary = game.state.encounter_summary()
	var target_enemy: Dictionary = target_card_preview.enemies[0]
	target_enemy["arrived"] = true
	target_enemy["defeated"] = false
	target_enemy["target"] = "coal_cell"
	target_enemy["impact"] = {"damage": 1}
	target_card_preview.enemies[0] = target_enemy
	target_card_preview["target_names"] = {"hull": "Hull", "coal_cell": "Coal Cell"}
	game.combat_panel.configure(target_card_preview, game.state.ENCOUNTER_ENEMIES)
	_expect(game.combat_panel.enemy_states[0].text.contains("TARGET · COAL CELL · NEXT HIT · 1 DAMAGE") and not game.combat_panel.enemy_states[0].text.contains("coal_cell"), "contact cards should translate target IDs and expose the exact next resolved damage")
	game._refresh_ui()
	await _advance_until_phase("map")
	_expect(int(game.campaign_progress_bar.value) == 1, "the region progress bar should advance after a secured encounter")
	_expect(game.journey_label.text.contains("1/5 encounters secured"), "planning between roads should distinguish completed encounters from one currently underway")
	_expect(game.campaign_pressure_label.text.contains("secured 1/5"), "the blockade summary should agree with completed campaign progress between roads")
	_expect(game.campaign_map.status_for("rill_crossing") == "current" and game.campaign_map.status_for("ashgate_depot") == "secured", "the map should retain the secured route and move the current marker")
	_expect(game.campaign_map.button_for("red_wheel_toll_bridge").text.contains("UNSCOUTED · UNKNOWN"), "an available unscouted node should advertise uncertainty without exposing its hidden risk")
	game.campaign_map.button_for("red_wheel_toll_bridge").grab_focus()
	await process_frame
	_expect(game.route_preview_label.text.contains("Unscouted route") and game.route_preview_label.text.contains("unknown"), "focusing an unscouted road should preserve uncertainty in the visible route intel")
	_expect(game.route_preview_label.text.contains("ready forecasting gear or Iven Pell"), "an unscouted road should teach the player how to reveal its hidden information")
	_expect(game.route_preview_label.text.contains("Visible risk factors:") and game.route_preview_label.text.contains("blockade +"), "unscouted intel should expose player-created risk without revealing the hidden route baseline")
	_expect(game.route_preview_label.get_theme_color("font_color") == Color("#cbb8e8"), "unscouted route intel should carry a distinct unknown-information tone")
	game.campaign_map.button_for("red_wheel_toll_bridge").pressed.emit()
	await process_frame
	_expect(game.campaign_commit_button.text.contains("RISK UNKNOWN") and not game.campaign_commit_button.text.contains("36%"), "selecting an unscouted road should not reveal its hidden risk in the commit action")
	_expect(not game.route_preview_label.text.contains("Visible risk factors:") and not game.route_preview_label.text.contains("Intel upgrade:"), "selected-route confirmation should collapse optional scouting guidance to keep Commit adjacent to the map")
	var unknown_commit_style := game.campaign_commit_button.get_theme_stylebox("normal") as StyleBoxFlat
	_expect(unknown_commit_style != null and unknown_commit_style.border_color == Color("#cbb8e8"), "an unscouted commitment should use the same unknown-information tone as its intel")
	game._unhandled_input(route_cancel)
	await process_frame
	await _press_campaign_node("broken_relay")
	await _advance_until_phase("map")
	_expect(game.state.campaign_event_pending == "lost_signal", "the Broken Relay should surface its authored decision")
	_expect(game.fortress_panel.locked_mode_help_text().contains("between road stops") and not game.fortress_panel.locked_mode_help_text().contains("battle damage"), "map-event chassis guidance should not describe the current phase as a battle")
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
	_expect(game.settlement_title.text.contains("2 ACTIONS LEFT"), "the settlement should expose its limited service budget")
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
	_expect(game.settlement_repair_button.disabled and game.settlement_repair_button.text.contains("SELECT FIELD WORKSHOP (1/3)"), "repair should point to the most damaged system when the current selection is already full")
	game.state.modules[damaged_workshop_index]["durability"] = workshop_before
	game.state._recalculate()
	game._refresh_ui()
	var recovery_money: int = game.state.money
	var recovery_hull: int = game.state.hull_condition
	var recovery_actions: int = game.state.settlement_actions_remaining
	game.state.money = 3
	game.state.hull_condition = 8
	game._refresh_ui()
	_expect(game.settlement_refuel_button.disabled and game.settlement_refuel_button.text.contains("HAVE 3 ASHMARKS"), "an unaffordable fuel service should name the player's current funds")
	_expect(game.settlement_hull_button.disabled and game.settlement_hull_button.text.contains("HAVE 3 ASHMARKS"), "an unaffordable hull service should name the player's current funds")
	game.state.money = recovery_money
	game.state.settlement_actions_remaining = 0
	game._refresh_ui()
	_expect(game.settlement_repair_button.text.contains("NO SERVICE ACTIONS LEFT") and game.settlement_refuel_button.text.contains("NO SERVICE ACTIONS LEFT") and game.settlement_hull_button.text.contains("NO SERVICE ACTIONS LEFT"), "exhausted recovery services should state the shared action-budget blocker")
	game.state.hull_condition = recovery_hull
	game.state.settlement_actions_remaining = recovery_actions
	game._refresh_ui()
	var saved_pressure: int = game.state.campaign_pressure
	game.state.campaign_pressure = 5
	game._refresh_ui()
	_expect(game.campaign_map.status_for("signal_causeway") == "closed" and game.campaign_map.status_for("lower_ash_road") == "available", "the visual map should show Break closing only the optional causeway")
	_expect(game.campaign_map.detail_for("signal_causeway").contains("Ready forecasting gear or Iven Pell"), "a closed route should name both ways to restore access")
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
	_expect(game.encounter_label.text.begins_with("SERVICE COMPLETE") and game.encounter_label.text.contains("+2 fuel") and game.encounter_label.text.contains("1 service action"), "settlement services should report cost, effect, and remaining budget above the fold")
	game.campaign_map.button_for("lower_ash_road").pressed.emit()
	await process_frame
	var high_risk_commit_style := game.campaign_commit_button.get_theme_stylebox("normal") as StyleBoxFlat
	_expect(game.campaign_commit_button.text.contains("HIGH RISK") and high_risk_commit_style != null and high_risk_commit_style.border_color == Color("#ef8375"), "a known high-risk commitment should carry the danger treatment before departure")
	game.campaign_commit_button.pressed.emit()
	await process_frame
	_expect(game.current_run_flow_step == 3 and game.run_flow_labels[3].text.contains("FINAL"), "leaving Morrowline should advance the tracker to the final approach")
	await _advance_until_phase("map")
	_expect(game.state.campaign_encounters_completed == 4, "the lower-hull route should become the fourth encounter")
	await _press_campaign_node("meridian_pass")
	_expect(game.state.phase == "final_battle", "the fifth map node should begin the final battle")
	await _advance_until_phase("results")
	_expect(game.state.phase == "results" and game.state.run_complete and game.state.campaign_encounters_completed == 5, "the five-encounter campaign should produce a completed run")
	_expect(game.current_run_flow_step == 4 and game.run_flow_labels[4].text.contains("RESULT"), "the completed run should finish the stage tracker")
	_expect(game.results_group.visible and game.play_again_button.visible and game.results_title_button.visible, "results should expose replay and return-to-title actions")
	_expect(game.results_summary_label.text.begins_with("SCARRED MARCH") and game.results_summary_label.text.contains("7 required"), "the result should explain the missed decisive threshold")
	_expect(game.results_record_label.text.contains("Rill Crossing") and game.results_record_label.text.contains("Meridian Pass") and game.results_record_label.text.contains("Pressure:") and game.results_record_label.text.contains("Contract:") and game.results_record_label.text.contains("Systems:"), "the debrief card should retain the path and operating state needed to interpret the run")
	_expect(game.results_replay_label.text.begins_with("NEXT RUN"), "the result should offer a concrete replay goal")
	var completed_path: Array[String] = game.state.campaign_path.duplicate()
	var completed_encounters: int = game.state.campaign_encounters_completed
	var completed_hull: int = game.state.hull_condition
	var completed_result: String = game.state.final_result
	var completed_outcome: String = game.state.encounter_outcome
	game.state.campaign_path.pop_back()
	game.state.campaign_encounters_completed = 4
	game.state.final_result = "march_failed"
	game.state.encounter_outcome = "march_failed"
	game.state.hull_condition = 0
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.results_summary_label.text.contains("hull reached zero"), "a hull failure should name the exact terminal cause")
	_expect(game.results_replay_label.text.contains("HULL FIRST") and game.results_replay_label.text.contains("Morrowline service"), "a hull failure should recommend a matching next-run adjustment")
	_expect(game.results_record_label.text.contains("Stopped at: Meridian Pass") and game.results_record_label.text.contains("4/5 encounters secured"), "a failed final road should remain visible beside the secured path")
	var failed_engine_index: int = game.state._module_index_by_id("steam_lance_engine")
	var failed_engine_before: int = int(game.state.modules[failed_engine_index].get("durability", 0))
	game.state.hull_condition = 6
	game.state.modules[failed_engine_index]["durability"] = 0
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.results_summary_label.text.contains("Steam Lance Engine reached 0/4 durability"), "a movement failure should identify the disabled engine and its condition")
	_expect(game.results_replay_label.text.contains("MOVEMENT FIRST") and game.results_replay_label.text.contains("Repair Steam Lance Engine"), "an engine failure should recommend repairing the system that ended the run")
	game.state.campaign_path = completed_path
	game.state.campaign_encounters_completed = completed_encounters
	game.state.hull_condition = completed_hull
	game.state.modules[failed_engine_index]["durability"] = failed_engine_before
	game.state.final_result = completed_result
	game.state.encounter_outcome = completed_outcome
	game.state._recalculate()
	game._refresh_ui()
	_expect(game.feedback_button.has_focus(), "the completed run should hand controller focus to playtest feedback")
	_expect(game.feedback_button.get_node_or_null(game.feedback_button.focus_neighbor_bottom) == game.play_again_button and game.play_again_button.get_node_or_null(game.play_again_button.focus_neighbor_right) == game.results_title_button, "the result actions should follow their visible controller layout")
	_expect(game.results_title_button.get_node_or_null(game.results_title_button.focus_next) == game.feedback_button and game.feedback_button.get_node_or_null(game.feedback_button.focus_previous) == game.results_title_button, "the result actions should form a closed Tab cycle")
	game.feedback_button.pressed.emit()
	await process_frame
	var feedback_panel := game.feedback_overlay.find_child("FeedbackPanel", true, false) as PanelContainer
	var feedback_surface := feedback_panel.get_theme_stylebox("panel") as StyleBoxFlat if feedback_panel != null else null
	_expect(feedback_panel != null and feedback_surface != null and feedback_surface.bg_color.a > 0.95 and feedback_surface.border_width_left == 2, "the feedback form should use an opaque bordered modal surface over the completed run")
	await process_frame
	_expect(game.feedback_overlay.visible, "the final screen should provide an accessible feedback form")
	_expect(game.feedback_close_button.text == "BACK TO RESULTS" and game.feedback_save_button.text == "SAVE NOTES LOCALLY", "the feedback form should expose clear local-only actions")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_neighbor_left) == game.feedback_close_button, "the feedback actions should have explicit horizontal controller navigation")
	_expect(game.feedback_save_button.get_node_or_null(game.feedback_save_button.focus_next) == game.feedback_clear_text and game.feedback_clear_text.get_node_or_null(game.feedback_clear_text.focus_previous) == game.feedback_save_button, "the feedback form should trap Tab navigation across fields and actions")
	game.feedback_clear_text.text = "The route consequences were clear."
	game.feedback_confusing_text.text = "The final repair tradeoff needs another run."
	game.feedback_score_option.select(3)
	game.feedback_save_button.pressed.emit()
	await process_frame
	_expect(not game.last_feedback_path.is_empty() and FileAccess.file_exists(game.last_feedback_path), "saving feedback should create a local bundle")
	_expect(game.feedback_status_label.text.begins_with("SAVED LOCALLY") and game.feedback_status_label.text.contains(String(ProjectSettings.get_setting("application/config/version"))) and game.feedback_save_button.text == "SAVE AGAIN" and game.feedback_save_button.has_focus(), "saved feedback should provide a clear versioned receipt and repeat action")
	game._hide_feedback()
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_status_label.text.begins_with("LAST SAVED LOCALLY") and game.feedback_save_button.text == "SAVE AGAIN", "reopening feedback should preserve the previous local-save receipt")
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
	game.play_again_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "refit" and game.current_run_flow_step == 0 and game.contract_accept_button.has_focus(), "Play Again should create a fresh focused Ashgate stage")
	_expect(last_checkpoint_reason == "new_run_started", "Play Again should request a fresh checkpoint instead of leaving Continue on the completed result")
	for path in [save_path, onboarding_path, journal_path]:
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
