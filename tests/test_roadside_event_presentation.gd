extends SceneTree

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle_ui(frames: int = 3) -> void:
	for _frame in range(frames):
		await process_frame

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1280, 720)
	var event_view = load("res://scenes/journey/RoadsideEvent.tscn").instantiate()
	root.add_child(event_view)
	event_view.visible = true
	await _settle_ui()
	var common := {
		"region_id": "ashgate_lowlands",
		"context": "LOCATION DECISION",
		"location_name": "Morrowline Camp",
		"values": {"day": "6", "fuel": "4", "hull": "8/10", "ashmarks": "36", "pressure": "CLOSING · 4", "trust": "2"},
		"fortress": {"modules": [{"id": "field_workshop", "family": "workshop", "state": "strained", "damaged": true, "sealed": false, "targeted": false}]}
	}
	var choice_view: Dictionary = common.duplicate(true)
	choice_view.merge({
		"event_id": "mara_workbench_choice",
		"title": "One Sound Core",
		"body": "Mara recovers one intact forge core from the convoy wreckage. It can serve the machine or the people, but not both.",
		"story": {"motif": "mara_core_choice", "heading": "MARA'S FORGE CORE · ONE USE ONLY", "detail": "Machine: restore Field Workshop now. Shelter: brace the Refugee Bunk against every future hit.", "target_name": "Field Workshop"},
		"choices": [
			{"id": "rebuild_weakest", "label": "Rebuild Field Workshop", "effect": "Restore up to 2 durability · Day +1 · Pressure +1", "enabled": true, "reason": ""},
			{"id": "brace_refuge", "label": "Brace the Refugee Bunk", "effect": "Refugee Bunk damage -1 per hit · No immediate repair", "enabled": true, "reason": ""}
		],
		"guidance": "Choose one response. The other need remains exposed."
	})
	event_view.configure(choice_view)
	event_view.focus_default()
	await _settle_ui()
	_expect(event_view.story_panel.visible and event_view.story_label.text.contains("ONE USE ONLY") and event_view.story_label.text.contains("Field Workshop"), "Mara's workbench event should frame the one-core commitment and exact repair target")
	_expect(event_view.choice_buttons[0].text.contains("Day +1") and event_view.choice_buttons[0].text.contains("Pressure +1") and event_view.choice_buttons[1].text.contains("damage -1 per hit"), "the two workbench choices should disclose immediate and persistent practical costs")
	_expect(event_view.tableau.presentation_signature() == "ONE CORE · MACHINE OR SHELTER", "the workbench should use its own machine-versus-shelter visual motif")
	_expect(event_view.choice_buttons[0].has_focus(), "the first legal workbench commitment should receive controller focus")
	event_view.set_high_contrast(true)
	var scaler = load("res://scenes/App.tscn").instantiate()
	scaler.text_scale_percent = 110
	scaler._apply_text_scale_to_tree(event_view)
	await _settle_ui()
	var view_rect: Rect2 = event_view.get_global_rect()
	_expect(event_view.tableau.high_contrast_enabled and view_rect.encloses(event_view.choice_buttons[1].get_global_rect()), "the two-choice workbench commitment should remain visible in high contrast at 1280×720 with 110% text")
	var callback_view: Dictionary = common.duplicate(true)
	callback_view.merge({
		"event_id": "mara_followup",
		"title": "What Held",
		"body": "Beyond the fourth road, Mara checks the promise made at her workbench against what the fortress actually carried through.",
		"story": {"motif": "mara_core_callback", "heading": "FOURTH-ROAD PROMISE CHECK · HELD", "detail": "Field Workshop was the workbench commitment. Pressure -1; it remained operational.", "target_name": "Field Workshop", "held": true},
		"choices": [{"id": "record_repair_held", "label": "Record what held", "effect": "Pressure -1 · Field Workshop remained operational", "enabled": true, "reason": ""}],
		"guidance": "Record the consequence to reopen the final road."
	})
	event_view.configure(callback_view)
	await _settle_ui()
	_expect(event_view.story_label.text.contains("PROMISE CHECK · HELD") and event_view.story_label.text.contains("Field Workshop was the workbench commitment"), "the later callback should name the earlier physical promise and whether it survived")
	_expect(event_view.tableau.presentation_signature() == "PROMISE CHECK · HELD · FIELD WORKSHOP", "the callback motif should visibly resolve the earlier workbench choice")
	await _settle_ui()
	_expect(event_view.tableau.high_contrast_enabled and view_rect.encloses(event_view.choice_buttons[0].get_global_rect()), "the authored event callback should remain visible in high contrast at 1280×720 with 110% text")
	var pump_view: Dictionary = common.duplicate(true)
	pump_view["region_id"] = "flooded_veyru"
	pump_view["location_name"] = "Pump Gallery"
	pump_view.merge({
		"event_id": "drain_pumps",
		"title": "The Gallery Still Turns",
		"body": "The old pumps can pull water out of the lower roads, but only if the fortress holds position long enough to wake them.",
		"story": {"motif": "pump_gallery_choice", "heading": "OLD DRAIN · ONE DAY AGAINST TWO WATER", "detail": "Hold: spend 1 day to lower rising water by 2. Leave: spend no time and carry the current flood clock into every remaining road."},
		"choices": [
			{"id": "drain_gallery", "label": "Restart the gallery pumps", "effect": "Day +1 · Rising water -2", "enabled": true, "reason": ""},
			{"id": "leave_gallery", "label": "Keep the column moving", "effect": "No delay · Water unchanged", "enabled": true, "reason": ""}
		]
	})
	event_view.configure(pump_view)
	await _settle_ui()
	_expect(event_view.story_label.text.contains("ONE DAY AGAINST TWO WATER") and event_view.choice_buttons[0].text.contains("Rising water -2") and event_view.choice_buttons[1].text.contains("Water unchanged"), "the Pump Gallery should expose the exact time-versus-flood tradeoff before commitment")
	_expect(event_view.tableau.presentation_signature() == "OLD DRAIN · ONE DAY OR TWO WATER" and view_rect.encloses(event_view.choice_buttons[1].get_global_rect()), "the Pump Gallery should retain a distinct pump-and-water motif within the large-text viewport")
	event_view.queue_free()
	scaler.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March roadside-event presentation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
