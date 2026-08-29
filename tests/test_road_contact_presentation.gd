extends SceneTree

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var contact = load("res://scenes/journey/RoadContact.tscn").instantiate()
	root.add_child(contact)
	await process_frame
	var base_view := {
		"region_id": "ashgate_lowlands",
		"location_name": "Rill Crossing",
		"active": true,
		"step": 2,
		"order": "Read the incoming contact.",
		"advance_label": "ADVANCE",
		"inspect_label": "INSPECT CHASSIS",
		"interventions": [],
		"enemy_definitions": {"road_raiders": {"name": "Road Raider", "arrival_step": 2, "route": "road flank", "target_tags": ["cargo"], "counter": "shell cannon"}},
		"target_names": {"coal_cell": "Coal Cell"},
		"enemies": [{"id": "road_raiders", "arrived": true, "defeated": false, "target": "coal_cell", "impact": {"damage": 1, "current_durability": 2, "remaining_durability": 1, "target_reason": "cargo profile", "dependency_changes": [{"name": "Steam Lance Engine", "to": "offline"}]}}],
		"recent_report": ["Road Raider hits Coal Cell for 1; durability is 1.", "Dependency change: Steam Lance Engine is now offline — engine has no adjacent Coal Cell."],
		"fortress_before": {"modules": [{"id": "steam_lance_engine", "family": "engine", "state": "ready", "damaged": false, "sealed": false, "targeted": false}, {"id": "coal_cell", "family": "cargo", "state": "ready", "damaged": false, "sealed": false, "targeted": false}], "damaged_count": 0, "offline_count": 0},
		"fortress": {"modules": [{"id": "coal_cell", "family": "cargo", "state": "strained", "damaged": true, "sealed": false, "targeted": true}], "damaged_count": 1, "offline_count": 0},
		"values": {}
	}
	contact.configure(base_view)
	contact.contact_canvas.report_changed = true
	contact.contact_canvas.step_from = 1.0
	contact.contact_canvas.step_to = 2.0
	contact.contact_canvas.transition_progress = 0.10
	_expect(contact.contact_canvas.presentation_stage_text() == "TARGET LOCK · ROAD RAIDER → COAL CELL", "an arriving threat should visibly lock its authoritative target before impact")
	contact.contact_canvas.transition_progress = 0.30
	_expect(contact.contact_canvas.presentation_stage_text() == "WIND-UP · HARPOON VOLLEY", "Road Raiders should have a stable attack signature during wind-up")
	contact.contact_canvas.transition_progress = 0.65
	_expect(contact.contact_canvas.presentation_stage_text().contains("IMPACT") and contact.contact_canvas.presentation_stage_text().contains("hits Coal Cell for 1"), "impact staging should repeat the authoritative damage report")
	contact.contact_canvas.transition_progress = 0.90
	_expect(contact.contact_canvas.presentation_stage_text() == "CONSEQUENCE · Steam Lance Engine → offline", "consequence staging should condense the resulting dependency change into a readable stage cue")
	contact.set_high_contrast(true)
	contact.set_reduced_motion(true)
	_expect(contact.contact_canvas.high_contrast_enabled and contact.contact_canvas.transition_progress == 1.0 and contact.contact_canvas.presentation_stage_text().begins_with("CONSEQUENCE"), "high contrast should preserve the cue while reduced motion resolves directly to consequence")
	var approach_view: Dictionary = base_view.duplicate(true)
	approach_view["step"] = 0
	approach_view["enemies"] = [{"id": "road_raiders", "arrived": false, "defeated": false, "target": "coal_cell"}]
	approach_view["recent_report"] = []
	contact.configure(approach_view)
	_expect(contact.contact_canvas.presentation_stage_text() == "APPROACH · ROAD RAIDER · 2 STEPS OUT", "an approaching threat should retain a readable distance cue before target lock")
	contact.queue_free()
	if failures.is_empty():
		print("PASS: The Long March road-contact presentation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
