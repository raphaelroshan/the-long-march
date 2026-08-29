extends SceneTree

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	var slots := FortressSilhouette.presentation_slots([
		{"id": "engine_a", "family": "engine", "state": "ready", "damaged": false, "sealed": false, "targeted": false},
		{"id": "engine_b", "family": "engine", "state": "offline", "damaged": true, "sealed": true, "targeted": true},
		{"id": "gun", "family": "weapon", "state": "strained", "damaged": false, "sealed": false, "targeted": false},
		{"id": "crew", "family": "crew_room", "state": "ready", "damaged": false, "sealed": false, "targeted": false}
	])
	_expect(slots.size() == 3, "the silhouette should collapse repeated modules into one readable family bay")
	_expect(String(slots[0].get("family", "")) == "engine" and String(slots[0].get("state", "")) == "offline", "a family bay should retain its most severe dependency state")
	_expect(bool(slots[0].get("damaged", false)) and bool(slots[0].get("sealed", false)) and bool(slots[0].get("targeted", false)), "damage, sealing, and targeting should survive family aggregation as separate visual marks")
	_expect(String(slots[1].get("family", "")) == "weapon" and String(slots[1].get("state", "")) == "strained", "a strained weapon should remain distinct from ready and offline systems")
	var defaults := FortressSilhouette.presentation_slots([])
	_expect(defaults.size() == FortressSilhouette.DEFAULT_FAMILIES.size() and String(defaults[0].get("family", "")) == "engine" and String(defaults[2].get("family", "")) == "power", "presentation-only scenes should receive a stable fallback silhouette with a distinct power bay when no live snapshot is available")
	if failures.is_empty():
		print("PASS: The Long March fortress silhouette")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
