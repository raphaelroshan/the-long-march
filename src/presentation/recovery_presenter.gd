extends RefCounted

static func build(state: LongMarchState, fortress: Dictionary, controls: Dictionary, last_receipt: String, location_name: String) -> Dictionary:
	var pressure_name := state.campaign_pressure_name()
	var is_morrowline := state.current_location == "morrowline_camp"
	var local_stake := "STAKE · "
	if is_morrowline:
		local_stake += "The convoy promise is kept; its people and parts preserve 2 service actions before Meridian Pass." if state.guard_contract_status == "completed" else "PARTS SHORTAGE · The convoy is absent; Morrowline can support only 1 service action before Meridian Pass."
	else:
		local_stake += "The sealed medicine carrier is intact and grants a second service opportunity." if state.veyru_contract_carrier_operational() else "The medicine carrier is absent or breached; only one service opportunity remains."
	var experiment := state.mastery_experiment_details()
	var repair_priority: Dictionary = controls.get("repair_priority_view", {})
	var service_priority := "PRIORITY · Restore the movement or repair chain, or reserve fuel and hull for Meridian Pass." if is_morrowline else "PRIORITY · Protect the lower hull, medicine carrier, or fuel margin for the archive road."
	if bool(experiment.get("active", false)):
		service_priority += "\nFIELD ORDER · %s · %s" % [String(experiment.get("title", "Experiment")).to_upper(), String(experiment.get("status", "ACTIVE"))]
	return {
		"region_id": state.campaign_region_id,
		"location_id": state.current_location,
		"location_name": location_name,
		"context": "%s offers %d finite service %s before the next road." % [location_name, state.settlement_actions_remaining, "opportunity" if state.settlement_actions_remaining == 1 else "opportunities"],
		"place_identity": "MORROWLINE · A moving convoy shelter of canvas repair bays, parts wagons, and departure bells." if is_morrowline else "EVACUATION CAMP · A raised flood platform sharing dry tools and emergency stores.",
		"service_priority": service_priority,
		"local_stake": local_stake,
		"route_outlook": "OUTBOUND ROADS · Lower Ash tests the underside; Dry Cistern rewards a condenser; Signal Causeway risks signal; Cinder Quarry trades a mixed contact for field repair." if is_morrowline else "OUTBOUND ROADS · Archive Causeway is the controlled high road; Drowned Registry trades safety for salvage; Pilgrim Gantry is the slow recovery line.",
		"repair_priority": String(repair_priority.get("headline", "REPAIR PRIORITY · All installed systems are at full durability.")),
		"repair_effect": String(repair_priority.get("effect", "WHY IT MATTERS · No damage is currently threatening a dependency chain.")),
		"repair_priority_view": repair_priority.duplicate(true),
		"values": {"hull": "%d/10" % state.hull_condition, "fuel": str(state.fuel), "money": str(state.money), "actions": str(state.settlement_actions_remaining), "trust": str(state.settlement_trust), "pressure": "%s %d" % [state.campaign_pressure_band().replace("_", " ").to_upper(), state.campaign_pressure]},
		"repair_text": String(controls.get("repair_text", "REPAIR MODULE")),
		"repair_tooltip": String(controls.get("repair_tooltip", "Review module repair.")),
		"repair_disabled": bool(controls.get("repair_disabled", false)),
		"refuel_text": String(controls.get("refuel_text", "REFUEL")),
		"refuel_tooltip": String(controls.get("refuel_tooltip", "Review fuel service.")),
		"refuel_disabled": bool(controls.get("refuel_disabled", false)),
		"hull_text": String(controls.get("hull_text", "REPAIR HULL")),
		"hull_tooltip": String(controls.get("hull_tooltip", "Review hull repair.")),
		"hull_disabled": bool(controls.get("hull_disabled", false)),
		"routes_text": String(controls.get("routes_text", "REVIEW NEXT ROADS")),
		"receipt": last_receipt if not last_receipt.is_empty() else "%s reached. No local service has been spent; %s remains at %s %d." % [location_name, pressure_name, state.campaign_pressure_band().replace("_", " ").capitalize(), state.campaign_pressure],
		"caption": "%s · ONE ACTION IS ONE LOST OPPORTUNITY" % location_name.to_upper(),
		"fortress": fortress.duplicate(true)
	}
