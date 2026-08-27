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
		"module_count": modules.size(),
		"can_travel": _has_engine() and fuel > 0,
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
	modules = data.get("modules", []).duplicate(true)
	log = data.get("log", []).duplicate()
	_recalculate()

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
