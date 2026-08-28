class_name LongMarchState
extends RefCounted

## Presentation-independent vertical-slice simulation for The Long March.
## Modules are placed in one chassis grid and interact through explicit dependencies.

const GRID_WIDTH := 6
const GRID_HEIGHT := 4
const MAX_EXTERIOR_MOUNTS := 2
const SAVE_VERSION := 4
const FINAL_RESULTS := ["decisive_march", "scarred_march", "march_failed"]
const VALID_PHASES := ["refit", "map", "battle", "final_battle", "settlement", "results"]
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
	"storm_front": {"name": "Storm Front", "target_tags": ["signal", "exterior"], "damage": 1},
	"siege_beast": {"name": "Siege Beast", "target_tags": ["armor", "crew"], "damage": 2}
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
	"signal_causeway": {"name": "Signal Causeway", "kind": "hazard", "description": "An exposed relay causeway caught inside a moving storm front."}
}
const JOURNEY_ENCOUNTERS := {
	"safe_road": ["road_raiders", "road_raiders"],
	"exposed_shortcut": ["road_raiders", "climbers"],
	"salvage_detour": ["burrowers"]
}
const ENCOUNTER_ENEMIES := {
	"road_raiders": {"name": "Road Raider", "health": 5, "damage": 1, "arrival_step": 2, "target_tags": ["cargo", "exterior"], "route": "road flank", "counter": "shell cannon or repeater gun"},
	"climbers": {"name": "Climber", "health": 4, "damage": 1, "arrival_step": 3, "target_tags": ["signal", "exterior", "crew"], "route": "fortress flank", "counter": "wall lamp or repeater gun"},
	"burrowers": {"name": "Burrower", "health": 7, "damage": 2, "arrival_step": 3, "target_tags": ["engine", "workshop", "lower_hull"], "route": "under-road", "counter": "lower-hull armor, shifted weapons, or a spare engine"},
	"storm_front": {"name": "Storm Front", "health": 7, "damage": 1, "arrival_step": 1, "target_tags": ["signal", "exterior"], "route": "weather line", "counter": "signal coverage, armor, or vent heat"},
	"siege_beast": {"name": "Siege Beast", "health": 10, "damage": 3, "arrival_step": 4, "target_tags": ["armor", "crew"], "route": "direct road", "counter": "shell cannon and front armor"}
}
const CAMPAIGN_NODES := {
	"ashgate_depot": {"name": "Ashgate Depot", "type": "settlement", "visibility": "known", "description": "Refit, choose the first guard contract, and leave before the blockade closes."},
	"rill_crossing": {"name": "Rill Crossing", "type": "ambush", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.14, "pressure": 1, "reward": 12, "threat_hint": "cargo raiders", "encounter": ["road_raiders"]},
	"soot_orchard": {"name": "The Soot Orchard", "type": "salvage", "visibility": "forecast", "days": 2, "fuel": 1, "risk": 0.22, "pressure": 1, "reward": 10, "mass_sensitive": true, "threat_hint": "fire and weather", "encounter": ["storm_front"]},
	"broken_relay": {"name": "Broken Relay", "type": "relay", "visibility": "forecast", "days": 1, "fuel": 1, "risk": 0.24, "pressure": 1, "reward": 14, "threat_hint": "upper-hull movement", "encounter": ["climbers"]},
	"red_wheel_toll_bridge": {"name": "Red Wheel Toll Bridge", "type": "ambush", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.36, "pressure": 2, "reward": 24, "threat_hint": "organized blockade", "encounter": ["road_raiders", "climbers"]},
	"morrowline_camp": {"name": "Morrowline Camp", "type": "settlement", "visibility": "known", "days": 1, "fuel": 1, "risk": 0.28, "pressure": 1, "reward": 16, "threat_hint": "raiders on the convoy approach", "encounter": ["road_raiders"]},
	"lower_ash_road": {"name": "Lower Ash Road", "type": "hazard", "visibility": "forecast", "days": 2, "fuel": 1, "risk": 0.38, "pressure": 2, "reward": 24, "mass_sensitive": true, "threat_hint": "movement below the road", "encounter": ["burrowers"]},
	"signal_causeway": {"name": "Signal Causeway", "type": "hazard", "visibility": "unscouted", "days": 1, "fuel": 1, "risk": 0.43, "pressure": 2, "reward": 20, "threat_hint": "weather and exposed approaches", "encounter": ["storm_front", "climbers"]},
	"meridian_pass": {"name": "Meridian Pass", "type": "boss", "visibility": "known", "days": 2, "fuel": 2, "risk": 0.58, "pressure": 2, "reward": 40, "threat_hint": "Siege Beast", "encounter": ["siege_beast"]}
}
const CAMPAIGN_EDGES := {
	"ashgate_depot": ["rill_crossing", "soot_orchard"],
	"rill_crossing": ["broken_relay", "red_wheel_toll_bridge"],
	"soot_orchard": ["broken_relay", "red_wheel_toll_bridge"],
	"broken_relay": ["morrowline_camp"],
	"red_wheel_toll_bridge": ["morrowline_camp"],
	"morrowline_camp": ["lower_ash_road", "signal_causeway"],
	"lower_ash_road": ["meridian_pass"],
	"signal_causeway": ["meridian_pass"]
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
	"signal_mast": {"name": "Signal Mast", "family": "signal", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["signal", "exterior", "long_range"], "capability": "Reveals exact contacts and cuts 2 Storm Front pressure while Ready."}
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
var campaign_encounters_completed: int = 0
var campaign_path: Array[String] = []
var campaign_target_node: String = ""
var campaign_last_safe_node: String = "ashgate_depot"
var campaign_pressure: int = 0
var campaign_retreats: int = 0
var campaign_event_pending: String = ""
var guard_contract_status: String = "unoffered"
var settlement_trust: int = 0
var mobility_tendency: int = 0
var shelter_tendency: int = 0
var knowledge_tendency: int = 0
var specialist_id: String = ""
var relay_repaired: bool = false
var workers_rescued: bool = false

func _init(world_seed: int = 1107) -> void:
	seed = world_seed

func module_definition(module_id: String) -> Dictionary:
	return MODULE_DEFS.get(module_id, {})

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
		if _cell_occupied(cell, ignore_index):
			return {"ok": false, "reason": "module overlaps an existing module"}
	if exterior and not _has_exterior_capacity(ignore_index):
		return {"ok": false, "reason": "exterior mount capacity exceeded"}
	var placement_mass := total_mass()
	if ignore_index >= 0 and ignore_index < modules.size():
		placement_mass -= int(module_definition(String(modules[ignore_index].get("id", ""))).get("mass", 0))
	if placement_mass + int(definition.get("mass", 0)) > BASE_MASS_LIMIT:
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
	return not encounter_active and phase in ["refit", "settlement"] and current_location in ["ashgate_depot", "morrowline_camp"]

func start_campaign() -> Dictionary:
	campaign_active = true
	campaign_encounters_completed = 0
	campaign_path = ["ashgate_depot"]
	campaign_target_node = ""
	campaign_last_safe_node = "ashgate_depot"
	campaign_pressure = 0
	campaign_retreats = 0
	campaign_event_pending = ""
	guard_contract_status = "offered"
	settlement_trust = 0
	mobility_tendency = 0
	shelter_tendency = 0
	knowledge_tendency = 0
	specialist_id = ""
	relay_repaired = false
	workers_rescued = false
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

func campaign_pressure_band() -> String:
	if campaign_pressure >= 5:
		return "break"
	if campaign_pressure >= 3:
		return "closing"
	return "watch"

func campaign_node_closed(node_id: String) -> bool:
	if node_id == "signal_causeway" and campaign_pressure_band() == "break" and specialist_id != "iven_pell" and not _has_ready_tag("forecast"):
		return true
	return false

func campaign_available_nodes() -> Array[String]:
	var result: Array[String] = []
	if not campaign_active or encounter_active or not campaign_event_pending.is_empty() or phase == "results":
		return result
	for raw_node_id in CAMPAIGN_EDGES.get(current_location, []):
		var node_id := String(raw_node_id)
		if not campaign_node_closed(node_id):
			result.append(node_id)
	return result

func campaign_node_preview(node_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	var node: Dictionary = CAMPAIGN_NODES.get(node_id, {})
	if node.is_empty():
		return {"ok": false, "reason": "unknown campaign node"}
	var mass_penalty := 1 if bool(node.get("mass_sensitive", false)) and total_mass() > BASE_MASS_LIMIT - 2 else 0
	var fuel_cost := int(node.get("fuel", 0)) + mass_penalty
	var predicted_heat := maxi(0, total_heat() + (2 if doctrine == "run_hot" else 0))
	var informed := specialist_id == "iven_pell" or _has_ready_tag("forecast")
	var visibility := "known" if informed else String(node.get("visibility", "forecast"))
	var signal_discount := 0.08 if informed else 0.0
	var heat_penalty := 0.08 if predicted_heat > BASE_HEAT_LIMIT else 0.0
	var base_risk := float(node.get("risk", 0.0))
	var blockade_risk := campaign_pressure * 0.02
	var mass_risk := float(mass_penalty) * 0.05
	var risk := clampf(base_risk + route_risk_modifier + blockade_risk + mass_risk + heat_penalty - signal_discount, 0.0, 0.95)
	var pressure_gain := int(node.get("pressure", 1))
	var encounter_difficulty := maxi(0, pressure_gain - (1 if informed else 0))
	if predicted_heat > BASE_HEAT_LIMIT:
		encounter_difficulty += 1
	var threat_names: Array[String] = []
	var counter_hints: Array[String] = []
	if visibility == "known":
		for enemy_id in node.get("encounter", []):
			var enemy_definition: Dictionary = ENCOUNTER_ENEMIES.get(String(enemy_id), {})
			threat_names.append(String(enemy_definition.get("name", enemy_id)))
			var counter_hint := String(enemy_definition.get("counter", ""))
			if not counter_hint.is_empty() and counter_hint not in counter_hints:
				counter_hints.append(counter_hint)
	var risk_factors: Array[String] = []
	if visibility != "unscouted":
		risk_factors.append("baseline %.0f%%" % (base_risk * 100.0))
	if blockade_risk > 0.0:
		risk_factors.append("blockade +%dpt" % roundi(blockade_risk * 100.0))
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
		"days": int(node.get("days", 0)),
		"fuel": fuel_cost,
		"risk": risk,
		"risk_factors": risk_factors,
		"pressure_gain": pressure_gain,
		"encounter_pressure": encounter_difficulty,
		"predicted_heat": predicted_heat,
		"reward": int(node.get("reward", 0)),
		"threat_hint": String(node.get("threat_hint", "uncertain road pressure")),
		"threats": threat_names,
		"counter_hints": counter_hints,
		"closed": campaign_node_closed(node_id)
	}

func choose_guard_contract(accept: bool) -> Dictionary:
	if not campaign_active or current_location != "ashgate_depot" or phase != "refit":
		return {"ok": false, "reason": "the guard contract is only offered at Ashgate Depot"}
	if guard_contract_status != "offered":
		return {"ok": false, "reason": "the guard contract has already been answered"}
	guard_contract_status = "accepted" if accept else "declined"
	var message := ""
	if accept:
		message = "Contract accepted: each enemy on the Morrowline approach gains 1 HP; safe arrival pays 30 Ashmarks and 2 trust."
	else:
		mobility_tendency += 1
		message = "Contract declined: Morrowline enemies keep normal endurance; the fortress gives up the 30-Ashmark and 2-trust payout."
	log.append(message)
	return {"ok": true, "status": guard_contract_status, "message": message, "summary": summary()}

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
	return {}

func resolve_campaign_event(choice_id: String) -> Dictionary:
	if campaign_event_pending.is_empty():
		return {"ok": false, "reason": "no campaign decision is pending"}
	var resolved_event := campaign_event_pending
	var result_message := ""
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
	else:
		return {"ok": false, "reason": "unknown campaign event"}
	log.append(result_message)
	campaign_event_pending = ""
	return {"ok": true, "event": resolved_event, "choice": choice_id, "message": result_message, "summary": summary()}

func iven_recruitment_status() -> Dictionary:
	if not campaign_active or current_location != "broken_relay" or phase != "map":
		return {"available": false, "reason": "Iven Pell can only join at the Broken Relay"}
	if not relay_repaired:
		return {"available": false, "reason": "Iven will not leave until the relay is restored"}
	if not specialist_id.is_empty():
		return {"available": false, "reason": "the prototype crew station is already assigned"}
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
	if guard_contract_status == "offered":
		return {"ok": false, "reason": "answer the Ashgate guard contract before departure"}
	if not campaign_event_pending.is_empty():
		return {"ok": false, "reason": "resolve the current node decision before leaving"}
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
	heat_surge = 2 if doctrine == "run_hot" else 0
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
	current_location = node_id
	journey_leg = campaign_encounters_completed + 1
	command_points = 2
	power_priority = "balanced"
	phase = "final_battle" if node_id == "meridian_pass" else "battle"
	var node: Dictionary = CAMPAIGN_NODES[node_id]
	var composition: Array = node.get("encounter", []).duplicate()
	if node_id == "meridian_pass" and campaign_pressure_band() == "break":
		composition.append("climbers")
	_configure_encounter(composition, String(node.name), String(JOURNEY_NODES.get(node_id, {}).get("description", "The route narrows ahead.")))
	if node_id == "morrowline_camp" and guard_contract_status == "accepted":
		for index in range(encounter_enemies.size()):
			encounter_enemies[index]["hp"] = int(encounter_enemies[index].get("hp", 0)) + 1
			encounter_enemies[index]["max_hp"] = int(encounter_enemies[index].get("max_hp", 0)) + 1
		_encounter_log("Guard contract: the raiders commit to the convoy approach, adding one enemy endurance.")
	log.append("Campaign route selected: %s. Closure pressure is %s (%d)." % [String(node.name), campaign_pressure_band(), campaign_pressure])
	return {"ok": true, "node": node_id, "preview": preview, "forecast": encounter_forecast(), "encounter": encounter_summary(), "summary": summary()}

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
	return {"module_id": module_id, "state": state_name, "operational": is_operational, "connections": connections, "reasons": reasons, "benefits": benefits}

func dependency_status_at(cell: Vector2i) -> Dictionary:
	var instance := module_at(cell)
	if instance.is_empty():
		return {}
	return dependency_status(instance)

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
	heat = maxi(0, total_heat() + heat_surge - heat_relief)
	if heat > BASE_HEAT_LIMIT:
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
		"mass_limit": BASE_MASS_LIMIT,
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
		"campaign_encounters_completed": campaign_encounters_completed,
		"campaign_path": campaign_path.duplicate(),
		"campaign_target_node": campaign_target_node,
		"campaign_pressure": campaign_pressure,
		"campaign_pressure_band": campaign_pressure_band(),
		"campaign_retreats": campaign_retreats,
		"campaign_event_pending": campaign_event_pending,
		"guard_contract_status": guard_contract_status,
		"settlement_trust": settlement_trust,
		"mobility_tendency": mobility_tendency,
		"shelter_tendency": shelter_tendency,
		"knowledge_tendency": knowledge_tendency,
		"specialist_id": specialist_id,
		"relay_repaired": relay_repaired,
		"workers_rescued": workers_rescued
	}

func serialize() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
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
		"campaign_encounters_completed": campaign_encounters_completed,
		"campaign_path": campaign_path.duplicate(),
		"campaign_target_node": campaign_target_node,
		"campaign_last_safe_node": campaign_last_safe_node,
		"campaign_pressure": campaign_pressure,
		"campaign_retreats": campaign_retreats,
		"campaign_event_pending": campaign_event_pending,
		"guard_contract_status": guard_contract_status,
		"settlement_trust": settlement_trust,
		"mobility_tendency": mobility_tendency,
		"shelter_tendency": shelter_tendency,
		"knowledge_tendency": knowledge_tendency,
		"specialist_id": specialist_id,
		"relay_repaired": relay_repaired,
		"workers_rescued": workers_rescued,
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

func load_serialized(data: Dictionary) -> Dictionary:
	var save_version := int(data.get("save_version", 1))
	if save_version > SAVE_VERSION:
		return {"ok": false, "reason": "save was created by a newer version"}
	if not data.has("modules"):
		return {"ok": false, "reason": "save is missing fortress modules"}
	var restored_phase := String(data.get("phase", phase))
	var restored_final_result := String(data.get("final_result", final_result))
	var restored_run_complete := bool(data.get("run_complete", run_complete))
	var restored_journey_complete := bool(data.get("journey_complete", journey_complete))
	var restored_encounter_active := bool(data.get("encounter_active", encounter_active))
	if restored_phase not in VALID_PHASES:
		return {"ok": false, "reason": "checkpoint has an unknown campaign phase"}
	var restored_battle_phase := restored_phase in ["battle", "final_battle"]
	if restored_battle_phase != restored_encounter_active:
		return {"ok": false, "reason": "encounter state conflicts with the campaign phase"}
	if restored_phase == "results" and restored_final_result not in FINAL_RESULTS:
		return {"ok": false, "reason": "result checkpoint has no recognized outcome"}
	if restored_phase == "results" and (not restored_run_complete or not restored_journey_complete):
		return {"ok": false, "reason": "result checkpoint is missing completion state"}
	if restored_phase != "results" and (restored_run_complete or restored_journey_complete or restored_final_result in FINAL_RESULTS):
		return {"ok": false, "reason": "completion state conflicts with the active campaign phase"}
	seed = int(data.get("seed", seed))
	day = int(data.get("day", day))
	fuel = int(data.get("fuel", fuel))
	money = int(data.get("money", money))
	command_points = int(data.get("command_points", command_points))
	heat = int(data.get("heat", heat))
	hull_condition = int(data.get("hull_condition", hull_condition))
	current_location = String(data.get("current_location", current_location))
	route_risk_modifier = float(data.get("route_risk_modifier", route_risk_modifier))
	current_route_risk = float(data.get("current_route_risk", current_route_risk))
	encounter_pressure = int(data.get("encounter_pressure", encounter_pressure))
	pending_route_reward = int(data.get("pending_route_reward", pending_route_reward))
	target_doctrine = String(data.get("target_doctrine", target_doctrine))
	power_priority = String(data.get("power_priority", power_priority))
	heat_relief = int(data.get("heat_relief", heat_relief))
	heat_surge = int(data.get("heat_surge", heat_surge))
	vent_exposure = bool(data.get("vent_exposure", vent_exposure))
	journey_node = String(data.get("journey_node", journey_node))
	journey_destination = String(data.get("journey_destination", journey_destination))
	journey_route = String(data.get("journey_route", journey_route))
	journey_complete = restored_journey_complete
	encounter_active = restored_encounter_active
	encounter_step = int(data.get("encounter_step", encounter_step))
	encounter_progress = float(data.get("encounter_progress", encounter_progress))
	encounter_enemies = data.get("encounter_enemies", []).duplicate(true)
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
	campaign_active = bool(data.get("campaign_active", campaign_active))
	campaign_encounters_completed = int(data.get("campaign_encounters_completed", campaign_encounters_completed))
	campaign_path = _string_array(data.get("campaign_path", []))
	campaign_target_node = String(data.get("campaign_target_node", campaign_target_node))
	campaign_last_safe_node = String(data.get("campaign_last_safe_node", campaign_last_safe_node))
	campaign_pressure = int(data.get("campaign_pressure", campaign_pressure))
	campaign_retreats = int(data.get("campaign_retreats", campaign_retreats))
	campaign_event_pending = String(data.get("campaign_event_pending", campaign_event_pending))
	guard_contract_status = String(data.get("guard_contract_status", guard_contract_status))
	settlement_trust = int(data.get("settlement_trust", settlement_trust))
	mobility_tendency = int(data.get("mobility_tendency", mobility_tendency))
	shelter_tendency = int(data.get("shelter_tendency", shelter_tendency))
	knowledge_tendency = int(data.get("knowledge_tendency", knowledge_tendency))
	specialist_id = String(data.get("specialist_id", specialist_id))
	relay_repaired = bool(data.get("relay_repaired", relay_repaired))
	workers_rescued = bool(data.get("workers_rescued", workers_rescued))
	modules = _deserialized_modules(data.get("modules", []))
	stored_modules = _deserialized_modules(data.get("stored_modules", []))
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

func settlement_repair(module_id: String) -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "repairs are only available at Morrowline Camp"}
	if settlement_actions_remaining <= 0:
		return {"ok": false, "reason": "no settlement actions remain"}
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) != module_id:
			continue
		var maximum := int(module_definition(module_id).get("durability", 1))
		if int(instance.get("durability", 0)) >= maximum:
			return {"ok": false, "reason": "selected module is already fully repaired"}
		var missing := maximum - int(instance.get("durability", 0))
		var restored := mini(2, missing)
		var cost := restored * 4
		if money < cost:
			return {"ok": false, "reason": "not enough Ashmarks"}
		money -= cost
		settlement_actions_remaining -= 1
		instance["durability"] = int(instance.get("durability", 0)) + restored
		modules[index] = instance
		_recalculate()
		var message := "Morrowline repaired %s by %d for %d Ashmarks." % [module_definition(module_id).name, restored, cost]
		settlement_report.append(message)
		log.append(message)
		return {"ok": true, "restored": restored, "cost": cost, "summary": summary()}
	return {"ok": false, "reason": "selected module was not found"}

func settlement_refuel() -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "fuel is only available at Morrowline Camp"}
	if settlement_actions_remaining <= 0:
		return {"ok": false, "reason": "no settlement actions remain"}
	if money < 8:
		return {"ok": false, "reason": "not enough Ashmarks"}
	money -= 8
	fuel += 2
	settlement_actions_remaining -= 1
	var message := "Morrowline loaded 2 fuel for 8 Ashmarks."
	settlement_report.append(message)
	log.append(message)
	return {"ok": true, "fuel_added": 2, "cost": 8, "summary": summary()}

func settlement_repair_hull() -> Dictionary:
	if phase != "settlement":
		return {"ok": false, "reason": "hull repair is only available at Morrowline Camp"}
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
	var message := "Morrowline restored %d hull for 10 Ashmarks." % hull_added
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
	var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
	var target_tags: Array = definition.get("target_tags", [])
	var best_index: int = -1
	var best_score: int = -999
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) == excluded_module_id:
			continue
		if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
			continue
		var module_def: Dictionary = module_definition(String(instance.get("id", "")))
		var module_tags: Array = module_def.get("tags", [])
		var score := 0
		var matches_target := false
		for tag in target_tags:
			if tag in module_tags:
				score += 10
				matches_target = true
		if not matches_target:
			continue
		var position: Vector2i = instance.get("position", Vector2i.ZERO)
		if enemy_id == "road_raiders":
			if "cargo" in module_tags:
				score += 6
			if bool(instance.get("exterior", false)):
				score += 4
		if enemy_id == "climbers":
			if bool(instance.get("exterior", false)):
				score += 6
			if position.y == 0:
				score += 3
		if enemy_id == "burrowers":
			if position.y >= 2:
				score += 6
			if "engine" in module_tags or "workshop" in module_tags:
				score += 4
		if enemy_id == "siege_beast" and ("armor" in module_tags or "crew" in module_tags):
			score += 6
		if encounter_target_doctrine == "protect_cargo" and "cargo" in module_tags:
			score -= 4
		elif encounter_target_doctrine == "protect_crew" and "crew" in module_tags:
			score -= 4
		score += maxi(0, 6 - int(instance.get("durability", 0)))
		if score > best_score:
			best_index = index
			best_score = score
	if best_index >= 0:
		return String(modules[best_index].get("id", ""))
	return "hull"

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
		if enemy_id == "burrowers" and "lower_hull" not in neighbor_tags:
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
		var absorbed := 2 if enemy_id == "burrowers" and "lower_hull" in armor_tags else 1
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
	if encounter_target_doctrine == "protect_cargo" and "cargo" in target_tags:
		damage = maxi(0, damage - 1)
		profile["doctrine_effect"] = "protect_cargo"
	elif encounter_target_doctrine == "protect_crew" and "crew" in target_tags:
		damage = maxi(0, damage - 1)
		profile["doctrine_effect"] = "protect_crew"
	elif encounter_target_doctrine == "run_hot" and heat > BASE_HEAT_LIMIT:
		damage += 1
		profile["doctrine_effect"] = "run_hot"
	if vent_exposure and bool(instance.get("exterior", false)):
		damage += 1
		profile["vent_exposed"] = true
	if target_id == "front_armor_plate" and enemy_id == "siege_beast":
		damage = maxi(1, damage - 1)
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
	profile["current_durability"] = current_durability
	profile["remaining_durability"] = maxi(0, current_durability - int(profile.get("damage", 0)))
	profile["dependency_changes"] = _encounter_dependency_impact_preview(profile)
	return profile

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
		if bool(profile.get("vent_exposed", false)):
			vent_exposure = false
			_encounter_log("Open heat vents expose %s to one additional damage." % module_def.name)
		instance["durability"] = maxi(0, int(instance.get("durability", 0)) - damage)
		modules[index] = instance
		_encounter_log("%s hits %s for %d; durability is %d." % [definition.name, module_def.name, damage, int(instance.durability)])
		_recalculate()
		_log_dependency_changes(dependency_before)
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
			_encounter_log("Field Workshop restores %s by %d durability%s." % [module_definition(weakest_id).name, repair_amount, " with connected parts" if repair_amount > 1 else ""])

func _workshop_repair_amount() -> int:
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if "repair" in definition.get("tags", []) and bool(dependency_status(instance).get("operational", false)):
			return 2 if _has_adjacent_tag(instance, "parts") else 1
	return 0

func _campaign_event_for_node(node_id: String) -> String:
	match node_id:
		"soot_orchard":
			return "salvage_choice"
		"broken_relay":
			return "lost_signal"
		"red_wheel_toll_bridge":
			return "toll_decision"
	return ""

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
	phase = "settlement" if campaign_last_safe_node == "morrowline_camp" else ("refit" if campaign_last_safe_node == "ashgate_depot" else "map")
	if phase == "settlement":
		settlement_actions_remaining = maxi(1, settlement_actions_remaining)
	_recalculate()
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

	campaign_encounters_completed += 1
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
	if arrived_node == "morrowline_camp":
		phase = "settlement"
		settlement_actions_remaining = 2
		settlement_report.clear()
		if guard_contract_status == "accepted":
			guard_contract_status = "completed"
			money += 30
			settlement_trust += 2
			_encounter_log("Contract complete: the Morrowline parts convoy arrives under guard. Payment is 30 Ashmarks and settlement trust rises by 2.")
		if workers_rescued:
			settlement_trust += 1
			_encounter_log("The rescued orchard workers reach Morrowline and add one settlement trust.")
		encounter_outcome = "protected_arrival" if hull_condition >= 7 else "damaged_arrival"
		_encounter_log("Outcome: %s at Morrowline Camp. Two service actions and a full refit window are available." % encounter_outcome.replace("_", " "))
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
			if enemy_id == "storm_front":
				_encounter_log("Storm pressure falls by %d through %s." % [damage, ", ".join(attack_result.get("attackers", []))])
			else:
				_encounter_log("%s takes %d damage from %s." % [ENCOUNTER_ENEMIES[enemy_id].name, damage, ", ".join(attack_result.get("attackers", []))])
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
				_encounter_log("%s reaches the fortress; target is %s." % [ENCOUNTER_ENEMIES[enemy_id].name, String(enemy.target)])
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
	return count < MAX_EXTERIOR_MOUNTS

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
