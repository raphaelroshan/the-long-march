class_name FortressSilhouette
extends RefCounted

const FAMILY_COLORS := {
	"engine": Color("#bd7149"),
	"weapon": Color("#bd5550"),
	"power": Color("#a78845"),
	"workshop": Color("#c19b55"),
	"crew_room": Color("#668baa"),
	"armor": Color("#79858c"),
	"cargo": Color("#9d7650"),
	"signal": Color("#62a89d"),
	"sustain": Color("#5795a0")
}

const DEFAULT_FAMILIES := ["engine", "cargo", "power", "crew_room", "workshop", "weapon", "signal"]

static func presentation_slots(modules: Array) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	var seen: Dictionary = {}
	for raw_module in modules:
		var module: Dictionary = raw_module
		var family := String(module.get("family", "cargo"))
		if seen.has(family):
			var existing_index := int(seen[family])
			var existing: Dictionary = slots[existing_index]
			if _state_priority(String(module.get("state", "ready"))) > _state_priority(String(existing.get("state", "ready"))):
				existing["state"] = String(module.get("state", "ready"))
			existing["damaged"] = bool(existing.get("damaged", false)) or bool(module.get("damaged", false))
			existing["sealed"] = bool(existing.get("sealed", false)) or bool(module.get("sealed", false))
			existing["targeted"] = bool(existing.get("targeted", false)) or bool(module.get("targeted", false))
			existing["selected"] = bool(existing.get("selected", false)) or bool(module.get("selected", false))
			existing["repaired"] = bool(existing.get("repaired", false)) or bool(module.get("repaired", false))
			slots[existing_index] = existing
			continue
		seen[family] = slots.size()
		slots.append({
			"id": String(module.get("id", family)),
			"family": family,
			"state": String(module.get("state", "ready")),
			"damaged": bool(module.get("damaged", false)),
			"sealed": bool(module.get("sealed", false)),
			"targeted": bool(module.get("targeted", false)),
			"selected": bool(module.get("selected", false)),
			"repaired": bool(module.get("repaired", false))
		})
		if slots.size() == 7:
			break
	if slots.is_empty():
		for family in DEFAULT_FAMILIES:
			slots.append({"id": family, "family": family, "state": "ready", "damaged": false, "sealed": false, "targeted": false, "selected": false, "repaired": false})
	return slots

static func primary_condition(slot: Dictionary) -> String:
	var state_name := String(slot.get("state", "ready"))
	if state_name == "offline" and bool(slot.get("damaged", false)):
		return "breached"
	if state_name == "offline":
		return "disabled"
	if bool(slot.get("damaged", false)):
		return "damaged"
	if state_name == "strained":
		return "strained"
	if bool(slot.get("sealed", false)):
		return "protected"
	if bool(slot.get("repaired", false)):
		return "repaired"
	return "ready"

static func visual_signature(view: Dictionary) -> Dictionary:
	var region_id := String(view.get("region_id", "ashgate_lowlands"))
	var heat := int(view.get("heat", 0))
	var heat_limit := int(view.get("heat_limit", 6))
	return {
		"region_id": region_id,
		"place_treatment": "rain_waterworks" if region_id == "flooded_veyru" else "dust_industry",
		"mode": String(view.get("mode", "rest")),
		"overheated": heat > heat_limit,
		"heat": heat,
		"heat_limit": heat_limit,
		"motion_profile": mode_treatment(String(view.get("mode", "rest"))).get("motion", "settled"),
		"stance": mode_treatment(String(view.get("mode", "rest"))).get("stance", "service")
	}

static func mode_treatment(mode: String) -> Dictionary:
	match mode:
		"departing":
			return {"motion": "gathering", "stance": "forward"}
		"travel", "traveling":
			return {"motion": "marching", "stance": "forward"}
		"retreating":
			return {"motion": "limping", "stance": "rearward"}
		"contact":
			return {"motion": "braced", "stance": "combat"}
		"event":
			return {"motion": "halted", "stance": "watchful"}
		"debrief":
			return {"motion": "settled", "stance": "scarred"}
		_:
			return {"motion": "settled", "stance": "service"}

static func draw(canvas: CanvasItem, bounds: Rect2, view: Dictionary = {}) -> Dictionary:
	var high_contrast := bool(view.get("high_contrast", false))
	var mode := String(view.get("mode", "rest"))
	var travel_phase := float(view.get("travel_phase", 0.0))
	var impact := float(view.get("impact", 0.0))
	var damaged_count := int(view.get("damaged_count", 0))
	var offline_count := int(view.get("offline_count", 0))
	var signature := visual_signature(view)
	var flooded := String(signature.get("region_id", "ashgate_lowlands")) == "flooded_veyru"
	var overheated := bool(signature.get("overheated", false))
	var metal := Color("#343a39") if high_contrast else (Color("#414c49") if flooded else Color("#4b4740"))
	var dark_metal := Color("#171d1e") if high_contrast else Color("#2b302f")
	var edge := Color("#f2dda2") if high_contrast else (Color("#86a9a3") if flooded else Color("#a98b59"))
	var warm := Color("#ffd47f") if high_contrast else Color("#dfa759")
	var body := Rect2(bounds.position + Vector2(bounds.size.x * 0.12, bounds.size.y * 0.28), Vector2(bounds.size.x * 0.76, bounds.size.y * 0.43))
	body.position += Vector2(-impact * 5.0, impact * 2.0)
	var roof := Rect2(body.position + Vector2(body.size.x * 0.12, -body.size.y * 0.26), Vector2(body.size.x * 0.34, body.size.y * 0.27))
	_draw_ground_shadow(canvas, body, mode, impact)
	var lower_hull := PackedVector2Array([
		body.position + Vector2(0, body.size.y * 0.78),
		body.position + Vector2(body.size.x, body.size.y * 0.78),
		body.end - Vector2(body.size.x * 0.08, 0),
		body.position + Vector2(body.size.x * 0.08, body.size.y)
	])
	canvas.draw_colored_polygon(lower_hull, dark_metal)
	canvas.draw_polyline(PackedVector2Array([lower_hull[0], lower_hull[1], lower_hull[2], lower_hull[3], lower_hull[0]]), edge, 3.0)
	canvas.draw_rect(body, metal, true)
	canvas.draw_rect(body, edge, false, 4.0)
	_draw_hull_profile(canvas, body, metal, dark_metal, edge)
	canvas.draw_rect(roof, dark_metal, true)
	canvas.draw_rect(roof, edge, false, 3.0)
	_draw_material_layers(canvas, body, roof, edge, dark_metal, flooded, high_contrast)
	_draw_rivets(canvas, body, edge.darkened(0.12))
	var moving := mode in ["departing", "travel", "traveling", "retreating"]
	_draw_legs(canvas, body, edge, dark_metal, travel_phase if moving else 0.0)
	_draw_stack(canvas, roof, edge, travel_phase if moving else 0.0, overheated)
	_draw_signal_mast(canvas, body, edge, high_contrast)
	_draw_forward_weapon(canvas, body, edge)
	var slots := presentation_slots(view.get("modules", []))
	var slot_gap := 5.0
	var slot_width := (body.size.x - 28.0 - slot_gap * float(slots.size() - 1)) / float(maxi(1, slots.size()))
	var slot_height := body.size.y * 0.34
	var anchors: Dictionary = {"hull": body.get_center()}
	var breached_families := 0
	for index in range(slots.size()):
		var slot: Dictionary = slots[index]
		if primary_condition(slot) == "breached":
			breached_families += 1
		var slot_rect := Rect2(body.position + Vector2(14.0 + float(index) * (slot_width + slot_gap), body.size.y * 0.34), Vector2(slot_width, slot_height))
		_draw_module_slot(canvas, slot_rect, slot, high_contrast, warm)
		_draw_module_activity(canvas, slot_rect, slot, travel_phase, high_contrast)
		anchors[String(slot.get("id", ""))] = slot_rect.get_center()
		anchors[String(slot.get("family", ""))] = slot_rect.get_center()
	_draw_region_wear(canvas, body, flooded, overheated, high_contrast)
	_draw_mode_cues(canvas, body, mode, travel_phase, impact, high_contrast)
	if breached_families > 0:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 96, 18), "%d BREACH" % breached_families, HORIZONTAL_ALIGNMENT_RIGHT, 86, 10, Color("#ff9a8d"))
	elif offline_count > 0:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 96, 18), "%d OFFLINE" % offline_count, HORIZONTAL_ALIGNMENT_RIGHT, 86, 10, Color("#ff9a8d"))
	elif overheated:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 96, 18), "OVERHEAT", HORIZONTAL_ALIGNMENT_RIGHT, 86, 10, Color("#ffb36f"))
	elif damaged_count > 0:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 96, 18), "%d DAMAGED" % damaged_count, HORIZONTAL_ALIGNMENT_RIGHT, 86, 10, Color("#f0c27b"))
	else:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 78, 18), "READY", HORIZONTAL_ALIGNMENT_RIGHT, 68, 9, Color("#9fddbd"))
	return {"body": body, "anchors": anchors}

static func _draw_ground_shadow(canvas: CanvasItem, body: Rect2, mode: String, impact: float) -> void:
	var moving := mode in ["departing", "travel", "traveling", "retreating"]
	var shadow_y := body.end.y + body.size.y * 0.41
	var inset := body.size.x * (0.08 if moving else 0.02)
	var shadow := PackedVector2Array([
		Vector2(body.position.x + inset, shadow_y),
		Vector2(body.end.x - inset, shadow_y),
		Vector2(body.end.x - body.size.x * 0.18, shadow_y + 12.0 + impact * 3.0),
		Vector2(body.position.x + body.size.x * 0.18, shadow_y + 12.0 + impact * 3.0)
	])
	canvas.draw_colored_polygon(shadow, Color(0.02, 0.025, 0.025, 0.55))

static func _draw_hull_profile(canvas: CanvasItem, body: Rect2, metal: Color, dark_metal: Color, edge: Color) -> void:
	var rear := PackedVector2Array([
		body.position + Vector2(-body.size.x * 0.045, body.size.y * 0.18),
		body.position + Vector2(0, body.size.y * 0.08),
		body.position + Vector2(0, body.size.y * 0.72),
		body.position + Vector2(-body.size.x * 0.035, body.size.y * 0.64)
	])
	canvas.draw_colored_polygon(rear, dark_metal)
	canvas.draw_polyline(PackedVector2Array([rear[0], rear[1], rear[2], rear[3], rear[0]]), edge.darkened(0.12), 2.0)
	var prow := PackedVector2Array([
		body.position + Vector2(body.size.x, body.size.y * 0.12),
		body.position + Vector2(body.size.x * 1.055, body.size.y * 0.25),
		body.position + Vector2(body.size.x * 1.055, body.size.y * 0.68),
		body.position + Vector2(body.size.x, body.size.y * 0.82)
	])
	canvas.draw_colored_polygon(prow, metal.darkened(0.12))
	canvas.draw_polyline(PackedVector2Array([prow[0], prow[1], prow[2], prow[3], prow[0]]), edge, 2.0)
	canvas.draw_line(body.position + Vector2(body.size.x * 0.04, body.size.y * 0.12), body.position + Vector2(body.size.x * 0.96, body.size.y * 0.12), edge.darkened(0.18), 2.0)
	for raw_brace_ratio in [0.28, 0.52, 0.76]:
		var brace_ratio: float = float(raw_brace_ratio)
		var x: float = body.position.x + body.size.x * brace_ratio
		canvas.draw_line(Vector2(x - 12.0, body.end.y - 4.0), Vector2(x + 8.0, body.position.y + body.size.y * 0.79), edge.darkened(0.26), 3.0)

static func _state_priority(state_name: String) -> int:
	if state_name == "offline":
		return 2
	if state_name == "strained":
		return 1
	return 0

static func _draw_rivets(canvas: CanvasItem, body: Rect2, edge: Color) -> void:
	for x_ratio in [0.04, 0.20, 0.80, 0.96]:
		for y_ratio in [0.12, 0.84]:
			canvas.draw_circle(body.position + Vector2(body.size.x * x_ratio, body.size.y * y_ratio), 2.3, edge)

static func _draw_material_layers(canvas: CanvasItem, body: Rect2, roof: Rect2, edge: Color, dark_metal: Color, flooded: bool, high_contrast: bool) -> void:
	var timber := Color("#d5b26d") if high_contrast else Color("#765838")
	var plate := Color("#52615e") if flooded else Color("#5c574d")
	var canvas_cloth := Color("#9a8b67") if flooded else Color("#8a7351")
	canvas.draw_line(body.position + Vector2(body.size.x * 0.04, body.size.y * 0.24), body.position + Vector2(body.size.x * 0.96, body.size.y * 0.24), timber, 5.0)
	canvas.draw_line(body.position + Vector2(body.size.x * 0.08, body.size.y * 0.78), body.position + Vector2(body.size.x * 0.92, body.size.y * 0.78), timber.darkened(0.14), 4.0)
	var rear_housing := Rect2(body.position + Vector2(body.size.x * 0.035, body.size.y * 0.08), Vector2(body.size.x * 0.16, body.size.y * 0.12))
	canvas.draw_rect(rear_housing, dark_metal.lightened(0.07), true)
	canvas.draw_rect(rear_housing, edge.darkened(0.10), false, 2.0)
	for vent_index in range(3):
		var vent_y := rear_housing.position.y + rear_housing.size.y * (0.30 + float(vent_index) * 0.20)
		canvas.draw_line(Vector2(rear_housing.position.x + 7.0, vent_y), Vector2(rear_housing.end.x - 7.0, vent_y), edge.darkened(0.32), 2.0)
	var patch := Rect2(body.position + Vector2(body.size.x * 0.73, body.size.y * 0.07), Vector2(body.size.x * 0.14, body.size.y * 0.13))
	canvas.draw_rect(patch, plate, true)
	canvas.draw_rect(patch, edge.darkened(0.16), false, 2.0)
	canvas.draw_line(patch.position + Vector2(5.0, 4.0), patch.end - Vector2(5.0, 4.0), edge.darkened(0.24), 1.5)
	var awning := PackedVector2Array([
		roof.position + Vector2(roof.size.x * 0.05, roof.size.y * 0.18),
		roof.position + Vector2(roof.size.x * 0.95, roof.size.y * 0.18),
		roof.position + Vector2(roof.size.x * 0.87, roof.size.y * 0.78),
		roof.position + Vector2(roof.size.x * 0.12, roof.size.y * 0.78)
	])
	canvas.draw_colored_polygon(awning, canvas_cloth.darkened(0.28))
	canvas.draw_polyline(PackedVector2Array([awning[0], awning[1], awning[2], awning[3], awning[0]]), canvas_cloth, 2.0)

static func _draw_legs(canvas: CanvasItem, body: Rect2, edge: Color, metal: Color, travel_phase: float) -> void:
	for index in range(4):
		var leg_x := body.position.x + body.size.x * (0.16 + float(index) * 0.225)
		var stride := sin(travel_phase * 0.06 + float(index) * 1.4) * body.size.x * 0.045 if travel_phase != 0.0 else 0.0
		var knee := Vector2(leg_x + stride * 0.45, body.end.y + body.size.y * 0.20)
		var foot := Vector2(leg_x + stride, body.end.y + body.size.y * 0.40)
		canvas.draw_line(Vector2(leg_x, body.end.y), knee, metal.lightened(0.12), 12.0)
		canvas.draw_line(knee, foot, edge, 9.0)
		canvas.draw_line(foot + Vector2(-body.size.x * 0.045, 0), foot + Vector2(body.size.x * 0.035, 0), edge, 6.0)

static func _draw_stack(canvas: CanvasItem, roof: Rect2, edge: Color, travel_phase: float, overheated: bool) -> void:
	var stack_base := roof.position + Vector2(roof.size.x * 0.30, 0)
	canvas.draw_line(stack_base, stack_base + Vector2(0, -roof.size.y * 0.85), edge, 7.0)
	for smoke_index in range(4 if overheated else 3):
		var drift := fmod(travel_phase * 0.35 + float(smoke_index) * 13.0, 45.0) if travel_phase != 0.0 else float(smoke_index) * 9.0
		var smoke_color := Color(0.48, 0.22, 0.10, 0.42) if overheated else Color(0.10, 0.13, 0.14, 0.34)
		canvas.draw_circle(stack_base + Vector2(-drift, -roof.size.y - 9.0 - float(smoke_index) * 12.0), 7.0 + float(smoke_index) * 2.5, smoke_color)

static func _draw_signal_mast(canvas: CanvasItem, body: Rect2, edge: Color, high_contrast: bool) -> void:
	var base := body.position + Vector2(body.size.x * 0.72, 0)
	canvas.draw_line(base, base + Vector2(0, -body.size.y * 0.42), edge, 4.0)
	canvas.draw_line(base + Vector2(0, -body.size.y * 0.40), base + Vector2(body.size.x * 0.09, -body.size.y * 0.49), Color.WHITE if high_contrast else Color("#8ed8d0"), 3.0)
	canvas.draw_circle(base + Vector2(0, -body.size.y * 0.38), 5.0, Color("#69d8cf"), false, 2.0)

static func _draw_forward_weapon(canvas: CanvasItem, body: Rect2, edge: Color) -> void:
	var mount := Rect2(body.position + Vector2(body.size.x * 0.78, -body.size.y * 0.12), Vector2(body.size.x * 0.13, body.size.y * 0.13))
	canvas.draw_rect(mount, Color("#343a39"), true)
	canvas.draw_rect(mount, edge, false, 2.0)
	canvas.draw_line(mount.position + Vector2(mount.size.x * 0.58, 0), mount.position + Vector2(mount.size.x * 0.95, -body.size.y * 0.22), edge, 5.0)

static func _draw_module_slot(canvas: CanvasItem, rect: Rect2, slot: Dictionary, high_contrast: bool, warm: Color) -> void:
	var family := String(slot.get("family", "cargo"))
	var condition := primary_condition(slot)
	var base: Color = FAMILY_COLORS.get(family, Color("#8b8b8b"))
	var fill := base.darkened(0.66) if condition in ["disabled", "breached"] else (base.lerp(Color("#d59645"), 0.38) if condition == "strained" else base.darkened(0.12))
	if high_contrast and condition == "ready":
		fill = fill.lightened(0.10)
	canvas.draw_rect(rect, fill, true)
	var frame := Color.WHITE if high_contrast else Color("#cdbb91")
	canvas.draw_rect(rect, frame, false, 2.0)
	draw_family_mark(canvas, rect.grow(-4.0), family, Color("#0c1214") if high_contrast else Color("#f7efe0"))
	_draw_condition_mark(canvas, rect, condition, high_contrast, warm)
	if bool(slot.get("selected", false)):
		canvas.draw_rect(rect.grow(3.0), Color("#83e5df"), false, 3.0)
	if bool(slot.get("targeted", false)):
		_draw_target_bracket(canvas, rect.grow(5.0), Color("#ff786b"))

static func _draw_module_activity(canvas: CanvasItem, rect: Rect2, slot: Dictionary, travel_phase: float, high_contrast: bool) -> void:
	var condition := primary_condition(slot)
	if condition not in ["damaged", "breached", "strained"]:
		return
	var pulse := 0.55 + sin(travel_phase * 0.09 + rect.position.x * 0.02) * 0.18
	var activity_color := Color("#fff0ba") if high_contrast else Color("#e99a59")
	activity_color.a = clampf(pulse, 0.28, 0.82)
	canvas.draw_circle(rect.position + Vector2(rect.size.x * 0.78, 5.0), 3.0 if condition == "strained" else 4.5, activity_color)
	if condition in ["damaged", "breached"]:
		for smoke_index in range(2):
			var smoke := Color(0.08, 0.10, 0.10, 0.48 - float(smoke_index) * 0.12)
			canvas.draw_circle(rect.position + Vector2(rect.size.x * 0.76 - float(smoke_index) * 6.0, -5.0 - float(smoke_index) * 9.0), 5.0 + float(smoke_index) * 2.0, smoke)

static func _draw_mode_cues(canvas: CanvasItem, body: Rect2, mode: String, travel_phase: float, impact: float, high_contrast: bool) -> void:
	var accent := Color.WHITE if high_contrast else Color("#d5b06c")
	if mode in ["departing", "travel", "traveling", "retreating"]:
		for dust_index in range(4):
			var drift := fmod(travel_phase * 0.8 + float(dust_index) * 19.0, body.size.x * 0.34)
			var dust_color := Color(0.68, 0.49, 0.28, 0.18 + float(dust_index) * 0.035)
			canvas.draw_circle(Vector2(body.position.x - 8.0 - drift, body.end.y + body.size.y * 0.34), 7.0 + float(dust_index) * 2.0, dust_color)
		canvas.draw_line(body.position + Vector2(-body.size.x * 0.18, body.size.y * 0.25), body.position + Vector2(-8.0, body.size.y * 0.25), accent.darkened(0.34), 2.0)
	if mode == "contact":
		var brace_color := Color("#ff9a8d") if impact > 0.1 else accent
		canvas.draw_line(body.position + Vector2(body.size.x * 0.94, body.size.y * 0.06), body.position + Vector2(body.size.x * 1.08, -body.size.y * 0.04), brace_color, 4.0)
		canvas.draw_line(body.position + Vector2(body.size.x * 0.94, body.size.y * 0.06), body.position + Vector2(body.size.x * 1.09, body.size.y * 0.15), brace_color, 4.0)
	if mode == "rest":
		for lamp_ratio in [0.26, 0.48, 0.70]:
			var lamp := body.position + Vector2(body.size.x * lamp_ratio, body.size.y * 0.18)
			canvas.draw_circle(lamp, 3.5, Color("#ffd47f"))
			canvas.draw_circle(lamp, 8.0, Color(1.0, 0.72, 0.34, 0.08))

static func _draw_condition_mark(canvas: CanvasItem, rect: Rect2, condition: String, high_contrast: bool, warm: Color) -> void:
	var warning := Color("#fff0ba") if high_contrast else Color("#f1c26f")
	var danger := Color("#ff8a7e")
	match condition:
		"breached":
			canvas.draw_line(rect.position + Vector2(5.0, 5.0), rect.end - Vector2(5.0, 5.0), danger, 4.0)
			canvas.draw_line(Vector2(rect.end.x - 5.0, rect.position.y + 5.0), Vector2(rect.position.x + 5.0, rect.end.y - 5.0), danger, 4.0)
		"disabled":
			canvas.draw_line(rect.position + Vector2(7.0, 7.0), rect.end - Vector2(7.0, 7.0), danger, 3.0)
		"damaged":
			var crack := PackedVector2Array([rect.position + Vector2(rect.size.x * 0.72, 3.0), rect.position + Vector2(rect.size.x * 0.55, rect.size.y * 0.40), rect.position + Vector2(rect.size.x * 0.68, rect.size.y * 0.58), rect.position + Vector2(rect.size.x * 0.49, rect.size.y - 3.0)])
			canvas.draw_polyline(crack, warning, 3.0)
		"strained":
			canvas.draw_line(rect.position + Vector2(3.0, 3.0), Vector2(rect.end.x - 3.0, rect.position.y + 3.0), warning, 5.0)
			canvas.draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 16.0, 16.0), "!", HORIZONTAL_ALIGNMENT_CENTER, 12.0, 13, warning)
		"protected":
			canvas.draw_rect(rect.grow(-4.0), warm, false, 3.0)
		"repaired":
			for stitch_index in range(3):
				var stitch_x := rect.position.x + rect.size.x * (0.34 + float(stitch_index) * 0.16)
				canvas.draw_line(Vector2(stitch_x - 3.0, rect.end.y - 5.0), Vector2(stitch_x + 3.0, rect.end.y - 10.0), Color("#9fddbd"), 2.0)

static func _draw_target_bracket(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	var length := minf(rect.size.x, rect.size.y) * 0.25
	var corners: Array[Vector2] = [Vector2(0, 0), Vector2(rect.size.x, 0), Vector2(0, rect.size.y), Vector2(rect.size.x, rect.size.y)]
	for corner: Vector2 in corners:
		var point: Vector2 = rect.position + corner
		var x_sign := 1.0 if corner.x == 0.0 else -1.0
		var y_sign := 1.0 if corner.y == 0.0 else -1.0
		canvas.draw_line(point, point + Vector2(length * x_sign, 0), color, 3.0)
		canvas.draw_line(point, point + Vector2(0, length * y_sign), color, 3.0)

static func _draw_region_wear(canvas: CanvasItem, body: Rect2, flooded: bool, overheated: bool, high_contrast: bool) -> void:
	if flooded:
		var water := Color("#9fe5df") if high_contrast else Color("#4b8784")
		canvas.draw_line(body.position + Vector2(body.size.x * 0.03, body.size.y * 0.88), body.position + Vector2(body.size.x * 0.97, body.size.y * 0.88), water, 3.0)
		for rain_index in range(5):
			var x := body.position.x + body.size.x * (0.18 + float(rain_index) * 0.16)
			canvas.draw_line(Vector2(x, body.position.y + 8.0), Vector2(x - 7.0, body.position.y + body.size.y * 0.18), water.darkened(0.24), 2.0)
	else:
		var dust := Color("#f0c27b") if high_contrast else Color("#8a6841")
		for dust_index in range(4):
			var x := body.position.x + body.size.x * (0.14 + float(dust_index) * 0.22)
			canvas.draw_line(Vector2(x, body.end.y - 8.0), Vector2(x + body.size.x * 0.08, body.end.y - 3.0), dust.darkened(0.18), 3.0)
	if overheated:
		var heat_color := Color("#ffb36f")
		for heat_index in range(3):
			var heat_x := body.position.x + body.size.x * (0.20 + float(heat_index) * 0.07)
			canvas.draw_arc(Vector2(heat_x, body.position.y + body.size.y * 0.18), 5.0 + float(heat_index) * 2.0, PI, TAU, 10, heat_color, 2.0)

static func draw_family_mark(canvas: CanvasItem, rect: Rect2, family: String, ink: Color) -> void:
	var center := rect.get_center()
	var scale := minf(rect.size.x, rect.size.y)
	match family:
		"engine":
			canvas.draw_circle(center, scale * 0.22, ink, false, 2.0)
			for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
				canvas.draw_line(center, center + Vector2(cos(angle), sin(angle)) * scale * 0.22, ink, 2.0)
		"weapon":
			canvas.draw_rect(Rect2(center - Vector2(scale * 0.20, scale * 0.10), Vector2(scale * 0.27, scale * 0.20)), ink, false, 2.0)
			canvas.draw_line(center + Vector2(scale * 0.05, -scale * 0.08), center + Vector2(scale * 0.31, -scale * 0.24), ink, 3.0)
		"power":
			var bolt := PackedVector2Array([center + Vector2(scale * 0.04, -scale * 0.28), center + Vector2(-scale * 0.15, scale * 0.02), center + Vector2(-scale * 0.01, scale * 0.02), center + Vector2(-scale * 0.08, scale * 0.28), center + Vector2(scale * 0.18, -scale * 0.07), center + Vector2(scale * 0.03, -scale * 0.07), center + Vector2(scale * 0.04, -scale * 0.28)])
			canvas.draw_polyline(bolt, ink, 3.0)
		"signal":
			canvas.draw_line(center + Vector2(0, scale * 0.24), center - Vector2(0, scale * 0.24), ink, 2.0)
			canvas.draw_arc(center - Vector2(0, scale * 0.10), scale * 0.17, -PI * 0.85, -PI * 0.15, 10, ink, 2.0)
		"crew_room":
			canvas.draw_circle(center - Vector2(scale * 0.12, scale * 0.05), scale * 0.08, ink)
			canvas.draw_circle(center + Vector2(scale * 0.12, scale * 0.05), scale * 0.08, ink)
			canvas.draw_line(center + Vector2(-scale * 0.22, scale * 0.20), center + Vector2(scale * 0.22, scale * 0.20), ink, 3.0)
		"workshop":
			canvas.draw_line(center + Vector2(-scale * 0.22, scale * 0.20), center + Vector2(scale * 0.20, -scale * 0.22), ink, 4.0)
			canvas.draw_line(center + Vector2(-scale * 0.18, -scale * 0.14), center + Vector2(scale * 0.16, scale * 0.20), ink, 3.0)
		"armor":
			var shield := PackedVector2Array([center + Vector2(0, -scale * 0.25), center + Vector2(scale * 0.24, -scale * 0.12), center + Vector2(scale * 0.16, scale * 0.20), center + Vector2(0, scale * 0.29), center + Vector2(-scale * 0.16, scale * 0.20), center + Vector2(-scale * 0.24, -scale * 0.12)])
			canvas.draw_polyline(PackedVector2Array([shield[0], shield[1], shield[2], shield[3], shield[4], shield[5], shield[0]]), ink, 2.0)
		"sustain":
			canvas.draw_arc(center, scale * 0.20, 0, TAU, 18, ink, 2.0)
			canvas.draw_line(center - Vector2(scale * 0.20, 0), center + Vector2(scale * 0.20, 0), ink, 2.0)
		_:
			canvas.draw_rect(Rect2(center - Vector2(scale * 0.20, scale * 0.18), Vector2(scale * 0.40, scale * 0.36)), ink, false, 2.0)
			canvas.draw_line(center - Vector2(scale * 0.20, scale * 0.18), center + Vector2(scale * 0.20, scale * 0.18), ink, 2.0)
