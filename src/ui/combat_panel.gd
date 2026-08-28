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
	var latest_step_index := -1
	for index in range(report.size()):
		if String(report[index]).begins_with("Step "):
			latest_step_index = index
	var useful: Array[String] = []
	for index in range(latest_step_index + 1, report.size()):
		var raw_line = report[index]
		var line := String(raw_line)
		if line.begins_with("Forecast:") or line.begins_with("Route:") or line.begins_with("Step "):
			continue
		useful.append(line)
	if useful.is_empty():
		return "Advance one step to reveal attacks, targets, and dependency changes."

	var latest_impact_index := -1
	for index in range(useful.size() - 1, -1, -1):
		var line := useful[index]
		if " hits " in line or "reaches the hull" in line:
			latest_impact_index = index
			break
	if latest_impact_index < 0:
		return "\n".join(useful.slice(maxi(0, useful.size() - 3), useful.size()))

	var receipt: Array[String] = []
	var consequence_count := useful.size() - latest_impact_index - 1
	if consequence_count < 3:
		for index in range(latest_impact_index - 1, -1, -1):
			var context := useful[index]
			if " absorbs " in context or context.begins_with("Protect ") or context.begins_with("Run Hot ") or context.begins_with("Open heat vents "):
				receipt.push_front(context)
				break
	receipt.append(useful[latest_impact_index])
	var consequence_start := maxi(latest_impact_index + 1, useful.size() - 3)
	for index in range(consequence_start, useful.size()):
		receipt.append(useful[index])
	return "\n".join(receipt)

func configure(view: Dictionary, enemy_definitions: Dictionary) -> void:
	var step := int(view.get("step", 0))
	var active := bool(view.get("active", false))
	var doctrine_id := String(view.get("doctrine", "protect_cargo"))
	var doctrine := doctrine_id.replace("_", " ").capitalize()
	var intervention_used := bool(view.get("intervention_used", false))
	var enemies: Array = view.get("enemies", [])
	var target_names: Dictionary = view.get("target_names", {})
	var unresolved_contact := false
	for enemy in enemies:
		if bool(enemy.get("arrived", false)) and not bool(enemy.get("defeated", false)):
			unresolved_contact = true
			break
	var contact_heading := "ACTIVE CONTACT" if unresolved_contact else ("CONTACT APPROACHING" if active else "CONTACT CLEARED")
	title_label.text = "%s · %s" % [contact_heading, String(view.get("location_name", "Unknown road")).to_upper()]
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
		var impact: Dictionary = enemy.get("impact", {})
		var target_text := ""
		if arrived and not target.is_empty() and not defeated and not impact.is_empty():
			var damage := int(impact.get("damage", 0))
			var current_durability := int(impact.get("current_durability", 0))
			var remaining_durability := int(impact.get("remaining_durability", maxi(0, current_durability - damage)))
			var terminal_warning := " · HULL COLLAPSE" if target == "hull" and remaining_durability <= 0 else (" · DISABLES SYSTEM" if remaining_durability <= 0 else "")
			target_text = "\nTARGET · %s\nWHY · %s\nNEXT · %d DAMAGE · %d→%d%s" % [target_name.to_upper(), String(impact.get("target_reason", "target route matched")).to_upper(), damage, current_durability, remaining_durability, terminal_warning]
			var armor_absorbed := int(impact.get("armor_absorbed", 0))
			if armor_absorbed > 0:
				var armor_id := String(impact.get("armor_id", "armor"))
				var armor_name := String(target_names.get(armor_id, armor_id.replace("_", " ").capitalize()))
				var armor_before := int(impact.get("armor_current_durability", 0))
				var armor_after := int(impact.get("armor_remaining_durability", maxi(0, armor_before - armor_absorbed)))
				var armor_warning := " · BREAKS" if armor_after <= 0 else ""
				target_text += "\nARMOR · %s · %d→%d%s" % [armor_name.to_upper(), armor_before, armor_after, armor_warning]
			var dependency_changes: Array = impact.get("dependency_changes", [])
			if not dependency_changes.is_empty():
				var cascade_labels: Array[String] = []
				for change_index in range(mini(2, dependency_changes.size())):
					var change: Dictionary = dependency_changes[change_index]
					cascade_labels.append("%s → %s" % [String(change.get("name", "system")).to_upper(), String(change.get("to", "offline")).to_upper()])
				var hidden_count := dependency_changes.size() - cascade_labels.size()
				target_text += "\nCASCADE · %s%s" % [", ".join(cascade_labels), " · +%d MORE" % hidden_count if hidden_count > 0 else ""]
		enemy_states[index].text = "%s\n%s %d/%d%s" % [contact_state, health_word, int(enemy.get("hp", 0)), int(enemy.get("max_hp", 0)), target_text]
		enemy_states[index].add_theme_color_override("font_color", state_color)
		var priority_labels: Array[String] = []
		for raw_tag in definition.get("target_tags", []):
			priority_labels.append(String(raw_tag).replace("_", " "))
		var doctrine_guard := ""
		if doctrine_id == "protect_cargo" and enemy_id == "road_raiders":
			doctrine_guard = " · Protect Cargo active"
		elif doctrine_id == "protect_crew" and enemy_id in ["climbers", "siege_beast"]:
			doctrine_guard = " · Protect Crew active"
		enemy_counters[index].text = "Seeks: %s%s\nCounter: %s" % [" / ".join(priority_labels), doctrine_guard, String(definition.get("counter", "unknown"))]
		card.tooltip_text = "%s approaches by %s and prioritizes %s." % [String(definition.get("name", enemy_id)), String(definition.get("route", "the road")), ", ".join(definition.get("target_tags", []))]
	causal_label.text = "LATEST CAUSE & EFFECT\n%s" % _latest_causal_lines(view.get("report", []))
