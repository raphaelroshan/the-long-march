extends SceneTree

const VisualContrast = preload("res://src/support/visual_contrast.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var host := Control.new()
	root.add_child(host)
	var muted_label := Label.new()
	muted_label.add_theme_color_override("font_color", Color("#718087"))
	host.add_child(muted_label)
	var status_label := Label.new()
	status_label.add_theme_color_override("font_color", Color("#ef8375"))
	host.add_child(status_label)
	VisualContrast.apply_to_tree(host, true)
	_expect(muted_label.get_theme_color("font_color") == Color("#c5d0d3"), "high contrast should brighten muted supporting copy through the reviewed palette")
	_expect(status_label.get_theme_color("font_color") == Color("#ff9fa8"), "high contrast should preserve a distinct warning family while increasing contrast")
	var first_adjusted := muted_label.get_theme_color("font_color")
	VisualContrast.apply_to_tree(host, true)
	_expect(muted_label.get_theme_color("font_color") == first_adjusted, "reapplying high contrast should be idempotent")
	status_label.add_theme_color_override("font_color", Color("#d8b568"))
	VisualContrast.apply_to_tree(host, true)
	_expect(status_label.get_theme_color("font_color") == Color("#ffe082"), "a status that changes while contrast is active should adopt the matching high-contrast tone")
	VisualContrast.apply_to_tree(host, false)
	_expect(muted_label.get_theme_color("font_color") == Color("#718087"), "disabling contrast should restore the original muted copy color")
	_expect(status_label.get_theme_color("font_color") == Color("#d8b568"), "disabling contrast should restore the latest semantic base color")
	var translucent := Color("#9fd2c280")
	_expect(is_equal_approx(VisualContrast.display_color(translucent).a, translucent.a), "contrast mapping should preserve authored transparency")
	host.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: The Long March visual contrast")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
