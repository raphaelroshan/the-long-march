class_name CombatPanel
extends VBoxContainer

const MAX_STEPS := 6
const MAX_ENEMIES := 3

var title_label: Label
var order_label: Label
var step_panels: Array[PanelContainer] = []
var step_labels: Array[Label] = []
var enemy_panels: Array[PanelContainer] = []
var enemy_names: Array[Label] = []
var enemy_states: Array[Label] = []
var enemy_counters: Array[Label] = []
var causal_label: Label

func _init() -> void:
	add_theme_constant_override("separation", 7)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color("#e8c58e"))
	add_child(title_label)
	order_label = Label.new()
	order_label.add_theme_font_size_override("font_size", 12)
	order_label.add_theme_color_override("font_color", Color("#aab6ba"))
	add_child(order_label)

	var timeline := HBoxContainer.new()
	timeline.add_theme_constant_override("separation", 5)
	for index in range(MAX_STEPS):
		var step_panel := PanelContainer.new()
		step_panel.custom_minimum_size = Vector2(0, 28)
		step_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var step_label := Label.new()
		step_label.text = str(index + 1)
		step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		step_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		step_label.add_theme_font_size_override("font_size", 11)
		step_panel.add_child(step_label)
		step_panels.append(step_panel)
		step_labels.append(step_label)
		timeline.add_child(step_panel)
	add_child(timeline)

	var enemy_row := HBoxContainer.new()
	enemy_row.add_theme_constant_override("separation", 7)
	for _index in range(MAX_ENEMIES):
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 94)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 2)
		card.add_child(stack)
		var enemy_name := Label.new()
		enemy_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		enemy_name.add_theme_font_size_override("font_size", 13)
		stack.add_child(enemy_name)
		var enemy_state := Label.new()
		enemy_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		enemy_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		enemy_state.add_theme_font_size_override("font_size", 11)
		stack.add_child(enemy_state)
		var counter := Label.new()
		counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		counter.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		counter.add_theme_font_size_override("font_size", 10)
		counter.add_theme_color_override("font_color", Color("#9aa8aa"))
		stack.add_child(counter)
		enemy_panels.append(card)
		enemy_names.append(enemy_name)
		enemy_states.append(enemy_state)
		enemy_counters.append(counter)
		enemy_row.add_child(card)
	add_child(enemy_row)

	causal_label = Label.new()
	causal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	causal_label.add_theme_font_size_override("font_size", 11)
	causal_label.add_theme_color_override("font_color", Color("#c9d2d2"))
	add_child(causal_label)

func _panel_style(background: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(4)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func _latest_causal_lines(report: Array) -> String:
	var useful: Array[String] = []
	for raw_line in report:
		var line := String(raw_line)
		if line.begins_with("Forecast:") or line.begins_with("Route:") or line.begins_with("Step "):
			continue
		useful.append(line)
	var recent := useful.slice(maxi(0, useful.size() - 2), useful.size())
	return "\n".join(recent) if not recent.is_empty() else "Advance one step to reveal attacks, targets, and dependency changes."

func configure(view: Dictionary, enemy_definitions: Dictionary) -> void:
	var step := int(view.get("step", 0))
	var active := bool(view.get("active", false))
	var doctrine := String(view.get("doctrine", "protect_cargo")).replace("_", " ").capitalize()
	var intervention_used := bool(view.get("intervention_used", false))
	var enemies: Array = view.get("enemies", [])
	var target_names: Dictionary = view.get("target_names", {})
	title_label.text = "ACTIVE CONTACT · %s" % String(view.get("location_name", "Unknown road")).to_upper()
	var timeline_status := "Complete" if not active else "Next step %d/%d" % [mini(step + 1, MAX_STEPS), MAX_STEPS]
	order_label.text = "Doctrine: %s   ·   Emergency order: %s   ·   %s" % [doctrine, "spent" if intervention_used else "1 available", timeline_status]
	for index in range(MAX_STEPS):
		var fill := Color("#1b272d")
		var border := Color("#3c4d54")
		var text_color := Color("#718087")
		if index < step:
			fill = Color("#25493e")
			border = Color("#73c99b")
			text_color = Color("#d4f1e4")
			step_labels[index].text = "DONE · %d" % (index + 1)
		elif index == step and active:
			var contact_next := false
			for enemy in enemies:
				if not bool(enemy.get("defeated", false)) and not bool(enemy.get("arrived", false)):
					var definition: Dictionary = enemy_definitions.get(String(enemy.get("id", "")), {})
					if int(definition.get("arrival_step", 0)) == index + 1:
						contact_next = true
						break
			fill = Color("#512f2c") if contact_next else Color("#5a4029")
			border = Color("#ef8375") if contact_next else Color("#e8c58e")
			text_color = Color("#ffd2ca") if contact_next else Color("#fff1ce")
			step_labels[index].text = "%s · %d" % ["CONTACT" if contact_next else "NEXT", index + 1]
		else:
			step_labels[index].text = str(index + 1)
		step_panels[index].add_theme_stylebox_override("panel", _panel_style(fill, border, 2 if index == step and active else 1))
		step_labels[index].add_theme_color_override("font_color", text_color)

	for index in range(MAX_ENEMIES):
		var card := enemy_panels[index]
		if index >= enemies.size():
			card.visible = false
			continue
		card.visible = true
		var enemy: Dictionary = enemies[index]
		var enemy_id := String(enemy.get("id", ""))
		var definition: Dictionary = enemy_definitions.get(enemy_id, {})
		var defeated := bool(enemy.get("defeated", false))
		var arrived := bool(enemy.get("arrived", false))
		var target := String(enemy.get("target", ""))
		var fill := Color("#1d3038")
		var border := Color("#527786")
		var state_color := Color("#9eced7")
		if defeated:
			fill = Color("#203d35")
			border = Color("#73c99b")
			state_color = Color("#8bd6ad")
		elif arrived:
			fill = Color("#482b29")
			border = Color("#ef8375")
			state_color = Color("#ffaea2")
		card.add_theme_stylebox_override("panel", _panel_style(fill, border, 2))
		enemy_names[index].text = String(definition.get("name", enemy_id)).to_upper()
		var health_word := "pressure" if enemy_id == "storm_front" else "HP"
		var steps_out := maxi(1, int(definition.get("arrival_step", 0)) - step)
		var contact_state := "CLEARED" if defeated and enemy_id == "storm_front" else ("DEFEATED" if defeated else ("CONTACT" if arrived else "APPROACHING · %d STEP%s OUT" % [steps_out, "" if steps_out == 1 else "S"]))
		var target_name := String(target_names.get(target, target.replace("_", " ").capitalize()))
		var target_text := " · TARGET %s" % target_name.to_upper() if arrived and not target.is_empty() and not defeated else ""
		enemy_states[index].text = "%s\n%s %d/%d%s" % [contact_state, health_word, int(enemy.get("hp", 0)), int(enemy.get("max_hp", 0)), target_text]
		enemy_states[index].add_theme_color_override("font_color", state_color)
		enemy_counters[index].text = "Counter: %s" % String(definition.get("counter", "unknown"))
		card.tooltip_text = "%s approaches by %s and prioritizes %s." % [String(definition.get("name", enemy_id)), String(definition.get("route", "the road")), ", ".join(definition.get("target_tags", []))]
	causal_label.text = "LATEST CAUSE & EFFECT\n%s" % _latest_causal_lines(view.get("report", []))
