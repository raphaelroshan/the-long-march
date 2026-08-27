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
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
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
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	if failures.is_empty():
		print("PASS: The Long March complete prototype flow")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
