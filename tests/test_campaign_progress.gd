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
	var ashgate_failure := progress.record_region_result("ashgate_lowlands", "march_failed")
	_expect(bool(ashgate_failure.get("ok", false)) and progress.result_for_region("ashgate_lowlands") == "march_failed" and progress.survived_region_count() == 0, "a terminal failure should be remembered without counting as a survived chapter")
	var ashgate_survival := progress.record_region_result("ashgate_lowlands", "scarred_march")
	_expect(bool(ashgate_survival.get("recorded", false)) and progress.survived_region("ashgate_lowlands") and progress.survived_region_count() == 1, "a later survival should upgrade the stored Ashgate result")
	var ashgate_downgrade := progress.record_region_result("ashgate_lowlands", "march_failed")
	_expect(bool(ashgate_downgrade.get("ok", false)) and not bool(ashgate_downgrade.get("recorded", true)) and progress.result_for_region("ashgate_lowlands") == "scarred_march", "a later failed attempt should not erase a stronger regional result")
	_expect(not bool(progress.record_region_result("ashgate_lowlands", "archive_kept").get("ok", true)) and not bool(progress.record_region_result("unknown_region", "scarred_march").get("ok", true)), "regional results should reject mismatched and unknown stable IDs")

	var restored := CampaignProgress.new(TEST_PATH)
	var restored_result := restored.load_progress()
	_expect(bool(restored_result.get("ok", false)) and restored.has_development("veyru_public_archive_signal") and restored.result_for_region("ashgate_lowlands") == "scarred_march", "valid developments and best regional results should survive a profile reload")

	var legacy := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"schema_version": 1, "developments": ["veyru_public_archive_signal"]}))
	legacy.close()
	var migrated := CampaignProgress.new(TEST_PATH)
	var migrated_result := migrated.load_progress()
	_expect(bool(migrated_result.get("ok", false)) and migrated.has_development("veyru_public_archive_signal") and migrated.region_results.is_empty(), "schema-1 regional records should migrate without inventing chapter results")

	var malformed := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	malformed.store_string(JSON.stringify({"schema_version": 2, "developments": ["veyru_public_archive_signal", "veyru_public_archive_signal"], "region_results": {}}))
	malformed.close()
	var rejected := CampaignProgress.new(TEST_PATH)
	var rejected_result := rejected.load_progress()
	_expect(not bool(rejected_result.get("ok", true)) and rejected.developments.is_empty(), "a duplicate development record should be rejected without partially restoring progress")
	var malformed_result := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	malformed_result.store_string(JSON.stringify({"schema_version": 2, "developments": [], "region_results": {"flooded_veyru": "decisive_march"}}))
	malformed_result.close()
	var rejected_result_ids := CampaignProgress.new(TEST_PATH)
	_expect(not bool(rejected_result_ids.load_progress().get("ok", true)) and rejected_result_ids.region_results.is_empty(), "mismatched regional result IDs should be rejected without partial restoration")

	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)
	if failures.is_empty():
		print("PASS: The Long March campaign progress")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
