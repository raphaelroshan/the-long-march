extends SceneTree

var game: Control
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	call_deferred("_run")

func _advance_until_phase(expected_phase: String) -> void:
	for _step in range(8):
		if game.state.phase == expected_phase:
			return
		game.advance_encounter_button.pressed.emit()
		await process_frame

func _run() -> void:
	var save_path := ProjectSettings.globalize_path("user://the_long_march_prototype.save")
	var onboarding_path := ProjectSettings.globalize_path("user://the_long_march_onboarding_v1.complete")
	var journal_path := ProjectSettings.globalize_path("user://the_long_march_playtest_journal.json")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_expect(game.onboarding_overlay.visible, "a first run should open the Marchmaster briefing")
	for _step in range(game.ONBOARDING_STEPS.size()):
		game.onboarding_next_button.pressed.emit()
		await process_frame
	_expect(not game.onboarding_overlay.visible and FileAccess.file_exists(onboarding_path), "completing onboarding should dismiss it and persist the choice")
	_expect(game.state.phase == "refit", "prototype should begin in Ashgate refit")
	game.travel_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "battle", "departure should begin the road battle")
	await _advance_until_phase("settlement")
	_expect(game.state.phase == "settlement", "surviving the road should open Morrowline services")
	var saved_money: int = game.state.money
	game.save_button.pressed.emit()
	await process_frame
	_expect(not game.load_button.disabled, "saving should immediately enable the visible load control")
	game.state.money = 1
	game.load_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "settlement" and game.state.money == saved_money, "JSON save/load should restore settlement state")
	game.settlement_refuel_button.pressed.emit()
	await process_frame
	_expect(game.state.settlement_actions_remaining == 1, "settlement service should consume one action")
	game.final_journey_button.pressed.emit()
	await process_frame
	_expect(game.state.phase == "final_battle", "Morrowline departure should begin the final battle")
	await _advance_until_phase("results")
	_expect(game.state.phase == "results" and game.state.run_complete, "final battle should produce a completed run")
	game.feedback_button.pressed.emit()
	await process_frame
	_expect(game.feedback_overlay.visible, "the final screen should provide an accessible feedback form")
	game._hide_feedback()
	_expect(FileAccess.file_exists(journal_path), "the UI flow should leave a local-only playtest journal")
	for path in [save_path, onboarding_path, journal_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if failures.is_empty():
		print("PASS: The Long March complete prototype flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
