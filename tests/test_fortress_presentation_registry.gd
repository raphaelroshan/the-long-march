extends SceneTree

const Registry = preload("res://src/presentation/fortress_presentation_registry.gd")
const FortressSilhouette = preload("res://src/ui/fortress_silhouette.gd")
const InterfaceAudio = preload("res://src/support/interface_audio.gd")

var failures: Array[String] = []


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _init() -> void:
	var registry := Registry.data()
	_expect(Registry.actor_id() == "long_march_fortress_v1" and registry.get("simulation_mutation") == false, "one presentation-only actor should own every fortress mode")
	var source_snapshot := {
		"region_id": "ashgate_lowlands",
		"mode": "rest",
		"heat": 7,
		"heat_limit": 6,
		"modules": [
			{"id": "engine", "family": "engine", "state": "strained", "damaged": true, "sealed": false, "targeted": false},
			{"id": "workshop", "family": "workshop", "state": "ready", "damaged": false, "sealed": false, "targeted": false}
		]
	}
	var original := source_snapshot.duplicate(true)
	var signatures: Dictionary = {}
	for mode_id in ["rest", "travel", "contact", "recovery", "debrief"]:
		var view := source_snapshot.duplicate(true)
		view["mode"] = mode_id
		var signature := FortressSilhouette.visual_signature(view)
		signatures[mode_id] = signature
		_expect(String(signature.get("actor_id", "")) == Registry.actor_id(), "%s should retain the shared fortress actor" % mode_id)
		_expect(not String(signature.get("motion_profile", "")).is_empty() and not String(signature.get("stance", "")).is_empty(), "%s should expose a declared motion and stance" % mode_id)
	_expect(source_snapshot == original, "presentation signatures must not mutate their authoritative input snapshot")
	_expect(Dictionary(signatures["rest"]).get("stance") == "service" and Dictionary(signatures["travel"]).get("motion_profile") == "marching", "rest and travel should change purpose without changing actor identity")
	_expect(Dictionary(signatures["contact"]).get("stance") == "combat" and Dictionary(signatures["debrief"]).get("stance") == "scarred", "contact and Debrief should preserve readable mode-specific condition")
	for cue_id in ["engine_strain", "repair", "threat_approach", "impact", "safe_arrival"]:
		var cue := Registry.cue(cue_id)
		var audio_id := String(cue.get("audio", ""))
		_expect(not cue.is_empty() and not String(cue.get("visual", "")).is_empty() and not String(cue.get("reduced_motion", "")).is_empty() and not String(cue.get("high_contrast", "")).is_empty(), "%s should retain visual and accessible equivalents" % cue_id)
		_expect(audio_id == "threat_family" or InterfaceAudio.SEMANTIC_STREAMS.has(audio_id), "%s should reference a bounded runtime audio family" % cue_id)
	if failures.is_empty():
		print("PASS: The Long March LM-GPT56-2 fortress presentation registry")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
