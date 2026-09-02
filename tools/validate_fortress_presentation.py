#!/usr/bin/env python3
"""Validate the shared fortress presentation contract without treating it as simulation."""
import json
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    data = json.loads((root / "content/fortress_presentation.json").read_text(encoding="utf-8"))
    errors: list[str] = []
    modes = {item.get("id"): item for item in data.get("modes", [])}
    cues = {item.get("id"): item for item in data.get("cues", [])}
    required_modes = {"rest", "travel", "contact", "recovery", "debrief"}
    required_cues = {"engine_strain", "repair", "threat_approach", "impact", "safe_arrival"}
    if data.get("schema_version") != 1 or data.get("actor_id") != "long_march_fortress_v1":
        errors.append("presentation registry needs one stable actor identity and schema")
    if data.get("simulation_mutation") is not False:
        errors.append("presentation registry must explicitly prohibit simulation mutation")
    if not required_modes.issubset(modes):
        errors.append("presentation registry is missing required fortress modes")
    if not required_cues.issubset(cues):
        errors.append("presentation registry is missing required visual/audio cues")
    if any(not item.get("motion") or not item.get("stance") or not item.get("purpose") for item in modes.values()):
        errors.append("every fortress mode needs motion, stance, and operational purpose")
    if any(not all(item.get(key) for key in ("visual", "audio", "reduced_motion", "high_contrast")) for item in cues.values()):
        errors.append("every cue needs visual, audio, reduced-motion, and high-contrast forms")
    asset_policy = data.get("asset_policy", {})
    if asset_policy.get("shared_actor") != "code_native_original" or asset_policy.get("final_art_claim") is not False:
        errors.append("asset policy must keep the actor original and temporary assets honest")
    for raw_path in [data.get("renderer"), *(asset_policy.get("temporary_visuals", []))]:
        path = str(raw_path or "")
        if not path.startswith("res://") or not (root / path.removeprefix("res://")).is_file():
            errors.append(f"presentation asset is missing: {path}")
    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1
    print(f"Fortress presentation: PASS ({len(modes)} modes, {len(cues)} bounded cues, shared actor {data['actor_id']})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
