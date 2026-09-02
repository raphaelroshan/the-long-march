extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _state_for(region_id: String) -> LongMarchState:
	var state := LongMarchState.new(9303)
	state.place_module("ash_runner_engine", Vector2i(0, 0), false, true)
	state.place_module("coal_cell", Vector2i(0, 1))
	state.place_module("generator_core", Vector2i(2, 0))
	state.place_module("crew_quarters", Vector2i(2, 1))
	state.place_module("signal_coil", Vector2i(5, 1), true)
	state.place_module("wall_lamp", Vector2i(5, 2), true)
	state.seed_starter_inventory()
	match region_id:
		"ashgate_lowlands":
			state.start_campaign()
		"flooded_veyru":
			state.start_flooded_veyru()
		"cinder_spine":
			state.start_cinder_spine()
		"white_salt_expanse":
			state.start_white_salt_expanse()
	return state


func _init() -> void:
	var file := FileAccess.open("res://content/regional_campaign_skeleton.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text()) if file != null else null
	_expect(data is Dictionary, "regional campaign skeleton should load")
	if not data is Dictionary:
		quit(1)
		return
	var region_ids: Array[String] = []
	for raw_region in data.get("regions", []):
		var region: Dictionary = raw_region
		var region_id := String(region.get("id", ""))
		region_ids.append(region_id)
		var state := _state_for(region_id)
		for contact_key in ["teaching_contact", "combined_contact"]:
			var contact: Dictionary = region.get(contact_key, {})
			var node_id := String(contact.get("node", ""))
			var preview := state.campaign_node_preview(node_id)
			var expected_threats: Array = contact.get("threats", [])
			var actual_threats: Array = Dictionary(state.CAMPAIGN_NODES.get(node_id, {})).get("encounter", [])
			_expect(bool(preview.get("ok", false)) and actual_threats.size() == expected_threats.size(), "%s %s should expose its authored threat count" % [region_id, contact_key])
			_expect(expected_threats.all(func(threat_id: String) -> bool: return threat_id in actual_threats), "%s %s should expose the declared threats" % [region_id, contact_key])
		_expect(Array(region.get("viable_loadouts", [])).size() >= 2, "%s should retain two complete loadout proofs" % region_id)
		_expect(not String(region.get("recovery_implication", "")).is_empty() and not String(region.get("failure_forward_development", "")).is_empty(), "%s should connect recovery to later campaign state" % region_id)
	_expect(region_ids == ["ashgate_lowlands", "flooded_veyru", "cinder_spine", "white_salt_expanse"], "regional teaching order should remain Ashgate, Veyru, Cinder, then White Salt")
	if failures.is_empty():
		print("PASS: The Long March LM-GPT56-3 regional campaign skeleton")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
