extends SceneTree

var failures: Array[String] = []
var viewport_size := Vector2i(1600, 900)
var responsive := false

func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)

func _settle() -> void:
	for _frame in range(4):
		await process_frame

func _run() -> void:
	var width := OS.get_environment("LONG_MARCH_VIEWPORT_WIDTH")
	var height := OS.get_environment("LONG_MARCH_VIEWPORT_HEIGHT")
	if width.is_valid_int() and height.is_valid_int():
		viewport_size = Vector2i(int(width), int(height))
	responsive = OS.get_environment("LONG_MARCH_RESPONSIVE_PROFILE") == "1"
	root.size = viewport_size
	var game = load("res://scenes/Main.tscn").instantiate()
	game.starting_region_id = "white_salt_expanse"
	game.show_onboarding_on_ready = false
	root.add_child(game)
	await _settle()
	if responsive:
		game.set_high_contrast(true)
		game.set_reduced_motion(true)
		await _settle()
	_expect(game.state.current_location == "saltglass_haven" and game.state.chassis_template_id == "salt_skimmer", "White Salt should launch at Saltglass Haven with the Salt Skimmer")
	_expect(game.state.chassis_mass_limit() == 13 and game.state.chassis_exterior_limit() == 3 and not game.state.chassis_cell_available(Vector2i(0, 3)), "the alternate chassis should expose its physical constraints")
	_expect(game.settlement_hub.context_label.text.contains("SALTGLASS SIGNAL MARKET") and game.settlement_hub.bazaar_canvas.presentation_signature().contains("MIRROR BEACONS"), "Saltglass should have a distinct signal-market identity")
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	_expect(game.state.salt_contract_status == "accepted", "the beacon escort should be accepted through the shared assignment station")
	game.settlement_hub.station_buttons["departure_gate"].pressed.emit()
	await process_frame
	game.settlement_hub.primary_action_button.pressed.emit()
	await _settle()
	var route_button: Button = game.campaign_map.button_for("buried_observatory")
	_expect(route_button != null and not route_button.disabled, "Buried Observatory should be a visible opening route")
	if route_button != null:
		route_button.pressed.emit()
		await process_frame
		game.campaign_commit_button.pressed.emit()
		await process_frame
		_expect(game.journey_transition.visible and game.journey_transition.promise_label.text.contains("Refugee Compact"), "the road scene should carry the escort promise")
		_expect(String(game.journey_transition.march_canvas.route_visual_signature().get("marker", "")) == "BURIED LENS", "the road scene should show the Buried Observatory landmark")
	if responsive:
		_expect(game.get_global_rect().encloses(game.journey_transition.continue_button.get_global_rect()), "responsive Salt travel should keep Continue visible")
	if failures.is_empty():
		if responsive:
			print("PASS: The Long March responsive White Salt profile %dx%d" % [viewport_size.x, viewport_size.y])
		print("PASS: The Long March White Salt UI flow")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)

func _init() -> void:
	call_deferred("_run")
