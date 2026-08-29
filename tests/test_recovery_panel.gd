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
	var panel = load("res://scenes/recovery/RecoveryPanel.tscn").instantiate()
	root.add_child(panel)
	panel.visible = true
	await _settle_ui()
	var view := {
		"region_id": "ashgate_lowlands",
		"location_id": "morrowline_camp",
		"location_name": "Morrowline Camp",
		"context": "Morrowline Camp offers 2 finite service opportunities before the next road.",
		"place_identity": "MORROWLINE · A moving convoy shelter of canvas repair bays, parts wagons, and departure bells.",
		"service_priority": "PRIORITY · Restore the movement or repair chain, or reserve fuel and hull for Meridian Pass.",
		"values": {"hull": "7/10", "fuel": "3", "money": "24", "actions": "2", "trust": "1", "pressure": "STRAIN 4"},
		"repair_text": "REPAIR FIELD WORKSHOP +2 · 8 ASHMARKS\nDURABILITY 1→3 · ACTIONS 2→1",
		"repair_tooltip": "Restore the Field Workshop.",
		"repair_disabled": false,
		"refuel_text": "BUY +2 FUEL · 8 ASHMARKS\nFUEL 3→5 · ACTIONS 2→1",
		"refuel_tooltip": "Load road fuel.",
		"refuel_disabled": false,
		"hull_text": "REPAIR +2 HULL · 10 ASHMARKS\nHULL 7→9 · ACTIONS 2→1",
		"hull_tooltip": "Patch the fortress hull.",
		"hull_disabled": false,
		"routes_text": "REVIEW NEXT ROADS\nKEEP 2 SERVICE ACTIONS AVAILABLE",
		"receipt": "Morrowline Camp reached. No local service has been spent.",
		"caption": "MORROWLINE CAMP · ONE ACTION IS ONE LOST OPPORTUNITY",
		"fortress": {"modules": [{"id": "field_workshop", "family": "workshop", "state": "strained", "damaged": true, "sealed": false, "targeted": false}], "damaged_count": 1, "offline_count": 0}
	}
	panel.configure(view)
	panel.focus_default()
	await _settle_ui()
	_expect(panel.location_label.text.contains("MORROWLINE CAMP") and panel.context_label.text.contains("2 finite service opportunities"), "the recovery tableau should identify its place and finite opportunity budget")
	_expect(panel.place_label.text.contains("canvas repair bays") and panel.priority_label.text.contains("movement or repair chain") and panel.priority_label.text.contains("fuel and hull"), "Morrowline should present a place-specific identity and two practical service priorities")
	_expect(panel.recovery_canvas.presentation_signature().contains("CANVAS REPAIR BAYS") and panel.recovery_canvas.presentation_signature().contains("PARTS WAGONS"), "Morrowline's recovery canvas should expose its authored convoy-shelter motif")
	_expect(panel.value_labels["hull"].text == "7/10" and panel.value_labels["actions"].text == "2" and panel.value_labels["pressure"].text == "STRAIN 4", "the recovery ledger should expose condition, service opportunities, and road pressure")
	_expect(panel.repair_button.text.contains("DURABILITY 1→3") and panel.refuel_button.text.contains("FUEL 3→5") and panel.hull_button.text.contains("HULL 7→9"), "every service should show its exact before-and-after state before commitment")
	_expect(panel.repair_button.has_focus(), "the first legal recovery service should receive default controller focus")
	var focus_after_repair: Node = panel.repair_button.get_node_or_null(panel.repair_button.focus_neighbor_bottom)
	_expect(focus_after_repair == panel.refuel_button and panel.routes_button.get_node_or_null(panel.routes_button.focus_neighbor_bottom) == panel.repair_button, "recovery controls should form an explicit controller loop")
	var signal_counts := {"repair": 0, "routes": 0}
	panel.repair_requested.connect(func() -> void: signal_counts["repair"] = int(signal_counts["repair"]) + 1)
	panel.routes_requested.connect(func() -> void: signal_counts["routes"] = int(signal_counts["routes"]) + 1)
	panel.repair_button.pressed.emit()
	panel.routes_button.pressed.emit()
	_expect(int(signal_counts["repair"]) == 1 and int(signal_counts["routes"]) == 1, "the recovery tableau should forward service and route actions without owning simulation state")
	view["values"] = {"hull": "7/10", "fuel": "5", "money": "16", "actions": "1", "trust": "1", "pressure": "STRAIN 4"}
	view["repair_disabled"] = true
	view["repair_text"] = "ALL SYSTEMS FULL"
	view["receipt"] = "+2 fuel loaded for 8 Ashmarks. 1 service action remains."
	panel.configure(view)
	panel.focus_default()
	await _settle_ui()
	_expect(panel.receipt_label.text.contains("+2 fuel loaded") and panel.receipt_label.text.contains("1 service action remains"), "a completed service should leave a compact exact receipt")
	_expect(panel.refuel_button.has_focus() and panel.repair_button.disabled, "controller focus should skip a newly unavailable service")
	panel.set_high_contrast(true)
	var scaler = load("res://scenes/App.tscn").instantiate()
	scaler.text_scale_percent = 110
	scaler._apply_text_scale_to_tree(panel)
	await _settle_ui()
	var panel_rect: Rect2 = panel.get_global_rect()
	_expect(panel.recovery_canvas.high_contrast_enabled, "the recovery fortress tableau should inherit high contrast")
	_expect(panel_rect.encloses(panel.pause_button.get_global_rect()) and panel_rect.encloses(panel.routes_button.get_global_rect()) and panel.routes_button.is_visible_in_tree(), "the recovery screen should keep pause and route actions visible at 1280×720 with 110% text")
	var veyru_view: Dictionary = view.duplicate(true)
	veyru_view["region_id"] = "flooded_veyru"
	veyru_view["location_id"] = "veyru_evacuation_camp"
	veyru_view["location_name"] = "Evacuation Camp"
	veyru_view["place_identity"] = "EVACUATION CAMP · A raised flood platform sharing dry tools and emergency stores."
	veyru_view["service_priority"] = "PRIORITY · Protect the lower hull, medicine carrier, or fuel margin for the archive road."
	panel.configure(veyru_view)
	await _settle_ui()
	_expect(panel.place_label.text.contains("raised flood platform") and panel.priority_label.text.contains("medicine carrier") and panel.priority_label.text.contains("fuel margin"), "Evacuation Camp should present its flood-specific identity and practical service priorities")
	_expect(panel.recovery_canvas.presentation_signature().contains("RAISED PLATFORM") and panel.recovery_canvas.presentation_signature().contains("WATER PUMP") and panel.recovery_canvas.presentation_signature().contains("SEALED CASES"), "Evacuation Camp's recovery canvas should expose its authored flood-platform motif")
	panel.queue_free()
	scaler.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March recovery panel")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
