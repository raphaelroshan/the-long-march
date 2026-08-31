class_name PlaytestJournal
extends RefCounted

## Local-only playtest journal. Nothing in this class performs network I/O.

const SCHEMA_VERSION := 1
const DEFAULT_JOURNAL_PATH := "user://the_long_march_playtest_journal.json"

var journal_path: String
var session_started_at: int
var events: Array = []
var fixed_timestamp: int = -1

func _init(path: String = DEFAULT_JOURNAL_PATH, timestamp_override: int = -1) -> void:
	journal_path = path
	fixed_timestamp = timestamp_override
	session_started_at = _now()

func _now() -> int:
	return fixed_timestamp if fixed_timestamp >= 0 else int(Time.get_unix_time_from_system())

func record(event_id: String, properties: Dictionary = {}) -> Dictionary:
	if event_id.strip_edges().is_empty():
		return {"ok": false, "reason": "event id is required"}
	var entry := {
		"schema_version": SCHEMA_VERSION,
		"timestamp_unix": _now(),
		"event": event_id,
		"properties": properties.duplicate(true)
	}
	events.append(entry)
	return _write_journal()

func _write_journal() -> Dictionary:
	var file := FileAccess.open(journal_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": error_string(FileAccess.get_open_error())}
	file.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"session_started_at": session_started_at,
		"events": events
	}, "\t"))
	return {"ok": true, "path": ProjectSettings.globalize_path(journal_path)}

func export_feedback(
	clear_or_satisfying: String,
	confusing_or_frustrating: String,
	replay_score: int,
	final_state: Dictionary,
	build_version: String = "unknown",
	output_path: String = ""
) -> Dictionary:
	var destination := output_path
	if destination.is_empty():
		destination = _available_feedback_path(_now())
	var file := FileAccess.open(destination, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": error_string(FileAccess.get_open_error())}
	var payload := {
		"schema_version": SCHEMA_VERSION,
		"build_version": build_version,
		"created_at_unix": _now(),
		"privacy": "Local file only. No data was uploaded by the game.",
		"answers": {
			"clear_or_satisfying": clear_or_satisfying.strip_edges(),
			"confusing_or_frustrating": confusing_or_frustrating.strip_edges(),
			"replay_score": clampi(replay_score, 1, 5)
		},
		"final_state": final_state.duplicate(true),
		"session_metrics": session_metrics(),
		"session": {
			"started_at_unix": session_started_at,
			"events": events.duplicate(true)
		}
	}
	file.store_string(JSON.stringify(payload, "\t"))
	return {"ok": true, "path": ProjectSettings.globalize_path(destination), "payload": payload}

func session_metrics() -> Dictionary:
	var metrics := {
		"encounter_steps": 0,
		"contact_targets_locked": 0,
		"contact_target_inspections": 0,
		"emergency_orders_used": 0
	}
	for raw_entry in events:
		var event_id := String(Dictionary(raw_entry).get("event", ""))
		match event_id:
			"encounter_step":
				metrics["encounter_steps"] = int(metrics["encounter_steps"]) + 1
			"contact_target_locked":
				metrics["contact_targets_locked"] = int(metrics["contact_targets_locked"]) + 1
			"contact_target_inspected":
				metrics["contact_target_inspections"] = int(metrics["contact_target_inspections"]) + 1
			"intervention_used":
				metrics["emergency_orders_used"] = int(metrics["emergency_orders_used"]) + 1
	return metrics

func _available_feedback_path(timestamp: int) -> String:
	var base_path := "user://the_long_march_feedback_%d.json" % timestamp
	if not FileAccess.file_exists(base_path):
		return base_path
	var copy_number := 2
	while FileAccess.file_exists("user://the_long_march_feedback_%d_%d.json" % [timestamp, copy_number]):
		copy_number += 1
	return "user://the_long_march_feedback_%d_%d.json" % [timestamp, copy_number]
