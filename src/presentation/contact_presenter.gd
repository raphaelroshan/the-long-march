extends RefCounted

static func active_target_id(combat_view: Dictionary) -> String:
	for raw_enemy in combat_view.get("enemies", []):
		var enemy: Dictionary = raw_enemy
		if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)):
			return String(enemy.get("target", "hull"))
	return ""

static func build(state: LongMarchState, snapshot: Dictionary, combat_view: Dictionary, context: Dictionary) -> Dictionary:
	var recent_report: Array[String] = []
	for report_index in range(maxi(0, state.encounter_report.size() - 6), state.encounter_report.size()):
		recent_report.append(String(state.encounter_report[report_index]))
	var counter_readiness := {}
	for raw_enemy in combat_view.get("enemies", []):
		var enemy_id := String(Dictionary(raw_enemy).get("id", ""))
		if not enemy_id.is_empty() and not counter_readiness.has(enemy_id):
			counter_readiness[enemy_id] = build_counter_readiness(state, enemy_id)
	return {
		"region_id": state.campaign_region_id,
		"location_name": String(LongMarchState.JOURNEY_NODES.get(state.journey_node, {}).get("name", state.journey_node)),
		"active": state.encounter_active,
		"step": state.encounter_step,
		"order": String(context.get("order", "Read the contact before advancing.")),
		"warning": String(context.get("warning", "")),
		"advance_label": String(context.get("advance_label", "ADVANCE CONTACT")),
		"inspect_label": String(context.get("inspect_label", "INSPECT CHASSIS")),
		"intervention_heading": String(context.get("intervention_heading", "EMERGENCY ORDER")),
		"intervention_help": String(context.get("intervention_help", "Choose one order, or preserve it for a later step.")),
		"interventions": Array(context.get("interventions", [])).duplicate(true),
		"enemies": Array(combat_view.get("enemies", [])).duplicate(true),
		"enemy_definitions": LongMarchState.ENCOUNTER_ENEMIES,
		"counter_readiness": counter_readiness,
		"target_names": Dictionary(combat_view.get("target_names", {})).duplicate(true),
		"recent_report": recent_report,
		"active_target_id": String(context.get("active_target_id", "")),
		"fortress": Dictionary(context.get("fortress", {})).duplicate(true),
		"fortress_before": Dictionary(context.get("fortress_before", {})).duplicate(true),
		"values": {
			"hull": "%d/10" % state.hull_condition,
			"power": "%d/%d" % [int(snapshot.get("power_draw", 0)), int(snapshot.get("power_output", 0))],
			"heat": "%d/%d" % [state.heat, LongMarchState.BASE_HEAT_LIMIT],
			"fuel": str(state.fuel),
			"pressure": "%s · %d" % [state.campaign_pressure_band().replace("_", " ").to_upper(), state.campaign_pressure],
			"step": "%d / 6" % state.encounter_step,
			"doctrine": state.encounter_target_doctrine.replace("_", " ").to_upper()
		}
	}

static func build_counter_readiness(state: LongMarchState, enemy_id: String) -> Dictionary:
	var definition: Dictionary = LongMarchState.ENCOUNTER_ENEMIES.get(enemy_id, {})
	var ready: Array[String] = []
	var offline: Array[String] = []
	for raw_module_id in definition.get("counter_modules", []):
		var module_id := String(raw_module_id)
		var module_name := String(state.module_definition(module_id).get("name", module_id.replace("_", " ").capitalize()))
		if state.operational(module_id):
			if module_name not in ready:
				ready.append(module_name)
			continue
		for instance in state.modules:
			if String(instance.get("id", "")) == module_id:
				if module_name not in offline:
					offline.append(module_name)
				break
	if enemy_id == "storm_front" and state.specialist_id == "iven_pell":
		ready.append("Iven Pell")
	if not ready.is_empty():
		return {"status": "ready", "text": "READY NOW · %s" % ", ".join(ready)}
	if not offline.is_empty():
		return {"status": "offline", "text": "COUNTER OFFLINE · %s" % ", ".join(offline)}
	return {"status": "missing", "text": "NO LISTED MODULE COUNTER READY"}
