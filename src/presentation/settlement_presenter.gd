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
		assignment_body = "Guard Morrowline's exposed parts wagon. Each enemy on the approach gains 1 HP; arrival pays 30 Ashmarks and 2 trust, and preserves 2 service actions. Decline and Morrowline will have only 1 service action."
	var assignment_station := {
		"title": contract_name,
		"status": "DECISION REQUIRED" if contract_status == "offered" else contract_status.replace("_", " ").to_upper(),
		"button_status": "CHOOSE" if contract_status == "offered" else contract_status.replace("_", " ").to_upper(),
		"body": assignment_body if contract_status == "offered" else ("The fortress accepted this assignment. Its consequences now travel with the march." if contract_status == "accepted" else ("The fortress declined this assignment. Morrowline will have only 1 service action because its parts convoy is absent." if not is_veyru else "The fortress declined this assignment. The first roads are open without its obligation.")),
		"tone": "warning" if contract_status == "offered" else ("safe" if contract_status == "accepted" else "neutral")
	}
	if contract_status == "offered":
		assignment_station["primary"] = {"id": "accept_assignment", "label": "ACCEPT ASSIGNMENT", "enabled": assignment_accept_enabled, "tooltip": "Accept the obligation and its stated consequences."}
		assignment_station["secondary"] = {"id": "decline_assignment", "label": "DECLINE · TRAVEL UNBOUND", "enabled": true, "tooltip": "Decline without spending fuel or time. Morrowline will have only 1 service action." if not is_veyru else "Decline without spending fuel or time."}
	elif not is_veyru:
		var experiment := state.mastery_experiment_details()
		var selected_title := String(experiment.get("title", "No field order"))
		assignment_station = {
			"title": "Marchmaster's Orders",
			"status": String(experiment.get("status", "UNASSIGNED")),
			"button_status": selected_title.to_upper() if bool(experiment.get("active", false)) else "OPTIONAL",
			"body": ("Selected: %s\n%s\n\nNo rewards or unlocks; this is a visible replay goal." % [selected_title, String(experiment.get("brief", ""))]) if bool(experiment.get("active", false)) else "The convoy decision is recorded. Choose one optional field experiment: Quarry Adaptation tests route and doctrine; Signal Discipline tests specialist or equipment planning. Each accepts two distinct solutions and grants no permanent reward.",
			"tone": "safe" if bool(experiment.get("active", false)) else "neutral",
			"primary": {"id": "select_experiment_quarry", "label": "FIELD ORDER · QUARRY", "enabled": true, "tooltip": "Secure Cinder Quarry with Run Hot speed or Protect Cargo plus lower-hull armor."},
			"secondary": {"id": "select_experiment_signal", "label": "FIELD ORDER · SIGNAL", "enabled": true, "tooltip": "Secure Signal Causeway with Iven Pell or an operational Wall Lamp."}
		}
	var departure_ready := contract_status != "offered"
	var settlement_context := "%s · Choose an assignment or inspect a bazaar station." % ("LANTERN QUAY FLOOD MARKET" if is_veyru else "ASHGATE RAIL DEPOT")
	if contract_status == "accepted":
		settlement_context = "ASSIGNMENT RECEIPT · %s accepted. Prepare the fortress, then plan the first road." % ("Sealed medicine delivery" if is_veyru else "Morrowline convoy guard")
	elif contract_status == "declined":
		settlement_context = "ASSIGNMENT RECEIPT · Traveling without the convoy. Morrowline will have 1 service action; prepare the fortress, then plan the first road." if not is_veyru else "ASSIGNMENT RECEIPT · Traveling without the local obligation. Prepare the fortress, then plan the first road."
	var signal_station := {"title": "Signal Broker", "status": "NO LOCAL REPORTS", "button_status": "QUIET", "body": "Lantern keepers compare water levels and archive signals. Exact forecasts still depend on working signal equipment." if is_veyru else "Depot signalers compare blockade sightings and ash fronts. Exact forecasts still depend on working signal equipment.", "tone": "muted"}
	if not is_veyru:
		var intel := state.active_settlement_intel_offer()
		var acquired := bool(intel.get("acquired", false))
		var price := int(intel.get("price", 0))
		signal_station = {
			"title": String(intel.get("name", "Signal Broker")),
			"status": "REPORT ACQUIRED" if acquired else "%d ASHMARKS" % price,
			"button_status": "IN LEDGER" if acquired else "BUY REPORT",
			"body": ("SOURCE · %s · %s\nThe route ledger now identifies the exact Soot Orchard contact and its authored counters. The report changes no fuel, time, pressure, or route risk." % [String(intel.get("source_name", "Unknown source")).to_upper(), String(intel.get("confidence", "unknown")).to_upper()]) if acquired else "A depot reader tracked the weather line through the Soot Orchard. Buy the report to reveal its exact contact and authored counters before Commit. This is information only: risk, fuel, time, and pressure do not change.",
			"tone": "safe" if acquired else ("warning" if state.money < price else "neutral")
		}
		if not acquired:
			signal_station["primary"] = {"id": "buy_orchard_intel", "label": "BUY REPORT · %d ASHMARKS" % price, "enabled": state.money >= price, "tooltip": "Add the source and exact Soot Orchard contacts to the route ledger without changing its mechanical risk." if state.money >= price else "Requires %d Ashmarks; only %d remain." % [price, state.money]}
		var active_experiment := state.mastery_experiment_details()
		if bool(active_experiment.get("active", false)):
			settlement_context += " · FIELD ORDER: %s" % String(active_experiment.get("title", "Experiment")).to_upper()
	var quartermaster_station := {"title": "Quartermaster Stores", "status": "%d ASHMARKS · %d FUEL" % [state.money, state.fuel], "button_status": "STORES", "body": "Review medicine space, fuel, and carried modules before the flood roads. No fixed trade is posted at this quay." if is_veyru else "Review fuel, parts, and carried modules before leaving the rail depot.", "tone": "neutral", "primary": {"id": "review_supplies", "label": "REVIEW FORTRESS STORES", "enabled": true, "tooltip": "Open the detailed module and capacity view."}}
	if not is_veyru:
		var buy_offer := state.active_settlement_market_buy_offer()
		var sell_offer := state.market_sell_preview("shell_cannon")
		var buy_price := int(buy_offer.get("price", 0))
		var buy_complete := bool(buy_offer.get("purchased", false))
		var sell_available := bool(sell_offer.get("available", false))
		var trade_lines: Array[String] = []
		if buy_complete:
			trade_lines.append("BOUGHT · Spare Side Armor Skirt is in storage. Install it in the Workshop; it uses a 1×2 footprint, 2 mass, no power, and protects the lower hull.")
		elif state.money < buy_price:
			trade_lines.append("BUY · Spare Side Armor Skirt · %d Ashmarks\nBLOCKED · %d available · %d short. Storage is unchanged until purchase; installed footprint 1×2 · mass 2 · power 0." % [buy_price, state.money, buy_price - state.money])
		else:
			trade_lines.append("BUY · Spare Side Armor Skirt · %d Ashmarks\nMoney %d→%d · Storage %d→%d · installed footprint 1×2 · mass 2 · power 0." % [buy_price, state.money, state.money - buy_price, state.stored_modules.size(), state.stored_modules.size() + 1])
		if sell_available:
			trade_lines.append("SELL · Stored Shell Cannon · +%d Ashmarks\nMoney %d→%d · Storage %d→%d. Selling cannot remove the installed fortress; it gives up a 2×1 exterior weapon that needs 2 power and adjacent ammunition." % [int(sell_offer.get("price", 0)), state.money, state.money + int(sell_offer.get("price", 0)), state.stored_modules.size(), state.stored_modules.size() - 1])
		else:
			trade_lines.append("SOLD · No stored Shell Cannon remains. Installed systems are never eligible for this sale.")
		quartermaster_station = {
			"title": "Quartermaster Stores",
			"status": "%d ASHMARKS · %d STORED" % [state.money, state.stored_modules.size()],
			"button_status": "TRADES SETTLED" if buy_complete and not sell_available else "BUY / SELL",
			"body": "\n\n".join(trade_lines),
			"tone": "safe" if buy_complete and not sell_available else "neutral"
		}
		if not buy_complete:
			quartermaster_station["primary"] = {"id": "buy_side_armor", "label": "BUY SIDE ARMOR · %d" % buy_price, "enabled": state.money >= buy_price, "tooltip": "Purchase one fixed-stock Side Armor Skirt into storage for %d Ashmarks." % buy_price if state.money >= buy_price else "Requires %d Ashmarks; only %d remain." % [buy_price, state.money]}
		if sell_available:
			quartermaster_station["secondary"] = {"id": "sell_stored_shell_cannon", "label": "SELL STORED CANNON · +%d" % int(sell_offer.get("price", 0)), "enabled": true, "tooltip": "Sell only the uninstalled Shell Cannon. The live chassis cannot be dismantled here."}
		if buy_complete and not sell_available:
			quartermaster_station["primary"] = {"id": "review_supplies", "label": "REVIEW FORTRESS STORES", "enabled": true, "tooltip": "Open the detailed module and capacity view."}
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
			"quartermaster": quartermaster_station,
			"signal_broker": signal_station,
			"hiring_post": {"title": "Hiring Post", "status": "NO CREW AVAILABLE", "button_status": "EMPTY", "body": "Specialists are encountered through authored locations and events. The hiring board is empty at this stop.", "tone": "muted"},
			"assignment_board": assignment_station,
			"departure_gate": {"title": "Departure Gate", "status": "ROUTES READY" if departure_ready else "ASSIGNMENT BLOCKS DEPARTURE", "button_status": "PLAN JOURNEY" if departure_ready else "LOCKED", "body": (("Pump Gallery is the slower managed-water road; Sunken Tramworks is the shorter submerged cut. Open the route table to compare exact costs and intelligence before Commit." if is_veyru else "Rill Crossing is the direct convoy road; Soot Orchard is the longer salvage road. Open the route table to compare exact costs and intelligence before Commit.") if departure_ready else "The settlement requires an answer at the assignment board before it will clear the fortress to leave."), "tone": "safe" if departure_ready else "warning", "primary": {"id": "plan_journey", "label": "PLAN JOURNEY", "enabled": departure_ready, "tooltip": "Open the regional map without committing a route."}}
		}
	}
