class_name LongMarchVisualContrast
extends RefCounted

const COLOR_OVERRIDE_NAMES: Array[StringName] = [
	&"font_color",
	&"font_hover_color",
	&"font_pressed_color",
	&"font_focus_color",
	&"font_disabled_color"
]

const PALETTE := {
	"667477": "bdc9cc",
	"6c777a": "b8c4c7",
	"718087": "c5d0d3",
	"738286": "c5d0d3",
	"819095": "d2dcde",
	"829092": "d2dcde",
	"89999e": "d8e2e4",
	"8fa3a7": "d8e2e4",
	"98a5a5": "e0e7e7",
	"98a8aa": "e0e7e7",
	"9aa8aa": "e0e7e7",
	"9faead": "e5ebea",
	"aab6ba": "edf2f2",
	"b7c1bf": "f0f4f3",
	"9fd2c2": "75efff",
	"69d8cf": "75efff",
	"79cfc3": "75efff",
	"9fddbd": "9fffb7",
	"8bd6ad": "9fffb7",
	"aee4cf": "b5ffd0",
	"d4f1e4": "c9ffdc",
	"dcf7e8": "d8ffe5",
	"d8a650": "ffe082",
	"d8b568": "ffe082",
	"d8c389": "ffe6a3",
	"e7c18b": "ffe6a3",
	"e8c58e": "ffe6a3",
	"f0cf96": "ffe6a3",
	"f0d29d": "ffe8ad",
	"f1ddb5": "fff0c7",
	"f1e6cf": "fff4dd",
	"f3dfad": "fff0bf",
	"fff1ce": "fff7df",
	"e06f61": "ff9fa8",
	"e89270": "ff9fa8",
	"e98b72": "ff9fa8",
	"ef8375": "ff9fa8",
	"ff9d8f": "ffb0b7",
	"ffaea2": "ffc0c4",
	"ffd2ca": "ffe0e1",
	"ffd4cd": "ffe0e1",
	"cbb8e8": "dfc2ff",
	"eee2ff": "f3e9ff"
}

static func display_color(base: Color) -> Color:
	var key := base.to_html(false).to_lower()
	var result := Color(String(PALETTE.get(key, key)))
	if not PALETTE.has(key) and base.get_luminance() < 0.52:
		result = base.lightened(0.42)
	result.a = base.a
	return result

static func apply_to_tree(root: Node, enabled: bool) -> void:
	if root is Control:
		_apply_to_control(root as Control, enabled)
	for child in root.get_children():
		apply_to_tree(child, enabled)

static func _apply_to_control(control: Control, enabled: bool) -> void:
	for color_name in COLOR_OVERRIDE_NAMES:
		if not control.has_theme_color_override(color_name):
			continue
		var base_key := "long_march_contrast_base_%s" % String(color_name)
		var applied_key := "long_march_contrast_applied_%s" % String(color_name)
		var current := control.get_theme_color(color_name)
		if enabled:
			if not control.has_meta(base_key) or not control.has_meta(applied_key) or current != control.get_meta(applied_key):
				control.set_meta(base_key, current)
			var adjusted := display_color(control.get_meta(base_key))
			control.add_theme_color_override(color_name, adjusted)
			control.set_meta(applied_key, adjusted)
		elif control.has_meta(base_key):
			control.add_theme_color_override(color_name, control.get_meta(base_key))
			control.remove_meta(base_key)
			control.remove_meta(applied_key)
