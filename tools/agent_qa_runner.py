#!/usr/bin/env python3
"""Execute and validate one repository-owned semantic QA scenario."""
from __future__ import annotations

import argparse
import hashlib
import json
import locale
import math
import os
import platform
import re
import signal
import shutil
import struct
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


REQUIRED_SCENARIO_FIELDS = {
    "schema_version",
    "game",
    "scenario_id",
    "status",
    "seed",
    "initial_save",
    "viewport",
    "adapter",
    "expected_states",
    "semantic_commands",
    "checkpoints",
    "screenshot_states",
    "terminal_state",
    "time_budget_ms",
    "known_limitations",
}
ERROR_PATTERN = re.compile(r"SCRIPT ERROR:|(^| )ERROR:", re.MULTILINE)


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("root must be a JSON object")
    return value


def unique_string_list(value: object, field: str, errors: list[str]) -> list[str]:
    if not isinstance(value, list) or not value or not all(isinstance(item, str) and item for item in value):
        errors.append(f"{field} must be a non-empty string list")
        return []
    items = list(value)
    if len(items) != len(set(items)):
        errors.append(f"{field} must not contain duplicates")
    return items


def load_scenario(root: Path, scenario_arg: str, expected_game: str) -> tuple[dict[str, Any], str, list[str]]:
    path = Path(scenario_arg)
    if not path.is_absolute():
        path = root / path
    try:
        text = path.read_text(encoding="utf-8")
        data = json.loads(text)
    except (OSError, json.JSONDecodeError) as exc:
        return {}, "", [f"could not read scenario manifest {path}: {exc}"]
    if not isinstance(data, dict):
        return {}, text, ["scenario manifest root must be an object"]

    errors: list[str] = []
    missing = sorted(REQUIRED_SCENARIO_FIELDS - set(data))
    if missing:
        errors.append(f"scenario manifest is missing fields: {', '.join(missing)}")
    if data.get("schema_version") != 2:
        errors.append("scenario schema_version must be 2")
    if data.get("game") != expected_game:
        errors.append(f"scenario game must match --game ({expected_game})")
    if data.get("status") != "implemented":
        errors.append("selected scenario must be implemented, not planned")
    if not isinstance(data.get("seed"), int):
        errors.append("seed must be an integer")
    if data.get("initial_save") != "fresh":
        errors.append("agent QA currently requires initial_save=fresh")
    if not isinstance(data.get("time_budget_ms"), int) or int(data.get("time_budget_ms", 0)) <= 0:
        errors.append("time_budget_ms must be a positive integer")

    expected_states = unique_string_list(data.get("expected_states"), "expected_states", errors)
    semantic_commands = unique_string_list(data.get("semantic_commands"), "semantic_commands", errors)
    checkpoints = unique_string_list(data.get("checkpoints"), "checkpoints", errors)
    screenshots = unique_string_list(data.get("screenshot_states"), "screenshot_states", errors)
    limitations = unique_string_list(data.get("known_limitations"), "known_limitations", errors)
    if expected_states and any(state not in expected_states for state in screenshots):
        errors.append("every screenshot_states entry must also be in expected_states")
    if any(Path(state).name != state or not state.endswith(".png") for state in expected_states):
        errors.append("expected_states must contain safe PNG basenames")

    viewport = data.get("viewport")
    if not isinstance(viewport, dict) or not all(isinstance(viewport.get(key), int) and viewport[key] > 0 for key in ("width", "height")):
        errors.append("viewport must contain positive integer width and height")
    adapter = data.get("adapter")
    if not isinstance(adapter, dict):
        errors.append("adapter must be an object")
    else:
        for field in ("fixture", "profile_id", "journey_id"):
            if not isinstance(adapter.get(field), str) or not adapter[field]:
                errors.append(f"adapter.{field} must be a non-empty string")
        fixture = str(adapter.get("fixture", ""))
        if not fixture.startswith("res://") or not (root / fixture.removeprefix("res://")).is_file():
            errors.append("adapter.fixture must resolve to a repository resource")
        unique_string_list(adapter.get("pass_markers"), "adapter.pass_markers", errors)
        environment = adapter.get("environment")
        if not isinstance(environment, dict) or not all(isinstance(key, str) and isinstance(value, str) for key, value in environment.items()):
            errors.append("adapter.environment must map strings to strings")
    terminal = data.get("terminal_state")
    if not isinstance(terminal, dict) or not terminal:
        errors.append("terminal_state must be a non-empty object")
    if not limitations:
        errors.append("known_limitations must describe at least one evidence boundary")
    return data, text, errors


def command_output(command: list[str], cwd: Path) -> str:
    try:
        return subprocess.run(command, cwd=cwd, check=False, capture_output=True, text=True, timeout=15).stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        return "unavailable"


def project_setting(root: Path, key: str, fallback: str = "unknown") -> str:
    project = (root / "project.godot").read_text(encoding="utf-8")
    match = re.search(rf"^{re.escape(key)}=\"([^\"]+)\"$", project, re.MULTILINE)
    return match.group(1) if match else fallback


def resolve_executable(value: str) -> str | None:
    if os.sep in value or (os.altsep and os.altsep in value):
        path = Path(value).expanduser().resolve()
        return str(path) if path.is_file() and os.access(path, os.X_OK) else None
    return shutil.which(value)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_dimensions(path: Path) -> tuple[int, int] | None:
    try:
        header = path.read_bytes()[:24]
    except OSError:
        return None
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", header[16:24])


def validate_capture(manifest_path: Path, scenario: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    errors: list[str] = []
    try:
        capture = read_json(manifest_path)
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        return {}, [f"capture manifest is missing or invalid: {exc}"]

    viewport = scenario["viewport"]
    expected_size = (int(viewport["width"]), int(viewport["height"]))
    if capture.get("schema_version") != 2:
        errors.append("capture manifest schema_version must be 2")
    if capture.get("capture_method") != "godot_viewport_after_rendered_frame_gate":
        errors.append("capture method is not the rendered-frame gate")
    if capture.get("quality_result") != "validated_rendered_frames":
        errors.append("capture quality_result is not validated_rendered_frames")
    if str(capture.get("game", "")).lower().replace(" ", "-") != scenario.get("game"):
        errors.append("capture game does not match the scenario")
    captured_viewport = capture.get("viewport", {})
    if (captured_viewport.get("width"), captured_viewport.get("height")) != expected_size:
        errors.append(f"capture viewport does not match {expected_size[0]}x{expected_size[1]}")

    adapter = scenario["adapter"]
    contract = capture.get("journey_contract", {})
    for key in ("profile_id", "journey_id"):
        if contract.get(key) != adapter.get(key):
            errors.append(f"journey_contract.{key} does not match the scenario adapter")
    if contract.get("scenario_id") != scenario.get("scenario_id"):
        errors.append("journey_contract.scenario_id does not match the scenario")
    if contract.get("semantic_commands") != scenario.get("semantic_commands"):
        errors.append("captured semantic command trace does not match the scenario")
    for field in ("fresh_save_started", "normal_player_actions", "terminal_complete"):
        if contract.get(field) is not True:
            errors.append(f"journey_contract.{field} must be true")

    checkpoint_ids = [item.get("checkpoint_id") for item in capture.get("resume_checkpoints", []) if isinstance(item, dict)]
    if checkpoint_ids != scenario.get("checkpoints"):
        errors.append("capture checkpoints do not exactly match the scenario")
    terminal = capture.get("terminal_state", {})
    for key, expected in scenario.get("terminal_state", {}).items():
        if terminal.get(key) != expected:
            errors.append(f"terminal_state.{key} is {terminal.get(key)!r}; expected {expected!r}")

    states = capture.get("states")
    if not isinstance(states, list):
        errors.append("capture states must be a list")
        states = []
    listed = [item.get("file") for item in states if isinstance(item, dict)]
    if listed != scenario.get("expected_states"):
        errors.append("captured state sequence does not exactly match expected_states")
    if contract.get("captured_state_count") != len(states):
        errors.append("captured_state_count does not match the state list")

    state_by_file = {item.get("file"): item for item in states if isinstance(item, dict)}
    for filename in scenario.get("expected_states", []):
        state = state_by_file.get(filename)
        if state is None:
            continue
        image_path = manifest_path.parent / filename
        if not image_path.is_file():
            errors.append(f"captured image is missing: {filename}")
            continue
        dimensions = png_dimensions(image_path)
        if dimensions != expected_size:
            errors.append(f"{filename} dimensions are {dimensions}; expected {expected_size}")
        if state.get("width") != expected_size[0] or state.get("height") != expected_size[1]:
            errors.append(f"{filename} manifest dimensions do not match the scenario")
        if state.get("ok") is not True:
            errors.append(f"{filename} was not accepted by the rendered-frame gate")
        if not isinstance(state.get("attempt"), int) or not 1 <= state["attempt"] <= 8:
            errors.append(f"{filename} has an invalid bounded readiness attempt")
        unique_colors = state.get("sampled_unique_colors")
        luminance_range = state.get("luminance_range")
        if not isinstance(unique_colors, int) or unique_colors <= 1 or not isinstance(luminance_range, (int, float)) or luminance_range < 0.01:
            errors.append(f"{filename} lacks rendered-frame variation evidence")
        if state.get("sha256") != sha256(image_path):
            errors.append(f"{filename} checksum does not match its manifest")

    for filename in scenario.get("screenshot_states", []):
        if filename not in state_by_file:
            errors.append(f"required screenshot state is missing: {filename}")
    return capture, errors


def run_process(command: list[str], root: Path, env: dict[str, str], timeout: int) -> tuple[str, int, str, str]:
    try:
        process = subprocess.Popen(
            command,
            cwd=root,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            start_new_session=os.name == "posix",
        )
    except OSError as exc:
        return "blocked", 127, "", str(exc)
    try:
        stdout, stderr = process.communicate(timeout=timeout)
        return "completed", process.returncode, stdout, stderr
    except subprocess.TimeoutExpired:
        if os.name == "posix":
            os.killpg(process.pid, signal.SIGTERM)
        else:
            process.kill()
        try:
            stdout, stderr = process.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            if os.name == "posix":
                os.killpg(process.pid, signal.SIGKILL)
            else:
                process.kill()
            stdout, stderr = process.communicate()
        return "timeout", 124, stdout, stderr


def build_scenario_command(godot: str, root: Path, fixture: str) -> list[str]:
    """Build the visual journey command without probing or mutating the host."""
    # GitHub's Linux runners have no ALSA device. Selecting Dummy explicitly
    # avoids a noisy ERR_CANT_OPEN followed by Godot's identical fallback while
    # preserving strict failure on every error the journey actually emits.
    command = [godot, "--audio-driver", "Dummy", "--path", str(root), "--script", fixture]
    if sys.platform.startswith("linux") and shutil.which("xvfb-run"):
        command = ["xvfb-run", "-a", "--server-args=-screen 0 1280x720x24", *command]
    return command


def write_result(output: Path, result: dict[str, Any]) -> int:
    (output / "qa-result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0 if result["status"] == "PASS" else 1


def reset_output(output: Path) -> None:
    output.mkdir(parents=True, exist_ok=True)
    for name in (
        "qa-result.json",
        "scenario-manifest.json",
        "import.stdout.log",
        "import.stderr.log",
        "scenario.stdout.log",
        "scenario.stderr.log",
    ):
        path = output / name
        if path.is_file() or path.is_symlink():
            path.unlink()
    capture_dir = output / "journey-capture"
    if capture_dir.is_dir():
        shutil.rmtree(capture_dir)
    elif capture_dir.exists() or capture_dir.is_symlink():
        capture_dir.unlink()
    (output / ".gdignore").touch()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--game", required=True)
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=900, help="Maximum scenario timeout in seconds")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    args = parser.parse_args()

    root = Path.cwd().resolve()
    output = args.output.resolve()
    reset_output(output)
    scenario, scenario_text, scenario_errors = load_scenario(root, args.scenario, args.game)
    if scenario_text:
        (output / "scenario-manifest.json").write_text(scenario_text, encoding="utf-8")

    godot = resolve_executable(args.godot)
    engine = command_output([godot, "--version"], root) if godot else "unavailable"
    started = time.time()
    result: dict[str, Any] = {
        "schema_version": 3,
        "game": args.game,
        "commit": command_output(["git", "rev-parse", "HEAD"], root),
        "working_tree_dirty": bool(command_output(["git", "status", "--porcelain"], root)),
        "version": project_setting(root, "config/version"),
        "engine": engine,
        "renderer": project_setting(root, "renderer/rendering_method"),
        "locale": locale.setlocale(locale.LC_CTYPE),
        "platform": platform.platform(),
        "viewport": scenario.get("viewport", {}),
        "seed": scenario.get("seed"),
        "scenario_id": scenario.get("scenario_id"),
        "scenario_status": scenario.get("status", "INVALID"),
        "input_trace": [],
        "state_identifiers": [],
        "screenshot_paths": [],
        "known_limitations": scenario.get("known_limitations", []),
        "status": "UNKNOWN",
    }
    if scenario_errors:
        result.update({"status": "INVALID_EVIDENCE", "exit_code": 2, "duration_ms": 0.0, "errors": scenario_errors})
        return write_result(output, result)
    if godot is None:
        result["command"] = [args.godot, "--path", str(root), "--script", str(scenario["adapter"]["fixture"])]
        result.update({"status": "BLOCKED_ENVIRONMENT", "exit_code": 127, "duration_ms": 0.0, "errors": [f"Godot executable was not found: {args.godot}"]})
        return write_result(output, result)

    capture_dir = output / "journey-capture"
    capture_dir.mkdir(parents=True)
    env = os.environ.copy()
    env.setdefault("GODOT_SILENCE_ROOT_WARNING", "1")
    env.update(scenario["adapter"]["environment"])
    env["LONG_MARCH_CAPTURE_DIR"] = str(capture_dir)
    env["LONG_MARCH_VIEWPORT_WIDTH"] = str(scenario["viewport"]["width"])
    env["LONG_MARCH_VIEWPORT_HEIGHT"] = str(scenario["viewport"]["height"])

    import_command = [godot, "--headless", "--path", str(root), "--import"]
    import_kind, import_code, import_stdout, import_stderr = run_process(import_command, root, env, min(args.timeout, 120))
    (output / "import.stdout.log").write_text(import_stdout, encoding="utf-8")
    (output / "import.stderr.log").write_text(import_stderr, encoding="utf-8")
    if import_kind != "completed" or import_code != 0 or ERROR_PATTERN.search(import_stdout + "\n" + import_stderr):
        status = "BLOCKED_ENVIRONMENT" if import_kind == "blocked" else ("TIMEOUT_PARTIAL" if import_kind == "timeout" else "FAIL")
        result.update({"status": status, "exit_code": import_code, "duration_ms": round((time.time() - started) * 1000, 2), "errors": ["Godot project import failed; inspect import logs."]})
        return write_result(output, result)

    command = build_scenario_command(godot, root, scenario["adapter"]["fixture"])
    timeout_seconds = min(args.timeout, max(1, math.ceil(scenario["time_budget_ms"] / 1000)))
    result["command"] = command
    result["timeout_seconds"] = timeout_seconds
    process_kind, exit_code, stdout, stderr = run_process(command, root, env, timeout_seconds)
    (output / "scenario.stdout.log").write_text(stdout, encoding="utf-8")
    (output / "scenario.stderr.log").write_text(stderr, encoding="utf-8")
    duration_ms = round((time.time() - started) * 1000, 2)
    if process_kind == "blocked":
        result.update({"status": "BLOCKED_ENVIRONMENT", "exit_code": exit_code, "duration_ms": duration_ms, "errors": [stderr]})
        return write_result(output, result)
    if process_kind == "timeout":
        result.update({"status": "TIMEOUT_PARTIAL", "exit_code": 124, "duration_ms": duration_ms, "errors": ["Semantic scenario exceeded its declared time budget; partial logs and captures were retained."]})
        return write_result(output, result)
    process_errors = [marker for marker in scenario["adapter"]["pass_markers"] if marker not in stdout]
    if exit_code != 0 or ERROR_PATTERN.search(stdout + "\n" + stderr) or process_errors:
        errors = [f"missing PASS marker: {marker}" for marker in process_errors]
        if exit_code != 0:
            errors.append(f"scenario process exited {exit_code}")
        if ERROR_PATTERN.search(stdout + "\n" + stderr):
            errors.append("scenario output contains Godot error markers")
        result.update({"status": "FAIL", "exit_code": exit_code, "duration_ms": duration_ms, "errors": errors})
        return write_result(output, result)

    capture_path = capture_dir / "capture-manifest.json"
    capture, capture_errors = validate_capture(capture_path, scenario)
    if capture and capture.get("build") != result["version"]:
        capture_errors.append("capture build does not match project.godot")
    if capture and not str(capture.get("engine", "")).startswith(".".join(engine.split(".")[:3])):
        capture_errors.append("capture engine does not match the executing Godot binary")
    if capture_errors:
        result.update({"status": "INVALID_EVIDENCE", "exit_code": 2, "duration_ms": duration_ms, "errors": capture_errors})
        return write_result(output, result)

    state_files = [state["file"] for state in capture["states"]]
    result.update({
        "status": "PASS",
        "exit_code": 0,
        "duration_ms": duration_ms,
        "input_trace": capture["journey_contract"]["semantic_commands"],
        "state_identifiers": state_files,
        "screenshot_paths": [str(Path("journey-capture") / name) for name in scenario["screenshot_states"]],
        "capture_manifest": "journey-capture/capture-manifest.json",
        "capture_manifest_sha256": sha256(capture_path),
        "terminal_state": capture["terminal_state"],
        "resume_checkpoints": [item["checkpoint_id"] for item in capture["resume_checkpoints"]],
        "scenario_stdout_log": "scenario.stdout.log",
        "scenario_stderr_log": "scenario.stderr.log",
        "import_stdout_log": "import.stdout.log",
        "import_stderr_log": "import.stderr.log",
    })
    return write_result(output, result)


if __name__ == "__main__":
    raise SystemExit(main())
