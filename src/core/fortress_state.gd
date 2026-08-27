class_name LongMarchState
extends RefCounted

## Presentation-independent vertical-slice simulation for The Long March.
## Modules are placed in one chassis grid and interact through explicit dependencies.

const GRID_WIDTH := 6
const GRID_HEIGHT := 4
const BASE_POWER := 2
const BASE_MASS_LIMIT := 14
const BASE_HEAT_LIMIT := 6
const ROUTES := {
	"safe_road": {"name": "The Long Road", "days": 2, "fuel": 2, "risk": 0.12, "reward": 14},
	"exposed_shortcut": {"name": "The Exposed Cut", "days": 1, "fuel": 2, "risk": 0.42, "reward": 22},
	"salvage_detour": {"name": "The Salvage Detour", "days": 3, "fuel": 3, "risk": 0.28, "reward": 28}
}
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
	"morrowline_camp": {"name": "Morrowline Camp", "kind": "city", "description": "A moving convoy shelter waiting for engines, tools, and protection."}
}
const JOURNEY_ENCOUNTERS := {
	"safe_road": ["road_raiders", "road_raiders"],
	"exposed_shortcut": ["road_raiders", "climbers"],
	"salvage_detour": ["burrowers"]
}
const ENCOUNTER_ENEMIES := {
	"road_raiders": {"name": "Road Raider", "health": 5, "damage": 1, "arrival_step": 2, "target_tags": ["cargo", "exterior"], "route": "road flank", "counter": "shell cannon or repeater gun"},
	"climbers": {"name": "Climber", "health": 4, "damage": 1, "arrival_step": 3, "target_tags": ["signal", "exterior", "crew"], "route": "fortress flank", "counter": "wall lamp or repeater gun"},
	"burrowers": {"name": "Burrower", "health": 7, "damage": 2, "arrival_step": 2, "target_tags": ["engine", "workshop", "lower_hull"], "route": "under-road", "counter": "shell cannon and spare engine"},
	"siege_beast": {"name": "Siege Beast", "health": 10, "damage": 3, "arrival_step": 4, "target_tags": ["armor", "crew"], "route": "direct road", "counter": "shell cannon and front armor"}
}
const MODULE_DEFS := {
	"steam_lance_engine": {"name": "Steam Lance Engine", "family": "engine", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 0, "heat": 1, "durability": 4, "tags": ["engine", "fuel_sensitive"]},
	"ash_runner_engine": {"name": "Ash Runner Engine", "family": "engine", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 0, "power_output": 0, "heat": 2, "durability": 3, "tags": ["engine", "fast", "hot"]},
	"generator_core": {"name": "Generator Core", "family": "crew_room", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 4, "heat": 2, "durability": 4, "tags": ["generator", "critical"]},
	"shell_cannon": {"name": "Shell Cannon", "family": "weapon", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 2, "power_output": 0, "heat": 2, "durability": 3, "tags": ["weapon", "exterior", "burst"]},
	"repeater_gun": {"name": "Repeater Gun", "family": "weapon", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 2, "tags": ["weapon", "exterior", "suppress"]},
	"field_workshop": {"name": "Field Workshop", "family": "workshop", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 3, "tags": ["repair", "workshop", "crew"]},
	"signal_coil": {"name": "Signal Coil", "family": "signal", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 2, "tags": ["signal", "forecast"]},
	"wall_lamp": {"name": "Wall Lamp", "family": "signal", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 1, "power_output": 0, "heat": 1, "durability": 2, "tags": ["signal", "exterior", "climber_counter"]},
	"front_armor_plate": {"name": "Front Armor Plate", "family": "armor", "shape": Vector2i(2, 1), "mass": 3, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 6, "tags": ["armor", "front"]},
	"side_armor_skirt": {"name": "Side Armor Skirt", "family": "armor", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 4, "tags": ["armor", "side", "lower_hull"]},
	"crew_quarters": {"name": "Crew Quarters", "family": "crew_room", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 4, "tags": ["crew", "life_support"]},
	"parts_crate": {"name": "Parts Crate", "family": "cargo", "shape": Vector2i(1, 1), "mass": 1, "power_draw": 0, "power_output": 0, "heat": 0, "durability": 2, "tags": ["parts", "cargo"]},
	"refugee_bunk": {"name": "Refugee Bunk", "family": "cargo", "shape": Vector2i(2, 1), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["refuge", "cargo", "life_support"]},
	"signal_mast": {"name": "Signal Mast", "family": "signal", "shape": Vector2i(1, 2), "mass": 2, "power_draw": 1, "power_output": 0, "heat": 0, "durability": 3, "tags": ["signal", "exterior", "long_range"]}
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
var target_doctrine: String = "protect_cargo"
var power_priority: String = "balanced"
var modules: Array = []
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

func _init(world_seed: int = 1107) -> void:
	seed = world_seed

func module_definition(module_id: String) -> Dictionary:
	return MODULE_DEFS.get(module_id, {})

func module_instance(module_id: String, position: Vector2i, exterior: bool = false) -> Dictionary:
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {}
	return {
		"id": module_id,
		"position": position,
		"exterior": exterior,
		"durability": int(definition.get("durability", 1)),
		"sealed": false
	}

func occupied_cells(instance: Dictionary) -> Array[Vector2i]:
	var definition := module_definition(String(instance.get("id", "")))
	var shape: Vector2i = definition.get("shape", Vector2i.ONE)
	var result: Array[Vector2i] = []
	var origin: Vector2i = instance.get("position", Vector2i.ZERO)
	for y in range(shape.y):
		for x in range(shape.x):
			result.append(origin + Vector2i(x, y))
	return result

func place_module(module_id: String, position: Vector2i, exterior: bool = false) -> Dictionary:
	var definition := module_definition(module_id)
	if definition.is_empty():
		return {"ok": false, "reason": "unknown module"}
	var instance := module_instance(module_id, position, exterior)
	for cell in occupied_cells(instance):
		if cell.x < 0 or cell.x >= GRID_WIDTH or cell.y < 0 or cell.y >= GRID_HEIGHT:
			return {"ok": false, "reason": "module is outside the chassis grid"}
		if _cell_occupied(cell):
			return {"ok": false, "reason": "module overlaps an existing module"}
	if exterior and not _has_exterior_capacity():
		return {"ok": false, "reason": "exterior mount capacity exceeded"}
	if total_mass() + int(definition.get("mass", 0)) > BASE_MASS_LIMIT:
		return {"ok": false, "reason": "mass limit exceeded"}
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
			return int(instance.get("durability", 0)) > 0 and not bool(instance.get("sealed", false)) and total_power_draw() <= total_power_output()
	return false

func _recalculate() -> void:
	heat = total_heat()
	if heat > BASE_HEAT_LIMIT:
		log.append("Heat warning: the fortress is above its safe operating limit.")

func travel(route_id: String) -> Dictionary:
	var route: Dictionary = ROUTES.get(route_id, {})
	if route.is_empty():
		return {"ok": false, "reason": "unknown route"}
	if fuel < int(route.get("fuel", 0)):
		return {"ok": false, "reason": "not enough fuel"}
	if not _has_engine():
		return {"ok": false, "reason": "no operational engine"}
	fuel -= int(route.get("fuel", 0))
	day += int(route.get("days", 0))
	money += int(route.get("reward", 0))
	var risk := clampf(float(route.get("risk", 0.0)) + route_risk_modifier, 0.0, 0.95)
	var threat := _deterministic_threat(route_id)
	log.append("Travelled %s; risk %.2f; forecast %s." % [String(route.get("name", route_id)), risk, threat])
	return {"ok": true, "days": int(route.get("days", 0)), "risk": risk, "threat": threat, "summary": summary()}

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
		log.append("Shifted power priority to %s." % power_priority)
		return {"ok": true, "intervention": intervention_id, "summary": summary()}
	if intervention_id == "seal_compartment":
		var sealed := _set_sealed(target_module, true)
		if not sealed:
			return {"ok": false, "reason": "target module not found"}
		command_points -= 1
		log.append("Sealed %s to contain damage." % target_module)
		_recalculate()
		return {"ok": true, "intervention": intervention_id, "summary": summary()}
	if intervention_id == "vent_heat":
		command_points -= 1
		heat = maxi(0, heat - 3)
		log.append("Vented heat; exterior exposure increased temporarily.")
		return {"ok": true, "intervention": intervention_id, "summary": summary()}
	if intervention_id == "cut_loose_cargo":
		var removed := _remove_first_tagged("cargo")
		if not removed:
			return {"ok": false, "reason": "no cargo to cut loose"}
		command_points -= 1
		log.append("Cut loose cargo to protect the fortress.")
		_recalculate()
		return {"ok": true, "intervention": intervention_id, "summary": summary()}
	return {"ok": false, "reason": "unknown intervention"}

func repair_module(module_id: String, amount: int = 1) -> Dictionary:
	if not _has_tag("workshop"):
		return {"ok": false, "reason": "no workshop installed"}
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
		"can_travel": _has_engine() and fuel > 0 and not encounter_active,
		"power_stable": total_power_draw() <= total_power_output()
	}

func serialize() -> Dictionary:
	return {
		"seed": seed,
		"day": day,
		"fuel": fuel,
		"money": money,
		"command_points": command_points,
		"heat": heat,
		"hull_condition": hull_condition,
		"current_location": current_location,
		"route_risk_modifier": route_risk_modifier,
		"target_doctrine": target_doctrine,
		"power_priority": power_priority,
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
		"modules": modules.duplicate(true),
		"log": log.duplicate()
	}

func load_serialized(data: Dictionary) -> void:
	seed = int(data.get("seed", seed))
	day = int(data.get("day", day))
	fuel = int(data.get("fuel", fuel))
	money = int(data.get("money", money))
	command_points = int(data.get("command_points", command_points))
	heat = int(data.get("heat", heat))
	hull_condition = int(data.get("hull_condition", hull_condition))
	current_location = String(data.get("current_location", current_location))
	route_risk_modifier = float(data.get("route_risk_modifier", route_risk_modifier))
	target_doctrine = String(data.get("target_doctrine", target_doctrine))
	power_priority = String(data.get("power_priority", power_priority))
	journey_node = String(data.get("journey_node", journey_node))
	journey_destination = String(data.get("journey_destination", journey_destination))
	journey_route = String(data.get("journey_route", journey_route))
	journey_complete = bool(data.get("journey_complete", journey_complete))
	encounter_active = bool(data.get("encounter_active", encounter_active))
	encounter_step = int(data.get("encounter_step", encounter_step))
	encounter_progress = float(data.get("encounter_progress", encounter_progress))
	encounter_enemies = data.get("encounter_enemies", []).duplicate(true)
	encounter_report = data.get("encounter_report", []).duplicate()
	encounter_outcome = String(data.get("encounter_outcome", encounter_outcome))
	encounter_intervention_used = bool(data.get("encounter_intervention_used", encounter_intervention_used))
	encounter_target_doctrine = String(data.get("encounter_target_doctrine", encounter_target_doctrine))
	modules = data.get("modules", []).duplicate(true)
	log = data.get("log", []).duplicate()
	_recalculate()

func begin_journey(route_id: String, doctrine: String = "protect_cargo") -> Dictionary:
	if encounter_active:
		return {"ok": false, "reason": "an encounter is already active"}
	if journey_complete:
		return {"ok": false, "reason": "this journey is already complete; reset the run to depart again"}
	var travel_result: Dictionary = travel(route_id)
	if not bool(travel_result.get("ok", false)):
		return travel_result
	journey_route = route_id
	journey_node = "rill_crossing" if route_id == "safe_road" else "morrowline_camp"
	current_location = journey_node
	encounter_target_doctrine = doctrine
	encounter_active = true
	encounter_step = 0
	encounter_progress = 0.0
	encounter_outcome = ""
	encounter_intervention_used = false
	encounter_enemies.clear()
	encounter_report.clear()
	var composition: Array = JOURNEY_ENCOUNTERS.get(route_id, ["road_raiders"])
	for index in range(composition.size()):
		var enemy_id: String = String(composition[index])
		var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
		encounter_enemies.append({"id": enemy_id, "hp": int(definition.health), "max_hp": int(definition.health), "target": "", "arrived": false, "defeated": false, "damage_taken": 0, "attacks": 0, "slot": index})
	_encounter_log("Forecast: %s from %s. Protect doctrine: %s." % [_encounter_names(), String(ROUTES[route_id].name), doctrine.replace("_", " ")])
	_encounter_log("Route: %s. The fortress is between Ashgate Depot and Morrowline Camp." % String(JOURNEY_NODES[journey_node].name))
	return {"ok": true, "route": route_id, "forecast": encounter_forecast(), "encounter": encounter_summary(), "summary": summary()}

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
	var signal_ready: bool = _has_operational_tag("forecast")
	return {"node": journey_node, "destination": journey_destination, "route": journey_route, "threat_ids": threat_ids, "threats": threat_names, "target_class": exact_target, "exact_target_revealed": signal_ready, "signal_ready": signal_ready}

func _has_operational_tag(tag: String) -> bool:
	for instance in modules:
		var definition: Dictionary = module_definition(String(instance.get("id", "")))
		if tag in definition.get("tags", []) and int(instance.get("durability", 0)) > 0 and not bool(instance.get("sealed", false)):
			return true
	return false

func _encounter_module_damage(enemy_id: String) -> Dictionary:
	var total_damage: int = 0
	var attackers: Array[String] = []
	var behavior_lines: Array[String] = []
	if total_power_draw() > total_power_output():
		return {"damage": 0, "attackers": attackers, "lines": ["Power is unstable; weapon modules cannot complete their firing cycle."]}
	for instance in modules:
		if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
			continue
		var module_id: String = String(instance.get("id", ""))
		var definition: Dictionary = module_definition(module_id)
		var damage: int = 0
		if module_id == "shell_cannon":
			damage = 3 if enemy_id in ["road_raiders", "siege_beast"] else 1
			if power_priority == "weapons":
				damage += 1
			behavior_lines.append("Shell Cannon fires a burst into the %s." % ENCOUNTER_ENEMIES[enemy_id].name)
		elif module_id == "repeater_gun":
			damage = 2 if enemy_id in ["road_raiders", "climbers"] else 1
			behavior_lines.append("Repeater Gun suppresses the %s advance." % ENCOUNTER_ENEMIES[enemy_id].name)
		elif module_id == "wall_lamp" and enemy_id == "climbers":
			damage = 2
			behavior_lines.append("Wall Lamp exposes the climber’s route.")
		if damage > 0:
			attackers.append(module_id)
			total_damage += damage
	return {"damage": total_damage, "attackers": attackers, "lines": behavior_lines}

func _encounter_choose_target(enemy_id: String) -> String:
	var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
	var target_tags: Array = definition.get("target_tags", [])
	var best_index: int = -1
	var best_durability: int = 999
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if int(instance.get("durability", 0)) <= 0 or bool(instance.get("sealed", false)):
			continue
		var module_def: Dictionary = module_definition(String(instance.get("id", "")))
		var matched: bool = false
		for tag in target_tags:
			if tag in module_def.get("tags", []):
				matched = true
		if matched and int(instance.get("durability", 0)) < best_durability:
			best_index = index
			best_durability = int(instance.get("durability", 0))
	if best_index >= 0:
		return String(modules[best_index].get("id", ""))
	return "hull"

func _encounter_apply_enemy_damage(enemy_id: String, target_id: String) -> int:
	var definition: Dictionary = ENCOUNTER_ENEMIES[enemy_id]
	var damage: int = int(definition.damage)
	if target_id == "hull":
		hull_condition = maxi(0, hull_condition - damage)
		_encounter_log("%s reaches the hull for %d damage; no matching module remains." % [definition.name, damage])
		return damage
	for index in range(modules.size()):
		var instance: Dictionary = modules[index]
		if String(instance.get("id", "")) != target_id:
			continue
		var module_def: Dictionary = module_definition(target_id)
		if target_id == "front_armor_plate" and enemy_id == "siege_beast":
			damage = maxi(1, damage - 1)
		instance["durability"] = maxi(0, int(instance.get("durability", 0)) - damage)
		modules[index] = instance
		_encounter_log("%s hits %s for %d; durability is %d." % [definition.name, module_def.name, damage, int(instance.durability)])
		_recalculate()
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
		var result: Dictionary = repair_module(weakest_id, 1)
		if bool(result.get("ok", false)):
			_encounter_log("Field Workshop restores %s by one durability." % module_definition(weakest_id).name)

func _finish_encounter() -> Dictionary:
	encounter_active = false
	encounter_progress = 1.0
	var engine_alive: bool = _has_engine()
	if hull_condition <= 0 or not engine_alive:
		encounter_outcome = "forced_retreat"
		journey_node = "ashgate_depot"
		current_location = journey_node
		_encounter_log("Outcome: forced retreat. Ashgate Depot is still behind the fortress; recover before attempting the road again.")
	else:
		journey_node = journey_destination
		current_location = journey_node
		journey_complete = true
		if hull_condition >= 7:
			encounter_outcome = "protected_arrival"
			money += 24
			_encounter_log("Outcome: protected arrival. Morrowline Camp receives the fortress and awards 24 Ashmarks.")
		else:
			encounter_outcome = "damaged_arrival"
			money += 12
			_encounter_log("Outcome: damaged arrival. Morrowline Camp is reached, but only 12 Ashmarks remain available.")
	return {"ok": true, "resolved": true, "outcome": encounter_outcome, "report": encounter_report.duplicate(), "summary": summary()}

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
			_encounter_log("%s takes %d damage from %s." % [ENCOUNTER_ENEMIES[enemy_id].name, damage, ", ".join(attack_result.get("attackers", []))])
			for line in attack_result.get("lines", []):
				_encounter_log(String(line))
		if int(enemy.get("hp", 0)) <= 0:
			enemy["defeated"] = true
			_encounter_log("%s is stopped before contact." % ENCOUNTER_ENEMIES[enemy_id].name)
			encounter_enemies[index] = enemy
			continue
		if encounter_step >= int(ENCOUNTER_ENEMIES[enemy_id].arrival_step):
			enemy["arrived"] = true
			if String(enemy.get("target", "")).is_empty():
				enemy["target"] = _encounter_choose_target(enemy_id)
				_encounter_log("%s reaches the fortress; target is %s." % [ENCOUNTER_ENEMIES[enemy_id].name, String(enemy.target)])
			if not String(enemy.get("target", "")).is_empty():
				enemy["attacks"] = int(enemy.get("attacks", 0)) + 1
				_encounter_apply_enemy_damage(enemy_id, String(enemy.target))
		encounter_enemies[index] = enemy
	_encounter_repair()
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
	var result: Dictionary = intervene(intervention_id, target_module)
	if bool(result.get("ok", false)):
		encounter_intervention_used = true
		_encounter_log("Intervention: %s." % intervention_id.replace("_", " ").capitalize())
	return result

func _all_encounter_enemies_defeated() -> bool:
	if encounter_enemies.is_empty():
		return false
	for enemy in encounter_enemies:
		if not bool(enemy.get("defeated", false)):
			return false
	return true

func encounter_summary() -> Dictionary:
	return {"active": encounter_active, "step": encounter_step, "progress": encounter_progress, "outcome": encounter_outcome, "intervention_used": encounter_intervention_used, "forecast": encounter_forecast(), "enemies": encounter_enemies.duplicate(true), "report": encounter_report.duplicate()}

func _cell_occupied(cell: Vector2i) -> bool:
	for instance in modules:
		if cell in occupied_cells(instance):
			return true
	return false

func _has_exterior_capacity() -> bool:
	var count := 0
	for instance in modules:
		if bool(instance.get("exterior", false)):
			count += 1
	return count < 2

func _has_engine() -> bool:
	for instance in modules:
		var definition := module_definition(String(instance.get("id", "")))
		if "engine" in definition.get("tags", []) and int(instance.get("durability", 0)) > 0:
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

func _remove_first_tagged(tag: String) -> bool:
	for index in range(modules.size()):
		var definition := module_definition(String(modules[index].get("id", "")))
		if tag in definition.get("tags", []):
			modules.remove_at(index)
			return true
	return false

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
