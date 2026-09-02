class_name FortressPresentationRegistry
extends RefCounted

const DATA_PATH := "res://content/fortress_presentation.json"

static var _cached_data: Dictionary = {}


static func data() -> Dictionary:
	if _cached_data.is_empty():
		var file := FileAccess.open(DATA_PATH, FileAccess.READ)
		if file == null:
			return {}
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			_cached_data = parsed
	return _cached_data.duplicate(true)


static func actor_id() -> String:
	return String(data().get("actor_id", "long_march_fortress_v1"))


static func mode(mode_id: String) -> Dictionary:
	var registry := data()
	for raw_mode in registry.get("modes", []):
		var entry: Dictionary = raw_mode
		if String(entry.get("id", "")) == mode_id or mode_id in entry.get("aliases", []):
			return entry.duplicate(true)
	for raw_mode in registry.get("modes", []):
		var fallback: Dictionary = raw_mode
		if String(fallback.get("id", "")) == "rest":
			return fallback.duplicate(true)
	return {"id": "rest", "motion": "settled", "stance": "service"}


static func cue(cue_id: String) -> Dictionary:
	for raw_cue in data().get("cues", []):
		var entry: Dictionary = raw_cue
		if String(entry.get("id", "")) == cue_id:
			return entry.duplicate(true)
	return {}
