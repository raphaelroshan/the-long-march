class_name CampaignProgress
extends RefCounted

## Small local progression record for consequences and results that survive runs.
## It contains authored stable IDs only and performs no network I/O.

const SCHEMA_VERSION := 2
const MIN_SUPPORTED_SCHEMA_VERSION := 1
const DEFAULT_PROGRESS_PATH := "user://the_long_march_progress.json"
const VALID_DEVELOPMENTS := ["veyru_public_archive_signal"]
const REGION_RESULT_RANKS := {
	"ashgate_lowlands": {
		"march_failed": 0,
		"scarred_march": 1,
		"decisive_march": 2
	},
	"flooded_veyru": {
		"veyru_lost": 0,
		"archive_scarred": 1,
		"archive_kept": 2
	}
}

var progress_path: String
var developments: Array[String] = []
var region_results: Dictionary = {}


func _init(path: String = DEFAULT_PROGRESS_PATH) -> void:
	progress_path = path


func has_development(development_id: String) -> bool:
	return development_id in developments


func result_for_region(region_id: String) -> String:
	return String(region_results.get(region_id, ""))


func survived_region(region_id: String) -> bool:
	var result_id := result_for_region(region_id)
	return not result_id.is_empty() and int(REGION_RESULT_RANKS.get(region_id, {}).get(result_id, 0)) > 0


func survived_region_count() -> int:
	var count := 0
	for region_id in REGION_RESULT_RANKS:
		if survived_region(String(region_id)):
			count += 1
	return count


func unlock(development_id: String) -> Dictionary:
	if development_id not in VALID_DEVELOPMENTS:
		return {"ok": false, "reason": "unknown regional development"}
	if development_id in developments:
		return {"ok": true, "unlocked": false, "development": development_id}
	developments.append(development_id)
	developments.sort()
	var saved := save()
	if not bool(saved.get("ok", false)):
		developments.erase(development_id)
		return saved
	return {"ok": true, "unlocked": true, "development": development_id, "path": saved.get("path", "")}


func record_region_result(region_id: String, result_id: String) -> Dictionary:
	var ranks: Dictionary = REGION_RESULT_RANKS.get(region_id, {})
	if ranks.is_empty() or result_id not in ranks:
		return {"ok": false, "reason": "unknown regional result"}
	var previous_result := result_for_region(region_id)
	if not previous_result.is_empty() and int(ranks.get(previous_result, -1)) >= int(ranks.get(result_id, -1)):
		return {"ok": true, "recorded": false, "region": region_id, "result": previous_result}
	region_results[region_id] = result_id
	var saved := save()
	if not bool(saved.get("ok", false)):
		if previous_result.is_empty():
			region_results.erase(region_id)
		else:
			region_results[region_id] = previous_result
		return saved
	return {"ok": true, "recorded": true, "region": region_id, "result": result_id, "path": saved.get("path", "")}


func clear_progress() -> Dictionary:
	var absolute_path := ProjectSettings.globalize_path(progress_path)
	if FileAccess.file_exists(absolute_path):
		var removal_error := DirAccess.remove_absolute(absolute_path)
		if removal_error != OK:
			return {"ok": false, "reason": error_string(removal_error)}
	developments.clear()
	region_results.clear()
	return {"ok": true, "cleared": true}


func save() -> Dictionary:
	var file := FileAccess.open(progress_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": error_string(FileAccess.get_open_error())}
	file.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"developments": developments.duplicate(),
		"region_results": region_results.duplicate(true)
	}, "\t"))
	file.close()
	return {"ok": true, "path": ProjectSettings.globalize_path(progress_path)}


func load_progress() -> Dictionary:
	developments.clear()
	region_results.clear()
	if not FileAccess.file_exists(progress_path):
		return {"ok": true, "exists": false, "developments": []}
	var file := FileAccess.open(progress_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "exists": true, "reason": "regional record could not be opened"}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {"ok": false, "exists": true, "reason": "regional record is not valid JSON data"}
	var schema_version := int(parsed.get("schema_version", -1))
	if schema_version < MIN_SUPPORTED_SCHEMA_VERSION or schema_version > SCHEMA_VERSION:
		return {"ok": false, "exists": true, "reason": "regional record uses an incompatible format"}
	var raw_developments: Variant = parsed.get("developments", [])
	if not raw_developments is Array or raw_developments.size() > VALID_DEVELOPMENTS.size():
		return {"ok": false, "exists": true, "reason": "regional development list is malformed"}
	var restored: Array[String] = []
	for raw_id in raw_developments:
		var development_id := String(raw_id)
		if development_id not in VALID_DEVELOPMENTS:
			return {"ok": false, "exists": true, "reason": "regional record contains an unknown development"}
		if development_id in restored:
			return {"ok": false, "exists": true, "reason": "regional record contains a duplicate development"}
		restored.append(development_id)
	restored.sort()
	var raw_region_results: Variant = parsed.get("region_results", {})
	if not raw_region_results is Dictionary or raw_region_results.size() > REGION_RESULT_RANKS.size():
		return {"ok": false, "exists": true, "reason": "regional result record is malformed"}
	var restored_results: Dictionary = {}
	for raw_region_id in raw_region_results:
		var region_id := String(raw_region_id)
		var result_id := String(raw_region_results[raw_region_id])
		var ranks: Dictionary = REGION_RESULT_RANKS.get(region_id, {})
		if ranks.is_empty() or result_id not in ranks:
			return {"ok": false, "exists": true, "reason": "regional record contains an unknown result"}
		restored_results[region_id] = result_id
	developments = restored
	region_results = restored_results
	return {"ok": true, "exists": true, "developments": developments.duplicate(), "region_results": region_results.duplicate(true)}
