class_name CampaignProgress
extends RefCounted

## Small local progression record for consequences that survive individual runs.
## It contains authored development IDs only and performs no network I/O.

const SCHEMA_VERSION := 1
const DEFAULT_PROGRESS_PATH := "user://the_long_march_progress.json"
const VALID_DEVELOPMENTS := ["veyru_public_archive_signal"]

var progress_path: String
var developments: Array[String] = []


func _init(path: String = DEFAULT_PROGRESS_PATH) -> void:
	progress_path = path


func has_development(development_id: String) -> bool:
	return development_id in developments


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


func save() -> Dictionary:
	var file := FileAccess.open(progress_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": error_string(FileAccess.get_open_error())}
	file.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"developments": developments.duplicate()
	}, "\t"))
	file.close()
	return {"ok": true, "path": ProjectSettings.globalize_path(progress_path)}


func load_progress() -> Dictionary:
	developments.clear()
	if not FileAccess.file_exists(progress_path):
		return {"ok": true, "exists": false, "developments": []}
	var file := FileAccess.open(progress_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "exists": true, "reason": "regional record could not be opened"}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {"ok": false, "exists": true, "reason": "regional record is not valid JSON data"}
	if int(parsed.get("schema_version", -1)) != SCHEMA_VERSION:
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
	developments = restored
	return {"ok": true, "exists": true, "developments": developments.duplicate()}
