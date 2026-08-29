extends SceneTree

const CAMPAIGN_SAVE := "user://the_long_march_prototype.save"
const TUTORIAL_SAVE := "user://the_long_march_tutorial.save"

var failures: Array[String] = []
var app: Control
var game: Control

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove(path: String) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(absolute):
		DirAccess.remove_absolute(absolute)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove(CAMPAIGN_SAVE)
	_remove("user://the_long_march_prototype.backup.save")
	_remove(TUTORIAL_SAVE)
	_remove("user://the_long_march_tutorial.backup.save")
	_remove("user://the_long_march_tutorial.complete")
	root.size = Vector2i(1280, 720)
	app = load("res://scenes/App.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await process_frame
	_expect(app.tutorial_button.has_focus(), "Learn to Command should be the first-run primary action")
	_expect(app.title_preview_id == "tutorial" and app.title_preview_title_label.text == "Learn by commanding", "the title should explain the interactive tutorial before launch")
	app.tutorial_button.pressed.emit()
	await process_frame
	_expect(app.tutorial_intro.visible and not app.menu_view.visible, "Learn to Command should open the prologue without starting gameplay behind it")
	_expect(app.game_view == null, "reading the prologue must not create or mutate a fortress run")
	_expect(app.tutorial_intro.page_index == 0 and app.tutorial_intro.next_button.has_focus(), "the prologue should begin on its first page with a focused forward action")
	app.text_scale_percent = 110
	app.high_contrast_enabled = true
	app._apply_visual_contrast()
	await process_frame
	var intro_rect: Rect2 = app.tutorial_intro.get_global_rect()
	_expect(app.tutorial_intro.canvas.high_contrast_enabled and intro_rect.encloses(app.tutorial_intro.next_button.get_global_rect()) and intro_rect.encloses(app.tutorial_intro.skip_button.get_global_rect()), "high contrast and 110% text should keep every required prologue action visible")
	app.text_scale_percent = 100
	app.high_contrast_enabled = false
	app.reduced_motion = true
	app._apply_visual_contrast()
	app.tutorial_intro.next_button.pressed.emit()
	app.tutorial_intro.next_button.pressed.emit()
	await process_frame
	_expect(app.tutorial_intro.next_button.text == "ENTER THE MUSTER YARD", "the final prologue page should name the transition into play")
	app.tutorial_intro.next_button.pressed.emit()
	await process_frame
	await process_frame
	game = app.game_view
	_expect(game != null and game.tutorial_mode, "entering the muster yard should create an isolated tutorial stage")
	_expect(game.reduced_motion_enabled and game.journey_transition.reduced_motion, "the tutorial should inherit reduced-motion behavior before travel begins")
	_expect(game.tutorial_director.lesson_id == "place_engine", "the first playable lesson should ask for the engine")
	_expect(game.tutorial_objective_view.visible and game.tutorial_objective_view.action_label.text.contains("Steam Lance Engine"), "the muster yard should show one concrete current order")
	_expect(not FileAccess.file_exists(ProjectSettings.globalize_path(CAMPAIGN_SAVE)), "opening the tutorial must not create or replace the campaign Continue slot")

	game._on_grid_cell_pressed(Vector2i(5, 3))
	await process_frame
	_expect(game.tutorial_director.lesson_id == "place_engine" and game.event_label.text.contains("Placement blocked"), "an invalid engine placement should explain the rejected command without advancing the lesson")
	game._on_grid_cell_pressed(Vector2i(0, 0))
	await process_frame
	_expect(game.state.operational("steam_lance_engine") and game.tutorial_director.lesson_id == "place_weapon", "a fuel-connected engine should complete the movement lesson")
	app._return_to_title()
	await process_frame
	_expect(app.tutorial_button.text.begins_with("RESUME TUTORIAL") and not app.continue_button.visible, "returning from a tutorial checkpoint should offer tutorial resume without creating campaign Continue")
	app.tutorial_button.pressed.emit()
	await process_frame
	await process_frame
	game = app.game_view
	_expect(game.tutorial_mode and game.tutorial_director.lesson_id == "place_weapon" and game.state.operational("steam_lance_engine"), "Resume Tutorial should restore the exact lesson and completed engine placement")
	game.tutorial_objective_view.reset_button.pressed.emit()
	await process_frame
	_expect(game.tutorial_director.lesson_id == "place_weapon" and game.state.stored_module_count("repeater_gun") == 1 and game.state.operational("steam_lance_engine"), "Reset Lesson should restore only the current lesson snapshot")
	game._on_grid_cell_pressed(Vector2i(5, 0))
	await process_frame
	_expect(game.state.operational("repeater_gun") and game.tutorial_director.lesson_id == "inspect_machine", "an ammunition-supported gun should complete the weapon lesson")
	game._on_grid_cell_pressed(Vector2i(0, 0))
	game._on_grid_cell_pressed(Vector2i(5, 0))
	await process_frame
	_expect(game.tutorial_director.lesson_id == "plan_road", "inspecting the movement and weapon chains should open route planning")

	var fuel_before: int = int(game.state.fuel)
	var day_before: int = int(game.state.day)
	var route_preview: Dictionary = game.state.route_preview("safe_road", game._selected_id(game.doctrine_option))
	game.travel_button.pressed.emit()
	await process_frame
	_expect(game.tutorial_director.lesson_id == "travel" and game.journey_transition.visible, "committing the training road should show the in-between travel scene")
	_expect(game.state.fuel == fuel_before - int(route_preview.get("fuel", 0)) and game.state.day == day_before + int(route_preview.get("days", 0)), "the training road should spend its displayed fuel and time exactly once")
	game.journey_transition.continue_button.pressed.emit()
	await process_frame
	_expect(game.tutorial_director.lesson_id == "read_contact" and game.road_contact.visible, "continuing from travel should pause at the contact dossier")
	_expect(game.road_contact.threat_heading.text == "ROAD RAIDER" and game.road_contact.threat_detail.text.contains("APPROACH") and game.road_contact.threat_detail.text.contains("PREFERRED TARGETS") and game.road_contact.threat_detail.text.contains("COUNTER"), "the contact dossier should expose approach, target preference, and counter before combat advances")
	game.road_contact.advance_button.pressed.emit()
	await process_frame
	_expect(game.state.encounter_step == 0 and game.tutorial_director.premature_advance_seen, "the first premature advance should teach the dossier without skipping a combat step")
	game.road_contact.advance_button.pressed.emit()
	await process_frame
	_expect(game.state.encounter_step == 1 and game.tutorial_director.lesson_id == "respond", "a second advance should resolve one real combat step")
	game.road_contact.advance_button.pressed.emit()
	await process_frame
	game.road_contact.intervention_buttons[0].pressed.emit()
	await process_frame
	_expect(game.state.encounter_intervention_used and game.tutorial_director.lesson_id == "damage", "a legal emergency order should open the damage lesson")
	var damaged: Dictionary = game._most_damaged_installed_module()
	_expect(not damaged.is_empty(), "the authored training contact should leave a surviving damaged system to inspect")
	if not damaged.is_empty():
		game._on_grid_cell_pressed(Vector2i(damaged.get("position", Vector2i.ZERO)))
		await process_frame
	_expect(game.tutorial_director.lesson_id == "victory", "inspecting the damaged system should complete the dependency consequence lesson")
	for _step in range(8):
		if not game.state.encounter_active:
			break
		game.road_contact.advance_button.pressed.emit()
		await process_frame
	_expect(game.tutorial_director.lesson_id == "repair" and game.journey_arrival.visible, "resolving contact should show an arrival receipt before recovery")
	game.journey_arrival.continue_button.pressed.emit()
	await process_frame
	damaged = game._most_damaged_installed_module()
	if not damaged.is_empty():
		game._on_grid_cell_pressed(Vector2i(damaged.get("position", Vector2i.ZERO)))
		await process_frame
		game.settlement_repair_button.pressed.emit()
		await process_frame
	_expect(game.tutorial_director.lesson_id == "complete", "repairing the authored damage should complete The First Watch")
	_expect(game.tutorial_completion_view.visible and game.tutorial_completion_view.begin_button.has_focus(), "completion should open an in-world certification screen with a focused campaign handoff")
	_expect(FileAccess.file_exists(ProjectSettings.globalize_path(TUTORIAL_SAVE)) and not FileAccess.file_exists(ProjectSettings.globalize_path(CAMPAIGN_SAVE)), "tutorial checkpoints should remain isolated from campaign Continue")
	game.tutorial_completion_view.repeat_option.select(9)
	game.tutorial_completion_view.repeat_button.pressed.emit()
	await process_frame
	_expect(game.tutorial_director.lesson_id == "repair" and not game.tutorial_completion_view.visible, "the certification screen should reopen an available lesson from its saved starting snapshot")
	damaged = game._most_damaged_installed_module()
	if not damaged.is_empty():
		game._on_grid_cell_pressed(Vector2i(damaged.get("position", Vector2i.ZERO)))
		game.settlement_repair_button.pressed.emit()
		await process_frame
	_expect(game.tutorial_director.lesson_id == "complete", "a repeated recovery lesson should return to certification after using the normal repair command")
	_expect(app.campaign_progress.region_results.is_empty() and app.campaign_progress.developments.is_empty(), "tutorial completion should not grant campaign results or numerical progression")
	game.tutorial_completion_view.begin_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(app.game_view != null and not app.game_view.tutorial_mode and app.game_view.state.campaign_active, "the certification action should hand off into a fresh Ashgate campaign")

	app.queue_free()
	await process_frame
	_remove(TUTORIAL_SAVE)
	_remove("user://the_long_march_tutorial.backup.save")
	var skip_app = load("res://scenes/App.tscn").instantiate()
	root.add_child(skip_app)
	await process_frame
	skip_app.tutorial_button.pressed.emit()
	await process_frame
	skip_app.tutorial_intro.skip_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(skip_app.game_view != null and not skip_app.game_view.tutorial_mode and skip_app.game_view.state.campaign_active, "Skip Tutorial should enter the documented Ashgate campaign without creating tutorial state")
	skip_app.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March guided tutorial")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
