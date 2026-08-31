extends RefCounted

static func build_planner(state: LongMarchState, snapshot: Dictionary, context: Dictionary) -> Dictionary:
	var order := String(context.get("order", "Review the next road."))
	var experiment := state.mastery_experiment_details()
	if bool(experiment.get("active", false)):
		order += "  FIELD ORDER · %s · %s" % [String(experiment.get("title", "Experiment")).to_upper(), String(experiment.get("proof", "Complete the stated objective."))]
	return {
		"region_name": state.campaign_region_name(),
		"location_name": String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location)),
		"order": order,
		"receipt": String(context.get("receipt", "")),
		"route_selected": bool(context.get("route_selected", false)),
		"can_return": bool(context.get("can_return", false)),
		"return_label": String(context.get("return_label", "RETURN")),
		"values": {
			"day": str(snapshot.get("day", state.day)),
			"fuel": str(snapshot.get("fuel", state.fuel)),
			"hull": "%d/10" % int(snapshot.get("hull_condition", state.hull_condition)),
			"power": "%d/%d" % [int(snapshot.get("power_draw", 0)), int(snapshot.get("power_output", 0))],
			"heat": "%d/%d" % [int(snapshot.get("heat", 0)), int(snapshot.get("heat_limit", LongMarchState.BASE_HEAT_LIMIT))],
			"mass": "%d/%d" % [int(snapshot.get("mass", 0)), int(snapshot.get("mass_limit", LongMarchState.BASE_MASS_LIMIT))],
			"pressure": "%s · %d" % [state.campaign_pressure_band().replace("_", " ").to_upper(), state.campaign_pressure]
		}
	}

static func build_transition(state: LongMarchState, origin_id: String, destination_id: String, preview: Dictionary, before: Dictionary, context: Dictionary) -> Dictionary:
	var origin_name := String(LongMarchState.JOURNEY_NODES.get(origin_id, {}).get("name", origin_id))
	var destination_name := String(LongMarchState.JOURNEY_NODES.get(destination_id, {}).get("name", destination_id))
	var visibility := String(preview.get("visibility", "unscouted"))
	var threats: Array = preview.get("threats", [])
	var contact_text := ", ".join(threats) if not threats.is_empty() else String(preview.get("threat_hint", "uncertain movement ahead"))
	var detail := "%s intel · %s; resolve the contact before %s can be secured." % [visibility.capitalize(), contact_text, destination_name]
	if bool(context.get("tutorial", false)):
		origin_name = "Ashgate Muster Yard"
		destination_name = "Muster Road"
		detail = "Training intel · %s. Read its approach, preferred targets, and counter before advancing the drill." % contact_text
	return {
		"region_id": state.campaign_region_id,
		"origin_id": origin_id,
		"origin_name": origin_name,
		"destination_id": destination_id,
		"destination_name": destination_name,
		"contact_name": contact_text,
		"status": "%s CONTACT AHEAD" % visibility.to_upper(),
		"promise": String(context.get("promise", "")),
		"phase": "COMMITMENT · COSTS APPLIED · ARRIVAL PENDING",
		"detail": detail,
		"next_decision": "NEXT · Enter contact and respond to %s." % contact_text,
		"day_receipt": "DAY %d → %d  ·  +%d" % [int(before.get("day", state.day)), state.day, state.day - int(before.get("day", state.day))],
		"fuel_receipt": "%d → %d  ·  −%d" % [int(before.get("fuel", state.fuel)), state.fuel, int(before.get("fuel", state.fuel)) - state.fuel],
		"pressure_receipt": "%d → %d  ·  +%d" % [int(before.get("pressure", state.campaign_pressure)), state.campaign_pressure, state.campaign_pressure - int(before.get("pressure", state.campaign_pressure))],
		"heat_receipt": "%d/%d" % [state.heat, LongMarchState.BASE_HEAT_LIMIT],
		"fortress": Dictionary(context.get("fortress", {})).duplicate(true),
		"action_label": "ENTER CONTACT"
	}
