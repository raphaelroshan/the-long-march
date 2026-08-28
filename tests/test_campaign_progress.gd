extends SceneTree

const CampaignProgress = preload("res://src/support/campaign_progress.gd")
const TEST_PATH := "user://the_long_march_progress_test.json"

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _init() -> void:
	var absolute_path := ProjectSettings.globalize_path(TEST_PATH)
	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)

	var progress := CampaignProgress.new(TEST_PATH)
	var fresh := progress.load_progress()
	_expect(bool(fresh.get("ok", false)) and not bool(fresh.get("exists", true)) and progress.developments.is_empty(), "a missing regional record should load as clean progress")
	var unlocked := progress.unlock("veyru_public_archive_signal")
	_expect(bool(unlocked.get("ok", false)) and bool(unlocked.get("unlocked", false)) and FileAccess.file_exists(absolute_path), "unlocking the public archive signal should persist a local regional record")
	var duplicate := progress.unlock("veyru_public_archive_signal")
	_expect(bool(duplicate.get("ok", false)) and not bool(duplicate.get("unlocked", true)) and progress.developments.size() == 1, "unlocking an existing development should be idempotent")
	_expect(not bool(progress.unlock("unknown_development").get("ok", true)), "unknown regional developments should not be written")

	var restored := CampaignProgress.new(TEST_PATH)
	var restored_result := restored.load_progress()
	_expect(bool(restored_result.get("ok", false)) and restored.has_development("veyru_public_archive_signal"), "a valid regional development should survive a profile reload")

	var malformed := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	malformed.store_string(JSON.stringify({"schema_version": 1, "developments": ["veyru_public_archive_signal", "veyru_public_archive_signal"]}))
	malformed.close()
	var rejected := CampaignProgress.new(TEST_PATH)
	var rejected_result := rejected.load_progress()
	_expect(not bool(rejected_result.get("ok", true)) and rejected.developments.is_empty(), "a duplicate development record should be rejected without partially restoring progress")

	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)
	if failures.is_empty():
		print("PASS: The Long March campaign progress")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
