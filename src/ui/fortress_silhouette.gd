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
			slots[existing_index] = existing
			continue
		seen[family] = slots.size()
		slots.append({
			"id": String(module.get("id", family)),
			"family": family,
			"state": String(module.get("state", "ready")),
			"damaged": bool(module.get("damaged", false)),
			"sealed": bool(module.get("sealed", false)),
			"targeted": bool(module.get("targeted", false))
		})
		if slots.size() == 7:
			break
	if slots.is_empty():
		for family in DEFAULT_FAMILIES:
			slots.append({"id": family, "family": family, "state": "ready", "damaged": false, "sealed": false, "targeted": false})
	return slots

static func draw(canvas: CanvasItem, bounds: Rect2, view: Dictionary = {}) -> Dictionary:
	var high_contrast := bool(view.get("high_contrast", false))
	var mode := String(view.get("mode", "rest"))
	var travel_phase := float(view.get("travel_phase", 0.0))
	var impact := float(view.get("impact", 0.0))
	var damaged_count := int(view.get("damaged_count", 0))
	var offline_count := int(view.get("offline_count", 0))
	var metal := Color("#343a39") if high_contrast else Color("#4b4a41")
	var dark_metal := Color("#171d1e") if high_contrast else Color("#2b302f")
	var edge := Color("#f2dda2") if high_contrast else Color("#a38a5d")
	var warm := Color("#ffd47f") if high_contrast else Color("#dfa759")
	var body := Rect2(bounds.position + Vector2(bounds.size.x * 0.12, bounds.size.y * 0.28), Vector2(bounds.size.x * 0.76, bounds.size.y * 0.43))
	body.position += Vector2(-impact * 5.0, impact * 2.0)
	var roof := Rect2(body.position + Vector2(body.size.x * 0.12, -body.size.y * 0.26), Vector2(body.size.x * 0.34, body.size.y * 0.27))
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
	canvas.draw_rect(roof, dark_metal, true)
	canvas.draw_rect(roof, edge, false, 3.0)
	_draw_rivets(canvas, body, edge.darkened(0.12))
	_draw_legs(canvas, body, edge, dark_metal, travel_phase if mode == "travel" else 0.0)
	_draw_stack(canvas, roof, edge, travel_phase if mode == "travel" else 0.0)
	_draw_signal_mast(canvas, body, edge, high_contrast)
	_draw_forward_weapon(canvas, body, edge)
	var slots := presentation_slots(view.get("modules", []))
	var slot_gap := 5.0
	var slot_width := (body.size.x - 28.0 - slot_gap * float(slots.size() - 1)) / float(maxi(1, slots.size()))
	var slot_height := body.size.y * 0.34
	var anchors: Dictionary = {"hull": body.get_center()}
	for index in range(slots.size()):
		var slot: Dictionary = slots[index]
		var slot_rect := Rect2(body.position + Vector2(14.0 + float(index) * (slot_width + slot_gap), body.size.y * 0.34), Vector2(slot_width, slot_height))
		_draw_module_slot(canvas, slot_rect, slot, high_contrast, warm)
		anchors[String(slot.get("id", ""))] = slot_rect.get_center()
		anchors[String(slot.get("family", ""))] = slot_rect.get_center()
	if offline_count > 0:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 88, 18), "%d OFFLINE" % offline_count, HORIZONTAL_ALIGNMENT_RIGHT, 78, 10, Color("#ff9a8d"))
	elif damaged_count > 0:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 88, 18), "%d DAMAGED" % damaged_count, HORIZONTAL_ALIGNMENT_RIGHT, 78, 10, Color("#f0c27b"))
	else:
		canvas.draw_string(ThemeDB.fallback_font, body.position + Vector2(body.size.x - 78, 18), "READY", HORIZONTAL_ALIGNMENT_RIGHT, 68, 9, Color("#9fddbd"))
	return {"body": body, "anchors": anchors}

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

static func _draw_legs(canvas: CanvasItem, body: Rect2, edge: Color, metal: Color, travel_phase: float) -> void:
	for index in range(4):
		var leg_x := body.position.x + body.size.x * (0.16 + float(index) * 0.225)
		var stride := sin(travel_phase * 0.06 + float(index) * 1.4) * body.size.x * 0.045 if travel_phase != 0.0 else 0.0
		var knee := Vector2(leg_x + stride * 0.45, body.end.y + body.size.y * 0.20)
		var foot := Vector2(leg_x + stride, body.end.y + body.size.y * 0.40)
		canvas.draw_line(Vector2(leg_x, body.end.y), knee, metal.lightened(0.12), 12.0)
		canvas.draw_line(knee, foot, edge, 9.0)
		canvas.draw_line(foot + Vector2(-body.size.x * 0.045, 0), foot + Vector2(body.size.x * 0.035, 0), edge, 6.0)

static func _draw_stack(canvas: CanvasItem, roof: Rect2, edge: Color, travel_phase: float) -> void:
	var stack_base := roof.position + Vector2(roof.size.x * 0.30, 0)
	canvas.draw_line(stack_base, stack_base + Vector2(0, -roof.size.y * 0.85), edge, 7.0)
	for smoke_index in range(3):
		var drift := fmod(travel_phase * 0.35 + float(smoke_index) * 13.0, 45.0) if travel_phase != 0.0 else float(smoke_index) * 9.0
		canvas.draw_circle(stack_base + Vector2(-drift, -roof.size.y - 9.0 - float(smoke_index) * 12.0), 7.0 + float(smoke_index) * 2.5, Color(0.10, 0.13, 0.14, 0.34))

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
	var state_name := String(slot.get("state", "ready"))
	var base: Color = FAMILY_COLORS.get(family, Color("#8b8b8b"))
	var fill := base.darkened(0.60) if state_name == "offline" else (base.lerp(Color("#d59645"), 0.42) if state_name == "strained" else base)
	if high_contrast and state_name == "ready":
		fill = fill.lightened(0.10)
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, Color.WHITE if high_contrast else Color("#dbc99f"), false, 2.0)
	draw_family_mark(canvas, rect, family, Color("#0c1214") if high_contrast else Color("#f7efe0"))
	if bool(slot.get("damaged", false)):
		var crack := PackedVector2Array([rect.position + Vector2(rect.size.x * 0.68, 2), rect.position + Vector2(rect.size.x * 0.52, rect.size.y * 0.38), rect.position + Vector2(rect.size.x * 0.66, rect.size.y * 0.58), rect.position + Vector2(rect.size.x * 0.47, rect.size.y - 2)])
		canvas.draw_polyline(crack, Color("#ffd28e"), 2.0)
	if bool(slot.get("sealed", false)):
		canvas.draw_rect(rect.grow(-3), Color("#f0d28f"), false, 3.0)
		canvas.draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, rect.size.y - 4), "SEALED", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 4, 8, warm)
	if state_name == "offline":
		canvas.draw_line(rect.position + Vector2(4, 4), rect.end - Vector2(4, 4), Color("#ff8a7e"), 3.0)
		canvas.draw_line(Vector2(rect.end.x - 4, rect.position.y + 4), Vector2(rect.position.x + 4, rect.end.y - 4), Color("#ff8a7e"), 3.0)
	elif state_name == "strained":
		canvas.draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 15, 14), "!", HORIZONTAL_ALIGNMENT_CENTER, 12, 12, Color("#fff0ba"))
	if bool(slot.get("targeted", false)):
		canvas.draw_rect(rect.grow(4), Color("#ff786b"), false, 4.0)
		canvas.draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.18, Color("#ff786b"), false, 2.0)

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
