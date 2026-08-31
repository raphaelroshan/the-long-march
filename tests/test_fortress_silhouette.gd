extends SceneTree

const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	var slots := FortressSilhouette.presentation_slots([
		{"id": "engine_a", "family": "engine", "state": "ready", "damaged": false, "sealed": false, "targeted": false},
		{"id": "engine_b", "family": "engine", "state": "offline", "damaged": true, "sealed": true, "targeted": true, "selected": true, "repaired": true},
		{"id": "gun", "family": "weapon", "state": "strained", "damaged": false, "sealed": false, "targeted": false},
		{"id": "crew", "family": "crew_room", "state": "ready", "damaged": false, "sealed": false, "targeted": false}
	])
	_expect(slots.size() == 3, "the silhouette should collapse repeated modules into one readable family bay")
	_expect(String(slots[0].get("family", "")) == "engine" and String(slots[0].get("state", "")) == "offline", "a family bay should retain its most severe dependency state")
	_expect(bool(slots[0].get("damaged", false)) and bool(slots[0].get("sealed", false)) and bool(slots[0].get("targeted", false)), "damage, sealing, and targeting should survive family aggregation as separate visual marks")
	_expect(bool(slots[0].get("selected", false)) and bool(slots[0].get("repaired", false)), "presentation-only selection and repair receipts should survive family aggregation without changing the primary condition")
	_expect(String(slots[1].get("family", "")) == "weapon" and String(slots[1].get("state", "")) == "strained", "a strained weapon should remain distinct from ready and offline systems")
	_expect(FortressSilhouette.primary_condition(slots[0]) == "breached", "an offline damaged family should collapse competing interior marks into one breached condition")
	_expect(FortressSilhouette.primary_condition(slots[1]) == "strained", "a dependency warning should remain the primary condition when no damage is present")
	_expect(FortressSilhouette.primary_condition({"state": "ready", "sealed": true, "repaired": true}) == "protected", "an active protection bracket should take precedence over a repair stitch")
	_expect(FortressSilhouette.primary_condition({"state": "ready", "repaired": true}) == "repaired", "a presentation-only repaired flag should have a stable visual condition")
	var defaults := FortressSilhouette.presentation_slots([])
	_expect(defaults.size() == FortressSilhouette.DEFAULT_FAMILIES.size() and String(defaults[0].get("family", "")) == "engine" and String(defaults[2].get("family", "")) == "power", "presentation-only scenes should receive a stable fallback silhouette with a distinct power bay when no live snapshot is available")
	var ashgate := FortressSilhouette.visual_signature({"region_id": "ashgate_lowlands", "mode": "rest", "heat": 6, "heat_limit": 6})
	var veyru := FortressSilhouette.visual_signature({"region_id": "flooded_veyru", "mode": "contact", "heat": 7, "heat_limit": 6})
	_expect(String(ashgate.get("place_treatment", "")) == "dust_industry" and not bool(ashgate.get("overheated", true)), "Ashgate should retain an industrial dust treatment without declaring heat at the safe limit")
	_expect(String(veyru.get("place_treatment", "")) == "rain_waterworks" and bool(veyru.get("overheated", false)), "Veyru and overheat should remain explicit presentation inputs rather than inferred from title copy")
	_expect(String(FortressSilhouette.mode_treatment("travel").get("motion", "")) == "marching" and String(FortressSilhouette.mode_treatment("contact").get("stance", "")) == "combat", "travel and contact should expose visibly different movement and stance treatments")
	_expect(String(FortressSilhouette.mode_treatment("debrief").get("stance", "")) == "scarred", "the returning fortress should retain a dedicated debrief treatment")
	if failures.is_empty():
		print("PASS: The Long March fortress silhouette")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
