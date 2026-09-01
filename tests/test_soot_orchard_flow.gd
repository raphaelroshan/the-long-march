extends SceneTree

const LOCAL_PATHS := [
	"user://the_long_march_prototype.save",
	"user://the_long_march_prototype.backup.save",
]

var failures: Array[String] = []
var game: Control
var capture_dir := ""

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle(frames: int = 3) -> void:
	for _frame in range(frames):
		await process_frame

func _remove_local_state() -> void:
	for path in LOCAL_PATHS:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute):
			DirAccess.remove_absolute(absolute)

func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "Soot Orchard capture requires a rendering display")
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "Soot Orchard capture should be written")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove_local_state()
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	root.size = Vector2i(1280, 720)
	game = load("res://scenes/Main.tscn").instantiate()
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle()

	game.state.choose_guard_contract(false)
	game.selected_campaign_node_id = "soot_orchard"
	game._on_campaign_route_committed("soot_orchard")
	await _settle()
	_expect(game.journey_transition.visible and game.state.current_location == "ashgate_depot", "the Orchard route should begin with the normal committed-road handoff")
	game.journey_transition.continue_button.pressed.emit()
	await _settle()
	_expect(game.road_contact.visible and game.state.encounter_active, "the Orchard road should enter its configured Storm Front contact before the scenario")

	for step in range(8):
		if not game.state.encounter_active:
			break
		game.road_contact.advance_button.pressed.emit()
		await _settle()
		if game.state.encounter_active and not game.state.encounter_intervention_used and step == 0:
			var shift_button := game.road_contact.intervention_buttons[0] as Button
			if not shift_button.disabled:
				shift_button.pressed.emit()
				await _settle()

	_expect(game.state.phase == "road_event" and game.state.road_arrival_event_active(), "clearing the Storm Front should enter the serialized road-event phase")
	_expect(game.state.current_location == "ashgate_depot" and game.state.campaign_target_node == "soot_orchard" and game.state.campaign_encounters_completed == 0, "the fortress should remain at its origin and leave the Orchard unsecured while the decision waits")
	_expect(game.roadside_event.visible and not game.journey_arrival.visible and game.roadside_event.context_label.text == "ROAD SCENARIO · ARRIVAL PENDING", "the Orchard decision should replace the arrival receipt until one response is chosen")
	_expect(game.roadside_event.location_label.text.contains("ASHGATE DEPOT → THE SOOT ORCHARD") and game.roadside_event.tableau.presentation_signature() == "BURNING ORCHARD · FUEL OR PEOPLE", "the road scenario should retain both route endpoints and the authored Orchard tableau")
	_expect(game.roadside_event.choice_buttons[0].has_focus(), "the first legal Orchard response should receive focus after contact")
	await _capture("01_orchard_before_arrival")

	_expect(game.save_run(true), "the post-contact Orchard decision should save")
	_expect(game.load_saved_run(), "the post-contact Orchard decision should load · %s" % game.event_label.text)
	await _settle()
	_expect(game.state.road_arrival_event_active() and game.roadside_event.visible and game.roadside_event.choice_buttons[0].has_focus(), "Continue should restore the same unresolved road scenario without moving the fortress")
	var fuel_before: int = game.state.fuel
	game.roadside_event.button_for("take_fuel").pressed.emit()
	await _settle()
	_expect(game.state.phase == "map" and game.state.current_location == "soot_orchard" and game.state.campaign_target_node.is_empty(), "resolving the Orchard scenario should atomically complete arrival")
	_expect(game.state.campaign_encounters_completed == 1 and game.state.fuel == fuel_before + 2 and String(game.state.campaign_decisions.get("salvage_choice", "")) == "take_fuel", "arrival should preserve the selected fuel consequence and secure exactly one encounter")
	_expect(game.journey_arrival.visible and not game.roadside_event.visible and game.journey_arrival.continue_button.has_focus(), "the completed scenario should hand focus to the arrival receipt rather than directly opening the map")
	_expect(game.journey_arrival.destination_label.text == "THE SOOT ORCHARD" and game.journey_arrival.report_label.text.contains("Road decision") and game.journey_arrival.report_label.text.contains("recovers 2 fuel"), "the arrival receipt should name the destination and carry the just-applied road consequence")
	_expect(game.get_global_rect().encloses(game.journey_arrival.continue_button.get_global_rect()), "the Orchard arrival action should remain fully visible at 1280×720")
	await _capture("02_orchard_arrival")
	game.journey_arrival.continue_button.pressed.emit()
	await _settle()
	_expect(game.journey_planner.visible and game.campaign_map.status_for("soot_orchard") == "current", "acknowledging arrival should reopen planning with the Orchard finally marked current")

	game.queue_free()
	await _settle()
	_remove_local_state()
	if failures.is_empty():
		print("PASS: The Long March Soot Orchard road-event flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
