extends SceneTree

var failures: Array[String] = []
var capture_dir := ""

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _settle_ui(frames: int = 3) -> void:
	for _frame in range(frames):
		await process_frame

func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "roadside occurrence capture requires a rendering display: " + name)
		return
	_expect(image.save_png(capture_dir.path_join(name + ".png")) == OK, "roadside occurrence capture should be written: " + name)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
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
	var boiler_view: Dictionary = common.duplicate(true)
	boiler_view.merge({
		"event_id": "boiler_heartbeat",
		"title": "The Boiler's Second Heartbeat",
		"body": "A second rhythm answers the engine stroke. The workshop can open the casing now, or the fortress can keep cadence.",
		"story": {"motif": "boiler_cadence_choice", "show_card": false, "heading": "DAMAGED ENGINE · STOP OR CARRY THE BEARING", "detail": "Inspect: Engine +1 durability · Day +1 · Pressure +1. March: Pressure -1 · Engine -1 durability."},
		"choices": [
			{"id": "inspect_boiler", "label": "Stop and inspect Steam Lance Engine", "effect": "Engine +1 durability · Day +1 · Pressure +1", "enabled": true, "reason": ""},
			{"id": "keep_cadence", "label": "Keep the marching cadence", "effect": "Pressure -1 · Engine -1 durability", "enabled": true, "reason": ""}
		]
	})
	event_view.configure(boiler_view)
	await _settle_ui()
	_expect(event_view.tableau.presentation_signature() == "DAMAGED BOILER · INSPECT OR KEEP CADENCE" and not event_view.story_panel.visible and event_view.choice_buttons[0].text.contains("Engine +1 durability"), "the boiler occurrence should stage the damaged bearing and keep its stop-or-march cost in the primary choices")
	await _capture("01_boiler_heartbeat")
	var lift_view: Dictionary = common.duplicate(true)
	lift_view.merge({
		"event_id": "lift_chain_sings",
		"title": "The Lift Chain Sings",
		"body": "The Ammunition Lift vibrates under a full road load.",
		"story": {"motif": "lift_chain_choice", "show_card": false, "heading": "AMMUNITION LIFT · BRACE OR CARRY THE LOAD", "detail": "Brace: spend 6 Ashmarks. Carry: lower pressure and lose 1 lift durability."},
		"choices": [
			{"id": "brace_lift_chain", "label": "Fit a proper chain brace", "effect": "Ashmarks -6 · Future route risk -2%", "enabled": true, "reason": ""},
			{"id": "carry_lift_load", "label": "Carry the load to the next stop", "effect": "Pressure -1 · Ammunition Lift -1 durability", "enabled": true, "reason": ""}
		]
	})
	lift_view["context"] = "ROAD INTERRUPTION · CONTACT WAITING"
	lift_view["location_name"] = "Ashgate Depot → Rill Crossing"
	lift_view["guidance"] = "Choose one response. Its listed cost applies now; the committed contact remains next and cannot be bypassed."
	event_view.configure(lift_view)
	await _settle_ui()
	_expect(event_view.tableau.presentation_signature() == "LOADED LIFT · BRACE OR CARRY" and not event_view.story_panel.visible and event_view.choice_buttons[1].text.contains("Ammunition Lift -1 durability"), "the lift occurrence should stage its loaded dependency and keep its brace-or-carry cost in the primary choices")
	_expect(event_view.context_label.text == "ROAD INTERRUPTION · CONTACT WAITING" and event_view.location_label.text.contains("ASHGATE DEPOT → RILL CROSSING") and event_view.guidance_label.text.contains("cannot be bypassed"), "the pre-contact lift tableau should preserve its road position and mandatory handoff in visible copy")
	await _capture("02_lift_chain")
	var miller_view: Dictionary = common.duplicate(true)
	miller_view.merge({
		"event_id": "the_miller_with_a_broken_wheel",
		"title": "The Miller With a Broken Wheel",
		"body": "A miller offers sealed fuel tins if the fortress lends its bench and fitter.",
		"story": {"motif": "miller_wheel_choice", "show_card": false, "heading": "BROKEN WHEEL · WORKSHOP TIME OR ROAD TIME", "detail": "Help: gain fuel and trust with delay and workshop wear. Leave: lower pressure and lose trust."},
		"choices": [
			{"id": "lend_workshop_bench", "label": "Lend the workshop bench", "effect": "Fuel +1 · Trust +1 · Day +1 · Pressure +1 · Workshop -1 durability", "enabled": true, "reason": ""},
			{"id": "keep_moving", "label": "Keep the column moving", "effect": "Pressure -1 · Trust -1", "enabled": true, "reason": ""}
		]
	})
	event_view.configure(miller_view)
	await _settle_ui()
	_expect(event_view.tableau.presentation_signature() == "BROKEN WHEEL · HELP OR KEEP MOVING" and not event_view.story_panel.visible and event_view.choice_buttons[0].text.contains("Workshop -1 durability"), "the miller occurrence should stage the broken wagon and keep its help-or-leave cost in the primary choices")
	await _capture("03_miller_wheel")
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
	var meeting_view: Dictionary = common.duplicate(true)
	meeting_view.merge({
		"event_id": "mara_meeting",
		"title": "The Forge Without a Roof",
		"body": "Mara Flint has kept the convoy's axles moving from an open repair bench.",
		"story": {"motif": "mara_meeting", "heading": "MARA FLINT · FORGE MASTER", "detail": "Repair before sacrifice. Bring Mara aboard or preserve the specialist berth."},
		"choices": [
			{"id": "recruit_mara", "label": "Bring Mara aboard", "effect": "Specialist berth filled · Workshop repairs +1", "enabled": true, "reason": ""},
			{"id": "decline_mara", "label": "Leave Mara with Morrowline", "effect": "Keep specialist berth open · No repair bonus", "enabled": true, "reason": ""}
		]
	})
	event_view.configure(meeting_view)
	await _settle_ui()
	_expect(event_view.tableau.presentation_signature() == "MARA FLINT · OPEN FORGE · JOIN OR REMAIN" and event_view.tableau.character_signature() == "MARA FLINT · FORGE MASTER · REPAIR BEFORE SACRIFICE", "Mara's first offer should identify the named forge master and her practical belief beside the open forge")
	await _capture("04_mara_meeting")
	event_view.configure(choice_view)
	event_view.focus_default()
	await _settle_ui()
	_expect(event_view.story_panel.visible and event_view.story_label.text.contains("ONE USE ONLY") and event_view.story_label.text.contains("Field Workshop"), "Mara's workbench event should frame the one-core commitment and exact repair target")
	_expect(event_view.choice_buttons[0].text.contains("Day +1") and event_view.choice_buttons[0].text.contains("Pressure +1") and event_view.choice_buttons[1].text.contains("damage -1 per hit"), "the two workbench choices should disclose immediate and persistent practical costs")
	_expect(event_view.tableau.presentation_signature() == "ONE CORE · MACHINE OR SHELTER", "the workbench should use its own machine-versus-shelter visual motif")
	_expect(event_view.tableau.decision_signature() == "ONE CORE · MACHINE OR SHELTER · FORTRESS HALTED · CONSEQUENCE PENDING", "the event tableau should visibly connect its subject to a halted fortress and pending consequence")
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
	var dry_room_view: Dictionary = common.duplicate(true)
	dry_room_view.merge({
		"event_id": "the_last_dry_room",
		"title": "The Last Dry Room",
		"body": "One sealed compartment can keep the repair stock dry or shelter the families riding beside it. The same floor cannot protect both.",
		"story": {"motif": "dry_room_choice", "heading": "ONE SEALED ROOM · TWO CLAIMS", "detail": "Families: Trust 2→4 · Shelter +1 · Parts Crate 2→1. Repair stock: Field Workshop 1→2 durability · Trust 2→1."},
		"choices": [
			{"id": "shelter_in_dry_room", "label": "Give the room to the families", "effect": "Trust 2→4 · Shelter +1 · Parts Crate 2→1", "enabled": true, "reason": ""},
			{"id": "preserve_dry_parts", "label": "Keep the parts dry and repair Field Workshop", "effect": "Field Workshop 1→2 durability · Trust 2→1", "enabled": true, "reason": ""}
		]
	})
	event_view.configure(dry_room_view)
	await _settle_ui()
	_expect(event_view.story_label.text.contains("ONE SEALED ROOM · TWO CLAIMS") and event_view.choice_buttons[0].text.contains("Parts Crate 2→1") and event_view.choice_buttons[1].text.contains("Field Workshop 1→2"), "The Last Dry Room should name both competing physical consequences before commitment")
	_expect(event_view.tableau.presentation_signature() == "ONE DRY ROOM · FAMILIES OR PARTS" and view_rect.encloses(event_view.choice_buttons[1].get_global_rect()), "The Last Dry Room should retain its own readable compartment motif at 110% text")
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
