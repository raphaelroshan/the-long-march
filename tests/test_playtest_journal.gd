extends SceneTree

const PlaytestJournal = preload("res://src/support/playtest_journal.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	var journal_path := "user://the_long_march_journal_test.json"
	var feedback_path := "user://the_long_march_feedback_test.json"
	for path in [journal_path, feedback_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var journal := PlaytestJournal.new(journal_path, 1700000000)
	var recorded: Dictionary = journal.record("route_started", {"route": "safe_road", "doctrine": "protect_cargo"})
	_expect(bool(recorded.get("ok", false)), "a playtest event should be written locally")
	_expect(FileAccess.file_exists(journal_path), "the local journal file should exist")
	var journal_data = JSON.parse_string(FileAccess.get_file_as_string(journal_path))
	_expect(journal_data is Dictionary and journal_data.get("events", []).size() == 1, "the journal should contain the recorded event")

	var exported: Dictionary = journal.export_feedback("Readable dependencies", "Route risk needs context", 4, {"phase": "results", "final_result": "scarred_march"}, feedback_path)
	_expect(bool(exported.get("ok", false)), "feedback should export to an explicit local path")
	var feedback_data = JSON.parse_string(FileAccess.get_file_as_string(feedback_path))
	_expect(feedback_data is Dictionary and String(feedback_data.get("privacy", "")).contains("No data was uploaded"), "feedback should state its local-only privacy contract")
	_expect(int(feedback_data.get("answers", {}).get("replay_score", 0)) == 4, "feedback should preserve the replay score")
	_expect(String(feedback_data.get("final_state", {}).get("final_result", "")) == "scarred_march", "feedback should include the final prototype state")

	for path in [journal_path, feedback_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if failures.is_empty():
		print("PASS: The Long March local playtest journal")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
