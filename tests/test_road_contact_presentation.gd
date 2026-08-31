extends SceneTree

var failures: Array[String] = []
var capture_dir := ""

const THREAT_CASES := {
	"road_raiders": {"name": "Road Raider", "arrival_step": 2, "route": "road flank", "targets": ["cargo", "exterior"], "counter": "shell cannon or repeater gun", "signature": "HARPOON VOLLEY", "response": "SHELL OR REPEATER FIRE", "target": "coal_cell", "target_name": "Coal Cell"},
	"climbers": {"name": "Climber", "arrival_step": 3, "route": "fortress flank", "targets": ["signal", "exterior", "crew"], "counter": "wall lamp or repeater gun", "signature": "GRAPNEL RUSH", "response": "WALL LIGHT OR REPEATER FIRE", "target": "signal_coil", "target_name": "Signal Coil"},
	"burrowers": {"name": "Burrower", "arrival_step": 3, "route": "under-road", "targets": ["engine", "workshop", "lower_hull"], "counter": "lower-hull armor, shifted weapons, or a spare engine", "signature": "UNDERCARRIAGE BREACH", "response": "LOWER-HULL ARMOR · SHIFTED GUNS · SPARE ENGINE", "target": "steam_lance_engine", "target_name": "Steam Lance Engine"},
	"storm_front": {"name": "Storm Front", "arrival_step": 1, "route": "weather line", "targets": ["signal", "exterior", "sustain"], "counter": "signal coverage, adjacent armor, Seal Compartment, or vent heat", "signature": "ARC DISCHARGE", "response": "SIGNAL · ADJACENT ARMOR · SEAL · VENT", "target": "signal_mast", "target_name": "Signal Mast"},
	"siege_beast": {"name": "Siege Beast", "arrival_step": 4, "route": "direct road", "targets": ["armor", "crew"], "counter": "shell cannon and front armor", "signature": "RAM CHARGE", "response": "SHELL FIRE · FRONT ARMOR", "target": "front_armor_plate", "target_name": "Front Armor Plate"},
	"flood_surge": {"name": "Flood Surge", "arrival_step": 1, "route": "rising waterline", "targets": ["lower_hull", "cargo", "sustain"], "counter": "Water Condenser, Side Armor Skirt, Field Workshop, or Seal Compartment", "signature": "SURGE CREST", "response": "CONDENSER · ARMOR · WORKSHOP · SEAL", "target": "water_condenser", "target_name": "Water Condenser"},
	"civic_guardian": {"name": "Civic Guardian", "arrival_step": 3, "route": "archive gate", "targets": ["cargo", "signal", "crew", "armor"], "counter": "Shell Cannon, protected cargo, or redundant signal and crew systems", "signature": "ARCHIVE BEAM", "response": "SHELL FIRE · PROTECTED CARGO · REDUNDANCY", "target": "archive_crate", "target_name": "Archive Crate"}
}

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	call_deferred("_run")

func _capture(name: String) -> void:
	if capture_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		_expect(false, "visual evidence requires a rendering display: %s" % name)
		return
	var result := image.save_png(capture_dir.path_join(name + ".png"))
	_expect(result == OK, "visual evidence should save %s" % name)

func _view_for(enemy_id: String, arrived: bool, defeated: bool = false) -> Dictionary:
	var case: Dictionary = THREAT_CASES[enemy_id]
	var target_id := String(case.target)
	var target_name := String(case.target_name)
	return {
		"region_id": "flooded_veyru" if enemy_id in ["flood_surge", "civic_guardian"] else "ashgate_lowlands",
		"location_name": "Contact Test Road",
		"active": true,
		"step": int(case.arrival_step) if arrived else 0,
		"order": "Read intent, choose a response, then resolve one authoritative beat.",
		"advance_label": "RESOLVE CONTACT",
		"inspect_label": "INSPECT CHASSIS",
		"interventions": [],
		"enemy_definitions": {enemy_id: {"name": case.name, "arrival_step": case.arrival_step, "route": case.route, "target_tags": case.targets, "counter": case.counter}},
		"target_names": {target_id: target_name},
		"enemies": [{"id": enemy_id, "arrived": arrived, "defeated": defeated, "target": target_id, "impact": {"damage": 1, "current_durability": 2, "remaining_durability": 1, "target_reason": "%s route matched" % String(case.route), "dependency_changes": [{"name": "Dependent System", "to": "offline"}]}}],
		"recent_report": [] if not arrived else ["%s hits %s for 1; durability is 1." % [case.name, target_name], "Dependency change: Dependent System is now offline — its required neighbor failed."],
		"fortress_before": {"modules": [{"id": target_id, "family": "cargo", "state": "ready", "damaged": false, "sealed": false, "targeted": false}], "damaged_count": 0, "offline_count": 0},
		"fortress": {"modules": [{"id": target_id, "family": "cargo", "state": "strained", "damaged": true, "sealed": false, "targeted": true}], "damaged_count": 1, "offline_count": 1},
		"values": {"hull": "9 / 10", "power": "2 spare", "heat": "2 / 6", "fuel": "4", "pressure": "1", "step": "%d / 6" % int(case.arrival_step), "doctrine": "Protect cargo"}
	}

func _run() -> void:
	capture_dir = OS.get_environment("LONG_MARCH_CAPTURE_DIR")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
	root.size = Vector2i(1600, 900)
	var contact = load("res://scenes/journey/RoadContact.tscn").instantiate()
	root.add_child(contact)
	await process_frame
	var impact_probe := {"count": 0, "cue": ""}
	contact.semantic_audio_requested.connect(func(cue_id: String) -> void:
		impact_probe["count"] = int(impact_probe["count"]) + 1
		impact_probe["cue"] = cue_id
	)
	_expect(contact.advance_button.has_meta("long_march_audio_manual_press") and contact.intervention_buttons.all(func(button: Button) -> bool: return button.has_meta("long_march_audio_manual_press")), "contact commands should defer audio to their authoritative encounter checkpoints")
	for enemy_id in THREAT_CASES:
		var case: Dictionary = THREAT_CASES[enemy_id]
		var visual_signature: Dictionary = contact.contact_canvas.threat_visual_signature(enemy_id)
		_expect(String(visual_signature.get("enemy_id", "")) == enemy_id and not String(visual_signature.get("form", "")).is_empty() and not String(visual_signature.get("lane", "")).is_empty(), "%s should expose a stable threat silhouette and approach lane" % case.name)
		var forecast_view := _view_for(enemy_id, false)
		contact.configure(forecast_view)
		_expect(contact.battle_phase_for() == "FORECAST", "%s should begin with a forecast phase" % case.name)
		_expect(contact.contact_canvas.presentation_stage_text() == "FORECAST · %s · %d STEP%s OUT" % [String(case.name).to_upper(), int(case.arrival_step), "" if int(case.arrival_step) == 1 else "S"], "%s should expose stable forecast timing" % case.name)
		_expect(contact.threat_detail.text.contains("APPROACH · %s" % String(case.route).capitalize()) and contact.threat_detail.text.contains("PREFERRED TARGETS · %s" % " / ".join(case.targets)) and contact.threat_detail.text.contains("COUNTER · %s" % case.counter), "%s forecast should name approach, target preference, and authored counter" % case.name)

		var impact_view := _view_for(enemy_id, true)
		contact.configure(impact_view)
		contact.contact_canvas.report_changed = true
		contact.contact_canvas.step_from = float(int(case.arrival_step) - 1)
		contact.contact_canvas.step_to = float(case.arrival_step)
		var phases := [
			{"progress": 0.05, "phase": "APPROACH", "text": "APPROACH · %s VIA %s" % [String(case.name).to_upper(), String(case.route).to_upper()]},
			{"progress": 0.20, "phase": "TARGET", "text": "TARGET LOCK · %s → %s" % [String(case.name).to_upper(), String(case.target_name).to_upper()]},
			{"progress": 0.34, "phase": "WIND-UP", "text": "WIND-UP · %s" % case.signature},
			{"progress": 0.50, "phase": "RESPONSE", "text": "RESPONSE WINDOW · %s" % case.response},
			{"progress": 0.68, "phase": "IMPACT", "contains": "hits %s for 1" % case.target_name},
			{"progress": 0.90, "phase": "CONSEQUENCE", "text": "CONSEQUENCE · Dependent System → offline"}
		]
		for phase_case in phases:
			contact.contact_canvas.transition_progress = float(phase_case.progress)
			contact._refresh_battle_phase_label(true)
			var stage_text: String = contact.contact_canvas.presentation_stage_text()
			_expect(contact.battle_phase_for() == phase_case.phase and contact.battle_phase_label.text == phase_case.phase, "%s should expose its %s phase in both header and canvas" % [case.name, phase_case.phase])
			if phase_case.has("text"):
				_expect(stage_text == phase_case.text, "%s %s cue should be stable; received '%s'" % [case.name, phase_case.phase, stage_text])
			else:
				_expect(stage_text.begins_with("IMPACT ·") and stage_text.contains(phase_case.contains), "%s impact should repeat authoritative damage; received '%s'" % [case.name, stage_text])
				_expect(contact.contact_canvas.temporary_impact_vfx_active(), "%s impact should expose the temporary resolved-impact VFX only during the impact beat" % case.name)
			if enemy_id == "road_raiders" and String(phase_case.phase) in ["WIND-UP", "IMPACT", "CONSEQUENCE"]:
				await _capture("causality_%s" % String(phase_case.phase).to_lower())
		_expect(contact.threat_detail.text.contains("INTENT · %s" % case.signature) and contact.threat_detail.text.contains("RESPONSE WINDOW · %s" % case.counter) and contact.threat_detail.text.contains("CASCADE · Dependent System → OFFLINE"), "%s active dossier should retain intent, counter, and dependency consequence together" % case.name)
		var readable: Dictionary = contact.contact_readability_summary()
		_expect(String(readable.get("threat", "")) == String(case.name) and String(readable.get("target", "")) == String(case.target_name) and int(readable.get("damage", 0)) == 1 and String(readable.get("counter", "")) == String(case.counter), "%s should expose threat, target, damage, and counter as one presentation summary" % case.name)
		_expect(int(readable.get("durability_before", 0)) == 2 and int(readable.get("durability_after", 0)) == 1 and String(readable.get("cascade", "")).contains("Dependent System READY→OFFLINE"), "%s should expose exact durability and dependency causality in the same summary" % case.name)
		contact.contact_canvas.transition_progress = 0.50
		contact._refresh_battle_phase_label(true)
		await _capture("%02d_%s_response" % [THREAT_CASES.keys().find(enemy_id) + 1, enemy_id])

	var impact_audio_view := _view_for("road_raiders", false)
	contact.configure(impact_audio_view)
	impact_audio_view = _view_for("road_raiders", true)
	contact.configure(impact_audio_view)
	contact.contact_canvas._process(1.4)
	_expect(int(impact_probe["count"]) == 1 and String(impact_probe["cue"]) == "contact_impact", "the contact view should request one impact cue when the staged transition reaches Impact")
	contact.contact_canvas._process(1.4)
	_expect(int(impact_probe["count"]) == 1, "a resolved impact should not replay its cue later in the same transition")

	var reduced_view := _view_for("road_raiders", true)
	contact.set_reduced_motion(true)
	var reduced_warning_view := _view_for("road_raiders", false)
	contact.configure(reduced_warning_view)
	contact.configure(reduced_view)
	contact.contact_canvas.report_changed = true
	contact.contact_canvas.step_from = 1.0
	contact.contact_canvas.step_to = 2.0
	contact.set_high_contrast(true)
	contact.contact_canvas.finish_transition()
	contact._refresh_battle_phase_label(true)
	_expect(contact.contact_canvas.high_contrast_enabled and contact.contact_canvas.transition_progress == 1.0 and contact.battle_phase_for() == "CONSEQUENCE" and contact.contact_canvas.presentation_stage_text().begins_with("CONSEQUENCE"), "high contrast should preserve the cue while reduced motion resolves directly to consequence without changing state")
	_expect(not contact.contact_canvas.temporary_impact_vfx_active(), "reduced motion should skip the temporary impact effect while retaining the consequence receipt")
	_expect(int(impact_probe["count"]) == 2, "reduced motion should collapse the same resolved impact cue to the immediate consequence instead of dropping it")

	var response_view := _view_for("road_raiders", true)
	response_view["recent_report"] = []
	contact.set_reduced_motion(false)
	contact.configure(response_view)
	_expect(contact.battle_phase_for() == "RESPONSE" and contact.contact_canvas.presentation_stage_text() == "RESPONSE READY · SHELL OR REPEATER FIRE", "an arrived threat without a new resolved report should keep the response opportunity visible")

	var settle_view := _view_for("road_raiders", true, true)
	settle_view["step"] = 6
	settle_view["values"]["step"] = "6 / 6"
	settle_view["recent_report"] = ["Road secured: the Road Raider contact is defeated."]
	contact.configure(settle_view)
	_expect(contact.battle_phase_label.text == "SETTLE" and contact.contact_canvas.presentation_stage_text() == "SETTLE · ROAD OPEN · ADVANCE TO ARRIVAL", "a cleared encounter should name the settling beat before the arrival handoff")
	await _capture("08_road_open_settle")
	contact.queue_free()
	if failures.is_empty():
		print("PASS: The Long March road-contact presentation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
