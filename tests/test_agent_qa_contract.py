#!/usr/bin/env python3
from __future__ import annotations

import json
import importlib.util
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

def main() -> int:
    root = Path(__file__).resolve().parents[1]
    runner_path = root / "tools" / "agent_qa_runner.py"
    spec = importlib.util.spec_from_file_location("agent_qa_runner", runner_path)
    if spec is None or spec.loader is None:
        print("ERROR: could not load tools/agent_qa_runner.py")
        return 1
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    scenario_path = root / "qa" / "scenarios" / "long_march_complete_journey.json"
    scenario, _, scenario_errors = runner.load_scenario(root, str(scenario_path), "the-long-march")
    errors = list(scenario_errors)

    fixture = str(scenario.get("adapter", {}).get("fixture", ""))
    if not fixture.startswith("res://") or not (root / fixture.removeprefix("res://")).is_file():
        errors.append("scenario adapter fixture must resolve to a repository file")
    wrapper = root / "scripts" / "agent_qa.sh"
    if not os.access(wrapper, os.X_OK):
        errors.append("agent QA wrapper must be executable")

    workflow = (root / ".github" / "workflows" / "ci.yml").read_text(encoding="utf-8")
    if workflow.count("run: bash scripts/agent_qa.sh") != 1:
        errors.append("CI must run agent QA exactly once")
    if "  agent-qa:\n" not in workflow or "name: Agent QA complete journey" not in workflow:
        errors.append("CI must expose a dedicated agent-qa job")
    agent_block = workflow.split("  agent-qa:\n", 1)[-1].split("\n  ai-review:", 1)[0]
    if "continue-on-error" in agent_block:
        errors.append("the dedicated agent-qa job must be required")
    if workflow.count("needs: [policy, tests, agent-qa, ai-review]") != 2:
        errors.append("Windows and Linux candidate packaging must require agent QA")
    release_workflow = (root / ".github" / "workflows" / "release.yml").read_text(encoding="utf-8")
    if release_workflow.count("run: bash scripts/agent_qa.sh") != 1 or "needs: agent-qa" not in release_workflow:
        errors.append("tagged releases must run and require one semantic agent-QA journey")
    combined_workflows = workflow + release_workflow
    if combined_workflows.count("include-hidden-files: true") < 2:
        errors.append("agent QA uploads must preserve .gdignore so downstream Godot imports skip evidence PNGs")
    for marker in (
        "--verification agent_qa_complete_journey",
        "--file agent_qa_result=artifacts/agent-qa/qa-result.json",
        "--file agent_qa_capture_manifest=artifacts/agent-qa/journey-capture/capture-manifest.json",
    ):
        if combined_workflows.count(marker) != 3:
            errors.append(f"all three candidate manifest paths must include agent QA provenance: {marker}")
    if (root / "tools" / "agent_qa_capture.gd").exists():
        errors.append("the obsolete editor-surface capture must remain removed")

    journey_command = runner.build_scenario_command("godot", root, fixture)
    if journey_command.count("--audio-driver") != 1:
        errors.append("the visual journey must select an audio driver explicitly")
    else:
        audio_option = journey_command.index("--audio-driver")
        if journey_command[audio_option + 1] != "Dummy":
            errors.append("the non-interactive visual journey must use Godot's Dummy audio driver")

    timeout_kind, timeout_code, _, _ = runner.run_process(
        ["python3", "-c", "import time; time.sleep(2)"], root, os.environ.copy(), 1
    )
    if timeout_kind != "timeout" or timeout_code != 124:
        errors.append("a bounded process must terminate its process group and return timeout/124")

    source_evidence = root / "docs" / "visual_evidence" / "v0.3.0-alpha.364-gpt56-1c-1280x720"
    with tempfile.TemporaryDirectory() as directory:
        evidence = Path(directory) / "journey-capture"
        evidence.mkdir()
        capture = json.loads((source_evidence / "capture-manifest.json").read_text(encoding="utf-8"))
        capture["journey_contract"]["scenario_id"] = scenario.get("scenario_id")
        capture["journey_contract"]["semantic_commands"] = scenario.get("semantic_commands")
        capture["terminal_state"]["seed"] = scenario.get("seed")
        for filename in scenario.get("expected_states", []):
            shutil.copy2(source_evidence / filename, evidence / filename)
        capture_path = evidence / "capture-manifest.json"
        capture_path.write_text(json.dumps(capture), encoding="utf-8")
        _, capture_errors = runner.validate_capture(capture_path, scenario)
        errors.extend(f"valid evidence rejected: {error}" for error in capture_errors)
        capture["journey_contract"]["semantic_commands"] = ["invented_command"]
        capture_path.write_text(json.dumps(capture), encoding="utf-8")
        _, invalid_errors = runner.validate_capture(capture_path, scenario)
        if not any("semantic command trace" in error for error in invalid_errors):
            errors.append("capture validation must reject a mismatched semantic trace")

    with tempfile.TemporaryDirectory() as directory:
        stale_capture = Path(directory) / "journey-capture"
        stale_capture.mkdir()
        (stale_capture / "stale.png").write_bytes(b"stale")
        completed = subprocess.run(
            [
                "python3",
                "tools/agent_qa_runner.py",
                "--game",
                "the-long-march",
                "--scenario",
                str(scenario_path),
                "--output",
                directory,
                "--godot",
                "/definitely/missing/godot",
            ],
            cwd=root,
            check=False,
            capture_output=True,
            text=True,
        )
        blocked = json.loads((Path(directory) / "qa-result.json").read_text(encoding="utf-8"))
        if completed.returncode == 0 or blocked.get("status") != "BLOCKED_ENVIRONMENT":
            errors.append("a missing Godot binary must produce BLOCKED_ENVIRONMENT and fail")
        if stale_capture.exists():
            errors.append("a new QA run must remove stale capture evidence before preflight")
        required_result_fields = {
            "game", "commit", "version", "engine", "renderer", "locale", "viewport", "seed",
            "input_trace", "state_identifiers", "screenshot_paths", "duration_ms", "exit_code", "known_limitations", "command",
        }
        missing_fields = sorted(required_result_fields - set(blocked))
        if missing_fields:
            errors.append(f"QA result is missing provenance fields: {', '.join(missing_fields)}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PASS: The Long March executable agent QA contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
