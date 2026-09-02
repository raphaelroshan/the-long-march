extends RefCounted

static func build(state: LongMarchState, fortress: Dictionary, context: Dictionary) -> Dictionary:
	var result_id := state.final_result
	var result_name := result_id.replace("_", " ").capitalize()
	var headline := "FAILED"
	var tone := "critical"
	if result_id in ["decisive_march", "archive_kept", "spine_powered", "expanse_allied"]:
		headline = "DECISIVE"
		tone = "stable"
	elif result_id in ["scarred_march", "archive_scarred", "spine_bypassed", "expanse_crossed"]:
		headline = "SCARRED"
		tone = "scarred"
	var timeline: Array[Dictionary] = []
	var visited: Array[String] = state.campaign_path.duplicate()
	var start_id := "ashgate_depot" if state.campaign_region_id == "ashgate_lowlands" else ("lantern_quay" if state.campaign_region_id == "flooded_veyru" else ("blackkiln" if state.campaign_region_id == "cinder_spine" else "saltglass_haven"))
	if state.current_location not in visited and state.current_location != start_id:
		visited.append(state.current_location)
	for index in range(1, mini(visited.size(), 6)):
		var node_id := visited[index]
		var is_last := index == visited.size() - 1
		var status := "FINAL COMMITMENT" if is_last and result_id in ["decisive_march", "scarred_march", "archive_kept", "archive_scarred", "spine_powered", "spine_bypassed", "expanse_allied", "expanse_crossed"] else ("MARCH ENDED" if is_last and result_id in ["march_failed", "veyru_lost", "cinder_lost", "salt_lost"] else "ROAD SECURED")
		timeline.append({"name": String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id.replace("_", " ").capitalize())), "status": status, "tone": "critical" if status == "MARCH ENDED" else ("scarred" if tone == "scarred" and is_last else "stable")})
	var path_names: Array[String] = []
	for node_id in visited:
		path_names.append(String(LongMarchState.CAMPAIGN_NODES.get(node_id, {}).get("name", node_id.replace("_", " ").capitalize())))
	var route_span := "%s → %s" % [path_names[0], path_names[path_names.size() - 1]] if not path_names.is_empty() else "Route unavailable"
	var dependencies := state.dependency_summary()
	var damaged_count := 0
	for module in state.modules:
		var module_id := String(module.get("id", ""))
		if int(module.get("durability", 0)) < int(state.module_definition(module_id).get("durability", 0)):
			damaged_count += 1
	var promises: Array[String] = []
	var berth_choice := String(state.campaign_decisions.get("mara_berth_choice", ""))
	if berth_choice == "keep_iven":
		promises.append("Specialist crossroads · Iven kept; exact forecasts retained")
	elif berth_choice == "replace_iven_with_mara":
		promises.append("Specialist crossroads · Iven → Mara; forecast traded for repair")
	if state.campaign_decisions.has("mara_workbench_choice"):
		if berth_choice == "replace_iven_with_mara":
			var forge_choice := String(state.campaign_decisions.get("mara_workbench_choice", ""))
			var forge_followup := String(state.campaign_decisions.get("mara_followup", ""))
			var forge_target := String(state.module_definition(state.mara_repaired_module_id).get("name", "System")) if forge_choice == "rebuild_weakest" else "Refugee Bunk"
			var forge_result := "HELD" if forge_followup in ["record_repair_held", "record_refuge_held"] else ("FAILED" if forge_followup in ["record_repair_failed", "record_refuge_failed"] else "PENDING")
			promises.append("Forge-core promise · %s → %s on fourth road" % [forge_target, forge_result])
		else:
			promises.append("Forge-core promise · %s" % state.mara_debrief_line().trim_prefix("Mara Flint — "))
	promises.append("Contract · %s  |  Doctrine · %s" % [String(context.get("contract_status", "unoffered")).replace("_", " ").capitalize(), state.encounter_target_doctrine.replace("_", " ").capitalize()])
	if state.campaign_region_id == "ashgate_lowlands" and state.guard_contract_status in ["completed", "declined", "failed"]:
		promises.append("Morrowline service · %s" % ("Convoy delivered · 2 recovery actions" if state.guard_contract_status == "completed" else "Parts shortage · 1 recovery action"))
	var carried: Array[String] = []
	if not state.specialist_id.is_empty():
		carried.append(state.specialist_name())
	if "soot_orchard" in state.campaign_path:
		carried.append("Soot Orchard workers aboard" if state.workers_rescued else "Soot Orchard workers left behind")
	if state.campaign_region_id == "flooded_veyru" and not state.veyru_medicine_carrier_id.is_empty():
		carried.append("sealed medicines in %s" % String(state.module_definition(state.veyru_medicine_carrier_id).get("name", "carrier")))
	if not carried.is_empty():
		promises.append("Carried · %s" % " · ".join(carried))
	promises.append("Road state · %s %d  |  Trust · %d" % [state.campaign_pressure_band().replace("_", " ").capitalize(), state.campaign_pressure, state.settlement_trust])
	var decision_record := String(context.get("decision_record", ""))
	if decision_record not in ["", "no route events on this path", "no regional decisions recorded"]:
		promises.append("Key choices · %s" % decision_record)
	var mastery := state.mastery_experiment_details()
	if bool(mastery.get("active", false)):
		promises.append("Field order · %s · %s" % [String(mastery.get("title", "Experiment")), String(mastery.get("status", "ACTIVE"))])
	for occurrence_line in state.occurrence_debrief_lines():
		promises.append(String(occurrence_line).replace("Road occurrence — ", "Occurrence · "))
	var ending := state.composable_ending()
	promises.append("Ending facets · %s" % String(ending.get("title", "Unrecorded")))
	var next_region_id := "ashgate_lowlands" if state.campaign_region_id == "flooded_veyru" else "flooded_veyru"
	var next_region_name := "ASHGATE LOWLANDS" if next_region_id == "ashgate_lowlands" else "FLOODED VEYRU"
	var next_region_result := String(Dictionary(context.get("starting_region_results", {})).get(next_region_id, ""))
	var experiment_text := String(context.get("replay_text", "")).trim_prefix("NEXT RUN · ")
	if bool(mastery.get("active", false)):
		experiment_text = "%s · %s\n%s\n\nNEXT · %s" % [String(mastery.get("status", "ACTIVE")), String(mastery.get("title", "Field order")).to_upper(), String(mastery.get("proof", "Complete the stated objective.")), experiment_text]
	return {
		"region_id": state.campaign_region_id,
		"region_name": state.campaign_region_name(),
		"day": state.day,
		"run_code": String(context.get("run_code", "")),
		"outcome_label": "%s · %s" % ["JOURNEY COMPLETE" if tone != "critical" else "JOURNEY ENDED", result_name.to_upper()],
		"headline": headline,
		"tone": tone,
		"timeline": timeline,
		"journey": "ROUTE SUMMARY\n%s\n\n%d of 5 encounters secured\n%s · %s %d" % [route_span, state.campaign_encounters_completed, state.campaign_pressure_name(), state.campaign_pressure_band().replace("_", " ").capitalize(), state.campaign_pressure],
		"commitments": "\n".join(promises),
		"consequence": "%s\n\nCAUSE → %s" % [String(context.get("result_summary", "")), String(context.get("causal_chain", ""))],
		"ending": ending,
		"condition": "HULL %d/10 · FUEL %d · HEAT %d/%d\n%d ready · %d strained · %d offline\n%s" % [state.hull_condition, state.fuel, state.heat, LongMarchState.BASE_HEAT_LIMIT, int(dependencies.get("ready", 0)), int(dependencies.get("strained", 0)), int(dependencies.get("offline", 0)), String(context.get("system_condition", ""))],
		"experiment": experiment_text,
		"march_on_label": "%s · %s" % ["REVISIT" if next_region_result in ["decisive_march", "scarred_march", "archive_kept", "archive_scarred"] else "MARCH ON", next_region_name],
		"fortress": fortress.duplicate(true),
		"damaged_count": damaged_count,
		"offline_count": int(dependencies.get("offline", 0))
	}
