extends RefCounted

static func build(state: LongMarchState, snapshot: Dictionary, fortress: Dictionary) -> Dictionary:
	var is_veyru := state.campaign_region_id == "flooded_veyru"
	var contract_status := state.veyru_contract_status if is_veyru else state.guard_contract_status
	var location_name := String(LongMarchState.JOURNEY_NODES.get(state.current_location, {}).get("name", state.current_location))
	var contract_name := "SEALED MEDICINE DELIVERY" if is_veyru else "MORROWLINE CONVOY GUARD"
	var assignment_body := "Carry sealed medicine cases to the Dry Archive. Flood contacts will value the reserved carrier, but successful delivery pays 28 Ashmarks and 2 trust."
	var assignment_accept_enabled := true
	if is_veyru:
		var medicine_status := state.veyru_medicine_contract_status()
		assignment_body += "\n\nReserved carrier: %s." % String(medicine_status.get("carrier_name", "No carrier"))
		assignment_accept_enabled = bool(medicine_status.get("available", false))
	else:
		assignment_body = "Guard Morrowline's exposed parts wagon. Each enemy on the approach gains 1 HP; arrival pays 30 Ashmarks and 2 trust."
	var assignment_station := {
		"title": contract_name,
		"status": "DECISION REQUIRED" if contract_status == "offered" else contract_status.replace("_", " ").to_upper(),
		"button_status": "CHOOSE" if contract_status == "offered" else contract_status.replace("_", " ").to_upper(),
		"body": assignment_body if contract_status == "offered" else ("The fortress accepted this assignment. Its consequences now travel with the march." if contract_status == "accepted" else "The fortress declined this assignment. The first roads are open without its obligation."),
		"tone": "warning" if contract_status == "offered" else ("safe" if contract_status == "accepted" else "neutral")
	}
	if contract_status == "offered":
		assignment_station["primary"] = {"id": "accept_assignment", "label": "ACCEPT ASSIGNMENT", "enabled": assignment_accept_enabled, "tooltip": "Accept the obligation and its stated consequences."}
		assignment_station["secondary"] = {"id": "decline_assignment", "label": "DECLINE · TRAVEL UNBOUND", "enabled": true, "tooltip": "Decline without spending fuel or time."}
	var departure_ready := contract_status != "offered"
	var settlement_context := "%s · Choose an assignment or inspect a bazaar station." % ("LANTERN QUAY FLOOD MARKET" if is_veyru else "ASHGATE RAIL DEPOT")
	if contract_status == "accepted":
		settlement_context = "ASSIGNMENT RECEIPT · %s accepted. Prepare the fortress, then plan the first road." % ("Sealed medicine delivery" if is_veyru else "Morrowline convoy guard")
	elif contract_status == "declined":
		settlement_context = "ASSIGNMENT RECEIPT · Traveling without the local obligation. Prepare the fortress, then plan the first road."
	return {
		"location_id": state.current_location,
		"location_name": location_name,
		"context": settlement_context,
		"place_identity": "FLOODLINE MARKET · Dry gantries, water gauges, and archive lanterns." if is_veyru else "LOWLAND RAILHEAD · Repair yards, black rails, and blockade signals.",
		"operational_pressure": "%s %d · %s" % [state.campaign_pressure_name().to_upper(), state.campaign_pressure, "Rising water can close the exposed registry road." if is_veyru else "Rising pursuit can close the exposed signal road."],
		"route_meaning": "Pump Gallery buys control with time; Sunken Tramworks saves time by exposing the lower hull." if is_veyru else "Rill Crossing is the direct convoy road; Soot Orchard spends time for salvage and weather exposure.",
		"preferred_station": "assignment_board" if contract_status == "offered" else "departure_gate",
		"values": {
			"hull": "%d/10" % int(snapshot.get("hull_condition", state.hull_condition)),
			"fuel": str(snapshot.get("fuel", state.fuel)),
			"power": "%d/%d" % [int(snapshot.get("power_draw", 0)), int(snapshot.get("power_output", 0))],
			"heat": "%d/%d" % [int(snapshot.get("heat", 0)), int(snapshot.get("heat_limit", LongMarchState.BASE_HEAT_LIMIT))],
			"mass": "%d/%d" % [int(snapshot.get("mass", 0)), int(snapshot.get("mass_limit", LongMarchState.BASE_MASS_LIMIT))],
			"money": str(snapshot.get("money", state.money)),
			"context": "TRUST %d" % state.settlement_trust
		},
		"fortress": fortress.duplicate(true),
		"stations": {
			"workshop": {"title": "Chassis Workshop", "status": "REFIT AVAILABLE", "button_status": "REFIT", "body": ("Use the quay's dry gantry to inspect the walking fortress and protect its lower hull before the archive road." if is_veyru else "Use the depot's rail-side repair bay to inspect the walking fortress, trace dependencies, and prepare its movement chain."), "tone": "safe", "primary": {"id": "open_workshop", "label": "ENTER WORKSHOP", "enabled": true, "tooltip": "Open the detailed chassis workbench."}},
			"quartermaster": {"title": "Quartermaster Stores", "status": "%d ASHMARKS · %d FUEL" % [state.money, state.fuel], "button_status": "STORES", "body": ("Review medicine space, fuel, and carried modules before the flood roads. Trading inventory is not yet available here." if is_veyru else "Review fuel, parts, and carried modules before leaving the rail depot. Trading inventory is not yet available here."), "tone": "neutral", "primary": {"id": "review_supplies", "label": "REVIEW FORTRESS STORES", "enabled": true, "tooltip": "Open the detailed module and capacity view."}},
			"signal_broker": {"title": "Signal Broker", "status": "NO LOCAL REPORTS", "button_status": "QUIET", "body": ("Lantern keepers compare water levels and archive signals. Exact forecasts still depend on working signal equipment." if is_veyru else "Depot signalers compare blockade sightings and ash fronts. Exact forecasts still depend on working signal equipment."), "tone": "muted"},
			"hiring_post": {"title": "Hiring Post", "status": "NO CREW AVAILABLE", "button_status": "EMPTY", "body": "Specialists are encountered through authored locations and events. The hiring board is empty at this stop.", "tone": "muted"},
			"assignment_board": assignment_station,
			"departure_gate": {"title": "Departure Gate", "status": "ROUTES READY" if departure_ready else "ASSIGNMENT BLOCKS DEPARTURE", "button_status": "PLAN JOURNEY" if departure_ready else "LOCKED", "body": (("Pump Gallery is the slower managed-water road; Sunken Tramworks is the shorter submerged cut. Open the route table to compare exact costs and intelligence before Commit." if is_veyru else "Rill Crossing is the direct convoy road; Soot Orchard is the longer salvage road. Open the route table to compare exact costs and intelligence before Commit.") if departure_ready else "The settlement requires an answer at the assignment board before it will clear the fortress to leave."), "tone": "safe" if departure_ready else "warning", "primary": {"id": "plan_journey", "label": "PLAN JOURNEY", "enabled": departure_ready, "tooltip": "Open the regional map without committing a route."}}
		}
	}
