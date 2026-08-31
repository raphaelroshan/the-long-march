extends SceneTree

const PlaytestJournal = preload("res://src/support/playtest_journal.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	var journal_path := "user://the_long_march_journal_test.json"
	var feedback_path := "user://the_long_march_feedback_test.json"
	var automatic_feedback_path := "user://the_long_march_feedback_1700000000.json"
	var automatic_feedback_copy_path := "user://the_long_march_feedback_1700000000_2.json"
	for path in [journal_path, feedback_path, automatic_feedback_path, automatic_feedback_copy_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var journal := PlaytestJournal.new(journal_path, 1700000000)
	var recorded: Dictionary = journal.record("route_started", {"route": "safe_road", "doctrine": "protect_cargo"})
	_expect(bool(recorded.get("ok", false)), "a playtest event should be written locally")
	_expect(FileAccess.file_exists(journal_path), "the local journal file should exist")
	var journal_data = JSON.parse_string(FileAccess.get_file_as_string(journal_path))
	_expect(journal_data is Dictionary and journal_data.get("events", []).size() == 1, "the journal should contain the recorded event")
	journal.record("encounter_step", {"leg": 1, "step": 2})
	journal.record("contact_target_locked", {"enemy": "road_raiders", "target": "coal_cell"})
	journal.record("contact_target_inspected", {"enemy": "road_raiders", "target": "coal_cell"})
	journal.record("intervention_used", {"intervention": "seal_compartment", "step": 2})

	var exported: Dictionary = journal.export_feedback("Readable dependencies", "Route risk needs context", "A disabled engine caused the stop; repair it first.", 4, {"phase": "results", "final_result": "scarred_march"}, "0.3.0-test", feedback_path)
	_expect(bool(exported.get("ok", false)), "feedback should export to an explicit local path")
	var feedback_data = JSON.parse_string(FileAccess.get_file_as_string(feedback_path))
	_expect(feedback_data is Dictionary and String(feedback_data.get("privacy", "")).contains("No data was uploaded"), "feedback should state its local-only privacy contract")
	_expect(String(feedback_data.get("build_version", "")) == "0.3.0-test", "feedback should identify the exact playtest build")
	_expect(int(feedback_data.get("answers", {}).get("replay_score", 0)) == 4, "feedback should preserve the replay score")
	_expect(String(feedback_data.get("answers", {}).get("causal_replay", "")).contains("disabled engine"), "feedback should preserve the tester's causal explanation and next-run change")
	_expect(String(feedback_data.get("final_state", {}).get("final_result", "")) == "scarred_march", "feedback should include the final prototype state")
	var metrics: Dictionary = feedback_data.get("session_metrics", {})
	_expect(int(metrics.get("encounter_steps", 0)) == 1 and int(metrics.get("contact_targets_locked", 0)) == 1 and int(metrics.get("contact_target_inspections", 0)) == 1 and int(metrics.get("emergency_orders_used", 0)) == 1, "feedback should summarize local contact-comprehension events without uploading data")
	var first_automatic: Dictionary = journal.export_feedback("First", "", "", 3, {"phase": "results"}, "0.3.0-test")
	var second_automatic: Dictionary = journal.export_feedback("Second", "", "", 3, {"phase": "results"}, "0.3.0-test")
	_expect(String(first_automatic.get("path", "")) != String(second_automatic.get("path", "")), "rapid feedback saves should receive distinct filenames")
	_expect(FileAccess.file_exists(String(first_automatic.get("path", ""))) and FileAccess.file_exists(String(second_automatic.get("path", ""))), "each repeated feedback save should remain available")

	for path in [journal_path, feedback_path, automatic_feedback_path, automatic_feedback_copy_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if failures.is_empty():
		print("PASS: The Long March local playtest journal")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
