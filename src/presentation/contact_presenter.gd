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
