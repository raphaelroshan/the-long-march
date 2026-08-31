extends SceneTree

var failures: Array[String] = []
var capture_dir := ""

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle_ui(frames: int = 4) -> void:
	for _frame in range(frames):
		await process_frame

func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "settlement capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "settlement capture should be written: " + name)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/Main.tscn").instantiate()
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle_ui()

	var hub = game.settlement_hub
	_expect(hub.visible and not game.main_columns.visible, "the opening settlement should use the bazaar hub instead of the dense operations desk")
	_expect(hub.station_buttons.size() == 6 and hub.station_buttons.has("workshop") and hub.station_buttons.has("departure_gate"), "the bazaar should expose six stable station landmarks")
	_expect(hub.value_labels["hull"].text == "10/10" and hub.value_labels["fuel"].text == "6" and hub.value_labels["money"].text == "80", "the left rail should expose the critical fortress values")
	_expect(hub.context_label.text.contains("ASHGATE RAIL DEPOT") and hub.bazaar_canvas.presentation_signature().contains("BLACK RAILS"), "Ashgate's starting bazaar should identify its rail-depot setting without relying only on the location title")
	_expect(hub.place_identity_label.text.contains("LOWLAND RAILHEAD") and hub.pressure_label.text.contains("BLOCKADE") and hub.route_meaning_label.text.contains("Rill Crossing") and hub.route_meaning_label.text.contains("Soot Orchard"), "Ashgate should state its place, active blockade pressure, and the meaning of both opening roads")
	_expect(hub.bazaar_canvas.route_signature() == "RILL CROSSING · SOOT ORCHARD", "Ashgate's center stage should carry a visible two-road departure sign")
	_expect(hub.bazaar_canvas.selected_station_signature() == "ASSIGNMENTS · FORTRESS SERVICE LINK", "the selected bazaar station should have a visible service link back to the fortress")
	_expect(hub.attendant_label.text == "ATTENDANT · CONVOY RUNNER" and hub.attendant_portrait.presentation_signature() == "ASHGATE_DEPOT · ASSIGNMENT_BOARD · CONVOY RUNNER", "the selected assignment should be represented by a stable bazaar attendant rather than only a menu button")
	_expect(hub.attendant_role_for("lantern_quay", "signal_broker") == "LANTERN READER" and hub.attendant_role_for("lantern_quay", "hiring_post") == "DIVER CAPTAIN", "Lantern Quay should retain region-specific station attendants")
	_expect(not hub.reduced_motion_enabled and not hub.bazaar_canvas.reduced_motion, "the inhabited bazaar should begin with restrained ambient service movement")
	_expect(hub.station_buttons["assignment_board"].has_focus(), "the unresolved opening assignment should receive default focus")
	var canvas_rect: Rect2 = hub.bazaar_canvas.get_global_rect()
	_expect(hub.value_labels["hull"].global_position.x < canvas_rect.position.x and hub.detail_title.global_position.x > canvas_rect.end.x, "the 1280x720 hub should keep values left, the fortress stage centered, and details right")
	_expect(game.get_global_rect().encloses(hub.pause_button.get_global_rect()) and game.get_global_rect().encloses(hub.primary_action_button.get_global_rect()), "the persistent pause and station action should remain on screen at 1280x720")
	await _capture("01_ashgate_depot")

	var state_before_browse: Dictionary = game.state.serialize()
	hub.station_buttons["workshop"].pressed.emit()
	await process_frame
	_expect(hub.selected_station_id == "workshop" and hub.primary_action_button.text == "ENTER WORKSHOP", "selecting a bazaar station should open its named detail action")
	_expect(hub.attendant_label.text == "ATTENDANT · RAIL-SIDE ENGINEER" and hub.attendant_portrait.presentation_signature().contains("WORKSHOP"), "station selection should carry its attendant and prop into the detail dock")
	_expect(hub.detail_body.text.contains("rail-side repair bay") and hub.detail_body.text.contains("movement chain"), "Ashgate's workshop should frame refit around the depot's immediate operational priority")
	await _capture("02_ashgate_workshop")
	_expect(game.state.serialize() == state_before_browse, "browsing bazaar stations should not mutate deterministic run state")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(not hub.visible and game.main_columns.visible and game.settlement_hub_return_button.visible and game.focus_chassis_button.has_focus(), "entering the workshop should reveal the detailed chassis view and a clear return path")
	game.settlement_hub_return_button.pressed.emit()
	await _settle_ui()
	_expect(hub.visible and hub.station_buttons["assignment_board"].has_focus(), "returning from detailed work should restore the bazaar's current required station")

	hub.station_buttons["quartermaster"].pressed.emit()
	await process_frame
	_expect(hub.primary_action_button.text == "BUY SIDE ARMOR · 18" and hub.secondary_action_button.text == "SELL STORED CANNON · +14" and hub.detail_body.text.contains("Money 80→62") and hub.detail_body.text.contains("Selling cannot remove"), "the Quartermaster should preview exact money, storage, footprint, mass, power, and stored-only sale boundaries")
	await _capture("02a_quartermaster_offer")
	var installed_before_trade: Array = game.state.modules.duplicate(true)
	var side_armor_before: int = game.state.stored_module_count("side_armor_skirt")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(hub.selected_station_id == "quartermaster" and hub.secondary_action_button.has_focus(), "a completed purchase should keep the Quartermaster receipt open and focus the remaining sale")
	_expect(game.state.money == 62 and game.state.stored_module_count("side_armor_skirt") == side_armor_before + 1 and game.state.modules == installed_before_trade and hub.detail_body.text.contains("BOUGHT"), "buying fixed stock should place one Side Armor Skirt in storage without changing the live chassis")
	hub.secondary_action_button.pressed.emit()
	await _settle_ui()
	_expect(hub.selected_station_id == "quartermaster" and hub.primary_action_button.has_focus(), "a completed sale should keep the final Quartermaster receipt open and focus store review")
	_expect(game.state.money == 76 and game.state.stored_module_count("shell_cannon") == 0 and game.state.modules == installed_before_trade and hub.detail_body.text.contains("SOLD"), "selling should remove only the stored Shell Cannon and add its exact 14-Ashmark price")
	await _capture("02a_quartermaster_trade")

	hub.station_buttons["signal_broker"].pressed.emit()
	await process_frame
	_expect(hub.detail_title.text == "ORCHARD WEATHER REPORT" and hub.primary_action_button.text == "BUY REPORT · 8 ASHMARKS" and hub.detail_body.text.contains("information only"), "Ashgate's Signal Broker should sell one explicit report without implying a mechanical route discount")
	var intel_risk_before := float(game.state.campaign_node_preview("soot_orchard").get("risk", 0.0))
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(hub.selected_station_id == "signal_broker" and hub.station_buttons["signal_broker"].has_focus(), "a completed information purchase should keep its broker receipt visible")
	_expect(game.state.money == 68 and game.state.acquired_intel_ids == ["ashgate_orchard_weather_report"] and hub.detail_status.text == "REPORT ACQUIRED", "buying the report should spend exactly 8 Ashmarks and leave a visible acquired receipt")
	_expect(float(game.state.campaign_node_preview("soot_orchard").get("risk", 0.0)) == intel_risk_before and hub.detail_body.text.contains("RELIABLE"), "the purchased report should expose confidence without changing route risk")
	await _capture("02b_signal_report")

	hub.station_buttons["hiring_post"].pressed.emit()
	await process_frame
	_expect(hub.detail_title.text == "IVEN PELL · RELAY KEEPER" and hub.detail_status.text == "LEAD · BROKEN RELAY" and hub.detail_body.text.contains("operational Crew Quarters") and hub.detail_body.text.contains("12 Ashmarks") and hub.detail_body.text.contains("anti-storm damage +2") and not hub.primary_action_button.visible, "the Hiring Post should make Iven's route, requirements, effect, and no-hire-here boundary inspectable without inventing a new action")
	await _capture("02c_hiring_post")

	hub.station_buttons["assignment_board"].pressed.emit()
	await process_frame
	_expect(hub.primary_action_button.text == "ACCEPT ASSIGNMENT" and hub.secondary_action_button.text.begins_with("DECLINE"), "the assignment board should disclose both commitment choices before activation")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.guard_contract_status == "accepted" and hub.visible, "accepting through the bazaar should use the existing campaign contract state")
	_expect(hub.context_label.text.begins_with("ASSIGNMENT RECEIPT") and hub.context_label.text.contains("Morrowline convoy guard accepted"), "the settlement should retain a concise visible receipt after the assignment decision")
	_expect(hub.station_buttons["departure_gate"].has_focus() and hub.station_buttons["departure_gate"].text.contains("PLAN JOURNEY"), "answering the assignment should hand focus to the now-open departure gate")

	hub.station_buttons["assignment_board"].pressed.emit()
	await process_frame
	_expect(hub.detail_title.text == "MARCHMASTER'S ORDERS" and hub.primary_action_button.text.contains("QUARRY") and hub.secondary_action_button.text.contains("SIGNAL"), "the resolved assignment desk should expose both optional field experiments")
	var mastery_resources := {"day": game.state.day, "fuel": game.state.fuel, "money": game.state.money}
	hub.secondary_action_button.pressed.emit()
	await _settle_ui()
	_expect(game.state.mastery_experiment_id == "ashgate_signal_discipline" and hub.context_label.text.contains("FIELD ORDER: SIGNAL DISCIPLINE"), "choosing Signal Discipline should retain the optional order in the bazaar context")
	_expect(mastery_resources == {"day": game.state.day, "fuel": game.state.fuel, "money": game.state.money}, "choosing a field experiment should not grant or spend run resources")

	hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	_expect(hub.primary_action_button.text == "PLAN JOURNEY" and not hub.primary_action_button.disabled and hub.detail_body.text.contains("Rill Crossing") and hub.detail_body.text.contains("Soot Orchard"), "the departure station should require an explicit plan action and explain the two opening road identities")
	hub.primary_action_button.pressed.emit()
	await _settle_ui()
	_expect(not hub.visible and not game.main_columns.visible and game.journey_planner.visible and game.campaign_map.visible, "planning a journey should open the dedicated regional map without moving the fortress")
	_expect(game.journey_planner.receipt_label.visible and game.journey_planner.receipt_label.text.begins_with("LAST RECEIPT"), "route planning should carry the last committed settlement decision into the next beat")
	_expect(game.journey_planner.detail_heading.text == "ROAD DOSSIER" and game.journey_planner.route_stage_label.text == "BROWSE ROAD · NO COST · SELECT TO REVIEW", "the route map should distinguish cost-free browsing from selecting a road for commitment")
	_expect(game.journey_planner.route_selection_label.text.begins_with("NO ROAD SELECTED"), "the map center should state that browsing has not selected or spent a road")
	await _capture("03_route_browse")
	_expect(game.state.current_location == "ashgate_depot" and game.state.phase == "refit" and game.selected_campaign_node_id.is_empty(), "opening the map should not spend fuel, time, or commit a destination")
	_expect(game.journey_planner.return_button.visible, "route planning should retain a visible return to the settlement bazaar")
	var planner_map_rect: Rect2 = game.campaign_map.get_global_rect()
	_expect(game.journey_planner.value_labels["fuel"].global_position.x < planner_map_rect.position.x and game.route_preview_label.global_position.x > planner_map_rect.end.x, "the route planner should keep readiness left, the map centered, and the road dossier right")

	game.set_high_contrast(true)
	game.set_reduced_motion(true)
	await _settle_ui(2)
	game.journey_planner.return_button.pressed.emit()
	await _settle_ui(2)
	_expect(hub.high_contrast_enabled and hub.bazaar_canvas.high_contrast_enabled, "the settlement presentation should inherit the stage's high-contrast setting")
	_expect(hub.attendant_portrait.high_contrast_enabled, "the selected attendant should inherit the same high-contrast treatment as the bazaar")
	_expect(hub.reduced_motion_enabled and hub.bazaar_canvas.reduced_motion, "the settlement's service activity should honor reduced motion without removing the resting tableau")
	game.set_reduced_motion(false)

	hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	hub.primary_action_button.pressed.emit()
	await _settle_ui(2)
	game.campaign_map.button_for("soot_orchard").pressed.emit()
	await _settle_ui(2)
	_expect(game.journey_planner.detail_heading.text == "SELECTED ROAD" and game.journey_planner.route_stage_label.text == "ROUTE SELECTED · REVIEW COSTS → COMMIT", "route selection should visibly distinguish review from commitment")
	_expect(game.journey_planner.route_selection_label.text.contains("SELECTION PREVIEW · THE SOOT ORCHARD") and game.journey_planner.route_selection_label.text.contains("DAY 1→3") and game.journey_planner.route_selection_label.text.contains("FUEL 6→4") and game.journey_planner.route_selection_label.text.contains("PRESSURE 0→1") and game.journey_planner.route_selection_label.text.contains("GUARDED RISK 27%"), "the selected road should restate exact before-and-after costs in the map center before commitment")
	_expect(game.campaign_commit_intel_label.text.contains("KNOWN CONTACTS · Storm Front") and game.campaign_commit_intel_label.text.contains("SOURCE · ASHGATE SIGNAL READER · RELIABLE"), "the selected Orchard dossier should show the purchased contact, source, and confidence before Commit")
	await _capture("03b_route_selected")
	game.campaign_map.button_for("rill_crossing").pressed.emit()
	await _settle_ui(2)
	game.campaign_commit_button.pressed.emit()
	await _settle_ui()
	var journey = game.journey_transition
	_expect(game.state.phase == "battle" and game.state.current_location == "ashgate_depot" and game.state.campaign_target_node == "rill_crossing" and journey.visible and not game.main_columns.visible, "committing a route should keep the fortress at its last secured location and stop at a mandatory road presentation")
	_expect(journey.route_label.text.contains("ASHGATE DEPOT") and journey.route_label.text.contains("RILL CROSSING") and journey.detail_label.text.contains("resolve the contact before"), "the road view should preserve origin, destination, and the unresolved-arrival rule")
	_expect(journey.day_label.text.contains("+1") and journey.fuel_label.text.contains("−1") and journey.pressure_label.text.contains("+1"), "the road view should show the committed time, fuel, and pressure receipt")
	_expect(journey.promise_label.text.contains("Guard Morrowline's parts convoy") and journey.phase_label.text.contains("COMMITMENT") and journey.phase_label.text.contains("ARRIVAL PENDING"), "the departure order should carry the accepted promise and distinguish committed costs from pending arrival")
	_expect(journey.next_label.text.contains("Skip the march beat"), "the departure beat should explain that its presentation can be skipped immediately")
	var march_rect: Rect2 = journey.march_canvas.get_global_rect()
	_expect(journey.day_label.global_position.x < march_rect.position.x and journey.destination_label.global_position.x > march_rect.end.x, "the road view should retain the left-values, centered-fortress, right-details hierarchy")
	_expect(journey.continue_button.has_focus() and journey.continue_button.text == "SKIP MARCH · REVIEW INTERRUPTION" and journey.presentation_beat() == "departed", "the road view should begin with an immediately skippable presentation beat that still preserves the road interruption")
	_expect(journey.march_canvas.beat_visual_signature() == "GATE RECEDING", "departure should begin with a distinct receding-settlement visual")
	_expect(String(journey.march_canvas.motion_signature().get("pace", "")) == "gathering" and not journey.march_canvas.temporary_travel_vfx_active(), "departure should gather momentum without showing full-march dust")
	journey._process(0.4)
	_expect(journey.presentation_beat() == "road_in_motion" and journey.status_label.text == "ROAD IN MOTION", "the road view should establish a short distinct motion beat without changing game state")
	_expect(journey.march_canvas.ROUTE_VISUALS.size() == 19 and journey.march_canvas.ROUTE_VISUALS.has("meridian_pass") and journey.march_canvas.ROUTE_VISUALS.has("dry_archive"), "every current route destination plus the tutorial road should have an authored travel-landmark profile")
	_expect(journey.march_canvas.beat_visual_signature() == "BRIDGE RIBS PASSING" and String(journey.march_canvas.route_visual_signature().get("destination_id", "")) == "rill_crossing", "the road-in-motion beat should foreshadow the committed crossing instead of using a generic landmark")
	await _capture("03_rill_crossing_travel")
	var travel_offset_before: float = journey.march_canvas.travel_offset
	journey.march_canvas._process(0.2)
	_expect(journey.march_canvas.travel_offset > travel_offset_before and journey.march_canvas.temporary_travel_vfx_active() and String(journey.march_canvas.motion_signature().get("fortress_mode", "")) == "travel", "the full-march beat should move the layered road and enable temporary travel atmosphere without changing route state")
	journey._process(0.7)
	_expect(journey.presentation_beat() == "contact_ahead" and journey.continue_button.text == "REVIEW INTERRUPTION" and journey.status_label.text.contains("ROAD INTERRUPTION AHEAD") and journey.next_label.text.contains("Lift Chain"), "the short march should settle on the authored interruption while retaining the committed contact behind it")
	_expect(journey.march_canvas.beat_visual_signature() == "CONTACT ON HORIZON" and journey.march_canvas.contact_name.contains("Road Raider"), "the final travel beat should put the named contact on the horizon")
	_expect(not journey.march_canvas.temporary_travel_vfx_active() and String(journey.march_canvas.motion_signature().get("pace", "")) == "contact_brace", "contact reveal should stop full-march dust and brace the fortress before encounter entry")
	var committed_day_receipt: String = journey.day_label.text
	var committed_fuel_receipt: String = journey.fuel_label.text
	_expect(game.save_run(true), "the departure handoff should save after costs are committed")
	game.journey_transition_active = false
	game.journey_transition_view = {}
	game._refresh_ui()
	_expect(game.load_saved_run(), "the departure handoff should load from its exact checkpoint")
	await _settle_ui(2)
	_expect(journey.visible and game.state.current_location == "ashgate_depot" and game.state.campaign_target_node == "rill_crossing", "Continue should restore the fortress on the road without securing the destination")
	_expect(journey.day_label.text == committed_day_receipt and journey.fuel_label.text == committed_fuel_receipt and journey.promise_label.text.contains("Guard Morrowline's parts convoy"), "restored departure should preserve the exact cost receipt and promise")
	_expect(journey.continue_button.has_focus() and journey.presentation_beat() == "departed", "restored departure should return focus to the explicit, skippable start of the march beat")
	journey.continue_button.pressed.emit()
	await _settle_ui()
	_expect(not journey.visible and game.roadside_event.visible and not game.road_contact.visible and game.state.pre_contact_occurrence_active(), "continuing from the first road should reveal its authored interruption before contact")
	_expect(game.roadside_event.context_label.text == "ROAD INTERRUPTION · CONTACT WAITING" and game.roadside_event.location_label.text.contains("ASHGATE DEPOT → RILL CROSSING"), "the first interruption should preserve the road's origin, destination, and pending-contact state")
	game.roadside_event.button_for("brace_lift_chain").pressed.emit()
	await _settle_ui()
	_expect(game.main_columns.visible and game.combat_panel.visible and game.road_contact.visible and game.road_contact.advance_button.has_focus(), "resolving the road interruption should reveal the fortress contact without advancing a combat step")

	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March settlement hub")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
