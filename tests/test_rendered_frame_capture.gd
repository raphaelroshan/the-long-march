extends SceneTree

const RenderCapture = preload("res://tests/support/rendered_frame_capture.gd")
const EVIDENCE_ROOTS := [
	"res://docs/visual_evidence/v0.3.0-alpha.364-gpt56-journey-1280x720",
	"res://docs/visual_evidence/v0.3.0-alpha.364-gpt56-journey-1600x900",
]
const REQUIRED_STATES := [
	"00_title.png",
	"01_first_watch_prologue.png",
	"02_first_watch_departure.png",
	"03_first_watch_arrival.png",
	"04_first_watch_complete.png",
	"05_ashgate_handoff.png",
	"05a_live_refit.png",
	"06_route_commitment.png",
	"07_departure.png",
	"07d_pre_contact_interruption.png",
	"08_road_contact.png",
	"09_arrival_receipt.png",
	"11_specialist_crossroads.png",
	"11b_forge_core_dilemma.png",
	"11_morrowline_recovery.png",
	"11b_cinder_quarry_route.png",
	"11c_cinder_quarry_contact.png",
	"11d_cinder_quarry_recovery.png",
	"11e_forge_core_callback.png",
	"12_final_arrival.png",
	"13_debrief.png",
	"14_playtest_notes.png",
]
const KNOWN_INVALID_GREY_FRAME := "res://docs/visual_evidence/v0.3.0-alpha.363-review-2026-09-03/01_title.png"

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _patterned_image() -> Image:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color("101820"))
	for y in range(8, 56):
		for x in range(8, 56):
			image.set_pixel(x, y, Color(float(x) / 63.0, float(y) / 63.0, float(x + y) / 126.0, 1.0))
	return image


func _check_committed_evidence(root_path: String) -> void:
	var manifest_path := root_path.path_join("capture-manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	_expect(file != null, "capture evidence should include a manifest: " + manifest_path)
	if file == null:
		return
	var manifest = JSON.parse_string(file.get_as_text())
	_expect(manifest is Dictionary, "capture manifest should be valid JSON: " + manifest_path)
	if not manifest is Dictionary:
		return
	_expect(manifest.get("capture_method") == "godot_viewport_after_rendered_frame_gate", "manifest should identify the Godot-controlled capture method")
	_expect(manifest.get("quality_result") == "validated_rendered_frames", "manifest should record validated rendered frames")
	var viewport: Dictionary = manifest.get("viewport", {})
	var expected_size := Vector2i(int(viewport.get("width", 0)), int(viewport.get("height", 0)))
	var states: Array = manifest.get("states", [])
	_expect(states.size() >= REQUIRED_STATES.size(), "capture manifest should list the complete journey state set")
	var listed_files: Array[String] = []
	for state in states:
		if not state is Dictionary:
			failures.append("capture manifest states should be objects")
			continue
		var image_path := root_path.path_join(String(state.get("file", "")))
		listed_files.append(String(state.get("file", "")))
		var image := Image.load_from_file(image_path)
		var inspection := RenderCapture.inspect_image(image, expected_size)
		_expect(bool(inspection.get("ok", false)), "%s should contain a non-uniform rendered frame: %s" % [image_path, inspection.get("reason", "unknown")])
		_expect(FileAccess.get_sha256(image_path) == state.get("sha256"), "capture checksum should match its manifest: " + image_path)
		_expect(int(state.get("attempt", 0)) >= 1 and int(state.get("attempt", 0)) <= 8, "capture manifest should record a bounded readiness attempt: " + image_path)
	for required_state in REQUIRED_STATES:
		_expect(required_state in listed_files, "capture manifest should include required state: " + required_state)


func _init() -> void:
	var flat := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	flat.fill(Color("777777"))
	var flat_result := RenderCapture.inspect_image(flat, Vector2i(64, 64))
	_expect(not bool(flat_result.get("ok", true)) and String(flat_result.get("reason", "")).contains("visually uniform"), "the rendered-frame gate should reject a uniform grey frame")
	var pattern_result := RenderCapture.inspect_image(_patterned_image(), Vector2i(64, 64))
	_expect(bool(pattern_result.get("ok", false)), "the rendered-frame gate should accept a varied rendered image")
	var size_result := RenderCapture.inspect_image(_patterned_image(), Vector2i(1280, 720))
	_expect(not bool(size_result.get("ok", true)) and String(size_result.get("reason", "")).contains("does not match"), "the rendered-frame gate should reject the wrong viewport size")
	var known_invalid := Image.load_from_file(KNOWN_INVALID_GREY_FRAME)
	var known_invalid_result := RenderCapture.inspect_image(known_invalid, Vector2i(1280, 720))
	_expect(not bool(known_invalid_result.get("ok", true)), "the rendered-frame gate should reject the exact uniform-grey frame from the failed review")
	for evidence_root in EVIDENCE_ROOTS:
		_check_committed_evidence(evidence_root)
	if failures.is_empty():
		print("PASS: The Long March LM-GPT56-0 rendered-frame evidence gate")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
