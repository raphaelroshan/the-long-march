extends RefCounted
class_name RenderedFrameCapture

const MIN_UNIQUE_SAMPLE_COLORS := 8
const MIN_LUMINANCE_RANGE := 0.05
const SAMPLE_COLUMNS := 32
const SAMPLE_ROWS := 18


static func inspect_image(image: Image, expected_size: Vector2i) -> Dictionary:
	if image == null or image.is_empty():
		return {"ok": false, "reason": "viewport returned no image"}
	var actual_size := Vector2i(image.get_width(), image.get_height())
	if actual_size != expected_size:
		return {"ok": false, "reason": "frame size %s does not match expected %s" % [actual_size, expected_size], "width": actual_size.x, "height": actual_size.y}
	var colors := {}
	var minimum_luminance := 1.0
	var maximum_luminance := 0.0
	var opaque_samples := 0
	var step_x: int = maxi(1, int(image.get_width() / SAMPLE_COLUMNS))
	var step_y: int = maxi(1, int(image.get_height() / SAMPLE_ROWS))
	for y in range(int(step_y / 2), image.get_height(), step_y):
		for x in range(int(step_x / 2), image.get_width(), step_x):
			var color := image.get_pixel(x, y)
			if color.a > 0.05:
				opaque_samples += 1
			var luminance := color.get_luminance()
			minimum_luminance = minf(minimum_luminance, luminance)
			maximum_luminance = maxf(maximum_luminance, luminance)
			var key := "%d:%d:%d:%d" % [roundi(color.r * 31.0), roundi(color.g * 31.0), roundi(color.b * 31.0), roundi(color.a * 7.0)]
			colors[key] = true
	var luminance_range := maximum_luminance - minimum_luminance
	var unique_colors := colors.size()
	var ok := opaque_samples > 0 and unique_colors >= MIN_UNIQUE_SAMPLE_COLORS and luminance_range >= MIN_LUMINANCE_RANGE
	return {
		"ok": ok,
		"reason": "" if ok else "frame is blank or visually uniform (%d sampled colors, %.4f luminance range)" % [unique_colors, luminance_range],
		"width": actual_size.x,
		"height": actual_size.y,
		"sampled_unique_colors": unique_colors,
		"luminance_range": snappedf(luminance_range, 0.0001),
		"opaque_samples": opaque_samples,
	}


static func capture(tree: SceneTree, output_path: String, expected_size: Vector2i, maximum_attempts: int = 8) -> Dictionary:
	var last_inspection: Dictionary = {"ok": false, "reason": "no rendered frame was inspected"}
	for attempt in range(1, maximum_attempts + 1):
		await tree.process_frame
		await RenderingServer.frame_post_draw
		var image := tree.root.get_texture().get_image()
		last_inspection = inspect_image(image, expected_size)
		last_inspection["attempt"] = attempt
		if bool(last_inspection.get("ok", false)):
			var save_result := image.save_png(output_path)
			if save_result != OK:
				last_inspection["ok"] = false
				last_inspection["reason"] = "could not write rendered frame (%s)" % error_string(save_result)
				return last_inspection
			last_inspection["sha256"] = FileAccess.get_sha256(output_path)
			last_inspection["file"] = output_path.get_file()
			return last_inspection
	return last_inspection
