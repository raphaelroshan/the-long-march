extends SceneTree

const LongMarchState = preload("res://src/core/fortress_state.gd")
const SettlementPresenter = preload("res://src/presentation/settlement_presenter.gd")
const RoutePresenter = preload("res://src/presentation/route_presenter.gd")
const ContactPresenter = preload("res://src/presentation/contact_presenter.gd")
const RecoveryPresenter = preload("res://src/presentation/recovery_presenter.gd")
const DebriefPresenter = preload("res://src/presentation/debrief_presenter.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_pure(state: LongMarchState, before: Dictionary, label: String) -> void:
	_expect(state.serialize() == before, "%s should be a read-only projection over FortressState" % label)

func _init() -> void:
	var state := LongMarchState.new(1107)
	state.start_campaign()
	var snapshot := state.summary()
	var fortress := {"modules": [], "damaged_count": 0, "offline_count": 0}
	var before := state.serialize()

	var settlement := SettlementPresenter.build(state, snapshot, fortress)
	_expect(settlement.get("location_id") == "ashgate_depot" and settlement.get("preferred_station") == "assignment_board", "settlement presenter should preserve the opening location and required station")
	_expect(settlement.get("stations", {}).keys().size() == 6, "settlement presenter should preserve all six stable station contracts")
	_expect(settlement.get("stations", {}).get("assignment_board", {}).get("primary", {}).get("id") == "accept_assignment" and settlement.get("stations", {}).get("departure_gate", {}).get("primary", {}).get("id") == "plan_journey", "settlement presenter should preserve stable assignment and route command IDs")
	_expect(String(settlement.get("stations", {}).get("assignment_board", {}).get("body", "")).contains("only 1 service action") and String(settlement.get("stations", {}).get("assignment_board", {}).get("secondary", {}).get("tooltip", "")).contains("only 1 service action"), "the assignment board should disclose the exact later shortage before decline")
	_expect(settlement.get("stations", {}).get("signal_broker", {}).get("primary", {}).get("id") == "select_experiment_quarry" and settlement.get("stations", {}).get("signal_broker", {}).get("secondary", {}).get("id") == "select_experiment_signal", "the Marchmaster's Desk should expose two stable optional mastery orders")
	_expect_pure(state, before, "settlement presenter")

	var planner := RoutePresenter.build_planner(state, snapshot, {"order": "Choose a road.", "receipt": "LAST RECEIPT", "route_selected": false, "can_return": true, "return_label": "RETURN TO ASHGATE DEPOT BAZAAR"})
	_expect(planner.get("region_name") == "Ashgate Lowlands" and planner.get("values", {}).get("fuel") == str(state.fuel) and planner.get("return_label") == "RETURN TO ASHGATE DEPOT BAZAAR", "route presenter should preserve region, readiness values, and return contract")
	var offered_markers := RoutePresenter.build_assignment_markers(state)
	_expect(offered_markers.get("morrowline_camp", {}).get("status") == "offer", "the route presenter should mark the unresolved Ashgate assignment destination as an offer")
	_expect_pure(state, before, "route planner presenter")
	state.guard_contract_status = "accepted"
	var accepted_marker_before := state.serialize()
	var accepted_markers := RoutePresenter.build_assignment_markers(state)
	_expect(accepted_markers.get("morrowline_camp", {}).get("status") == "accepted" and accepted_markers.get("morrowline_camp", {}).get("title") == "CONVOY GUARD", "the route presenter should carry the accepted convoy obligation onto its destination")
	_expect_pure(state, accepted_marker_before, "assignment marker presenter")
	state.choose_mastery_experiment("ashgate_quarry_adaptation")
	var mastery_before := state.serialize()
	var mastery_planner := RoutePresenter.build_planner(state, snapshot, {"order": "Choose a road."})
	_expect(String(mastery_planner.get("order", "")).contains("FIELD ORDER · QUARRY ADAPTATION") and String(mastery_planner.get("order", "")).contains("Cinder Quarry secured"), "the route planner should retain the selected mastery objective")
	_expect_pure(state, mastery_before, "mastery route presenter")

	var preview := state.campaign_node_preview("rill_crossing", "protect_cargo")
	state.day += int(preview.get("days", 0))
	state.fuel -= int(preview.get("fuel", 0))
	state.campaign_pressure += int(preview.get("pressure_gain", 0))
	var transition_before := state.serialize()
	var transition := RoutePresenter.build_transition(state, "ashgate_depot", "rill_crossing", preview, {"day": 1, "fuel": 6, "pressure": 0}, {"tutorial": false, "promise": "PROMISE · Test", "fortress": fortress})
	_expect(transition.get("origin_name") == "Ashgate Depot" and transition.get("destination_name") == "Rill Crossing" and transition.get("destination_visual_id") == "rill_crossing" and String(transition.get("day_receipt", "")).contains("+1"), "route transition presenter should preserve location names, destination visual identity, and exact committed receipts")
	var tutorial_transition := RoutePresenter.build_transition(state, "ashgate_depot", "rill_crossing", preview, {"day": 1, "fuel": 6, "pressure": 0}, {"tutorial": true, "promise": "TRAINING ORDER", "fortress": fortress})
	_expect(tutorial_transition.get("destination_visual_id") == "muster_road" and tutorial_transition.get("destination_name") == "Muster Road", "tutorial travel should use its own training-road landmark rather than borrowing Rill Crossing scenery")
	_expect_pure(state, transition_before, "route transition presenter")

	state.encounter_active = true
	state.encounter_step = 2
	state.journey_node = "rill_crossing"
	state.encounter_report = ["one", "two", "three", "four", "five", "Road Raider hits Coal Cell for 1; durability is 1.", "Dependency change: Steam Lance Engine is now offline."]
	var combat_view := {"enemies": [{"id": "road_raiders", "arrived": true, "defeated": false, "target": "coal_cell"}], "target_names": {"coal_cell": "Coal Cell"}}
	var contact_before := state.serialize()
	var active_target := ContactPresenter.active_target_id(combat_view)
	var contact := ContactPresenter.build(state, snapshot, combat_view, {"order": "Read contact.", "interventions": [{"id": "shift_power", "enabled": true}], "active_target_id": active_target, "fortress": fortress, "fortress_before": fortress})
	_expect(active_target == "coal_cell" and contact.get("active_target_id") == "coal_cell", "contact presenter should preserve the authoritative target ID")
	_expect(contact.get("recent_report", []).size() == 6 and contact.get("interventions", [])[0].get("id") == "shift_power", "contact presenter should preserve the bounded report and stable intervention command ID")
	_expect_pure(state, contact_before, "contact presenter")

	state.phase = "settlement"
	state.current_location = "morrowline_camp"
	state.settlement_actions_remaining = 2
	state.guard_contract_status = "completed"
	var recovery_before := state.serialize()
	var recovery := RecoveryPresenter.build(state, fortress, {"repair_text": "REPAIR", "repair_disabled": false, "refuel_text": "REFUEL", "refuel_disabled": false, "hull_text": "HULL", "hull_disabled": false, "routes_text": "ROUTES"}, "", "Morrowline Camp")
	_expect(recovery.get("location_id") == "morrowline_camp" and String(recovery.get("local_stake", "")).contains("promise is kept"), "recovery presenter should preserve the live location and completed human stake")
	_expect(recovery.get("repair_text") == "REPAIR" and recovery.get("routes_text") == "ROUTES", "recovery presenter should preserve existing service command labels")
	_expect_pure(state, recovery_before, "recovery presenter")
	state.guard_contract_status = "declined"
	state.settlement_actions_remaining = 1
	var shortage_before := state.serialize()
	var shortage := RecoveryPresenter.build(state, fortress, {}, "", "Morrowline Camp")
	_expect(String(shortage.get("local_stake", "")).contains("PARTS SHORTAGE") and String(shortage.get("local_stake", "")).contains("only 1 service action"), "Morrowline recovery should name the declined convoy's mechanical consequence")
	_expect(String(shortage.get("context", "")).contains("1 finite service opportunity"), "the shortage recovery context should agree with the authoritative action budget")
	_expect_pure(state, shortage_before, "shortage recovery presenter")

	state.phase = "results"
	state.guard_contract_status = "completed"
	state.final_result = "decisive_march"
	state.current_location = "meridian_pass"
	state.campaign_path = ["ashgate_depot", "rill_crossing", "morrowline_camp", "meridian_pass"]
	state.campaign_encounters_completed = 5
	var debrief_before := state.serialize()
	var debrief := DebriefPresenter.build(state, fortress, {"run_code": "TEST-RUN", "contract_status": state.guard_contract_status, "decision_record": "no route events on this path", "result_summary": "The road opened.", "causal_chain": "The fortress held.", "system_condition": "Damaged systems · none", "replay_text": "NEXT RUN · Try another road.", "starting_region_results": {}})
	_expect(debrief.get("headline") == "DECISIVE" and debrief.get("run_code") == "TEST-RUN" and debrief.get("timeline", []).size() == 3, "debrief presenter should preserve outcome identity, run identity, and route timeline")
	_expect(String(debrief.get("consequence", "")).contains("CAUSE → The fortress held") and debrief.get("march_on_label") == "MARCH ON · FLOODED VEYRU", "debrief presenter should preserve the supplied causal chain and regional handoff")
	_expect(String(debrief.get("commitments", "")).contains("Convoy delivered · 2 recovery actions"), "the debrief should retain the convoy's resolved service consequence")
	_expect(String(debrief.get("commitments", "")).contains("Field order · Quarry Adaptation") and String(debrief.get("experiment", "")).contains("QUARRY ADAPTATION"), "the debrief should evaluate and retain the active field order")
	_expect_pure(state, debrief_before, "debrief presenter")

	if failures.is_empty():
		print("PASS: The Long March presentation builders")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
