class_name LongMarchState
extends RefCounted

## Presentation-independent vertical-slice simulation for The Long March.
## Modules are placed in one chassis grid and interact through explicit dependencies.

const GRID_WIDTH := 6
const GRID_HEIGHT := 4
const MAX_EXTERIOR_MOUNTS := 2
const SAVE_VERSION := 15
const MIN_SUPPORTED_SAVE_VERSION := 4
const VALID_CAMPAIGN_REGIONS := ["ashgate_lowlands", "flooded_veyru", "cinder_spine", "white_salt_expanse"]
const VALID_REGIONAL_DEVELOPMENTS := ["veyru_public_archive_signal", "cinder_communal_lift_plan", "cinder_refuge_chain", "salt_public_beacons", "salt_shared_cisterns"]
const FINAL_RESULTS := ["decisive_march", "scarred_march", "march_failed", "archive_kept", "archive_scarred", "veyru_lost", "spine_powered", "spine_bypassed", "cinder_lost", "expanse_allied", "expanse_crossed", "salt_lost"]
const VALID_CHASSIS_TEMPLATES := ["road_keep", "salt_skimmer", "ridge_crawler"]
const VALID_PHASES := ["refit", "map", "battle", "final_battle", "road_event", "settlement", "results"]
const VALID_SPECIALIST_IDS := ["", "iven_pell", "mara_flint", "sela_vonn", "nera_quill", "orla_nine", "tomas_reed"]
const VALID_CONTRACT_STATUSES := ["unoffered", "offered", "accepted", "declined", "completed", "failed"]
const MASTERY_EXPERIMENTS := {
	"ashgate_quarry_adaptation": {
		"region_id": "ashgate_lowlands",
		"origin_location_id": "ashgate_depot",
		"title": "Quarry Adaptation",
		"brief": "Secure Cinder Quarry with either speed and Run Hot or lower-hull protection and a cargo doctrine.",
		"proof": "Cinder Quarry secured",
		"solutions": ["Run Hot with enough movement and firepower", "Protect Cargo with lower-hull armor"]
	},
	"ashgate_signal_discipline": {
		"region_id": "ashgate_lowlands",
		"origin_location_id": "ashgate_depot",
		"title": "Signal Discipline",
		"brief": "Secure Signal Causeway with either Iven Pell's forecast or an operational Wall Lamp.",
		"proof": "Signal Causeway secured",
		"solutions": ["Recruit Iven Pell after restoring Broken Relay", "Carry and preserve an operational Wall Lamp"]
	},
	"cinder_redundant_lift": {
		"region_id": "cinder_spine",
		"origin_location_id": "blackkiln",
		"title": "Redundant Lift",
		"brief": "Reach the lift engine with a working Generator Core, then choose either the powered lift or the slower human switchback.",
		"proof": "Lift Engine choice resolved with movement intact",
		"solutions": ["Power the old lift with a working Generator Core", "Cut the switchback and preserve another operational engine"]
	},
	"salt_dependency_watch": {
		"region_id": "white_salt_expanse",
		"origin_location_id": "saltglass_haven",
		"title": "Dependency Watch",
		"brief": "Secure one specialist threat road with its physical counter: Command Deck at Salt Mine or Salvage Crane at Empty Mile.",
		"proof": "Dependency counter carried through its authored road",
		"solutions": ["Secure Salt Mine with a Ready Command Deck", "Secure Empty Mile with a Ready Salvage Crane"]
	}
}
const INTEL_OFFERS := {
	"ashgate_orchard_weather_report": {
		"name": "Orchard Weather Report",
		"region_id": "ashgate_lowlands",
		"origin_location_id": "ashgate_depot",
		"subject_node_id": "soot_orchard",
		"source_id": "ashgate_signal_reader",
		"source_name": "Ashgate Signal Reader",
		"confidence": "reliable",
		"revealed_fields": ["threats", "counter_hints"],
		"price": 8
	}
}
const MARKET_BUY_OFFERS := {
	"ashgate_spare_side_armor": {
		"name": "Spare Side Armor Skirt",
		"region_id": "ashgate_lowlands",
		"origin_location_id": "ashgate_depot",
		"module_id": "side_armor_skirt",
		"price": 18
	}
}
const MARKET_SELL_PRICES := {
	"shell_cannon": 14
}
const SPECIALIST_NAMES := {"iven_pell": "Iven Pell", "mara_flint": "Mara Flint", "sela_vonn": "Sela Vonn", "nera_quill": "Dr. Nera Quill", "orla_nine": "Orla Nine", "tomas_reed": "Tomas Reed"}
const CAMPAIGN_DECISION_OPTIONS := {
	"salvage_choice": ["take_fuel", "rescue_workers"],
	"lost_signal": ["restore_relay", "move_silent"],
	"toll_decision": ["pay_toll", "break_blockade"],
	"mara_berth_choice": ["keep_iven", "replace_iven_with_mara"],
	"mara_meeting": ["recruit_mara", "decline_mara"],
	"mara_workbench_choice": ["rebuild_weakest", "brace_refuge"],
	"mara_followup": ["record_repair_held", "record_repair_failed", "record_refuge_held", "record_refuge_failed"],
	"boiler_heartbeat": ["inspect_boiler", "keep_cadence"],
	"lift_chain_sings": ["brace_lift_chain", "carry_lift_load"],
	"the_last_dry_room": ["shelter_in_dry_room", "preserve_dry_parts"],
	"the_miller_with_a_broken_wheel": ["lend_workshop_bench", "keep_moving"],
	"drain_pumps": ["drain_gallery", "leave_gallery"],
	"registry_salvage": ["recover_records", "abandon_records"],
	"archive_broadcast": ["broadcast_archive", "seal_archive"],
	"charcoal_vow": ["bank_coals", "share_coals", "call_refuge_chain"],
	"lift_engine_choice": ["power_lift", "cut_switchback"],
	"commune_design": ["share_lift_plan", "keep_guild_pattern"]
	,"observatory_signal": ["broadcast_beacons", "sell_coordinates", "call_cistern_network"]
	,"rival_terms": ["escort_compact", "race_rival"]
	,"chapel_refuge": ["light_refuge_markers", "strip_chapel_bell"]
	,"trench_cistern": ["share_trench_water", "seal_trench_reserve"]
}
const OCCURRENCE_STREAM_NAME := "ashgate_operational_occurrences_v1"
const OCCURRENCE_HISTORY_LIMIT := 8
const OCCURRENCE_DEFS := {
	"boiler_heartbeat": {"title": "The Boiler's Second Heartbeat", "type": "operational", "phases": ["road_arrival"], "nodes": ["rill_crossing", "lower_ash_road", "dry_cistern_cut", "signal_causeway"], "repeat": "cooldown", "cooldown": 2},
	"lift_chain_sings": {"title": "The Lift Chain Sings", "type": "operational", "phases": ["pre_contact", "road_arrival"], "nodes": ["rill_crossing", "lower_ash_road", "dry_cistern_cut", "signal_causeway"], "repeat": "cooldown", "cooldown": 2},
	"the_last_dry_room": {"title": "The Last Dry Room", "type": "operational", "phases": ["road_arrival", "settlement_arrival"], "nodes": ["rill_crossing", "morrowline_camp", "lower_ash_road", "dry_cistern_cut", "signal_causeway"], "repeat": "once", "cooldown": 0},
	"the_miller_with_a_broken_wheel": {"title": "The Miller With a Broken Wheel", "type": "meeting", "phases": ["road_arrival", "settlement_arrival"], "nodes": ["rill_crossing", "morrowline_camp"], "repeat": "once", "cooldown": 0}
}
const BASE_POWER := 2
const BASE_MASS_LIMIT := 14
const BASE_HEAT_LIMIT := 6
const ROUTES := {
	"safe_road": {"name": "The Long Road", "days": 2, "fuel": 2, "risk": 0.12, "reward": 14},
	"exposed_shortcut": {"name": "The Exposed Cut", "days": 1, "fuel": 2, "risk": 0.42, "reward": 22},
	"salvage_detour": {"name": "The Salvage Detour", "days": 3, "fuel": 3, "risk": 0.28, "reward": 28}
}
const ROUTE_PRESSURE := {"safe_road": 0, "exposed_shortcut": 1, "salvage_detour": 1}
const THREATS := {
	"road_raiders": {"name": "Road Raiders", "target_tags": ["cargo", "exterior"], "damage": 1},
	"climbers": {"name": "Climbers", "target_tags": ["signal", "exterior", "crew"], "damage": 1},
	"burrowers": {"name": "Burrowers", "target_tags": ["engine", "workshop", "lower_hull"], "damage": 2},
	"storm_front": {"name": "Storm Front", "target_tags": ["signal", "exterior", "sustain"], "damage": 1},
	"siege_beast": {"name": "Siege Beast", "target_tags": ["armor", "crew"], "damage": 2},
	"flood_surge": {"name": "Flood Surge", "target_tags": ["lower_hull", "cargo", "sustain"], "damage": 1},
	"civic_guardian": {"name": "Civic Guardian", "target_tags": ["cargo", "signal", "crew", "armor"], "damage": 2},
	"ember_drakes": {"name": "Ember Drakes", "target_tags": ["fuel", "exterior", "sustain"], "damage": 1},
	"lift_saboteurs": {"name": "Lift Saboteurs", "target_tags": ["generator", "workshop", "signal"], "damage": 1},
	"elevator_warden": {"name": "Elevator Warden", "target_tags": ["generator", "engine", "armor"], "damage": 2}
	,"salt_storm": {"name": "Salt Storm", "target_tags": ["water", "signal", "exterior"], "damage": 1}
	,"rival_scouts": {"name": "Rival Scouts", "target_tags": ["cargo", "signal", "engine"], "damage": 1}
	,"rival_fortress": {"name": "Rival Fortress", "target_tags": ["engine", "generator", "weapon", "armor"], "damage": 2}
	,"signal_hunters": {"name": "Signal Hunters", "target_tags": ["signal", "command", "exterior"], "damage": 1}
	,"bridgebreakers": {"name": "Bridgebreakers", "target_tags": ["lower_hull", "engine", "armor"], "damage": 2}
}
const JOURNEY_NODES := {
	"ashgate_depot": {"name": "Ashgate Depot", "kind": "city", "description": "The departure yard: fuel, parts, and one last decision."},
	"rill_crossing": {"name": "Rill Crossing", "kind": "crossing", "description": "A broken bridge where the road narrows between ash channels."},
	"morrowline_camp": {"name": "Morrowline Camp", "kind": "city", "description": "A moving convoy shelter waiting for engines, tools, and protection."},
	"meridian_pass": {"name": "Meridian Pass", "kind": "finale", "description": "The last open road, blocked by a Siege Beast."},
	"soot_orchard": {"name": "The Soot Orchard", "kind": "salvage", "description": "A burning orchard where fuel and stranded workers compete for time."},
	"broken_relay": {"name": "Broken Relay", "kind": "relay", "description": "A dead signal mast watched by Climbers and one stubborn operator."},
	"red_wheel_toll_bridge": {"name": "Red Wheel Toll Bridge", "kind": "ambush", "description": "A fortified crossing where the blockade has learned the fortress silhouette."},
	"lower_ash_road": {"name": "Lower Ash Road", "kind": "hazard", "description": "A buried service road where Burrowers test the lower hull."},
	"dry_cistern_cut": {"name": "Dry Cistern Cut", "kind": "hazard", "description": "A short cistern road where a maintained condenser can recover enough water to spare fuel."},
	"signal_causeway": {"name": "Signal Causeway", "kind": "hazard", "description": "An exposed relay causeway caught inside a moving storm front."},
	"cinder_quarry": {"name": "Cinder Quarry", "kind": "salvage", "description": "A collapsed switchback where raiders hold the rim and Burrowers move beneath abandoned plate stock."},
	"lantern_quay": {"name": "Lantern Quay", "kind": "city", "description": "A flood-edge market where the fortress chooses what it will carry into Veyru."},
	"pump_gallery": {"name": "Pump Gallery", "kind": "hazard", "description": "Old civic pumps offer a slow road above the first flood line."},
	"sunken_tramworks": {"name": "Sunken Tramworks", "kind": "hazard", "description": "A fast submerged rail cut that punishes heavy lower hulls."},
	"veyru_evacuation_camp": {"name": "Evacuation Camp", "kind": "camp", "description": "A raised platform where stranded crews can restore one critical system."},
	"archive_causeway": {"name": "Archive Causeway", "kind": "relay", "description": "A longer signal-marked road that keeps fragile cargo above the water."},
	"drowned_registry": {"name": "Drowned Registry", "kind": "salvage", "description": "A short flooded records hall where salvage and exposed systems compete."},
	"pilgrim_gantry": {"name": "Pilgrim Gantry", "kind": "recovery", "description": "A slow high-water gantry that remains passable after the lower roads close."},
	"dry_archive_gate": {"name": "Dry Archive Gate", "kind": "choice", "description": "The last sealed approach where the archive's signal must be broadcast or hidden."},
	"dry_archive": {"name": "The Dry Archive", "kind": "finale", "description": "The civic vault above the flood line and the chapter's final commitment."},
	"blackkiln": {"name": "Blackkiln", "kind": "city", "description": "A forge town beneath the ridge where every useful machine adds heat to the road."},
	"charcoal_monastery": {"name": "Charcoal Monastery", "kind": "sanctuary", "description": "A slow terrace road whose banked coals can cool or provision the march."},
	"red_cut": {"name": "Red Cut", "kind": "hazard", "description": "A steep exposed grade that rewards a light fortress and punishes hot engines."},
	"old_lift_station": {"name": "Old Lift Station", "kind": "camp", "description": "A broken ore platform where one repair or firebreak can be completed before the climb."},
	"long_slope": {"name": "The Long Slope", "kind": "hazard", "description": "A fuel-hungry ascent under an advancing fireline."},
	"slag_tunnel": {"name": "Slag Tunnel", "kind": "salvage", "description": "A narrow industrial tunnel with rare plate and hidden saboteurs."},
	"ash_chapel_bypass": {"name": "Ash Chapel Bypass", "kind": "recovery", "description": "A low-reward refuge road opened when the fireline closes the tunnel."},
	"lift_engine_house": {"name": "Lift Engine House", "kind": "choice", "description": "The abandoned industrial elevator can be powered or bypassed at a permanent cost."},
	"switchback_commune": {"name": "Switchback Commune", "kind": "finale", "description": "The mountain settlement above the fireline and the chapter's final engineering vote."}
	,"saltglass_haven": {"name": "Saltglass Haven", "kind": "city", "description": "A water-and-signal market where every visible promise travels across the flats."}
	,"buried_observatory": {"name": "Buried Observatory", "kind": "relay", "description": "A half-buried lens station that can warn the whole Expanse or sell one private route."}
	,"quiet_caravan": {"name": "Quiet Caravan", "kind": "convoy", "description": "A slow refugee column carrying water under canvas and no signal fire."}
	,"windbreak": {"name": "The Windbreak", "kind": "camp", "description": "A stone lee wall with enough water for one deliberate recovery."}
	,"salt_mine": {"name": "Salt Mine", "kind": "salvage", "description": "A deep brine shaft with useful stores and no clean horizon."}
	,"empty_mile": {"name": "The Empty Mile", "kind": "hazard", "description": "An exposed straight crossing where speed matters and every silhouette is visible."}
	,"beacon_road": {"name": "Beacon Road", "kind": "relay", "description": "A marked convoy lane that trades concealment for reliable direction."}
	,"lee_trench": {"name": "Lee Trench", "kind": "recovery", "description": "A low-value storm refuge opened when the ash front erases the Empty Mile."}
	,"rival_approach": {"name": "Rival Approach", "kind": "choice", "description": "The final open ground where the Compact and the rival fortress demand a doctrine."}
	,"salt_citadel": {"name": "Salt Citadel", "kind": "finale", "description": "A rival walking fortress holds the last water towers beyond the flats."}
}
const JOURNEY_ENCOUNTERS := {
	"safe_road": ["road_raiders", "road_raiders"],
	"exposed_shortcut": ["road_raiders", "climbers"],
	"salvage_detour": ["burrowers"]
}
const ENCOUNTER_ENEMIES := {
	"road_raiders": {"name": "Road Raider", "health": 5, "damage": 1, "arrival_step": 2, "target_tags": ["cargo", "exterior"], "route": "road flank", "counter": "shell cannon or repeater gun", "counter_modules": ["shell_cannon", "repeater_gun"]},
	"climbers": {"name": "Climber", "health": 4, "damage": 1, "arrival_step": 3, "target_tags": ["signal", "exterior", "crew"], "route": "fortress flank", "counter": "wall lamp or repeater gun", "counter_modules": ["wall_lamp", "repeater_gun"]},
	"burrowers": {"name": "Burrower", "health": 7, "damage": 2, "arrival_step": 3, "target_tags": ["engine", "workshop", "lower_hull"], "route": "under-road", "counter": "lower-hull armor, shifted weapons, or a spare engine", "counter_modules": ["side_armor_skirt", "shell_cannon", "repeater_gun"]},
	"storm_front": {"name": "Storm Front", "health": 7, "damage": 1, "arrival_step": 1, "target_tags": ["signal", "exterior", "sustain"], "route": "weather line", "counter": "signal coverage, adjacent armor, Seal Compartment, or vent heat", "counter_modules": ["signal_coil", "signal_mast", "front_armor_plate", "side_armor_skirt"]},
	"siege_beast": {"name": "Siege Beast", "health": 10, "damage": 3, "arrival_step": 4, "target_tags": ["armor", "crew"], "route": "direct road", "counter": "shell cannon and front armor", "counter_modules": ["shell_cannon", "front_armor_plate"]},
	"flood_surge": {"name": "Flood Surge", "health": 4, "damage": 1, "arrival_step": 1, "target_tags": ["lower_hull", "cargo", "sustain"], "route": "rising waterline", "counter": "Water Condenser, Side Armor Skirt, Field Workshop, or Seal Compartment", "counter_modules": ["water_condenser", "side_armor_skirt", "field_workshop"]},
	"civic_guardian": {"name": "Civic Guardian", "health": 10, "damage": 2, "arrival_step": 3, "target_tags": ["cargo", "signal", "crew", "armor"], "route": "archive gate", "counter": "Shell Cannon, protected cargo, or redundant signal and crew systems", "counter_modules": ["shell_cannon", "front_armor_plate", "signal_coil"]},
	"ember_drakes": {"name": "Ember Drake", "health": 5, "damage": 1, "arrival_step": 4, "target_tags": ["fuel", "exterior", "sustain"], "route": "fireline above", "counter": "Wall Lamp, Repeater Gun, Water Condenser, or Vent Heat", "counter_modules": ["wall_lamp", "repeater_gun", "water_condenser", "shell_cannon"]},
	"lift_saboteurs": {"name": "Lift Saboteur", "health": 6, "damage": 1, "arrival_step": 3, "target_tags": ["generator", "workshop", "signal"], "route": "industrial gantry", "counter": "Repeater Gun, crew-connected Workshop, or adjacent armor", "counter_modules": ["repeater_gun", "field_workshop", "front_armor_plate", "side_armor_skirt"]},
	"elevator_warden": {"name": "Elevator Warden", "health": 10, "damage": 2, "arrival_step": 4, "target_tags": ["generator", "engine", "armor"], "route": "lift counterweight", "counter": "Shell Cannon, protected Generator Core, or Cut Switchback", "counter_modules": ["shell_cannon", "front_armor_plate", "side_armor_skirt"]}
	,"salt_storm": {"name": "Salt Storm", "health": 5, "damage": 1, "arrival_step": 2, "target_tags": ["water", "signal", "exterior"], "route": "white horizon", "counter": "Water Condenser, protected signal, or Seal Compartment", "counter_modules": ["water_condenser", "signal_coil", "wall_lamp", "side_armor_skirt"]}
	,"rival_scouts": {"name": "Rival Scouts", "health": 6, "damage": 1, "arrival_step": 3, "target_tags": ["cargo", "signal", "engine"], "route": "open flank", "counter": "Repeater Gun, Signal Coil, or a light engine", "counter_modules": ["repeater_gun", "signal_coil", "ash_runner_engine"]}
	,"rival_fortress": {"name": "Rival Fortress", "health": 11, "damage": 2, "arrival_step": 3, "target_tags": ["engine", "generator", "weapon", "armor"], "route": "parallel march", "counter": "redundant systems, Shell Cannon, or escort beacons", "counter_modules": ["shell_cannon", "front_armor_plate", "side_armor_skirt", "signal_coil"]}
	,"signal_hunters": {"name": "Signal Hunter", "health": 6, "damage": 1, "arrival_step": 3, "target_tags": ["signal", "command", "exterior"], "route": "reflected beacon line", "counter": "Command Deck, Repeater Gun, or protected signal", "counter_modules": ["command_deck", "repeater_gun", "side_armor_skirt"]}
	,"bridgebreakers": {"name": "Bridgebreaker", "health": 8, "damage": 2, "arrival_step": 3, "target_tags": ["lower_hull", "engine", "armor"], "route": "salt crust below", "counter": "Shell Cannon, side armor, or Salvage Crane bracing", "counter_modules": ["shell_cannon", "side_armor_skirt", "salvage_crane"]}
}
const CAMPAIGN_NODES := {
	"ashgate_depot": {"name": "Ashgate Depot", "type": "settlement", "visibility": "known", "description": "Refit, choose the first guard contract, and leave before the blockade closes."},
	"rill_crossing": {"name": "Rill Crossing", "type": "ambush", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.14, "pressure": 1, "reward": 12, "threat_hint": "cargo raiders", "encounter": ["road_raiders"]},
	"soot_orchard": {"name": "The Soot Orchard", "type": "salvage", "visibility": "forecast", "days": 2, "fuel": 1, "risk": 0.22, "pressure": 1, "reward": 10, "mass_sensitive": true, "threat_hint": "fire and weather", "encounter": ["storm_front"]},
	"broken_relay": {"name": "Broken Relay", "type": "relay", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.24, "pressure": 1, "reward": 14, "threat_hint": "upper-hull movement", "encounter": ["climbers"]},
	"red_wheel_toll_bridge": {"name": "Red Wheel Toll Bridge", "type": "ambush", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.36, "pressure": 2, "reward": 24, "threat_hint": "organized blockade", "encounter": ["road_raiders", "climbers"]},
	"morrowline_camp": {"name": "Morrowline Camp", "type": "settlement", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.28, "pressure": 1, "reward": 16, "threat_hint": "raiders on the convoy approach", "encounter": ["road_raiders"]},
	"lower_ash_road": {"name": "Lower Ash Road", "type": "hazard", "visibility": "forecast", "days": 2, "fuel": 1, "risk": 0.38, "pressure": 2, "reward": 24, "mass_sensitive": true, "threat_hint": "movement below the road", "encounter": ["burrowers"]},
	"dry_cistern_cut": {"name": "Dry Cistern Cut", "type": "hazard", "visibility": "forecast", "days": 1, "fuel": 2, "risk": 0.28, "pressure": 1, "reward": 18, "threat_hint": "dry weather line", "encounter": ["storm_front"]},
	"signal_causeway": {"name": "Signal Causeway", "type": "hazard", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.43, "pressure": 2, "reward": 20, "threat_hint": "weather and exposed approaches", "encounter": ["storm_front", "climbers"]},
	"cinder_quarry": {"name": "Cinder Quarry", "type": "salvage", "visibility": "forecast", "days": 1, "fuel": 2, "risk": 0.48, "pressure": 1, "reward": 18, "threat_hint": "raiders above and movement below", "encounter": ["road_raiders", "burrowers"], "route_effect": "Victory restores 2 durability to the weakest damaged system; if none is damaged, spare plate sells for 8 Ashmarks"},
	"meridian_pass": {"name": "Meridian Pass", "type": "boss", "visibility": "known", "days": 2, "fuel": 2, "risk": 0.58, "pressure": 2, "reward": 40, "threat_hint": "Siege Beast", "encounter": ["siege_beast"]},
	"lantern_quay": {"name": "Lantern Quay", "type": "settlement", "visibility": "known", "description": "Choose the medicine contract and prepare for rising water."},
	"pump_gallery": {"name": "Pump Gallery", "type": "hazard", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.22, "pressure": 2, "reward": 12, "threat_hint": "rising water", "encounter": ["flood_surge"]},
	"sunken_tramworks": {"name": "Sunken Tramworks", "type": "hazard", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.34, "pressure": 1, "reward": 18, "mass_sensitive": true, "threat_hint": "submerged rail movement", "encounter": ["burrowers"]},
	"veyru_evacuation_camp": {"name": "Evacuation Camp", "type": "settlement", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.2, "pressure": 1, "reward": 8, "threat_hint": "flooded approach", "encounter": ["flood_surge"]},
	"archive_causeway": {"name": "Archive Causeway", "type": "relay", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.25, "pressure": 1, "reward": 14, "threat_hint": "signal-marked high road", "encounter": ["flood_surge"]},
	"drowned_registry": {"name": "Drowned Registry", "type": "salvage", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.42, "pressure": 2, "reward": 20, "threat_hint": "flooded records and upper movement", "encounter": ["flood_surge", "climbers"]},
	"pilgrim_gantry": {"name": "Pilgrim Gantry", "type": "recovery", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.18, "pressure": -1, "reward": 0, "threat_hint": "reduced flood surge", "encounter": ["flood_surge"]},
	"dry_archive_gate": {"name": "Dry Archive Gate", "type": "choice", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.36, "pressure": 1, "reward": 12, "threat_hint": "flood and archive defenses", "encounter": ["flood_surge", "climbers"]},
	"dry_archive": {"name": "The Dry Archive", "type": "boss", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.56, "pressure": 1, "reward": 36, "threat_hint": "Civic Guardian", "encounter": ["civic_guardian"]},
	"blackkiln": {"name": "Blackkiln", "type": "settlement", "visibility": "known", "description": "Choose the Guild dynamo contract and prepare for the Cinder Spine."},
	"charcoal_monastery": {"name": "Charcoal Monastery", "type": "sanctuary", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.2, "pressure": 1, "reward": 10, "threat_hint": "embers above the terraces", "encounter": ["ember_drakes"]},
	"red_cut": {"name": "Red Cut", "type": "hazard", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.34, "pressure": 2, "reward": 18, "mass_sensitive": true, "threat_hint": "steep grade and exposed fuel", "encounter": ["ember_drakes"]},
	"old_lift_station": {"name": "Old Lift Station", "type": "settlement", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.28, "pressure": 1, "reward": 12, "threat_hint": "saboteurs in the ore gantry", "encounter": ["lift_saboteurs"]},
	"long_slope": {"name": "The Long Slope", "type": "hazard", "visibility": "known", "days": 2, "fuel": 2, "risk": 0.3, "pressure": 1, "reward": 14, "mass_sensitive": true, "threat_hint": "fireline and fuel strain", "encounter": ["ember_drakes"]},
	"slag_tunnel": {"name": "Slag Tunnel", "type": "salvage", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.46, "pressure": 2, "reward": 22, "threat_hint": "embers and industrial sabotage", "encounter": ["ember_drakes", "lift_saboteurs"]},
	"ash_chapel_bypass": {"name": "Ash Chapel Bypass", "type": "recovery", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.18, "pressure": -1, "reward": 0, "threat_hint": "sheltered ember drift", "encounter": ["ember_drakes"]},
	"lift_engine_house": {"name": "Lift Engine House", "type": "choice", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.4, "pressure": 1, "reward": 16, "threat_hint": "saboteurs around the dynamo", "encounter": ["lift_saboteurs", "ember_drakes"]},
	"switchback_commune": {"name": "Switchback Commune", "type": "boss", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.56, "pressure": 1, "reward": 36, "threat_hint": "Elevator Warden", "encounter": ["elevator_warden"]}
	,"saltglass_haven": {"name": "Saltglass Haven", "type": "settlement", "visibility": "known", "description": "Choose the beacon escort and a fortress template before crossing the open salt."}
	,"buried_observatory": {"name": "Buried Observatory", "type": "relay", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.20, "pressure": 1, "reward": 10, "threat_hint": "salt weather", "encounter": ["salt_storm"]}
	,"quiet_caravan": {"name": "Quiet Caravan", "type": "convoy", "visibility": "forecast", "days": 1, "fuel": 2, "risk": 0.30, "pressure": 1, "reward": 16, "threat_hint": "rival scouts", "encounter": ["rival_scouts"]}
	,"windbreak": {"name": "The Windbreak", "type": "settlement", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.22, "pressure": 1, "reward": 10, "threat_hint": "salt storm", "encounter": ["salt_storm"]}
	,"salt_mine": {"name": "Salt Mine", "type": "salvage", "visibility": "unscouted", "days": 2, "fuel": 1, "risk": 0.42, "pressure": 2, "reward": 22, "threat_hint": "signal hunters in the brine shafts", "encounter": ["salt_storm", "signal_hunters"]}
	,"empty_mile": {"name": "The Empty Mile", "type": "hazard", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.38, "pressure": 2, "reward": 18, "threat_hint": "bridgebreakers on open ground", "encounter": ["bridgebreakers"]}
	,"beacon_road": {"name": "Beacon Road", "type": "relay", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.24, "pressure": 1, "reward": 12, "threat_hint": "salt weather", "encounter": ["salt_storm"]}
	,"lee_trench": {"name": "Lee Trench", "type": "recovery", "visibility": "known", "days": 2, "fuel": 1, "risk": 0.18, "pressure": -1, "reward": 0, "threat_hint": "sheltered scouts", "encounter": ["rival_scouts"]}
	,"rival_approach": {"name": "Rival Approach", "type": "choice", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.40, "pressure": 1, "reward": 16, "threat_hint": "rival screen", "encounter": ["rival_scouts", "salt_storm"]}
	,"salt_citadel": {"name": "Salt Citadel", "type": "boss", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.58, "pressure": 1, "reward": 38, "threat_hint": "Rival Fortress", "encounter": ["rival_fortress"]}
}
const CAMPAIGN_EDGES := {
	"ashgate_depot": ["rill_crossing", "soot_orchard"],
	"rill_crossing": ["broken_relay", "red_wheel_toll_bridge"],
	"soot_orchard": ["broken_relay", "red_wheel_toll_bridge"],
	"broken_relay": ["morrowline_camp"],
	"red_wheel_toll_bridge": ["morrowline_camp"],
	"morrowline_camp": ["lower_ash_road", "dry_cistern_cut", "signal_causeway", "cinder_quarry"],
	"lower_ash_road": ["meridian_pass"],
	"dry_cistern_cut": ["meridian_pass"],
	"signal_causeway": ["meridian_pass"],
	"cinder_quarry": ["meridian_pass"]
}
const VEYRU_EDGES := {
	"lantern_quay": ["pump_gallery", "sunken_tramworks"],
	"pump_gallery": ["veyru_evacuation_camp"],
	"sunken_tramworks": ["veyru_evacuation_camp"],
	"veyru_evacuation_camp": ["archive_causeway", "drowned_registry", "pilgrim_gantry"],
	"archive_causeway": ["dry_archive_gate"],
	"drowned_registry": ["dry_archive_gate"],
	"pilgrim_gantry": ["dry_archive_gate"],
	"dry_archive_gate": ["dry_archive"]
}
const CINDER_EDGES := {
	"blackkiln": ["charcoal_monastery", "red_cut"],
	"charcoal_monastery": ["old_lift_station"],
	"red_cut": ["old_lift_station"],
	"old_lift_station": ["long_slope", "slag_tunnel", "ash_chapel_bypass"],
	"long_slope": ["lift_engine_house"],
	"slag_tunnel": ["lift_engine_house"],
	"ash_chapel_bypass": ["lift_engine_house"],
	"lift_engine_house": ["switchback_commune"]
}
const SALT_EDGES := {
	"saltglass_haven": ["buried_observatory", "quiet_caravan"],
	"buried_observatory": ["windbreak"],
	"quiet_caravan": ["windbreak"],
	"windbreak": ["salt_mine", "empty_mile", "beacon_road", "lee_trench"],
	"salt_mine": ["rival_approach"],
	"empty_mile": ["rival_approach"],
	"beacon_road": ["rival_approach"],
	"lee_trench": ["rival_approach"],
	"rival_approach": ["salt_citadel"]
}
const MODULE_DEFS := {
	"steam_lance_engine": {"name": "Steam Lance Engine", "family": "engine", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 0, "heat": 1, "durability": 4, "tags": ["engine", "fuel_sensitive"], "capability": "Keeps the fortress moving while adjacent to a fuel module."},
	"ash_runner_engine": {"name": "Ash Runner Engine", "family": "engine", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 0, "power_output": 0, "heat": 2, "durability": 3, "tags": ["engine", "fast", "hot"], "capability": "Provides compact movement at lower mass but adds more heat; requires adjacent fuel."},
	"coal_cell": {"name": "Coal Cell", "family": "cargo", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 2, "tags": ["fuel", "cargo"], "capability": "Feeds adjacent engines and counts as cargo for enemy targeting and sacrifice."},
	"generator_core": {"name": "Generator Core", "family": "crew_room", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 4, "heat": 2, "durability": 4, "tags": ["generator", "critical"], "capability": "Adds 4 power to the shared bus; losing it can disable every powered system."},
	"shell_cannon": {"name": "Shell Cannon", "family": "weapon", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 2, "power_output": 0, "heat": 2, "durability": 3, "tags": ["weapon", "exterior", "burst"], "capability": "Deals 3 damage to Raiders and Siege Beasts; needs adjacent ammunition for full output."},
	"repeater_gun": {"name": "Repeater Gun", "family": "weapon", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 2, "tags": ["weapon", "exterior", "suppress"], "capability": "Deals 2 damage to Raiders and Climbers; needs adjacent ammunition for full output."},
	"ammunition_lift": {"name": "Ammunition Lift", "family": "workshop", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["ammunition", "dependency"], "capability": "Lets adjacent weapons fire at full output instead of using emergency rounds."},
	"field_workshop": {"name": "Field Workshop", "family": "workshop", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 3, "tags": ["repair", "workshop", "crew"], "capability": "Repairs the weakest damaged system after combat steps; needs adjacent crew."},
	"signal_coil": {"name": "Signal Coil", "family": "signal", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 2, "tags": ["signal", "forecast"], "capability": "Reveals exact route contacts and reduces route risk while Ready."},
	"wall_lamp": {"name": "Wall Lamp", "family": "signal", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 2, "tags": ["signal", "exterior", "climber_counter"], "capability": "Exposes Climber routes for 2 damage and provides clear exterior visibility."},
	"front_armor_plate": {"name": "Front Armor Plate", "family": "armor", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 6, "tags": ["armor", "front"], "capability": "Absorbs 1 damage aimed at an adjacent system and resists direct Siege Beast hits."},
	"side_armor_skirt": {"name": "Side Armor Skirt", "family": "armor", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 4, "tags": ["armor", "side", "lower_hull"], "capability": "Absorbs adjacent hits and intercepts up to 2 damage from Burrowers."},
	"crew_quarters": {"name": "Crew Quarters", "family": "crew_room", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 4, "tags": ["crew", "life_support"], "capability": "Staffs adjacent workshops and provides the crew space Iven Pell requires."},
	"parts_crate": {"name": "Parts Crate", "family": "cargo", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 2, "tags": ["parts", "cargo"], "capability": "Lets an adjacent Field Workshop restore 2 durability instead of 1."},
	"refugee_bunk": {"name": "Refugee Bunk", "family": "cargo", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["refuge", "cargo", "life_support"], "capability": "Unlocks shelter and rescue choices, but remains valuable cargo to Raiders."},
	"signal_mast": {"name": "Signal Mast", "family": "signal", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["signal", "exterior", "long_range"], "capability": "Reveals exact contacts and cuts 2 Storm Front pressure while Ready."},
	"water_condenser": {"name": "Water Condenser", "family": "sustain", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 2, "durability": 3, "tags": ["sustain", "water", "storm_target"], "capability": "Unlocks the Dry Cistern Cut and saves 1 fuel there while powered beside an operational Field Workshop."}
	,"infirmary": {"name": "Field Infirmary", "family": "medical", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["medical", "crew_support"], "capability": "Reduces crew and refuge damage while staffed beside Crew Quarters; enables Dr. Nera Quill."}
	,"command_deck": {"name": "Command Deck", "family": "command", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 3, "tags": ["command", "crew_support"], "capability": "Improves committed doctrine while staffed beside Crew Quarters; enables Sela Vonn."}
	,"salvage_crane": {"name": "Salvage Crane", "family": "recovery", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["recovery", "exterior", "brace"], "capability": "Braces Bridgebreaker contact and recovers exposed salvage, but consumes an exterior mount."}
}

var seed: int = 1107
var day: int = 1
var fuel: int = 6
var money: int = 80
var command_points: int = 2
var heat: int = 0
var hull_condition: int = 10
var current_location: String = "ashgate_depot"
var route_risk_modifier: float = 0.0
var current_route_risk: float = 0.0
var encounter_pressure: int = 0
var pending_route_reward: int = 0
var target_doctrine: String = "protect_cargo"
var power_priority: String = "balanced"
var heat_relief: int = 0
var heat_surge: int = 0
var vent_exposure: bool = false
var modules: Array = []
var stored_modules: Array = []
var log: Array[String] = []
var journey_node: String = "ashgate_depot"
var journey_destination: String = "morrowline_camp"
var journey_route: String = ""
var journey_complete: bool = false
var encounter_active: bool = false
var encounter_step: int = 0
var encounter_progress: float = 0.0
var encounter_enemies: Array = []
var encounter_report: Array[String] = []
var encounter_outcome: String = ""
var encounter_intervention_used: bool = false
var encounter_target_doctrine: String = "protect_cargo"
var phase: String = "refit"
var journey_leg: int = 0
var run_complete: bool = false
var final_result: String = ""
var settlement_actions_remaining: int = 0
var settlement_report: Array[String] = []
var campaign_active: bool = false
var campaign_region_id: String = "ashgate_lowlands"
var campaign_encounters_completed: int = 0
var campaign_path: Array[String] = []
var campaign_target_node: String = ""
var campaign_last_safe_node: String = "ashgate_depot"
var campaign_pressure: int = 0
var campaign_retreats: int = 0
var campaign_event_pending: String = ""
var campaign_decisions: Dictionary = {}
var occurrence_stream_cursor: int = 0
var occurrence_active_phase: String = ""
var occurrence_phase_history: Array[String] = []
var occurrence_history: Array[Dictionary] = []
var occurrence_cooldowns: Dictionary = {}
var guard_contract_status: String = "unoffered"
var veyru_contract_status: String = "unoffered"
var veyru_medicine_carrier_id: String = ""
var cinder_contract_status: String = "unoffered"
var salt_contract_status: String = "unoffered"
var chassis_template_id: String = "road_keep"
var settlement_trust: int = 0
var mobility_tendency: int = 0
var shelter_tendency: int = 0
var knowledge_tendency: int = 0
var industry_tendency: int = 0
var specialist_id: String = ""
var mara_repaired_module_id: String = ""
var relay_repaired: bool = false
var workers_rescued: bool = false
var regional_developments: Array[String] = []
var mastery_experiment_id: String = ""
var acquired_intel_ids: Array[String] = []
var purchased_market_offer_ids: Array[String] = []

func _init(world_seed: int = 1107) -> void:
	seed = world_seed

func module_definition(module_id: String) -> Dictionary:
	return MODULE_DEFS.get(module_id, {})

func chassis_mass_limit() -> int:
	return 13 if chassis_template_id == "salt_skimmer" else (15 if chassis_template_id == "ridge_crawler" else BASE_MASS_LIMIT)

func chassis_exterior_limit() -> int:
	return 3 if chassis_template_id == "salt_skimmer" else MAX_EXTERIOR_MOUNTS

func chassis_cell_available(cell: Vector2i) -> bool:
	if chassis_template_id == "salt_skimmer":
		return cell not in [Vector2i(0, 3), Vector2i(5, 3)]
	if chassis_template_id == "ridge_crawler":
		return cell not in [Vector2i(0, 3), Vector2i(1, 3)]
	return true

func choose_chassis_template(template_id: String) -> Dictionary:
	if template_id not in VALID_CHASSIS_TEMPLATES:
		return {"ok": false, "reason": "unknown chassis template"}
	if not modules.is_empty():
		return {"ok": false, "reason": "choose a chassis template before installing modules"}
	chassis_template_id = template_id
	return {"ok": true, "template_id": chassis_template_id, "mass_limit": chassis_mass_limit(), "exterior_limit": chassis_exterior_limit()}

func specialist_name() -> String:
	return String(SPECIALIST_NAMES.get(specialist_id, "None" if specialist_id.is_empty() else specialist_id.replace("_", " ").capitalize()))

func assign_specialist(candidate_id: String) -> Dictionary:
	if candidate_id not in ["sela_vonn", "nera_quill", "orla_nine", "tomas_reed"]:
		return {"ok": false, "reason": "specialist is not available through this assignment"}
	if phase not in ["refit", "settlement"] or not campaign_active:
		return {"ok": false, "reason": "specialists can only join while the fortress is at rest"}
	if not specialist_id.is_empty():
		return {"ok": false, "reason": "the specialist berth is already occupied"}
	var required_modules := {"sela_vonn": "command_deck", "nera_quill": "infirmary", "orla_nine": "ash_runner_engine", "tomas_reed": "field_workshop"}
	var required_module := String(required_modules.get(candidate_id, ""))
	if candidate_id == "orla_nine":
		required_module = _operational_module_id_with_tag("engine")
	var requirement_ready := not required_module.is_empty() and operational(required_module)
	if not requirement_ready:
		return {"ok": false, "reason": "%s requires a Ready %s" % [SPECIALIST_NAMES[candidate_id], "engine" if candidate_id == "orla_nine" else module_definition(required_module).name]}
	specialist_id = candidate_id
	log.append("%s joins the fortress and staffs %s." % [specialist_name(), module_definition(required_module).name])
	return {"ok": true, "specialist": specialist_id, "message": "%s is now assigned to the %s." % [specialist_name(), module_definition(required_module).name], "summary": summary()}

func choose_mastery_experiment(experiment_id: String) -> Dictionary:
	if experiment_id not in MASTERY_EXPERIMENTS:
		return {"ok": false, "reason": "unknown field experiment"}
	var definition: Dictionary = MASTERY_EXPERIMENTS[experiment_id]
	if not campaign_active or campaign_region_id != String(definition.get("region_id", "")) or current_location != String(definition.get("origin_location_id", "")) or phase != "refit" or campaign_encounters_completed != 0:
		return {"ok": false, "reason": "field experiments can only be chosen at their chapter's starting settlement before the first road"}
	mastery_experiment_id = experiment_id
	var details := mastery_experiment_details()
	var message := "Field experiment selected: %s. %s No reward or unlock is attached; the order is a replay goal." % [String(details.get("title", "Experiment")), String(details.get("brief", ""))]
	log.append(message)
	return {"ok": true, "id": mastery_experiment_id, "message": message, "experiment": details}

func mastery_experiment_details() -> Dictionary:
	if mastery_experiment_id.is_empty() or mastery_experiment_id not in MASTERY_EXPERIMENTS:
		return {"id": "", "active": false, "status": "UNASSIGNED", "proven": false}
	var details: Dictionary = Dictionary(MASTERY_EXPERIMENTS[mastery_experiment_id]).duplicate(true)
	var proven := false
	match mastery_experiment_id:
		"ashgate_quarry_adaptation":
			proven = "cinder_quarry" in campaign_path
		"ashgate_signal_discipline":
			proven = "signal_causeway" in campaign_path
		"cinder_redundant_lift":
			proven = campaign_decisions.has("lift_engine_choice") and _has_engine() and (String(campaign_decisions.get("lift_engine_choice", "")) != "power_lift" or operational("generator_core"))
		"salt_dependency_watch":
			proven = ("salt_mine" in campaign_path and operational("command_deck")) or ("empty_mile" in campaign_path and operational("salvage_crane"))
	details["id"] = mastery_experiment_id
	details["active"] = true
	details["proven"] = proven
	details["status"] = "PROVEN" if proven else ("INCOMPLETE" if run_complete else "ACTIVE")
	return details

func intel_offer(intel_id: String) -> Dictionary:
	if intel_id not in INTEL_OFFERS:
		return {}
	var offer: Dictionary = Dictionary(INTEL_OFFERS[intel_id]).duplicate(true)
	offer["id"] = intel_id
	offer["acquired"] = intel_id in acquired_intel_ids
	return offer

func active_settlement_intel_offer() -> Dictionary:
	for intel_id in INTEL_OFFERS:
		var offer := intel_offer(String(intel_id))
		if String(offer.get("region_id", "")) == campaign_region_id and String(offer.get("origin_location_id", "")) == current_location:
			return offer
	return {}

func purchase_intel(intel_id: String) -> Dictionary:
	var offer := intel_offer(intel_id)
	if offer.is_empty():
		return {"ok": false, "reason": "unknown information offer"}
	if not campaign_active or phase not in ["refit", "settlement"] or encounter_active:
		return {"ok": false, "reason": "information can only be purchased while the fortress is at rest"}
	if campaign_region_id != String(offer.get("region_id", "")) or current_location != String(offer.get("origin_location_id", "")):
		return {"ok": false, "reason": "this report is not available at the current settlement"}
	if intel_id in acquired_intel_ids:
		return {"ok": false, "reason": "this report is already in the route ledger"}
	var price := int(offer.get("price", 0))
	if money < price:
		return {"ok": false, "reason": "requires %d Ashmarks; only %d remain" % [price, money]}
	money -= price
	acquired_intel_ids.append(intel_id)
	acquired_intel_ids.sort()
	var message := "%s purchased for %d Ashmarks. %s marks its source %s and reveals only the authored contact report." % [String(offer.get("name", "Report")), price, String(offer.get("source_name", "The source")), String(offer.get("confidence", "unknown")).to_upper()]
	log.append(message)
	return {"ok": true, "intel": intel_offer(intel_id), "cost": price, "remaining_money": money, "message": message}

func acquired_intel_for_node(node_id: String) -> Dictionary:
	for intel_id in acquired_intel_ids:
		var offer := intel_offer(intel_id)
		if String(offer.get("subject_node_id", "")) == node_id:
			return offer
	return {}

func market_buy_offer(offer_id: String) -> Dictionary:
	if offer_id not in MARKET_BUY_OFFERS:
		return {}
	var offer: Dictionary = Dictionary(MARKET_BUY_OFFERS[offer_id]).duplicate(true)
	var module_id := String(offer.get("module_id", ""))
	offer["id"] = offer_id
	offer["module"] = module_definition(module_id).duplicate(true)
	offer["purchased"] = offer_id in purchased_market_offer_ids
	return offer

func active_settlement_market_buy_offer() -> Dictionary:
	for offer_id in MARKET_BUY_OFFERS:
		var offer := market_buy_offer(String(offer_id))
		if String(offer.get("region_id", "")) == campaign_region_id and String(offer.get("origin_location_id", "")) == current_location:
			return offer
	return {}

func buy_market_offer(offer_id: String) -> Dictionary:
	var offer := market_buy_offer(offer_id)
	if offer.is_empty():
		return {"ok": false, "reason": "unknown market offer"}
	if not campaign_active or phase not in ["refit", "settlement"] or encounter_active:
		return {"ok": false, "reason": "market trades require the fortress to be at rest"}
	if campaign_region_id != String(offer.get("region_id", "")) or current_location != String(offer.get("origin_location_id", "")):
		return {"ok": false, "reason": "this stock is not available at the current settlement"}
	if offer_id in purchased_market_offer_ids:
		return {"ok": false, "reason": "this fixed-stock item has already been purchased"}
	var module_id := String(offer.get("module_id", ""))
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {"ok": false, "reason": "market offer references an unknown module"}
	var price := int(offer.get("price", 0))
	if money < price:
		return {"ok": false, "reason": "requires %d Ashmarks; only %d remain" % [price, money]}
	var storage_before := stored_modules.size()
	money -= price
	purchased_market_offer_ids.append(offer_id)
	purchased_market_offer_ids.sort()
	stored_modules.append(module_instance(module_id, Vector2i(-1, -1), "exterior" in definition.get("tags", []), false))
	var message := "%s purchased for %d Ashmarks and placed in storage. Installation remains a separate workshop action." % [String(offer.get("name", definition.get("name", module_id))), price]
	log.append(message)
	return {"ok": true, "offer": market_buy_offer(offer_id), "module_id": module_id, "cost": price, "remaining_money": money, "storage_before": storage_before, "storage_after": stored_modules.size(), "message": message}

func market_sell_preview(module_id: String) -> Dictionary:
	if module_id not in MARKET_SELL_PRICES:
		return {}
	var definition := module_definition(module_id)
	return {
		"module_id": module_id,
		"name": String(definition.get("name", module_id)),
		"price": int(MARKET_SELL_PRICES[module_id]),
		"available": stored_module_count(module_id) > 0,
		"stored_count": stored_module_count(module_id),
		"module": definition.duplicate(true)
	}

func sell_stored_module_at_market(module_id: String) -> Dictionary:
	if not campaign_active or phase not in ["refit", "settlement"] or encounter_active:
		return {"ok": false, "reason": "market trades require the fortress to be at rest"}
	if campaign_region_id != "ashgate_lowlands" or current_location != "ashgate_depot":
		return {"ok": false, "reason": "this buyer is not available at the current settlement"}
	var preview := market_sell_preview(module_id)
	if preview.is_empty():
		return {"ok": false, "reason": "the quartermaster has no standing offer for that module"}
	var stored_index := -1
	for index in range(stored_modules.size()):
		if String(stored_modules[index].get("id", "")) == module_id:
			stored_index = index
			break
	if stored_index < 0:
		return {"ok": false, "reason": "%s is not in storage; installed systems cannot be sold" % String(preview.get("name", "module"))}
	var storage_before := stored_modules.size()
	var sold: Dictionary = stored_modules[stored_index].duplicate(true)
	stored_modules.remove_at(stored_index)
	var price := int(preview.get("price", 0))
	money += price
	var message := "%s sold from storage for %d Ashmarks. No installed system was removed." % [String(preview.get("name", module_id)), price]
	log.append(message)
	return {"ok": true, "module": sold, "module_id": module_id, "price": price, "remaining_money": money, "storage_before": storage_before, "storage_after": stored_modules.size(), "message": message}

func module_shape(module_id: String, rotated: bool = false) -> Vector2i:
	var definition := module_definition(module_id)
	var shape: Vector2i = definition.get("shape", Vector2i.ONE)
	if rotated and shape.x != shape.y:
		return Vector2i(shape.y, shape.x)
	return shape

func module_instance(module_id: String, position: Vector2i, exterior: bool = false, rotated: bool = false) -> Dictionary:
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {}
	return {
		"id": module_id,
		"position": position,
		"exterior": exterior,
		"rotated": rotated,
		"durability": int(definition.get("durability", 1)),
		"sealed": false
	}

func occupied_cells(instance: Dictionary) -> Array[Vector2i]:
	var shape := module_shape(String(instance.get("id", "")), bool(instance.get("rotated", false)))
	var result: Array[Vector2i] = []
	var origin: Vector2i = instance.get("position", Vector2i.ZERO)
	for y in range(shape.y):
		for x in range(shape.x):
			result.append(origin + Vector2i(x, y))
	return result

func validate_module_placement(module_id: String, position: Vector2i, exterior: bool = false, rotated: bool = false, ignore_index: int = -1) -> Dictionary:
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {"ok": false, "reason": "unknown module"}
	var tags: Array = definition.get("tags", [])
	if "exterior" in tags and not exterior:
		return {"ok": false, "reason": "module requires an exterior mount"}
	if exterior and not ("exterior" in tags):
		return {"ok": false, "reason": "module cannot use an exterior mount"}
	var instance := module_instance(module_id, position, exterior, rotated)
	for cell in occupied_cells(instance):
		if cell.x < 0 or cell.x >= GRID_WIDTH or cell.y < 0 or cell.y >= GRID_HEIGHT:
			return {"ok": false, "reason": "module is outside the chassis grid"}
		if not chassis_cell_available(cell):
			return {"ok": false, "reason": "module overlaps a cut-away chassis cell"}
		if _cell_occupied(cell, ignore_index):
			return {"ok": false, "reason": "module overlaps an existing module"}
	if exterior and not _has_exterior_capacity(ignore_index):
		return {"ok": false, "reason": "exterior mount capacity exceeded"}
	var placement_mass := total_mass()
	if ignore_index >= 0 and ignore_index < modules.size():
		placement_mass -= int(module_definition(String(modules[ignore_index].get("id", ""))).get("mass", 0))
	if placement_mass + int(definition.get("mass", 0)) > chassis_mass_limit():
		return {"ok": false, "reason": "mass limit exceeded"}
	return {"ok": true, "module": instance.duplicate(true)}

func place_module(module_id: String, position: Vector2i, exterior: bool = false, rotated: bool = false) -> Dictionary:
	var validation := validate_module_placement(module_id, position, exterior, rotated)
	if not bool(validation.get("ok", false)):
		return validation
	var definition := module_definition(module_id)
	var instance: Dictionary = validation.module
	modules.append(instance)
	_recalculate()
	log.append("Installed %s." % String(definition.get("name", module_id)))
	return {"ok": true, "module": instance.duplicate(true), "summary": summary()}

func remove_module(module_id: String) -> Dictionary:
	for index in range(modules.size()):
		if String(modules[index].get("id", "")) == module_id:
			var removed: Dictionary = modules[index]
			modules.remove_at(index)
			_recalculate()
			log.append("Removed %s." % module_id)
			return {"ok": true, "module": removed.duplicate(true)}
	return {"ok": false, "reason": "module not installed"}

func module_at(cell: Vector2i) -> Dictionary:
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if cell in occupied_cells(instance):
			var result := instance.duplicate(true)
			result["index"] = index
			return result
	return {}

func remove_module_at(cell: Vector2i) -> Dictionary:
	var found := module_at(cell)
	if found.is_empty():
		return {"ok": false, "reason": "no module at that cell"}
	var index := int(found.get("index", -1))
	if index < 0 or index >= modules.size():
		return {"ok": false, "reason": "module index is invalid"}
	var removed: Dictionary = modules[index]
	modules.remove_at(index)
	removed["position"] = Vector2i(-1, -1)
	stored_modules.append(removed)
	_recalculate()
	log.append("Removed %s from the chassis." % String(module_definition(String(removed.get("id", ""))).get("name", removed.get("id", "module"))))
	return {"ok": true, "module": removed.duplicate(true), "summary": summary()}

func stored_module_count(module_id: String) -> int:
	var count := 0
	for instance in stored_modules:
		if String(instance.get("id", "")) == module_id:
			count += 1
	return count

func seed_starter_inventory() -> void:
	for module_id in MODULE_DEFS.keys():
		if module_count(String(module_id)) + stored_module_count(String(module_id)) > 0:
			continue
		var definition := module_definition(String(module_id))
		stored_modules.append(module_instance(String(module_id), Vector2i(-1, -1), "exterior" in definition.get("tags", []), false))

func deploy_stored_module(module_id: String, position: Vector2i, rotated: bool = false) -> Dictionary:
	for index in range(stored_modules.size()):
		var stored: Dictionary = stored_modules[index]
		if String(stored.get("id", "")) != module_id:
			continue
		var exterior := bool(stored.get("exterior", false))
		var validation := validate_module_placement(module_id, position, exterior, rotated)
		if not bool(validation.get("ok", false)):
			return validation
		stored["position"] = position
		stored["rotated"] = rotated
		stored_modules.remove_at(index)
		modules.append(stored)
		_recalculate()
		log.append("Installed stored %s." % String(module_definition(module_id).get("name", module_id)))
		return {"ok": true, "module": stored.duplicate(true), "summary": summary()}
	return {"ok": false, "reason": "module is not available in storage"}

func validate_module_reposition(cell: Vector2i, new_position: Vector2i, rotated: bool) -> Dictionary:
	var found := module_at(cell)
	if found.is_empty():
		return {"ok": false, "reason": "no module selected"}
	return validate_module_placement(
		String(found.get("id", "")),
		new_position,
		bool(found.get("exterior", false)),
		rotated,
		int(found.get("index", -1))
	)

func reposition_module_at(cell: Vector2i, new_position: Vector2i, rotated: bool) -> Dictionary:
	var found := module_at(cell)
	if found.is_empty():
		return {"ok": false, "reason": "no module selected"}
	var index := int(found.get("index", -1))
	var validation := validate_module_reposition(cell, new_position, rotated)
	if not bool(validation.get("ok", false)):
		return validation
	var moved: Dictionary = modules[index].duplicate(true)
	var rotation_changed := bool(moved.get("rotated", false)) != rotated
	moved["position"] = new_position
	moved["rotated"] = rotated
	modules[index] = moved
	_recalculate()
	log.append("Moved %s to %d,%d%s." % [
		String(module_definition(String(moved.get("id", ""))).get("name", moved.get("id", "module"))),
		new_position.x,
		new_position.y,
		" and changed its orientation" if rotation_changed else ""
	])
	return {"ok": true, "module": moved.duplicate(true), "summary": summary()}

func module_count(module_id: String) -> int:
	var count := 0
	for instance in modules:
		if String(instance.get("id", "")) == module_id:
			count += 1
	return count

func can_refit() -> bool:
	return not encounter_active and phase in ["refit", "settlement"] and current_location in ["ashgate_depot", "morrowline_camp", "lantern_quay", "veyru_evacuation_camp", "blackkiln", "old_lift_station", "saltglass_haven", "windbreak"]

func start_campaign() -> Dictionary:
	campaign_active = true
	campaign_region_id = "ashgate_lowlands"
	campaign_encounters_completed = 0
	campaign_path = ["ashgate_depot"]
	campaign_target_node = ""
	campaign_last_safe_node = "ashgate_depot"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	campaign_decisions.clear()
	occurrence_stream_cursor = 0
	occurrence_active_phase = ""
	occurrence_phase_history.clear()
	occurrence_history.clear()
	occurrence_cooldowns.clear()
	guard_contract_status = "offered"
	veyru_contract_status = "unoffered"
	veyru_medicine_carrier_id = ""
	cinder_contract_status = "unoffered"
	salt_contract_status = "unoffered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	industry_tendency = 0
	specialist_id = ""
	mara_repaired_module_id = ""
	relay_repaired = false
	workers_rescued = false
	mastery_experiment_id = ""
	acquired_intel_ids.clear()
	purchased_market_offer_ids.clear()
	journey_node = "ashgate_depot"
	journey_destination = ""
	journey_route = ""
	journey_leg = 0
	current_location = "ashgate_depot"
	phase = "refit"
	journey_complete = false
	run_complete = false
	final_result = ""
	encounter_active = false
	encounter_outcome = ""
	log.append("The Ashgate Lowlands map is open. Choose whether to guard Morrowline's parts convoy before taking the first road.")
	return {"ok": true, "summary": summary(), "options": campaign_available_nodes()}

func start_tutorial() -> Dictionary:
	campaign_active = false
	campaign_region_id = "ashgate_lowlands"
	campaign_encounters_completed = 0
	campaign_path = ["ashgate_depot"]
	campaign_target_node = ""
	campaign_last_safe_node = "ashgate_depot"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	campaign_decisions.clear()
	guard_contract_status = "unoffered"
	veyru_contract_status = "unoffered"
	cinder_contract_status = "unoffered"
	salt_contract_status = "unoffered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	industry_tendency = 0
	specialist_id = ""
	mastery_experiment_id = ""
	acquired_intel_ids.clear()
	purchased_market_offer_ids.clear()
	journey_node = "ashgate_depot"
	journey_destination = ""
	journey_route = ""
	journey_leg = 0
	current_location = "ashgate_depot"
	phase = "refit"
	fuel = 5
	money = 24
	hull_condition = 10
	settlement_actions_remaining = 1
	journey_complete = false
	run_complete = false
	final_result = ""
	encounter_active = false
	encounter_outcome = ""
	modules.clear()
	stored_modules.clear()
	log.clear()
	place_module("coal_cell", Vector2i(0, 1))
	place_module("generator_core", Vector2i(2, 0))
	place_module("ammunition_lift", Vector2i(4, 0))
	place_module("crew_quarters", Vector2i(2, 2))
	place_module("field_workshop", Vector2i(2, 3))
	stored_modules.append(module_instance("steam_lance_engine", Vector2i(-1, -1)))
	stored_modules.append(module_instance("repeater_gun", Vector2i(-1, -1), true))
	_recalculate()
	log.clear()
	log.append("Ashgate Muster Yard opens the unfinished fortress for its first command lesson.")
	return {"ok": true, "summary": summary(), "stored_modules": stored_modules.duplicate(true)}

func begin_tutorial_journey(doctrine: String = "protect_cargo") -> Dictionary:
	if encounter_active:
		return {"ok": false, "reason": "an encounter is already active"}
	if phase != "refit" or current_location != "ashgate_depot":
		return {"ok": false, "reason": "the training road begins at Ashgate Muster Yard"}
	var travel_result := travel("safe_road", doctrine)
	if not bool(travel_result.get("ok", false)):
		return travel_result
	journey_route = "safe_road"
	journey_destination = "morrowline_camp"
	journey_node = "rill_crossing"
	current_location = journey_node
	journey_leg = 1
	phase = "battle"
	command_points = 2
	encounter_target_doctrine = doctrine
	_configure_encounter(["road_raiders"], "Muster Road", "A controlled contact waits between the muster yard and its recovery siding.")
	if not encounter_enemies.is_empty():
		encounter_enemies[0]["hp"] = 7
		encounter_enemies[0]["max_hp"] = 7
		encounter_enemies[0]["damage_bonus"] = 1
	return {"ok": true, "route": "safe_road", "forecast": encounter_forecast(), "encounter": encounter_summary(), "summary": summary()}

func start_flooded_veyru() -> Dictionary:
	campaign_active = true
	campaign_region_id = "flooded_veyru"
	campaign_encounters_completed = 0
	campaign_path = ["lantern_quay"]
	campaign_target_node = ""
	campaign_last_safe_node = "lantern_quay"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	campaign_decisions.clear()
	occurrence_stream_cursor = 0
	occurrence_active_phase = ""
	occurrence_phase_history.clear()
	occurrence_history.clear()
	occurrence_cooldowns.clear()
	guard_contract_status = "unoffered"
	veyru_contract_status = "offered"
	veyru_medicine_carrier_id = ""
	cinder_contract_status = "unoffered"
	salt_contract_status = "unoffered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	industry_tendency = 0
	specialist_id = ""
	mara_repaired_module_id = ""
	relay_repaired = false
	workers_rescued = false
	mastery_experiment_id = ""
	acquired_intel_ids.clear()
	purchased_market_offer_ids.clear()
	journey_node = "lantern_quay"
	journey_destination = ""
	journey_route = ""
	journey_leg = 0
	current_location = "lantern_quay"
	phase = "refit"
	journey_complete = false
	run_complete = false
	final_result = ""
	encounter_active = false
	encounter_outcome = ""
	log.append("The Flooded Veyru chart is open. Decide whether to carry Lantern Quay's sealed medicines before the water rises.")
	return {"ok": true, "summary": summary(), "options": campaign_available_nodes()}

func start_cinder_spine() -> Dictionary:
	campaign_active = true
	campaign_region_id = "cinder_spine"
	campaign_encounters_completed = 0
	campaign_path = ["blackkiln"]
	campaign_target_node = ""
	campaign_last_safe_node = "blackkiln"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	campaign_decisions.clear()
	occurrence_stream_cursor = 0
	occurrence_active_phase = ""
	occurrence_phase_history.clear()
	occurrence_history.clear()
	occurrence_cooldowns.clear()
	guard_contract_status = "unoffered"
	veyru_contract_status = "unoffered"
	veyru_medicine_carrier_id = ""
	cinder_contract_status = "offered"
	salt_contract_status = "unoffered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	industry_tendency = 0
	specialist_id = ""
	mara_repaired_module_id = ""
	relay_repaired = false
	workers_rescued = false
	mastery_experiment_id = ""
	acquired_intel_ids.clear()
	purchased_market_offer_ids.clear()
	journey_node = "blackkiln"
	journey_destination = ""
	journey_route = ""
	journey_leg = 0
	current_location = "blackkiln"
	phase = "refit"
	journey_complete = false
	run_complete = false
	final_result = ""
	encounter_active = false
	encounter_outcome = ""
	log.append("The Cinder Spine chart is open. Decide whether Blackkiln's Guild dynamo travels under fortress protection before the fireline climbs.")
	return {"ok": true, "summary": summary(), "options": campaign_available_nodes()}

func start_white_salt_expanse() -> Dictionary:
	campaign_active = true
	campaign_region_id = "white_salt_expanse"
	campaign_encounters_completed = 0
	campaign_path = ["saltglass_haven"]
	campaign_target_node = ""
	campaign_last_safe_node = "saltglass_haven"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	campaign_decisions.clear()
	occurrence_stream_cursor = 0
	occurrence_active_phase = ""
	occurrence_phase_history.clear()
	occurrence_history.clear()
	occurrence_cooldowns.clear()
	guard_contract_status = "unoffered"
	veyru_contract_status = "unoffered"
	veyru_medicine_carrier_id = ""
	cinder_contract_status = "unoffered"
	salt_contract_status = "offered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	industry_tendency = 0
	specialist_id = ""
	journey_node = "saltglass_haven"
	journey_destination = ""
	journey_route = ""
	journey_leg = 0
	current_location = "saltglass_haven"
	phase = "refit"
	journey_complete = false
	run_complete = false
	final_result = ""
	encounter_active = false
	encounter_outcome = ""
	log.append("The White Salt Expanse is open. Choose whether to guide the Compact under public beacons before the ash front arrives.")
	return {"ok": true, "summary": summary(), "options": campaign_available_nodes()}

func campaign_region_name() -> String:
	match campaign_region_id:
		"flooded_veyru":
			return "Flooded Veyru"
		"cinder_spine":
			return "The Cinder Spine"
		"white_salt_expanse":
			return "The White Salt Expanse"
		_:
			return "Ashgate Lowlands"

func set_regional_developments(developments: Array) -> Dictionary:
	var validated: Array[String] = []
	for raw_id in developments:
		var development_id := String(raw_id)
		if development_id not in VALID_REGIONAL_DEVELOPMENTS:
			return {"ok": false, "reason": "unknown regional development"}
		if development_id not in validated:
			validated.append(development_id)
	validated.sort()
	regional_developments = validated
	return {"ok": true, "developments": regional_developments.duplicate()}

func has_regional_development(development_id: String) -> bool:
	return development_id in regional_developments

func earned_regional_development() -> String:
	var earned := earned_regional_developments()
	return String(earned[0]) if not earned.is_empty() else ""

func earned_regional_developments() -> Array[String]:
	var earned: Array[String] = []
	if phase != "results":
		return earned
	if final_result in ["archive_kept", "archive_scarred"] and String(campaign_decisions.get("archive_broadcast", "")) == "broadcast_archive":
		earned.append("veyru_public_archive_signal")
	if final_result in ["spine_powered", "spine_bypassed"]:
		if String(campaign_decisions.get("commune_design", "")) == "share_lift_plan":
			earned.append("cinder_communal_lift_plan")
		if String(campaign_decisions.get("chapel_refuge", "")) == "light_refuge_markers":
			earned.append("cinder_refuge_chain")
	if final_result in ["expanse_allied", "expanse_crossed"]:
		if String(campaign_decisions.get("observatory_signal", "")) == "broadcast_beacons":
			earned.append("salt_public_beacons")
		if String(campaign_decisions.get("trench_cistern", "")) == "share_trench_water":
			earned.append("salt_shared_cisterns")
	return earned

func composable_ending() -> Dictionary:
	var survival := "lost"
	if final_result in ["decisive_march", "archive_kept", "spine_powered", "expanse_allied"]:
		survival = "secure"
	elif final_result in ["scarred_march", "archive_scarred", "spine_bypassed", "expanse_crossed"]:
		survival = "scarred"
	var network := "isolated_road"
	if knowledge_tendency > 0:
		network = "open_signal_network"
	elif shelter_tendency > 0:
		network = "shelter_chain"
	elif industry_tendency > 0:
		network = "industrial_corridor"
	elif mobility_tendency > 0:
		network = "fast_corridor"
	var contract_status := guard_contract_status
	if campaign_region_id == "flooded_veyru":
		contract_status = veyru_contract_status
	elif campaign_region_id == "cinder_spine":
		contract_status = cinder_contract_status
	elif campaign_region_id == "white_salt_expanse":
		contract_status = salt_contract_status
	var promise := "unbound"
	if contract_status == "completed":
		promise = "promise_kept"
	elif contract_status == "failed":
		promise = "promise_broken"
	elif contract_status == "accepted":
		promise = "promise_unresolved"
	var titles := {
		"secure": "Secure",
		"scarred": "Scarred",
		"lost": "Lost",
		"open_signal_network": "Open Signal Network",
		"shelter_chain": "Shelter Chain",
		"industrial_corridor": "Industrial Corridor",
		"fast_corridor": "Fast Corridor",
		"isolated_road": "Isolated Road",
		"promise_kept": "Promise Kept",
		"promise_broken": "Promise Broken",
		"promise_unresolved": "Promise Unresolved",
		"unbound": "Unbound"
	}
	return {
		"survival": survival,
		"network": network,
		"promise": promise,
		"title": "%s · %s · %s" % [titles[survival], titles[network], titles[promise]],
		"causes": ["Hull %d/10 and %d secured contacts" % [hull_condition, campaign_encounters_completed], "Tendencies M%d S%d K%d I%d" % [mobility_tendency, shelter_tendency, knowledge_tendency, industry_tendency], "Contract %s" % contract_status.replace("_", " ")]
	}

func campaign_pressure_name() -> String:
	match campaign_region_id:
		"flooded_veyru":
			return "Rising water"
		"cinder_spine":
			return "Fireline"
		"white_salt_expanse":
			return "Ash front"
		_:
			return "Blockade"

func campaign_edges() -> Dictionary:
	return _campaign_edges_for_state(campaign_region_id, campaign_pressure, campaign_retreats)

func _campaign_edges_for_state(region_id: String, pressure: int, retreats: int) -> Dictionary:
	if region_id == "flooded_veyru":
		var veyru_edges := VEYRU_EDGES.duplicate(true)
		if pressure < 5 and retreats == 0:
			veyru_edges["veyru_evacuation_camp"].erase("pilgrim_gantry")
		return veyru_edges
	if region_id == "cinder_spine":
		var cinder_edges := CINDER_EDGES.duplicate(true)
		if pressure < 5 and retreats == 0:
			cinder_edges["old_lift_station"].erase("ash_chapel_bypass")
		return cinder_edges
	if region_id == "white_salt_expanse":
		var salt_edges := SALT_EDGES.duplicate(true)
		if pressure < 5 and retreats == 0:
			salt_edges["windbreak"].erase("lee_trench")
		return salt_edges
	return CAMPAIGN_EDGES

func campaign_final_node_id() -> String:
	match campaign_region_id:
		"flooded_veyru":
			return "dry_archive"
		"cinder_spine":
			return "switchback_commune"
		"white_salt_expanse":
			return "salt_citadel"
		_:
			return "meridian_pass"

func campaign_pressure_band() -> String:
	if campaign_region_id == "flooded_veyru":
		if campaign_pressure >= 5:
			return "breach"
		if campaign_pressure >= 3:
			return "flooding"
		return "low_water"
	if campaign_region_id == "cinder_spine":
		if campaign_pressure >= 5:
			return "inferno"
		if campaign_pressure >= 3:
			return "advancing"
		return "embers"
	if campaign_region_id == "white_salt_expanse":
		if campaign_pressure >= 5:
			return "whiteout"
		if campaign_pressure >= 3:
			return "approaching"
		return "clear"
	if campaign_pressure >= 5:
		return "break"
	if campaign_pressure >= 3:
		return "closing"
	return "watch"

func campaign_node_closed(node_id: String) -> bool:
	if campaign_region_id == "flooded_veyru":
		return node_id == "drowned_registry" and campaign_pressure_band() == "breach"
	if campaign_region_id == "cinder_spine":
		return node_id == "slag_tunnel" and campaign_pressure_band() == "inferno"
	if campaign_region_id == "white_salt_expanse":
		return node_id == "empty_mile" and campaign_pressure_band() == "whiteout"
	if node_id == "signal_causeway" and campaign_pressure_band() == "break" and specialist_id != "iven_pell" and not _has_ready_tag("forecast"):
		return true
	return false

func campaign_node_lock_reason(node_id: String) -> String:
	if node_id == "dry_cistern_cut" and not _has_ready_tag("water"):
		return "Requires a Ready Water Condenser: shared power and an adjacent operational Field Workshop."
	return ""

func campaign_available_nodes() -> Array[String]:
	var result: Array[String] = []
	if not campaign_active or encounter_active or not campaign_event_pending.is_empty() or phase == "results":
		return result
	for raw_node_id in campaign_edges().get(current_location, []):
		var node_id := String(raw_node_id)
		if not campaign_node_closed(node_id) and campaign_node_lock_reason(node_id).is_empty():
			result.append(node_id)
	return result

func campaign_node_preview(node_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	var node: Dictionary = CAMPAIGN_NODES.get(node_id, {})
	if node.is_empty():
		return {"ok": false, "reason": "unknown campaign node"}
	var cinder_grade := campaign_region_id == "cinder_spine" and node_id != "ash_chapel_bypass"
	var mass_penalty := 1 if (bool(node.get("mass_sensitive", false)) or cinder_grade) and total_mass() > BASE_MASS_LIMIT - 2 else 0
	var condenser_discount := 1 if node_id == "dry_cistern_cut" and _has_ready_tag("water") else 0
	var orla_discount := 1 if specialist_id == "orla_nine" and int(node.get("days", 0)) >= 2 else 0
	var fuel_cost := maxi(1, int(node.get("fuel", 0)) + mass_penalty - condenser_discount - orla_discount)
	var sela_fast_line := specialist_id == "sela_vonn" and doctrine == "run_hot"
	var route_days := maxi(1, int(node.get("days", 0)) - (1 if sela_fast_line else 0))
	var contract_heat := 1 if campaign_region_id == "cinder_spine" and cinder_contract_status == "accepted" else 0
	var predicted_heat := maxi(0, total_heat() + contract_heat + (2 if doctrine == "run_hot" else 0) + orla_discount)
	var informed := specialist_id == "iven_pell" or _has_ready_tag("forecast")
	var acquired_intel := acquired_intel_for_node(node_id)
	var development_reveal := campaign_region_id == "flooded_veyru" and node_id == "drowned_registry" and has_regional_development("veyru_public_archive_signal")
	var cinder_development_reveal := campaign_region_id == "cinder_spine" and node_id == "slag_tunnel" and has_regional_development("cinder_communal_lift_plan")
	var salt_development_reveal := campaign_region_id == "white_salt_expanse" and node_id == "salt_mine" and has_regional_development("salt_public_beacons")
	var visibility := "known" if informed else String(node.get("visibility", "forecast"))
	if development_reveal or cinder_development_reveal or salt_development_reveal or not acquired_intel.is_empty():
		visibility = "known"
	if campaign_region_id == "flooded_veyru" and node_id == "dry_archive" and String(campaign_decisions.get("archive_broadcast", "")) == "seal_archive":
		visibility = "forecast"
	var signal_discount := 0.08 if informed else 0.0
	var heat_penalty := 0.08 if predicted_heat > BASE_HEAT_LIMIT else 0.0
	var base_risk := float(node.get("risk", 0.0))
	var blockade_risk := campaign_pressure * (0.025 if campaign_region_id == "cinder_spine" else 0.02)
	var mass_risk := float(mass_penalty) * 0.05
	var risk := clampf(base_risk + route_risk_modifier + blockade_risk + mass_risk + heat_penalty - signal_discount, 0.0, 0.95)
	if sela_fast_line:
		risk = clampf(risk + 0.04, 0.0, 0.95)
	var pressure_gain := int(node.get("pressure", 1))
	var encounter_difficulty := maxi(0, pressure_gain - (1 if informed else 0))
	if predicted_heat > BASE_HEAT_LIMIT:
		encounter_difficulty += 1
	var threat_names: Array[String] = []
	var counter_hints: Array[String] = []
	var ready_counter_names: Array[String] = []
	if visibility == "known":
		for enemy_id in node.get("encounter", []):
			var enemy_definition: Dictionary = ENCOUNTER_ENEMIES.get(String(enemy_id), {})
			threat_names.append(String(enemy_definition.get("name", enemy_id)))
			var counter_hint := String(enemy_definition.get("counter", ""))
			if not counter_hint.is_empty() and counter_hint not in counter_hints:
				counter_hints.append(counter_hint)
			for counter_module_id in enemy_definition.get("counter_modules", []):
				var module_id := String(counter_module_id)
				if operational(module_id):
					var module_name := String(module_definition(module_id).get("name", module_id))
					if module_name not in ready_counter_names:
						ready_counter_names.append(module_name)
	var risk_factors: Array[String] = []
	if sela_fast_line:
		risk_factors.append("Sela fast line -1 day, +4pt")
	if orla_discount > 0:
		risk_factors.append("Orla fuel line -1 fuel, +1 heat")
	if visibility != "unscouted":
		risk_factors.append("baseline %.0f%%" % (base_risk * 100.0))
	if blockade_risk > 0.0:
		risk_factors.append("%s +%dpt" % [campaign_pressure_name().to_lower(), roundi(blockade_risk * 100.0)])
	if mass_risk > 0.0:
		risk_factors.append("heavy fortress +%dpt, +1 fuel" % roundi(mass_risk * 100.0))
	if heat_penalty > 0.0:
		risk_factors.append("overheat +%dpt" % roundi(heat_penalty * 100.0))
	if route_risk_modifier != 0.0:
		risk_factors.append("prior choices %s%dpt" % ["+" if route_risk_modifier > 0.0 else "-", roundi(absf(route_risk_modifier) * 100.0)])
	if signal_discount > 0.0:
		risk_factors.append("forecasting -%dpt" % roundi(signal_discount * 100.0))
	return {
		"ok": true,
		"id": node_id,
		"name": String(node.get("name", node_id)),
		"type": String(node.get("type", "route")),
		"visibility": visibility,
		"days": route_days,
		"fuel": fuel_cost,
		"fuel_discount": condenser_discount,
		"specialist_fuel_discount": orla_discount,
		"risk": risk,
		"risk_band": "low" if risk <= 0.18 else ("guarded" if risk <= 0.32 else "high"),
		"risk_factors": risk_factors,
		"pressure_gain": pressure_gain,
		"encounter_pressure": encounter_difficulty,
		"predicted_heat": predicted_heat,
		"reward": int(node.get("reward", 0)),
		"route_effect": String(node.get("route_effect", "")),
		"threat_hint": String(node.get("threat_hint", "uncertain road pressure")),
		"threats": threat_names,
		"counter_hints": counter_hints,
		"ready_counter_names": ready_counter_names,
		"regional_development": "Public Archive Signal" if development_reveal else ("Communal Lift Plan" if cinder_development_reveal else ("Public Salt Beacons" if salt_development_reveal else "")),
		"intel_id": String(acquired_intel.get("id", "")),
		"intel_source": String(acquired_intel.get("source_name", "")),
		"intel_confidence": String(acquired_intel.get("confidence", "")),
		"intel_revealed_fields": acquired_intel.get("revealed_fields", []).duplicate(),
		"closed": campaign_node_closed(node_id),
		"locked_reason": campaign_node_lock_reason(node_id)
	}

func campaign_route_comparison(doctrine: String = "protect_cargo") -> Array[Dictionary]:
	var comparison: Array[Dictionary] = []
	for node_id in campaign_available_nodes():
		var preview := campaign_node_preview(node_id, doctrine)
		var next_names: Array[String] = []
		var settlement_follows := false
		for raw_next_id in campaign_edges().get(node_id, []):
			var next_id := String(raw_next_id)
			var next_node: Dictionary = CAMPAIGN_NODES.get(next_id, {})
			next_names.append(String(next_node.get("name", next_id)))
			if String(next_node.get("type", "")) == "settlement":
				settlement_follows = true
		comparison.append({
			"id": node_id,
			"name": String(preview.get("name", node_id)),
			"visibility": String(preview.get("visibility", "unscouted")),
			"days": int(preview.get("days", 0)),
			"fuel": int(preview.get("fuel", 0)),
			"fuel_discount": int(preview.get("fuel_discount", 0)),
			"risk": float(preview.get("risk", 0.0)),
			"risk_band": String(preview.get("risk_band", "high")),
			"pressure_gain": int(preview.get("pressure_gain", 0)),
			"threat_hint": String(preview.get("threat_hint", "uncertain pressure")),
			"threats": preview.get("threats", []).duplicate(),
			"route_effect": String(preview.get("route_effect", "")),
			"regional_development": String(preview.get("regional_development", "")),
			"intel_source": String(preview.get("intel_source", "")),
			"intel_confidence": String(preview.get("intel_confidence", "")),
			"next_stops": next_names,
			"settlement_follows": settlement_follows
		})
	return comparison

func choose_guard_contract(accept: bool) -> Dictionary:
	if not campaign_active or current_location != "ashgate_depot" or phase != "refit":
		return {"ok": false, "reason": "the guard contract is only offered at Ashgate Depot"}
	if guard_contract_status != "offered":
		return {"ok": false, "reason": "the guard contract has already been answered"}
	guard_contract_status = "accepted" if accept else "declined"
	var message := ""
	if accept:
		message = "Contract accepted: each enemy on the Morrowline approach gains 1 HP; safe arrival pays 30 Ashmarks, 2 trust, and preserves 2 Morrowline service actions."
	else:
		mobility_tendency += 1
		message = "Contract declined: Morrowline enemies keep normal endurance, but the parts convoy does not arrive; Morrowline will have 1 service action instead of 2, with no payout or trust."
	log.append(message)
	return {"ok": true, "status": guard_contract_status, "message": message, "summary": summary()}

func morrowline_service_capacity() -> int:
	return 2 if guard_contract_status in ["accepted", "completed"] else 1

func veyru_medicine_contract_status() -> Dictionary:
	if not campaign_active or campaign_region_id != "flooded_veyru" or current_location != "lantern_quay" or phase != "refit":
		return {"available": false, "reason": "the medicine contract is only offered at Lantern Quay"}
	if veyru_contract_status != "offered":
		return {"available": false, "reason": "the medicine contract has already been answered"}
	var carrier_id := "refugee_bunk" if operational("refugee_bunk") else ("parts_crate" if operational("parts_crate") else "")
	if carrier_id.is_empty():
		return {"available": false, "reason": "requires an operational Refugee Bunk or Parts Crate"}
	return {"available": true, "reason": "", "carrier_id": carrier_id, "carrier_name": String(module_definition(carrier_id).get("name", carrier_id))}

func choose_veyru_medicine_contract(accept: bool) -> Dictionary:
	if not campaign_active or campaign_region_id != "flooded_veyru" or current_location != "lantern_quay" or phase != "refit":
		return {"ok": false, "reason": "the medicine contract is only offered at Lantern Quay"}
	if veyru_contract_status != "offered":
		return {"ok": false, "reason": "the medicine contract has already been answered"}
	var message := ""
	if accept:
		var status := veyru_medicine_contract_status()
		if not bool(status.get("available", false)):
			return {"ok": false, "reason": String(status.get("reason", "no carrier is available"))}
		veyru_contract_status = "accepted"
		veyru_medicine_carrier_id = String(status.get("carrier_id", ""))
		message = "Medicine contract accepted: %s carries the sealed cases. Delivery pays 28 Ashmarks and 2 trust if that system reaches the Dry Archive operational." % String(status.get("carrier_name", "The selected carrier"))
	else:
		veyru_contract_status = "declined"
		veyru_medicine_carrier_id = ""
		mobility_tendency += 1
		message = "Medicine contract declined: cargo capacity stays free and Mobility rises by 1, but the fortress gives up the 28-Ashmark and 2-trust delivery."
	log.append(message)
	return {"ok": true, "status": veyru_contract_status, "carrier_id": veyru_medicine_carrier_id, "message": message, "summary": summary()}

func veyru_contract_carrier_operational() -> bool:
	return veyru_contract_status == "accepted" and not veyru_medicine_carrier_id.is_empty() and operational(veyru_medicine_carrier_id)

func _refresh_veyru_contract_state() -> bool:
	if campaign_region_id != "flooded_veyru" or veyru_contract_status != "accepted":
		return false
	var carrier_index := _module_index_by_id(veyru_medicine_carrier_id)
	if carrier_index >= 0 and int(modules[carrier_index].get("durability", 0)) > 0:
		return false
	veyru_contract_status = "failed"
	var carrier_name := String(module_definition(veyru_medicine_carrier_id).get("name", "medicine carrier"))
	var message := "Medicine contract failed: %s can no longer carry the sealed cases. The march continues without the delivery reward." % carrier_name
	log.append(message)
	if encounter_active:
		_encounter_log(message)
	return true

func choose_cinder_forge_contract(accept: bool) -> Dictionary:
	if not campaign_active or campaign_region_id != "cinder_spine" or current_location != "blackkiln" or phase != "refit":
		return {"ok": false, "reason": "the dynamo contract is only offered at Blackkiln"}
	if cinder_contract_status != "offered":
		return {"ok": false, "reason": "the dynamo contract has already been answered"}
	if accept and not operational("generator_core"):
		return {"ok": false, "reason": "requires an operational Generator Core to carry the Guild pattern"}
	if accept:
		cinder_contract_status = "accepted"
		industry_tendency += 1
		var accepted_message := "Dynamo contract accepted: keep the Generator Core operational through Switchback Commune for 30 Ashmarks and 2 trust. Its full load adds 1 heat on every Cinder route."
		log.append(accepted_message)
		return {"ok": true, "status": cinder_contract_status, "message": accepted_message, "summary": summary()}
	cinder_contract_status = "declined"
	mobility_tendency += 1
	var declined_message := "Dynamo contract declined: Mobility rises by 1 and the fortress carries no Guild heat load, but gives up the delivery reward and the powered-lift ending."
	log.append(declined_message)
	return {"ok": true, "status": cinder_contract_status, "message": declined_message, "summary": summary()}

func choose_salt_beacon_contract(accept: bool) -> Dictionary:
	if not campaign_active or campaign_region_id != "white_salt_expanse" or current_location != "saltglass_haven" or phase != "refit":
		return {"ok": false, "reason": "the beacon escort is only offered at Saltglass Haven"}
	if salt_contract_status != "offered":
		return {"ok": false, "reason": "the beacon escort has already been answered"}
	if accept and not _has_ready_tag("forecast"):
		return {"ok": false, "reason": "requires an operational signal system"}
	if accept:
		salt_contract_status = "accepted"
		shelter_tendency += 1
		var accepted_message := "Beacon escort accepted: keep a signal system operational through the Salt Citadel. Rival scouts gain 1 endurance; delivery pays 26 Ashmarks and 2 trust."
		log.append(accepted_message)
		return {"ok": true, "status": salt_contract_status, "message": accepted_message, "summary": summary()}
	salt_contract_status = "declined"
	mobility_tendency += 1
	var declined_message := "Beacon escort declined: Mobility rises by 1 and rival scouts keep normal endurance, but the Compact receives no guided crossing."
	log.append(declined_message)
	return {"ok": true, "status": salt_contract_status, "message": declined_message, "summary": summary()}

func mara_recruitment_status() -> Dictionary:
	if not campaign_active or current_location != "morrowline_camp" or phase != "settlement" or campaign_event_pending != "mara_meeting":
		return {"available": false, "reason": "Mara Flint is only considering the fortress at Morrowline Camp"}
	if not specialist_id.is_empty():
		return {"available": false, "reason": "the specialist berth is already occupied"}
	if not operational("field_workshop"):
		return {"available": false, "reason": "requires an operational crew-connected Field Workshop"}
	if not _has_operational_tag("crew"):
		return {"available": false, "reason": "requires operational Crew Quarters"}
	return {"available": true, "reason": "Mara can staff the Field Workshop"}

func _weakest_damaged_module_id() -> String:
	var weakest_id := ""
	var weakest_durability := 999
	for instance in modules:
		var module_id := String(instance.get("id", ""))
		var maximum := int(module_definition(module_id).get("durability", 1))
		var current := int(instance.get("durability", maximum))
		if current >= maximum:
			continue
		if current < weakest_durability:
			weakest_id = module_id
			weakest_durability = current
	return weakest_id

func _has_recoverable_refuge_bunk() -> bool:
	return module_count("refugee_bunk") + stored_module_count("refugee_bunk") > 0

func mara_repair_bonus() -> int:
	return 1 if specialist_id == "mara_flint" else 0

func mara_refuge_bracing_active() -> bool:
	return String(campaign_decisions.get("mara_workbench_choice", "")) == "brace_refuge"

func mara_followup_preview() -> Dictionary:
	var workbench_choice := String(campaign_decisions.get("mara_workbench_choice", ""))
	if specialist_id != "mara_flint" or workbench_choice.is_empty():
		return {"valid": false, "effect": "Mara's workbench commitment is not active."}
	if workbench_choice == "rebuild_weakest":
		var held := operational(mara_repaired_module_id)
		var module_name := String(module_definition(mara_repaired_module_id).get("name", "the repaired system"))
		return {
			"valid": true,
			"path": "repair",
			"held": held,
			"choice_id": "record_repair_held" if held else "record_repair_failed",
			"effect": "Pressure -1 · %s remained operational" % module_name if held else "No pressure recovery · %s failed after Mara's repair" % module_name
		}
	var bunk_ready := operational("refugee_bunk")
	return {
		"valid": true,
		"path": "refuge",
		"held": bunk_ready,
		"choice_id": "record_refuge_held" if bunk_ready else "record_refuge_failed",
		"effect": "Trust +1 · Shelter +1 · Refugee Bunk operational" if bunk_ready else "No trust or Shelter gain · Refugee Bunk is not operational"
	}

func mara_debrief_line() -> String:
	var meeting := String(campaign_decisions.get("mara_meeting", ""))
	if meeting.is_empty():
		return "Mara Flint — not encountered"
	if meeting == "decline_mara":
		return "Mara Flint — remained at Morrowline; specialist berth preserved"
	var workbench := String(campaign_decisions.get("mara_workbench_choice", ""))
	var followup := String(campaign_decisions.get("mara_followup", ""))
	if workbench == "rebuild_weakest":
		var module_name := String(module_definition(mara_repaired_module_id).get("name", "damaged system"))
		if followup == "record_repair_held":
			return "Mara Flint — rebuilt %s; it held through the fourth road and recovered 1 pressure" % module_name
		if followup == "record_repair_failed":
			return "Mara Flint — rebuilt %s; it failed before the fourth-road check" % module_name
		return "Mara Flint — rebuilt %s; later result unresolved" % module_name
	if workbench == "brace_refuge":
		if followup == "record_refuge_held":
			return "Mara Flint — braced the Refugee Bunk; it earned 1 trust and 1 Shelter"
		if followup == "record_refuge_failed":
			return "Mara Flint — braced the Refugee Bunk; it was not operational at the later check"
		return "Mara Flint — braced the Refugee Bunk; later result unresolved"
	return "Mara Flint — recruited; forge-core decision unresolved"

func _bounded_append(target: Array, value: Variant) -> void:
	target.append(value)
	while target.size() > OCCURRENCE_HISTORY_LIMIT:
		target.pop_front()

func _occurrence_roll(phase_id: String, cursor: int) -> int:
	var value := posmod(seed, 2147483647)
	var stream_key := "%s:%s:%d" % [OCCURRENCE_STREAM_NAME, phase_id, cursor]
	for byte in stream_key.to_utf8_buffer():
		value = posmod(value * 1103515245 + int(byte) + 12345, 2147483647)
	return value

func _operational_module_id_with_tag(tag: String, damaged_only: bool = false) -> String:
	var candidate_id := ""
	var candidate_durability := 1000000
	for instance in modules:
		var module_id := String(instance.get("id", ""))
		var definition := module_definition(module_id)
		if tag not in definition.get("tags", []) or not bool(dependency_status(instance).get("operational", false)):
			continue
		var durability := int(instance.get("durability", 0))
		var maximum := int(definition.get("durability", 1))
		if damaged_only and durability >= maximum:
			continue
		if durability < candidate_durability or (durability == candidate_durability and module_id < candidate_id):
			candidate_id = module_id
			candidate_durability = durability
	return candidate_id

func _change_module_durability(module_id: String, amount: int) -> Dictionary:
	var index := _module_index_by_id(module_id)
	if index < 0:
		return {"ok": false, "reason": "module not found"}
	var maximum := int(module_definition(module_id).get("durability", 1))
	var before := int(modules[index].get("durability", 0))
	var after := clampi(before + amount, 0, maximum)
	modules[index]["durability"] = after
	_recalculate()
	return {"ok": true, "before": before, "after": after, "maximum": maximum}

func occurrence_eligibility(event_id: String, phase_kind: String, node_id: String) -> Dictionary:
	var definition: Dictionary = OCCURRENCE_DEFS.get(event_id, {})
	if definition.is_empty():
		return {"eligible": false, "reason": "unknown occurrence"}
	if phase_kind not in definition.get("phases", []):
		return {"eligible": false, "reason": "wrong occurrence phase"}
	if node_id not in definition.get("nodes", []):
		return {"eligible": false, "reason": "wrong occurrence location"}
	if String(definition.get("repeat", "once")) == "once" and campaign_decisions.has(event_id):
		return {"eligible": false, "reason": "one-shot occurrence already resolved"}
	if campaign_encounters_completed < int(occurrence_cooldowns.get(event_id, 0)):
		return {"eligible": false, "reason": "occurrence is cooling down"}
	match event_id:
		"boiler_heartbeat":
			if _operational_module_id_with_tag("engine", true).is_empty():
				return {"eligible": false, "reason": "requires a damaged operational engine"}
			if not _has_operational_tag("repair"):
				return {"eligible": false, "reason": "requires a Ready repair system"}
		"lift_chain_sings":
			if not _has_operational_tag("ammunition") or not _has_operational_tag("weapon"):
				return {"eligible": false, "reason": "requires an operational Ammunition Lift and weapon"}
		"the_last_dry_room":
			if not _has_operational_tag("refuge") or not _has_operational_tag("parts"):
				return {"eligible": false, "reason": "requires operational refuge and parts space"}
		"the_miller_with_a_broken_wheel":
			if not _has_operational_tag("repair"):
				return {"eligible": false, "reason": "requires a Ready Field Workshop"}
	return {"eligible": true, "reason": ""}

func occurrence_candidates(phase_kind: String, node_id: String) -> Array[String]:
	var candidates: Array[String] = []
	for event_id in OCCURRENCE_DEFS:
		if bool(occurrence_eligibility(String(event_id), phase_kind, node_id).get("eligible", false)):
			candidates.append(String(event_id))
	candidates.sort()
	return candidates

func try_schedule_occurrence(phase_kind: String, node_id: String, phase_id: String) -> Dictionary:
	if not campaign_event_pending.is_empty():
		return {"ok": false, "reason": "another primary event is already active"}
	if phase_id.is_empty():
		return {"ok": false, "reason": "occurrence phase ID is required"}
	if phase_id in occurrence_phase_history:
		return {"ok": true, "event_id": "", "reason": "phase already evaluated"}
	_bounded_append(occurrence_phase_history, phase_id)
	var candidates := occurrence_candidates(phase_kind, node_id)
	if candidates.is_empty():
		return {"ok": true, "event_id": "", "reason": "no eligible occurrences"}
	var roll := _occurrence_roll(phase_id, occurrence_stream_cursor)
	occurrence_stream_cursor += 1
	var selected_index := posmod(roll, candidates.size() + 2)
	if selected_index >= candidates.size():
		return {"ok": true, "event_id": "", "reason": "the road stayed quiet"}
	var selected_id := candidates[selected_index]
	campaign_event_pending = selected_id
	occurrence_active_phase = phase_id
	log.append("Road occurrence: %s requires a decision before departure." % String(OCCURRENCE_DEFS[selected_id].title))
	return {"ok": true, "event_id": selected_id, "phase_id": phase_id, "candidates": candidates.duplicate()}

func _schedule_first_pre_contact_occurrence(node_id: String) -> Dictionary:
	if campaign_region_id != "ashgate_lowlands" or campaign_encounters_completed != 0 or node_id != "rill_crossing":
		return {"ok": true, "event_id": "", "reason": "no authored pre-contact occurrence on this road"}
	var phase_id := "pre_contact_%d_%s" % [journey_leg, node_id]
	if phase_id in occurrence_phase_history:
		return {"ok": true, "event_id": "", "reason": "phase already evaluated"}
	_bounded_append(occurrence_phase_history, phase_id)
	var event_id := "lift_chain_sings"
	var eligibility := occurrence_eligibility(event_id, "pre_contact", node_id)
	if not bool(eligibility.get("eligible", false)):
		return {"ok": true, "event_id": "", "phase_id": phase_id, "reason": String(eligibility.get("reason", "occurrence unavailable"))}
	campaign_event_pending = event_id
	occurrence_active_phase = phase_id
	log.append("Road interruption: %s requires a decision before contact." % String(OCCURRENCE_DEFS[event_id].title))
	return {"ok": true, "event_id": event_id, "phase_id": phase_id}

func pre_contact_occurrence_active() -> bool:
	return encounter_active and encounter_step == 0 and phase in ["battle", "final_battle"] and campaign_event_pending in OCCURRENCE_DEFS and occurrence_active_phase.begins_with("pre_contact_")

func road_arrival_event_active() -> bool:
	return phase == "road_event" and not encounter_active and not campaign_event_pending.is_empty() and not campaign_target_node.is_empty() and current_location != campaign_target_node

func _record_occurrence_resolution(event_id: String, choice_id: String) -> void:
	_bounded_append(occurrence_history, {"event_id": event_id, "choice_id": choice_id, "phase_id": occurrence_active_phase})
	var cooldown := int(OCCURRENCE_DEFS.get(event_id, {}).get("cooldown", 0))
	if cooldown > 0:
		occurrence_cooldowns[event_id] = campaign_encounters_completed + cooldown + 1
	occurrence_active_phase = ""

func occurrence_debrief_lines() -> Array[String]:
	var lines: Array[String] = []
	for entry in occurrence_history:
		var event_id := String(entry.get("event_id", ""))
		var choice_id := String(entry.get("choice_id", ""))
		var title := String(OCCURRENCE_DEFS.get(event_id, {}).get("title", event_id.replace("_", " ").capitalize()))
		var outcome := choice_id.replace("_", " ").capitalize()
		if event_id == "the_last_dry_room":
			outcome = "families sheltered; repair stock exposed" if choice_id == "shelter_in_dry_room" else "repair stock preserved; families turned away"
		lines.append("Road occurrence — %s: %s" % [title, outcome])
	return lines

func campaign_event_details() -> Dictionary:
	match campaign_event_pending:
		"salvage_choice":
			var can_rescue_workers := _has_operational_tag("refuge")
			return {"id": "salvage_choice", "title": "The Orchard Burns", "body": "Fuel lies under the burning orchard, but workers are still trapped beyond the firebreak.", "choices": [
				{"id": "take_fuel", "label": "Recover the fuel", "effect": "Fuel +2 · Trust -1", "enabled": true, "reason": ""},
				{"id": "rescue_workers", "label": "Carry the stranded workers", "effect": "Trust +2 · Day +1 · Pressure +1", "enabled": can_rescue_workers, "reason": "Requires an operational Refugee Bunk" if not can_rescue_workers else ""}
			]}
		"lost_signal":
			var can_restore_relay := _has_operational_tag("signal")
			return {"id": "lost_signal", "title": "The Silence Between Lamps", "body": "The relay can be restored and broadcast, or the fortress can leave quietly before more Climbers arrive.", "choices": [
				{"id": "restore_relay", "label": "Restore and broadcast", "effect": "Exact forecasts · Trust +1 · Pressure +1", "enabled": can_restore_relay, "reason": "Requires an operational signal system" if not can_restore_relay else ""},
				{"id": "move_silent", "label": "Mark the route and move in silence", "effect": "Pressure -1 · Future risk -3%", "enabled": true, "reason": ""}
			]}
		"toll_decision":
			var can_pay_toll := money >= 10
			return {"id": "toll_decision", "title": "The Red Wheel Ledger", "body": "The toll captain offers a quiet crossing for coin. Breaking the post helps later convoys but brings the blockade closer.", "choices": [
				{"id": "pay_toll", "label": "Pay the toll", "effect": "Ashmarks -10 · Pressure -1", "enabled": can_pay_toll, "reason": "Requires 10 Ashmarks" if not can_pay_toll else ""},
				{"id": "break_blockade", "label": "Break the toll post", "effect": "Ashmarks +8 · Trust +1 · Pressure +1", "enabled": true, "reason": ""}
			]}
		"mara_berth_choice":
			var mara_ready := operational("field_workshop") and _has_operational_tag("crew")
			return {"id": "mara_berth_choice", "title": "Two Hands, One Berth", "body": "Iven Pell can keep reading the road ahead, or step ashore to help Morrowline's relay crews while Mara Flint takes the only specialist berth. The fortress cannot carry both.", "choices": [
				{"id": "keep_iven", "label": "Keep Iven on signal watch", "effect": "Retain exact nearby forecasts · Mara remains at Morrowline", "enabled": true, "reason": ""},
				{"id": "replace_iven_with_mara", "label": "Give the berth to Mara", "effect": "Lose Iven's forecast · Workshop repairs +1 · Forge-core choice", "enabled": mara_ready, "reason": "Requires an operational crew-connected Field Workshop" if not mara_ready else ""}
			]}
		"mara_meeting":
			var recruitment := mara_recruitment_status()
			return {"id": "mara_meeting", "title": "The Forge Without a Roof", "body": "Mara Flint has kept the convoy's axles moving from an open repair bench. She will join a fortress that can give the work a staffed room.", "choices": [
				{"id": "recruit_mara", "label": "Bring Mara aboard", "effect": "Specialist berth filled · Workshop repairs +1", "enabled": bool(recruitment.get("available", false)), "reason": String(recruitment.get("reason", "")) if not bool(recruitment.get("available", false)) else ""},
				{"id": "decline_mara", "label": "Leave Mara with Morrowline", "effect": "Keep specialist berth open · No repair bonus", "enabled": true, "reason": ""}
			]}
		"mara_workbench_choice":
			var weakest_id := _weakest_damaged_module_id()
			var weakest_name := String(module_definition(weakest_id).get("name", "damaged system"))
			var refuge_available := _has_recoverable_refuge_bunk()
			return {"id": "mara_workbench_choice", "title": "One Sound Core", "body": "Mara recovers one intact forge core from the convoy wreckage. It can serve the machine or the people, but not both.", "choices": [
				{"id": "rebuild_weakest", "label": "Rebuild %s" % weakest_name, "effect": "Restore up to 2 durability · Day +1 · Pressure +1", "enabled": not weakest_id.is_empty(), "reason": "No installed system is damaged" if weakest_id.is_empty() else ""},
				{"id": "brace_refuge", "label": "Brace the Refugee Bunk", "effect": "Refugee Bunk damage -1 per hit · No immediate repair", "enabled": refuge_available, "reason": "No recoverable Refugee Bunk remains" if not refuge_available else ""}
			]}
		"mara_followup":
			var followup := mara_followup_preview()
			return {"id": "mara_followup", "title": "What Held", "body": "Beyond the fourth road, Mara checks the promise made at her workbench against what the fortress actually carried through.", "choices": [
				{"id": String(followup.get("choice_id", "record_repair_failed")), "label": "Record what held", "effect": String(followup.get("effect", "No result available")), "enabled": bool(followup.get("valid", false)), "reason": "The workbench commitment is missing" if not bool(followup.get("valid", false)) else ""}
			]}
		"boiler_heartbeat":
			var engine_id := _operational_module_id_with_tag("engine", true)
			var engine_name := String(module_definition(engine_id).get("name", "damaged engine"))
			var engine_index := _module_index_by_id(engine_id)
			var can_keep_cadence := engine_index >= 0 and int(modules[engine_index].get("durability", 0)) > 1
			return {"id": "boiler_heartbeat", "title": "The Boiler's Second Heartbeat", "body": "A second rhythm answers the engine stroke. The workshop can open the casing now, or the fortress can keep cadence and let the damaged bearing carry the road.", "choices": [
				{"id": "inspect_boiler", "label": "Stop and inspect %s" % engine_name, "effect": "Engine +1 durability · Day +1 · Pressure +1", "enabled": not engine_id.is_empty() and _has_operational_tag("repair"), "reason": "Requires a damaged operational engine and Ready workshop"},
				{"id": "keep_cadence", "label": "Keep the marching cadence", "effect": "Pressure -1 · Engine -1 durability", "enabled": can_keep_cadence, "reason": "The damaged engine would be disabled" if not can_keep_cadence else ""}
			]}
		"lift_chain_sings":
			return {"id": "lift_chain_sings", "title": "The Lift Chain Sings", "body": "The Ammunition Lift vibrates under a full road load. A paid brace will quiet it; carrying the load risks the dependency but keeps the column moving.", "choices": [
				{"id": "brace_lift_chain", "label": "Fit a proper chain brace", "effect": "Ashmarks -6 · Future route risk -2%", "enabled": money >= 6, "reason": "Requires 6 Ashmarks" if money < 6 else ""},
				{"id": "carry_lift_load", "label": "Carry the load to the next stop", "effect": "Pressure -1 · Ammunition Lift -1 durability", "enabled": true, "reason": ""}
			]}
		"the_last_dry_room":
			var weakest_id := _weakest_damaged_module_id()
			var weakest_name := String(module_definition(weakest_id).get("name", "damaged system"))
			var weakest_index := _module_index_by_id(weakest_id)
			var weakest_before := int(modules[weakest_index].get("durability", 0)) if weakest_index >= 0 else 0
			var weakest_maximum := int(module_definition(weakest_id).get("durability", weakest_before))
			var parts_id := _operational_module_id_with_tag("parts")
			var parts_index := _module_index_by_id(parts_id)
			var parts_before := int(modules[parts_index].get("durability", 0)) if parts_index >= 0 else 0
			return {"id": "the_last_dry_room", "title": "The Last Dry Room", "body": "One sealed compartment can keep the repair stock dry or shelter the families riding beside it. The same floor cannot protect both.", "choices": [
				{"id": "shelter_in_dry_room", "label": "Give the room to the families", "effect": "Trust %d→%d · Shelter +1 · Parts Crate %d→%d" % [settlement_trust, settlement_trust + 2, parts_before, maxi(0, parts_before - 1)], "enabled": true, "reason": ""},
				{"id": "preserve_dry_parts", "label": "Keep the parts dry and repair %s" % weakest_name, "effect": "%s %d→%d durability · Trust %d→%d" % [weakest_name, weakest_before, mini(weakest_maximum, weakest_before + 1), settlement_trust, settlement_trust - 1], "enabled": not weakest_id.is_empty(), "reason": "No installed system is damaged" if weakest_id.is_empty() else ""}
			]}
		"the_miller_with_a_broken_wheel":
			return {"id": "the_miller_with_a_broken_wheel", "title": "The Miller With a Broken Wheel", "body": "A miller offers sealed fuel tins if the fortress lends its bench and fitter. The repair is small; the stopped column is not.", "choices": [
				{"id": "lend_workshop_bench", "label": "Lend the workshop bench", "effect": "Fuel +1 · Trust +1 · Day +1 · Pressure +1 · Workshop -1 durability", "enabled": _has_operational_tag("repair"), "reason": "Requires a Ready Field Workshop"},
				{"id": "keep_moving", "label": "Keep the column moving", "effect": "Pressure -1 · Trust -1", "enabled": true, "reason": ""}
			]}
		"drain_pumps":
			return {"id": "drain_pumps", "title": "The Gallery Still Turns", "body": "The old pumps can pull water out of the lower roads, but only if the fortress holds position long enough to wake them.", "choices": [
				{"id": "drain_gallery", "label": "Restart the gallery pumps", "effect": "Day +1 · Rising water -2", "enabled": true, "reason": ""},
				{"id": "leave_gallery", "label": "Keep the column moving", "effect": "No delay · Water unchanged", "enabled": true, "reason": ""}
			]}
		"registry_salvage":
			return {"id": "registry_salvage", "title": "Names Beneath the Water", "body": "Six Ashmarks of sealed records remain within reach. Recovering them means opening the flooded stacks again.", "choices": [
				{"id": "recover_records", "label": "Recover the sealed records", "effect": "Ashmarks +6 · Rising water +1", "enabled": true, "reason": ""},
				{"id": "abandon_records", "label": "Mark the stacks and leave", "effect": "Rising water -1 · No salvage", "enabled": true, "reason": ""}
			]}
		"archive_broadcast":
			return {"id": "archive_broadcast", "title": "What the Archive Broadcasts", "body": "The gate can open its civic signal to every flooded district, or seal the archive and hide the medicine carrier's approach.", "choices": [
				{"id": "broadcast_archive", "label": "Broadcast the archive", "effect": "Knowledge +1 · Trust +1\nClimbers join the final contact", "enabled": true, "reason": ""},
				{"id": "seal_archive", "label": "Seal the archive", "effect": "Rising water -1 · Carrier damage -1\nFinal targeting stays forecast", "enabled": true, "reason": ""}
			]}
		"charcoal_vow":
			var charcoal_choices: Array[Dictionary] = [
				{"id": "bank_coals", "label": "Bank the cold coals", "effect": "Fuel +1 · Fireline +1", "enabled": true, "reason": ""},
				{"id": "share_coals", "label": "Share them downhill", "effect": "Trust +2 · Fireline -1", "enabled": true, "reason": ""}
			]
			if has_regional_development("cinder_refuge_chain"):
				charcoal_choices.append({"id": "call_refuge_chain", "label": "Call the refuge chain", "effect": "Trust +1 · Fireline -2 · no fuel taken", "enabled": true, "reason": "Unlocked by lighting the Ash Chapel refuge markers on an earlier march."})
			return {"id": "charcoal_vow", "title": "Coals for the Climb", "body": "The monastery can bank its last cold coals inside the fortress, share them below, or call a refuge network established by an earlier march.", "choices": charcoal_choices}
		"lift_engine_choice":
			var generator_ready := operational("generator_core")
			return {"id": "lift_engine_choice", "title": "The Counterweight Road", "body": "The old elevator can carry the fortress if its dynamo is powered, or the crew can cut a permanent switchback around the Warden.", "choices": [
				{"id": "power_lift", "label": "Power the industrial lift", "effect": "Industry +1 · Fireline +1 · full Warden contact", "enabled": generator_ready, "reason": "Requires an operational Generator Core" if not generator_ready else ""},
				{"id": "cut_switchback", "label": "Cut the switchback", "effect": "Day +1 · Warden damage -1 · dynamo contract fails", "enabled": true, "reason": ""}
			]}
		"commune_design":
			return {"id": "commune_design", "title": "Who Owns the Lift", "body": "Switchback Commune can publish the recovered lift pattern as shared infrastructure or return it to the Cinder Guild as a guarded industrial design.", "choices": [
				{"id": "share_lift_plan", "label": "Publish the communal plan", "effect": "Knowledge +1 · future Slag Tunnel becomes Known", "enabled": true, "reason": ""},
				{"id": "keep_guild_pattern", "label": "Keep the Guild pattern", "effect": "Ashmarks +12 · Industry +1", "enabled": true, "reason": ""}
			]}
		"observatory_signal":
			var observatory_choices: Array[Dictionary] = [
				{"id": "broadcast_beacons", "label": "Broadcast public beacons", "effect": "Knowledge +1 · Trust +1 · future Salt Mine becomes Known", "enabled": true, "reason": ""},
				{"id": "sell_coordinates", "label": "Sell the private line", "effect": "Ashmarks +10 · Ash front -1", "enabled": true, "reason": ""}
			]
			if has_regional_development("salt_shared_cisterns"):
				observatory_choices.append({"id": "call_cistern_network", "label": "Call the cistern network", "effect": "Fuel +1 · Ash front -1 · Trust +1", "enabled": true, "reason": "Unlocked by marking Lee Trench's water on an earlier march."})
			return {"id": "observatory_signal", "title": "The White Horizon", "body": "The buried lens can broadcast safe headings, sell one private line, or call a public water network established by an earlier march.", "choices": observatory_choices}
		"rival_terms":
			return {"id": "rival_terms", "title": "Two Fortresses on One Horizon", "body": "The Refugee Compact asks for an escorted approach. The rival captain offers a clean race to the water towers instead.", "choices": [
				{"id": "escort_compact", "label": "Hold the Compact line", "effect": "Shelter +1 · Trust +2 · rival fortress gains 1 endurance", "enabled": true, "reason": ""},
				{"id": "race_rival", "label": "Race for the towers", "effect": "Mobility +1 · Ash front +1 · rival impact -1", "enabled": true, "reason": ""}
			]}
		"chapel_refuge":
			return {"id": "chapel_refuge", "title": "Lamps in the Ash Chapel", "body": "Families shelter in the bypass while the abandoned bell and lamp oil could still be stripped for the climb. Marking the refuge makes this failure road part of a future network.", "choices": [
				{"id": "light_refuge_markers", "label": "Light the refuge markers", "effect": "Shelter +1 · Trust +2 · future Refuge Chain option", "enabled": true, "reason": ""},
				{"id": "strip_chapel_bell", "label": "Strip the bell and oil", "effect": "Ashmarks +8 · Industry +1", "enabled": true, "reason": ""}
			]}
		"trench_cistern":
			return {"id": "trench_cistern", "title": "Water Under the Lee", "body": "A buried cistern survived beneath the refuge trench. Sharing its location establishes a public water chain; sealing it keeps one reserve aboard.", "choices": [
				{"id": "share_trench_water", "label": "Mark the public cistern", "effect": "Fuel -1 · Shelter +1 · Trust +2 · future Cistern Network option", "enabled": fuel > 1, "reason": "Requires at least 2 fuel so the fortress can still depart" if fuel <= 1 else ""},
				{"id": "seal_trench_reserve", "label": "Seal one reserve aboard", "effect": "Fuel +1 · Knowledge -1", "enabled": true, "reason": ""}
			]}
	return {}

func resolve_campaign_event(choice_id: String) -> Dictionary:
	if campaign_event_pending.is_empty():
		return {"ok": false, "reason": "no campaign decision is pending"}
	var resolved_event := campaign_event_pending
	var result_message := ""
	var next_event := ""
	if resolved_event == "salvage_choice":
		if choice_id == "take_fuel":
			fuel += 2
			settlement_trust -= 1
			result_message = "The fortress recovers 2 fuel while the orchard workers scatter; Morrowline trust falls by 1."
		elif choice_id == "rescue_workers" and _has_operational_tag("refuge"):
			workers_rescued = true
			settlement_trust += 2
			shelter_tendency += 1
			day += 1
			campaign_pressure += 1
			result_message = "The Refugee Bunk carries the workers toward Morrowline; trust rises by 2, but the rescue costs 1 day and 1 pressure."
		else:
			return {"ok": false, "reason": "that orchard choice is not currently available"}
	elif resolved_event == "lost_signal":
		if choice_id == "restore_relay" and _has_operational_tag("signal"):
			relay_repaired = true
			knowledge_tendency += 1
			settlement_trust += 1
			campaign_pressure += 1
			result_message = "The Broken Relay broadcasts again. Forecasts improve and trust rises by 1, but blockade pressure rises by 1."
		elif choice_id == "move_silent":
			campaign_pressure = maxi(0, campaign_pressure - 1)
			route_risk_modifier = maxf(-0.12, route_risk_modifier - 0.03)
			result_message = "The fortress leaves the relay dark. Blockade pressure falls by 1 and future route risk falls by 3%."
		else:
			return {"ok": false, "reason": "that relay choice is not currently available"}
	elif resolved_event == "toll_decision":
		if choice_id == "pay_toll" and money >= 10:
			money -= 10
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The Red Wheel accepts 10 Ashmarks and delays pursuit; blockade pressure falls by 1."
		elif choice_id == "break_blockade":
			money += 8
			settlement_trust += 1
			campaign_pressure += 1
			result_message = "The fortress breaks the toll post, recovering 8 Ashmarks and 1 trust while blockade pressure rises by 1."
		else:
			return {"ok": false, "reason": "that toll choice is not currently available"}
	elif resolved_event == "mara_berth_choice":
		if specialist_id != "iven_pell":
			return {"ok": false, "reason": "Iven Pell is not occupying the specialist berth"}
		if choice_id == "keep_iven":
			campaign_decisions["mara_meeting"] = "decline_mara"
			result_message = "Iven Pell remains on signal watch. Mara stays with Morrowline's repair crews; exact nearby forecasts remain available."
		elif choice_id == "replace_iven_with_mara" and operational("field_workshop") and _has_operational_tag("crew"):
			specialist_id = "mara_flint"
			campaign_decisions["mara_meeting"] = "recruit_mara"
			next_event = "mara_workbench_choice"
			result_message = "Iven Pell joins Morrowline's relay crews and Mara Flint takes the specialist berth. Exact nearby forecasts are lost; workshop repairs gain 1 durability and the recovered forge core still needs a purpose."
		else:
			return {"ok": false, "reason": "Mara requires an operational crew-connected Field Workshop"}
	elif resolved_event == "mara_meeting":
		if choice_id == "recruit_mara" and bool(mara_recruitment_status().get("available", false)):
			specialist_id = "mara_flint"
			next_event = "mara_workbench_choice"
			result_message = "Mara Flint takes the specialist berth and staffs the Field Workshop; workshop repairs now restore 1 additional durability. One recovered forge core still needs a purpose."
		elif choice_id == "decline_mara":
			result_message = "Mara remains with Morrowline's repair crews. The specialist berth stays open and the fortress gains no workshop repair bonus."
		else:
			return {"ok": false, "reason": "Mara cannot join the fortress in its current condition"}
	elif resolved_event == "mara_workbench_choice":
		if specialist_id != "mara_flint":
			return {"ok": false, "reason": "Mara is not assigned to the fortress"}
		if choice_id == "rebuild_weakest":
			var weakest_id := _weakest_damaged_module_id()
			if weakest_id.is_empty():
				return {"ok": false, "reason": "no installed system is damaged"}
			var target_index := _module_index_by_id(weakest_id)
			var maximum := int(module_definition(weakest_id).get("durability", 1))
			var before := int(modules[target_index].get("durability", 0))
			var after := mini(maximum, before + 2)
			modules[target_index]["durability"] = after
			mara_repaired_module_id = weakest_id
			day += 1
			campaign_pressure += 1
			_recalculate()
			result_message = "Mara rebuilds %s from %d/%d to %d/%d durability. The careful work costs 1 day and adds 1 blockade pressure." % [module_definition(weakest_id).name, before, maximum, after, maximum]
		elif choice_id == "brace_refuge" and _has_recoverable_refuge_bunk():
			mara_repaired_module_id = ""
			result_message = "Mara turns the forge core into Refugee Bunk bracing. Each hit against the bunk loses 1 damage, but no system is repaired now."
		else:
			return {"ok": false, "reason": "that forge-core choice is not currently available"}
	elif resolved_event == "mara_followup":
		var followup := mara_followup_preview()
		if not bool(followup.get("valid", false)) or choice_id != String(followup.get("choice_id", "")):
			return {"ok": false, "reason": "Mara's workbench commitment is missing"}
		if String(followup.get("path", "")) == "repair":
			if bool(followup.get("held", false)):
				campaign_pressure = maxi(0, campaign_pressure - 1)
				result_message = "%s Mara's repair held through the fourth road, avoiding another roadside delay; blockade pressure falls by 1." % String(module_definition(mara_repaired_module_id).get("name", "The repaired system"))
			else:
				result_message = "%s failed after Mara's work. No blockade pressure is recovered." % String(module_definition(mara_repaired_module_id).get("name", "The repaired system"))
		else:
			if bool(followup.get("held", false)):
				settlement_trust += 1
				shelter_tendency += 1
				result_message = "The braced Refugee Bunk remains operational. Morrowline trust and Shelter tendency each rise by 1."
			else:
				result_message = "The Refugee Bunk is not operational when Mara checks it. The reserved bracing earns no trust or Shelter gain."
	elif resolved_event == "boiler_heartbeat":
		var engine_id := _operational_module_id_with_tag("engine", true)
		if engine_id.is_empty() or not _has_operational_tag("repair"):
			return {"ok": false, "reason": "the boiler incident no longer has an eligible engine and workshop"}
		var engine_name := String(module_definition(engine_id).get("name", engine_id))
		if choice_id == "inspect_boiler":
			var repair := _change_module_durability(engine_id, 1)
			day += 1
			campaign_pressure += 1
			result_message = "The workshop opens %s and restores it from %d to %d durability. The stop costs 1 day and adds 1 blockade pressure." % [engine_name, int(repair.before), int(repair.after)]
		elif choice_id == "keep_cadence":
			var engine_index := _module_index_by_id(engine_id)
			if engine_index < 0 or int(modules[engine_index].get("durability", 0)) <= 1:
				return {"ok": false, "reason": "keeping cadence would disable the engine"}
			var strain := _change_module_durability(engine_id, -1)
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "%s carries the cadence and falls from %d to %d durability; blockade pressure falls by 1." % [engine_name, int(strain.before), int(strain.after)]
		else:
			return {"ok": false, "reason": "that boiler response is not available"}
	elif resolved_event == "lift_chain_sings":
		var lift_id := _operational_module_id_with_tag("ammunition")
		if lift_id.is_empty() or not _has_operational_tag("weapon"):
			return {"ok": false, "reason": "the ammunition dependency is no longer operational"}
		if choice_id == "brace_lift_chain" and money >= 6:
			money -= 6
			route_risk_modifier = maxf(-0.12, route_risk_modifier - 0.02)
			result_message = "A six-Ashmark brace quiets the Ammunition Lift; future route risk falls by 2%."
		elif choice_id == "carry_lift_load":
			var strain := _change_module_durability(lift_id, -1)
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The Ammunition Lift carries the load and falls from %d to %d durability; blockade pressure falls by 1." % [int(strain.before), int(strain.after)]
		else:
			return {"ok": false, "reason": "that lift-chain response is not available"}
	elif resolved_event == "the_last_dry_room":
		var parts_id := _operational_module_id_with_tag("parts")
		if parts_id.is_empty() or not _has_operational_tag("refuge"):
			return {"ok": false, "reason": "the dry-room conflict no longer has both refuge and parts space"}
		if choice_id == "shelter_in_dry_room":
			var parts_use := _change_module_durability(parts_id, -1)
			settlement_trust += 2
			shelter_tendency += 1
			result_message = "The families take the dry room. Trust rises by 2 and Shelter by 1 while the Parts Crate falls from %d to %d durability." % [int(parts_use.before), int(parts_use.after)]
		elif choice_id == "preserve_dry_parts":
			var weakest_id := _weakest_damaged_module_id()
			if weakest_id.is_empty():
				return {"ok": false, "reason": "no installed system needs the dry parts"}
			var repair := _change_module_durability(weakest_id, 1)
			settlement_trust -= 1
			result_message = "%s is restored from %d to %d durability with the dry stock; trust falls by 1." % [String(module_definition(weakest_id).get("name", weakest_id)), int(repair.before), int(repair.after)]
		else:
			return {"ok": false, "reason": "that dry-room response is not available"}
	elif resolved_event == "the_miller_with_a_broken_wheel":
		if choice_id == "lend_workshop_bench" and _has_operational_tag("repair"):
			var workshop_id := _operational_module_id_with_tag("repair")
			var workshop_use := _change_module_durability(workshop_id, -1)
			fuel += 1
			settlement_trust += 1
			day += 1
			campaign_pressure += 1
			result_message = "The miller's wheel turns again. Fuel and trust rise by 1, the stop adds 1 day and pressure, and %s falls from %d to %d durability." % [String(module_definition(workshop_id).get("name", workshop_id)), int(workshop_use.before), int(workshop_use.after)]
		elif choice_id == "keep_moving":
			campaign_pressure = maxi(0, campaign_pressure - 1)
			settlement_trust -= 1
			result_message = "The fortress keeps moving. Blockade pressure falls by 1 and settlement trust falls by 1."
		else:
			return {"ok": false, "reason": "that roadside response is not available"}
	elif resolved_event == "drain_pumps":
		if choice_id == "drain_gallery":
			day += 1
			campaign_pressure = maxi(0, campaign_pressure - 2)
			result_message = "The gallery pumps wake for one full day. Rising water falls by 2 before the fortress leaves."
		elif choice_id == "leave_gallery":
			result_message = "The fortress leaves the old pumps quiet and keeps its place in the moving column."
		else:
			return {"ok": false, "reason": "that pump-gallery response is not available"}
	elif resolved_event == "registry_salvage":
		if choice_id == "recover_records":
			money += 6
			campaign_pressure += 1
			result_message = "The crew recovers six Ashmarks of sealed records while rising water gains 1."
		elif choice_id == "abandon_records":
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The flooded stacks are marked and abandoned; rising water falls by 1 as the column takes the high exit."
		else:
			return {"ok": false, "reason": "that registry response is not available"}
	elif resolved_event == "archive_broadcast":
		if choice_id == "broadcast_archive":
			knowledge_tendency += 1
			settlement_trust += 1
			result_message = "The Dry Archive broadcasts across Veyru. Knowledge and trust rise by 1, and Climbers answer the exposed signal."
		elif choice_id == "seal_archive":
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The archive seals its signal. Rising water falls by 1 and the medicine carrier gains cover for the final approach."
		else:
			return {"ok": false, "reason": "that archive commitment is not available"}
	elif resolved_event == "charcoal_vow":
		if choice_id == "bank_coals":
			fuel += 1
			campaign_pressure += 1
			result_message = "The fortress banks one fuel of cold coals while the fireline gains 1 behind the delayed column."
		elif choice_id == "share_coals":
			settlement_trust += 2
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The monastery sends its coals downhill. Trust rises by 2 and the organized firebreak reduces the fireline by 1."
		elif choice_id == "call_refuge_chain" and has_regional_development("cinder_refuge_chain"):
			settlement_trust += 1
			campaign_pressure = maxi(0, campaign_pressure - 2)
			result_message = "The Ash Chapel refuge chain answers the monastery. Trust rises by 1 and coordinated firebreaks reduce the fireline by 2 without consuming the coals."
		else:
			return {"ok": false, "reason": "that charcoal vow is not available"}
	elif resolved_event == "lift_engine_choice":
		if choice_id == "power_lift" and operational("generator_core"):
			industry_tendency += 1
			campaign_pressure += 1
			next_event = "commune_design"
			result_message = "The Generator Core wakes the industrial lift. Industry and fireline each rise by 1 before the Warden contact."
		elif choice_id == "cut_switchback":
			day += 1
			if cinder_contract_status == "accepted":
				cinder_contract_status = "failed"
			next_event = "commune_design"
			result_message = "The crew cuts a slower switchback. The final Warden loses 1 damage, but the powered-lift contract cannot be delivered."
		else:
			return {"ok": false, "reason": "that lift-engine choice is not available"}
	elif resolved_event == "commune_design":
		if choice_id == "share_lift_plan":
			knowledge_tendency += 1
			settlement_trust += 1
			result_message = "Switchback Commune publishes the lift plan. Knowledge and trust rise by 1, and a future Slag Tunnel approach begins Known."
		elif choice_id == "keep_guild_pattern":
			money += 12
			industry_tendency += 1
			result_message = "The Guild pays 12 Ashmarks for the guarded pattern and Industry rises by 1."
		else:
			return {"ok": false, "reason": "that commune decision is not available"}
	elif resolved_event == "observatory_signal":
		if choice_id == "broadcast_beacons":
			knowledge_tendency += 1
			settlement_trust += 1
			result_message = "The observatory broadcasts public headings. Knowledge and trust rise by 1, and future Salt Mine contacts begin Known."
		elif choice_id == "sell_coordinates":
			money += 10
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The private coordinates sell for 10 Ashmarks while the fortress gains one clear day ahead of the ash front."
		elif choice_id == "call_cistern_network" and has_regional_development("salt_shared_cisterns"):
			fuel += 1
			settlement_trust += 1
			campaign_pressure = maxi(0, campaign_pressure - 1)
			result_message = "The shared cistern network answers the observatory signal. Fuel and trust rise by 1 while ash-front pressure falls by 1."
		else:
			return {"ok": false, "reason": "that observatory decision is not available"}
	elif resolved_event == "rival_terms":
		if choice_id == "escort_compact":
			shelter_tendency += 1
			settlement_trust += 2
			result_message = "The fortress holds the Compact line. Shelter rises by 1 and trust by 2; the rival prepares for a longer fight."
		elif choice_id == "race_rival":
			mobility_tendency += 1
			campaign_pressure += 1
			result_message = "The fortress races the rival. Mobility and ash-front pressure rise by 1, but the final impact loses 1 damage."
		else:
			return {"ok": false, "reason": "those rival terms are not available"}
	elif resolved_event == "chapel_refuge":
		if choice_id == "light_refuge_markers":
			shelter_tendency += 1
			settlement_trust += 2
			result_message = "The chapel lamps become a marked refuge chain. Shelter rises by 1 and trust by 2; future Cinder columns can call that chain from Charcoal Monastery."
		elif choice_id == "strip_chapel_bell":
			money += 8
			industry_tendency += 1
			result_message = "The crew strips the old bell and lamp oil for 8 Ashmarks. Industry rises by 1, but no refuge chain survives the passage."
		else:
			return {"ok": false, "reason": "that chapel choice is not available"}
	elif resolved_event == "trench_cistern":
		if choice_id == "share_trench_water" and fuel > 1:
			fuel -= 1
			shelter_tendency += 1
			settlement_trust += 2
			result_message = "The fortress spends 1 fuel marking a safe public cistern. Shelter rises by 1 and trust by 2; future Salt caravans can answer from the network."
		elif choice_id == "seal_trench_reserve":
			fuel += 1
			knowledge_tendency -= 1
			result_message = "The cistern is sealed into the private route ledger. Fuel rises by 1 and Knowledge falls by 1."
		else:
			return {"ok": false, "reason": "that cistern choice is not available"}
	else:
		return {"ok": false, "reason": "unknown campaign event"}
	var completes_road_arrival := road_arrival_event_active() and resolved_event == "salvage_choice"
	campaign_decisions[resolved_event] = choice_id
	if resolved_event in OCCURRENCE_DEFS:
		_record_occurrence_resolution(resolved_event, choice_id)
	log.append(result_message)
	campaign_event_pending = next_event
	var response := {"ok": true, "event": resolved_event, "choice": choice_id, "message": result_message, "summary": summary()}
	if completes_road_arrival:
		var arrival := _complete_campaign_arrival(campaign_target_node)
		response["arrival_ready"] = true
		response["outcome"] = String(arrival.get("outcome", encounter_outcome))
		response["report"] = arrival.get("report", encounter_report.duplicate())
		response["summary"] = arrival.get("summary", summary())
	return response

func iven_recruitment_status() -> Dictionary:
	if not campaign_active or current_location != "broken_relay" or phase != "map":
		return {"available": false, "reason": "Iven Pell can only join at the Broken Relay"}
	if not relay_repaired:
		return {"available": false, "reason": "Iven will not leave until the relay is restored"}
	if not specialist_id.is_empty():
		return {"available": false, "reason": "a specialist is already assigned to the fortress"}
	if not _has_operational_tag("crew"):
		return {"available": false, "reason": "an operational Crew Quarters is required"}
	if money < 12:
		return {"available": false, "reason": "Iven needs 12 Ashmarks of route supplies"}
	return {"available": true, "reason": "Iven can join as signal officer"}

func recruit_iven_pell() -> Dictionary:
	var status := iven_recruitment_status()
	if not bool(status.get("available", false)):
		return {"ok": false, "reason": String(status.get("reason", "recruitment unavailable"))}
	money -= 12
	specialist_id = "iven_pell"
	log.append("Iven Pell joins as signal officer. Immediate-node forecasts now reveal exact threats and gain a risk discount.")
	return {"ok": true, "specialist": specialist_id, "summary": summary()}

func begin_campaign_route(node_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	if not campaign_active:
		return {"ok": false, "reason": "the authored campaign has not started"}
	if encounter_active or phase not in ["refit", "map", "settlement"]:
		return {"ok": false, "reason": "the fortress cannot choose a map route in the current phase"}
	if campaign_region_id == "ashgate_lowlands" and guard_contract_status == "offered":
		return {"ok": false, "reason": "answer the Ashgate guard contract before departure"}
	if campaign_region_id == "flooded_veyru" and veyru_contract_status == "offered":
		return {"ok": false, "reason": "answer the Lantern Quay medicine contract before departure"}
	if campaign_region_id == "cinder_spine" and cinder_contract_status == "offered":
		return {"ok": false, "reason": "answer the Blackkiln dynamo contract before departure"}
	if campaign_region_id == "white_salt_expanse" and salt_contract_status == "offered":
		return {"ok": false, "reason": "answer the Saltglass beacon escort before departure"}
	if not campaign_event_pending.is_empty():
		return {"ok": false, "reason": "resolve the current node decision before leaving"}
	var lock_reason := campaign_node_lock_reason(node_id)
	if not lock_reason.is_empty() and node_id in campaign_edges().get(current_location, []):
		return {"ok": false, "reason": lock_reason}
	if node_id not in campaign_available_nodes():
		return {"ok": false, "reason": "that node is not reachable from the current position"}
	var preview := campaign_node_preview(node_id, doctrine)
	if fuel < int(preview.get("fuel", 0)):
		return {"ok": false, "reason": "not enough fuel for that route"}
	if not _has_engine():
		return {"ok": false, "reason": "no operational fuel-connected engine"}
	target_doctrine = doctrine
	encounter_target_doctrine = doctrine
	heat_relief = 0
	heat_surge = (2 if doctrine == "run_hot" else 0) + (1 if campaign_region_id == "cinder_spine" and cinder_contract_status == "accepted" else 0)
	vent_exposure = false
	_recalculate()
	fuel -= int(preview.fuel)
	day += int(preview.days)
	campaign_pressure += int(preview.pressure_gain)
	current_route_risk = float(preview.risk)
	encounter_pressure = int(preview.encounter_pressure)
	pending_route_reward = int(preview.reward)
	campaign_target_node = node_id
	journey_destination = node_id
	journey_route = node_id
	journey_node = node_id
	journey_leg = campaign_encounters_completed + 1
	command_points = 2
	power_priority = "balanced"
	phase = "final_battle" if node_id == campaign_final_node_id() else "battle"
	var node: Dictionary = CAMPAIGN_NODES[node_id]
	var composition: Array = node.get("encounter", []).duplicate()
	if node_id == "meridian_pass" and campaign_pressure_band() == "break":
		composition.append("climbers")
	elif node_id == "dry_archive" and String(campaign_decisions.get("archive_broadcast", "")) == "broadcast_archive":
		composition.append("climbers")
	_configure_encounter(composition, String(node.name), String(JOURNEY_NODES.get(node_id, {}).get("description", "The route narrows ahead.")))
	if node_id == "morrowline_camp" and guard_contract_status == "accepted":
		for index in range(encounter_enemies.size()):
			encounter_enemies[index]["hp"] = int(encounter_enemies[index].get("hp", 0)) + 1
			encounter_enemies[index]["max_hp"] = int(encounter_enemies[index].get("max_hp", 0)) + 1
		_encounter_log("Guard contract: the raiders commit to the convoy approach, adding one enemy endurance.")
	if campaign_region_id == "white_salt_expanse" and salt_contract_status == "accepted":
		for index in range(encounter_enemies.size()):
			if String(encounter_enemies[index].get("id", "")) == "rival_scouts":
				encounter_enemies[index]["hp"] = int(encounter_enemies[index].get("hp", 0)) + 1
				encounter_enemies[index]["max_hp"] = int(encounter_enemies[index].get("max_hp", 0)) + 1
		_encounter_log("Beacon escort: rival scouts commit to the visible convoy signal, adding one endurance.")
	var pre_contact_occurrence := _schedule_first_pre_contact_occurrence(node_id)
	log.append("Campaign route selected: %s. %s is %s (%d)." % [String(node.name), campaign_pressure_name(), campaign_pressure_band().replace("_", " "), campaign_pressure])
	return {"ok": true, "node": node_id, "preview": preview, "forecast": encounter_forecast(), "encounter": encounter_summary(), "pre_contact_event": String(pre_contact_occurrence.get("event_id", "")), "summary": summary()}

func adjacent_modules(instance: Dictionary) -> Array[Dictionary]:
	var adjacent: Array[Dictionary] = []
	var seen_indices: Dictionary = {}
	var source_index := int(module_at(Vector2i(instance.get("position", Vector2i.ZERO))).get("index", -1))
	for source_cell in occupied_cells(instance):
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor_cell: Vector2i = source_cell + direction
			var neighbor := module_at(neighbor_cell)
			var neighbor_index := int(neighbor.get("index", -1))
			if neighbor_index < 0 or neighbor_index == source_index or seen_indices.has(neighbor_index):
				continue
			seen_indices[neighbor_index] = true
			adjacent.append(neighbor)
	return adjacent

func _connection_source_available(instance: Dictionary) -> bool:
	if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
		return false
	var definition := module_definition(String(instance.get("id", "")))
	return int(definition.get("power_draw", 0)) <= 0 or total_power_draw() <= total_power_output()

func _has_adjacent_tag(instance: Dictionary, tag: String) -> bool:
	for neighbor in adjacent_modules(instance):
		var definition := module_definition(String(neighbor.get("id", "")))
		if tag in definition.get("tags", []) and _connection_source_available(neighbor):
			return true
	return false

func _has_adjacent_operational_module(instance: Dictionary, module_id: String) -> bool:
	for neighbor in adjacent_modules(instance):
		if String(neighbor.get("id", "")) != module_id:
			continue
		if bool(dependency_status(neighbor).get("operational", false)):
			return true
	return false

func dependency_status(instance: Dictionary) -> Dictionary:
	var module_id := String(instance.get("id", ""))
	var definition := module_definition(module_id)
	var tags: Array = definition.get("tags", [])
	var connections: Array[Dictionary] = []
	var reasons: Array[String] = []
	var benefits: Array[String] = []
	var state_name := "ready"
	var is_operational := true
	if int(instance.get("durability", 0)) <= 0:
		return {"module_id": module_id, "state": "offline", "operational": false, "connections": connections, "reasons": ["module is disabled"], "benefits": benefits}
	if bool(instance.get("sealed", false)):
		return {"module_id": module_id, "state": "offline", "operational": false, "connections": connections, "reasons": ["compartment is sealed"], "benefits": benefits}
	if int(definition.get("power_draw", 0)) > 0:
		var power_ready := total_power_draw() <= total_power_output()
		connections.append({"id": "power_to_module", "satisfied": power_ready, "benefit": "shared power bus is stable", "failure": "insufficient shared power"})
		if power_ready:
			benefits.append("powered")
		else:
			state_name = "offline"
			is_operational = false
			reasons.append("insufficient shared power")
	if "engine" in tags:
		var fuel_ready := _has_adjacent_tag(instance, "fuel")
		connections.append({"id": "fuel_to_engine", "satisfied": fuel_ready, "benefit": "adjacent fuel feed enables movement", "failure": "engine has no adjacent fuel feed"})
		if fuel_ready:
			benefits.append("fuel feed connected")
		else:
			state_name = "offline"
			is_operational = false
			reasons.append("engine has no adjacent Coal Cell")
	if "weapon" in tags:
		var ammunition_ready := _has_adjacent_tag(instance, "ammunition")
		connections.append({"id": "ammunition_to_weapon", "satisfied": ammunition_ready, "benefit": "full reload cycle", "failure": "weapon uses emergency ammunition"})
		if ammunition_ready:
			benefits.append("ammunition lift connected")
		elif is_operational:
			state_name = "strained"
			reasons.append("no adjacent Ammunition Lift; emergency ammunition only")
	if "repair" in tags:
		var crew_ready := _has_adjacent_tag(instance, "crew")
		connections.append({"id": "crew_to_workshop", "satisfied": crew_ready, "benefit": "workshop crew available", "failure": "repair unavailable"})
		if crew_ready:
			benefits.append("crew station connected")
		else:
			state_name = "offline"
			is_operational = false
			reasons.append("workshop has no adjacent Crew Quarters")
		var parts_ready := _has_adjacent_tag(instance, "parts")
		connections.append({"id": "parts_to_workshop", "satisfied": parts_ready, "benefit": "full repair amount", "failure": "temporary patch only"})
		if parts_ready:
			benefits.append("parts supply connected")
		elif is_operational:
			state_name = "strained"
			reasons.append("no adjacent Parts Crate; repairs are limited")
	if "crew_support" in tags:
		var staff_ready := _has_adjacent_tag(instance, "crew")
		connections.append({"id": "crew_to_specialist_facility", "satisfied": staff_ready, "benefit": "specialist facility staffed", "failure": "specialist effect unavailable"})
		if staff_ready:
			benefits.append("specialist facility staffed")
		else:
			state_name = "offline"
			is_operational = false
			reasons.append("facility has no adjacent Crew Quarters")
	if "signal" in tags:
		var visibility_ready := bool(instance.get("exterior", false))
		if not visibility_ready:
			for neighbor in adjacent_modules(instance):
				var neighbor_definition := module_definition(String(neighbor.get("id", "")))
				if "signal" in neighbor_definition.get("tags", []) and bool(neighbor.get("exterior", false)) and _connection_source_available(neighbor):
					visibility_ready = true
					break
		connections.append({"id": "visibility_to_signal", "satisfied": visibility_ready, "benefit": "exact threat target forecast", "failure": "route forecast remains broad"})
		if visibility_ready:
			benefits.append("clear exterior visibility")
		elif is_operational:
			state_name = "strained"
			reasons.append("signal has no exterior visibility source")
	if "water" in tags:
		var maintenance_ready := _has_adjacent_operational_module(instance, "field_workshop")
		connections.append({"id": "maintenance_to_condenser", "satisfied": maintenance_ready, "benefit": "dry-road recovery cycle available", "failure": "condenser cannot sustain the dry-road benefit"})
		if maintenance_ready:
			benefits.append("Field Workshop maintenance connected")
		elif is_operational:
			state_name = "strained"
			reasons.append("no adjacent operational Field Workshop; dry-road benefit unavailable")
	return {"module_id": module_id, "state": state_name, "operational": is_operational, "connections": connections, "reasons": reasons, "benefits": benefits}

func dependency_status_at(cell: Vector2i) -> Dictionary:
	var instance := module_at(cell)
	if instance.is_empty():
		return {}
	return dependency_status(instance)

func module_dependency_card(instance: Dictionary) -> Dictionary:
	var module_id := String(instance.get("id", ""))
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {}
	var status := dependency_status(instance)
	var connections: Array = status.get("connections", [])
	var dependency_labels := {
		"power_to_module": "shared power bus",
		"fuel_to_engine": "adjacent Coal Cell",
		"ammunition_to_weapon": "adjacent Ammunition Lift",
		"crew_to_workshop": "adjacent Crew Quarters",
		"parts_to_workshop": "adjacent Parts Crate",
		"visibility_to_signal": "exterior signal visibility",
		"maintenance_to_condenser": "adjacent operational Field Workshop"
		,"crew_to_specialist_facility": "adjacent Crew Quarters"
	}
	var failure_texts := {
		"power_to_module": "Power demand can force this module offline.",
		"fuel_to_engine": "Losing the adjacent Coal Cell stops movement and blocks departure.",
		"ammunition_to_weapon": "Losing the Ammunition Lift strains this weapon and reduces its damage.",
		"crew_to_workshop": "Losing Crew Quarters takes the workshop offline and stops field repairs.",
		"parts_to_workshop": "Losing the Parts Crate limits each workshop repair.",
		"visibility_to_signal": "Losing exterior visibility broadens route and target forecasts.",
		"maintenance_to_condenser": "Losing workshop access removes the Dry Cistern Cut fuel saving and route access."
		,"crew_to_specialist_facility": "Losing adjacent Crew Quarters disables this staffed facility and its specialist."
	}
	var counter_texts := {
		"power_to_module": "Keep total draw at or below output, or restore a Generator Core.",
		"fuel_to_engine": "Keep a working Coal Cell adjacent; reposition or repair it before departure.",
		"ammunition_to_weapon": "Place a working Ammunition Lift adjacent, or accept emergency ammunition.",
		"crew_to_workshop": "Place working Crew Quarters adjacent before relying on field repair.",
		"parts_to_workshop": "Place a working Parts Crate adjacent to restore full repair output.",
		"visibility_to_signal": "Use an exterior signal module or place this beside one.",
		"maintenance_to_condenser": "Keep an operational Field Workshop adjacent, or refit before choosing the dry road."
		,"crew_to_specialist_facility": "Keep operational Crew Quarters adjacent to staff this facility."
	}
	var dependency_names: Array[String] = []
	var focus_connection: Dictionary = {}
	for connection in connections:
		var connection_id := String(connection.get("id", ""))
		dependency_names.append(String(dependency_labels.get(connection_id, connection_id.replace("_", " "))))
		if focus_connection.is_empty() and not bool(connection.get("satisfied", false)):
			focus_connection = connection
	if focus_connection.is_empty():
		for connection in connections:
			if String(connection.get("id", "")) != "power_to_module":
				focus_connection = connection
				break
	if focus_connection.is_empty() and not connections.is_empty():
		focus_connection = connections[0]

	var reasons: Array = status.get("reasons", [])
	var benefits: Array = status.get("benefits", [])
	var current_detail := String(reasons[0]) if not reasons.is_empty() else ("; ".join(benefits) if not benefits.is_empty() else "no operating input required")
	var direct_dependency := ", ".join(dependency_names) if not dependency_names.is_empty() else "no required operating input"
	var next_failure := "Damage reduces this module's own capability before affecting another system."
	var legal_counter := "Repair before durability reaches zero or place it behind an adjacent armor module."
	if not focus_connection.is_empty():
		var focus_id := String(focus_connection.get("id", ""))
		next_failure = String(failure_texts.get(focus_id, next_failure))
		legal_counter = String(counter_texts.get(focus_id, legal_counter))
	else:
		match module_id:
			"generator_core":
				direct_dependency = "no input · supplies the shared power bus"
				next_failure = "If disabled, four power is lost and powered systems may go offline."
				legal_counter = "Keep power draw within reserve or protect the core with adjacent armor."
			"coal_cell":
				direct_dependency = "no input · supplies adjacent engines"
				next_failure = "If disabled or moved, an adjacent engine loses its fuel feed and movement stops."
				legal_counter = "Keep it beside an engine and repair it before durability reaches zero."
			"ammunition_lift":
				direct_dependency = "shared power bus · supplies adjacent weapons"
				next_failure = "If disabled or moved, adjacent weapons fall back to emergency ammunition."
				legal_counter = "Keep it powered beside a weapon or retain a lower-output fallback weapon."
			"parts_crate":
				direct_dependency = "no input · supplies adjacent workshops"
				next_failure = "If disabled or moved, adjacent workshops perform only limited repairs."
				legal_counter = "Keep it beside a workshop or reserve settlement repair for critical damage."
			_:
				if "armor" in definition.get("tags", []):
					direct_dependency = "adjacent system placement"
					next_failure = "If disabled or moved, its adjacent system loses damage absorption."
					legal_counter = "Place it beside the system you cannot afford to lose and repair it before zero."
	if module_id == "ammunition_lift":
		direct_dependency = "shared power bus · supplies adjacent weapons"
		next_failure = "If disabled or moved, adjacent weapons fall back to emergency ammunition."
		legal_counter = "Keep it powered beside a weapon or retain a lower-output fallback weapon."
	elif module_id == "crew_quarters":
		direct_dependency = "shared power bus · staffs adjacent workshops"
		next_failure = "If disabled or moved, adjacent workshops lose their crew and go offline."
		legal_counter = "Keep it powered beside the workshop or protect it with adjacent armor."
	return {
		"module_id": module_id,
		"name": String(definition.get("name", module_id)),
		"state": String(status.get("state", "offline")),
		"current_detail": current_detail,
		"direct_dependency": direct_dependency,
		"next_failure": next_failure,
		"legal_counter": legal_counter
	}

func dependency_summary() -> Dictionary:
	var result := {"ready": 0, "strained": 0, "offline": 0}
	for instance in modules:
		var status := dependency_status(instance)
		var state_name := String(status.get("state", "offline"))
		result[state_name] = int(result.get(state_name, 0)) + 1
	return result

func total_mass() -> int:
	var total := 0
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		total += int(definition.get("mass", 0))
	return total

func total_power_output() -> int:
	var total := BASE_POWER
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if int(instance.get("durability", 0)) > 0 and not bool(instance.get("sealed", false)):
			total += int(definition.get("power_output", 0))
	return total

func total_power_draw() -> int:
	var total := 0
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if int(instance.get("durability", 0)) > 0 and not bool(instance.get("sealed", false)):
			total += int(definition.get("power_draw", 0))
	return total

func total_heat() -> int:
	var total := 0
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if int(instance.get("durability", 0)) > 0 and not bool(instance.get("sealed", false)):
			total += int(definition.get("heat", 0))
	return total

func operational(module_id: String) -> bool:
	for instance in modules:
		if String(instance.get("id", "")) == module_id:
			return bool(dependency_status(instance).get("operational", false))
	return false

func _recalculate() -> void:
	var was_overheated := heat > BASE_HEAT_LIMIT
	heat = maxi(0, total_heat() + heat_surge - heat_relief)
	if heat > BASE_HEAT_LIMIT and not was_overheated:
		log.append("Heat warning: the fortress is above its safe operating limit.")

func route_preview(route_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	var route: Dictionary = ROUTES.get(route_id, {})
	if route.is_empty():
		return {"ok": false, "reason": "unknown route"}
	var mass_penalty := 1 if total_mass() > BASE_MASS_LIMIT - 2 else 0
	var fuel_cost := int(route.get("fuel", 0)) + mass_penalty
	var predicted_heat := maxi(0, total_heat() + (2 if doctrine == "run_hot" else 0))
	var signal_discount := 0.08 if _has_ready_tag("forecast") else 0.0
	var heat_penalty := 0.08 if predicted_heat > BASE_HEAT_LIMIT else 0.0
	var risk := clampf(float(route.get("risk", 0.0)) + route_risk_modifier + float(mass_penalty) * 0.05 + heat_penalty - signal_discount, 0.0, 0.95)
	var pressure := int(ROUTE_PRESSURE.get(route_id, 0))
	if predicted_heat > BASE_HEAT_LIMIT:
		pressure += 1
	if signal_discount > 0.0:
		pressure = maxi(0, pressure - 1)
	return {"ok": true, "days": int(route.get("days", 0)), "fuel": fuel_cost, "risk": risk, "pressure": pressure, "predicted_heat": predicted_heat, "mass_penalty": mass_penalty, "signal_discount": signal_discount}

func travel(route_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	var route: Dictionary = ROUTES.get(route_id, {})
	var preview := route_preview(route_id, doctrine)
	if not bool(preview.get("ok", false)):
		return preview
	if fuel < int(preview.get("fuel", 0)):
		return {"ok": false, "reason": "not enough fuel"}
	if not _has_engine():
		return {"ok": false, "reason": "no operational fuel-connected engine"}
	target_doctrine = doctrine
	heat_relief = 0
	heat_surge = 2 if doctrine == "run_hot" else 0
	vent_exposure = false
	_recalculate()
	fuel -= int(preview.get("fuel", 0))
	day += int(route.get("days", 0))
	pending_route_reward = int(route.get("reward", 0))
	current_route_risk = float(preview.get("risk", 0.0))
	encounter_pressure = int(preview.get("pressure", 0))
	var threat := _deterministic_threat(route_id)
	log.append("Travelled %s; fuel %d; risk %.2f; pressure %d; forecast %s." % [String(route.get("name", route_id)), int(preview.fuel), current_route_risk, encounter_pressure, threat])
	return {"ok": true, "days": int(route.get("days", 0)), "fuel": int(preview.fuel), "risk": current_route_risk, "pressure": encounter_pressure, "threat": threat, "summary": summary()}

func resolve_threat(threat_id: String) -> Dictionary:
	var threat: Dictionary = THREATS.get(threat_id, {})
	if threat.is_empty():
		return {"ok": false, "reason": "unknown threat"}
	var target_index := _choose_target(threat)
	if target_index < 0:
		hull_condition = maxi(0, hull_condition - int(threat.get("damage", 1)))
		log.append("%s hit the hull; no valid module target." % String(threat.get("name", threat_id)))
		return {"ok": true, "target": "hull", "damage": int(threat.get("damage", 1)), "summary": summary()}
	var target: Dictionary = modules[target_index]
	var damage := int(threat.get("damage", 1))
	target["durability"] = maxi(0, int(target.get("durability", 0)) - damage)
	modules[target_index] = target
	log.append("%s damaged %s for %d." % [String(threat.get("name", threat_id)), String(target.get("id", "unknown")), damage])
	_recalculate()
	return {"ok": true, "target": String(target.get("id", "unknown")), "damage": damage, "summary": summary()}

func intervene(intervention_id: String, target_module: String = "") -> Dictionary:
	if command_points <= 0:
		return {"ok": false, "reason": "no command points"}
	if intervention_id == "shift_power":
		command_points -= 1
		power_priority = "weapons" if power_priority != "weapons" else "engines"
		var heat_change := 1 if power_priority == "weapons" else -1
		heat_surge += heat_change
		heat_surge = maxi(0, heat_surge)
		_recalculate()
		log.append("Shifted power priority to %s." % power_priority)
		return {"ok": true, "intervention": intervention_id, "priority": power_priority, "heat_change": heat_change, "summary": summary()}
	if intervention_id == "seal_compartment":
		var target_index := _module_index_by_id(target_module)
		if target_index < 0:
			return {"ok": false, "reason": "target module not found"}
		if int(modules[target_index].get("durability", 0)) <= 0:
			return {"ok": false, "reason": "destroyed modules cannot be sealed"}
		if bool(modules[target_index].get("sealed", false)):
			return {"ok": false, "reason": "module is already sealed"}
		var sealed := _set_sealed(target_module, true)
		assert(sealed)
		command_points -= 1
		log.append("Sealed %s to contain damage." % target_module)
		_recalculate()
		return {"ok": true, "intervention": intervention_id, "target_module": target_module, "summary": summary()}
	if intervention_id == "vent_heat":
		var heat_before := heat
		command_points -= 1
		heat_relief += 3
		vent_exposure = true
		_recalculate()
		log.append("Vented heat; exterior exposure increased temporarily.")
		return {"ok": true, "intervention": intervention_id, "heat_removed": maxi(0, heat_before - heat), "exterior_exposed": true, "summary": summary()}
	if intervention_id == "cut_loose_cargo":
		var removed_module := _remove_first_sacrificable_cargo()
		if removed_module.is_empty():
			return {"ok": false, "reason": "no cargo to cut loose"}
		command_points -= 1
		log.append("Cut loose %s to protect the fortress." % String(module_definition(removed_module).get("name", removed_module)))
		_recalculate()
		_refresh_veyru_contract_state()
		return {"ok": true, "intervention": intervention_id, "removed_module": removed_module, "summary": summary()}
	return {"ok": false, "reason": "unknown intervention"}

func repair_module(module_id: String, amount: int = 1) -> Dictionary:
	if not _has_operational_tag("repair"):
		return {"ok": false, "reason": "no operational crew-connected workshop"}
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) == module_id:
			var definition := module_definition(module_id)
			instance["durability"] = mini(int(definition.get("durability", 1)), int(instance.get("durability", 0)) + maxi(1, amount))
			modules[index] = instance
			log.append("Repaired %s." % module_id)
			return {"ok": true, "summary": summary()}
	return {"ok": false, "reason": "module not found"}

func summary() -> Dictionary:
	var dependencies := dependency_summary()
	return {
		"day": day,
		"fuel": fuel,
		"money": money,
		"command_points": command_points,
		"heat": heat,
		"heat_limit": BASE_HEAT_LIMIT,
		"mass": total_mass(),
		"mass_limit": chassis_mass_limit(),
		"exterior_limit": chassis_exterior_limit(),
		"chassis_template_id": chassis_template_id,
		"power_output": total_power_output(),
		"power_draw": total_power_draw(),
		"hull_condition": hull_condition,
		"current_location": current_location,
		"journey_node": journey_node,
		"journey_destination": journey_destination,
		"journey_route": journey_route,
		"journey_complete": journey_complete,
		"encounter_active": encounter_active,
		"encounter_step": encounter_step,
		"encounter_progress": encounter_progress,
		"encounter_outcome": encounter_outcome,
		"module_count": modules.size(),
		"stored_module_count": stored_modules.size(),
		"dependencies": dependencies,
		"can_travel": phase == "refit" and _has_engine() and fuel > 0 and not encounter_active,
		"can_continue": phase == "settlement" and _has_engine() and fuel > 0,
		"power_stable": total_power_draw() <= total_power_output(),
		"route_risk": current_route_risk,
		"encounter_pressure": encounter_pressure,
		"pending_route_reward": pending_route_reward,
		"target_doctrine": target_doctrine,
		"phase": phase,
		"journey_leg": journey_leg,
		"run_complete": run_complete,
		"final_result": final_result,
		"settlement_actions_remaining": settlement_actions_remaining,
		"campaign_active": campaign_active,
		"campaign_region_id": campaign_region_id,
		"campaign_encounters_completed": campaign_encounters_completed,
		"campaign_path": campaign_path.duplicate(),
		"campaign_target_node": campaign_target_node,
		"campaign_pressure": campaign_pressure,
		"campaign_pressure_band": campaign_pressure_band(),
		"campaign_retreats": campaign_retreats,
		"campaign_event_pending": campaign_event_pending,
		"campaign_decisions": campaign_decisions.duplicate(true),
		"occurrence_stream": OCCURRENCE_STREAM_NAME,
		"occurrence_stream_cursor": occurrence_stream_cursor,
		"occurrence_active_phase": occurrence_active_phase,
		"occurrence_phase_history": occurrence_phase_history.duplicate(),
		"occurrence_history": occurrence_history.duplicate(true),
		"occurrence_cooldowns": occurrence_cooldowns.duplicate(true),
		"guard_contract_status": guard_contract_status,
		"veyru_contract_status": veyru_contract_status,
		"veyru_medicine_carrier_id": veyru_medicine_carrier_id,
		"cinder_contract_status": cinder_contract_status,
		"salt_contract_status": salt_contract_status,
		"settlement_trust": settlement_trust,
		"mobility_tendency": mobility_tendency,
		"shelter_tendency": shelter_tendency,
		"knowledge_tendency": knowledge_tendency,
		"industry_tendency": industry_tendency,
		"specialist_id": specialist_id,
		"mara_repaired_module_id": mara_repaired_module_id,
		"relay_repaired": relay_repaired,
		"workers_rescued": workers_rescued,
		"regional_developments": regional_developments.duplicate(),
		"mastery_experiment_id": mastery_experiment_id,
		"acquired_intel_ids": acquired_intel_ids.duplicate(),
		"purchased_market_offer_ids": purchased_market_offer_ids.duplicate()
	}

func serialize() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"chassis_template_id": chassis_template_id,
		"seed": seed,
		"day": day,
		"fuel": fuel,
		"money": money,
		"command_points": command_points,
		"heat": heat,
		"hull_condition": hull_condition,
		"current_location": current_location,
		"route_risk_modifier": route_risk_modifier,
		"current_route_risk": current_route_risk,
		"encounter_pressure": encounter_pressure,
		"pending_route_reward": pending_route_reward,
		"target_doctrine": target_doctrine,
		"power_priority": power_priority,
		"heat_relief": heat_relief,
		"heat_surge": heat_surge,
		"vent_exposure": vent_exposure,
		"journey_node": journey_node,
		"journey_destination": journey_destination,
		"journey_route": journey_route,
		"journey_complete": journey_complete,
		"encounter_active": encounter_active,
		"encounter_step": encounter_step,
		"encounter_progress": encounter_progress,
		"encounter_enemies": encounter_enemies.duplicate(true),
		"encounter_report": encounter_report.duplicate(),
		"encounter_outcome": encounter_outcome,
		"encounter_intervention_used": encounter_intervention_used,
		"encounter_target_doctrine": encounter_target_doctrine,
		"phase": phase,
		"journey_leg": journey_leg,
		"run_complete": run_complete,
		"final_result": final_result,
		"settlement_actions_remaining": settlement_actions_remaining,
		"settlement_report": settlement_report.duplicate(),
		"campaign_active": campaign_active,
		"campaign_region_id": campaign_region_id,
		"campaign_encounters_completed": campaign_encounters_completed,
		"campaign_path": campaign_path.duplicate(),
		"campaign_target_node": campaign_target_node,
		"campaign_last_safe_node": campaign_last_safe_node,
		"campaign_pressure": campaign_pressure,
		"campaign_retreats": campaign_retreats,
		"campaign_event_pending": campaign_event_pending,
		"campaign_decisions": campaign_decisions.duplicate(true),
		"occurrence_stream": OCCURRENCE_STREAM_NAME,
		"occurrence_stream_cursor": occurrence_stream_cursor,
		"occurrence_active_phase": occurrence_active_phase,
		"occurrence_phase_history": occurrence_phase_history.duplicate(),
		"occurrence_history": occurrence_history.duplicate(true),
		"occurrence_cooldowns": occurrence_cooldowns.duplicate(true),
		"guard_contract_status": guard_contract_status,
		"veyru_contract_status": veyru_contract_status,
		"veyru_medicine_carrier_id": veyru_medicine_carrier_id,
		"cinder_contract_status": cinder_contract_status,
		"salt_contract_status": salt_contract_status,
		"settlement_trust": settlement_trust,
		"mobility_tendency": mobility_tendency,
		"shelter_tendency": shelter_tendency,
		"knowledge_tendency": knowledge_tendency,
		"industry_tendency": industry_tendency,
		"specialist_id": specialist_id,
		"mara_repaired_module_id": mara_repaired_module_id,
		"relay_repaired": relay_repaired,
		"workers_rescued": workers_rescued,
		"mastery_experiment_id": mastery_experiment_id,
		"regional_developments": regional_developments.duplicate(),
		"acquired_intel_ids": acquired_intel_ids.duplicate(),
		"purchased_market_offer_ids": purchased_market_offer_ids.duplicate(),
		"modules": _serialized_modules(),
		"stored_modules": _serialized_stored_modules(),
		"log": log.duplicate()
	}

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(String(item))
	return result

func _validated_occurrence_state(data: Dictionary, pending_event: String) -> Dictionary:
	if data.has("occurrence_stream") and String(data.get("occurrence_stream", "")) != OCCURRENCE_STREAM_NAME:
		return {"ok": false, "reason": "checkpoint contains an unknown occurrence stream"}
	var cursor := int(data.get("occurrence_stream_cursor", 0))
	if cursor < 0:
		return {"ok": false, "reason": "checkpoint contains an invalid occurrence cursor"}
	var active_phase := String(data.get("occurrence_active_phase", ""))
	var raw_phase_history: Variant = data.get("occurrence_phase_history", [])
	if not raw_phase_history is Array or raw_phase_history.size() > OCCURRENCE_HISTORY_LIMIT:
		return {"ok": false, "reason": "checkpoint occurrence phase history is malformed or unbounded"}
	var phase_history := _string_array(raw_phase_history)
	var unique_phases: Dictionary = {}
	for phase_id in phase_history:
		if phase_id.is_empty() or unique_phases.has(phase_id):
			return {"ok": false, "reason": "checkpoint occurrence phase history contains an invalid phase"}
		unique_phases[phase_id] = true
	var raw_history: Variant = data.get("occurrence_history", [])
	if not raw_history is Array or raw_history.size() > OCCURRENCE_HISTORY_LIMIT:
		return {"ok": false, "reason": "checkpoint occurrence history is malformed or unbounded"}
	var history: Array[Dictionary] = []
	for raw_entry in raw_history:
		if not raw_entry is Dictionary:
			return {"ok": false, "reason": "checkpoint occurrence history contains a malformed entry"}
		var event_id := String(raw_entry.get("event_id", ""))
		var choice_id := String(raw_entry.get("choice_id", ""))
		var phase_id := String(raw_entry.get("phase_id", ""))
		if event_id not in OCCURRENCE_DEFS or choice_id not in CAMPAIGN_DECISION_OPTIONS.get(event_id, []) or phase_id.is_empty():
			return {"ok": false, "reason": "checkpoint occurrence history contains an unknown result"}
		history.append({"event_id": event_id, "choice_id": choice_id, "phase_id": phase_id})
	var raw_cooldowns: Variant = data.get("occurrence_cooldowns", {})
	if not raw_cooldowns is Dictionary:
		return {"ok": false, "reason": "checkpoint occurrence cooldowns are malformed"}
	var cooldowns: Dictionary = {}
	for event_id in raw_cooldowns:
		if String(event_id) not in OCCURRENCE_DEFS or int(raw_cooldowns[event_id]) < 0:
			return {"ok": false, "reason": "checkpoint occurrence cooldowns contain an invalid entry"}
		cooldowns[String(event_id)] = int(raw_cooldowns[event_id])
	var pending_is_occurrence := pending_event in OCCURRENCE_DEFS
	if pending_is_occurrence != not active_phase.is_empty():
		return {"ok": false, "reason": "active occurrence phase conflicts with the pending campaign event"}
	if pending_is_occurrence and active_phase not in phase_history:
		return {"ok": false, "reason": "active occurrence phase is missing from phase history"}
	return {"ok": true, "cursor": cursor, "active_phase": active_phase, "phase_history": phase_history, "history": history, "cooldowns": cooldowns}

func _serialize_module_array(source: Array) -> Array:
	var result: Array = []
	for instance in source:
		var encoded: Dictionary = instance.duplicate(true)
		var position: Vector2i = instance.get("position", Vector2i.ZERO)
		encoded["position"] = [position.x, position.y]
		result.append(encoded)
	return result

func _serialized_modules() -> Array:
	return _serialize_module_array(modules)

func _serialized_stored_modules() -> Array:
	return _serialize_module_array(stored_modules)

func _vector2i_from_value(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	if value is String:
		var cleaned := String(value).strip_edges().trim_prefix("(").trim_suffix(")")
		var parts := cleaned.split(",")
		if parts.size() >= 2:
			return Vector2i(int(parts[0].strip_edges()), int(parts[1].strip_edges()))
	return Vector2i.ZERO

func _deserialized_modules(value: Variant) -> Array:
	var result: Array = []
	if value is Array:
		for raw_instance in value:
			if raw_instance is Dictionary:
				var instance: Dictionary = raw_instance.duplicate(true)
				instance["position"] = _vector2i_from_value(instance.get("position", Vector2i.ZERO))
				result.append(instance)
	return result

func _validated_module_records(value: Variant, installed: bool, template_id: String = "road_keep") -> Dictionary:
	if not value is Array:
		return {"ok": false, "reason": "fortress module record is malformed"}
	var restored := _deserialized_modules(value)
	if restored.size() != value.size():
		return {"ok": false, "reason": "fortress module record contains a malformed entry"}
	var occupied: Dictionary = {}
	var exterior_count := 0
	var restored_mass := 0
	for instance in restored:
		var module_id := String(instance.get("id", ""))
		var definition := module_definition(module_id)
		if definition.is_empty():
			return {"ok": false, "reason": "fortress module record contains an unknown system"}
		var durability := int(instance.get("durability", definition.get("durability", 1)))
		if durability < 0 or durability > int(definition.get("durability", 1)):
			return {"ok": false, "reason": "fortress module record contains invalid durability"}
		if not installed:
			continue
		var exterior := bool(instance.get("exterior", false))
		var requires_exterior: bool = "exterior" in definition.get("tags", [])
		if exterior != requires_exterior:
			return {"ok": false, "reason": "fortress module record conflicts with mount requirements"}
		if exterior:
			exterior_count += 1
		restored_mass += int(definition.get("mass", 0))
		for cell in occupied_cells(instance):
			if cell.x < 0 or cell.x >= GRID_WIDTH or cell.y < 0 or cell.y >= GRID_HEIGHT:
				return {"ok": false, "reason": "fortress module record places a system outside the chassis"}
			if (template_id == "salt_skimmer" and cell in [Vector2i(0, 3), Vector2i(5, 3)]) or (template_id == "ridge_crawler" and cell in [Vector2i(0, 3), Vector2i(1, 3)]):
				return {"ok": false, "reason": "fortress module record overlaps a cut-away chassis cell"}
			if occupied.has(cell):
				return {"ok": false, "reason": "fortress module record contains overlapping systems"}
			occupied[cell] = true
	var exterior_limit := 3 if template_id == "salt_skimmer" else MAX_EXTERIOR_MOUNTS
	var mass_limit := 13 if template_id == "salt_skimmer" else (15 if template_id == "ridge_crawler" else BASE_MASS_LIMIT)
	if installed and exterior_count > exterior_limit:
		return {"ok": false, "reason": "fortress module record exceeds exterior mount capacity"}
	if installed and restored_mass > mass_limit:
		return {"ok": false, "reason": "fortress module record exceeds chassis mass capacity"}
	return {"ok": true, "modules": restored}

func _validated_encounter_records(value: Variant, installed_modules: Array, targets_may_be_historical: bool = false) -> Dictionary:
	if not value is Array:
		return {"ok": false, "reason": "encounter contact record is malformed"}
	var installed_ids: Dictionary = {}
	for instance in installed_modules:
		installed_ids[String(instance.get("id", ""))] = true
	var restored: Array = []
	var occupied_slots: Dictionary = {}
	for raw_enemy in value:
		if not raw_enemy is Dictionary:
			return {"ok": false, "reason": "encounter contact record contains a malformed entry"}
		var enemy: Dictionary = raw_enemy.duplicate(true)
		var enemy_id := String(enemy.get("id", ""))
		if enemy_id not in ENCOUNTER_ENEMIES:
			return {"ok": false, "reason": "encounter contact record contains an unknown threat"}
		var slot := int(enemy.get("slot", -1))
		if slot < 0 or occupied_slots.has(slot):
			return {"ok": false, "reason": "encounter contact record contains an invalid slot"}
		occupied_slots[slot] = true
		var maximum_health := int(enemy.get("max_hp", 0))
		var health := int(enemy.get("hp", 0))
		if maximum_health <= 0 or health < 0 or health > maximum_health:
			return {"ok": false, "reason": "encounter contact record contains invalid health"}
		if bool(enemy.get("defeated", false)) != (health == 0):
			return {"ok": false, "reason": "encounter contact record conflicts with threat health"}
		var target_id := String(enemy.get("target", ""))
		if not targets_may_be_historical and not target_id.is_empty() and target_id != "hull" and not installed_ids.has(target_id):
			return {"ok": false, "reason": "encounter contact record targets a missing system"}
		restored.append(enemy)
	return {"ok": true, "enemies": restored}

func load_serialized(data: Dictionary) -> Dictionary:
	var save_version := int(data.get("save_version", 1))
	if save_version > SAVE_VERSION:
		return {"ok": false, "reason": "save was created by a newer version"}
	if save_version < MIN_SUPPORTED_SAVE_VERSION:
		return {"ok": false, "reason": "save uses an unsupported older version"}
	if not data.has("modules"):
		return {"ok": false, "reason": "save is missing fortress modules"}
	var restored_chassis_template_id := String(data.get("chassis_template_id", "road_keep"))
	if restored_chassis_template_id not in VALID_CHASSIS_TEMPLATES:
		return {"ok": false, "reason": "checkpoint contains an unknown chassis template"}
	var restored_modules_result := _validated_module_records(data.get("modules", []), true, restored_chassis_template_id)
	if not bool(restored_modules_result.get("ok", false)):
		return restored_modules_result
	var restored_stored_modules_result := {"ok": true, "modules": []}
	if data.has("stored_modules"):
		restored_stored_modules_result = _validated_module_records(data.get("stored_modules", []), false, restored_chassis_template_id)
		if not bool(restored_stored_modules_result.get("ok", false)):
			return restored_stored_modules_result
	var targets_may_be_historical := not bool(data.get("encounter_active", encounter_active)) and float(data.get("encounter_progress", encounter_progress)) >= 1.0
	var restored_encounter_result := _validated_encounter_records(data.get("encounter_enemies", []), restored_modules_result.get("modules", []), targets_may_be_historical)
	if not bool(restored_encounter_result.get("ok", false)):
		return restored_encounter_result
	var restored_phase := String(data.get("phase", phase))
	var restored_final_result := String(data.get("final_result", final_result))
	var restored_run_complete := bool(data.get("run_complete", run_complete))
	var restored_journey_complete := bool(data.get("journey_complete", journey_complete))
	var restored_encounter_active := bool(data.get("encounter_active", encounter_active))
	var restored_encounter_step := int(data.get("encounter_step", encounter_step))
	var restored_encounter_progress := float(data.get("encounter_progress", encounter_progress))
	var restored_campaign_active := bool(data.get("campaign_active", campaign_active))
	var restored_campaign_region_id := String(data.get("campaign_region_id", "ashgate_lowlands"))
	var restored_campaign_pressure := int(data.get("campaign_pressure", campaign_pressure))
	var restored_campaign_retreats := int(data.get("campaign_retreats", campaign_retreats))
	var restored_current_location := String(data.get("current_location", current_location))
	var restored_journey_node := String(data.get("journey_node", journey_node))
	var restored_journey_destination := String(data.get("journey_destination", journey_destination))
	var restored_journey_route := String(data.get("journey_route", journey_route))
	var restored_campaign_target_node := String(data.get("campaign_target_node", campaign_target_node))
	var restored_campaign_last_safe_node := String(data.get("campaign_last_safe_node", campaign_last_safe_node))
	var restored_campaign_event_pending := String(data.get("campaign_event_pending", campaign_event_pending))
	var restored_specialist_id := String(data.get("specialist_id", specialist_id))
	var restored_mara_repaired_module_id := String(data.get("mara_repaired_module_id", ""))
	var restored_veyru_contract_status := String(data.get("veyru_contract_status", "unoffered"))
	var restored_veyru_medicine_carrier_id := String(data.get("veyru_medicine_carrier_id", ""))
	var restored_cinder_contract_status := String(data.get("cinder_contract_status", "unoffered"))
	var restored_salt_contract_status := String(data.get("salt_contract_status", "unoffered"))
	var restored_mastery_experiment_id := String(data.get("mastery_experiment_id", ""))
	var raw_regional_developments: Variant = data.get("regional_developments", [])
	var raw_acquired_intel_ids: Variant = data.get("acquired_intel_ids", [])
	var raw_purchased_market_offer_ids: Variant = data.get("purchased_market_offer_ids", [])
	var raw_campaign_path: Variant = data.get("campaign_path", [])
	if restored_campaign_region_id not in VALID_CAMPAIGN_REGIONS:
		return {"ok": false, "reason": "checkpoint contains an unknown campaign region"}
	if not restored_mastery_experiment_id.is_empty() and restored_mastery_experiment_id not in MASTERY_EXPERIMENTS:
		return {"ok": false, "reason": "checkpoint contains an unknown mastery experiment"}
	if not restored_mastery_experiment_id.is_empty() and restored_campaign_region_id != String(Dictionary(MASTERY_EXPERIMENTS[restored_mastery_experiment_id]).get("region_id", "")):
		return {"ok": false, "reason": "mastery experiment conflicts with the campaign region"}
	if not raw_regional_developments is Array or raw_regional_developments.size() > VALID_REGIONAL_DEVELOPMENTS.size():
		return {"ok": false, "reason": "checkpoint regional development list is malformed"}
	var restored_regional_developments: Array[String] = []
	for raw_id in raw_regional_developments:
		var development_id := String(raw_id)
		if development_id not in VALID_REGIONAL_DEVELOPMENTS:
			return {"ok": false, "reason": "checkpoint contains an unknown regional development"}
		if development_id in restored_regional_developments:
			return {"ok": false, "reason": "checkpoint contains a duplicate regional development"}
		restored_regional_developments.append(development_id)
	restored_regional_developments.sort()
	if not raw_acquired_intel_ids is Array or raw_acquired_intel_ids.size() > INTEL_OFFERS.size():
		return {"ok": false, "reason": "checkpoint acquired intel list is malformed"}
	var restored_acquired_intel_ids: Array[String] = []
	for raw_id in raw_acquired_intel_ids:
		var intel_id := String(raw_id)
		if intel_id not in INTEL_OFFERS:
			return {"ok": false, "reason": "checkpoint contains an unknown acquired intel record"}
		if intel_id in restored_acquired_intel_ids:
			return {"ok": false, "reason": "checkpoint contains a duplicate acquired intel record"}
		var intel_region := String(Dictionary(INTEL_OFFERS[intel_id]).get("region_id", ""))
		if intel_region != restored_campaign_region_id:
			return {"ok": false, "reason": "acquired intel conflicts with the campaign region"}
		restored_acquired_intel_ids.append(intel_id)
	restored_acquired_intel_ids.sort()
	if not raw_purchased_market_offer_ids is Array or raw_purchased_market_offer_ids.size() > MARKET_BUY_OFFERS.size():
		return {"ok": false, "reason": "checkpoint market purchase list is malformed"}
	var restored_market_offer_ids: Array[String] = []
	for raw_id in raw_purchased_market_offer_ids:
		var offer_id := String(raw_id)
		if offer_id not in MARKET_BUY_OFFERS:
			return {"ok": false, "reason": "checkpoint contains an unknown market purchase"}
		if offer_id in restored_market_offer_ids:
			return {"ok": false, "reason": "checkpoint contains a duplicate market purchase"}
		var offer_region := String(Dictionary(MARKET_BUY_OFFERS[offer_id]).get("region_id", ""))
		if offer_region != restored_campaign_region_id:
			return {"ok": false, "reason": "market purchase conflicts with the campaign region"}
		restored_market_offer_ids.append(offer_id)
	restored_market_offer_ids.sort()
	if restored_current_location not in JOURNEY_NODES or restored_journey_node not in JOURNEY_NODES:
		return {"ok": false, "reason": "checkpoint contains an unknown journey location"}
	if not restored_journey_destination.is_empty() and restored_journey_destination not in JOURNEY_NODES:
		return {"ok": false, "reason": "checkpoint contains an unknown journey destination"}
	if not restored_journey_route.is_empty() and restored_journey_route not in ROUTES and restored_journey_route not in CAMPAIGN_NODES:
		return {"ok": false, "reason": "checkpoint contains an unknown journey route"}
	if not restored_campaign_target_node.is_empty() and restored_campaign_target_node not in CAMPAIGN_NODES:
		return {"ok": false, "reason": "checkpoint contains an unknown campaign target"}
	if restored_campaign_last_safe_node not in CAMPAIGN_NODES:
		return {"ok": false, "reason": "checkpoint contains an unknown safe campaign node"}
	if not raw_campaign_path is Array:
		return {"ok": false, "reason": "campaign path record is malformed"}
	var restored_campaign_path := _string_array(raw_campaign_path)
	for node_id in restored_campaign_path:
		if node_id not in CAMPAIGN_NODES:
			return {"ok": false, "reason": "campaign path contains an unknown node"}
	if restored_campaign_active:
		var expected_start := "lantern_quay" if restored_campaign_region_id == "flooded_veyru" else ("blackkiln" if restored_campaign_region_id == "cinder_spine" else ("saltglass_haven" if restored_campaign_region_id == "white_salt_expanse" else "ashgate_depot"))
		if restored_campaign_path.is_empty() or restored_campaign_path[0] != expected_start:
			return {"ok": false, "reason": "campaign path does not begin at the region's starting settlement"}
		var restored_edges := VEYRU_EDGES if restored_campaign_region_id == "flooded_veyru" else (CINDER_EDGES if restored_campaign_region_id == "cinder_spine" else (SALT_EDGES if restored_campaign_region_id == "white_salt_expanse" else CAMPAIGN_EDGES))
		for index in range(1, restored_campaign_path.size()):
			if restored_campaign_path[index] not in restored_edges.get(restored_campaign_path[index - 1], []):
				return {"ok": false, "reason": "campaign path contains an impossible route"}
		if restored_campaign_region_id == "flooded_veyru":
			if restored_campaign_last_safe_node not in ["lantern_quay", "veyru_evacuation_camp"] or restored_campaign_last_safe_node not in restored_campaign_path:
				return {"ok": false, "reason": "safe campaign node conflicts with the secured path"}
		elif restored_campaign_region_id == "cinder_spine":
			if restored_campaign_last_safe_node not in ["blackkiln", "old_lift_station"] or restored_campaign_last_safe_node not in restored_campaign_path:
				return {"ok": false, "reason": "safe campaign node conflicts with the secured path"}
		elif restored_campaign_region_id == "white_salt_expanse":
			if restored_campaign_last_safe_node not in ["saltglass_haven", "windbreak"] or restored_campaign_last_safe_node not in restored_campaign_path:
				return {"ok": false, "reason": "safe campaign node conflicts with the secured path"}
		elif restored_campaign_last_safe_node != restored_campaign_path.back():
			return {"ok": false, "reason": "safe campaign node conflicts with the secured path"}
	var restored_decisions = data.get("campaign_decisions", {})
	if not restored_decisions is Dictionary:
		return {"ok": false, "reason": "campaign decision record is malformed"}
	for event_id in restored_decisions:
		if event_id not in CAMPAIGN_DECISION_OPTIONS or String(restored_decisions[event_id]) not in CAMPAIGN_DECISION_OPTIONS[event_id]:
			return {"ok": false, "reason": "campaign decision record contains an unknown choice"}
	if not restored_campaign_event_pending.is_empty() and restored_campaign_event_pending not in CAMPAIGN_DECISION_OPTIONS:
		return {"ok": false, "reason": "checkpoint contains an unknown active campaign event"}
	var restored_occurrence_state := _validated_occurrence_state(data, restored_campaign_event_pending)
	if not bool(restored_occurrence_state.get("ok", false)):
		return restored_occurrence_state
	if restored_specialist_id not in VALID_SPECIALIST_IDS:
		return {"ok": false, "reason": "checkpoint contains an unknown specialist"}
	if restored_veyru_contract_status not in VALID_CONTRACT_STATUSES:
		return {"ok": false, "reason": "checkpoint contains an unknown Veyru contract state"}
	if restored_cinder_contract_status not in VALID_CONTRACT_STATUSES:
		return {"ok": false, "reason": "checkpoint contains an unknown Cinder contract state"}
	if restored_salt_contract_status not in VALID_CONTRACT_STATUSES:
		return {"ok": false, "reason": "checkpoint contains an unknown Salt contract state"}
	if restored_campaign_region_id == "cinder_spine" and restored_cinder_contract_status == "unoffered":
		return {"ok": false, "reason": "Cinder campaign is missing its dynamo contract state"}
	if restored_campaign_region_id == "white_salt_expanse" and restored_salt_contract_status == "unoffered":
		return {"ok": false, "reason": "Salt campaign is missing its beacon contract state"}
	if not restored_veyru_medicine_carrier_id.is_empty() and restored_veyru_medicine_carrier_id not in ["refugee_bunk", "parts_crate"]:
		return {"ok": false, "reason": "checkpoint contains an invalid medicine carrier"}
	if restored_veyru_contract_status in ["accepted", "completed", "failed"] and restored_veyru_medicine_carrier_id.is_empty():
		return {"ok": false, "reason": "resolved Veyru medicine contract is missing its carrier record"}
	if restored_veyru_contract_status in ["unoffered", "offered", "declined"] and not restored_veyru_medicine_carrier_id.is_empty():
		return {"ok": false, "reason": "Veyru medicine carrier conflicts with contract state"}
	if restored_veyru_contract_status == "accepted":
		var carrier_present := false
		for instance in restored_modules_result.get("modules", []):
			if String(instance.get("id", "")) == restored_veyru_medicine_carrier_id:
				carrier_present = true
				break
		if not carrier_present:
			return {"ok": false, "reason": "Veyru medicine carrier is missing from the installed fortress"}
	if not restored_mara_repaired_module_id.is_empty() and restored_mara_repaired_module_id not in MODULE_DEFS:
		return {"ok": false, "reason": "checkpoint contains an unknown Mara repair target"}
	var mara_meeting_choice := String(restored_decisions.get("mara_meeting", ""))
	var mara_berth_choice := String(restored_decisions.get("mara_berth_choice", ""))
	var mara_workbench_choice := String(restored_decisions.get("mara_workbench_choice", ""))
	if restored_campaign_event_pending == "mara_berth_choice" and (restored_specialist_id != "iven_pell" or not mara_meeting_choice.is_empty()):
		return {"ok": false, "reason": "active specialist crossroads conflicts with the occupied berth"}
	if mara_berth_choice == "keep_iven" and (restored_specialist_id != "iven_pell" or mara_meeting_choice != "decline_mara"):
		return {"ok": false, "reason": "Iven retention conflicts with the specialist crossroads record"}
	if mara_berth_choice == "replace_iven_with_mara" and (restored_specialist_id != "mara_flint" or mara_meeting_choice != "recruit_mara"):
		return {"ok": false, "reason": "Mara reassignment conflicts with the specialist crossroads record"}
	if restored_specialist_id == "mara_flint" and mara_meeting_choice != "recruit_mara":
		return {"ok": false, "reason": "Mara specialist state conflicts with the meeting decision"}
	if mara_workbench_choice == "rebuild_weakest" and restored_mara_repaired_module_id.is_empty():
		return {"ok": false, "reason": "Mara repair decision is missing its system target"}
	if mara_workbench_choice != "rebuild_weakest" and not restored_mara_repaired_module_id.is_empty():
		return {"ok": false, "reason": "Mara repair target conflicts with the workbench decision"}
	if restored_campaign_event_pending == "mara_workbench_choice" and (restored_specialist_id != "mara_flint" or mara_meeting_choice != "recruit_mara"):
		return {"ok": false, "reason": "active Mara workbench event conflicts with recruitment state"}
	if restored_campaign_event_pending == "mara_followup" and (restored_specialist_id != "mara_flint" or mara_workbench_choice.is_empty()):
		return {"ok": false, "reason": "active Mara follow-up conflicts with workbench state"}
	if restored_phase not in VALID_PHASES:
		return {"ok": false, "reason": "checkpoint has an unknown campaign phase"}
	if restored_phase == "road_event":
		if restored_campaign_region_id != "ashgate_lowlands" or restored_campaign_event_pending != "salvage_choice" or restored_campaign_target_node != "soot_orchard" or restored_journey_destination != "soot_orchard" or restored_current_location == "soot_orchard":
			return {"ok": false, "reason": "road-event checkpoint conflicts with its pending arrival"}
		if restored_encounter_progress < 1.0:
			return {"ok": false, "reason": "road-event checkpoint contains an unresolved contact"}
	var restored_battle_phase := restored_phase in ["battle", "final_battle"]
	if restored_battle_phase != restored_encounter_active:
		return {"ok": false, "reason": "encounter state conflicts with the campaign phase"}
	if restored_encounter_step < 0 or restored_encounter_step > 6 or restored_encounter_progress < 0.0 or restored_encounter_progress > 1.0:
		return {"ok": false, "reason": "checkpoint contains invalid encounter progress"}
	if restored_encounter_active and restored_encounter_result.get("enemies", []).is_empty():
		return {"ok": false, "reason": "active encounter checkpoint has no threats"}
	if restored_phase == "results" and restored_final_result not in FINAL_RESULTS:
		return {"ok": false, "reason": "result checkpoint has no recognized outcome"}
	if restored_phase == "results" and (not restored_run_complete or not restored_journey_complete):
		return {"ok": false, "reason": "result checkpoint is missing completion state"}
	if restored_phase != "results" and (restored_run_complete or restored_journey_complete or restored_final_result in FINAL_RESULTS):
		return {"ok": false, "reason": "completion state conflicts with the active campaign phase"}
	seed = int(data.get("seed", seed))
	chassis_template_id = restored_chassis_template_id
	day = int(data.get("day", day))
	fuel = int(data.get("fuel", fuel))
	money = int(data.get("money", money))
	command_points = int(data.get("command_points", command_points))
	heat = int(data.get("heat", heat))
	hull_condition = int(data.get("hull_condition", hull_condition))
	current_location = restored_current_location
	route_risk_modifier = float(data.get("route_risk_modifier", route_risk_modifier))
	current_route_risk = float(data.get("current_route_risk", current_route_risk))
	encounter_pressure = int(data.get("encounter_pressure", encounter_pressure))
	pending_route_reward = int(data.get("pending_route_reward", pending_route_reward))
	target_doctrine = String(data.get("target_doctrine", target_doctrine))
	power_priority = String(data.get("power_priority", power_priority))
	heat_relief = int(data.get("heat_relief", heat_relief))
	heat_surge = int(data.get("heat_surge", heat_surge))
	vent_exposure = bool(data.get("vent_exposure", vent_exposure))
	journey_node = restored_journey_node
	journey_destination = restored_journey_destination
	journey_route = restored_journey_route
	journey_complete = restored_journey_complete
	encounter_active = restored_encounter_active
	encounter_step = restored_encounter_step
	encounter_progress = restored_encounter_progress
	encounter_enemies = restored_encounter_result.get("enemies", []).duplicate(true)
	encounter_report = _string_array(data.get("encounter_report", []))
	encounter_outcome = String(data.get("encounter_outcome", encounter_outcome))
	encounter_intervention_used = bool(data.get("encounter_intervention_used", encounter_intervention_used))
	encounter_target_doctrine = String(data.get("encounter_target_doctrine", encounter_target_doctrine))
	phase = restored_phase
	journey_leg = int(data.get("journey_leg", journey_leg))
	run_complete = restored_run_complete
	final_result = restored_final_result
	settlement_actions_remaining = int(data.get("settlement_actions_remaining", settlement_actions_remaining))
	settlement_report = _string_array(data.get("settlement_report", []))
	campaign_active = restored_campaign_active
	campaign_region_id = restored_campaign_region_id
	campaign_encounters_completed = int(data.get("campaign_encounters_completed", campaign_encounters_completed))
	campaign_path = restored_campaign_path
	campaign_target_node = restored_campaign_target_node
	campaign_last_safe_node = restored_campaign_last_safe_node
	campaign_pressure = restored_campaign_pressure
	campaign_retreats = restored_campaign_retreats
	campaign_event_pending = restored_campaign_event_pending
	campaign_decisions = restored_decisions.duplicate(true)
	occurrence_stream_cursor = int(restored_occurrence_state.get("cursor", 0))
	occurrence_active_phase = String(restored_occurrence_state.get("active_phase", ""))
	occurrence_phase_history = restored_occurrence_state.get("phase_history", []).duplicate()
	occurrence_history = restored_occurrence_state.get("history", []).duplicate(true)
	occurrence_cooldowns = restored_occurrence_state.get("cooldowns", {}).duplicate(true)
	guard_contract_status = String(data.get("guard_contract_status", guard_contract_status))
	veyru_contract_status = restored_veyru_contract_status
	veyru_medicine_carrier_id = restored_veyru_medicine_carrier_id
	cinder_contract_status = restored_cinder_contract_status
	salt_contract_status = restored_salt_contract_status
	settlement_trust = int(data.get("settlement_trust", settlement_trust))
	mobility_tendency = int(data.get("mobility_tendency", mobility_tendency))
	shelter_tendency = int(data.get("shelter_tendency", shelter_tendency))
	knowledge_tendency = int(data.get("knowledge_tendency", knowledge_tendency))
	industry_tendency = int(data.get("industry_tendency", 0))
	specialist_id = restored_specialist_id
	mara_repaired_module_id = restored_mara_repaired_module_id
	relay_repaired = bool(data.get("relay_repaired", relay_repaired))
	workers_rescued = bool(data.get("workers_rescued", workers_rescued))
	mastery_experiment_id = restored_mastery_experiment_id
	regional_developments = restored_regional_developments
	acquired_intel_ids = restored_acquired_intel_ids
	purchased_market_offer_ids = restored_market_offer_ids
	modules = restored_modules_result.get("modules", []).duplicate(true)
	stored_modules = restored_stored_modules_result.get("modules", []).duplicate(true)
	if not data.has("stored_modules"):
		seed_starter_inventory()
	log = _string_array(data.get("log", []))
	_recalculate()
	return {"ok": true, "save_version": save_version, "summary": summary()}

func begin_journey(route_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	if encounter_active:
		return {"ok": false, "reason": "an encounter is already active"}
	if phase != "refit" or current_location != "ashgate_depot":
		return {"ok": false, "reason": "the first route can only begin from Ashgate Depot"}
	var travel_result: Dictionary = travel(route_id, doctrine)
	if not bool(travel_result.get("ok", false)):
		return travel_result
	journey_route = route_id
	journey_node = "rill_crossing" if route_id == "safe_road" else "morrowline_camp"
	current_location = journey_node
	journey_leg = 1
	phase = "battle"
	command_points = 2
	encounter_target_doctrine = doctrine
	_configure_encounter(JOURNEY_ENCOUNTERS.get(route_id, ["road_raiders"]), String(ROUTES[route_id].name), "The fortress is between Ashgate Depot and Morrowline Camp.")
	return {"ok": true, "route": route_id, "forecast": encounter_forecast(), "encounter": encounter_summary(), "summary": summary()}

func _configure_encounter(composition: Array, route_name: String, location_text: String) -> void:
	encounter_active = true
	encounter_step = 0
	encounter_progress = 0.0
	encounter_outcome = ""
	encounter_intervention_used = false
	encounter_enemies.clear()
	encounter_report.clear()
	for index in range(composition.size()):
		var enemy_id: String = String(composition[index])
		var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
		var pressured_health := int(definition.health) + encounter_pressure
		encounter_enemies.append({"id": enemy_id, "hp": pressured_health, "max_hp": pressured_health, "target": "", "arrived": false, "defeated": false, "damage_taken": 0, "attacks": 0, "slot": index, "damage_bonus": 1 if encounter_pressure >= 2 else 0})
	_encounter_log("Forecast: %s from %s. Doctrine: %s." % [_encounter_names(), route_name, encounter_target_doctrine.replace("_", " ")])
	_encounter_log("Route: %s. %s" % [String(JOURNEY_NODES[journey_node].name), location_text])

func settlement_repair_preview(module_id: String) -> Dictionary:
	var target_index := _module_index_by_id(module_id)
	if target_index < 0:
		return {"available": false, "reason": "selected module was not found"}
	var maximum := int(module_definition(module_id).get("durability", 1))
	var current := int(modules[target_index].get("durability", 0))
	if current >= maximum:
		return {"available": false, "reason": "selected module is already fully repaired", "before": current, "after": current, "restored": 0, "cost": 0, "mara_bonus": 0}
	var missing := maximum - current
	var base_restored := mini(2, missing)
	var mara_bonus := mini(mara_repair_bonus(), missing - base_restored)
	var restored := base_restored + mara_bonus
	return {"available": true, "before": current, "after": current + restored, "restored": restored, "cost": base_restored * 4, "mara_bonus": mara_bonus}

func settlement_repair(module_id: String) -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "repairs are only available at a settlement"}
	if settlement_actions_remaining <= 0:
		return {"ok": false, "reason": "no settlement actions remain"}
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) != module_id:
			continue
		var preview := settlement_repair_preview(module_id)
		if not bool(preview.get("available", false)):
			return {"ok": false, "reason": String(preview.get("reason", "repair unavailable"))}
		var restored := int(preview.get("restored", 0))
		var cost := int(preview.get("cost", 0))
		if money < cost:
			return {"ok": false, "reason": "not enough Ashmarks"}
		money -= cost
		settlement_actions_remaining -= 1
		instance["durability"] = int(instance.get("durability", 0)) + restored
		modules[index] = instance
		_recalculate()
		var mara_text := " Mara Flint adds 1 durability without increasing the price." if int(preview.get("mara_bonus", 0)) > 0 else ""
		var settlement_name := String(JOURNEY_NODES.get(current_location, {}).get("name", "The settlement"))
		var message := "%s repaired %s by %d for %d Ashmarks.%s" % [settlement_name, module_definition(module_id).name, restored, cost, mara_text]
		settlement_report.append(message)
		log.append(message)
		return {"ok": true, "restored": restored, "cost": cost, "mara_bonus": int(preview.get("mara_bonus", 0)), "message": message, "summary": summary()}
	return {"ok": false, "reason": "selected module was not found"}

func settlement_refuel() -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "fuel is only available at a settlement"}
	if settlement_actions_remaining <= 0:
		return {"ok": false, "reason": "no settlement actions remain"}
	if campaign_region_id == "flooded_veyru":
		if current_location != "veyru_evacuation_camp":
			return {"ok": false, "reason": "emergency fuel is only available at Evacuation Camp"}
		if fuel >= 2:
			return {"ok": false, "reason": "free emergency fuel is reserved for fortresses below 2 fuel"}
		fuel += 1
		settlement_actions_remaining -= 1
		var emergency_message := "Evacuation Camp loaded 1 emergency fuel at no cost."
		settlement_report.append(emergency_message)
		log.append(emergency_message)
		return {"ok": true, "fuel_added": 1, "cost": 0, "message": emergency_message, "summary": summary()}
	if money < 8:
		return {"ok": false, "reason": "not enough Ashmarks"}
	money -= 8
	fuel += 2
	settlement_actions_remaining -= 1
	var settlement_name := String(JOURNEY_NODES.get(current_location, {}).get("name", "The settlement"))
	var message := "%s loaded 2 fuel for 8 Ashmarks." % settlement_name
	settlement_report.append(message)
	log.append(message)
	return {"ok": true, "fuel_added": 2, "cost": 8, "summary": summary()}

func settlement_repair_hull() -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "hull repair is only available at a settlement"}
	if settlement_actions_remaining <= 0:
		return {"ok": false, "reason": "no settlement actions remain"}
	if hull_condition >= 10:
		return {"ok": false, "reason": "hull is already fully repaired"}
	if money < 10:
		return {"ok": false, "reason": "not enough Ashmarks"}
	var hull_before := hull_condition
	money -= 10
	hull_condition = mini(10, hull_condition + 2)
	settlement_actions_remaining -= 1
	var hull_added := hull_condition - hull_before
	var settlement_name := String(JOURNEY_NODES.get(current_location, {}).get("name", "The settlement"))
	var message := "%s restored %d hull for 10 Ashmarks." % [settlement_name, hull_added]
	settlement_report.append(message)
	log.append(message)
	return {"ok": true, "hull_added": hull_added, "cost": 10, "summary": summary()}

func begin_final_journey(doctrine: String = "protect_crew") -> Dictionary:
	if phase != "settlement" or current_location != "morrowline_camp":
		return {"ok": false, "reason": "the final march begins from Morrowline Camp"}
	if not _has_engine():
		return {"ok": false, "reason": "no operational fuel-connected engine"}
	var mass_penalty := 1 if total_mass() > BASE_MASS_LIMIT - 2 else 0
	var fuel_cost := 2 + mass_penalty
	if fuel < fuel_cost:
		return {"ok": false, "reason": "not enough fuel for Meridian Pass"}
	fuel -= fuel_cost
	day += 2
	target_doctrine = doctrine
	encounter_target_doctrine = doctrine
	heat_relief = 0
	heat_surge = 2 if doctrine == "run_hot" else 0
	_recalculate()
	current_route_risk = 0.55 + (0.08 if heat > BASE_HEAT_LIMIT else 0.0)
	encounter_pressure = 1 + (1 if heat > BASE_HEAT_LIMIT else 0)
	pending_route_reward = 0
	command_points = 2
	power_priority = "balanced"
	journey_leg = 2
	journey_route = "meridian_pass"
	journey_node = "meridian_pass"
	journey_destination = "meridian_pass"
	current_location = "meridian_pass"
	phase = "final_battle"
	_configure_encounter(["siege_beast", "climbers"], "Meridian Pass", "The Siege Beast blocks the last open road.")
	return {"ok": true, "route": journey_route, "forecast": encounter_forecast(), "encounter": encounter_summary(), "summary": summary()}

func _encounter_names() -> String:
	var names: Array[String] = []
	for enemy in encounter_enemies:
		names.append(String(ENCOUNTER_ENEMIES[String(enemy.id)].name))
	return ", ".join(names)

func _encounter_log(message: String) -> void:
	encounter_report.append(message)
	log.append(message)

func _encounter_source_names(source_ids: Array) -> Array[String]:
	var names: Array[String] = []
	for raw_source_id in source_ids:
		var source_id := String(raw_source_id)
		var source_name := "Iven Pell" if source_id == "iven_pell" else String(module_definition(source_id).get("name", source_id.replace("_", " ").capitalize()))
		if source_name not in names:
			names.append(source_name)
	return names

func _encounter_target_name(target_id: String) -> String:
	if target_id == "hull":
		return "Hull"
	return String(module_definition(target_id).get("name", target_id.replace("_", " ").capitalize()))

func encounter_forecast() -> Dictionary:
	var threat_ids: Array[String] = []
	var threat_names: Array[String] = []
	for enemy in encounter_enemies:
		var enemy_id: String = String(enemy.get("id", ""))
		threat_ids.append(enemy_id)
		threat_names.append(String(ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id)))
	var exact_target: String = "cargo or exterior modules"
	if "climbers" in threat_ids:
		exact_target = "signal or exterior modules"
	elif "burrowers" in threat_ids:
		exact_target = "engine or workshop modules"
	elif "storm_front" in threat_ids:
		exact_target = "signal, exterior, or sustain systems"
	elif "ember_drakes" in threat_ids:
		exact_target = "fuel, exterior, or sustain systems"
	elif "lift_saboteurs" in threat_ids:
		exact_target = "generator, workshop, or signal systems"
	elif "elevator_warden" in threat_ids:
		exact_target = "generator, engine, or armor systems"
	elif "siege_beast" in threat_ids:
		exact_target = "front armor or crew modules"
	var signal_ready: bool = _has_ready_tag("forecast") or specialist_id == "iven_pell"
	var likely_target := ""
	if signal_ready and not threat_ids.is_empty():
		likely_target = _encounter_choose_target(threat_ids[0])
	return {"node": journey_node, "destination": journey_destination, "route": journey_route, "threat_ids": threat_ids, "threats": threat_names, "target_class": exact_target, "likely_target": likely_target, "exact_target_revealed": signal_ready, "signal_ready": signal_ready, "risk": current_route_risk, "pressure": encounter_pressure, "doctrine": encounter_target_doctrine}

func _has_operational_tag(tag: String) -> bool:
	for instance in modules:
		var definition: Dictionary = module_definition(String(instance.get("id", "")))
		if tag in definition.get("tags", []) and bool(dependency_status(instance).get("operational", false)):
			return true
	return false

func _has_ready_tag(tag: String) -> bool:
	for instance in modules:
		var definition: Dictionary = module_definition(String(instance.get("id", "")))
		var status := dependency_status(instance)
		if tag in definition.get("tags", []) and String(status.get("state", "offline")) == "ready":
			return true
	return false

func _encounter_module_damage(enemy_id: String, priority_override: String = "") -> Dictionary:
	var total_damage: int = 0
	var attackers: Array[String] = []
	var behavior_lines: Array[String] = []
	var active_priority := power_priority if priority_override.is_empty() else priority_override
	for instance in modules:
		var status := dependency_status(instance)
		if not bool(status.get("operational", false)):
			continue
		var module_id: String = String(instance.get("id", ""))
		var definition: Dictionary = module_definition(module_id)
		var damage: int = 0
		if enemy_id == "storm_front":
			var tags: Array = definition.get("tags", [])
			if "forecast" in tags or "long_range" in tags:
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("%s charts a stable line through the ash." % definition.name)
			elif "armor" in tags:
				damage = 1
				behavior_lines.append("%s keeps the storm from opening the chassis." % definition.name)
			elif "engine" in tags:
				damage = 1
				behavior_lines.append("%s holds the fortress against the weather line." % definition.name)
		elif enemy_id == "flood_surge":
			var tags: Array = definition.get("tags", [])
			if module_id == "water_condenser" and String(status.get("state", "strained")) == "ready":
				damage = 2
				behavior_lines.append("Water Condenser drains the pressure line before it reaches the lower deck.")
			elif "repair" in tags or "lower_hull" in tags:
				damage = 1
				behavior_lines.append("%s braces the flooded approach." % definition.name)
		elif enemy_id == "ember_drakes":
			var tags: Array = definition.get("tags", [])
			if module_id == "wall_lamp" or module_id == "water_condenser":
				damage = 2
				behavior_lines.append("%s breaks the ember flight before it reaches the fuel line." % definition.name)
			elif module_id == "repeater_gun":
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Repeater Gun scatters the ember flight.")
			elif module_id == "shell_cannon":
				damage = 1
				behavior_lines.append("Shell Cannon breaks the densest ember flight.")
			elif "armor" in tags:
				damage = 1
				behavior_lines.append("%s shields the exposed grade." % definition.name)
		elif enemy_id == "lift_saboteurs":
			var tags: Array = definition.get("tags", [])
			if module_id == "repeater_gun":
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Repeater Gun clears the industrial gantry.")
			elif module_id == "shell_cannon":
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Shell Cannon breaks the saboteurs' gantry access.")
			elif "repair" in tags or "forecast" in tags:
				damage = 1
				behavior_lines.append("%s detects and clears a sabotage route." % definition.name)
		elif enemy_id == "elevator_warden":
			var tags: Array = definition.get("tags", [])
			if module_id == "shell_cannon":
				damage = 3 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Shell Cannon strikes the Warden's counterweight.")
			elif "armor" in tags:
				damage = 1
				behavior_lines.append("%s holds the lift line steady." % definition.name)
		elif enemy_id == "salt_storm":
			var tags: Array = definition.get("tags", [])
			if module_id == "water_condenser":
				damage = 3 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Water Condenser harvests the salt storm before it strips the chassis.")
			elif "forecast" in tags:
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("%s holds a forecast line through the whiteout." % definition.name)
			elif "signal" in tags or "armor" in tags:
				damage = 1
				behavior_lines.append("%s holds a line through the whiteout." % definition.name)
		elif enemy_id == "rival_scouts":
			var tags: Array = definition.get("tags", [])
			if module_id == "repeater_gun":
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Repeater Gun clears the rival screen.")
			elif "forecast" in tags or "fast" in tags:
				damage = 1
				behavior_lines.append("%s denies the scouts an open flank." % definition.name)
		elif enemy_id == "rival_fortress":
			var tags: Array = definition.get("tags", [])
			if module_id == "shell_cannon":
				damage = 3 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Shell Cannon answers the rival fortress at equal range.")
			elif "armor" in tags or "forecast" in tags:
				damage = 1
				behavior_lines.append("%s preserves a redundant line under rival fire." % definition.name)
		elif enemy_id == "signal_hunters":
			var tags: Array = definition.get("tags", [])
			if module_id == "command_deck" or module_id == "repeater_gun":
				damage = 2 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("%s breaks the reflected approach." % definition.name)
			elif "armor" in tags:
				damage = 1
				behavior_lines.append("%s screens the beacon line." % definition.name)
		elif enemy_id == "bridgebreakers":
			var tags: Array = definition.get("tags", [])
			if module_id == "shell_cannon":
				damage = 3 if String(status.get("state", "strained")) == "ready" else 1
				behavior_lines.append("Shell Cannon breaks the demolition team before the span gives way.")
			elif module_id == "salvage_crane" or "lower_hull" in tags:
				damage = 2
				behavior_lines.append("%s braces the fractured salt crust." % definition.name)
		elif module_id == "shell_cannon":
			damage = 3 if enemy_id in ["road_raiders", "siege_beast"] else 1
			if String(status.get("state", "ready")) == "strained":
				damage = maxi(1, damage - 2)
				behavior_lines.append("Shell Cannon lacks an adjacent Ammunition Lift and fires emergency rounds.")
			behavior_lines.append("Shell Cannon fires a burst into the %s." % ENCOUNTER_ENEMIES[enemy_id].name)
		elif module_id == "repeater_gun":
			damage = 2 if enemy_id in ["road_raiders", "climbers"] else 1
			if String(status.get("state", "ready")) == "strained":
				damage = 1
				behavior_lines.append("Repeater Gun lacks an adjacent Ammunition Lift and fires short bursts.")
			behavior_lines.append("Repeater Gun suppresses the %s advance." % ENCOUNTER_ENEMIES[enemy_id].name)
		elif module_id == "wall_lamp" and enemy_id == "climbers":
			damage = 2
			behavior_lines.append("Wall Lamp exposes the climber’s route.")
		if damage > 0 and active_priority == "weapons" and "weapon" in definition.get("tags", []):
			damage += 1
			behavior_lines.append("Shift Power increases %s output." % definition.name)
		if damage > 0 and encounter_target_doctrine == "protect_cargo" and enemy_id == "road_raiders":
			damage += 1
			behavior_lines.append("Protect Cargo doctrine focuses fire on the raider approach.")
		elif damage > 0 and encounter_target_doctrine == "protect_crew" and enemy_id in ["climbers", "siege_beast"]:
			damage += 1
			behavior_lines.append("Protect Crew doctrine focuses fire on the threat to occupied rooms.")
		elif damage > 0 and encounter_target_doctrine == "run_hot":
			damage += 1
			behavior_lines.append("Run Hot doctrine trades thermal safety for weapon output.")
		if damage > 0:
			attackers.append(module_id)
			total_damage += damage
	if enemy_id == "storm_front" and specialist_id == "iven_pell":
		total_damage += 2
		attackers.append("iven_pell")
		behavior_lines.append("Iven Pell reads the relay drift and calls a path through the storm.")
	return {"damage": total_damage, "attackers": attackers, "lines": behavior_lines}

func _encounter_choose_target(enemy_id: String, excluded_module_id: String = "") -> String:
	var best_index: int = -1
	var best_score: int = -999
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) == excluded_module_id:
			continue
		if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
			continue
		var target_profile := encounter_target_rationale(enemy_id, instance)
		if not bool(target_profile.get("eligible", false)):
			continue
		var score := int(target_profile.get("score", -999))
		if score > best_score:
			best_index = index
			best_score = score
	if best_index >= 0:
		return String(modules[best_index].get("id", ""))
	return "hull"

func encounter_target_rationale(enemy_id: String, instance: Dictionary) -> Dictionary:
	var definition: Dictionary = ENCOUNTER_ENEMIES.get(enemy_id, {})
	var module_def := module_definition(String(instance.get("id", "")))
	if definition.is_empty() or module_def.is_empty() or int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
		return {"eligible": false, "score": -999, "reason": "target is unavailable"}
	var module_tags: Array = module_def.get("tags", [])
	var matched_tags: Array[String] = []
	var score := 0
	for raw_tag in definition.get("target_tags", []):
		var tag := String(raw_tag)
		if tag in module_tags:
			score += 10
			matched_tags.append(tag.replace("_", " "))
	if matched_tags.is_empty():
		return {"eligible": false, "score": -999, "reason": "outside this threat's target route"}
	var reasons: Array[String] = ["matches %s" % " / ".join(matched_tags)]
	var position: Vector2i = instance.get("position", Vector2i.ZERO)
	if enemy_id == "road_raiders":
		if "cargo" in module_tags:
			score += 6
			reasons.append("valuable cargo")
		if bool(instance.get("exterior", false)):
			score += 4
			reasons.append("exposed mount")
	elif enemy_id == "climbers":
		if bool(instance.get("exterior", false)):
			score += 6
			reasons.append("exposed mount")
		if position.y == 0:
			score += 3
			reasons.append("upper deck access")
	elif enemy_id == "burrowers":
		if position.y >= 2:
			score += 6
			reasons.append("lower-hull position")
		if "engine" in module_tags or "workshop" in module_tags:
			score += 4
			reasons.append("mobility or repair role")
	elif enemy_id == "flood_surge":
		if position.y >= 2:
			score += 6
			reasons.append("lower-deck exposure")
		if String(instance.get("id", "")) == veyru_medicine_carrier_id:
			score += 8
			reasons.append("sealed medicine carrier")
	elif enemy_id == "civic_guardian" and String(instance.get("id", "")) == veyru_medicine_carrier_id:
		score += 10
		reasons.append("archive-bound medicine carrier")
	elif enemy_id == "storm_front" and "sustain" in module_tags:
		score += 12
		reasons.append("dry-road sustain role" if journey_route == "dry_cistern_cut" else "journey sustain role")
	elif enemy_id == "siege_beast" and ("armor" in module_tags or "crew" in module_tags):
		score += 6
		reasons.append("frontline or occupied role")
	if encounter_target_doctrine == "protect_cargo" and "cargo" in module_tags:
		score -= 4
		reasons.append("priority reduced by Protect Cargo")
	elif encounter_target_doctrine == "protect_crew" and "crew" in module_tags:
		score -= 4
		reasons.append("priority reduced by Protect Crew")
	var damage_priority := maxi(0, 6 - int(instance.get("durability", 0)))
	score += damage_priority
	if damage_priority > 0:
		reasons.append("damaged condition")
	return {"eligible": true, "score": score, "reason": ", ".join(reasons)}

func _encounter_target_redirect_preview(target_module: String) -> Array[Dictionary]:
	var retargets: Array[Dictionary] = []
	for index in range(encounter_enemies.size()):
		var enemy: Dictionary = encounter_enemies[index]
		if bool(enemy.get("defeated", false)) or not bool(enemy.get("arrived", false)) or String(enemy.get("target", "")) != target_module:
			continue
		var enemy_id := String(enemy.get("id", ""))
		var replacement_target := _encounter_choose_target(enemy_id, target_module)
		var enemy_name := String(ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id.replace("_", " ").capitalize()))
		var replacement_name := "Hull" if replacement_target == "hull" else String(module_definition(replacement_target).get("name", replacement_target.replace("_", " ").capitalize()))
		retargets.append({"enemy_index": index, "enemy_id": enemy_id, "enemy_name": enemy_name, "previous_target": target_module, "target": replacement_target, "target_name": replacement_name})
	return retargets

func encounter_seal_preview(target_module: String) -> Dictionary:
	var target_index := _module_index_by_id(target_module)
	if target_index < 0:
		return {"valid": false, "reason": "target module not found", "retargets": []}
	if int(modules[target_index].get("durability", 0)) <= 0:
		return {"valid": false, "reason": "destroyed modules cannot be sealed", "retargets": []}
	if bool(modules[target_index].get("sealed", false)):
		return {"valid": false, "reason": "module is already sealed", "retargets": []}
	return {"valid": true, "target_module": target_module, "retargets": _encounter_target_redirect_preview(target_module)}

func encounter_cut_loose_preview() -> Dictionary:
	var target_module := sacrificable_cargo_id()
	if target_module.is_empty():
		return {"valid": false, "reason": "no cargo to cut loose", "retargets": []}
	return {"valid": true, "target_module": target_module, "retargets": _encounter_target_redirect_preview(target_module)}

func encounter_vent_heat_preview() -> Dictionary:
	var heat_after := maxi(0, total_heat() + heat_surge - (heat_relief + 3))
	var affected_hits: Array[Dictionary] = []
	for enemy in encounter_enemies:
		if bool(enemy.get("defeated", false)) or not bool(enemy.get("arrived", false)):
			continue
		var target_id := String(enemy.get("target", ""))
		var target_index := _module_index_by_id(target_id)
		if target_index < 0 or not bool(modules[target_index].get("exterior", false)):
			continue
		var impact := encounter_enemy_impact_preview(enemy)
		if impact.is_empty():
			continue
		var enemy_id := String(enemy.get("id", ""))
		affected_hits.append({
			"enemy_id": enemy_id,
			"enemy_name": String(ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id.replace("_", " ").capitalize())),
			"target": target_id,
			"target_name": String(module_definition(target_id).get("name", target_id.replace("_", " ").capitalize())),
			"damage_before": int(impact.get("damage", 0)),
			"damage_after": int(impact.get("damage", 0)) + (0 if vent_exposure else 1)
		})
	return {"heat_before": heat, "heat_after": heat_after, "heat_removed": maxi(0, heat - heat_after), "affected_hits": affected_hits}

func encounter_shift_power_preview() -> Dictionary:
	var next_priority := "weapons" if power_priority != "weapons" else "engines"
	var heat_change := 1 if next_priority == "weapons" else -1
	var heat_surge_after := maxi(0, heat_surge + heat_change)
	var heat_after := maxi(0, total_heat() + heat_surge_after - heat_relief)
	var affected_attacks: Array[Dictionary] = []
	for enemy in encounter_enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id := String(enemy.get("id", ""))
		var before := _encounter_module_damage(enemy_id)
		var after := _encounter_module_damage(enemy_id, next_priority)
		if int(before.get("damage", 0)) == int(after.get("damage", 0)):
			continue
		affected_attacks.append({
			"enemy_id": enemy_id,
			"enemy_name": String(ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id.replace("_", " ").capitalize())),
			"damage_before": int(before.get("damage", 0)),
			"damage_after": int(after.get("damage", 0))
		})
	return {"priority": next_priority, "heat_before": heat, "heat_after": heat_after, "heat_change": heat_after - heat, "affected_attacks": affected_attacks}

func _encounter_retarget_unavailable_module(target_module: String, cause: String) -> Array[Dictionary]:
	var retargets: Array[Dictionary] = []
	for index in range(encounter_enemies.size()):
		var enemy: Dictionary = encounter_enemies[index]
		if bool(enemy.get("defeated", false)) or not bool(enemy.get("arrived", false)) or String(enemy.get("target", "")) != target_module:
			continue
		var enemy_id := String(enemy.get("id", ""))
		var replacement_target := _encounter_choose_target(enemy_id)
		enemy["target"] = replacement_target
		encounter_enemies[index] = enemy
		var enemy_name := String(ENCOUNTER_ENEMIES.get(enemy_id, {}).get("name", enemy_id.replace("_", " ").capitalize()))
		var replacement_name := "Hull" if replacement_target == "hull" else String(module_definition(replacement_target).get("name", replacement_target.replace("_", " ").capitalize()))
		var change := {"enemy_id": enemy_id, "enemy_name": enemy_name, "previous_target": target_module, "target": replacement_target, "target_name": replacement_name}
		retargets.append(change)
		_encounter_log("%s redirects to %s after %s." % [enemy_name, replacement_name, cause])
	return retargets

func _module_index_by_id(module_id: String) -> int:
	for index in range(modules.size()):
		if String(modules[index].get("id", "")) == module_id:
			return index
	return -1

func _protecting_armor_index(target_index: int, enemy_id: String) -> int:
	if target_index < 0 or target_index >= modules.size():
		return -1
	var target: Dictionary = modules[target_index]
	for neighbor in adjacent_modules(target):
		var neighbor_index := int(neighbor.get("index", -1))
		var neighbor_definition := module_definition(String(neighbor.get("id", "")))
		var neighbor_tags: Array = neighbor_definition.get("tags", [])
		if "armor" not in neighbor_tags or not bool(dependency_status(neighbor).get("operational", false)):
			continue
		if enemy_id in ["burrowers", "flood_surge"] and "lower_hull" not in neighbor_tags:
			continue
		return neighbor_index
	return -1

func _dependency_states() -> Dictionary:
	var result := {}
	for instance in modules:
		result[String(instance.get("id", ""))] = String(dependency_status(instance).get("state", "offline"))
	return result

func _log_dependency_changes(before: Dictionary) -> void:
	for instance in modules:
		var module_id := String(instance.get("id", ""))
		var old_state := String(before.get(module_id, "offline"))
		var status := dependency_status(instance)
		var new_state := String(status.get("state", "offline"))
		if old_state == new_state:
			continue
		var reasons: Array = status.get("reasons", [])
		_encounter_log("Dependency change: %s is now %s%s." % [module_definition(module_id).name, new_state, " — " + String(reasons[0]) if not reasons.is_empty() else ""])

func _encounter_damage_profile(enemy_id: String, target_id: String, pressure_bonus: int = 0) -> Dictionary:
	var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
	var damage: int = int(definition.damage) + pressure_bonus
	var profile := {
		"damage": damage,
		"target_index": -1,
		"armor_index": -1,
		"armor_absorbed": 0,
		"doctrine_effect": "",
		"threat_effect": "",
		"mara_effect": "",
		"vent_exposed": false
	}
	if target_id == "hull":
		if encounter_target_doctrine == "run_hot" and heat > BASE_HEAT_LIMIT:
			damage += 1
			profile["doctrine_effect"] = "run_hot"
		profile["damage"] = damage
		return profile
	var target_index := _module_index_by_id(target_id)
	profile["target_index"] = target_index
	if target_index < 0:
		profile["damage"] = 0
		return profile
	var armor_index := _protecting_armor_index(target_index, enemy_id)
	if armor_index >= 0 and armor_index != target_index:
		var armor_id := String(modules[armor_index].get("id", ""))
		var armor_tags: Array = module_definition(armor_id).get("tags", [])
		var absorbed := 2 if enemy_id in ["burrowers", "flood_surge"] and "lower_hull" in armor_tags else 1
		absorbed = mini(absorbed, damage)
		damage = maxi(0, damage - absorbed)
		profile["armor_index"] = armor_index
		profile["armor_id"] = armor_id
		profile["armor_absorbed"] = absorbed
		profile["armor_current_durability"] = int(modules[armor_index].get("durability", 0))
		profile["armor_remaining_durability"] = maxi(0, int(modules[armor_index].get("durability", 0)) - absorbed)
	var instance: Dictionary = modules[target_index]
	var module_def: Dictionary = module_definition(target_id)
	var target_tags: Array = module_def.get("tags", [])
	if enemy_id == "storm_front" and "sustain" in target_tags:
		damage += 1
		profile["threat_effect"] = "sustain_exposure"
	if enemy_id == "flood_surge":
		if campaign_pressure >= 3 or total_mass() >= BASE_MASS_LIMIT:
			damage += 1
			profile["threat_effect"] = "flood_pressure"
		if journey_route == "pilgrim_gantry":
			damage = maxi(0, damage - 1)
			profile["route_effect"] = "high_gantry"
		if _has_ready_tag("water") and target_id != "water_condenser":
			damage = maxi(0, damage - 1)
			profile["water_effect"] = "condenser_buffer"
	if enemy_id == "civic_guardian" and target_id == veyru_medicine_carrier_id and String(campaign_decisions.get("archive_broadcast", "")) == "seal_archive":
		damage = maxi(0, damage - 1)
		profile["archive_effect"] = "sealed_approach"
	if enemy_id == "ember_drakes":
		if campaign_pressure >= 3 or heat > BASE_HEAT_LIMIT:
			damage += 1
			profile["threat_effect"] = "fireline_heat"
		if _has_ready_tag("water") and target_id != "water_condenser":
			damage = maxi(0, damage - 1)
			profile["water_effect"] = "condenser_buffer"
	if enemy_id == "lift_saboteurs" and campaign_pressure >= 5:
		damage += 1
		profile["threat_effect"] = "fireline_sabotage"
	if enemy_id == "elevator_warden" and String(campaign_decisions.get("lift_engine_choice", "")) == "cut_switchback":
		damage = maxi(0, damage - 1)
		profile["route_effect"] = "cut_switchback"
	if enemy_id == "salt_storm" and not _has_ready_tag("water"):
		damage += 1
		profile["threat_effect"] = "water_exposure"
	if enemy_id == "rival_fortress" and String(campaign_decisions.get("rival_terms", "")) == "race_rival":
		damage = maxi(0, damage - 1)
		profile["route_effect"] = "racing_line"
	if specialist_id == "nera_quill" and operational("infirmary") and ("crew" in target_tags or "refuge" in target_tags):
		damage = maxi(0, damage - 1)
		profile["specialist_effect"] = "nera_triage"
	if specialist_id == "sela_vonn" and operational("command_deck") and encounter_target_doctrine == "run_hot" and enemy_id in ["rival_scouts", "signal_hunters"]:
		damage = maxi(0, damage - 1)
		profile["specialist_effect"] = "sela_feint"
	if specialist_id == "tomas_reed" and operational("field_workshop") and enemy_id == "lift_saboteurs":
		damage = maxi(0, damage - 1)
		profile["specialist_effect"] = "tomas_rigging"
	if encounter_target_doctrine == "protect_cargo" and "cargo" in target_tags:
		damage = maxi(0, damage - 1)
		profile["doctrine_effect"] = "protect_cargo"
	elif encounter_target_doctrine == "protect_crew" and "crew" in target_tags:
		damage = maxi(0, damage - 1)
		profile["doctrine_effect"] = "protect_crew"
	elif encounter_target_doctrine == "run_hot" and heat > BASE_HEAT_LIMIT:
		damage += 1
		profile["doctrine_effect"] = "run_hot"
	if target_id == "refugee_bunk" and mara_refuge_bracing_active():
		damage = maxi(0, damage - 1)
		profile["mara_effect"] = "refuge_bracing"
	if vent_exposure and bool(instance.get("exterior", false)):
		damage += 1
		profile["vent_exposed"] = true
	if target_id == "front_armor_plate" and enemy_id == "siege_beast":
		damage = maxi(1, damage - 1)
		profile["front_armor_effect"] = "braced_plate"
	profile["damage"] = damage
	return profile

func encounter_enemy_impact_preview(enemy: Dictionary) -> Dictionary:
	if bool(enemy.get("defeated", false)) or not bool(enemy.get("arrived", false)):
		return {}
	var target_id := String(enemy.get("target", ""))
	if target_id.is_empty():
		return {}
	var profile := _encounter_damage_profile(String(enemy.get("id", "")), target_id, int(enemy.get("damage_bonus", 0)))
	var current_durability := hull_condition
	if target_id != "hull":
		var target_index := int(profile.get("target_index", -1))
		if target_index < 0:
			return {}
		current_durability = int(modules[target_index].get("durability", 0))
	profile["target"] = target_id
	profile["target_reason"] = "No eligible preferred system remains; the hull is exposed." if target_id == "hull" else String(encounter_target_rationale(String(enemy.get("id", "")), modules[int(profile.get("target_index", -1))]).get("reason", "target route matched"))
	profile["current_durability"] = current_durability
	profile["remaining_durability"] = maxi(0, current_durability - int(profile.get("damage", 0)))
	profile["dependency_changes"] = _encounter_dependency_impact_preview(profile)
	return profile

func encounter_defense_preview(enemy: Dictionary) -> Dictionary:
	if bool(enemy.get("defeated", false)):
		return {}
	var enemy_id := String(enemy.get("id", ""))
	if not ENCOUNTER_ENEMIES.has(enemy_id):
		return {}
	var attack := _encounter_module_damage(enemy_id)
	var source_names: Array[String] = _encounter_source_names(Array(attack.get("attackers", [])))
	var impact := encounter_enemy_impact_preview(enemy)
	var armor_name := ""
	var armor_id := String(impact.get("armor_id", ""))
	if not armor_id.is_empty():
		armor_name = String(module_definition(armor_id).get("name", armor_id.replace("_", " ").capitalize()))
	var direct_buffer := 1 if String(impact.get("front_armor_effect", "")) == "braced_plate" else 0
	var buffer_source := "Front Armor Plate" if direct_buffer > 0 else armor_name
	return {
		"damage": int(attack.get("damage", 0)),
		"sources": source_names,
		"impact_buffer": int(impact.get("armor_absorbed", 0)) + direct_buffer,
		"buffer_source": buffer_source
	}

func _encounter_dependency_impact_preview(profile: Dictionary) -> Array[Dictionary]:
	var affected_indices: Array[int] = []
	var target_index := int(profile.get("target_index", -1))
	if target_index >= 0 and int(profile.get("remaining_durability", 1)) <= 0:
		affected_indices.append(target_index)
	var armor_index := int(profile.get("armor_index", -1))
	if armor_index >= 0 and armor_index != target_index and int(profile.get("armor_remaining_durability", 1)) <= 0:
		affected_indices.append(armor_index)
	if affected_indices.is_empty():
		return []

	var before_states: Array[String] = []
	for instance in modules:
		before_states.append(String(dependency_status(instance).get("state", "offline")))
	var original_durabilities := {}
	for index in affected_indices:
		original_durabilities[index] = int(modules[index].get("durability", 0))
		modules[index]["durability"] = 0

	var changes: Array[Dictionary] = []
	for index in range(modules.size()):
		if index in affected_indices:
			continue
		var status := dependency_status(modules[index])
		var after_state := String(status.get("state", "offline"))
		if before_states[index] == after_state:
			continue
		var module_id := String(modules[index].get("id", ""))
		var reasons: Array = status.get("reasons", [])
		changes.append({
			"module_id": module_id,
			"name": String(module_definition(module_id).get("name", module_id)),
			"from": before_states[index],
			"to": after_state,
			"reason": String(reasons[0]) if not reasons.is_empty() else "dependency lost"
		})

	for index in affected_indices:
		modules[index]["durability"] = int(original_durabilities[index])
	return changes

func _encounter_apply_enemy_damage(enemy_id: String, target_id: String, pressure_bonus: int = 0) -> int:
	var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
	var profile := _encounter_damage_profile(enemy_id, target_id, pressure_bonus)
	var damage: int = int(profile.get("damage", 0))
	if target_id == "hull":
		hull_condition = maxi(0, hull_condition - damage)
		_encounter_log("%s reaches the hull for %d damage; no matching module remains." % [definition.name, damage])
		return damage
	var target_index := int(profile.get("target_index", -1))
	if target_index < 0:
		return 0
	var dependency_before := _dependency_states()
	var armor_index := int(profile.get("armor_index", -1))
	if armor_index >= 0 and armor_index != target_index:
		var armor: Dictionary = modules[armor_index]
		var absorbed := int(profile.get("armor_absorbed", 0))
		armor["durability"] = maxi(0, int(armor.get("durability", 0)) - absorbed)
		modules[armor_index] = armor
		_encounter_log("%s absorbs %d damage intended for %s." % [module_definition(String(armor.get("id", ""))).name, absorbed, module_definition(target_id).name])
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) != target_id:
			continue
		var module_def: Dictionary = module_definition(target_id)
		var doctrine_effect := String(profile.get("doctrine_effect", ""))
		if doctrine_effect == "protect_cargo":
			_encounter_log("Protect Cargo doctrine reduces the impact on %s." % module_def.name)
		elif doctrine_effect == "protect_crew":
			_encounter_log("Protect Crew doctrine reduces the impact on %s." % module_def.name)
		elif doctrine_effect == "run_hot":
			_encounter_log("Run Hot instability increases the impact on %s." % module_def.name)
		if String(profile.get("threat_effect", "")) == "sustain_exposure":
			_encounter_log("Dry-system exposure adds 1 Storm Front damage to %s." % module_def.name)
		elif String(profile.get("threat_effect", "")) == "flood_pressure":
			_encounter_log("Flooding water or maximum mass adds 1 Flood Surge damage to %s." % module_def.name)
		elif String(profile.get("threat_effect", "")) == "fireline_heat":
			_encounter_log("Advancing fire or unsafe heat adds 1 Ember Drake damage to %s." % module_def.name)
		elif String(profile.get("threat_effect", "")) == "fireline_sabotage":
			_encounter_log("Inferno conditions add 1 Lift Saboteur damage to %s." % module_def.name)
		elif String(profile.get("threat_effect", "")) == "water_exposure":
			_encounter_log("No Ready Water Condenser adds 1 Salt Storm damage to %s." % module_def.name)
		if String(profile.get("water_effect", "")) == "condenser_buffer":
			_encounter_log("The Ready Water Condenser removes 1 Flood Surge damage from %s." % module_def.name)
		if String(profile.get("route_effect", "")) == "high_gantry":
			_encounter_log("Pilgrim Gantry's high deck removes 1 Flood Surge damage from %s." % module_def.name)
		elif String(profile.get("route_effect", "")) == "cut_switchback":
			_encounter_log("The cut switchback removes 1 Elevator Warden damage from %s." % module_def.name)
		elif String(profile.get("route_effect", "")) == "racing_line":
			_encounter_log("The racing line removes 1 Rival Fortress damage from %s." % module_def.name)
		if String(profile.get("archive_effect", "")) == "sealed_approach":
			_encounter_log("The sealed archive approach removes 1 Civic Guardian damage from %s." % module_def.name)
		if String(profile.get("specialist_effect", "")) == "nera_triage":
			_encounter_log("Dr. Nera Quill's staffed infirmary removes 1 damage from %s." % module_def.name)
		elif String(profile.get("specialist_effect", "")) == "sela_feint":
			_encounter_log("Sela Vonn's command feint removes 1 damage from %s." % module_def.name)
		elif String(profile.get("specialist_effect", "")) == "tomas_rigging":
			_encounter_log("Tomas Reed's workshop rigging removes 1 Lift Saboteur damage from %s." % module_def.name)
		if String(profile.get("mara_effect", "")) == "refuge_bracing":
			_encounter_log("Mara Flint's forge-core bracing absorbs 1 damage intended for Refugee Bunk.")
		if bool(profile.get("vent_exposed", false)):
			vent_exposure = false
			_encounter_log("Open heat vents expose %s to one additional damage." % module_def.name)
		instance["durability"] = maxi(0, int(instance.get("durability", 0)) - damage)
		modules[index] = instance
		_encounter_log("%s hits %s for %d; durability is %d." % [definition.name, module_def.name, damage, int(instance.durability)])
		_recalculate()
		_log_dependency_changes(dependency_before)
		_refresh_veyru_contract_state()
		return damage
	return 0

func _encounter_repair() -> void:
	if not _has_operational_tag("repair"):
		return
	var weakest_id: String = ""
	var weakest_durability: int = 999
	for instance in modules:
		if int(instance.get("durability", 0)) <= 0:
			continue
		var module_id: String = String(instance.get("id", ""))
		var maximum: int = int(module_definition(module_id).get("durability", 1))
		var current: int = int(instance.get("durability", 0))
		if current < maximum and current < weakest_durability:
			weakest_id = module_id
			weakest_durability = current
	if not weakest_id.is_empty():
		var repair_amount := _workshop_repair_amount()
		var result: Dictionary = repair_module(weakest_id, repair_amount)
		if bool(result.get("ok", false)):
			var repair_sources: Array[String] = []
			for instance in modules:
				var definition := module_definition(String(instance.get("id", "")))
				if "repair" in definition.get("tags", []) and bool(dependency_status(instance).get("operational", false)) and _has_adjacent_tag(instance, "parts"):
					repair_sources.append("connected parts")
					break
			if mara_repair_bonus() > 0:
				repair_sources.append("Mara Flint")
			var source_text := " with %s" % " and ".join(repair_sources) if not repair_sources.is_empty() else ""
			_encounter_log("Field Workshop restores %s by %d durability%s." % [module_definition(weakest_id).name, repair_amount, source_text])

func _workshop_repair_amount() -> int:
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if "repair" in definition.get("tags", []) and bool(dependency_status(instance).get("operational", false)):
			return (2 if _has_adjacent_tag(instance, "parts") else 1) + mara_repair_bonus()
	return 0

func _campaign_event_for_node(node_id: String) -> String:
	if campaign_region_id == "flooded_veyru":
		match node_id:
			"pump_gallery":
				return "drain_pumps"
			"drowned_registry":
				return "registry_salvage"
			"dry_archive_gate":
				return "archive_broadcast"
		return ""
	if campaign_region_id == "white_salt_expanse":
		match node_id:
			"buried_observatory":
				return "observatory_signal"
			"rival_approach":
				return "rival_terms"
			"lee_trench":
				return "trench_cistern"
		return ""
	if campaign_region_id == "cinder_spine":
		match node_id:
			"charcoal_monastery":
				return "charcoal_vow"
			"lift_engine_house":
				return "lift_engine_choice"
			"ash_chapel_bypass":
				return "chapel_refuge"
		return ""
	if node_id in ["lower_ash_road", "dry_cistern_cut", "signal_causeway", "cinder_quarry"] and specialist_id == "mara_flint" and campaign_decisions.has("mara_workbench_choice") and not campaign_decisions.has("mara_followup"):
		return "mara_followup"
	match node_id:
		"soot_orchard":
			return "" if campaign_decisions.has("salvage_choice") else "salvage_choice"
		"broken_relay":
			return "lost_signal"
		"red_wheel_toll_bridge":
			return "toll_decision"
	var phase_id := "road_arrival_%d_%s" % [campaign_encounters_completed, node_id]
	return String(try_schedule_occurrence("road_arrival", node_id, phase_id).get("event_id", ""))

func _campaign_restore_limping_engine() -> Array[String]:
	var repairs: Array[String] = []
	for index in range(modules.size()):
		var module_id := String(modules[index].get("id", ""))
		var definition := module_definition(module_id)
		var tags: Array = definition.get("tags", [])
		if "engine" not in tags and "fuel" not in tags:
			continue
		var durability_before := int(modules[index].get("durability", 0))
		var durability_after := maxi(1, durability_before)
		modules[index]["durability"] = durability_after
		if durability_after > durability_before:
			repairs.append("%s %d→%d" % [String(definition.get("name", module_id)), durability_before, durability_after])
	return repairs

func _apply_cinder_quarry_recovery() -> Dictionary:
	var weakest_id := _weakest_damaged_module_id()
	if weakest_id.is_empty():
		money += 8
		_encounter_log("Cinder Quarry recovery: no damaged system needs platework; spare plate sells for 8 Ashmarks.")
		return {"kind": "ashmarks", "amount": 8}
	var result := _change_module_durability(weakest_id, 2)
	var module_name := String(module_definition(weakest_id).get("name", weakest_id))
	var restored := int(result.get("after", 0)) - int(result.get("before", 0))
	_encounter_log("Cinder Quarry recovery: plate crews restore %s by %d durability (%d→%d)." % [module_name, restored, int(result.get("before", 0)), int(result.get("after", 0))])
	return {"kind": "repair", "module_id": weakest_id, "amount": restored, "before": int(result.get("before", 0)), "after": int(result.get("after", 0))}

func _campaign_recover_from_failure() -> Dictionary:
	var day_before := day
	var money_before := money
	var pressure_before := campaign_pressure
	var fuel_before := fuel
	var hull_before := hull_condition
	encounter_outcome = "forced_retreat"
	campaign_retreats += 1
	campaign_pressure += 2
	day += 1
	money = maxi(0, money - 10)
	fuel = maxi(2, fuel)
	hull_condition = maxi(3, hull_condition)
	var system_repairs := _campaign_restore_limping_engine()
	command_points = 2
	power_priority = "balanced"
	heat_surge = 0
	heat_relief = 0
	pending_route_reward = 0
	campaign_target_node = ""
	journey_node = campaign_last_safe_node
	current_location = campaign_last_safe_node
	journey_destination = ""
	phase = "settlement" if campaign_last_safe_node in ["morrowline_camp", "veyru_evacuation_camp", "old_lift_station", "windbreak"] else ("refit" if campaign_last_safe_node in ["ashgate_depot", "lantern_quay", "blackkiln", "saltglass_haven"] else "map")
	if phase == "settlement":
		settlement_actions_remaining = maxi(1, settlement_actions_remaining)
	_recalculate()
	_refresh_veyru_contract_state()
	var retreat_receipt := {
		"day_added": day - day_before,
		"ashmarks_lost": money_before - money,
		"pressure_added": campaign_pressure - pressure_before,
		"fuel_before": fuel_before,
		"fuel_after": fuel,
		"hull_before": hull_before,
		"hull_after": hull_condition,
		"system_repairs": system_repairs.duplicate()
	}
	var repair_text := ", ".join(system_repairs) if not system_repairs.is_empty() else "no disabled engine or fuel module"
	_encounter_log("Outcome: forced retreat to %s · day +%d · Ashmarks -%d · pressure +%d · hull %d→%d · fuel %d→%d. Crew repair: %s." % [
		String(JOURNEY_NODES.get(campaign_last_safe_node, {}).get("name", campaign_last_safe_node)),
		int(retreat_receipt.day_added),
		int(retreat_receipt.ashmarks_lost),
		int(retreat_receipt.pressure_added),
		int(retreat_receipt.hull_before),
		int(retreat_receipt.hull_after),
		int(retreat_receipt.fuel_before),
		int(retreat_receipt.fuel_after),
		repair_text
	])
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "recovered_to": campaign_last_safe_node, "retreat": retreat_receipt, "report": encounter_report.duplicate(), "summary": summary()}

func _finish_campaign_encounter(engine_alive: bool) -> Dictionary:
	if campaign_region_id == "flooded_veyru":
		return _finish_veyru_encounter(engine_alive)
	if campaign_region_id == "cinder_spine":
		return _finish_cinder_encounter(engine_alive)
	if campaign_region_id == "white_salt_expanse":
		return _finish_salt_encounter(engine_alive)
	var arrived_node := campaign_target_node
	if hull_condition <= 0 or not engine_alive:
		if arrived_node == "meridian_pass":
			encounter_outcome = "march_failed"
			final_result = "march_failed"
			run_complete = true
			journey_complete = true
			phase = "results"
			_encounter_log("Outcome: the campaign ends at Meridian Pass. The final report preserves the dependency chain that stopped the fortress.")
			_clear_temporary_seals()
			return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}
		return _campaign_recover_from_failure()
	if arrived_node == "soot_orchard" and not campaign_decisions.has("salvage_choice"):
		phase = "road_event"
		campaign_event_pending = "salvage_choice"
		encounter_outcome = "road_interruption"
		_encounter_log("Contact cleared at The Soot Orchard. The fortress holds before the firebreak; choose between the fuel cache and stranded workers before arrival.")
		_clear_temporary_seals()
		return {"ok": true, "resolved": true, "outcome": encounter_outcome, "arrival_pending": true, "event": campaign_event_pending, "report": encounter_report.duplicate(), "summary": summary()}
	return _complete_campaign_arrival(arrived_node)

func _complete_campaign_arrival(arrived_node: String) -> Dictionary:
	campaign_encounters_completed += 1
	current_location = arrived_node
	journey_node = arrived_node
	if arrived_node not in campaign_path:
		campaign_path.append(arrived_node)
	campaign_last_safe_node = arrived_node
	money += pending_route_reward
	pending_route_reward = 0
	command_points = 2
	power_priority = "balanced"
	heat_surge = 0
	heat_relief = 0
	_recalculate()
	if arrived_node == "cinder_quarry":
		_apply_cinder_quarry_recovery()
	if arrived_node == "morrowline_camp":
		phase = "settlement"
		settlement_report.clear()
		if guard_contract_status == "accepted":
			guard_contract_status = "completed"
			money += 30
			settlement_trust += 2
			_encounter_log("Contract complete: the Morrowline parts convoy arrives under guard. Payment is 30 Ashmarks and settlement trust rises by 2.")
		settlement_actions_remaining = morrowline_service_capacity()
		if settlement_actions_remaining == 1:
			_encounter_log("Parts shortage: without the guarded convoy, Morrowline can support only 1 service action before departure.")
		if workers_rescued:
			settlement_trust += 1
			_encounter_log("The rescued orchard workers reach Morrowline and add one settlement trust.")
		if specialist_id == "iven_pell" and not campaign_decisions.has("mara_berth_choice"):
			campaign_event_pending = "mara_berth_choice"
			_encounter_log("Mara Flint offers Iven Pell a place with Morrowline's relay crews. The fortress must choose which specialist carries the next road.")
		elif specialist_id.is_empty() and not campaign_decisions.has("mara_meeting"):
			campaign_event_pending = "mara_meeting"
			_encounter_log("Mara Flint waits beside an open forge bench. Her offer must be answered before the fortress departs.")
		elif campaign_event_pending.is_empty():
			var phase_id := "settlement_arrival_%d_morrowline_camp" % campaign_encounters_completed
			try_schedule_occurrence("settlement_arrival", arrived_node, phase_id)
		encounter_outcome = "protected_arrival" if hull_condition >= 7 else "damaged_arrival"
		var service_text := "Two service actions" if settlement_actions_remaining == 2 else "One service action"
		_encounter_log("Outcome: %s at Morrowline Camp. %s and a full refit window are available%s." % [encounter_outcome.replace("_", " "), service_text, " after the current decision is resolved" if not campaign_event_pending.is_empty() else ""])
	elif arrived_node == "meridian_pass":
		journey_complete = true
		run_complete = true
		phase = "results"
		if _all_encounter_enemies_defeated() and hull_condition >= 7 and guard_contract_status != "failed":
			encounter_outcome = "decisive_march"
			final_result = "decisive_march"
		else:
			encounter_outcome = "scarred_march"
			final_result = "scarred_march"
		_encounter_log("Outcome: %s after five campaign encounters. Contract, crew, trust, pressure, and surviving systems are preserved in the result." % final_result.replace("_", " "))
	else:
		phase = "map"
		campaign_event_pending = _campaign_event_for_node(arrived_node)
		encounter_outcome = "route_secured"
		_encounter_log("Outcome: %s is secured. Choose the next available route%s." % [String(JOURNEY_NODES.get(arrived_node, {}).get("name", arrived_node)), " after resolving the local decision" if not campaign_event_pending.is_empty() else ""])
	campaign_target_node = ""
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

func _finish_veyru_encounter(engine_alive: bool) -> Dictionary:
	var arrived_node := campaign_target_node
	if arrived_node == "sunken_tramworks" and total_mass() > BASE_MASS_LIMIT - 2:
		hull_condition = maxi(0, hull_condition - 1)
		_encounter_log("The heavy fortress drags through the submerged tram bed for 1 hull damage.")
	_refresh_veyru_contract_state()
	if hull_condition <= 0 or not engine_alive:
		if arrived_node == "dry_archive":
			encounter_outcome = "veyru_lost"
			final_result = "veyru_lost"
			run_complete = true
			journey_complete = true
			phase = "results"
			_encounter_log("Outcome: Veyru is lost at the Dry Archive. The final report preserves the failure chain and archive commitment.")
			_clear_temporary_seals()
			return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}
		return _campaign_recover_from_failure()

	campaign_encounters_completed += 1
	current_location = arrived_node
	journey_node = arrived_node
	if arrived_node not in campaign_path:
		campaign_path.append(arrived_node)
	if arrived_node == "veyru_evacuation_camp":
		campaign_last_safe_node = arrived_node
	money += pending_route_reward
	pending_route_reward = 0
	command_points = 2
	power_priority = "balanced"
	heat_surge = 0
	heat_relief = 0
	_recalculate()

	if arrived_node == "veyru_evacuation_camp":
		phase = "settlement"
		settlement_actions_remaining = 2 if veyru_contract_carrier_operational() else 1
		settlement_report.clear()
		encounter_outcome = "protected_arrival" if hull_condition >= 7 else "damaged_arrival"
		var action_text := "Two service actions are" if settlement_actions_remaining == 2 else "One service action is"
		_encounter_log("Outcome: %s at Evacuation Camp. %s available with a full refit window." % [encounter_outcome.replace("_", " "), action_text])
	elif arrived_node == "dry_archive":
		journey_complete = true
		run_complete = true
		phase = "results"
		var carrier_delivered := veyru_contract_carrier_operational()
		if carrier_delivered:
			veyru_contract_status = "completed"
			money += 28
			settlement_trust += 2
			_encounter_log("Medicine contract complete: the sealed cases reach the Dry Archive. Payment is 28 Ashmarks and trust rises by 2.")
		if carrier_delivered and hull_condition >= 6:
			encounter_outcome = "archive_kept"
			final_result = "archive_kept"
		else:
			encounter_outcome = "archive_scarred"
			final_result = "archive_scarred"
		_encounter_log("Outcome: %s after five Veyru encounters. Water, medicine, archive commitment, and surviving systems remain in the result." % final_result.replace("_", " "))
	else:
		phase = "map"
		campaign_event_pending = _campaign_event_for_node(arrived_node)
		encounter_outcome = "route_secured"
		_encounter_log("Outcome: %s is secured. Choose the next available route%s." % [String(JOURNEY_NODES.get(arrived_node, {}).get("name", arrived_node)), " after resolving the local decision" if not campaign_event_pending.is_empty() else ""])
	campaign_target_node = ""
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

func _finish_cinder_encounter(engine_alive: bool) -> Dictionary:
	var arrived_node := campaign_target_node
	if arrived_node == "red_cut" and total_mass() > BASE_MASS_LIMIT - 2:
		hull_condition = maxi(0, hull_condition - 1)
		_encounter_log("The heavy fortress loses 1 hull dragging across Red Cut's steep grade.")
	if hull_condition <= 0 or not engine_alive:
		if arrived_node == "switchback_commune":
			encounter_outcome = "cinder_lost"
			final_result = "cinder_lost"
			run_complete = true
			journey_complete = true
			phase = "results"
			_encounter_log("Outcome: the Cinder march fails below Switchback Commune. The final report preserves the heat, grade, and dependency chain.")
			_clear_temporary_seals()
			return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}
		return _campaign_recover_from_failure()
	campaign_encounters_completed += 1
	current_location = arrived_node
	journey_node = arrived_node
	if arrived_node not in campaign_path:
		campaign_path.append(arrived_node)
	if arrived_node == "old_lift_station":
		campaign_last_safe_node = arrived_node
	money += pending_route_reward
	pending_route_reward = 0
	command_points = 2
	power_priority = "balanced"
	heat_surge = 0
	heat_relief = 0
	_recalculate()
	if arrived_node == "old_lift_station":
		phase = "settlement"
		settlement_actions_remaining = 2 if cinder_contract_status == "accepted" and operational("generator_core") else 1
		settlement_report.clear()
		encounter_outcome = "protected_arrival" if hull_condition >= 7 else "damaged_arrival"
		_encounter_log("Outcome: %s at Old Lift Station. %d service action%s and a full refit window are available." % [encounter_outcome.replace("_", " "), settlement_actions_remaining, "s" if settlement_actions_remaining != 1 else ""])
	elif arrived_node == "switchback_commune":
		journey_complete = true
		run_complete = true
		phase = "results"
		var delivered := cinder_contract_status == "accepted" and operational("generator_core") and String(campaign_decisions.get("lift_engine_choice", "")) == "power_lift"
		if delivered:
			cinder_contract_status = "completed"
			money += 30
			settlement_trust += 2
			encounter_outcome = "spine_powered"
			final_result = "spine_powered"
			_encounter_log("Dynamo contract complete: the powered lift reaches Switchback Commune. Payment is 30 Ashmarks and trust rises by 2.")
		else:
			encounter_outcome = "spine_bypassed"
			final_result = "spine_bypassed"
		_encounter_log("Outcome: %s after five Cinder encounters. Fireline, lift choice, contract, and surviving systems remain in the result." % final_result.replace("_", " "))
	else:
		phase = "map"
		campaign_event_pending = _campaign_event_for_node(arrived_node)
		encounter_outcome = "route_secured"
		_encounter_log("Outcome: %s is secured. Choose the next available route%s." % [String(JOURNEY_NODES.get(arrived_node, {}).get("name", arrived_node)), " after resolving the local decision" if not campaign_event_pending.is_empty() else ""])
	campaign_target_node = ""
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

func _finish_salt_encounter(engine_alive: bool) -> Dictionary:
	var arrived_node := campaign_target_node
	if hull_condition <= 0 or not engine_alive:
		if arrived_node == "salt_citadel":
			encounter_outcome = "salt_lost"
			final_result = "salt_lost"
			run_complete = true
			journey_complete = true
			phase = "results"
			_encounter_log("Outcome: the White Salt crossing fails below the Citadel. The final report preserves water, signal, and redundancy losses.")
			_clear_temporary_seals()
			return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}
		return _campaign_recover_from_failure()
	campaign_encounters_completed += 1
	current_location = arrived_node
	journey_node = arrived_node
	if arrived_node not in campaign_path:
		campaign_path.append(arrived_node)
	if arrived_node == "windbreak":
		campaign_last_safe_node = arrived_node
	money += pending_route_reward
	pending_route_reward = 0
	command_points = 2
	power_priority = "balanced"
	heat_surge = 0
	heat_relief = 0
	_recalculate()
	if arrived_node == "windbreak":
		phase = "settlement"
		settlement_actions_remaining = 2 if salt_contract_status == "accepted" and _has_ready_tag("forecast") else 1
		settlement_report.clear()
		encounter_outcome = "protected_arrival" if hull_condition >= 7 else "damaged_arrival"
		_encounter_log("Outcome: %s at The Windbreak. %d water-service action%s and a full refit window are available." % [encounter_outcome.replace("_", " "), settlement_actions_remaining, "s" if settlement_actions_remaining != 1 else ""])
	elif arrived_node == "salt_citadel":
		journey_complete = true
		run_complete = true
		phase = "results"
		var allied := salt_contract_status == "accepted" and _has_ready_tag("forecast") and String(campaign_decisions.get("rival_terms", "")) == "escort_compact"
		if allied:
			salt_contract_status = "completed"
			money += 26
			settlement_trust += 2
			encounter_outcome = "expanse_allied"
			final_result = "expanse_allied"
			_encounter_log("Beacon escort complete: the Compact reaches the Salt Citadel. Payment is 26 Ashmarks and trust rises by 2.")
		else:
			encounter_outcome = "expanse_crossed"
			final_result = "expanse_crossed"
			_encounter_log("Outcome: the Expanse is crossed without a complete alliance. Signal, water, doctrine, and surviving systems remain in the result.")
	else:
		phase = "map"
		campaign_event_pending = _campaign_event_for_node(arrived_node)
		encounter_outcome = "route_secured"
		_encounter_log("Outcome: %s is secured. Choose the next available route%s." % [String(JOURNEY_NODES.get(arrived_node, {}).get("name", arrived_node)), " after resolving the local decision" if not campaign_event_pending.is_empty() else ""])
	campaign_target_node = ""
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

func _finish_encounter() -> Dictionary:
	encounter_active = false
	encounter_progress = 1.0
	vent_exposure = false
	var engine_alive: bool = _has_engine()
	if campaign_active:
		return _finish_campaign_encounter(engine_alive)
	if hull_condition <= 0 or not engine_alive:
		if journey_leg >= 2:
			encounter_outcome = "march_failed"
			final_result = "march_failed"
			run_complete = true
			journey_complete = true
			phase = "results"
			_encounter_log("Outcome: the final march fails at Meridian Pass. The report preserves the exact dependency chain that stopped the fortress.")
		else:
			encounter_outcome = "forced_retreat"
			pending_route_reward = 0
			command_points = 2
			power_priority = "balanced"
			heat_surge = 0
			heat_relief = 0
			journey_node = "ashgate_depot"
			journey_destination = "morrowline_camp"
			current_location = journey_node
			journey_leg = 0
			phase = "refit"
			_encounter_log("Outcome: forced retreat. Ashgate Depot is still behind the fortress; refit before attempting the road again.")
	elif journey_leg >= 2:
		journey_node = "meridian_pass"
		current_location = journey_node
		journey_complete = true
		run_complete = true
		phase = "results"
		if _all_encounter_enemies_defeated() and hull_condition >= 7:
			encounter_outcome = "decisive_march"
			final_result = "decisive_march"
			money += 40
			_encounter_log("Outcome: decisive march. The Siege Beast falls and the convoy crosses Meridian Pass.")
		else:
			encounter_outcome = "scarred_march"
			final_result = "scarred_march"
			money += 24
			_encounter_log("Outcome: scarred march. The fortress survives Meridian Pass with unresolved damage.")
	else:
		journey_node = journey_destination
		current_location = journey_node
		phase = "settlement"
		settlement_actions_remaining = 2
		settlement_report.clear()
		command_points = 2
		power_priority = "balanced"
		heat_surge = 0
		heat_relief = 0
		_recalculate()
		if hull_condition >= 7:
			encounter_outcome = "protected_arrival"
			money += pending_route_reward + 24
			_encounter_log("Outcome: protected arrival. Morrowline Camp pays the route contract and awards 24 additional Ashmarks.")
		else:
			encounter_outcome = "damaged_arrival"
			money += pending_route_reward + 12
			_encounter_log("Outcome: damaged arrival. Morrowline Camp pays the route contract and 12 additional Ashmarks.")
		pending_route_reward = 0
	_clear_temporary_seals()
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

func _clear_temporary_seals() -> void:
	for index in range(modules.size()):
		if bool(modules[index].get("sealed", false)):
			modules[index]["sealed"] = false
	_recalculate()

func _encounter_step() -> Dictionary:
	encounter_step += 1
	_encounter_log("Step %d: the road pressure advances." % encounter_step)
	for index in range(encounter_enemies.size()):
		var enemy: Dictionary = encounter_enemies[index]
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id: String = String(enemy.get("id", ""))
		var attack_result: Dictionary = _encounter_module_damage(enemy_id)
		var damage: int = int(attack_result.get("damage", 0))
		if damage > 0:
			enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
			enemy["damage_taken"] = int(enemy.get("damage_taken", 0)) + damage
			var source_names := _encounter_source_names(attack_result.get("attackers", []))
			if enemy_id == "storm_front":
				_encounter_log("Storm pressure falls by %d through %s." % [damage, ", ".join(source_names)])
			else:
				_encounter_log("%s takes %d damage from %s." % [ENCOUNTER_ENEMIES[enemy_id].name, damage, ", ".join(source_names)])
			for line in attack_result.get("lines", []):
				_encounter_log(String(line))
		if int(enemy.get("hp", 0)) <= 0:
			enemy["defeated"] = true
			if enemy_id == "storm_front":
				_encounter_log("The Storm Front breaks around the fortress before it can cause further damage.")
			else:
				_encounter_log("%s is stopped before contact." % ENCOUNTER_ENEMIES[enemy_id].name)
			encounter_enemies[index] = enemy
			continue
		if encounter_step >= int(ENCOUNTER_ENEMIES[enemy_id].arrival_step):
			enemy["arrived"] = true
			var existing_target := String(enemy.get("target", ""))
			var existing_index := _module_index_by_id(existing_target)
			if not existing_target.is_empty() and existing_target != "hull" and (existing_index < 0 or int(modules[existing_index].get("durability", 0)) <= 0 or bool(modules[existing_index].get("sealed", false))):
				enemy["target"] = ""
				_encounter_log("%s adapts after its original target becomes unavailable." % ENCOUNTER_ENEMIES[enemy_id].name)
			if String(enemy.get("target", "")).is_empty():
				enemy["target"] = _encounter_choose_target(enemy_id)
				_encounter_log("%s reaches the fortress; target is %s." % [ENCOUNTER_ENEMIES[enemy_id].name, _encounter_target_name(String(enemy.target))])
			if not String(enemy.get("target", "")).is_empty():
				enemy["attacks"] = int(enemy.get("attacks", 0)) + 1
				_encounter_apply_enemy_damage(enemy_id, String(enemy.target), int(enemy.get("damage_bonus", 0)))
		encounter_enemies[index] = enemy
	_encounter_repair()
	if heat > BASE_HEAT_LIMIT and encounter_step % 2 == 0:
		hull_condition = maxi(0, hull_condition - 1)
		_encounter_log("Overheat strains the moving fortress for 1 hull damage.")
	encounter_progress = clampf(float(encounter_step) / 6.0, 0.0, 1.0)
	if encounter_step >= 6 or _all_encounter_enemies_defeated():
		return _finish_encounter()
	return {"ok": true, "resolved": false, "step": encounter_step, "report": encounter_report.duplicate(), "summary": summary()}

func advance_encounter(delta: float = 1.0) -> Dictionary:
	if not encounter_active:
		return {"ok": false, "reason": "no active journey encounter"}
	if pre_contact_occurrence_active():
		return {"ok": false, "reason": "resolve the road interruption before entering contact"}
	var steps: int = maxi(1, int(floor(maxf(0.0, delta))))
	var latest: Dictionary = {"ok": true, "resolved": false, "step": encounter_step, "report": encounter_report.duplicate(), "summary": summary()}
	for _step in range(steps):
		if not encounter_active:
			break
		latest = _encounter_step()
	return latest

func use_encounter_intervention(intervention_id: String, target_module: String = "") -> Dictionary:
	if not encounter_active:
		return {"ok": false, "reason": "interventions are only available during an active encounter"}
	if pre_contact_occurrence_active():
		return {"ok": false, "reason": "resolve the road interruption before issuing a contact order"}
	if encounter_intervention_used:
		return {"ok": false, "reason": "one intervention has already been used in this encounter"}
	var shift_preview: Dictionary = encounter_shift_power_preview() if intervention_id == "shift_power" else {}
	var vent_preview: Dictionary = encounter_vent_heat_preview() if intervention_id == "vent_heat" else {}
	var result: Dictionary = intervene(intervention_id, target_module)
	if bool(result.get("ok", false)):
		encounter_intervention_used = true
		if intervention_id == "shift_power":
			result["affected_attacks"] = shift_preview.get("affected_attacks", [])
		elif intervention_id == "seal_compartment":
			result["retargets"] = _encounter_retarget_unavailable_module(target_module, "its target compartment is sealed")
		elif intervention_id == "cut_loose_cargo":
			result["retargets"] = _encounter_retarget_unavailable_module(String(result.get("removed_module", "")), "its target module is cut loose")
		elif intervention_id == "vent_heat":
			result["affected_hits"] = vent_preview.get("affected_hits", [])
		var effect := _intervention_effect_text(intervention_id, result)
		result["effect"] = effect
		_encounter_log("Intervention: %s." % effect)
	return result

func _intervention_effect_text(intervention_id: String, result: Dictionary) -> String:
	match intervention_id:
		"shift_power":
			var heat_change := int(result.get("heat_change", 1))
			var heat_text := "+%d" % heat_change if heat_change >= 0 else str(heat_change)
			var effect := "Weapon priority set; weapon output +1 each, heat %s" % heat_text if String(result.get("priority", "weapons")) == "weapons" else "Engine priority set; weapon bonus removed, heat %s" % heat_text
			var affected_attacks: Array = result.get("affected_attacks", [])
			if not affected_attacks.is_empty():
				var attack_changes: Array[String] = []
				for attack in affected_attacks:
					var change := "%s %d→%d" % [String(attack.get("enemy_name", "Threat")), int(attack.get("damage_before", 0)), int(attack.get("damage_after", 0))]
					if change not in attack_changes:
						attack_changes.append(change)
				effect += "; attacks %s" % ", ".join(attack_changes)
			return effect
		"seal_compartment":
			var target_module := String(result.get("target_module", "module"))
			var effect := "%s sealed; protected from targeting, offline until the encounter ends" % String(module_definition(target_module).get("name", target_module))
			var retargets: Array = result.get("retargets", [])
			if not retargets.is_empty():
				var redirects: Array[String] = []
				for retarget in retargets:
					redirects.append("%s → %s" % [String(retarget.get("enemy_name", "Threat")), String(retarget.get("target_name", "Hull"))])
				effect += "; redirected %s" % ", ".join(redirects)
			return effect
		"vent_heat":
			var effect := "%d heat vented; the next exterior hit deals +1 damage" % int(result.get("heat_removed", 0))
			var affected_hits: Array = result.get("affected_hits", [])
			if not affected_hits.is_empty():
				var exposure_lines: Array[String] = []
				for hit in affected_hits:
					exposure_lines.append("%s → %s %d→%d" % [String(hit.get("enemy_name", "Threat")), String(hit.get("target_name", "system")), int(hit.get("damage_before", 0)), int(hit.get("damage_after", 0))])
				effect += "; exposed %s" % ", ".join(exposure_lines)
			return effect
		"cut_loose_cargo":
			var removed_module := String(result.get("removed_module", "cargo"))
			var effect := "%s discarded; mass and cargo incentive reduced" % String(module_definition(removed_module).get("name", removed_module))
			var retargets: Array = result.get("retargets", [])
			if not retargets.is_empty():
				var redirects: Array[String] = []
				for retarget in retargets:
					redirects.append("%s → %s" % [String(retarget.get("enemy_name", "Threat")), String(retarget.get("target_name", "Hull"))])
				effect += "; redirected %s" % ", ".join(redirects)
			return effect
	return intervention_id.replace("_", " ").capitalize()

func _all_encounter_enemies_defeated() -> bool:
	if encounter_enemies.is_empty():
		return false
	for enemy in encounter_enemies:
		if not bool(enemy.get("defeated", false)):
			return false
	return true

func encounter_summary() -> Dictionary:
	var enemy_views: Array = encounter_enemies.duplicate(true)
	for index in range(enemy_views.size()):
		enemy_views[index]["impact"] = encounter_enemy_impact_preview(enemy_views[index])
		enemy_views[index]["defense"] = encounter_defense_preview(enemy_views[index])
	return {"active": encounter_active, "step": encounter_step, "progress": encounter_progress, "outcome": encounter_outcome, "intervention_used": encounter_intervention_used, "forecast": encounter_forecast(), "enemies": enemy_views, "report": encounter_report.duplicate()}

func _cell_occupied(cell: Vector2i, ignore_index: int = -1) -> bool:
	for index in range(modules.size()):
		if index == ignore_index:
			continue
		var instance: Dictionary = modules[index]
		if cell in occupied_cells(instance):
			return true
	return false

func _has_exterior_capacity(ignore_index: int = -1) -> bool:
	var count := 0
	for index in range(modules.size()):
		if index == ignore_index:
			continue
		var instance: Dictionary = modules[index]
		if bool(instance.get("exterior", false)):
			count += 1
	return count < chassis_exterior_limit()

func _has_engine() -> bool:
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if "engine" in definition.get("tags", []) and bool(dependency_status(instance).get("operational", false)):
			return true
	return false

func _has_tag(tag: String) -> bool:
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if tag in definition.get("tags", []) and int(instance.get("durability", 0)) > 0:
			return true
	return false

func _set_sealed(module_id: String, value: bool) -> bool:
	for index in range(modules.size()):
		if String(modules[index].get("id", "")) == module_id:
			modules[index]["sealed"] = value
			return true
	return false

func sacrificable_cargo_id() -> String:
	for preferred_id in ["refugee_bunk", "parts_crate", "coal_cell"]:
		if module_count(preferred_id) > 0:
			return preferred_id
	for instance in modules:
		var module_id := String(instance.get("id", ""))
		if "cargo" in module_definition(module_id).get("tags", []):
			return module_id
	return ""

func _remove_first_sacrificable_cargo() -> String:
	var module_id := sacrificable_cargo_id()
	if module_id.is_empty():
		return ""
	for index in range(modules.size()):
		if String(modules[index].get("id", "")) == module_id:
			modules.remove_at(index)
			return module_id
	return ""

func _choose_target(threat: Dictionary) -> int:
	var target_tags: Array = threat.get("target_tags", [])
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		var definition := module_definition(String(instance.get("id", "")))
		if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
			continue
		for tag in target_tags:
			if tag in definition.get("tags", []):
				return index
	return -1

func _deterministic_threat(route_id: String) -> String:
	var threat_ids: Array = ["road_raiders", "climbers", "burrowers", "storm_front"]
	var index := absi(seed + day + route_id.length()) % threat_ids.size()
	return String(threat_ids[index])
