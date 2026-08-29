class_name TutorialDirector
extends RefCounted

const LESSONS := [
	"place_engine",
	"place_weapon",
	"inspect_machine",
	"plan_road",
	"travel",
	"read_contact",
	"respond",
	"damage",
	"victory",
	"repair",
	"complete"
]

const COPY := {
	"place_engine": {"number": "01", "title": "Wake the engine", "reason": "The fortress cannot leave without a working movement chain.", "action": "Install the Steam Lance Engine beside the Coal Cell.", "show": "SELECT ENGINE"},
	"place_weapon": {"number": "02", "title": "Arm the fortress", "reason": "Weapons fire automatically, but only if preparation gives them power and ammunition.", "action": "Install the Repeater Gun beside the Ammunition Lift.", "show": "SELECT WEAPON"},
	"inspect_machine": {"number": "03", "title": "Trace the chains", "reason": "Every system card names its role, dependency, first failure, and counter.", "action": "Inspect the engine and the Repeater Gun on the chassis.", "show": "INSPECT CHASSIS"},
	"plan_road": {"number": "04", "title": "Plan the training road", "reason": "A route spends fuel and time before contact begins.", "action": "Review The Long Road, choose a doctrine, then depart.", "show": "REVIEW ROUTE"},
	"travel": {"number": "05", "title": "Watch the road", "reason": "Departure is committed; arrival is not secured until the contact is resolved.", "action": "Read the travel receipt, then continue to contact.", "show": "CONTINUE"},
	"read_contact": {"number": "06", "title": "Read the contact", "reason": "Approach, target preference, counter, and next damage explain the threat before it lands.", "action": "Inspect the Road Raider dossier before advancing.", "show": "READ DOSSIER"},
	"respond": {"number": "07", "title": "Advance and respond", "reason": "The fortress attacks automatically; you hold one emergency order.", "action": "Advance until a target is named, inspect it, then issue an order.", "show": "ADVANCE CONTACT"},
	"damage": {"number": "08", "title": "Follow the damage", "reason": "Damage matters through the dependency chain, not only through lost durability.", "action": "Inspect the damaged system and read its operating state.", "show": "INSPECT DAMAGE"},
	"victory": {"number": "09", "title": "Secure the road", "reason": "Destroy the contact early or survive the full road timeline.", "action": "Advance until the Road Raider is defeated and acknowledge arrival.", "show": "ADVANCE CONTACT"},
	"repair": {"number": "10", "title": "Restore continuity", "reason": "Recovery is a choice about which future capability matters most.", "action": "Select the damaged system and spend one repair action.", "show": "REPAIR SYSTEM"},
	"complete": {"number": "COMPLETE", "title": "The First Watch", "reason": "You built, read, fought, and restored a working fortress.", "action": "Begin the Ashgate journey or return to the title.", "show": "BEGIN JOURNEY"}
}

var lesson_id: String = "place_engine"
var completed_lessons: Array[String] = []
var inspected_modules: Array[String] = []
var receipt: String = ""
var premature_advance_seen: bool = false

func current_copy() -> Dictionary:
	return Dictionary(COPY.get(lesson_id, COPY.place_engine)).duplicate(true)

func advance(next_lesson: String, completion_receipt: String) -> bool:
	if next_lesson not in LESSONS or next_lesson == lesson_id:
		return false
	if lesson_id not in completed_lessons:
		completed_lessons.append(lesson_id)
	lesson_id = next_lesson
	receipt = completion_receipt
	return true

func observe_state(state: LongMarchState) -> bool:
	if lesson_id == "place_engine" and state.operational("steam_lance_engine"):
		return advance("place_weapon", "ENGINE READY · The adjacent Coal Cell feeds movement. If either system is disabled, the fortress may be unable to leave.")
	if lesson_id == "place_weapon" and state.operational("repeater_gun"):
		return advance("inspect_machine", "WEAPON READY · The Repeater Gun fires automatically. Your work is preparation, analysis, and emergency command.")
	return false

func observe_inspection(module_id: String) -> bool:
	if module_id not in inspected_modules:
		inspected_modules.append(module_id)
	if lesson_id == "inspect_machine" and "steam_lance_engine" in inspected_modules and "repeater_gun" in inspected_modules:
		return advance("plan_road", "CHAINS READ · Movement depends on fuel; weapon output depends on power and adjacent ammunition.")
	return false

func serialize() -> Dictionary:
	return {
		"lesson_id": lesson_id,
		"completed_lessons": completed_lessons.duplicate(),
		"inspected_modules": inspected_modules.duplicate(),
		"receipt": receipt,
		"premature_advance_seen": premature_advance_seen
	}

func restore(data: Dictionary) -> void:
	var restored_lesson := String(data.get("lesson_id", "place_engine"))
	lesson_id = restored_lesson if restored_lesson in LESSONS else "place_engine"
	completed_lessons.clear()
	for value in data.get("completed_lessons", []):
		var lesson := String(value)
		if lesson in LESSONS and lesson not in completed_lessons:
			completed_lessons.append(lesson)
	inspected_modules.clear()
	for value in data.get("inspected_modules", []):
		var module_id := String(value)
		if module_id not in inspected_modules:
			inspected_modules.append(module_id)
	receipt = String(data.get("receipt", ""))
	premature_advance_seen = bool(data.get("premature_advance_seen", false))
